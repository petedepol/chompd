# Chompd — Unified Service Database & Sweep System
## Claude Code Context Document

> Read this ENTIRE document before writing any code. It covers the live Supabase schema,
> the sweep tool architecture, the Isar offline cache, and the Loki automation layer.

---

## What Exists Now (Live in Supabase)

The unified service schema v3 has been applied directly to the Chompd Supabase project.
All 10 tables, 2 views, all enums, RLS policies, triggers, and functions are LIVE.
The tables are currently EMPTY — no seed data yet.

### Tables (all live):

| # | Table | Purpose |
|---|-------|---------|
| 1 | `services` | Master service table (Netflix, Spotify, etc.) |
| 2 | `service_tiers` | Pricing tiers per service per currency (GBP/USD/EUR/PLN) |
| 3 | `cancel_guides` | Per-service, per-platform (ios/android/web/all) cancel steps |
| 4 | `refund_templates` | Per-service, per-billing-method (app_store/google_play/direct/paypal/stripe) refund paths |
| 5 | `dark_pattern_flags` | Deceptive practices flagged per service |
| 6 | `service_alternatives` | Competitor/cheaper alternatives per service |
| 7 | `community_tips` | User-reported cancel hacks, refund tricks, dark pattern reports |
| 8 | `price_history` | Historical price changes per tier (for subscription creep detection) |
| 9 | `service_aliases` | Alternative names for fuzzy matching (e.g. "YT Premium" → YouTube Premium) |
| 10 | `service_update_log` | Tracks every AI sweep run (manual or automated) |

### Views (live):
- `service_full` — Denormalizes everything into one fat JSON response per service (tiers, cancel guides, refund templates, dark patterns, alternatives, community tip count)
- `top_community_tips` — Approved tips sorted by net score (upvotes - downvotes)

### Enums (live):
- `service_category`: streaming, music, storage, productivity, ai, fitness, gaming, reading, communication, bundle, developer, finance, education, news, vpn, dating, food_delivery, transport, other
- `core_currency`: GBP, USD, EUR, PLN
- `cancel_platform`: ios, android, web, all
- `billing_method`: app_store, google_play, direct, paypal, stripe
- `pattern_severity`: mild, moderate, severe
- `tip_status`: pending, approved, rejected, outdated

### Key Triggers (live):
- `bump_service_version()` — fires on INSERT/UPDATE/DELETE on service_tiers, cancel_guides, refund_templates, dark_pattern_flags, service_alternatives. Increments `services.data_version` so the app knows what's changed since last sync.

### Key Functions (live):
- `get_updated_services(since_version INTEGER)` — returns all services from `service_full` where `data_version > since_version`. This is what the Flutter app calls for delta syncs.

### RLS Policies (live):
- All tables have public read (SELECT) enabled
- `community_tips` allows public INSERT (users can submit tips)
- `community_tips` allows UPDATE only on approved tips (for voting)
- Service role key bypasses RLS (used by sweep tool and Loki)

---

## What Needs Building

### 1. Seed Data
The tables are empty. We need initial seed data for the ~60 subscription services Chompd tracks.
The seed data from the v2 schema (services + service_tiers with GBP/USD/EUR/PLN pricing) should be migrated into the v3 tables. The v2 seed data was a Python script that generated INSERT statements — that data needs to be converted to v3 format.

Additionally, the cancel guides that were previously hardcoded in Isar (`lib/data/cancel_guides_data.dart`) need to be converted to INSERT statements for the `cancel_guides` table. Same for refund templates that were in `lib/data/refund_paths_data.dart`.

### 2. Flutter Isar Cache Layer
Replace the existing separate Isar collections (CancelGuide, etc.) with a single `ServiceCache` collection that mirrors the `service_full` view.

**Isar model** (`lib/models/service_cache.dart`):

```dart
@collection
class ServiceCache {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String supabaseId;       // UUID from Supabase

  @Index()
  late String slug;
  late String name;
  @Index()
  late String category;
  late String brandColor;
  late String iconLetter;
  String? iconUrl;

  // URLs
  String? websiteUrl;
  String? cancelUrl;
  String? pricingUrl;
  String? refundPolicyUrl;

  // Flags
  late bool hasFreeTier;
  late bool hasFamily;
  late bool hasAnnual;
  late bool hasStudent;
  double? annualDiscountPct;

  // Currency & region
  late String fallbackCurrency;
  late List<String> regions;

  // Scores
  int? cancelDifficulty;
  double? refundSuccessRate;

  // Denormalized children (stored as JSON strings in Isar)
  late String tiersJson;
  late String cancelGuidesJson;
  late String refundTemplatesJson;
  late String darkPatternsJson;
  late String alternativesJson;
  late int communityTipCount;

  // Aliases for fuzzy matching
  @Index(type: IndexType.value)
  late List<String> aliases;

  // Sync metadata
  @Index()
  late int dataVersion;
  late DateTime verifiedAt;
  late DateTime updatedAt;
  late DateTime localSyncedAt;
}

@collection
class SyncState {
  Id id = Isar.autoIncrement;
  late int lastSyncedVersion;
  late DateTime lastSyncedAt;
  late int lastSyncCount;
}
```

