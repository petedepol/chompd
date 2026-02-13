# Chompd — Supabase Backend Integration

## Context
Chompd is currently fully client-side: subscriptions live in-memory (Isar declared but not wired), dodged traps in SharedPreferences, purchase state in-memory, and the Anthropic API key ships in the app binary. This plan adds Supabase as the backend for auth, cloud sync, AI API proxy, and analytics — while keeping the app offline-first with Isar as local source of truth.

**Key principles:**
- Zero friction: anonymous auth on first launch, no login screen
- Offline-first: Isar is the UI source of truth, Supabase syncs in background
- Last-write-wins: `updated_at` timestamp for conflict resolution
- Soft deletes: `deleted_at` field so deletions sync across devices

---

## Phase 1 — Supabase Project + Flutter Init (~15 min)

### 1a. Create Supabase project
- Dashboard: new project `chompd-production`, EU West region
- Save Project URL + Anon Key
- Enable Anonymous Sign-Ins (Authentication > Providers)
- Enable Cloudflare Turnstile CAPTCHA on auth
- Set rate limit: 30 anonymous sign-ups/hour

### 1b. Flutter dependencies

**Modify `pubspec.yaml`:**
```yaml
dependencies:
  supabase_flutter: ^2.8.0
  connectivity_plus: ^6.1.0
```

### 1c. Initialise Supabase

**Modify `lib/main.dart`** — add before existing init sequence:
```dart
await Supabase.initialize(
  url: const String.fromEnvironment('SUPABASE_URL'),
  anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
);
```

**Create `.env.example`** (document required vars, add `.env` to `.gitignore`):
```
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_ANON_KEY=eyJhbG...
ANTHROPIC_API_KEY=sk-ant-...
```

Build command becomes:
```
flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=... --dart-define=ANTHROPIC_API_KEY=...
```

### Verification
- App launches without crash
- `Supabase.instance.client` accessible

---

## Phase 2 — Authentication (~20 min)

### 2a. Create `lib/services/auth_service.dart` (NEW)

Singleton following existing pattern (`AuthService._()` + `static final instance`):

```dart
class AuthService {
  AuthService._();
  static final instance = AuthService._();

  SupabaseClient get _client => Supabase.instance.client;

  Future<User> ensureUser() async {
    final current = _client.auth.currentUser;
    if (current != null) return current;
    final response = await _client.auth.signInAnonymously();
    return response.user!;
  }

  bool get isAnonymous => _client.auth.currentUser?.isAnonymous ?? true;
  bool get isSignedIn => _client.auth.currentUser != null;
  String? get userId => _client.auth.currentUser?.id;

  Future<void> linkAppleSignIn(String idToken, String nonce) async {
    await _client.auth.signInWithIdToken(
      provider: OAuthProvider.apple,
      idToken: idToken,
      nonce: nonce,
    );
  }

  Future<void> linkGoogleSignIn(String idToken, String accessToken) async {
    await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
  }

  Future<void> linkEmail(String email, String password) async {
    await _client.auth.updateUser(
      UserAttributes(email: email, password: password),
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;
}
```

### 2b. Create `lib/providers/auth_provider.dart` (NEW)

```dart
final authProvider = StateNotifierProvider<AuthNotifier, AuthServiceState>(...);
// States: initialising, anonymous, signedIn, offline
```

### 2c. Wire into app startup

**Modify `lib/main.dart`** — after Supabase.initialize:
```dart
try {
  await AuthService.instance.ensureUser();
} catch (e) {
  debugPrint('Auth deferred (offline): $e');
}
```

### 2d. Enable providers in Supabase Dashboard
- Anonymous Sign-Ins: enabled (required)
- Apple Sign-In: enable + add Bundle ID (optional, for Phase 6)
- Google Sign-In: enable + add OAuth client IDs (optional, for Phase 6)

### Verification
- First launch creates anonymous user (check Supabase Auth dashboard)
- Offline first launch: app works, auth deferred
- Subsequent launch: same anonymous user persisted

---

## Phase 3 — Database Schema + Isar Wiring (~30 min)

### 3a. SQL Migration — Run in Supabase SQL Editor

