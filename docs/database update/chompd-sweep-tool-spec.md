# Chompd — Service Sweep Tool Build Spec

> For Claude Code. Read fully before coding.

---

## What We're Building

A React artifact (runs in Claude.ai) that lets Pete manually trigger a Chompd service database sweep. It calls Claude Sonnet 4 with web search to verify and update subscription service data, shows a diff preview, then commits changes to Supabase.

This is a management tool, not a user-facing feature. Pete uses it from Claude.ai chat.

---

## Architecture

```
┌──────────────────────────────────────────┐
│  React Artifact (Claude.ai)              │
│                                          │
│  1. Select services (dropdown/multi)     │
│  2. Select phases to run                 │
│  3. Hit "Run Sweep"                      │
│  4. Sonnet + web search runs per service │
│  5. Show diff: current vs proposed       │
│  6. "Approve & Commit" → writes Supabase │
└──────────┬───────────────────────────────┘
           │
           ▼
┌──────────────────────┐    ┌─────────────────────┐
│  Anthropic API       │    │  Supabase            │
│  claude-sonnet-4     │    │  (service_role key)  │
│  + web_search tool   │    │                      │
│  (no API key needed  │    │  Tables:             │
│   in artifacts)      │    │  • services          │
│                      │    │  • service_tiers     │
│                      │    │  • cancel_guides     │
│                      │    │  • refund_templates  │
│                      │    │  • dark_pattern_flags│
│                      │    │  • service_alternatives│
│                      │    │  • service_update_log│
└──────────────────────┘    └─────────────────────┘
```

---

## Tech Stack

