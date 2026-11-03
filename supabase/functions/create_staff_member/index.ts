// create_staff_member
//
// The only way a staff/tailor/admin account comes into existence (SRS §3:
// "the owner controls staff accounts"; no public registration may grant
// staff privileges). Creating another user's auth.users row requires the
// Supabase service-role key, which must never ship inside the Flutter app
// — so this has to run server-side, as an Edge Function, not a Postgres
// RPC callable with the anon key.
//
// Deploy: `supabase functions deploy create_staff_member` (once the CLI is
// linked), or paste this file into the Supabase Dashboard's Edge Functions
// editor. SUPABASE_URL / SUPABASE_SERVICE_ROLE_KEY / SUPABASE_ANON_KEY are
// injected automatically by the Edge Function runtime — nothing to
// configure. See supabase/README.md.
//
// Call from the app via `client.functions.invoke('create_staff_member',
// body: {...})` — the caller's JWT is forwarded automatically, which is
// how this function knows who is asking.

import { createClient } from "jsr:@supabase/supabase-js@2";

const ALLOWED_ROLES = ["admin", "tailor", "staff"] as const;
type StaffRole = (typeof ALLOWED_ROLES)[number];

function jsonResponse(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return jsonResponse({ error: "Method not allowed" }, 405);
  }

  const authHeader = req.headers.get("Authorization");
  if (!authHeader) {
    return jsonResponse({ error: "Missing Authorization header" }, 401);
  }

  let payload: { email?: string; password?: string; fullName?: string; role?: string };
  try {
    payload = await req.json();
  } catch {
    return jsonResponse({ error: "Invalid JSON body" }, 400);
  }

  const { email, password, fullName, role } = payload;
  if (!email || !password || !fullName || !role) {
    return jsonResponse({ error: "email, password, fullName and role are required" }, 400);
  }
  if (!ALLOWED_ROLES.includes(role as StaffRole)) {
    return jsonResponse({ error: `role must be one of: ${ALLOWED_ROLES.join(", ")}` }, 400);
  }
  if (password.length < 6) {
    return jsonResponse({ error: "password must be at least 6 characters" }, 400);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY")!;

  // Identify the caller from their own JWT — never trust a caller-supplied id.
  const callerClient = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authHeader } },
  });
  const { data: callerUser, error: callerError } = await callerClient.auth.getUser();
  if (callerError || !callerUser?.user) {
    return jsonResponse({ error: "Not authenticated" }, 401);
  }

  // Service-role client bypasses RLS on purpose — this function *is* the
  // controlled path RLS defers to for this one operation.
  const adminClient = createClient(supabaseUrl, serviceRoleKey);

  const { data: membership, error: membershipError } = await adminClient
    .from("shop_members")
    .select("shop_id, role, is_active")
    .eq("user_id", callerUser.user.id)
    .eq("is_active", true)
    .maybeSingle();

  if (membershipError) {
    return jsonResponse({ error: membershipError.message }, 500);
  }
  if (!membership || !["owner", "admin"].includes(membership.role)) {
    return jsonResponse({ error: "Only the shop owner or an admin can add staff" }, 403);
  }

  const { data: created, error: createError } = await adminClient.auth.admin.createUser({
    email,
    password,
    email_confirm: true,
    user_metadata: { full_name: fullName },
  });
  if (createError || !created?.user) {
    return jsonResponse({ error: createError?.message ?? "Failed to create account" }, 400);
  }

  const { error: memberInsertError } = await adminClient.from("shop_members").insert({
    shop_id: membership.shop_id,
    user_id: created.user.id,
    role,
  });
  if (memberInsertError) {
    // Roll back the orphaned auth user rather than leave a login with no
    // shop membership — the exact dead-end this function exists to avoid.
    await adminClient.auth.admin.deleteUser(created.user.id);
    return jsonResponse({ error: memberInsertError.message }, 500);
  }

  await adminClient.from("audit_logs").insert({
    actor_id: callerUser.user.id,
    action: "staff.create",
    entity_type: "shop_members",
    entity_id: created.user.id,
    new_values: { shop_id: membership.shop_id, role, email, full_name: fullName },
  });

  return jsonResponse({
    id: created.user.id,
    email,
    fullName,
    role,
    shopId: membership.shop_id,
  });
});
