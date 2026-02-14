#!/usr/bin/env node

/**
 * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 * CHOMPD DB POPULATOR
 * Seeds 63 subscription services using Sonnet + web search
 * Run: node chompd-populate.mjs
 * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 * 
 * Required env vars (or edit the CONFIG section below):
 *   SUPABASE_URL=https://xyz.supabase.co
 *   SUPABASE_SERVICE_KEY=eyJ...
 *   ANTHROPIC_API_KEY=sk-ant-...
 * 
 * Usage:
 *   node chompd-populate.mjs                    # populate all
 *   node chompd-populate.mjs --start=10         # resume from service #10
 *   node chompd-populate.mjs --only=netflix     # single service by slug
 */

// ━━━ CONFIG (override with env vars) ━━━
const CONFIG = {
  SUPABASE_URL: process.env.SUPABASE_URL || "",
  SUPABASE_SERVICE_KEY: process.env.SUPABASE_SERVICE_KEY || "",
  ANTHROPIC_API_KEY: process.env.ANTHROPIC_API_KEY || "",
  DELAY_MS: 3000,        // delay between services
  MAX_SEARCH_ROUNDS: 20, // max web search rounds per service
};

// ━━━ SERVICE CATALOG ━━━
const SERVICE_CATALOG = [
  { name: "Netflix", slug: "netflix", category: "streaming", brand_color: "#E50914", icon_letter: "N", website_url: "https://netflix.com" },
  { name: "Disney+", slug: "disney_plus", category: "streaming", brand_color: "#113CCF", icon_letter: "D+", website_url: "https://disneyplus.com" },
  { name: "Amazon Prime Video", slug: "prime_video", category: "streaming", brand_color: "#00A8E1", icon_letter: "PV", website_url: "https://primevideo.com" },
  { name: "Apple TV+", slug: "apple_tv", category: "streaming", brand_color: "#000000", icon_letter: "TV", website_url: "https://tv.apple.com" },
  { name: "HBO Max", slug: "hbo_max", category: "streaming", brand_color: "#5822B4", icon_letter: "HBO", website_url: "https://max.com" },
  { name: "Paramount+", slug: "paramount_plus", category: "streaming", brand_color: "#0064FF", icon_letter: "P+", website_url: "https://paramountplus.com" },
  { name: "Peacock", slug: "peacock", category: "streaming", brand_color: "#000000", icon_letter: "Pk", website_url: "https://peacocktv.com" },
  { name: "Hulu", slug: "hulu", category: "streaming", brand_color: "#1CE783", icon_letter: "Hu", website_url: "https://hulu.com" },
  { name: "Crunchyroll", slug: "crunchyroll", category: "streaming", brand_color: "#F47521", icon_letter: "CR", website_url: "https://crunchyroll.com" },
  { name: "DAZN", slug: "dazn", category: "streaming", brand_color: "#0C0C0C", icon_letter: "DZ", website_url: "https://dazn.com" },
  { name: "NOW TV", slug: "now_tv", category: "streaming", brand_color: "#78BE20", icon_letter: "NOW", website_url: "https://nowtv.com" },
  { name: "Spotify", slug: "spotify", category: "music", brand_color: "#1DB954", icon_letter: "S", website_url: "https://spotify.com" },
  { name: "Apple Music", slug: "apple_music", category: "music", brand_color: "#FC3C44", icon_letter: "AM", website_url: "https://music.apple.com" },
  { name: "YouTube Music", slug: "youtube_music", category: "music", brand_color: "#FF0000", icon_letter: "YM", website_url: "https://music.youtube.com" },
  { name: "Tidal", slug: "tidal", category: "music", brand_color: "#000000", icon_letter: "Ti", website_url: "https://tidal.com" },
  { name: "Amazon Music", slug: "amazon_music", category: "music", brand_color: "#25D1DA", icon_letter: "AM", website_url: "https://music.amazon.com" },
  { name: "Deezer", slug: "deezer", category: "music", brand_color: "#A238FF", icon_letter: "Dz", website_url: "https://deezer.com" },
  { name: "iCloud+", slug: "icloud", category: "storage", brand_color: "#3693F3", icon_letter: "iC", website_url: "https://icloud.com" },
  { name: "Google One", slug: "google_one", category: "storage", brand_color: "#4285F4", icon_letter: "G1", website_url: "https://one.google.com" },
  { name: "Dropbox", slug: "dropbox", category: "storage", brand_color: "#0061FF", icon_letter: "Db", website_url: "https://dropbox.com" },
  { name: "OneDrive", slug: "onedrive", category: "storage", brand_color: "#0078D4", icon_letter: "OD", website_url: "https://onedrive.live.com" },
  { name: "Microsoft 365", slug: "microsoft_365", category: "productivity", brand_color: "#D83B01", icon_letter: "M3", website_url: "https://microsoft365.com" },
  { name: "Notion", slug: "notion", category: "productivity", brand_color: "#000000", icon_letter: "No", website_url: "https://notion.so" },
  { name: "Evernote", slug: "evernote", category: "productivity", brand_color: "#00A82D", icon_letter: "Ev", website_url: "https://evernote.com" },
  { name: "Todoist", slug: "todoist", category: "productivity", brand_color: "#E44232", icon_letter: "Td", website_url: "https://todoist.com" },
  { name: "Canva Pro", slug: "canva", category: "productivity", brand_color: "#00C4CC", icon_letter: "Ca", website_url: "https://canva.com" },
  { name: "Adobe Creative Cloud", slug: "adobe_cc", category: "productivity", brand_color: "#FF0000", icon_letter: "Ai", website_url: "https://adobe.com" },
  { name: "Grammarly", slug: "grammarly", category: "productivity", brand_color: "#15C39A", icon_letter: "Gr", website_url: "https://grammarly.com" },
  { name: "ChatGPT Plus", slug: "chatgpt", category: "ai", brand_color: "#10A37F", icon_letter: "GP", website_url: "https://chat.openai.com" },
  { name: "Claude Pro", slug: "claude", category: "ai", brand_color: "#D4A574", icon_letter: "Cl", website_url: "https://claude.ai" },
  { name: "Midjourney", slug: "midjourney", category: "ai", brand_color: "#000000", icon_letter: "MJ", website_url: "https://midjourney.com" },
  { name: "Perplexity Pro", slug: "perplexity", category: "ai", brand_color: "#20808D", icon_letter: "Px", website_url: "https://perplexity.ai" },
  { name: "GitHub Copilot", slug: "copilot", category: "ai", brand_color: "#000000", icon_letter: "Co", website_url: "https://github.com/features/copilot" },
  { name: "Cursor Pro", slug: "cursor", category: "ai", brand_color: "#000000", icon_letter: "Cu", website_url: "https://cursor.com" },
  { name: "Strava", slug: "strava", category: "fitness", brand_color: "#FC4C02", icon_letter: "St", website_url: "https://strava.com" },
  { name: "Peloton", slug: "peloton", category: "fitness", brand_color: "#000000", icon_letter: "Pe", website_url: "https://onepeloton.com" },
  { name: "MyFitnessPal", slug: "myfitnesspal", category: "fitness", brand_color: "#0070E0", icon_letter: "MF", website_url: "https://myfitnesspal.com" },
  { name: "Headspace", slug: "headspace", category: "fitness", brand_color: "#F47D31", icon_letter: "Hs", website_url: "https://headspace.com" },
  { name: "Calm", slug: "calm", category: "fitness", brand_color: "#4A90D9", icon_letter: "Ca", website_url: "https://calm.com" },
  { name: "Xbox Game Pass", slug: "xbox_game_pass", category: "gaming", brand_color: "#107C10", icon_letter: "XB", website_url: "https://xbox.com/game-pass" },
  { name: "PlayStation Plus", slug: "ps_plus", category: "gaming", brand_color: "#003791", icon_letter: "PS", website_url: "https://playstation.com/ps-plus" },
  { name: "Nintendo Switch Online", slug: "nintendo_online", category: "gaming", brand_color: "#E60012", icon_letter: "NS", website_url: "https://nintendo.com/switch/online" },
  { name: "EA Play", slug: "ea_play", category: "gaming", brand_color: "#000000", icon_letter: "EA", website_url: "https://ea.com/ea-play" },
  { name: "Kindle Unlimited", slug: "kindle_unlimited", category: "reading", brand_color: "#FF9900", icon_letter: "KU", website_url: "https://amazon.com/kindle-unlimited" },
  { name: "Audible", slug: "audible", category: "reading", brand_color: "#F8991D", icon_letter: "Au", website_url: "https://audible.com" },
  { name: "Medium", slug: "medium", category: "reading", brand_color: "#000000", icon_letter: "Me", website_url: "https://medium.com" },
  { name: "The Athletic", slug: "the_athletic", category: "reading", brand_color: "#000000", icon_letter: "TA", website_url: "https://theathletic.com" },
  { name: "Slack Pro", slug: "slack", category: "communication", brand_color: "#4A154B", icon_letter: "Sl", website_url: "https://slack.com" },
  { name: "Discord Nitro", slug: "discord_nitro", category: "communication", brand_color: "#5865F2", icon_letter: "Di", website_url: "https://discord.com" },
  { name: "Zoom", slug: "zoom", category: "communication", brand_color: "#2D8CFF", icon_letter: "Zm", website_url: "https://zoom.us" },
  { name: "Apple One", slug: "apple_one", category: "bundle", brand_color: "#000000", icon_letter: "A1", website_url: "https://apple.com/apple-one" },
  { name: "Amazon Prime", slug: "amazon_prime", category: "bundle", brand_color: "#FF9900", icon_letter: "AP", website_url: "https://amazon.com/prime" },
  { name: "YouTube Premium", slug: "youtube_premium", category: "bundle", brand_color: "#FF0000", icon_letter: "YP", website_url: "https://youtube.com/premium" },
  { name: "GitHub Pro", slug: "github", category: "developer", brand_color: "#181717", icon_letter: "GH", website_url: "https://github.com" },
  { name: "Figma", slug: "figma", category: "developer", brand_color: "#F24E1E", icon_letter: "Fi", website_url: "https://figma.com" },
  { name: "Vercel Pro", slug: "vercel", category: "developer", brand_color: "#000000", icon_letter: "Vc", website_url: "https://vercel.com" },
  { name: "NordVPN", slug: "nordvpn", category: "vpn", brand_color: "#4687FF", icon_letter: "NV", website_url: "https://nordvpn.com" },
  { name: "ExpressVPN", slug: "expressvpn", category: "vpn", brand_color: "#DA3940", icon_letter: "EV", website_url: "https://expressvpn.com" },
  { name: "Surfshark", slug: "surfshark", category: "vpn", brand_color: "#178BF1", icon_letter: "Sf", website_url: "https://surfshark.com" },
  { name: "The Times", slug: "the_times", category: "news", brand_color: "#000000", icon_letter: "TT", website_url: "https://thetimes.com" },
  { name: "The Guardian", slug: "the_guardian", category: "news", brand_color: "#052962", icon_letter: "TG", website_url: "https://theguardian.com" },
  { name: "Washington Post", slug: "wapo", category: "news", brand_color: "#000000", icon_letter: "WP", website_url: "https://washingtonpost.com" },
  { name: "New York Times", slug: "nyt", category: "news", brand_color: "#000000", icon_letter: "NYT", website_url: "https://nytimes.com" },
];

