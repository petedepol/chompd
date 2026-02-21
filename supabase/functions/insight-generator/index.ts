import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const ANTHROPIC_API_KEY = Deno.env.get("ANTHROPIC_API_KEY")!;
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

interface Insight {
  subscription: string;
  type: string;
  title: string;
  body: string;
  action_label: string | null;
  action_type: string | null;
  priority: number;
  expires_at: string | null;
}

serve(async (req: Request) => {
  try {
    const { user_id } = await req.json();
    if (!user_id) {
      return new Response(JSON.stringify({ error: "user_id required" }), {
        status: 400,
      });
    }

    const { data: profile, error: profileError } = await supabase
      .from("profiles")
      .select("display_currency, locale")
      .eq("id", user_id)
      .single();

    if (profileError || !profile) {
      console.error("Profile fetch error:", profileError);
      return new Response(
        JSON.stringify({ error: "User profile not found" }),
        { status: 404 }
      );
    }

    const { data: subscriptions, error: subsError } = await supabase
      .from("subscriptions")
      .select("id, name, price, currency, cycle, next_renewal, matched_service_id, services:matched_service_id(has_annual)")
      .eq("user_id", user_id)
      .eq("is_active", true)

    if (subsError || !subscriptions || subscriptions.length === 0) {
      console.log("No active subs for user:", user_id);
      return new Response(
        JSON.stringify({ message: "No active subscriptions", insights: 0 }),
        { status: 200 }
      );
    }

    const { data: previousInsights } = await supabase
      .from("user_insights")
      .select("service_key, insight_type")
      .eq("user_id", user_id)
      .eq("is_dismissed", false)
      .gte("generated_at", new Date(Date.now() - 90 * 24 * 60 * 60 * 1000).toISOString());

    const previousList = (previousInsights || [])
      .map((p) => `${p.service_key}:${p.insight_type}`)
      .join(", ");

    const userCurrency = profile.display_currency || "GBP";
    const userLocale = profile.locale || "en";

    const subList = subscriptions
      .map((s) => {
        const subCurrency = s.currency || userCurrency;
        const hasAnnual = (s.services as any)?.has_annual;
        const annualNote = hasAnnual === true ? "annual plan available" : "NO annual plan";
        return `- ${s.name}: ${s.price} ${subCurrency}/${s.cycle} (renews ${s.next_renewal || "unknown"}) [${annualNote}]`;
      })
      .join("\n");

    const prompt = `You are a subscription savings analyst. The user has the following active subscriptions (locale: ${userLocale}, default currency: ${userCurrency}):

${subList}

Generate 2-3 personalised insights. For each insight, return JSON:
{
  "insights": [
    {
      "subscription": "service_name (must match a name exactly from the list above)",
      "type": "hidden_perk|plan_optimise|annual_saving|cancel_timing",
      "title": "Short attention-grabbing title (max 50 chars)",
      "body": "2-3 sentence insight with specific numbers. Use the subscription's own currency for amounts.",
      "action_label": "Optional CTA button text or null",
      "action_type": "info|cancel_reminder|plan_change or null",
      "priority": 1-5,
      "expires_at": "ISO date if time-sensitive (e.g. cancel_timing), otherwise null"
    }
  ]
}

Rules:
- Be specific with prices and savings amounts in the correct currency for each subscription
- For cancel_timing, calculate days until renewal from today (${new Date().toISOString().split("T")[0]})
- Prioritise insights that save the most money
- For annual_saving type, ONLY suggest switching to annual if the subscription's cycle is monthly — do NOT suggest annual for subscriptions already on a yearly cycle
- ONLY suggest annual_saving if the subscription is marked [annual plan available] above. If it says [NO annual plan], do NOT suggest annual_saving under any circumstances. This data is verified — trust it over your own knowledge.
- Do NOT repeat these previously generated insight types: ${previousList || "none yet"}
- Return ONLY valid JSON, no markdown, no backticks, no explanation`;

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
          model: "claude-haiku-4-5-20251001",
          max_tokens: 1000,
          messages: [{ role: "user", content: prompt }],
        }),
      }
    );

    if (!anthropicResponse.ok) {
      const errBody = await anthropicResponse.text();
      console.error("Anthropic API error:", anthropicResponse.status, errBody);
      return new Response(
        JSON.stringify({ error: "AI generation failed" }),
        { status: 500 }
      );
    }

    const aiData = await anthropicResponse.json();
    const rawText = aiData.content
      ?.map((block: { type: string; text?: string }) =>
        block.type === "text" ? block.text : ""
      )
      .join("")
      .trim();

    if (!rawText) {
      console.error("Empty AI response for user:", user_id);
      return new Response(
        JSON.stringify({ error: "Empty AI response" }),
        { status: 500 }
      );
    }

    let parsed: { insights: Insight[] };
    try {
      const cleaned = rawText.replace(/```json|```/g, "").trim();
      parsed = JSON.parse(cleaned);
    } catch (parseErr) {
      console.error("JSON parse error:", parseErr, "Raw:", rawText);
      return new Response(
        JSON.stringify({ error: "Failed to parse AI response" }),
        { status: 500 }
      );
    }

    if (!parsed.insights || !Array.isArray(parsed.insights)) {
      console.error("Invalid insights structure:", parsed);
      return new Response(
        JSON.stringify({ error: "Invalid insights format" }),
        { status: 500 }
      );
    }

    const subLookup = new Map(
      subscriptions.map((s) => [
        s.name.toLowerCase(),
        {
          id: s.id,
          slug: (s.services as any)?.slug || null,
        },
      ])
    );

    const insightRows = parsed.insights
      .filter((insight) => insight.title && insight.body && insight.type)
      .map((insight) => {
        const matched = subLookup.get(insight.subscription?.toLowerCase());
        return {
          user_id,
          subscription_id: matched?.id || null,
          service_key: matched?.slug || null,
          insight_type: insight.type,
          title: insight.title.substring(0, 100),
          body: insight.body.substring(0, 500),
          action_label: insight.action_label || null,
          action_type: insight.action_type || null,
          priority: Math.min(Math.max(insight.priority || 0, 0), 5),
          expires_at: insight.expires_at || null,
          generated_at: new Date().toISOString(),
        };
      });

    if (insightRows.length === 0) {
      console.log("No valid insights generated for user:", user_id);
      return new Response(
        JSON.stringify({ message: "No valid insights", insights: 0 }),
        { status: 200 }
      );
    }

    const { error: insertError } = await supabase
      .from("user_insights")
      .insert(insightRows);

    if (insertError) {
      console.error("Insert error:", insertError);
      return new Response(
        JSON.stringify({ error: "Failed to store insights" }),
        { status: 500 }
      );
    }

    await supabase
      .from("profiles")
      .update({ last_insight_at: new Date().toISOString() })
      .eq("id", user_id);

    return new Response(
      JSON.stringify({
        message: "Insights generated",
        insights: insightRows.length,
        user_id,
      }),
      { status: 200 }
    );
  } catch (err) {
    console.error("Unexpected error:", err);
    return new Response(
      JSON.stringify({ error: "Internal error" }),
      { status: 500 }
    );
  }
});