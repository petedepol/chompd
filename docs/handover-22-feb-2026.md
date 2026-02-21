# Chompd — Session Handover (22 Feb 2026)

## Session Summary
Reviewed AI insight generation infrastructure (3 systems: local logic, curated service insights, AI-generated user insights). Discovered existing Edge Functions (`insight-generator` with 15 deployments, `insight-dispatcher`) and Supabase `user_insights` table already set up but not in local repo. Updated dispatcher from daily/14-day/batch-10 to **weekly/7-day/batch-250 with pagination**. Added **Postgres trigger** for instant insight generation on subscription add (Pro users only, 1-hour debounce). All deployed and live.

---

## Build Status
- **Latest commit:** `27cb609` (pre-session, no new commits yet)
- **Branch:** main
- **Supabase changes:** Deployed via dashboard + CLI (not committed)

---

## Changes This Session

### 1. Insight Dispatcher Updated
**File:** `supabase/functions/insight-dispatcher/index.ts`
- `BATCH_SIZE`: 10 → **250**
- `MIN_INTERVAL_DAYS`: 14 → **7**
- Added **pagination loop** — processes all due users across multiple batches
- Added **timeout guard** (`MAX_RUNTIME_MS = 140s`) — stops cleanly before 150s Edge Function limit
- Logs elapsed time in response
- Deployed via `supabase functions deploy insight-dispatcher`

### 2. Cron Rescheduled (Daily → Weekly)
**SQL run in Supabase SQL Editor:**
- Unscheduled `insight-dispatcher-daily` (was `0 3 * * *`)
- Created `insight-dispatcher-weekly` (`0 3 * * 1` — Monday 3am UTC)
- Uses hardcoded Supabase URL + service role key (no `ALTER DATABASE SET` on hosted Supabase)

### 3. On-Subscription-Add Trigger Created
**SQL run in Supabase SQL Editor:**
- `trigger_insight_on_sub_add()` — SECURITY DEFINER function
- Guards: active + non-deleted subs only, Pro users only, 1-hour debounce via `last_insight_at`
- Calls `insight-generator` Edge Function via `net.http_post()` (async, non-blocking)
- `on_subscription_inserted` trigger on `subscriptions` table (AFTER INSERT)

### 4. Performance Index Added
```sql
CREATE INDEX idx_profiles_insight_due ON profiles (is_pro, last_insight_at) WHERE is_pro = true;
```

### 5. Migration SQL Updated
**File:** `supabase/migration.sql`
- Appended V2 section: trigger function, trigger, and index for documentation

---

## Files Changed This Session

| File | Change |
|------|--------|
| `supabase/functions/insight-dispatcher/index.ts` | BATCH_SIZE 250, MIN_INTERVAL_DAYS 7, pagination + timeout guard |
| `supabase/migration.sql` | V2 section: trigger function + trigger + index |

## Supabase Changes (not in repo — run manually)
- `insight-dispatcher` Edge Function redeployed
- pg_cron: daily → weekly Monday 3am
- Postgres trigger `on_subscription_inserted` created
- Index `idx_profiles_insight_due` created
- Service role key hardcoded in trigger function (SECURITY DEFINER, server-side only)

---

## Architecture: AI Insight Generation

```
Weekly (Monday 3am UTC)
  pg_cron → insight-dispatcher Edge Function
    → queries profiles WHERE is_pro AND last_insight_at < 7 days ago
    → calls insight-generator for each user (batch 250, paginated)

On Subscription Add
  INSERT INTO subscriptions
    → Postgres trigger fires
    → checks: is_active? not deleted? is_pro? last_insight_at > 1hr ago?
    → calls insight-generator via pg_net.http_post()

insight-generator (unchanged)
  → fetches user profile (currency, locale)
  → fetches active subs with has_annual from services table
  → sends to Claude Haiku 4.5
  → parses 2-3 JSON insights
  → inserts into user_insights
  → updates profiles.last_insight_at

Flutter client (unchanged)
  → syncs user_insights on app launch + reconnect
  → combinedInsightsProvider merges AI + curated (max 3)
  → displays in carousel with AI badge
```

---

## Infrastructure
- **Supabase:** https://bavfommuelhivrigiafg.supabase.co
- **Edge Functions:** insight-generator (15 deploys), insight-dispatcher (3 deploys), ai-scan, + 2 legacy (Chompd-i8/i9)
- **pg_cron:** Weekly Monday 3am UTC
- **pg_net:** Enabled, used by trigger for async HTTP calls
- **AI:** Haiku 4.5 for insights (~$0.003/user/call)
