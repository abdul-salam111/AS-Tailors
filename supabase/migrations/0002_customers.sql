-- ============================================================================
-- 0002_customers.sql
--
-- Customer directory for AS Tailors. Mirrors SRS v1.3 §9.3 (customers table)
-- and §23.4 (Customer Management): a shop-scoped, searchable customer
-- record that supports walk-ins without a Supabase Auth account, phone-based
-- duplicate detection, and archive-not-delete for records tied to business
-- history.
--
-- Apply via the Supabase SQL Editor after 0001_identity_and_shops.sql, or
-- `supabase db push` once the CLI is linked. See supabase/README.md.
-- ============================================================================

-- ─── customers ───────────────────────────────────────────────────────────
create table customers (
  id uuid primary key default gen_random_uuid(),
  shop_id uuid not null references shops (id) on delete cascade,
  profile_id uuid references profiles (id),
  full_name text not null,
  phone text,
  normalized_phone text,
  whatsapp text,
  email text,
  address text,
  notes text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger customers_set_updated_at
  before update on customers
  for each row execute function set_updated_at();

-- ─── Phone normalization ─────────────────────────────────────────────────
-- Strips everything but digits, then maps a local 11-digit "0XXXXXXXXXX"
-- Pakistani number onto its "92XXXXXXXXXX" form so the same physical number
-- always indexes/matches the same way regardless of how it was typed
-- (spaces, dashes, +92, leading 0, ...). Deliberately not validated beyond
-- that — this is for duplicate detection and search, not phone verification.
create or replace function normalize_phone(p_phone text)
returns text
language plpgsql
immutable
as $$
declare
  v_digits text;
begin
  if p_phone is null or btrim(p_phone) = '' then
    return null;
  end if;

  v_digits := regexp_replace(p_phone, '\D', '', 'g');

  if v_digits = '' then
    return null;
  end if;

  if length(v_digits) = 11 and left(v_digits, 1) = '0' then
    v_digits := '92' || substring(v_digits from 2);
  end if;

  return v_digits;
end;
$$;

create or replace function customers_set_normalized_phone()
returns trigger
language plpgsql
as $$
begin
  new.normalized_phone = normalize_phone(new.phone);
  return new;
end;
$$;

create trigger customers_normalize_phone
  before insert or update of phone on customers
  for each row execute function customers_set_normalized_phone();

-- ─── Indexes ─────────────────────────────────────────────────────────────
-- Not a unique index: SRS §23.4 requires a duplicate *warning* the user can
-- knowingly proceed past, not a hard database-level rejection.
create index idx_customers_shop on customers (shop_id);
create index idx_customers_shop_normalized_phone on customers (shop_id, normalized_phone);
create index idx_customers_shop_full_name on customers (shop_id, full_name);

-- ─── RLS ─────────────────────────────────────────────────────────────────
-- Every active member of a shop (owner/admin/tailor/staff alike) can read,
-- register and edit that shop's customers — SRS §3's role matrix restricts
-- *financial* and *administrative* data per-role, not the customer
-- directory itself (staff explicitly "Customer registration" is a listed
-- capability). No delete policy anywhere: archiving (is_active = false via
-- update) is the only supported removal path, per §23.4's
-- "do not hard-delete" rule.
alter table customers enable row level security;

create policy customers_select on customers for select
  using (is_shop_member(shop_id));

create policy customers_insert on customers for insert
  with check (is_shop_member(shop_id));

create policy customers_update on customers for update
  using (is_shop_member(shop_id))
  with check (is_shop_member(shop_id));

-- ─── Grants ──────────────────────────────────────────────────────────────
grant select, insert, update on customers to authenticated;
grant execute on function normalize_phone(text) to authenticated;
