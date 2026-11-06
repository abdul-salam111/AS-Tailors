import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sticky_headers/sticky_headers.dart';
import '../../../../../core/constants/app_enums.dart';
import '../../../../../core/di/di_exports.dart';
import '../../../../../core/services/measurement_unit_cubit.dart';
import '../../../../../core/shared/shared_exports.dart';
import '../../../../../core/theme/theme_exports.dart';
import '../../../../../core/utils/utils_exports.dart';
import '../../../../../core/widgets/widgets_exports.dart';
import '../../../../../routes/routes_exports.dart';
import '../../../domain/entities/garment_category_entity.dart';
import '../../../domain/entities/measurement_field_value.dart';
import '../../../domain/entities/measurement_template_field_entity.dart';
import '../../widgets/measurement_field_widgets.dart';
import '../blocs/measurement_form_bloc.dart';
import '../blocs/measurement_form_event.dart';
import '../blocs/measurement_form_state.dart';

/// Take-measurement screen (SRS §23.5) for one customer: pick a garment
/// category, optionally pick a sub-section (e.g. a Shalwar Kameez
/// template's "Qameez" vs "Shalwar" halves), fill in that section's
/// fields — numbers, counters, dropdowns and checkboxes, per field
/// `inputType` — optionally attach reference photos, and save. Reached
/// either straight after creating a new customer, or later from that
/// customer's detail screen.
class MeasurementFormView extends StatelessWidget {
  final String customerId;

  const MeasurementFormView({super.key, required this.customerId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<MeasurementFormBloc>()
        ..add(MeasurementFormInitialized(customerId, context.read<MeasurementUnitCubit>().state)),
      child: const _MeasurementFormBody(),
    );
  }
}

class _MeasurementFormBody extends StatefulWidget {
  const _MeasurementFormBody();

  @override
  State<_MeasurementFormBody> createState() => _MeasurementFormBodyState();
}

