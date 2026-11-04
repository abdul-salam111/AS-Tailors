-- ============================================================================
-- 0004_join_existing_shop.sql
--
-- Product decision (2026-11-05): this deployment is single-shop for one
-- real business, not a multi-tenant SaaS signup funnel. `bootstrap_shop()`
-- (0001) already refuses once a shop exists — that's correct for the
-- *first* account, but left every account after it stuck: `shop_exists()`
-- (0003) could tell the sign-up screen a shop exists, but nothing let a
-- new signup actually become staff of it.
--
-- `join_existing_shop()` closes that gap: once the single shop exists, any
-- newly-signed-up authenticated user with no existing membership can call
-- this once to be added as `staff` (no owner approval step — see the
-- decision this migration encodes). Mirrors `bootstrap_shop()`'s shape
-- (SECURITY DEFINER, same guard checks, same audit logging) and returns
-- `shops` so the Flutter side can reuse `ShopModel`/`ShopEntity` as-is.
--
-- Apply after 0001-0003. See supabase/README.md.
-- ============================================================================

create or replace function join_existing_shop()
returns shops
language plpgsql
security definer set search_path = public
as $$
declare
  v_shop shops;
begin
  if auth.uid() is null then
    raise exception 'Must be authenticated to join a shop';
  end if;

  if exists (select 1 from shop_members where user_id = auth.uid()) then
    raise exception 'This account already belongs to a shop';
  end if;

  select * into v_shop from shops order by created_at asc limit 1;

  if v_shop.id is null then
    raise exception 'No shop exists yet for this deployment';
  end if;

  insert into shop_members (shop_id, user_id, role)
  values (v_shop.id, auth.uid(), 'staff');

  insert into audit_logs (actor_id, action, entity_type, entity_id, new_values)
  values (
    auth.uid(),
    'shop_member.auto_join',
    'shop_members',
    v_shop.id,
    jsonb_build_object('user_id', auth.uid(), 'role', 'staff')
  );

  return v_shop;
end;
$$;

grant execute on function join_existing_shop() to authenticated;
