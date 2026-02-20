-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- CHOMPD — Unified Service Database Schema v3
-- Single source of truth for everything Chompd knows about a subscription.
-- Supabase (PostgreSQL) as primary, Isar caches locally for offline.
-- Monthly AI sweep (Sonnet via Loki) updates all data.
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- ┌─────────────────────────────────────────────────────────────────────┐
-- │  MIGRATION NOTES                                                    │
-- │                                                                     │
-- │  REPLACES:                                                          │
-- │  • services table (v2)           → merged into services (v3)        │
-- │  • service_tiers table (v2)      → merged into service_tiers (v3)   │
-- │  • price_history table (v2)      → kept, unchanged                  │
-- │  • service_aliases table (v2)    → kept, unchanged                  │
-- │  • price_check_log table (v2)    → expanded → service_update_log    │
-- │  • Isar CancelGuide model        → NEW cancel_guides table          │
-- │  • Hardcoded refund templates    → NEW refund_templates table       │
-- │                                                                     │
-- │  NEW TABLES:                                                        │
-- │  • cancel_guides         — per-service, per-platform cancel steps   │
-- │  • refund_templates      — per-service, per-billing-method guides   │
-- │  • dark_pattern_flags    — auto-renew tricks, hidden fees, etc.     │
-- │  • service_alternatives  — competitor/cheaper alternative suggestions│
-- │  • community_tips        — user-reported cancel tips & refund hacks │
-- │  • service_update_log    — replaces price_check_log, tracks all AI  │
-- │                            sweep activity                           │
-- └─────────────────────────────────────────────────────────────────────┘


-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- ENUMS
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- Keep existing category enum, add new values as needed
-- (If migrating from v2, ALTER TYPE to add new categories)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'service_category') THEN
    CREATE TYPE service_category AS ENUM (
      'streaming', 'music', 'storage', 'productivity',
      'ai', 'fitness', 'gaming', 'reading',
      'communication', 'bundle', 'developer', 'finance',
      'education', 'news', 'vpn', 'dating', 'food_delivery',
      'transport', 'other'
    );
  END IF;
END $$;

-- Core currencies (unchanged from v2)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'core_currency') THEN
    CREATE TYPE core_currency AS ENUM ('GBP', 'USD', 'EUR', 'PLN');
  END IF;
END $$;

-- Platform for cancel guides
CREATE TYPE cancel_platform AS ENUM (
  'ios', 'android', 'web', 'all'
);

-- Billing method for refund templates
CREATE TYPE billing_method AS ENUM (
  'app_store', 'google_play', 'direct', 'paypal', 'stripe'
);

-- Dark pattern severity
CREATE TYPE pattern_severity AS ENUM (
  'mild',       -- annoying but manageable (e.g. buried cancel button)
  'moderate',   -- deliberately misleading (e.g. confusing plan names)
  'severe'      -- actively hostile (e.g. phone-call-only cancellation)
);

-- Community tip status
CREATE TYPE tip_status AS ENUM (
  'pending',    -- submitted, awaiting moderation
  'approved',   -- verified and visible
  'rejected',   -- spam or inaccurate
  'outdated'    -- was valid, now stale
);


-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- TABLE 1: services (MASTER — upgraded from v2)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