// ━━━ COLORS FOR TERMINAL ━━━
const c = {
  reset: "\x1b[0m", bold: "\x1b[1m", dim: "\x1b[2m",
  red: "\x1b[31m", green: "\x1b[32m", yellow: "\x1b[33m",
  blue: "\x1b[34m", magenta: "\x1b[35m", cyan: "\x1b[36m",
  orange: "\x1b[38;5;208m",
};

function log(msg, color = "") { console.log(`${color}${msg}${c.reset}`); }
function logErr(msg) { log(`  ❌ ${msg}`, c.red); }
function logOk(msg) { log(`  ✓ ${msg}`, c.green); }
function logWarn(msg) { log(`  ⚠ ${msg}`, c.yellow); }
function logDim(msg) { log(`  ${msg}`, c.dim); }

// ━━━ PROMPT BUILDER ━━━
function buildPrompt(service) {
  return `You are populating the Chompd subscription database with real, current data.
Today's date: ${new Date().toLocaleDateString("en-GB", { day: "numeric", month: "long", year: "numeric" })}.

Service: ${service.name}
Category: ${service.category}
Website: ${service.website_url}

Use web search to find ALL of the following. Be thorough and accurate.

1. PRICING TIERS: Find every subscription tier with prices in GBP, USD, EUR, and PLN.
   Include trial info (free trial days, whether payment method required).
   Note which tier is most popular. Note if student pricing exists.

2. CANCEL GUIDE: How to cancel on iOS, Android, and Web.
   Find the direct cancel URL. Rate difficulty 1-10.
   Note any warnings or pro tips.

3. REFUND INFO: Refund policy, window (days), contact email, support URL, success rate estimate.

4. DARK PATTERNS: Any dark patterns? (buried cancel, phone-only cancel, guilt trips, confusing tiers, hidden auto-renew, fake countdowns, stealth price increases)

5. ALTERNATIVES: Top 3 alternatives with reason and price comparison.

6. SERVICE FLAGS: has_free_tier, has_family, has_annual, has_student, annual_discount_pct

Respond ONLY with valid JSON (no markdown, no backticks, no preamble):
{
  "tiers": [
    {
      "tier_name": "Standard",
      "monthly_gbp": 10.99, "annual_gbp": null,
      "monthly_usd": 15.49, "annual_usd": null,
      "monthly_eur": 12.99, "annual_eur": null,
      "monthly_pln": 43.00, "annual_pln": null,
      "trial_days": null, "trial_requires_payment": false,
      "is_popular": true, "is_student": false, "sort_order": 0
    }
  ],
  "flags": {
    "has_free_tier": false, "has_family": true, "has_annual": false,
    "has_student": false, "annual_discount_pct": null
  },
  "cancel_url": "https://...",
  "pricing_url": "https://...",
  "refund_policy_url": "https://...",
  "cancel_difficulty": 3,
  "cancel_guides": {
    "ios": {
      "steps": [
        {"step": 1, "title": "Open Settings", "detail": "Go to Settings app"},
        {"step": 2, "title": "Tap your name", "detail": "Tap Apple ID at top"}
      ],
      "cancel_deeplink": null, "cancel_web_url": null,
      "warning": null, "pro_tip": null
    },
    "android": null,
    "web": null
  },
  "refund": {
    "refund_window_days": 30, "contact_email": "support@example.com",
    "contact_url": "https://...", "success_rate_pct": 70,
    "avg_refund_days": 5, "process_notes": "..."
  },
  "dark_patterns": [
    {"type": "buried_cancel", "severity": "mild", "title": "...", "description": "..."}
  ],
  "alternatives": [
    {"name": "...", "reason": "...", "price_comparison": "..."}
  ]
}`;
}

