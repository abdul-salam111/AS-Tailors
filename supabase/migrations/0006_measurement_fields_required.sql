-- ============================================================================
-- 0006_measurement_fields_required.sql
--
-- 0005's seed insert never set `is_required` explicitly, so every
-- measurement_template_fields row took the column's table-level default
-- (`true`) — making all 25 Shalwar Kameez fields and all 11 Shirt fields
-- mandatory, including style dropdowns (collar type, button type, hem
-- type...), option checkboxes (embroidery, double patti...) and pocket
-- counters. Product correction: a tailor should only be forced to enter
-- the handful of core body measurements needed to cut fabric; everything
-- else (style choices, counts, optional extras) is fill-in-when-relevant.
--
-- Flips every field to optional, then re-marks just the core numeric
-- measurements as required, by field_key (field_key is reused as the
-- same semantic field across templates, e.g. 'chest'/'shoulder' appear in
-- both the Qameez and Shirt templates and are basic in both):
--   Qameez:   length, shoulder, sleeve, chest, collar_measurement
--   Shalwar:  shalwar_length, shalwar_width
--   Shirt:    shirt_length, collar, chest, shoulder, sleeve_length
--
-- UNCONFIRMED like the rest of 0005's seed data — this basic/optional
-- split is a reasonable default, not a tailor sign-off; adjust the
-- field_key list below if the real required set differs.
--
-- Apply after 0001-0005. See supabase/README.md.
-- ============================================================================

update measurement_template_fields set is_required = false;

update measurement_template_fields set is_required = true
where field_key in (
  'length', 'shoulder', 'sleeve', 'chest', 'collar_measurement',
  'shalwar_length', 'shalwar_width',
  'shirt_length', 'collar', 'sleeve_length'
);