CREATE TABLE services (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name                TEXT NOT NULL,                    -- "Netflix"
  slug                TEXT NOT NULL UNIQUE,             -- "netflix"
  category            service_category NOT NULL,
  brand_color         TEXT NOT NULL,                    -- "#E50914"
  icon_letter         TEXT NOT NULL DEFAULT '?',        -- "N" (for generated icon)
  icon_url            TEXT,                             -- optional real icon URL

  -- URLs
  website_url         TEXT,                             -- "https://netflix.com"
  cancel_url          TEXT,                             -- deeplink to cancel page
  pricing_url         TEXT,                             -- URL to check for price updates
  refund_policy_url   TEXT,                             -- link to official refund policy

  -- Flags
  has_free_tier       BOOLEAN DEFAULT false,
  has_family          BOOLEAN DEFAULT false,
  has_annual          BOOLEAN DEFAULT false,
  has_student         BOOLEAN DEFAULT false,
  annual_discount_pct DECIMAL(4,1),                    -- typical annual discount %

  -- Currency & region
  fallback_currency   core_currency DEFAULT 'USD',
  regions             TEXT[] DEFAULT '{GB,US}',

  -- Cancellation difficulty score (1-10, AI-assessed)
  cancel_difficulty   SMALLINT CHECK (cancel_difficulty BETWEEN 1 AND 10),

  -- Refund success rates (aggregated from community data + known rates)
  refund_success_rate DECIMAL(4,1),                    -- overall % success

  -- Sync metadata
  data_version        INTEGER NOT NULL DEFAULT 1,      -- bumped on any AI update
  verified_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_services_category ON services(category);
CREATE INDEX idx_services_slug ON services(slug);
CREATE INDEX idx_services_data_version ON services(data_version);


-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- TABLE 2: service_tiers (upgraded from v2)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

CREATE TABLE service_tiers (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  service_id      UUID NOT NULL REFERENCES services(id) ON DELETE CASCADE,
  tier_name       TEXT NOT NULL,                    -- "Standard", "Premium"

  -- Core 4 currencies (verified prices)
  monthly_gbp     DECIMAL(8,2),
  annual_gbp      DECIMAL(8,2),
  monthly_usd     DECIMAL(8,2),
  annual_usd      DECIMAL(8,2),
  monthly_eur     DECIMAL(8,2),
  annual_eur      DECIMAL(8,2),
  monthly_pln     DECIMAL(8,2),
  annual_pln      DECIMAL(8,2),

  -- Trial info (moved from hardcoded data)
  trial_days      SMALLINT,                         -- 7, 14, 30, null if none
  trial_requires_payment BOOLEAN DEFAULT true,      -- does trial need card?

  sort_order      INTEGER DEFAULT 0,
  is_popular      BOOLEAN DEFAULT false,
  is_student      BOOLEAN DEFAULT false,

  -- Sync metadata
  verified_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),

  UNIQUE(service_id, tier_name)
);

CREATE INDEX idx_tiers_service ON service_tiers(service_id);


-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- TABLE 3: cancel_guides (NEW — replaces Isar CancelGuide)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

CREATE TABLE cancel_guides (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  service_id      UUID NOT NULL REFERENCES services(id) ON DELETE CASCADE,
  platform        cancel_platform NOT NULL,         -- ios, android, web, all

  -- Ordered steps as JSONB array
  -- Each step: {"step": 1, "title": "Open Settings", "detail": "Go to...", "deeplink": "app-settings:..."}
  steps           JSONB NOT NULL DEFAULT '[]',

  -- Direct cancel links per platform
  cancel_deeplink TEXT,                             -- platform-specific deeplink
  cancel_web_url  TEXT,                             -- fallback web URL

  -- Estimated time to complete
  estimated_minutes SMALLINT DEFAULT 5,

  -- Tips / gotchas
  warning_text    TEXT,                             -- "Netflix will charge you if..."
  pro_tip         TEXT,                             -- "Cancel on day 28 to keep access"

  -- Sync metadata
  verified_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),

  UNIQUE(service_id, platform)
);

CREATE INDEX idx_cancel_guides_service ON cancel_guides(service_id);


-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- TABLE 4: refund_templates (NEW — replaces hardcoded refund paths)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

CREATE TABLE refund_templates (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  service_id          UUID NOT NULL REFERENCES services(id) ON DELETE CASCADE,
  billing_method      billing_method NOT NULL,

  -- Refund path steps (JSONB array, same format as cancel steps)
  steps               JSONB NOT NULL DEFAULT '[]',

  -- Pre-written email/message template (with {{placeholders}})
  email_template      TEXT,                         -- "Dear {{service}} support, I was charged..."
  email_subject       TEXT,                         -- "Refund request for {{service}}"
  contact_email       TEXT,                         -- support@service.com
  contact_url         TEXT,                         -- support page URL

  -- Success metrics
  success_rate_pct    DECIMAL(4,1),                 -- platform-specific success %
  avg_refund_days     SMALLINT,                     -- typical days to get money back
  refund_window_days  SMALLINT,                     -- how many days after charge you can claim

  -- Sync metadata
  verified_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT now(),

  UNIQUE(service_id, billing_method)
);

CREATE INDEX idx_refund_templates_service ON refund_templates(service_id);


-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- TABLE 5: dark_pattern_flags (NEW)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

