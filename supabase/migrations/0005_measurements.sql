-- ============================================================================
-- 0005_measurements.sql
--
-- Measurement management for AS Tailors (SRS v1.3 FR-004, §9.4, §23.5):
-- garment categories, versioned measurement templates/fields, versioned
-- per-customer measurement profiles + their numeric values, and optional
-- reference photos stored in Supabase Storage.
--
-- Deviation from the SRS's literal schema, documented here rather than
-- silently: `measurement_profiles.shop_id` is denormalized (the SRS's table
-- list omits it, deriving shop ownership only through customer_id). This
-- repo's established convention (CLAUDE.md §1a item 8, see `customers` in
-- 0002) is every feature table carries its own `shop_id` so RLS and
-- client-side scoping stay a single-column check with no join — kept
-- consistent here instead of being the one feature table that's different.
-- `measurement_values`/`measurement_reference_images` do NOT get their own
-- shop_id — they're never queried without their parent profile already
-- loaded, so an EXISTS join in their RLS policy is enough.
--
-- Apply via the Supabase SQL Editor after 0001-0004, or `supabase db push`
-- once the CLI is linked. See supabase/README.md.
-- ============================================================================

-- ─── garment_categories ──────────────────────────────────────────────────
-- Global reference data (not shop-scoped) — every shop in this single-shop
-- deployment sees the same catalogue. Seeded below; no client write policy.
create table garment_categories (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  name_ur text,
  slug text not null unique,
  description text,
  is_active boolean not null default true
);