// ━━━ JSON EXTRACTION ━━━
function extractJSON(text) {
  let cleaned = text.replace(/```json\s*/g, "").replace(/```\s*/g, "").trim();
  try { return JSON.parse(cleaned); } catch {}
  const first = cleaned.indexOf("{");
  const last = cleaned.lastIndexOf("}");
  if (first !== -1 && last > first) {
    try { return JSON.parse(cleaned.slice(first, last + 1)); } catch {}
  }
  throw new Error("Could not extract JSON from response");
}

// ━━━ SONNET API ━━━
async function callSonnet(prompt) {
  let messages = [{ role: "user", content: prompt }];

  for (let round = 0; round < CONFIG.MAX_SEARCH_ROUNDS; round++) {
    const res = await fetch("https://api.anthropic.com/v1/messages", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "x-api-key": CONFIG.ANTHROPIC_API_KEY,
        "anthropic-version": "2023-06-01",
      },
      body: JSON.stringify({
        model: "claude-sonnet-4-5-20250929",
        max_tokens: 4096,
        tools: [{ type: "web_search_20250305", name: "web_search" }],
        messages,
      }),
    });

    if (!res.ok) {
      const errText = await res.text();
      throw new Error(`Anthropic API ${res.status}: ${errText}`);
    }

    const data = await res.json();
    const content = data.content || [];

    // End turn with text → extract JSON
    if (data.stop_reason === "end_turn") {
      const textBlocks = content.filter(b => b.type === "text").map(b => b.text).join("\n");
      if (textBlocks.trim()) return extractJSON(textBlocks);
    }

    // Tool use → continue conversation
    const toolUses = content.filter(b => b.type === "tool_use");
    if (toolUses.length > 0) {
      messages.push({ role: "assistant", content });
      const toolResults = toolUses.map(tu => ({
        type: "tool_result",
        tool_use_id: tu.id,
        content: "Search completed",
      }));
      messages.push({ role: "user", content: toolResults });
      logDim(`...web search round ${round + 1}`);
      continue;
    }

    // Fallback
    const textBlocks = content.filter(b => b.type === "text").map(b => b.text).join("\n");
    if (textBlocks.trim()) return extractJSON(textBlocks);
  }

  throw new Error("Max search rounds exceeded");
}