**Sync service** (`lib/services/service_sync_service.dart`):
- On first launch: `SELECT * FROM service_full` → cache all in Isar, store max(data_version)
- On subsequent opens: `SELECT * FROM get_updated_services(local_version)` → delta sync only changed services
- If Supabase unreachable: use Isar cache, show "last updated X days ago" if stale > 30 days
- Community tips: INSERT to `community_tips` (pending), approved tips sync on next refresh

### 3. Sweep Tool Integration

There's a React artifact (sweep tool) that Pete can run from Claude.ai chat. It:
1. Connects to Supabase using service_role key
2. Loads services from the `services` table (with `service_tiers` joined)
3. Lets Pete select services and phases (pricing, cancel guides, refund, dark patterns, alternatives, community moderation)
4. Calls Claude Sonnet 4 with web search per service to verify/update data
5. Shows a diff preview (current vs proposed changes)
6. On approval, writes changes to Supabase

The sweep tool is already built as a React artifact. The Flutter app doesn't need to know about it — it just sees updated data via the sync.

### 4. Loki Automation (Hetzner VPS)

Loki runs on the Hetzner VPS and handles scheduled tasks. The monthly sweep:
- Runs 1st of each month at 03:00 UTC
- Uses Claude Sonnet with web search (same prompt as the manual sweep tool)
- Updates all services across all phases
- Logs to `service_update_log`
- Sends summary email to petebotlad@gmail.com
- Can be manually triggered via: `openclaw onboard chompd-sweep --full`

---

## Schema Details (for reference)

### services table columns:
id (UUID PK), name (TEXT), slug (TEXT UNIQUE), category (service_category enum), brand_color (TEXT), icon_letter (TEXT), icon_url (TEXT nullable), website_url (TEXT nullable), cancel_url (TEXT nullable), pricing_url (TEXT nullable), refund_policy_url (TEXT nullable), has_free_tier (BOOL), has_family (BOOL), has_annual (BOOL), has_student (BOOL), annual_discount_pct (DECIMAL(4,1) nullable), fallback_currency (core_currency default 'USD'), regions (TEXT[] default '{GB,US}'), cancel_difficulty (SMALLINT 1-10 nullable), refund_success_rate (DECIMAL(4,1) nullable), data_version (INT default 1), verified_at (TIMESTAMPTZ), created_at (TIMESTAMPTZ), updated_at (TIMESTAMPTZ)

### service_tiers table columns:
id (UUID PK), service_id (UUID FK → services), tier_name (TEXT), monthly_gbp (DECIMAL(8,2)), annual_gbp (DECIMAL(8,2)), monthly_usd (DECIMAL(8,2)), annual_usd (DECIMAL(8,2)), monthly_eur (DECIMAL(8,2)), annual_eur (DECIMAL(8,2)), monthly_pln (DECIMAL(8,2)), annual_pln (DECIMAL(8,2)), trial_days (SMALLINT nullable), trial_requires_payment (BOOL default true), sort_order (INT), is_popular (BOOL), is_student (BOOL), verified_at (TIMESTAMPTZ), created_at (TIMESTAMPTZ), updated_at (TIMESTAMPTZ), UNIQUE(service_id, tier_name)

### cancel_guides table columns:
id (UUID PK), service_id (UUID FK → services), platform (cancel_platform enum), steps (JSONB — array of {step, title, detail, deeplink}), cancel_deeplink (TEXT nullable), cancel_web_url (TEXT nullable), estimated_minutes (SMALLINT default 5), warning_text (TEXT nullable), pro_tip (TEXT nullable), verified_at (TIMESTAMPTZ), created_at (TIMESTAMPTZ), updated_at (TIMESTAMPTZ), UNIQUE(service_id, platform)

### refund_templates table columns:
id (UUID PK), service_id (UUID FK → services), billing_method (billing_method enum), steps (JSONB), email_template (TEXT nullable — uses {{placeholders}}), email_subject (TEXT nullable), contact_email (TEXT nullable), contact_url (TEXT nullable), success_rate_pct (DECIMAL(4,1) nullable), avg_refund_days (SMALLINT nullable), refund_window_days (SMALLINT nullable), verified_at (TIMESTAMPTZ), created_at (TIMESTAMPTZ), updated_at (TIMESTAMPTZ), UNIQUE(service_id, billing_method)