-- ─── measurement_templates ───────────────────────────────────────────────
-- One active template per category today; `version` exists so a future
-- re-definition of a category's fields can be introduced without mutating
-- the template historical profiles were measured against.
create table measurement_templates (
  id uuid primary key default gen_random_uuid(),
  category_id uuid not null references garment_categories (id),
  name text not null,
  version integer not null default 1,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create index idx_measurement_templates_category on measurement_templates (category_id);

-- ─── measurement_template_fields ─────────────────────────────────────────
-- field_key is the stable machine identifier (SRS §23.5: "must have a
-- stable machine key independent of translated labels") — label_en/label_ur
-- can change without breaking historical measurement_values rows, which
-- reference field_id, not the label.
--
-- A template's fields can be a plain flat list (section_key null throughout
-- — the `shirt` template) or grouped into named sub-sections the form
-- renders as a secondary picker, e.g. the `shalwar_kameez` template's
-- "Qameez" vs "Shalwar" halves (real Pakistani-tailor UX, not an SRS
-- concept — see the seed data comment below).
create table measurement_template_fields (
  id uuid primary key default gen_random_uuid(),
  template_id uuid not null references measurement_templates (id) on delete cascade,
  field_key text not null,
  label_en text not null,
  label_ur text,
  section_key text,
  section_label_en text,
  section_label_ur text,
  display_order integer not null,
  is_required boolean not null default true,
  input_type text not null default 'number'
    check (input_type in ('number', 'counter', 'dropdown', 'checkbox')),
  default_unit text not null default 'in',
  unique (template_id, field_key)
);

create index idx_measurement_template_fields_template on measurement_template_fields (template_id);

-- ─── measurement_template_field_options ──────────────────────────────────
-- Only populated for `input_type = 'dropdown'` fields (e.g. collar type,
-- stitching type) — one row per selectable option.
create table measurement_template_field_options (
  id uuid primary key default gen_random_uuid(),
  field_id uuid not null references measurement_template_fields (id) on delete cascade,
  option_key text not null,
  label_en text not null,
  label_ur text,
  display_order integer not null,
  unique (field_id, option_key)
);

create index idx_measurement_template_field_options_field
  on measurement_template_field_options (field_id);

-- ─── measurement_profiles ─────────────────────────────────────────────────
-- A named, versioned snapshot of a customer's measurements for one garment
-- category. Append-only: editing creates a new version row rather than
-- mutating an existing one (SRS §23.5 "template changes are versioned; old
-- profiles retain their original field keys/values" — the same immutability
-- principle this app already applies to order/price snapshots elsewhere).
create table measurement_profiles (
  id uuid primary key default gen_random_uuid(),
  shop_id uuid not null references shops (id) on delete cascade,
  customer_id uuid not null references customers (id) on delete cascade,
  template_id uuid not null references measurement_templates (id),
  name text,
  version integer not null,
  unit text not null default 'in',
  measured_at timestamptz not null default now(),
  notes text,
  created_by uuid references profiles (id),
  created_at timestamptz not null default now()
);

create index idx_measurement_profiles_customer on measurement_profiles (customer_id);
create index idx_measurement_profiles_shop on measurement_profiles (shop_id);
create index idx_measurement_profiles_customer_template on measurement_profiles (customer_id, template_id);

-- ─── measurement_values ───────────────────────────────────────────────────
-- `value`/`unit` hold a 'number'/'counter' entry or a 'checkbox' flag
-- (stored as 0/1, `unit` null); `selected_option_id` holds a 'dropdown'
-- pick instead. Exactly one of the two must be present — which one is
-- determined by the field's `input_type`, not re-validated here beyond the
-- not-both-null check, since that'd require a cross-table lookup in a
-- check constraint.
create table measurement_values (
  id uuid primary key default gen_random_uuid(),
  measurement_profile_id uuid not null references measurement_profiles (id) on delete cascade,
  field_id uuid not null references measurement_template_fields (id),
  value numeric,
  unit text,
  selected_option_id uuid references measurement_template_field_options (id),
  unique (measurement_profile_id, field_id),
  check (value is not null or selected_option_id is not null)
);

create index idx_measurement_values_profile on measurement_values (measurement_profile_id);

-- ─── measurement_reference_images ────────────────────────────────────────
-- storage_path points into the private `measurement-references` Storage
-- bucket created below — resolve to a usable URL via createSignedUrl() on
-- read, never a public URL.
create table measurement_reference_images (
  id uuid primary key default gen_random_uuid(),
  measurement_profile_id uuid not null references measurement_profiles (id) on delete cascade,
  storage_path text not null,
  uploaded_by uuid references profiles (id),
  created_at timestamptz not null default now()
);

create index idx_measurement_reference_images_profile on measurement_reference_images (measurement_profile_id);

-- ─── RLS ─────────────────────────────────────────────────────────────────
alter table garment_categories enable row level security;
alter table measurement_templates enable row level security;
alter table measurement_template_fields enable row level security;
alter table measurement_template_field_options enable row level security;
alter table measurement_profiles enable row level security;
alter table measurement_values enable row level security;
alter table measurement_reference_images enable row level security;

-- Reference-data tables: any authenticated shop member can read; no client
-- insert/update/delete policy — seeded by migration only, like an enum.
create policy garment_categories_select on garment_categories for select
  using (auth.role() = 'authenticated');

create policy measurement_templates_select on measurement_templates for select
  using (auth.role() = 'authenticated');

create policy measurement_template_fields_select on measurement_template_fields for select
  using (auth.role() = 'authenticated');

create policy measurement_template_field_options_select on measurement_template_field_options for select
  using (auth.role() = 'authenticated');

-- measurement_profiles: shop-scoped like customers. No update policy —
-- profiles are append-only (see create_measurement_profile() below).
create policy measurement_profiles_select on measurement_profiles for select
  using (is_shop_member(shop_id));

create policy measurement_profiles_insert on measurement_profiles for insert
  with check (is_shop_member(shop_id));

-- measurement_values / measurement_reference_images: scoped via their
-- parent profile's shop_id through an EXISTS join (no denormalized shop_id
-- needed — never queried without the parent profile already loaded).
create policy measurement_values_select on measurement_values for select
  using (
    exists (
      select 1 from measurement_profiles p
      where p.id = measurement_values.measurement_profile_id and is_shop_member(p.shop_id)
    )
  );

create policy measurement_values_insert on measurement_values for insert
  with check (
    exists (
      select 1 from measurement_profiles p
      where p.id = measurement_values.measurement_profile_id and is_shop_member(p.shop_id)
    )
  );

create policy measurement_reference_images_select on measurement_reference_images for select
  using (
    exists (
      select 1 from measurement_profiles p
      where p.id = measurement_reference_images.measurement_profile_id and is_shop_member(p.shop_id)
    )
  );

create policy measurement_reference_images_insert on measurement_reference_images for insert
  with check (
    exists (
      select 1 from measurement_profiles p
      where p.id = measurement_reference_images.measurement_profile_id and is_shop_member(p.shop_id)
    )
  );

