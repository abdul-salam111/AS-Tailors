-- ============================================================================
-- 0001_identity_and_shops.sql
--
-- Identity, shop, membership and audit foundation for AS Tailors.
-- Mirrors SRS v1.3 §9-§11 (profiles / shops / shop_members / audit_logs +
-- RLS). Deliberately scoped to what every future feature depends on —
-- customers/measurements/orders/payments/etc. land in their own later
-- migrations once that feature is actually being built.
--
-- Apply via the Supabase SQL Editor (paste this whole file), or with the
-- Supabase CLI once linked: `supabase db push`. See supabase/README.md.
-- ============================================================================

-- ─── Extensions ──────────────────────────────────────────────────────────
create extension if not exists pgcrypto;

-- ─── Enums ───────────────────────────────────────────────────────────────
-- Lower-case values on purpose — the Flutter-side ShopRole enum matches
-- these 1:1 so no string-conversion layer is needed on either side.
create type shop_role as enum ('owner', 'admin', 'tailor', 'staff');

-- ─── Reusable trigger: keep updated_at current ──────────────────────────
create or replace function set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- ─── profiles ────────────────────────────────────────────────────────────
-- One row per auth.users row, created automatically by handle_new_user().
create table profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  full_name text not null default '',
  phone text,
  email text,
  avatar_url text,
  preferred_language text not null default 'en',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger profiles_set_updated_at
  before update on profiles
  for each row execute function set_updated_at();

-- Auto-create a profile whenever a new auth user is created. SECURITY
-- DEFINER so it can write to public.profiles despite running in the
-- context of the auth schema's own trigger.
create or replace function handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, email, full_name)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data ->> 'full_name', '')
  );
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function handle_new_user();