### dark_pattern_flags table columns:
id (UUID PK), service_id (UUID FK → services), pattern_type (TEXT), severity (pattern_severity enum), title (TEXT), description (TEXT), user_impact (TEXT nullable), reported_count (INT default 1), first_reported (TIMESTAMPTZ), last_confirmed (TIMESTAMPTZ), is_active (BOOL default true), verified_at (TIMESTAMPTZ), created_at (TIMESTAMPTZ), updated_at (TIMESTAMPTZ)

### service_alternatives table columns:
id (UUID PK), service_id (UUID FK → services), alternative_id (UUID FK → services nullable), alt_name (TEXT), alt_slug (TEXT nullable), reason (TEXT), price_comparison (TEXT nullable), relevance_score (SMALLINT 1-10 default 5), sort_order (INT default 0), created_at (TIMESTAMPTZ), updated_at (TIMESTAMPTZ)

### community_tips table columns:
id (UUID PK), service_id (UUID FK → services), user_id (UUID nullable), tip_type (TEXT), title (TEXT), body (TEXT), platform (cancel_platform nullable), upvotes (INT default 0), downvotes (INT default 0), status (tip_status default 'pending'), reported_count (INT default 0), moderated_by (TEXT nullable), moderated_at (TIMESTAMPTZ nullable), created_at (TIMESTAMPTZ), updated_at (TIMESTAMPTZ)

### price_history table columns:
id (UUID PK), tier_id (UUID FK → service_tiers), currency (core_currency), old_monthly (DECIMAL(8,2)), new_monthly (DECIMAL(8,2)), old_annual (DECIMAL(8,2)), new_annual (DECIMAL(8,2)), change_pct (DECIMAL(5,1)), source (TEXT default 'auto'), recorded_at (TIMESTAMPTZ)

### service_aliases table columns:
id (UUID PK), service_id (UUID FK → services), alias (TEXT UNIQUE)

### service_update_log table columns:
id (UUID PK), run_at (TIMESTAMPTZ), update_type (TEXT), model_used (TEXT), services_checked (INT), prices_changed (INT), guides_updated (INT), patterns_flagged (INT), errors (INT), summary_json (JSONB nullable), error_log (JSONB nullable), duration_seconds (INT nullable), api_cost_usd (DECIMAL(6,4) nullable)

---

## Existing Flutter Code Context

### Current Isar models to REPLACE:
- `lib/models/cancel_guide.dart` — separate Isar collection with serviceName, platform, steps, deepLink, etc.
- Cancel guide seed data in `lib/data/cancel_guides_data.dart` (~30 services)
- Refund path data classes in `lib/data/refund_paths_data.dart` (4 refund paths: app_store, google_play, direct, bank_chargeback)

### Current Flutter screens that consume this data:
- `lib/screens/cancel/cancel_guide_screen.dart` — step-by-step cancel UI
- `lib/screens/refund/refund_rescue_screen.dart` — refund path selector + templates
- `lib/screens/detail/detail_screen.dart` — links to cancel guide and refund rescue
- `lib/widgets/nudge_card.dart` — AI nudge that references cancel guides

These screens currently read from Isar directly. After migration, they should read from the new `ServiceCache` Isar collection instead, parsing the JSON fields.

### Tech Stack:
- Flutter + Riverpod + Isar (local DB)
- Supabase (remote DB, auth, edge functions)
- Dark theme (CFR-inspired)

---

## Build Order for Claude Code

1. **Seed data script** — generate INSERT statements for services + service_tiers from the v2 Python seed data. Include cancel guides and refund templates.
2. **ServiceCache Isar model** — single collection mirroring `service_full`. Run build_runner.
3. **ServiceSyncService** — handles first-launch full sync and delta sync on app open.
4. **Migrate screens** — update cancel_guide_screen, refund_rescue_screen, detail_screen to read from ServiceCache instead of old Isar CancelGuide.
5. **Remove old models** — delete CancelGuide Isar collection, cancel_guides_data.dart, refund_paths_data.dart.
6. **Test sync** — verify delta sync works with data_version bumping.

---

## Important Gotchas

- The `service_full` view is a Postgres VIEW, not a table. Supabase REST API exposes views the same way as tables, so `sb.from('service_full').select('*')` works.
- The `get_updated_services` function takes an integer param. Call it via Supabase RPC: `sb.rpc('get_updated_services', { since_version: 5 })`.
- Cancel guide `steps` is JSONB. Each step should be: `{"step": 1, "title": "Open Settings", "detail": "Go to Settings > Subscriptions", "deeplink": "itms-apps://..."}`
- Refund template `email_template` uses `{{service}}`, `{{amount}}`, `{{date}}` as placeholders that the app fills in at runtime.
- The `bump_service_version` trigger fires on child table changes. This means inserting a cancel guide automatically bumps the parent service's `data_version` — no need to manually update it.
- `service_role` key bypasses RLS. The anon key respects RLS (public read, community tip insert/vote).
- `price_history` rows should be inserted whenever a tier price changes (the sweep tool handles this).