-- ─── create_measurement_profile: atomic profile + values write ──────────
-- SRS §10.3 names this function explicitly ("Create a new version and
-- persist structured measurement values"). Mirrors bootstrap_shop()'s
-- validate-then-insert style (0001_identity_and_shops.sql). Version number
-- is computed server-side as max(version)+1 scoped to (customer_id,
-- template_id) — each garment category has its own independent version
-- sequence per customer, so a customer's Shalwar Kameez history and Shirt
-- history never collide.
create or replace function create_measurement_profile(
  p_shop_id uuid,
  p_customer_id uuid,
  p_template_id uuid,
  p_name text,
  p_unit text,
  p_notes text,
  -- Array of {"field_id": uuid, "value": numeric|null, "unit": text|null,
  -- "selected_option_id": uuid|null} — one object per field. 'number'/
  -- 'counter'/'checkbox' fields set value (+unit for 'number' only);
  -- 'dropdown' fields set selected_option_id instead. Built client-side,
  -- see MeasurementFormBloc.
  p_values jsonb
)
returns measurement_profiles
language plpgsql
security definer set search_path = public
as $$
declare
  v_profile measurement_profiles;
  v_next_version integer;
  v_item jsonb;
begin
  if not is_shop_member(p_shop_id) then
    raise exception 'Not a member of this shop';
  end if;

  select coalesce(max(version), 0) + 1 into v_next_version
  from measurement_profiles
  where customer_id = p_customer_id and template_id = p_template_id;

  insert into measurement_profiles (shop_id, customer_id, template_id, name, version, unit, notes, created_by)
  values (p_shop_id, p_customer_id, p_template_id, p_name, v_next_version, p_unit, p_notes, auth.uid())
  returning * into v_profile;

  for v_item in select * from jsonb_array_elements(p_values) loop
    insert into measurement_values (measurement_profile_id, field_id, value, unit, selected_option_id)
    values (
      v_profile.id,
      (v_item ->> 'field_id')::uuid,
      (v_item ->> 'value')::numeric,
      v_item ->> 'unit',
      (v_item ->> 'selected_option_id')::uuid
    );
  end loop;

  return v_profile;
end;
$$;

-- ─── Storage: reference-photo bucket ────────────────────────────────────
-- Private bucket (not public) — files are only reachable via a signed URL
-- generated on read. Path convention: {shop_id}/{profile_id}/{uuid}.jpg.
insert into storage.buckets (id, name, public, file_size_limit)
values ('measurement-references', 'measurement-references', false, 52428800)
on conflict (id) do nothing;

create policy measurement_references_select on storage.objects for select
  using (
    bucket_id = 'measurement-references'
    and is_shop_member((storage.foldername(name))[1]::uuid)
  );

create policy measurement_references_insert on storage.objects for insert
  with check (
    bucket_id = 'measurement-references'
    and is_shop_member((storage.foldername(name))[1]::uuid)
  );

-- ─── Grants ──────────────────────────────────────────────────────────────
grant select on garment_categories, measurement_templates, measurement_template_fields,
  measurement_template_field_options to authenticated;
grant select, insert on measurement_profiles, measurement_values, measurement_reference_images to authenticated;
grant execute on function create_measurement_profile(uuid, uuid, uuid, text, text, text, jsonb) to authenticated;

-- ─── Seed data: Shalwar Kameez and Shirt categories/templates/fields ─────
-- Field list and display order per the SRS v1.3 §9.4 draft table. The SRS
-- itself flags this list as pending tailor sign-off (§28 open items) — it's
-- the best available starting point, not a final confirmed spec. Adjust
-- label_en/display_order/is_required here in a follow-up migration once
-- confirmed with the tailor; don't hand-edit seeded rows outside migrations
-- (see supabase/README.md).
insert into garment_categories (name, name_ur, slug, description) values
  ('Shalwar Kameez', 'شلوار قمیض', 'shalwar_kameez', 'Traditional shalwar kameez ensemble'),
  ('Shirt', 'شرٹ', 'shirt', 'Western-style formal/casual shirt');

insert into measurement_templates (category_id, name, version)
select id, 'Shalwar Kameez Measurements', 1 from garment_categories where slug = 'shalwar_kameez';

insert into measurement_templates (category_id, name, version)
select id, 'Shirt Measurements', 1 from garment_categories where slug = 'shirt';

-- Shalwar Kameez fields are transcribed from a reference Pakistani
-- tailoring app's own "Measurement" step (two sub-sections — Qameez,
-- Shalwar — toggled like the category picker above), not the plainer SRS
-- §9.4 draft list. Real Pakistani-tailor usage: "Tera" (shoulder), "Gala
-- Naap"/"Gala Qasam" (collar measurement/type), "Kaff"/"Kaff Qasam"
-- (cuff/cuff type), "Paincha" (shalwar bottom opening), "Daman" (hem).
-- Flagged as UNCONFIRMED pending tailor sign-off, same as the rest of this
-- seed data (see note above) — doubly so for: "jeb_qasam" (pocket type)
-- dropdown options, which weren't legible in the source reference and are
-- placeholders; and "front_pocket_count", which may actually be two
-- distinct fields (count + style) collapsed into one here for lack of a
-- confident reading.
insert into measurement_template_fields
  (template_id, field_key, label_en, label_ur, section_key, section_label_en, section_label_ur,
   display_order, input_type, default_unit)