```sql
-- ============================================
-- CHOMPD DATABASE SCHEMA
-- ============================================

-- 1. PROFILES (extends auth.users with app-specific data)
CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name TEXT,
  display_currency TEXT NOT NULL DEFAULT 'GBP',
  monthly_budget NUMERIC(10,2),
  is_pro BOOLEAN NOT NULL DEFAULT false,
  pro_purchased_at TIMESTAMPTZ,
  app_version TEXT,
  locale TEXT DEFAULT 'en',
  timezone TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. SUBSCRIPTIONS (mirrors Isar Subscription model)
CREATE TABLE public.subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  uid TEXT NOT NULL,
  name TEXT NOT NULL,
  price NUMERIC(10,2) NOT NULL DEFAULT 0,
  currency TEXT NOT NULL DEFAULT 'GBP',
  cycle TEXT NOT NULL DEFAULT 'monthly',
  next_renewal TIMESTAMPTZ NOT NULL,
  category TEXT NOT NULL DEFAULT 'Other',
  is_trial BOOLEAN NOT NULL DEFAULT false,
  trial_end_date TIMESTAMPTZ,
  is_active BOOLEAN NOT NULL DEFAULT true,
  cancelled_date TIMESTAMPTZ,
  icon_name TEXT,
  brand_color TEXT,
  source TEXT NOT NULL DEFAULT 'manual',
  is_trap BOOLEAN,
  trap_type TEXT,
  trial_price NUMERIC(10,2),
  trial_duration_days INTEGER,
  real_price NUMERIC(10,2),
  real_annual_cost NUMERIC(10,2),
  trap_severity TEXT,
  trial_expires_at TIMESTAMPTZ,
  trial_reminder_set BOOLEAN NOT NULL DEFAULT false,
  last_reviewed_at TIMESTAMPTZ,
  last_nudged_at TIMESTAMPTZ,
  keep_confirmed BOOLEAN NOT NULL DEFAULT false,
  reminders JSONB NOT NULL DEFAULT '[]'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at TIMESTAMPTZ,
  UNIQUE(user_id, uid)
);

-- 3. DODGED TRAPS
CREATE TABLE public.dodged_traps (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  service_name TEXT NOT NULL,
  saved_amount NUMERIC(10,2) NOT NULL,
  dodged_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  trap_type TEXT NOT NULL,
  source TEXT NOT NULL DEFAULT 'skipped',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 4. SCAN LOG
CREATE TABLE public.scan_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  model_used TEXT NOT NULL,
  escalated BOOLEAN NOT NULL DEFAULT false,
  service_detected TEXT,
  trap_detected BOOLEAN NOT NULL DEFAULT false,
  scan_duration_ms INTEGER,
  tokens_used INTEGER,
  cost_estimate NUMERIC(8,6),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 5. APP EVENTS
CREATE TABLE public.app_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  event_type TEXT NOT NULL,
  metadata JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 6. USER SETTINGS
CREATE TABLE public.user_settings (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  notification_enabled BOOLEAN NOT NULL DEFAULT true,
  reminder_defaults JSONB NOT NULL DEFAULT '[{"daysBefore": 0, "enabled": true}]'::jsonb,
  onboarding_completed BOOLEAN NOT NULL DEFAULT false,
  scan_count_used INTEGER NOT NULL DEFAULT 0,
  theme TEXT DEFAULT 'dark',
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- INDEXES
CREATE INDEX idx_subscriptions_user_id ON public.subscriptions(user_id);
CREATE INDEX idx_subscriptions_user_active ON public.subscriptions(user_id, is_active);
CREATE INDEX idx_subscriptions_user_uid ON public.subscriptions(user_id, uid);
CREATE INDEX idx_dodged_traps_user_id ON public.dodged_traps(user_id);
CREATE INDEX idx_scan_logs_user_id ON public.scan_logs(user_id);
CREATE INDEX idx_scan_logs_created ON public.scan_logs(user_id, created_at);
CREATE INDEX idx_app_events_user_id ON public.app_events(user_id);
CREATE INDEX idx_app_events_type ON public.app_events(user_id, event_type);

-- ROW LEVEL SECURITY
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dodged_traps ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.scan_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.app_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_settings ENABLE ROW LEVEL SECURITY;

-- PROFILES policies
CREATE POLICY "Users can view own profile"
  ON public.profiles FOR SELECT TO authenticated
  USING (auth.uid() = id);
CREATE POLICY "Users can update own profile"
  ON public.profiles FOR UPDATE TO authenticated
  USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile"
  ON public.profiles FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = id);

-- SUBSCRIPTIONS policies
CREATE POLICY "Users can view own subscriptions"
  ON public.subscriptions FOR SELECT TO authenticated
  USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own subscriptions"
  ON public.subscriptions FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own subscriptions"
  ON public.subscriptions FOR UPDATE TO authenticated
  USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own subscriptions"
  ON public.subscriptions FOR DELETE TO authenticated
  USING (auth.uid() = user_id);

-- DODGED TRAPS policies
CREATE POLICY "Users can view own dodged traps"
  ON public.dodged_traps FOR SELECT TO authenticated
  USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own dodged traps"
  ON public.dodged_traps FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- SCAN LOGS policies
CREATE POLICY "Users can view own scan logs"
  ON public.scan_logs FOR SELECT TO authenticated
  USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own scan logs"
  ON public.scan_logs FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- APP EVENTS policies (insert-only)
CREATE POLICY "Users can insert own events"
  ON public.app_events FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- USER SETTINGS policies
CREATE POLICY "Users can view own settings"
  ON public.user_settings FOR SELECT TO authenticated
  USING (auth.uid() = user_id);
CREATE POLICY "Users can upsert own settings"
  ON public.user_settings FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own settings"
  ON public.user_settings FOR UPDATE TO authenticated
  USING (auth.uid() = user_id);

-- AUTO-CREATE PROFILE + SETTINGS ON SIGNUP
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id) VALUES (NEW.id);
  INSERT INTO public.user_settings (user_id) VALUES (NEW.id);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- AUTO-UPDATE updated_at
CREATE OR REPLACE FUNCTION public.update_updated_at()
RETURNS trigger AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_updated_at_profiles
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();
CREATE TRIGGER set_updated_at_subscriptions
  BEFORE UPDATE ON public.subscriptions
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();
CREATE TRIGGER set_updated_at_user_settings
  BEFORE UPDATE ON public.user_settings
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();
```

