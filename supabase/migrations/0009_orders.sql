-- ============================================================================
-- 0009_orders.sql
--
-- Order management (SRS orders/order_items): a shop-scoped order for one
-- customer, made up of one or more garment line items. Each item can
-- optionally link to one of the customer's existing measurement profiles
-- (features/measurement) — when it does, that profile's current values
-- are snapshotted into the item at creation time (measurements_snapshot),
-- so a later edit to the live measurement profile never changes a
-- historical order (same immutability principle CLAUDE.md §1a already
-- applies to price/measurement snapshots elsewhere).
--
-- Pricing is manual per item (no price list yet); there is no payment
-- capture here — Payments stays a separate future feature. `total_amount`
-- is always server-recalculated inside create_order(), never trusted from
-- the client (CLAUDE.md §1a: "totals/balances are server-recalculated,
-- never client-submitted").
--
-- Apply via `supabase db push` once linked, after 0001-0008. See
-- supabase/README.md.
-- ============================================================================

-- ─── orders ────────────────────────────────────────────────────────────────
create table orders (
  id uuid primary key default gen_random_uuid(),
  shop_id uuid not null references shops (id) on delete cascade,
  customer_id uuid not null references customers (id) on delete cascade,
  -- Per-shop sequential number (computed in create_order(), not a DB
  -- sequence object) — human-friendly, e.g. "Order #14", distinct from
  -- the uuid primary key.
  order_number integer not null,
  status text not null default 'pending'
    check (status in ('pending', 'in_progress', 'ready', 'delivered', 'cancelled')),
  due_date date,
  notes text,
  total_amount numeric(12,2) not null default 0,
  created_by uuid references profiles (id),
  created_at timestamptz not null default now(),
  unique (shop_id, order_number)
);

create index idx_orders_shop on orders (shop_id);
create index idx_orders_customer on orders (customer_id);

-- ─── order_items ─────────────────────────────────────────────────────────
create table order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references orders (id) on delete cascade,
  category_id uuid not null references garment_categories (id),
  measurement_profile_id uuid references measurement_profiles (id),
  quantity integer not null default 1 check (quantity > 0),
  unit_price numeric(12,2) not null check (unit_price >= 0),
  line_total numeric(12,2) not null check (line_total >= 0),
  -- Immutable copy of the linked profile's measurement_values at the
  -- moment this item was created (null when no profile was linked) — see
  -- create_order() below. Never re-read from measurement_values after
  -- insert.
  measurements_snapshot jsonb,
  notes text,
  display_order integer not null default 0
);

create index idx_order_items_order on order_items (order_id);
create index idx_order_items_category on order_items (category_id);

-- ─── RLS ─────────────────────────────────────────────────────────────────
alter table orders enable row level security;
alter table order_items enable row level security;

create policy orders_select on orders for select
  using (is_shop_member(shop_id));

-- Direct insert policy kept for consistency with measurement_profiles
-- (0005) even though the app only writes through create_order() below —
-- that RPC is security definer so it doesn't depend on this policy, but
-- every other shop-scoped table in this schema has one.
create policy orders_insert on orders for insert
  with check (is_shop_member(shop_id));

create policy order_items_select on order_items for select
  using (
    exists (
      select 1 from orders o where o.id = order_items.order_id and is_shop_member(o.shop_id)
    )
  );

create policy order_items_insert on order_items for insert
  with check (
    exists (
      select 1 from orders o where o.id = order_items.order_id and is_shop_member(o.shop_id)
    )
  );

-- ─── create_order: atomic order + line-items write ───────────────────────
-- Mirrors create_measurement_profile()'s validate-then-insert-in-a-loop
-- shape (0005). order_number is computed server-side as
-- max(order_number)+1 scoped to shop_id. Each item's line_total is
-- computed here (quantity * unit_price), never trusted from the client,
-- and summed into the order's total_amount.
create or replace function create_order(
  p_shop_id uuid,
  p_customer_id uuid,
  p_due_date date,
  p_notes text,
  -- Array of {"category_id": uuid, "measurement_profile_id": uuid|null,
  -- "quantity": int, "unit_price": numeric, "notes": text|null} — one
  -- object per garment. Built client-side, see AddOrderBloc.
  p_items jsonb
)
returns orders
language plpgsql
security definer set search_path = public
as $$
declare
  v_order orders;
  v_next_number integer;
  v_item jsonb;
  v_profile_id uuid;
  v_line_total numeric(12,2);
  v_total numeric(12,2) := 0;
  v_snapshot jsonb;
begin
  if not is_shop_member(p_shop_id) then
    raise exception 'Not a member of this shop';
  end if;

  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'An order needs at least one item';
  end if;

  select coalesce(max(order_number), 0) + 1 into v_next_number
  from orders
  where shop_id = p_shop_id;

  insert into orders (shop_id, customer_id, order_number, due_date, notes, created_by)
  values (p_shop_id, p_customer_id, v_next_number, p_due_date, p_notes, auth.uid())
  returning * into v_order;

  for v_item in select * from jsonb_array_elements(p_items) loop
    v_line_total := (v_item ->> 'quantity')::integer * (v_item ->> 'unit_price')::numeric;
    v_total := v_total + v_line_total;
    v_profile_id := (v_item ->> 'measurement_profile_id')::uuid;
    v_snapshot := null;

    if v_profile_id is not null then
      select jsonb_agg(jsonb_build_object(
        'field_key', f.field_key,
        'label_en', f.label_en,
        'label_ur', f.label_ur,
        'value', mv.value,
        'unit', mv.unit,
        'selected_option_label_en', o.label_en,
        'selected_option_label_ur', o.label_ur
      ))
      into v_snapshot
      from measurement_values mv
      join measurement_template_fields f on f.id = mv.field_id
      left join measurement_template_field_options o on o.id = mv.selected_option_id
      where mv.measurement_profile_id = v_profile_id;
    end if;

    insert into order_items (
      order_id, category_id, measurement_profile_id, quantity, unit_price, line_total,
      measurements_snapshot, notes, display_order
    ) values (
      v_order.id,
      (v_item ->> 'category_id')::uuid,
      v_profile_id,
      (v_item ->> 'quantity')::integer,
      (v_item ->> 'unit_price')::numeric,
      v_line_total,
      v_snapshot,
      v_item ->> 'notes',
      (select coalesce(max(display_order), -1) + 1 from order_items where order_id = v_order.id)
    );
  end loop;

  update orders set total_amount = v_total where id = v_order.id
  returning * into v_order;

  return v_order;
end;
$$;

-- ─── Grants ──────────────────────────────────────────────────────────────
grant select, insert on orders, order_items to authenticated;
grant execute on function create_order(uuid, uuid, date, text, jsonb) to authenticated;
