import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2";

const ANTHROPIC_API_KEY = Deno.env.get("ANTHROPIC_API_KEY")!;
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const ALLOWED_MODELS = [
  "claude-haiku-4-5-20251001",
  "claude-sonnet-4-6",
];

const FREE_SCAN_LIMIT = 1;

Deno.serve(async (req: Request) => {
  // CORS preflight
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
      return new Response(JSON.stringify({ error: "No auth header" }), {
        status: 401,
        headers: { "Content-Type": "application/json" },
      });
    }

    const supabaseAdmin = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);
    const token = authHeader.replace("Bearer ", "");
    const {
      data: { user },
      error: authError,
    } = await supabaseAdmin.auth.getUser(token);

    if (authError || !user) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { "Content-Type": "application/json" },
      });
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

    if (!isPro && scanCount >= FREE_SCAN_LIMIT) {
      return new Response(
        JSON.stringify({
          error: "scan_limit_reached",
          limit: FREE_SCAN_LIMIT,
        }),
        {
          status: 429,
          headers: { "Content-Type": "application/json" },
        }
      );
    }

    // 3. Validate + forward to Anthropic
    const body = await req.json();
    const { model, messages, max_tokens, system } = body;

    if (!ALLOWED_MODELS.includes(model)) {
      return new Response(JSON.stringify({ error: "Invalid model" }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      });
    }

    const startTime = Date.now();
    const anthropicResponse = await fetch(
      "https://api.anthropic.com/v1/messages",
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "x-api-key": ANTHROPIC_API_KEY,
          "anthropic-version": "2023-06-01",
        },
        body: JSON.stringify({
          model,
          max_tokens: max_tokens || 4096,
          system,
          messages,
        }),
      }
    );

    const result = await anthropicResponse.json();
    const durationMs = Date.now() - startTime;

    // 4. Increment scan count for free users (only on successful AI response)
    if (!isPro && anthropicResponse.ok) {
      await supabaseAdmin
        .from("user_settings")
        .update({ scan_count_used: scanCount + 1 })
        .eq("user_id", user.id);
    }

    // Detect service name + trap from response (best-effort)
    let serviceDetected: string | null = null;
    let trapDetected = false;
    try {
      const text = result.content?.[0]?.text;
      if (text) {
        const parsed = JSON.parse(
          text.replace(/```json?\s*/g, "").replace(/```\s*$/g, "")
        );
        const sub = parsed.subscription || parsed;
        serviceDetected = sub.service_name || null;
        trapDetected = parsed.trap?.is_trap || false;
      }
    } catch {
      // Best-effort — don't fail on parse errors
    }

    await supabaseAdmin.from("scan_logs").insert({
      user_id: user.id,
      model_used: model,
      escalated: model.includes("sonnet"),
      service_detected: serviceDetected,
      trap_detected: trapDetected,
      scan_duration_ms: durationMs,
      tokens_used:
        (result.usage?.input_tokens || 0) +
        (result.usage?.output_tokens || 0),
      cost_estimate: estimateCost(model, result.usage),
    });

    return new Response(JSON.stringify(result), {
      headers: { "Content-Type": "application/json" },
    });
  } catch (error) {
    return new Response(
      JSON.stringify({ error: (error as Error).message }),
      {
        status: 500,
        headers: { "Content-Type": "application/json" },
      }
    );
  }
});

function estimateCost(
  model: string,
  usage: { input_tokens?: number; output_tokens?: number } | undefined
): number {
  if (!usage) return 0;
  const input = usage.input_tokens || 0;
  const output = usage.output_tokens || 0;
  if (model.includes("haiku")) {
    return (input * 0.25 + output * 1.25) / 1_000_000;
  }
  // Sonnet pricing
  return (input * 3 + output * 15) / 1_000_000;
}