-- ─── shops ───────────────────────────────────────────────────────────────
create table shops (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references profiles (id),
  name text not null,
  phone text,
  whatsapp text,
  address text,
  logo_url text,
  currency text not null default 'PKR',
  timezone text not null default 'Asia/Karachi',
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger shops_set_updated_at
  before update on shops
  for each row execute function set_updated_at();

-- ─── shop_members ────────────────────────────────────────────────────────
create table shop_members (
  id uuid primary key default gen_random_uuid(),
  shop_id uuid not null references shops (id) on delete cascade,
  user_id uuid not null references profiles (id) on delete cascade,
  role shop_role not null,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  unique (shop_id, user_id)
);

-- ─── audit_logs ──────────────────────────────────────────────────────────
create table audit_logs (
  id uuid primary key default gen_random_uuid(),
  actor_id uuid references profiles (id),
  action text not null,
  entity_type text not null,
  entity_id uuid,
  old_values jsonb,
  new_values jsonb,
  created_at timestamptz not null default now()
);

create index idx_shop_members_user on shop_members (user_id);
create index idx_shop_members_shop on shop_members (shop_id);
create index idx_audit_logs_entity on audit_logs (entity_type, entity_id);

-- ─── RLS helper functions ────────────────────────────────────────────────
-- Reusable building blocks so future feature-table policies (customers,
-- orders, ...) don't each re-derive the same "is this caller a member of
-- this shop" subquery. STABLE + SECURITY DEFINER keeps them cheap and
-- usable inside RLS policies.

create or replace function is_shop_member(p_shop_id uuid, p_roles shop_role[] default null)
returns boolean
language sql
stable
security definer set search_path = public
as $$
  select exists (
    select 1 from shop_members m
    where m.shop_id = p_shop_id
      and m.user_id = auth.uid()
      and m.is_active
      and (p_roles is null or m.role = any(p_roles))
  );
$$;

-- For a future feature's RLS policy: `shop_id in (select my_shop_ids())`.
create or replace function my_shop_ids()
returns setof uuid
language sql
stable
security definer set search_path = public
as $$
  select shop_id from shop_members
  where user_id = auth.uid() and is_active;
$$;

-- ─── RLS ─────────────────────────────────────────────────────────────────
alter table profiles enable row level security;
alter table shops enable row level security;
alter table shop_members enable row level security;
alter table audit_logs enable row level security;

-- profiles: your own row, or any profile that shares a shop with you
-- (so the app can show a staff directory / "assigned to" names).
create policy profiles_select on profiles for select
  using (
    id = auth.uid()
    or exists (
      select 1 from shop_members m1
      join shop_members m2 on m2.shop_id = m1.shop_id
      where m1.user_id = auth.uid() and m2.user_id = profiles.id
    )
  );

create policy profiles_update_own on profiles for update
  using (id = auth.uid())
  with check (id = auth.uid());

-- shops: members can read their shop; only the owner can update it.
-- No insert/delete policy for normal roles on purpose — shop creation only
-- happens through bootstrap_shop() below.
create policy shops_select on shops for select
  using (is_shop_member(id));

create policy shops_update_owner on shops for update
  using (owner_id = auth.uid())
  with check (owner_id = auth.uid());

-- shop_members: members can see their shop's roster; only owner/admin
-- manage membership (promote/deactivate staff, etc.).
create policy shop_members_select on shop_members for select
  using (is_shop_member(shop_id));

create policy shop_members_write_owner_admin on shop_members for all
  using (is_shop_member(shop_id, array['owner', 'admin']::shop_role[]))
  with check (is_shop_member(shop_id, array['owner', 'admin']::shop_role[]));

-- audit_logs: no direct client write policy — only SECURITY DEFINER
-- functions (e.g. bootstrap_shop) insert here. Owner/admin can read.
create policy audit_logs_select_owner_admin on audit_logs for select
  using (
    exists (
      select 1 from shop_members m
      where m.user_id = auth.uid()
        and m.role in ('owner', 'admin')
        and m.is_active
    )
  );

-- ─── bootstrap_shop: controlled first-owner setup ───────────────────────
-- SRS §3: "the first owner account must be provisioned through a
-- controlled setup process." This is that process: an authenticated user
-- with no existing shop membership calls this once to create the shop and
-- become its owner. Refuses if a shop already exists — this product is a
-- single-shop deployment (SRS §1.4) — or if the caller already belongs to
-- one. SECURITY DEFINER so it can insert into shops/shop_members despite
-- neither table having a client-facing insert policy.
create or replace function bootstrap_shop(
  p_name text,
  p_phone text default null,
  p_currency text default 'PKR',
  p_timezone text default 'Asia/Karachi'
)
returns shops
language plpgsql
security definer set search_path = public
as $$
declare
  v_shop shops;
begin
  if auth.uid() is null then
    raise exception 'Must be authenticated to create a shop';
  end if;

  if exists (select 1 from shops) then
    raise exception 'A shop already exists for this deployment. Ask the owner for an invite instead.';
  end if;

  if exists (select 1 from shop_members where user_id = auth.uid()) then
    raise exception 'This account already belongs to a shop';
  end if;

  insert into shops (owner_id, name, phone, currency, timezone)
  values (auth.uid(), p_name, p_phone, p_currency, p_timezone)
  returning * into v_shop;

  insert into shop_members (shop_id, user_id, role)
  values (v_shop.id, auth.uid(), 'owner');

  insert into audit_logs (actor_id, action, entity_type, entity_id, new_values)
  values (auth.uid(), 'shop.bootstrap', 'shops', v_shop.id, to_jsonb(v_shop));

  return v_shop;
end;
$$;

-- ─── Grants ──────────────────────────────────────────────────────────────
-- Phase 1 has no customer-facing access (SRS §1.2) — nothing is granted to
-- `anon`. Authenticated users get base table privileges; RLS above is what
-- actually scopes which rows they can touch.
grant usage on schema public to authenticated;
grant select, insert, update, delete on profiles, shops, shop_members, audit_logs to authenticated;
grant execute on function is_shop_member(uuid, shop_role[]) to authenticated;
grant execute on function my_shop_ids() to authenticated;
grant execute on function bootstrap_shop(text, text, text, text) to authenticated;
