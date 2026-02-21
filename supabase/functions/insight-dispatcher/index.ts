// supabase/functions/insight-dispatcher/index.ts
//
// Dispatches insight generation for Pro users due for refresh.
// Runs weekly via pg_cron (Monday 3am UTC).
// Paginates through all due users with a timeout guard.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

// How many users to fetch per query (pagination batch)
const BATCH_SIZE = 250;

// Minimum days between insight generations per user
const MIN_INTERVAL_DAYS = 7;

// Stop processing 10s before Edge Function timeout (150s)
const MAX_RUNTIME_MS = 140_000;

serve(async (_req: Request) => {
  try {
    const startTime = Date.now();
    const cutoffDate = new Date(
      Date.now() - MIN_INTERVAL_DAYS * 24 * 60 * 60 * 1000
    ).toISOString();

    let totalProcessed = 0;
    const allResults: Array<Record<string, unknown>> = [];
    let hasMore = true;

    while (hasMore) {
      // Check if we're approaching timeout
      if (Date.now() - startTime > MAX_RUNTIME_MS) {
        console.log(
          `Approaching timeout after ${totalProcessed} users, stopping`
        );
        break;
      }

      // Find Pro users who are due for insights.
      // Processed users drop out of this query because insight-generator
      // updates last_insight_at, so we always fetch from the top.
      const { data: dueUsers, error: queryError } = await supabase
        .from("profiles")
        .select("id")
        .eq("is_pro", true)
        .or(`last_insight_at.is.null,last_insight_at.lt.${cutoffDate}`)
        .limit(BATCH_SIZE);

      if (queryError) {
        console.error("Query error:", queryError);
        return new Response(
          JSON.stringify({
            error: "Failed to query users",
            processed: totalProcessed,
          }),
          { status: 500 }
        );
      }

      if (!dueUsers || dueUsers.length === 0) {
        hasMore = false;
        break;
      }

      console.log(
        `Batch: ${dueUsers.length} users (total so far: ${totalProcessed})`
      );

      for (const user of dueUsers) {
        // Check timeout before each user call
        if (Date.now() - startTime > MAX_RUNTIME_MS) {
          console.log(
            `Timeout guard hit during batch at user ${totalProcessed}`
          );
          hasMore = false;
          break;
        }

        try {
          const response = await fetch(
            `${SUPABASE_URL}/functions/v1/insight-generator`,
            {
              method: "POST",
              headers: {
                Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
                "Content-Type": "application/json",
              },
              body: JSON.stringify({ user_id: user.id }),
            }
          );

          const result = await response.json();
          allResults.push({
            user_id: user.id,
            status: response.status,
            ...result,
          });
          console.log(`User ${user.id}: ${response.status}`, result);
        } catch (err) {
          console.error(`Error processing user ${user.id}:`, err);
          allResults.push({
            user_id: user.id,
            status: "error",
            error: String(err),
          });
        }

        totalProcessed++;

        // Small delay between users to avoid rate limits
        await new Promise((resolve) => setTimeout(resolve, 500));
      }

      // If we got fewer than BATCH_SIZE, no more users to process
      if (dueUsers.length < BATCH_SIZE) {
        hasMore = false;
      }
    }

    const elapsed = Math.round((Date.now() - startTime) / 1000);
    console.log(`Dispatch complete: ${totalProcessed} users in ${elapsed}s`);

    return new Response(
      JSON.stringify({
        message: "Dispatch complete",
        processed: totalProcessed,
        elapsed_seconds: elapsed,
        results: allResults,
      }),
      { status: 200 }
    );
  } catch (err) {
    console.error("Dispatcher error:", err);
    return new Response(
      JSON.stringify({ error: "Dispatcher failed" }),
      { status: 500 }
    );
  }
});
