-- ============================================================================
-- 0007_measurement_fields_not_required.sql
--
-- Product correction, superseding 0006's basic/optional split: no
-- measurement field is required at all. A tailor can save a profile with
-- any subset of fields filled in — the whole template is fill-in-what's-
-- relevant, not just the style/count/checkbox fields 0006 already
-- relaxed.
--
-- Apply after 0001-0006. See supabase/README.md.
-- ============================================================================

update measurement_template_fields set is_required = false;