### 3b. Add sync fields to Subscription model

**Modify `lib/models/subscription.dart`:**
```dart
// Add to Subscription class:
DateTime updatedAt = DateTime.now();
DateTime? deletedAt;

// Add serialization helpers:
Map<String, dynamic> toSupabaseMap(String userId) { ... }
static Subscription fromSupabaseMap(Map<String, dynamic> row) { ... }
```

### 3c. Wire up Isar persistence

**Create `lib/services/isar_service.dart` (NEW):**
```dart
class IsarService {
  IsarService._();
  static final instance = IsarService._();
  late Isar _isar;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [SubscriptionSchema],
      directory: dir.path,
    );
  }

  Isar get db => _isar;
}
```

**Modify `lib/main.dart`** — add to init sequence:
```dart
await IsarService.instance.init();
```

**Modify `lib/providers/subscriptions_provider.dart`:**
- Change from pure in-memory list to Isar-backed
- `_load()` reads from Isar on startup
- `add()` / `update()` / `remove()` write to Isar + queue sync
- `cancel()` writes to Isar + queue sync

### 3d. Migrate dodged traps to Isar

**Modify `lib/models/dodged_trap.dart`** — add `@collection` + Isar fields
**Modify `lib/services/dodged_trap_repository.dart`** — read/write Isar, migrate from SharedPreferences on first run

### Verification
- Subscriptions persist across app restarts (Isar)
- Dodged traps persist across app restarts (Isar)
- SQL schema created in Supabase dashboard
- Profile + settings auto-created on anonymous sign-in

---

## Phase 4 — AI API Proxy Edge Function (~30 min)

**Highest security priority** — removes Anthropic API key from app binary.

### 4a. Create Edge Function `supabase/functions/ai-scan/index.ts`