select t.id, f.field_key, f.label_en, f.label_ur, f.section_key, f.section_label_en, f.section_label_ur,
  f.display_order, f.input_type, f.default_unit
from measurement_templates t
join garment_categories c on c.id = t.category_id
cross join (values
  -- Qameez section
  ('length', 'Length', 'لمبائی', 'qameez', 'Qameez', 'قمیض', 1, 'number', 'in'),
  ('shoulder', 'Shoulder (Tera)', 'تیرا', 'qameez', 'Qameez', 'قمیض', 2, 'number', 'in'),
  ('sleeve', 'Sleeve', 'بازو', 'qameez', 'Qameez', 'قمیض', 3, 'number', 'in'),
  ('armhole', 'Armhole', 'بغل', 'qameez', 'Qameez', 'قمیض', 4, 'number', 'in'),
  ('chest_width', 'Chest Width', 'چوڑائی', 'qameez', 'Qameez', 'قمیض', 5, 'number', 'in'),
  ('chest', 'Chest', 'سینہ', 'qameez', 'Qameez', 'قمیض', 6, 'number', 'in'),
  ('front_pocket_count', 'Front Pocket (count)', 'سامنی جیب', 'qameez', 'Qameez', 'قمیض', 7, 'counter', 'in'),
  ('side_pocket_count', 'Side Pocket (count)', 'سائڈ جیب', 'qameez', 'Qameez', 'قمیض', 8, 'counter', 'in'),
  ('slit', 'Slit', 'چاک', 'qameez', 'Qameez', 'قمیض', 9, 'number', 'in'),
  ('sherwani_collar', 'Sherwani Collar', 'شیروانی کالر', 'qameez', 'Qameez', 'قمیض', 10, 'checkbox', 'in'),
  ('collar_measurement', 'Collar Measurement (Gala)', 'گلا ناپ', 'qameez', 'Qameez', 'قمیض', 11, 'number', 'in'),
  ('collar_type', 'Collar Type', 'گلا قسم', 'qameez', 'Qameez', 'قمیض', 12, 'dropdown', 'in'),
  ('cuff', 'Cuff', 'کف', 'qameez', 'Qameez', 'قمیض', 13, 'number', 'in'),
  ('cuff_type', 'Cuff Type', 'کف قسم', 'qameez', 'Qameez', 'قمیض', 14, 'dropdown', 'in'),
  -- Shalwar section
  ('shalwar_type', 'Shalwar Type', 'شلوار', 'shalwar', 'Shalwar', 'شلوار', 15, 'dropdown', 'in'),
  ('pocket_type', 'Pocket Type', 'جیب قسم', 'shalwar', 'Shalwar', 'شلوار', 16, 'dropdown', 'in'),
  ('shalwar_length', 'Length', 'لمبائی', 'shalwar', 'Shalwar', 'شلوار', 17, 'number', 'in'),
  ('paincha', 'Bottom Opening (Paincha)', 'پائنچہ', 'shalwar', 'Shalwar', 'شلوار', 18, 'number', 'in'),
  ('shalwar_width', 'Shalwar Width', 'شلوار چوڑائی', 'shalwar', 'Shalwar', 'شلوار', 19, 'number', 'in'),
  ('button_type', 'Button Type', 'بٹن', 'shalwar', 'Shalwar', 'شلوار', 20, 'dropdown', 'in'),
  ('hem_type', 'Hem Type (Daman)', 'دامن', 'shalwar', 'Shalwar', 'شلوار', 21, 'dropdown', 'in'),
  ('stitch_type', 'Stitching Type', 'سلائی', 'shalwar', 'Shalwar', 'شلوار', 22, 'dropdown', 'in'),
  ('double_patti', 'Double Patti', 'ڈبل پٹی', 'shalwar', 'Shalwar', 'شلوار', 23, 'checkbox', 'in'),
  ('embroidery', 'Embroidery (Karhai)', 'کڑھائی', 'shalwar', 'Shalwar', 'شلوار', 24, 'checkbox', 'in'),
  ('slit_placket_button', 'Slit Placket Button', 'چاک پٹی بٹن', 'shalwar', 'Shalwar', 'شلوار', 25, 'checkbox', 'in')
) as f(field_key, label_en, label_ur, section_key, section_label_en, section_label_ur, display_order,
  input_type, default_unit)
