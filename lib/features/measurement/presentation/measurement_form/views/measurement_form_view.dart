import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/constants/app_enums.dart';
import '../../../../../core/di/di_exports.dart';
import '../../../../../core/shared/shared_exports.dart';
import '../../../../../core/theme/theme_exports.dart';
import '../../../../../core/utils/utils_exports.dart';
import '../../../../../core/widgets/widgets_exports.dart';
import '../../../../../routes/routes_exports.dart';
import '../../../domain/entities/garment_category_entity.dart';
import '../../../domain/entities/measurement_field_value.dart';
import '../../../domain/entities/measurement_template_field_entity.dart';
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
      create: (_) => sl<MeasurementFormBloc>()..add(MeasurementFormInitialized(customerId)),
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
                MeasurementFormInitialized(state.customerId!),
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
                      Row(
                        children: [
                          Expanded(child: _sectionLabel(context, context.l10n.measurements)),
                          _SegmentedTabs(
                            compact: true,
                            items: [
                              (key: 'in', label: context.l10n.inches),
                              (key: 'cm', label: context.l10n.centimeters),
                            ],
                            selectedKey: state.unit,
                            onSelected: (unit) =>
                                context.read<MeasurementFormBloc>().add(UnitChangedEvent(unit)),
                          ),
                        ],
                      ),
                      if (state.sectionKeys.length > 1) ...[
                        heightBox(14),
                        _buildSectionTabs(context, state),
                      ],
                      heightBox(14),
                      _buildFieldsCard(context, state),
                      heightBox(28),
                      CustomTextFormField(
                        label: context.l10n.notes,
                        hintText: context.l10n.enterNotes,
                        prefixIcon: Iconsax.note,
                        maxLines: 3,
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
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: categories
          .map(
            (category) => _PickerCard(
              selected: state.selectedCategoryId == category.id,
              label: _displayLabel(context, en: category.name, ur: category.nameUr),
              icon: Iconsax.ruler,
              onTap: () =>
                  context.read<MeasurementFormBloc>().add(CategorySelectedEvent(category.id)),
            ),
          )
          .toList(),
    );
  }

  Widget _buildSectionTabs(BuildContext context, MeasurementFormState state) {
    final fieldsBySection = <String, MeasurementTemplateFieldEntity>{};
    for (final field in state.template!.fields) {
      if (field.sectionKey != null) fieldsBySection.putIfAbsent(field.sectionKey!, () => field);
    }
    return _SegmentedTabs(
      items: state.sectionKeys.map((key) {
        final field = fieldsBySection[key]!;
        return (
          key: key,
          label: _displayLabel(context, en: field.sectionLabelEn ?? key, ur: field.sectionLabelUr),
        );
      }).toList(),
      selectedKey: state.selectedSectionKey,
      onSelected: (key) => context.read<MeasurementFormBloc>().add(SectionSelectedEvent(key)),
    );
  }

  Widget _buildFieldsCard(BuildContext context, MeasurementFormState state) {
    final fields = [...state.template!.fields]
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    final visibleFields = fields
        .where((f) => f.sectionKey == null || f.sectionKey == state.selectedSectionKey)
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: context.surfaceElevated,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.divider),
        boxShadow: [BoxShadow(color: context.shadow, blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          for (var i = 0; i < visibleFields.length; i++) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildField(context, state, visibleFields[i]),
            ),
            if (i != visibleFields.length - 1)
              Divider(height: 1, thickness: 1, color: context.divider),
          ],
        ],
      ),
    );
  }

  Widget _buildField(
    BuildContext context,
    MeasurementFormState state,
    MeasurementTemplateFieldEntity field,
  ) {
    switch (field.inputType) {
      case MeasurementFieldInputType.number:
        return CustomTextFormField(
          label: _fieldLabel(context, field),
          isRequired: field.isRequired,
          hintText: context.l10n.measurementValueHint,
          fillColor: AppColors.transparent,
          borderColor: AppColors.transparent,
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Center(
              widthFactor: 1,
              child: Text(
                state.unit,
                style: context.bodySmall.copyWith(
                  color: context.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          controller: _numberControllerFor(field.id),
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
        );
      case MeasurementFieldInputType.counter:
        final current = state.fieldValues[field.id]?.numericValue?.toInt() ?? 0;
        return _CounterField(
          label: _fieldLabel(context, field),
          value: current,
          onChanged: (next) => context.read<MeasurementFormBloc>().add(
            FieldValueChangedEvent(field.id, MeasurementFieldValue(numericValue: next.toDouble())),
          ),
        );
      case MeasurementFieldInputType.dropdown:
        final selectedOptionId = state.fieldValues[field.id]?.selectedOptionId;
        return _DropdownField(
          label: _fieldLabel(context, field),
          isRequired: field.isRequired,
          value: selectedOptionId,
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
        );
      case MeasurementFieldInputType.checkbox:
        final checked = (state.fieldValues[field.id]?.numericValue ?? 0) == 1;
        return Row(
          children: [
            Expanded(
              child: Text(
                _fieldLabel(context, field),
                style: context.bodyMedium.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            Switch(
              value: checked,
              activeTrackColor: context.primary,
              onChanged: (value) => context.read<MeasurementFormBloc>().add(
                FieldValueChangedEvent(
                  field.id,
                  MeasurementFieldValue(numericValue: value ? 1 : 0),
                ),
              ),
            ),
          ],
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

/// A selectable card for the top-level garment-category picker — larger
/// and more prominent than [_SegmentedTabs] since choosing a category is
/// the primary decision on this screen, not a minor toggle.
class _PickerCard extends StatelessWidget {
  final bool selected;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _PickerCard({
    required this.selected,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: selected ? null : context.surfaceElevated,
        gradient: selected
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.brandTeal, AppColors.brandTealDeep],
              )
            : null,
        borderRadius: BorderRadius.circular(16),
        border: selected ? null : Border.all(color: context.divider),
        boxShadow: [
          BoxShadow(
            color: selected ? AppColors.brandTeal.withValues(alpha: 0.28) : context.shadow,
            blurRadius: selected ? 12 : 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22, color: selected ? AppColors.white : context.primary),
          heightBox(8),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.labelMedium.copyWith(
              color: selected ? AppColors.white : context.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
    return card.onTap(onTap);
  }
}

/// Compact tab bar used for both the sub-section picker (e.g. Qameez vs
/// Shalwar) and the unit toggle — one bordered track, equal-width segments
/// by default, or hugging content when [compact] (used for the 2-item unit
/// toggle so it doesn't stretch across the whole row next to the section
/// title).
class _SegmentedTabs extends StatelessWidget {
  final List<({String key, String label})> items;
  final String? selectedKey;
  final ValueChanged<String> onSelected;
  final bool compact;

  const _SegmentedTabs({
    required this.items,
    required this.selectedKey,
    required this.onSelected,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final segments = items.map((item) => _buildSegment(context, item)).toList();

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.divider),
      ),
      child: Row(
        mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
        children: compact ? segments : segments.map((s) => Expanded(child: s)).toList(),
      ),
    );
  }

  Widget _buildSegment(BuildContext context, ({String key, String label}) item) {
    final selected = item.key == selectedKey;
    final segment = Container(
      decoration: BoxDecoration(
        color: selected ? context.primary : AppColors.transparent,
        borderRadius: BorderRadius.circular(9),
      ),
      padding: EdgeInsets.symmetric(vertical: 9, horizontal: compact ? 16 : 0),
      alignment: Alignment.center,
      child: Text(
        item.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.labelMedium.copyWith(
          color: selected ? AppColors.white : context.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
    return segment.onTap(() => onSelected(item.key));
  }
}

/// Small +/- stepper for `counter`-type fields (e.g. pocket count) — plain
/// widget, not a `FormField`, since counts have no meaningful "required"
/// state (0 is always valid) and so don't participate in `Form` validation.
class _CounterField extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  const _CounterField({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(label, style: context.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
        ),
        Row(
          children: [
            _StepperButton(
              icon: Iconsax.minus,
              onTap: value > 0 ? () => onChanged(value - 1) : null,
            ),
            SizedBox(
              width: 32,
              child: Text(
                '$value',
                textAlign: TextAlign.center,
                style: context.titleMedium.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            _StepperButton(icon: Iconsax.add, onTap: () => onChanged(value + 1)),
          ],
        ),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _StepperButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final button = Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: enabled
            ? context.primary.withValues(alpha: 0.12)
            : context.border.withValues(alpha: 0.5),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 15, color: enabled ? context.primary : context.textDisabled),
    );
    return onTap == null ? button : button.onTap(onTap!);
  }
}

/// Dropdown field styled to match [CustomTextFormField]'s label/border
/// language (same radius, transparent-until-focused border) instead of
/// the stock Material outline look, so it blends into the fields card
/// exactly like its number/counter siblings.
class _DropdownField extends StatelessWidget {
  final String label;
  final bool isRequired;
  final String? value;
  final List<DropdownMenuItem<String>> items;
  final String? Function(String?) validator;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.label,
    required this.isRequired,
    required this.value,
    required this.items,
    required this.validator,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: label,
                style: context.bodySmall.copyWith(color: context.textSecondary),
              ),
              if (isRequired)
                TextSpan(
                  text: ' *',
                  style: context.bodyMedium.copyWith(
                    color: context.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
        heightBox(5),
        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          icon: Icon(Iconsax.arrow_down, size: 16, color: context.grey500),
          style: context.bodySmall.copyWith(color: context.textPrimary),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: AppColors.transparent,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.transparent),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.transparent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: context.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: context.error),
            ),
          ),
          items: items,
          validator: validator,
          onChanged: onChanged,
        ),
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