```typescript
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2";

const ANTHROPIC_API_KEY = Deno.env.get("ANTHROPIC_API_KEY")!;
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST",
        "Access-Control-Allow-Headers": "Authorization, Content-Type",
      },
    });
  }

  try {
    // 1. Verify JWT
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "No auth header" }), { status: 401 });
    }

    const supabaseAdmin = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);
    const token = authHeader.replace("Bearer ", "");
    const { data: { user }, error: authError } = await supabaseAdmin.auth.getUser(token);

    if (authError || !user) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), { status: 401 });
    }

    // 2. Check scan limits
    const { data: settings } = await supabaseAdmin
      .from("user_settings")
      .select("scan_count_used")
      .eq("user_id", user.id)
      .single();

    const { data: profile } = await supabaseAdmin
      .from("profiles")
      .select("is_pro")
      .eq("id", user.id)
      .single();

    const isPro = profile?.is_pro ?? false;
    const scanCount = settings?.scan_count_used ?? 0;
    const FREE_SCAN_LIMIT = 5;

    if (!isPro && scanCount >= FREE_SCAN_LIMIT) {
      return new Response(
        JSON.stringify({ error: "scan_limit_reached", limit: FREE_SCAN_LIMIT }),
        { status: 429 }
      );
    }

    // 3. Forward to Anthropic
    const body = await req.json();
    const { model, messages, max_tokens, system } = body;

    const allowedModels = [
      "claude-haiku-4-5-20251001",
      "claude-sonnet-4-5-20250929",
    ];
    if (!allowedModels.includes(model)) {
      return new Response(JSON.stringify({ error: "Invalid model" }), { status: 400 });
    }

    const startTime = Date.now();
    const anthropicResponse = await fetch("https://api.anthropic.com/v1/messages", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "x-api-key": ANTHROPIC_API_KEY,
        "anthropic-version": "2023-06-01",
      },
      body: JSON.stringify({ model, max_tokens: max_tokens || 4000, system, messages }),
    });

    const result = await anthropicResponse.json();
    const durationMs = Date.now() - startTime;

    // 4. Increment scan count + log
    if (!isPro) {
      await supabaseAdmin
        .from("user_settings")
        .update({ scan_count_used: scanCount + 1 })
        .eq("user_id", user.id);
    }

    await supabaseAdmin.from("scan_logs").insert({
      user_id: user.id,
      model_used: model,
      escalated: false,
      scan_duration_ms: durationMs,
      tokens_used: (result.usage?.input_tokens || 0) + (result.usage?.output_tokens || 0),
      cost_estimate: estimateCost(model, result.usage),
    });

    return new Response(JSON.stringify(result), {
      headers: { "Content-Type": "application/json" },
    });

  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), { status: 500 });
  }
});

function estimateCost(model: string, usage: any): number {
  if (!usage) return 0;
  const input = usage.input_tokens || 0;
  const output = usage.output_tokens || 0;
  if (model.includes("haiku")) {
    return (input * 0.25 + output * 1.25) / 1_000_000;
  }
  return (input * 3 + output * 15) / 1_000_000;
}
```

### 4b. Set secrets
```bash
supabase secrets set ANTHROPIC_API_KEY=sk-ant-...
```

### 4c. Update AI scan service

**Modify `lib/services/ai_scan_service.dart`:**
- Remove direct HTTP call to `api.anthropic.com`
- Replace with `Supabase.instance.client.functions.invoke('ai-scan', body: {...})`
- Handle 429 (scan limit) -> throw `ScanLimitReachedException`
- Remove `apiKey` constructor param
- Dev fallback: if Supabase unreachable + API key available, use direct call

### Verification
- AI scan works through Edge Function
- Free user blocked after N scans (429)
- Pro user unlimited scans
- Scan logged in `scan_logs` table
- App works without `ANTHROPIC_API_KEY` in dart-defines

---

## Phase 5 — Sync Service (~45 min)

### 5a. Create `lib/services/sync_service.dart` (NEW)

```dart
class SyncService {
  SyncService._();
  static final instance = SyncService._();

  Future<bool> get isOnline async {
    final result = await Connectivity().checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  // Called after every Isar write
  Future<void> pushSubscription(Subscription sub) async { ... }
  Future<void> pushDodgedTrap(DodgedTrap trap) async { ... }
  Future<void> pushDelete(String uid) async { ... }

  // Called on app open + connectivity restored
  Future<void> pullAndMerge() async { ... }

  // Sync user preferences
  Future<void> syncProfile() async { ... }

  // Analytics (best-effort, no retry)
  Future<void> logEvent(String type, [Map<String, dynamic>? metadata]) async { ... }
}
```