where c.slug = 'shalwar_kameez';

-- Dropdown options for the Shalwar Kameez fields above. option_key is the
-- stable machine key; label_ur is the exact wording read from the
-- reference app where legible.
insert into measurement_template_field_options (field_id, option_key, label_en, label_ur, display_order)
select f.id, o.option_key, o.label_en, o.label_ur, o.display_order
from measurement_template_fields f
join measurement_templates t on t.id = f.template_id
join garment_categories c on c.id = t.category_id
join (values
  ('collar_type', 'collar', 'Collar', 'کالر', 1),
  ('collar_type', 'bein', 'Bein', 'بین', 2),
  ('collar_type', 'baf_bein', 'Baf Bein', 'باف بین', 3),
  ('collar_type', 'double_collar', 'Double Collar', 'ڈبل کالر', 4),
  ('collar_type', 'fancy', 'Fancy', 'فینسی', 5),
  ('collar_type', 'maghzi_collar', 'Maghzi Collar', 'مغزی کالر', 6),
  ('cuff_type', 'round', 'Round', 'گول', 1),
  ('cuff_type', 'square', 'Square', 'چورس', 2),
  ('cuff_type', 'round_sleeve', 'Round Sleeve', 'گول بازو', 3),
  ('cuff_type', 'bein_patti', 'Bein Patti Cuff', 'بین پٹی کف', 4),
  ('shalwar_type', 'plain', 'Plain', 'سادہ', 1),
  ('shalwar_type', 'trouser', 'Trouser', 'ٹراؤزر', 2),
  ('shalwar_type', 'kinara_wali', 'Kinara Wali', 'کندے والی', 3),
  ('shalwar_type', 'capri', 'Capri', 'کیپری', 4),
  ('shalwar_type', 'pajama', 'Pajama', 'پاجامہ', 5),
  -- Placeholder options — not legible in the source reference, verify
  -- with the tailor before relying on these.
  ('pocket_type', 'plain', 'Plain', 'سادہ', 1),
  ('pocket_type', 'zip', 'Zip', 'زپ والی', 2),
  ('pocket_type', 'none', 'No Pocket', 'بغیر جیب', 3),
  ('button_type', 'plain', 'Plain', 'سادہ', 1),
  ('button_type', 'silky', 'Silky', 'ریشمی', 2),
  ('hem_type', 'round_hem', 'Round Hem', 'گول دامن', 1),
  ('hem_type', 'square_hem', 'Square Hem', 'چورس دامن', 2),
  ('stitch_type', 'single', 'Single Stitch', 'سنگل سلائی', 1),
  ('stitch_type', 'double', 'Double Stitch', 'ڈبل سلائی', 2),
  ('stitch_type', 'triple', 'Triple Stitch', 'ٹرپل سلائی', 3)
) as o(field_key, option_key, label_en, label_ur, display_order)
  on o.field_key = f.field_key
where c.slug = 'shalwar_kameez';

insert into measurement_template_fields (template_id, field_key, label_en, label_ur, display_order)
select t.id, f.field_key, f.label_en, f.label_ur, f.display_order
from measurement_templates t
join garment_categories c on c.id = t.category_id
cross join (values
  ('shirt_length', 'Shirt Length', 'شرٹ کی لمبائی', 1),
  ('collar', 'Collar', 'کالر', 2),
  ('chest', 'Chest', 'سینہ', 3),
  ('waist', 'Waist', 'کمر', 4),
  ('shoulder', 'Shoulder', 'کندھا', 5),
  ('sleeve_length', 'Sleeve Length', 'آستین کی لمبائی', 6),
  ('sleeve_opening', 'Sleeve Opening', 'آستین کا منہ', 7),
  ('cuff', 'Cuff', 'کف', 8),
  ('armhole', 'Armhole', 'بغل', 9),
  ('back_length', 'Back Length', 'پیٹھ کی لمبائی', 10),
  ('hip', 'Hip', 'کولہا', 11)
) as f(field_key, label_en, label_ur, display_order)
where c.slug = 'shirt';