// ━━━ SUPABASE ━━━
async function sbPost(table, body) {
  const res = await fetch(`${CONFIG.SUPABASE_URL}/rest/v1/${table}`, {
    method: "POST",
    headers: {
      apikey: CONFIG.SUPABASE_SERVICE_KEY,
      Authorization: `Bearer ${CONFIG.SUPABASE_SERVICE_KEY}`,
      "Content-Type": "application/json",
      Prefer: "return=representation",
    },
    body: JSON.stringify(body),
  });
  if (!res.ok) {
    const errText = await res.text();
    throw new Error(`${table} INSERT ${res.status}: ${errText}`);
  }
  return res.json();
}

// ━━━ MAIN ━━━
async function main() {
  // Validate config
  if (!CONFIG.SUPABASE_URL || !CONFIG.SUPABASE_SERVICE_KEY || !CONFIG.ANTHROPIC_API_KEY) {
    log("\n🐟 Chompd DB Populator", c.orange + c.bold);
    log("\nMissing config! Set these env vars:\n", c.red);
    log("  export SUPABASE_URL=https://xyz.supabase.co", c.cyan);
    log("  export SUPABASE_SERVICE_KEY=eyJ...", c.cyan);
    log("  export ANTHROPIC_API_KEY=sk-ant-...", c.cyan);
    log("\nThen run:  node chompd-populate.mjs\n", c.dim);
    process.exit(1);
  }

  // Parse args
  const args = process.argv.slice(2);
  let startIdx = 0;
  let onlySlug = null;

  for (const arg of args) {
    if (arg.startsWith("--start=")) startIdx = parseInt(arg.split("=")[1]) - 1;
    if (arg.startsWith("--only=")) onlySlug = arg.split("=")[1];
  }

  let services = SERVICE_CATALOG;
  if (onlySlug) {
    services = services.filter(s => s.slug === onlySlug);
    if (services.length === 0) {
      logErr(`No service found with slug "${onlySlug}"`);
      process.exit(1);
    }
  } else {
    services = services.slice(startIdx);
  }

  log("\n🐟 Chompd DB Populator", c.orange + c.bold);
  log(`━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`, c.dim);
  log(`Services: ${services.length}`, c.cyan);
  log(`Supabase: ${CONFIG.SUPABASE_URL}`, c.dim);
  log(`Model:    claude-sonnet-4-5-20250929 + web search`, c.dim);
  log(`━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n`, c.dim);

  // Test Supabase connection
  logDim("Testing Supabase connection...");
  try {
    const testRes = await fetch(`${CONFIG.SUPABASE_URL}/rest/v1/services?select=count`, {
      headers: { apikey: CONFIG.SUPABASE_SERVICE_KEY, Authorization: `Bearer ${CONFIG.SUPABASE_SERVICE_KEY}` },
    });
    if (!testRes.ok) throw new Error(`${testRes.status}`);
    logOk("Supabase connected");
  } catch (e) {
    logErr(`Supabase connection failed: ${e.message}`);
    process.exit(1);
  }

  let done = 0, errors = 0;
  const startTime = Date.now();

  for (let i = 0; i < services.length; i++) {
    const svc = services[i];
    const num = startIdx + i + 1;
    log(`\n[${num}/${SERVICE_CATALOG.length}] ${svc.name}`, c.bold + c.orange);

    try {
      // Call Sonnet
      logDim("Calling Sonnet with web search...");
      const data = await callSonnet(buildPrompt(svc));
      logDim("Got response, writing to Supabase...");

      // Insert service
      const [inserted] = await sbPost("services", {
        name: svc.name, slug: svc.slug, category: svc.category,
        brand_color: svc.brand_color, icon_letter: svc.icon_letter,
        website_url: svc.website_url,
        cancel_url: data.cancel_url || null,
        pricing_url: data.pricing_url || null,
        refund_policy_url: data.refund_policy_url || null,
        has_free_tier: data.flags?.has_free_tier || false,
        has_family: data.flags?.has_family || false,
        has_annual: data.flags?.has_annual || false,
        has_student: data.flags?.has_student || false,
        annual_discount_pct: data.flags?.annual_discount_pct || null,
        cancel_difficulty: data.cancel_difficulty || null,
        refund_success_rate: data.refund?.success_rate_pct || null,
        fallback_currency: "USD", regions: ["GB", "US"],
      });
      const sid = inserted.id;
      logOk(`Service created (${sid.slice(0, 8)}...)`);

      // Tiers
      if (data.tiers?.length > 0) {
        for (const t of data.tiers) {
          await sbPost("service_tiers", {
            service_id: sid, tier_name: t.tier_name,
            monthly_gbp: t.monthly_gbp, annual_gbp: t.annual_gbp,
            monthly_usd: t.monthly_usd, annual_usd: t.annual_usd,
            monthly_eur: t.monthly_eur, annual_eur: t.annual_eur,
            monthly_pln: t.monthly_pln, annual_pln: t.annual_pln,
            trial_days: t.trial_days || null,
            trial_requires_payment: t.trial_requires_payment ?? true,
            sort_order: t.sort_order || 0,
            is_popular: t.is_popular || false,
            is_student: t.is_student || false,
          });
        }
        logOk(`${data.tiers.length} tier(s)`);
      }

      // Cancel guides
      if (data.cancel_guides) {
        let gc = 0;
        for (const [platform, guide] of Object.entries(data.cancel_guides)) {
          if (!guide) continue;
          await sbPost("cancel_guides", {
            service_id: sid, platform,
            steps: guide.steps || [],
            cancel_deeplink: guide.cancel_deeplink || null,
            cancel_web_url: guide.cancel_web_url || null,
            warning_text: guide.warning || null,
            pro_tip: guide.pro_tip || null,
          });
          gc++;
        }
        if (gc > 0) logOk(`${gc} cancel guide(s)`);
      }

      // Refund templates
      if (data.refund) {
        const methods = ["app_store", "google_play", "direct", "bank_chargeback"];
        const rates = { app_store: 80, google_play: 70, direct: 50, bank_chargeback: 40 };
        const days = { app_store: 2, google_play: 4, direct: 10, bank_chargeback: 12 };
        for (const m of methods) {
          await sbPost("refund_templates", {
            service_id: sid, billing_method: m, steps: [],
            contact_email: data.refund.contact_email || null,
            contact_url: data.refund.contact_url || null,
            success_rate_pct: rates[m],
            avg_refund_days: days[m],
            refund_window_days: data.refund.refund_window_days || null,
          });
        }
        logOk("4 refund templates");
      }

      // Dark patterns
      if (data.dark_patterns?.length > 0) {
        for (const dp of data.dark_patterns) {
          await sbPost("dark_pattern_flags", {
            service_id: sid,
            pattern_type: dp.type || "other",
            severity: ["mild", "moderate", "severe"].includes(dp.severity) ? dp.severity : "mild",
            title: dp.title, description: dp.description, is_active: true,
          });
        }
        logWarn(`${data.dark_patterns.length} dark pattern(s)`);
      }

      // Alternatives
      if (data.alternatives?.length > 0) {
        for (const alt of data.alternatives) {
          await sbPost("service_alternatives", {
            service_id: sid, alt_name: alt.name,
            reason: alt.reason, price_comparison: alt.price_comparison || null,
            relevance_score: 5,
          });
        }
        logOk(`${data.alternatives.length} alternative(s)`);
      }

      // Aliases
      for (const alias of [...new Set([svc.slug.replace(/_/g, " "), svc.name.toLowerCase()])]) {
        try { await sbPost("service_aliases", { service_id: sid, alias }); } catch {}
      }

      done++;
      log(`  ✅ ${svc.name} complete`, c.green + c.bold);

    } catch (e) {
      errors++;
      logErr(`${svc.name} FAILED: ${e.message}`);
    }

    // Rate limit
    if (i < services.length - 1) {
      await new Promise(r => setTimeout(r, CONFIG.DELAY_MS));
    }
  }

  // Log sweep
  try {
    await sbPost("service_update_log", {
      update_type: "initial_seed", model_used: "claude-sonnet-4-5-20250929",
      services_checked: done + errors, prices_changed: done,
      guides_updated: done, patterns_flagged: 0, errors,
      summary_json: { seeded: done, failed: errors },
      duration_seconds: Math.round((Date.now() - startTime) / 1000),
    });
  } catch {}

  const elapsed = Math.round((Date.now() - startTime) / 1000);
  log(`\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`, c.dim);
  log(`🐟 Done! ${done} seeded, ${errors} errors, ${elapsed}s elapsed`, c.orange + c.bold);
  log(`━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n`, c.dim);
}

main().catch(e => { console.error(e); process.exit(1); });