- **React artifact** (.jsx) — single file, Tailwind CSS
- **Anthropic API** — claude-sonnet-4-5-20250929, web_search_20250305 tool
- **Supabase JS client** — loaded via CDN (https://cdnjs.cloudflare.com/ajax/libs/supabase/2.39.3/supabase.min.js) or import if available
- **No localStorage** — all state in React useState/useReducer

---

## UI Layout

### Header
- "Chompd Service Sweep" title
- Last sweep timestamp (fetched from service_update_log)
- Total services count

### Service Selector
- Multi-select dropdown of all services (fetched from Supabase on load)
- "Select All" button
- Search/filter by name or category
- Show category badges next to each service

### Phase Selector
- Checkboxes for each phase:
  - ☑ Pricing (verify tier prices across GBP/USD/EUR/PLN)
  - ☑ Cancel Guides (verify steps, deeplinks, difficulty score)
  - ☑ Refund Templates (verify policy, window, contact info)
  - ☑ Dark Patterns (scan for new patterns, verify existing)
  - ☑ Alternatives (check competitors, update comparisons)
  - ☑ Community Tips (moderate pending tips)
- "All Phases" toggle

### Run Button
- "Run Sweep" — disabled until at least 1 service + 1 phase selected
- Shows progress: "Checking Netflix (1/5)..." with spinner

### Results Panel
- Per-service expandable cards showing:
  - Service name + category badge
  - Status: ✅ No changes / ⚠️ Changes detected / ❌ Error
  - Diff view for each phase that found changes:
    - Red/green highlighting (old value → new value)
    - New items highlighted in blue
  - "Approve" / "Reject" per service
- Summary bar: "3 services updated, 1 unchanged, 1 error"

### Commit Button
- "Commit Approved Changes" — only enabled if ≥1 service approved
- Writes to Supabase, logs to service_update_log
- Shows confirmation with commit summary

---

## Sonnet Prompt (per service)

```
You are updating the Chompd subscription database.
Today is {date}.

Service: {service_name} ({category})
Current data:
{current_service_json}

Phases to check: {selected_phases}

Use web search to verify EACH selected phase. Be thorough.

For PRICING:
- Search for current {service_name} pricing in GBP, USD, EUR, PLN
- Check each tier: {tier_names}
- Report exact prices found, note any changes from current data
- Check if trial days or trial_requires_payment changed

For CANCEL GUIDES:
- Search "how to cancel {service_name} {year}"
- Verify steps for each platform (iOS, Android, Web)
- Check if cancel URLs still work
- Rate cancel_difficulty 1-10

For REFUND TEMPLATES:
- Search "{service_name} refund policy {year}"
- Verify refund window, contact email, support URL
- Note any process changes

For DARK PATTERNS:
- Search "{service_name} dark pattern" / "hard to cancel"
- Flag any deceptive practices in signup/cancel/billing
- Classify severity: mild/moderate/severe

For ALTERNATIVES:
- Search "best alternatives to {service_name} {year}"
- List top 3 with reason and price comparison

Respond ONLY with valid JSON (no markdown, no backticks):
{
  "pricing": {
    "changes": [
      {"tier": "...", "field": "monthly_gbp", "old": 0.00, "new": 0.00}
    ] | null,
    "trial_changes": {"trial_days": 7, "trial_requires_payment": true} | null
  },
  "cancel_guides": {
    "ios": {"steps": [...], "cancel_deeplink": "...", "warning": "...", "pro_tip": "..."} | null,
    "android": {...} | null,
    "web": {...} | null,
    "cancel_difficulty": 5
  } | null,
  "refund": {
    "refund_window_days": 30,
    "contact_email": "...",
    "contact_url": "...",
    "success_rate_pct": 70,
    "process_notes": "..."
  } | null,
  "dark_patterns": [
    {"type": "...", "severity": "mild|moderate|severe", "title": "...", "description": "..."}
  ] | null,
  "alternatives": [
    {"name": "...", "reason": "...", "price_comparison": "..."}
  ] | null,
  "notes": "anything else notable"
}
```

---

## API Calls

### Anthropic (Sonnet + Web Search)
```javascript
const response = await fetch("https://api.anthropic.com/v1/messages", {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({
    model: "claude-sonnet-4-5-20250929",
    max_tokens: 4096,
    tools: [{ type: "web_search_20250305", name: "web_search" }],
    messages: [{ role: "user", content: sweepPrompt }]
  })
});
```

### Supabase
```javascript
// Load client
const { createClient } = supabase;
const sb = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);

// Read current services
const { data } = await sb.from('service_full').select('*');

// Write updates (example: update tier price)
await sb.from('service_tiers')
  .update({ monthly_gbp: newPrice, verified_at: new Date().toISOString() })
  .eq('id', tierId);

// Log the sweep
await sb.from('service_update_log').insert({
  update_type: 'manual',
  model_used: 'claude-sonnet-4-5-20250929',
  services_checked: count,
  prices_changed: priceChanges,
  // ...
});
```

---

## Supabase Config

Pete will need to provide:
- `SUPABASE_URL` — the project URL
- `SUPABASE_SERVICE_KEY` — service_role key (bypasses RLS, needed for writes)

These should be entered in the artifact UI (text inputs at top), NOT hardcoded.
Store in React state only — no localStorage.

---

## Important Notes

1. **No API key needed** for Anthropic calls from artifacts — it's handled automatically
2. **Supabase service_role key** is needed for writes — Pete enters it in the UI
3. **Rate limiting** — add 2-second delay between Sonnet calls to avoid hammering the API
4. **Error handling** — if Sonnet returns invalid JSON, show raw response and let Pete retry that service
5. **Diff display** — use red/green color coding, not complex diff library. Keep it simple.
6. **No localStorage** — all state in useState. Config (Supabase URL/key) re-entered each session.
7. **The `service_full` view** may not exist yet — fall back to joining services + service_tiers manually if needed
8. **Dark theme** — match Chompd's dark aesthetic (dark bg, accent colors)

---

## Database Schema Reference

### services (master table)
Key columns: id, name, slug, category, brand_color, icon_letter, website_url, cancel_url, pricing_url, refund_policy_url, has_free_tier, has_family, has_annual, has_student, annual_discount_pct, fallback_currency, regions, cancel_difficulty, refund_success_rate, data_version, verified_at

### service_tiers
Key columns: id, service_id, tier_name, monthly_gbp, annual_gbp, monthly_usd, annual_usd, monthly_eur, annual_eur, monthly_pln, annual_pln, trial_days, trial_requires_payment, is_popular, is_student

### cancel_guides
Key columns: id, service_id, platform (ios/android/web/all), steps (JSONB), cancel_deeplink, cancel_web_url, estimated_minutes, warning_text, pro_tip

### refund_templates
Key columns: id, service_id, billing_method (app_store/google_play/direct/paypal/stripe), steps (JSONB), email_template, email_subject, contact_email, contact_url, success_rate_pct, avg_refund_days, refund_window_days

### dark_pattern_flags
Key columns: id, service_id, pattern_type, severity (mild/moderate/severe), title, description, user_impact, reported_count, is_active

### service_alternatives
Key columns: id, service_id, alternative_id, alt_name, reason, price_comparison, relevance_score

### community_tips
Key columns: id, service_id, user_id, tip_type, title, body, platform, upvotes, downvotes, status (pending/approved/rejected/outdated)

### service_update_log
Key columns: id, run_at, update_type, model_used, services_checked, prices_changed, guides_updated, patterns_flagged, errors, summary_json, api_cost_usd