### 5b. Create `lib/providers/sync_provider.dart` (NEW)

```dart
class SyncState {
  final bool isOnline;
  final bool isSyncing;
  final DateTime? lastSyncAt;
  final int pendingCount;
}

final syncProvider = StateNotifierProvider<SyncNotifier, SyncState>(...);
```

### 5c. Wire sync into existing providers

**Modify `lib/providers/subscriptions_provider.dart`** — after every Isar write:
```dart
SyncService.instance.pushSubscription(sub);
```

**Modify `lib/main.dart`** — on app start:
```dart
SyncService.instance.pullAndMerge();
Connectivity().onConnectivityChanged.listen((result) {
  if (!result.contains(ConnectivityResult.none)) {
    SyncService.instance.pullAndMerge();
  }
});
```

**Modify `lib/providers/currency_provider.dart`** — after setCurrency(), sync to profiles table
**Modify `lib/providers/locale_provider.dart`** — same pattern

### Verification
- Create subscription -> appears in Supabase
- Delete subscription -> `deleted_at` set in Supabase
- Kill app, reopen -> restored from Isar
- Offline edit -> syncs on reconnect
- Change currency -> `profiles.display_currency` updated

---

## Phase 6 — Account Upgrade Flow (~20 min)

### 6a. Add account section to settings

**Modify `lib/screens/settings/settings_screen.dart`:**

New section at TOP (above Notifications):
```
ACCOUNT
[Anonymous — Back up your account]     <- if anonymous
[Signed in via Apple — user@email.com] <- if upgraded
```

Tap -> bottom sheet: Apple / Google / Email sign-in options.

### 6b. New l10n keys

**Modify `lib/l10n/app_en.arb` + `lib/l10n/app_pl.arb`:**
```
sectionAccount, accountAnonymous, backUpAccount, backUpAccountDesc,
signInWithApple, signInWithGoogle, signInWithEmail,
accountBackedUp, signedInVia, signOut, signOutWarning,
syncStatus, lastSynced, syncing, offline, syncNow
```

### Verification
- Anonymous user sees upgrade prompt
- Apple Sign-In preserves user_id + all data
- Settings shows correct auth state

---

## Phase 7 — Restore on Reinstall (~15 min)

**Modify `lib/main.dart`** or create startup provider:

```dart
final localCount = await IsarService.instance.db.subscriptions.count();
if (localCount == 0 && AuthService.instance.isSignedIn) {
  final remote = await supabase.from('subscriptions')
    .select().eq('user_id', userId).is_('deleted_at', null);
  if (remote.isNotEmpty) {
    // Show "Welcome back! Restoring X subscriptions..."
    // Import all into Isar
  }
}
```

### Verification
- Delete app -> reinstall -> data restored
- New device + same Apple account -> data synced

---

## Analytics Dashboard Queries (Reference)

```sql
-- Total users
SELECT COUNT(*) as total,
  COUNT(*) FILTER (WHERE raw_user_meta_data->>'is_anonymous' = 'true') as anonymous,
  COUNT(*) FILTER (WHERE raw_user_meta_data->>'is_anonymous' != 'true') as permanent
FROM auth.users;

-- Pro conversion
SELECT COUNT(*) as total,
  COUNT(*) FILTER (WHERE is_pro = true) as pro,
  ROUND(100.0 * COUNT(*) FILTER (WHERE is_pro = true) / COUNT(*), 1) as pct
FROM public.profiles;

-- Most tracked subscriptions
SELECT name, COUNT(*) as users FROM public.subscriptions
WHERE is_active = true AND deleted_at IS NULL
GROUP BY name ORDER BY users DESC LIMIT 20;

-- AI scan costs by day
SELECT DATE(created_at) as day, COUNT(*) as scans,
  SUM(cost_estimate) as cost, AVG(scan_duration_ms) as avg_ms
FROM public.scan_logs GROUP BY day ORDER BY day DESC;

-- Trap detection rate
SELECT COUNT(*) as total,
  COUNT(*) FILTER (WHERE trap_detected) as traps,
  ROUND(100.0 * COUNT(*) FILTER (WHERE trap_detected) / COUNT(*), 1) as pct
FROM public.scan_logs;

-- Total money saved
SELECT SUM(saved_amount) as total, COUNT(*) as traps_dodged
FROM public.dodged_traps;
```

