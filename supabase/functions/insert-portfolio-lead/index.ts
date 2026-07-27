// supabase/functions/insert-portfolio-lead/index.ts
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const TURNSTILE_VERIFY_URL = "https://challenges.cloudflare.com/turnstile/v0/siteverify";

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  const body = await req.json().catch(() => null);
  if (!body) return new Response("Bad JSON", { status: 400 });

  const {
    turnstileToken,
    name,
    email,
    company,
    score,
    max_score,
    percent,
    level_title,
    email_message, // optionnel
  } = body;

  const turnstileSecret = Deno.env.get("TURNSTILE_SITE_KEY");
  if (!turnstileSecret) {
    return new Response("Missing TURNSTILE_SITE_KEY", { status: 500 });
  }

  // 1) Verify Turnstile
  const verifyRes = await fetch(TURNSTILE_VERIFY_URL, {
    method: "POST",
    headers: { "content-type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      secret: turnstileSecret,
      response: turnstileToken,
    }),
  });

  const verifyJson = await verifyRes.json().catch(() => null);
  if (!verifyJson?.success) {
    return new Response(JSON.stringify({ error: "Turnstile failed" }), {
      status: 400,
      headers: { "content-type": "application/json" },
    });
  }

  // 2) Insert with service role (bypass RLS)
  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const serviceRoleKey = Deno.env.get("SUPABASE_ANON_KEY")!;
  const supabase = createClient(supabaseUrl, serviceRoleKey);

  const { data, error } = await supabase
    .from("portfolio_diagnostic_leads")
    .insert({
      name: name ?? null,
      email,
      company: company ?? null,
      score: score ?? 0,
      max_score: max_score ?? 0,
      percent: percent ?? 0,
      level_title,
    })
    .select("*")
    .single();

  if (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { "content-type": "application/json" },
    });
  }

  return new Response(JSON.stringify({ ok: true, lead: data }), {
    status: 200,
    headers: { "content-type": "application/json" },
  });
});