CREATE TABLE dark_pattern_flags (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  service_id      UUID NOT NULL REFERENCES services(id) ON DELETE CASCADE,

  -- Pattern details
  pattern_type    TEXT NOT NULL,                    -- "hidden_auto_renew", "phone_only_cancel",
                                                    -- "confusing_tiers", "cancel_guilt_trip",
                                                    -- "buried_settings", "fake_countdown",
                                                    -- "price_increase_stealth"
  severity        pattern_severity NOT NULL DEFAULT 'mild',
  title           TEXT NOT NULL,                    -- "Phone-only cancellation"
  description     TEXT NOT NULL,                    -- "Adobe requires you to call..."
  user_impact     TEXT,                             -- "You'll waste 30+ minutes on hold"

  -- Evidence
  reported_count  INTEGER DEFAULT 1,               -- how many users flagged this
  first_reported  TIMESTAMPTZ DEFAULT now(),
  last_confirmed  TIMESTAMPTZ DEFAULT now(),
  is_active       BOOLEAN DEFAULT true,             -- still happening?

  -- Sync metadata
  verified_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_dark_patterns_service ON dark_pattern_flags(service_id);
CREATE INDEX idx_dark_patterns_severity ON dark_pattern_flags(severity);
CREATE INDEX idx_dark_patterns_type ON dark_pattern_flags(pattern_type);


-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- TABLE 6: service_alternatives (NEW)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

CREATE TABLE service_alternatives (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  service_id          UUID NOT NULL REFERENCES services(id) ON DELETE CASCADE,
  alternative_id      UUID REFERENCES services(id) ON DELETE SET NULL,

  -- If the alternative isn't in our DB yet, store basic info
  alt_name            TEXT NOT NULL,                 -- "Tidal" as alternative to Spotify
  alt_slug            TEXT,
  reason              TEXT NOT NULL,                 -- "Better audio quality, similar price"
  price_comparison    TEXT,                          -- "£2/mo cheaper", "Free tier available"

  -- Ranking
  relevance_score     SMALLINT DEFAULT 5 CHECK (relevance_score BETWEEN 1 AND 10),
  sort_order          INTEGER DEFAULT 0,

  -- Sync metadata
  created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_alternatives_service ON service_alternatives(service_id);


-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- TABLE 7: community_tips (NEW — user-reported data)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

CREATE TABLE community_tips (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  service_id      UUID NOT NULL REFERENCES services(id) ON DELETE CASCADE,
  user_id         UUID,                             -- anonymous if null

  -- Tip content
  tip_type        TEXT NOT NULL,                    -- "cancel_hack", "refund_trick",
                                                    -- "hidden_discount", "retention_offer",
                                                    -- "dark_pattern_report"
  title           TEXT NOT NULL,                    -- "Say 'cancel' 3 times to skip IVR"
  body            TEXT NOT NULL,                    -- detailed explanation
  platform        cancel_platform,                  -- which platform this applies to

  -- Community validation
  upvotes         INTEGER DEFAULT 0,
  downvotes       INTEGER DEFAULT 0,
  status          tip_status DEFAULT 'pending',

  -- Moderation
  reported_count  INTEGER DEFAULT 0,
  moderated_by    TEXT,                             -- 'ai' or admin user id
  moderated_at    TIMESTAMPTZ,

  -- Sync metadata
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_community_tips_service ON community_tips(service_id);
CREATE INDEX idx_community_tips_status ON community_tips(status);
CREATE INDEX idx_community_tips_type ON community_tips(tip_type);

-- View: top tips per service (approved, net positive votes)
CREATE VIEW top_community_tips AS
SELECT *,
  (upvotes - downvotes) AS net_score
FROM community_tips
WHERE status = 'approved'
ORDER BY net_score DESC;


-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- TABLE 8: price_history (UNCHANGED from v2)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

CREATE TABLE price_history (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tier_id         UUID NOT NULL REFERENCES service_tiers(id) ON DELETE CASCADE,
  currency        core_currency NOT NULL,
  old_monthly     DECIMAL(8,2),
  new_monthly     DECIMAL(8,2),
  old_annual      DECIMAL(8,2),
  new_annual      DECIMAL(8,2),
  change_pct      DECIMAL(5,1),
  source          TEXT DEFAULT 'auto',              -- 'auto' | 'manual' | 'user_report'
  recorded_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_price_history_tier ON price_history(tier_id);
CREATE INDEX idx_price_history_date ON price_history(recorded_at);


-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- TABLE 9: service_aliases (UNCHANGED from v2)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

CREATE TABLE service_aliases (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  service_id      UUID NOT NULL REFERENCES services(id) ON DELETE CASCADE,
  alias           TEXT NOT NULL,
  UNIQUE(alias)
);

CREATE INDEX idx_aliases_service ON service_aliases(service_id);


-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- TABLE 10: service_update_log (REPLACES price_check_log)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

CREATE TABLE service_update_log (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  run_at              TIMESTAMPTZ NOT NULL DEFAULT now(),

  -- Scope of update
  update_type         TEXT NOT NULL,                 -- 'monthly_full', 'price_only', 'cancel_guides', 'manual'
  model_used          TEXT DEFAULT 'claude-sonnet',  -- which AI model ran the sweep

  -- Stats
  services_checked    INTEGER DEFAULT 0,
  prices_changed      INTEGER DEFAULT 0,
  guides_updated      INTEGER DEFAULT 0,
  patterns_flagged    INTEGER DEFAULT 0,
  errors              INTEGER DEFAULT 0,

  -- Full results
  summary_json        JSONB,                         -- detailed per-service results
  error_log           JSONB,                         -- any failures

  -- Duration
  duration_seconds    INTEGER,
  api_cost_usd        DECIMAL(6,4)                   -- track Sonnet API cost per sweep
);


-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- HELPER VIEWS
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- Full service snapshot (everything the app needs in one query)
CREATE VIEW service_full AS
SELECT
  s.*,
  -- Aggregate tiers as JSON array
  COALESCE(
    (SELECT json_agg(
      json_build_object(
        'id', t.id,
        'tier_name', t.tier_name,
        'monthly_gbp', t.monthly_gbp,
        'annual_gbp', t.annual_gbp,
        'monthly_usd', t.monthly_usd,
        'annual_usd', t.annual_usd,
        'monthly_eur', t.monthly_eur,
        'annual_eur', t.annual_eur,
        'monthly_pln', t.monthly_pln,
        'annual_pln', t.annual_pln,
        'trial_days', t.trial_days,
        'trial_requires_payment', t.trial_requires_payment,
        'is_popular', t.is_popular
      ) ORDER BY t.sort_order
    ) FROM service_tiers t WHERE t.service_id = s.id),
    '[]'::json
  ) AS tiers,

  -- Aggregate cancel guides
  COALESCE(
    (SELECT json_agg(
      json_build_object(
        'platform', cg.platform,
        'steps', cg.steps,
        'cancel_deeplink', cg.cancel_deeplink,
        'cancel_web_url', cg.cancel_web_url,
        'estimated_minutes', cg.estimated_minutes,
        'warning_text', cg.warning_text,
        'pro_tip', cg.pro_tip
      )
    ) FROM cancel_guides cg WHERE cg.service_id = s.id),
    '[]'::json
  ) AS cancel_guides,

  -- Aggregate refund templates
  COALESCE(
    (SELECT json_agg(
      json_build_object(
        'billing_method', rt.billing_method,
        'steps', rt.steps,
        'email_template', rt.email_template,
        'email_subject', rt.email_subject,
        'contact_email', rt.contact_email,
        'success_rate_pct', rt.success_rate_pct,
        'avg_refund_days', rt.avg_refund_days,
        'refund_window_days', rt.refund_window_days
      )
    ) FROM refund_templates rt WHERE rt.service_id = s.id),
    '[]'::json
  ) AS refund_templates,

  -- Aggregate dark patterns
  COALESCE(
    (SELECT json_agg(
      json_build_object(
        'pattern_type', dp.pattern_type,
        'severity', dp.severity,
        'title', dp.title,
        'description', dp.description,
        'is_active', dp.is_active
      )
    ) FROM dark_pattern_flags dp WHERE dp.service_id = s.id AND dp.is_active = true),
    '[]'::json
  ) AS dark_patterns,

  -- Aggregate alternatives
  COALESCE(
    (SELECT json_agg(
      json_build_object(
        'alt_name', sa.alt_name,
        'reason', sa.reason,
        'price_comparison', sa.price_comparison,
        'relevance_score', sa.relevance_score
      ) ORDER BY sa.relevance_score DESC
    ) FROM service_alternatives sa WHERE sa.service_id = s.id),
    '[]'::json
  ) AS alternatives,

  -- Count of approved community tips
  (SELECT COUNT(*) FROM community_tips ct
   WHERE ct.service_id = s.id AND ct.status = 'approved') AS community_tip_count

FROM services s;


-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- ROW-LEVEL SECURITY (Supabase)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- All service data is public read (no auth needed for the app to cache it)
ALTER TABLE services ENABLE ROW LEVEL SECURITY;
ALTER TABLE service_tiers ENABLE ROW LEVEL SECURITY;
ALTER TABLE cancel_guides ENABLE ROW LEVEL SECURITY;
ALTER TABLE refund_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE dark_pattern_flags ENABLE ROW LEVEL SECURITY;
ALTER TABLE service_alternatives ENABLE ROW LEVEL SECURITY;
ALTER TABLE community_tips ENABLE ROW LEVEL SECURITY;
ALTER TABLE service_aliases ENABLE ROW LEVEL SECURITY;

-- Public read for all service data
CREATE POLICY "Public read services" ON services FOR SELECT USING (true);
CREATE POLICY "Public read tiers" ON service_tiers FOR SELECT USING (true);
CREATE POLICY "Public read cancel_guides" ON cancel_guides FOR SELECT USING (true);
CREATE POLICY "Public read refund_templates" ON refund_templates FOR SELECT USING (true);
CREATE POLICY "Public read dark_patterns" ON dark_pattern_flags FOR SELECT USING (true);
CREATE POLICY "Public read alternatives" ON service_alternatives FOR SELECT USING (true);
CREATE POLICY "Public read approved tips" ON community_tips FOR SELECT USING (status = 'approved');
CREATE POLICY "Public read aliases" ON service_aliases FOR SELECT USING (true);

-- Users can submit community tips
CREATE POLICY "Users can submit tips" ON community_tips
  FOR INSERT WITH CHECK (true);

-- Users can upvote/downvote (update votes only)
CREATE POLICY "Users can vote on tips" ON community_tips
  FOR UPDATE USING (status = 'approved')
  WITH CHECK (status = 'approved');

-- Service account (Loki bot) can write everything
-- Use Supabase service_role key for the AI sweep
-- No policy needed — service_role bypasses RLS


-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- FUNCTIONS
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- Get services updated since last sync (for Isar cache)
CREATE OR REPLACE FUNCTION get_updated_services(since_version INTEGER)
RETURNS SETOF service_full AS $$
  SELECT * FROM service_full
  WHERE data_version > since_version;
$$ LANGUAGE sql STABLE;

-- Bump data_version on any child table update
CREATE OR REPLACE FUNCTION bump_service_version()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE services
  SET data_version = data_version + 1,
      updated_at = now()
  WHERE id = COALESCE(NEW.service_id, OLD.service_id);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply version bump triggers to all child tables
CREATE TRIGGER trg_tiers_version
  AFTER INSERT OR UPDATE OR DELETE ON service_tiers
  FOR EACH ROW EXECUTE FUNCTION bump_service_version();

CREATE TRIGGER trg_cancel_version
  AFTER INSERT OR UPDATE OR DELETE ON cancel_guides
  FOR EACH ROW EXECUTE FUNCTION bump_service_version();

CREATE TRIGGER trg_refund_version
  AFTER INSERT OR UPDATE OR DELETE ON refund_templates
  FOR EACH ROW EXECUTE FUNCTION bump_service_version();

CREATE TRIGGER trg_dark_pattern_version
  AFTER INSERT OR UPDATE OR DELETE ON dark_pattern_flags
  FOR EACH ROW EXECUTE FUNCTION bump_service_version();

CREATE TRIGGER trg_alternatives_version
  AFTER INSERT OR UPDATE OR DELETE ON service_alternatives
  FOR EACH ROW EXECUTE FUNCTION bump_service_version();


-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- SYNC STRATEGY (App-side notes)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- The Flutter app should:
--
-- 1. On first launch:
--    SELECT * FROM service_full;
--    → Cache everything in Isar
--    → Store max(data_version) as local_version
--
-- 2. On subsequent app opens:
--    SELECT * FROM get_updated_services(local_version);
--    → Only sync changed services
--    → Update local_version
--
-- 3. Isar schema mirrors the service_full view:
--    - ServiceCache (maps to services + denormalized children)
--    - Each child (tiers, guides, etc.) stored as JSON in Isar
--    - This avoids needing separate Isar collections per table
--
-- 4. Offline fallback:
--    - If Supabase unreachable, use Isar cache
--    - Show "last updated X days ago" badge if stale > 30 days
--
-- 5. Community tips:
--    - User submits tip → INSERT to community_tips (pending)
--    - Monthly AI sweep moderates pending tips
--    - Approved tips sync to all users on next cache refresh