---

## Files Summary

### New files (7):
| File | Purpose |
|------|---------|
| `lib/services/auth_service.dart` | Anonymous auth + account upgrade |
| `lib/services/sync_service.dart` | Isar <-> Supabase sync engine |
| `lib/services/isar_service.dart` | Isar database initialisation |
| `lib/providers/auth_provider.dart` | Auth state for UI |
| `lib/providers/sync_provider.dart` | Sync state for UI |
| `supabase/functions/ai-scan/index.ts` | AI API proxy Edge Function |
| `.env.example` | Documents required environment variables |

### Modified files (~12):
| File | Changes |
|------|---------|
| `pubspec.yaml` | Add supabase_flutter, connectivity_plus |
| `lib/main.dart` | Supabase init, auth, Isar init, sync on start |
| `lib/models/subscription.dart` | Add updatedAt, deletedAt, toSupabaseMap, fromSupabaseMap |
| `lib/models/dodged_trap.dart` | Add @collection for Isar |
| `lib/services/ai_scan_service.dart` | Route through Edge Function instead of direct API |
| `lib/services/dodged_trap_repository.dart` | Migrate to Isar + sync |
| `lib/providers/subscriptions_provider.dart` | Isar persistence + sync hooks |
| `lib/providers/scan_provider.dart` | Server-side scan limit handling |
| `lib/providers/currency_provider.dart` | Sync preference to profiles table |
| `lib/providers/locale_provider.dart` | Sync preference to profiles table |
| `lib/screens/settings/settings_screen.dart` | Account section + sync status |
| `lib/l10n/app_en.arb` + `app_pl.arb` | ~15 new l10n keys for account/sync UI |

### NOT changed:
- `lib/data/cancel_guides_data.dart` — static content
- `lib/data/refund_paths_data.dart` — static content
- `lib/services/notification_service.dart` — stays local (server push in v2)
- `lib/services/merchant_db.dart` — stays local (community DB in v2)

---

## Implementation Order

| # | Phase | Est. | Dependencies |
|---|-------|------|-------------|
| 1 | Supabase project + Flutter init | 15 min | None |
| 2 | Anonymous auth | 20 min | Phase 1 |
| 3 | DB schema + Isar wiring | 30 min | Phase 1 |
| 4 | AI API proxy Edge Function | 30 min | Phase 2 (needs auth JWT) |
| 5 | Sync service | 45 min | Phases 2 + 3 |
| 6 | Account upgrade + settings UI | 20 min | Phase 2 |
| 7 | Restore on reinstall | 15 min | Phases 2 + 3 + 5 |

**Total: ~3 hours**

---

## Security Checklist
- [ ] RLS enabled on ALL 6 tables
- [ ] Anon key in app (safe — RLS protects data)
- [ ] Service role key ONLY in Edge Functions (never in app)
- [ ] Anthropic API key ONLY in Edge Function secrets
- [ ] Anonymous sign-in rate limiting + CAPTCHA enabled
- [ ] No secrets in source control (.env in .gitignore)
- [ ] Tested: User A cannot see User B's data

## Testing Checklist
- [ ] App works fully offline (Isar only, no Supabase)
- [ ] Anonymous user created on first launch
- [ ] Subscription CRUD syncs to Supabase
- [ ] AI scan works through Edge Function proxy
- [ ] Free scan limit enforced server-side (429)
- [ ] Pro users get unlimited scans
- [ ] Delete + reinstall restores data
- [ ] Account upgrade (Apple) preserves all data
- [ ] Offline edits sync when connectivity returns
- [ ] Soft delete syncs across devices

---

## Future Features (Schema Ready)

The schema already supports:
- **Household/shared subscriptions** — add `shared_with` JSONB or join table
- **Subscription creep detection** — query historical prices in scan_logs
- **Server-side push notifications** — Edge Function + APNs using subscriptions.next_renewal
- **Admin dashboard** — connect Metabase/Grafana to Supabase
- **Data portability** — clean relational structure, easy CSV/JSON export
