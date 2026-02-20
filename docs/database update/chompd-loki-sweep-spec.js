// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CHOMPD — Loki Monthly Service Sweep (Sonnet via Hetzner VPS)
// Replaces the quarterly price-only checker with a full
// service data update that covers all unified table fields.
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
// SCHEDULE: 1st of each month, 03:00 UTC
// MODEL: claude-sonnet-4-5-20250929 (web search enabled)
// RUNTIME: Node.js on Hetzner VPS (Loki)
// AUTH: Supabase service_role key (bypasses RLS)
// EMAIL: petebotlad@gmail.com for error notifications
//
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// ── SWEEP PHASES ──
//
// Phase 1: PRICE CHECK (existing, expanded)
//   For each service + tier:
//   - Search "[service] [tier] pricing [month] [year]"
//   - Compare GBP, USD, EUR, PLN prices
//   - If changed: update service_tiers, insert price_history, flag in summary
//   - Also check: trial_days, trial_requires_payment changes
//
// Phase 2: CANCEL GUIDE VERIFICATION (NEW)
//   For each service:
//   - Search "how to cancel [service] [year]"
//   - Verify existing steps are still accurate
//   - Check cancel_url / deeplinks still work (HEAD request)
//   - Update cancel_difficulty score
//   - Flag any new dark patterns found during research
//
// Phase 3: REFUND TEMPLATE UPDATE (NEW)
//   For each service:
//   - Search "[service] refund policy [year]"
//   - Verify refund_window_days, contact_email, contact_url
//   - Update success_rate_pct based on community data + web reports
//   - Refresh email_template if service changed their process
//
// Phase 4: DARK PATTERN SCAN (NEW)
//   For each service:
//   - Search "[service] dark pattern" / "[service] hard to cancel"
//   - Cross-reference with community_tips (tip_type = 'dark_pattern_report')
//   - Flag new patterns, mark resolved ones as is_active = false
//   - Update severity based on report volume
//
// Phase 5: ALTERNATIVES CHECK (NEW)
//   For each service:
//   - Search "best [category] alternatives to [service] [year]"
//   - Update price_comparison text
//   - Add new alternatives if significant new competitors emerged
//   - Remove alternatives that no longer exist
//
// Phase 6: COMMUNITY TIP MODERATION (NEW)
//   - Query all community_tips WHERE status = 'pending'
//   - For each tip: ask Sonnet to assess validity
//     - Is it accurate? (cross-reference with known data)
//     - Is it spam? (check for promotion, links, etc.)
//     - Is it still relevant? (not outdated)
//   - Set status to 'approved', 'rejected', or 'outdated'
//   - Log moderation decisions
//
// Phase 7: LOG & NOTIFY
//   - Insert row into service_update_log
//   - Email summary to petebotlad@gmail.com
//   - Include: services checked, prices changed, guides updated,
//     patterns flagged, tips moderated, errors, total API cost

// ── SONNET PROMPT TEMPLATE (per service) ──

const SWEEP_PROMPT = `
You are updating the Chompd subscription database for {{service_name}}.
Today is {{date}}. Check all information carefully using web search.

Current data:
{{current_service_json}}

Tasks:
1. PRICING: Verify all tier prices (GBP, USD, EUR, PLN). Report any changes.
2. CANCEL GUIDE: Verify cancellation steps for iOS, Android, Web. Report if process changed.
3. REFUND: Check refund policy, window, contact info. Report changes.
4. DARK PATTERNS: Note any dark patterns in cancellation/billing process.
5. ALTERNATIVES: List top 3 alternatives with brief reason and price comparison.

Respond ONLY with JSON:
{
  "pricing_changes": [{"tier": "...", "currency": "...", "old": 0, "new": 0}] | null,
  "cancel_guide_changes": {"platform": "...", "new_steps": [...]} | null,
  "refund_changes": {"refund_window_days": 0, "contact_email": "..."} | null,
  "dark_patterns": [{"type": "...", "severity": "...", "title": "...", "description": "..."}] | null,
  "alternatives": [{"name": "...", "reason": "...", "price_comparison": "..."}] | null,
  "cancel_difficulty": 1-10,
  "notes": "any other changes worth noting"
}
`;

// ── COST ESTIMATE ──
//
// ~60 services × 1 Sonnet call with web search each = ~60 API calls
// Sonnet input: ~2K tokens (prompt + current data) = 120K input tokens
// Sonnet output: ~500 tokens per service = 30K output tokens
// Web search: ~3 searches per service = ~180 searches
//
// At current Sonnet pricing (~$3/M input, ~$15/M output):
// Input cost:  ~$0.36
// Output cost: ~$0.45
// Total: ~$0.81 per monthly sweep (very manageable)
//
// Budget alert if sweep exceeds $2.00 (means something went wrong)

// ── ERROR HANDLING ──
//
// - If a service fails, log error and continue to next
// - If >10 services fail, abort sweep and send alert email
// - Retry failed services once after 5-minute delay
// - Never update a service if Sonnet response fails JSON parse
// - Always compare old vs new before writing — never overwrite with empty data

// ── MANUAL TRIGGER ──
//
// Can be triggered outside schedule via:
//   openclaw onboard chompd-sweep --service=netflix  (single service)
//   openclaw onboard chompd-sweep --full              (full sweep)
//   openclaw onboard chompd-sweep --phase=pricing     (single phase)
