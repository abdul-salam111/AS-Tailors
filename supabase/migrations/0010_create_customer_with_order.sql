-- ============================================================================
-- 0010_create_customer_with_order.sql
--
-- Atomic "new customer" wizard (Flutter: AddCustomerWizardView, 4 steps —
-- customer info, measurement, order, summary): nothing is written until
-- the final Confirm step, at which point this single function creates the
-- customer, their first measurement profile (one garment category), and
-- their first order (one line item for that same category) all in one
-- transaction. If anything fails partway, the whole thing rolls back —
-- unlike the standalone customer/measurement/order flows (which each
-- persist their own step immediately via create_measurement_profile() /
-- create_order()), this wizard deliberately holds everything in memory
-- client-side so an abandoned wizard leaves no partial records.
--
-- Mirrors create_measurement_profile() (0005) and create_order() (0009)'s
-- own validate-then-insert shape; see those for the per-entity version of
-- this same logic. Apply via `supabase db push` after 0001-0009.
-- ============================================================================

create or replace function create_customer_with_order(
  p_shop_id uuid,
  -- Step 1: customer
  p_full_name text,
  p_whatsapp text,
  p_address text,
  p_customer_notes text,
  -- Step 2: measurement (one category/template only — see AddOrderView's
  -- own docs for why this wizard doesn't support multiple garments yet)
  p_template_id uuid,
  p_measurement_name text,
  p_unit text,
  p_measurement_notes text,
  -- Array of {"field_id": uuid, "value": numeric|null, "unit": text|null,
  -- "selected_option_id": uuid|null} — same shape create_measurement_profile() takes.
  p_measurement_values jsonb,
  -- Step 3: order (single line item for the category above)
  p_quantity integer,
  p_unit_price numeric,
  p_due_date date,
  p_order_notes text,
  p_item_notes text
)
returns jsonb
language plpgsql
security definer set search_path = public
as $$
declare
  v_customer customers;
  v_profile measurement_profiles;
  v_order orders;
  v_category_id uuid;
  v_next_order_number integer;
  v_line_total numeric(12,2);
  v_item jsonb;
  v_snapshot jsonb;
begin
  if not is_shop_member(p_shop_id) then
    raise exception 'Not a member of this shop';
  end if;

  select category_id into v_category_id from measurement_templates where id = p_template_id;
  if v_category_id is null then
    raise exception 'Unknown measurement template';
  end if;

  insert into customers (shop_id, full_name, whatsapp, address, notes)
  values (p_shop_id, p_full_name, p_whatsapp, p_address, p_customer_notes)
  returning * into v_customer;

  insert into measurement_profiles (
    shop_id, customer_id, template_id, name, version, unit, notes, created_by
  ) values (
    p_shop_id, v_customer.id, p_template_id, p_measurement_name, 1, p_unit, p_measurement_notes,
    auth.uid()
  )
  returning * into v_profile;

  for v_item in select * from jsonb_array_elements(p_measurement_values) loop
    insert into measurement_values (measurement_profile_id, field_id, value, unit, selected_option_id)
    values (
      v_profile.id,
      (v_item ->> 'field_id')::uuid,
      (v_item ->> 'value')::numeric,
      v_item ->> 'unit',
      (v_item ->> 'selected_option_id')::uuid
    );
  end loop;

  select coalesce(max(order_number), 0) + 1 into v_next_order_number
  from orders
  where shop_id = p_shop_id;

  insert into orders (shop_id, customer_id, order_number, due_date, notes, created_by)
  values (p_shop_id, v_customer.id, v_next_order_number, p_due_date, p_order_notes, auth.uid())
  returning * into v_order;

  v_line_total := p_quantity * p_unit_price;

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
  where mv.measurement_profile_id = v_profile.id;

  insert into order_items (
    order_id, category_id, measurement_profile_id, quantity, unit_price, line_total,
    measurements_snapshot, notes, display_order
  ) values (
    v_order.id, v_category_id, v_profile.id, p_quantity, p_unit_price, v_line_total,
    v_snapshot, p_item_notes, 0
  );

  update orders set total_amount = v_line_total where id = v_order.id
  returning * into v_order;

  return jsonb_build_object(
    'customer', to_jsonb(v_customer),
    'measurement_profile', to_jsonb(v_profile),
    'order', to_jsonb(v_order)
  );
end;
$$;

grant execute on function create_customer_with_order(
  uuid, text, text, text, text, uuid, text, text, text, jsonb, integer, numeric, date, text, text
) to authenticated;