class _MeasurementFormBodyState extends State<_MeasurementFormBody> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _numberControllers = {};
  final _notesController = TextEditingController();
  final _picker = ImagePicker();

  TextEditingController _numberControllerFor(String fieldId) =>
      _numberControllers.putIfAbsent(fieldId, () => TextEditingController());

  @override
  void dispose() {
    for (final controller in _numberControllers.values) {
      controller.dispose();
    }
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked != null && context.mounted) {
      context.read<MeasurementFormBloc>().add(ImageAddedEvent(picked.path));
    }
  }

  Future<void> _showImageSourceSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              heightBox(18),
              _SheetOption(
                icon: Iconsax.camera,
                label: context.l10n.takePhoto,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _pickImage(context, ImageSource.camera);
                },
              ),
              heightBox(10),
              _SheetOption(
                icon: Iconsax.image,
                label: context.l10n.chooseFromGallery,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _pickImage(context, ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _displayLabel(BuildContext context, {required String en, String? ur}) =>
      context.isUrdu ? (ur ?? en) : en;

  String _fieldLabel(BuildContext context, MeasurementTemplateFieldEntity field) =>
      _displayLabel(context, en: field.labelEn, ur: field.labelUr);

  /// Label plus a required-marker, used as the field's hint text instead
  /// of a separate label row above it (same reasoning as
  /// `CustomTextFormField` — see its own changelog entry).
  String _fieldHint(BuildContext context, MeasurementTemplateFieldEntity field) =>
      '${_fieldLabel(context, field)}${field.isRequired ? ' *' : ''}';

  String? _validateNumberField(
    BuildContext context,
    MeasurementTemplateFieldEntity field,
    String? value,
  ) {
    final label = _fieldLabel(context, field);
    if (field.isRequired) {
      final requiredError = Validator.validateRequired(value, fieldName: label);
      if (requiredError != null) return requiredError;
    }
    if (value != null && value.isNotEmpty) {
      return Validator.validateMinValue(value, 0.1, fieldName: label);
    }
    return null;
  }

  String? _validateDropdownField(
    BuildContext context,
    MeasurementTemplateFieldEntity field,
    String? selectedOptionId,
  ) {
    if (!field.isRequired) return null;
    return Validator.validateRequired(selectedOptionId, fieldName: _fieldLabel(context, field));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MeasurementFormBloc, MeasurementFormState>(
      listenWhen: (previous, current) => previous.submitStatus != current.submitStatus,
      listener: (context, state) {
        if (state.submitStatus == ApiStatus.SUCCESS) {
          AppToastsUtils.showSuccessTop(context, context.l10n.measurementSavedSuccessfully);
          context.pop();
        }
        if (state.submitStatus == ApiStatus.FAILURE && state.failure != null) {
          AppToastsUtils.showErrorTop(context, AppFailureMapper.map(state.failure!).message);
        }
      },
      builder: (context, state) {
        return UnfocusWrapper(
          child: Scaffold(
            backgroundColor: context.background,
            appBar: CustomAppBar(title: context.l10n.takeMeasurement),
            body: ApiStatusBuilder<List<GarmentCategoryEntity>>(
              status: state.categoriesStatus,
              data: state.categories,
              failure: state.failure,
              onRetry: () => context.read<MeasurementFormBloc>().add(
                MeasurementFormInitialized(state.customerId!, state.unit),
              ),
              isEmpty: (categories) => categories.isEmpty,
              builder: (context, categories) => Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _sectionLabel(context, context.l10n.selectGarmentCategory),
                    heightBox(12),
                    _buildCategoryPicker(context, state, categories),
                    if (state.templateStatus == ApiStatus.LOADING) ...[
                      heightBox(40),
                      const Center(child: LoadingIndicator()),
                    ],
                    if (state.templateStatus == ApiStatus.SUCCESS && state.template != null) ...[
                      heightBox(28),
                      _sectionLabel(context, context.l10n.measurements),
                      heightBox(16),
                      _buildFieldsArea(context, state),
                      heightBox(24),
                      CustomTextFormField(
                        label: context.l10n.notes,
                        prefixIcon: Iconsax.note,
                        maxLines: 3,
                        // 16px to match _FieldBox's card radius above it
                        // (fill/border color now match by default).
                        borderRadius: 16,
                        controller: _notesController,
                        onChanged: (value) => context.read<MeasurementFormBloc>().add(
                          MeasurementNotesChangedEvent(value),
                        ),
                      ),
                      heightBox(28),
                      _sectionLabel(context, context.l10n.referencePhotos),
                      heightBox(12),
                      _buildImagesSection(context, state),
                      heightBox(32),
                      CustomButton(
                        label: context.l10n.saveMeasurement,
                        isLoading: state.submitStatus == ApiStatus.LOADING,
                        radius: 10,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            context.read<MeasurementFormBloc>().add(MeasurementFormSubmitted());
                          }
                        },
                      ),
                      heightBox(12),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _sectionLabel(BuildContext context, String title) =>
      Text(title, style: context.titleSmall.copyWith(fontWeight: FontWeight.bold));

  Widget _buildCategoryPicker(
    BuildContext context,
    MeasurementFormState state,
    List<GarmentCategoryEntity> categories,
  ) {
    final ordered = categories.sortedByDisplayPriority();
    return Row(
      children: [
        for (var i = 0; i < ordered.length; i++) ...[
          Expanded(
            child: PillHeader(
              icon: Iconsax.ruler,
              label: _displayLabel(context, en: ordered[i].name, ur: ordered[i].nameUr),
              selected: state.selectedCategoryId == ordered[i].id,
              onTap: () =>
                  context.read<MeasurementFormBloc>().add(CategorySelectedEvent(ordered[i].id)),
            ),
          ),
          if (i != ordered.length - 1) widthBox(10),
        ],
      ],
    );
  }

  /// Renders every section of the active template in one continuous
  /// scroll — e.g. Shalwar Kameez's "Qameez" fields followed by its
  /// "Shalwar" fields — instead of hiding all but one behind a tab
  /// switcher, so a tailor fills the whole template in one pass and
  /// `_formKey.currentState!.validate()` genuinely checks every required
  /// field, not just the currently-visible section's. Within each
  /// section, number/counter fields ("measurements") render before
  /// dropdown/checkbox fields ("features"), matching the reference
  /// layout's own grouping. Each section/features group is wrapped in a
  /// `StickyHeader` so its pill header pins to the top of the screen
  /// while that group's fields scroll beneath it, handing off to the
  /// next group's header once it scrolls up to take over — e.g. "Qameez"
  /// stays pinned until "Features" arrives, which stays pinned until
  /// "Shalwar" arrives. Fields sit in a responsive 2-column wrap of
  /// individually-bordered boxes (not one shared card) so each field
  /// reads as its own compact input, auto-sized to its own content.
  Widget _buildFieldsArea(BuildContext context, MeasurementFormState state) {
    final fields = [...state.template!.fields]
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    final sectionOrder = <String?>[];
    final bySection = <String?, List<MeasurementTemplateFieldEntity>>{};
    for (final field in fields) {
      bySection
          .putIfAbsent(field.sectionKey, () {
            sectionOrder.add(field.sectionKey);
            return [];
          })
          .add(field);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 12) / 2;

        Widget fieldsWrap(List<MeasurementTemplateFieldEntity> group) => Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [for (final field in group) _buildFieldBox(context, state, field, itemWidth)],
        );

        Widget paddedContent(List<MeasurementTemplateFieldEntity> group) =>
            Padding(padding: const EdgeInsets.only(top: 12, bottom: 20), child: fieldsWrap(group));

        // Opaque backing behind a pinned pill header — `_PillHeader`'s own
        // fill is a translucent tint, so without this the fields
        // scrolling underneath would show faintly through it once stuck.
        Widget stickyHeader(Widget pill) => Container(
          color: context.background,
          padding: const EdgeInsets.only(bottom: 6),
          child: pill,
        );

        final units = <Widget>[];

        for (final sectionKey in sectionOrder) {
          final sectionFields = bySection[sectionKey]!;

          final measurementFields = sectionFields
              .where(
                (f) =>
                    f.inputType == MeasurementFieldInputType.number ||
                    f.inputType == MeasurementFieldInputType.counter,
              )
              .toList();
          final featureFields = sectionFields
              .where(
                (f) =>
                    f.inputType == MeasurementFieldInputType.dropdown ||
                    f.inputType == MeasurementFieldInputType.checkbox,
              )
              .toList();

          if (measurementFields.isNotEmpty) {
            if (sectionKey == null) {
              units.add(paddedContent(measurementFields));
            } else {
              final header = sectionFields.first;
              units.add(
                StickyHeader(
                  header: stickyHeader(
                    PillHeader(
                      icon: Iconsax.ruler,
                      label: _displayLabel(
                        context,
                        en: header.sectionLabelEn ?? sectionKey,
                        ur: header.sectionLabelUr,
                      ),
                    ),
                  ),
                  content: paddedContent(measurementFields),
                ),
              );
            }
          }

          if (featureFields.isNotEmpty) {
            units.add(
              StickyHeader(
                header: stickyHeader(
                  PillHeader(icon: Iconsax.tick_square, label: context.l10n.measurementFeatures),
                ),
                content: paddedContent(featureFields),
              ),
            );
          }
        }

        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: units);
      },
    );
  }

  Widget _buildFieldBox(
    BuildContext context,
    MeasurementFormState state,
    MeasurementTemplateFieldEntity field,
    double width,
  ) {
    switch (field.inputType) {
      case MeasurementFieldInputType.number:
        return FieldBox(
          width: width,
          child: TextFormField(
            controller: _numberControllerFor(field.id),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: context.bodyMedium.copyWith(fontWeight: FontWeight.w700),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              // Explicitly unfilled — the app-wide InputDecorationTheme
              // defaults to `filled: true, fillColor: grey50`, which
              // painted a small grey strip inside this field's own white
              // _FieldBox card (the bug this comment is here to prevent
              // regressing).
              filled: false,
              hintText: _fieldHint(context, field),
              hintStyle: context.bodyMedium.copyWith(color: context.textDisabled),
              suffixText: state.unit,
              suffixStyle: context.labelSmall.copyWith(color: context.textSecondary),
              errorStyle: context.labelSmall.copyWith(color: context.error),
            ),
            validator: (value) => _validateNumberField(context, field, value),
            onChanged: (value) {
              final parsed = double.tryParse(value);
              context.read<MeasurementFormBloc>().add(
                FieldValueChangedEvent(
                  field.id,
                  MeasurementFieldValue(numericValue: parsed, unit: state.unit),
                ),
              );
            },
          ),
        );
      case MeasurementFieldInputType.counter:
        final current = state.fieldValues[field.id]?.numericValue?.toInt() ?? 0;
        return FieldBox(
          width: width,
          label: _fieldLabel(context, field),
          child: Row(
            children: [
              StepperButton(
                icon: Iconsax.minus,
                onTap: current > 0
                    ? () => context.read<MeasurementFormBloc>().add(
                        FieldValueChangedEvent(
                          field.id,
                          MeasurementFieldValue(numericValue: (current - 1).toDouble()),
                        ),
                      )
                    : null,
              ),
              Expanded(
                child: Text(
                  '$current',
                  textAlign: TextAlign.center,
                  style: context.titleMedium.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              StepperButton(
                icon: Iconsax.add,
                onTap: () => context.read<MeasurementFormBloc>().add(
                  FieldValueChangedEvent(
                    field.id,
                    MeasurementFieldValue(numericValue: (current + 1).toDouble()),
                  ),
                ),
              ),
            ],
          ),
        );
      case MeasurementFieldInputType.dropdown:
        final selectedOptionId = state.fieldValues[field.id]?.selectedOptionId;
        return FieldBox(
          width: width,
          child: DropdownButtonFormField<String>(
            initialValue: selectedOptionId,
            isExpanded: true,
            isDense: true,
            icon: Icon(Iconsax.arrow_down, size: 14, color: context.grey500),
            style: context.bodyMedium.copyWith(
              color: context.textPrimary,
              fontWeight: FontWeight.w700,
            ),
            hint: Text(
              _fieldHint(context, field),
              style: context.bodyMedium.copyWith(color: context.textDisabled),
            ),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              filled: false,
            ),
            items: field.options
                .map(
                  (o) => DropdownMenuItem(
                    value: o.id,
                    child: Text(_displayLabel(context, en: o.labelEn, ur: o.labelUr)),
                  ),
                )
                .toList(),
            validator: (value) => _validateDropdownField(context, field, value),
            onChanged: (value) => context.read<MeasurementFormBloc>().add(
              FieldValueChangedEvent(field.id, MeasurementFieldValue(selectedOptionId: value)),
            ),
          ),
        );
      case MeasurementFieldInputType.checkbox:
        final checked = (state.fieldValues[field.id]?.numericValue ?? 0) == 1;
        return CheckboxFieldBox(
          width: width,
          label: _fieldLabel(context, field),
          checked: checked,
          onChanged: (value) => context.read<MeasurementFormBloc>().add(
            FieldValueChangedEvent(field.id, MeasurementFieldValue(numericValue: value ? 1 : 0)),
          ),
        );
    }
  }

  Widget _buildImagesSection(BuildContext context, MeasurementFormState state) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        ...state.imagePaths.map(
          (path) => _ImageThumb(
            path: path,
            onRemove: () => context.read<MeasurementFormBloc>().add(ImageRemovedEvent(path)),
          ),
        ),
        _AddImageTile(onTap: () => _showImageSourceSheet(context)),
      ],
    );
  }
}

class _ImageThumb extends StatelessWidget {
  final String path;
  final VoidCallback onRemove;

  const _ImageThumb({required this.path, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76,
      height: 76,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.file(File(path), width: 76, height: 76, fit: BoxFit.cover),
          ),
          PositionedDirectional(
            top: 4,
            end: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: AppColors.black.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(Iconsax.close_circle, color: AppColors.white, size: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddImageTile extends StatelessWidget {
  final VoidCallback onTap;

  const _AddImageTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tile = Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: context.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.primary.withValues(alpha: 0.3), width: 1.2),
      ),
      alignment: Alignment.center,
      child: Icon(Iconsax.add, color: context.primary, size: 22),
    );
    return tile.onTap(onTap);
  }
}

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SheetOption({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final row = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: context.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: context.primary, size: 18),
          ),
          widthBox(12),
          Expanded(
            child: Text(label, style: context.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
          ),
          Icon(Iconsax.arrow_right_3, size: 16, color: context.textSecondary),
        ],
      ),
    );
    return row.onTap(onTap);
  }
}
