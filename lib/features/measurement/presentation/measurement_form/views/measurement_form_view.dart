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
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Iconsax.camera),
              title: Text(context.l10n.takePhoto),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _pickImage(context, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.image),
              title: Text(context.l10n.chooseFromGallery),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _pickImage(context, ImageSource.gallery);
              },
            ),
          ],
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
            appBar: CustomAppBar(title: context.l10n.takeMeasurement),
            body: ApiStatusBuilder<List<GarmentCategoryEntity>>(
              status: state.categoriesStatus,
              data: state.categories,
              isEmpty: (categories) => categories.isEmpty,
              builder: (context, categories) => Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(context.l10n.selectGarmentCategory, style: context.titleMedium),
                    heightBox(12),
                    _buildCategoryRow(context, state, categories),
                    heightBox(24),
                    if (state.templateStatus == ApiStatus.LOADING) const LoadingIndicator(),
                    if (state.templateStatus == ApiStatus.SUCCESS && state.template != null) ...[
                      if (state.sectionKeys.length > 1) ...[
                        _buildSectionRow(context, state),
                        heightBox(16),
                      ],
                      ..._buildFields(context, state),
                      heightBox(8),
                      _buildUnitToggle(context, state),
                      heightBox(16),
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
                      heightBox(16),
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

  Widget _buildCategoryRow(
    BuildContext context,
    MeasurementFormState state,
    List<GarmentCategoryEntity> categories,
  ) {
    return Row(
      children: categories
          .map(
            (category) => Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: state.selectedCategoryId == category.id
                    ? CustomButton(
                        label: _displayLabel(context, en: category.name, ur: category.nameUr),
                        onPressed: () => context.read<MeasurementFormBloc>().add(
                          CategorySelectedEvent(category.id),
                        ),
                      )
                    : CustomButton.outline(
                        label: _displayLabel(context, en: category.name, ur: category.nameUr),
                        onPressed: () => context.read<MeasurementFormBloc>().add(
                          CategorySelectedEvent(category.id),
                        ),
                      ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildSectionRow(BuildContext context, MeasurementFormState state) {
    final fieldsBySection = <String, MeasurementTemplateFieldEntity>{};
    for (final field in state.template!.fields) {
      if (field.sectionKey != null) fieldsBySection.putIfAbsent(field.sectionKey!, () => field);
    }
    return Row(
      children: state.sectionKeys.map((key) {
        final field = fieldsBySection[key]!;
        final label = _displayLabel(
          context,
          en: field.sectionLabelEn ?? key,
          ur: field.sectionLabelUr,
        );
        final selected = state.selectedSectionKey == key;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: selected
                ? CustomButton(
                    label: label,
                    onPressed: () =>
                        context.read<MeasurementFormBloc>().add(SectionSelectedEvent(key)),
                  )
                : CustomButton.outline(
                    label: label,
                    onPressed: () =>
                        context.read<MeasurementFormBloc>().add(SectionSelectedEvent(key)),
                  ),
          ),
        );
      }).toList(),
    );
  }

  List<Widget> _buildFields(BuildContext context, MeasurementFormState state) {
    final fields = [...state.template!.fields]
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    final visibleFields = fields.where(
      (f) => f.sectionKey == null || f.sectionKey == state.selectedSectionKey,
    );

    return visibleFields
        .map(
          (field) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildField(context, state, field),
          ),
        )
        .toList();
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
          hintText: '${context.l10n.measurementValueHint} (${state.unit})',
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
        return DropdownButtonFormField<String>(
          initialValue: selectedOptionId,
          decoration: InputDecoration(
            labelText: field.isRequired
                ? '${_fieldLabel(context, field)} *'
                : _fieldLabel(context, field),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
        );
      case MeasurementFieldInputType.checkbox:
        final checked = (state.fieldValues[field.id]?.numericValue ?? 0) == 1;
        return CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: Text(_fieldLabel(context, field)),
          value: checked,
          onChanged: (value) => context.read<MeasurementFormBloc>().add(
            FieldValueChangedEvent(
              field.id,
              MeasurementFieldValue(numericValue: (value ?? false) ? 1 : 0),
            ),
          ),
        );
    }
  }

  Widget _buildUnitToggle(BuildContext context, MeasurementFormState state) {
    return Row(
      children: [
        Text(context.l10n.unit, style: context.bodyMedium),
        widthBox(16),
        ChoiceChip(
          label: Text(context.l10n.inches),
          selected: state.unit == 'in',
          onSelected: (_) => context.read<MeasurementFormBloc>().add(UnitChangedEvent('in')),
        ),
        widthBox(8),
        ChoiceChip(
          label: Text(context.l10n.centimeters),
          selected: state.unit == 'cm',
          onSelected: (_) => context.read<MeasurementFormBloc>().add(UnitChangedEvent('cm')),
        ),
      ],
    );
  }

  Widget _buildImagesSection(BuildContext context, MeasurementFormState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.referencePhotos, style: context.bodyMedium),
        heightBox(8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...state.imagePaths.map(
              (path) => Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(File(path), width: 72, height: 72, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: -8,
                    right: -8,
                    child: IconButton(
                      icon: Icon(Iconsax.close_circle, color: context.error, size: 20),
                      onPressed: () =>
                          context.read<MeasurementFormBloc>().add(ImageRemovedEvent(path)),
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () => _showImageSourceSheet(context),
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  border: Border.all(color: context.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Iconsax.add, color: context.textSecondary),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Small stepper for `counter`-type fields (e.g. pocket count) — plain
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
        Text(label, style: context.bodyMedium),
        Row(
          children: [
            IconButton(
              icon: const Icon(Iconsax.minus_cirlce),
              onPressed: value > 0 ? () => onChanged(value - 1) : null,
            ),
            Text('$value', style: context.titleMedium),
            IconButton(icon: const Icon(Iconsax.add_circle), onPressed: () => onChanged(value + 1)),
          ],
        ),
      ],
    );
  }
}
