-- ============================================
-- CHOMPD DATABASE SCHEMA
-- Run this in Supabase SQL Editor (single execution)
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
  matched_service_id TEXT,
  trap_warning_message TEXT,
  last_reviewed_at TIMESTAMPTZ,
  last_nudged_at TIMESTAMPTZ,
  keep_confirmed BOOLEAN NOT NULL DEFAULT false,
  cancelled_dismissed BOOLEAN NOT NULL DEFAULT false,
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
-- NOTE: No updated_at trigger for subscriptions — client controls updated_at
-- for last-write-wins sync. The trigger was removed because it overwrites
-- the client-provided timestamp, breaking conflict resolution.
CREATE TRIGGER set_updated_at_user_settings
  BEFORE UPDATE ON public.user_settings
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();
