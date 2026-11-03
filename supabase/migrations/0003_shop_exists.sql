-- ============================================================================
-- 0003_shop_exists.sql
--
-- Closes a real gap: the app's public Sign Up screen had no way to know,
-- *before* creating an auth.users row, whether this single-shop deployment
-- (SRS §1.4) already has its owner. Every table that could answer that
-- (`shops`) is RLS-locked to members only, so an unauthenticated visitor
-- couldn't even check — they'd sign up, hit `bootstrap_shop()`'s refusal
-- at the create-shop step, and be left with a dead-end account.
--
-- `shop_exists()` is a narrow, boolean-only, SECURITY DEFINER escape hatch
-- granted to `anon` too, so the sign-in/sign-up screens can gate the entry
-- point itself instead of discovering the problem one screen too late. It
-- leaks nothing beyond "does a shop exist yet" — no name, no id, no owner.
--
-- Apply after 0001 and 0002. See supabase/README.md.
-- ============================================================================

create or replace function shop_exists()
returns boolean
language sql
stable
security definer set search_path = public
as $$
  select exists (select 1 from shops);
$$;

grant execute on function shop_exists() to anon, authenticated;
