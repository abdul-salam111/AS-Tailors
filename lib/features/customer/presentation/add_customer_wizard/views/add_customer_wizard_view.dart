import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_enums.dart';
import '../../../../../core/di/di_exports.dart';
import '../../../../../core/services/measurement_unit_cubit.dart';
import '../../../../../core/shared/shared_exports.dart';
import '../../../../../core/theme/theme_exports.dart';
import '../../../../../core/utils/utils_exports.dart';
import '../../../../../core/widgets/widgets_exports.dart';
import '../../../../measurement/domain/entities/garment_category_entity.dart';
import '../../../../measurement/domain/entities/measurement_field_value.dart';
import '../../../../measurement/domain/entities/measurement_template_field_entity.dart';
import '../../../../measurement/presentation/widgets/measurement_field_widgets.dart';
import '../blocs/add_customer_wizard_bloc.dart';
import '../blocs/add_customer_wizard_event.dart';
import '../blocs/add_customer_wizard_state.dart';

/// Guided 4-step "new customer" flow — Customer info, Measurement,
/// Order, Summary — replacing the old single-screen quick-add form
/// (CustomerFormView is still used for *editing* an existing customer).
/// Nothing is written to the backend until the Summary step's "Confirm &
/// Create" button, which submits everything in one atomic call (see
/// AddCustomerWizardBloc / CreateCustomerWithOrderUsecase); abandoning the
/// wizard at any earlier step leaves no partial records.
///
/// Scoped to one garment category end-to-end: the category picked in the
/// Measurement step is the same one the Order step places a (single) line
/// item for. A customer who wants multiple different garments measured
/// and ordered on day one still gets this quick path for their first one,
/// then uses the standalone Add Order flow for anything else.
class AddCustomerWizardView extends StatelessWidget {
  const AddCustomerWizardView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<AddCustomerWizardBloc>()
            ..add(WizardInitialized(context.read<MeasurementUnitCubit>().state)),
      child: const _AddCustomerWizardBody(),
    );
  }
}

const _stepCount = 4;

class _AddCustomerWizardBody extends StatefulWidget {
  const _AddCustomerWizardBody();

  @override
  State<_AddCustomerWizardBody> createState() => _AddCustomerWizardBodyState();
}

class _AddCustomerWizardBodyState extends State<_AddCustomerWizardBody>
    with SingleTickerProviderStateMixin {
  final _customerFormKey = GlobalKey<FormState>();
  final _orderFormKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _addressController = TextEditingController();
  final _customerNotesController = TextEditingController();
  final _measurementNotesController = TextEditingController();
  final _unitPriceController = TextEditingController();
  final _orderNotesController = TextEditingController();
  final Map<String, TextEditingController> _numberControllers = {};

  // Drives a short fade + horizontal-slide whenever the step changes
  // (triggered from the BlocConsumer's listener below) — the step bodies
  // themselves stay in an IndexedStack underneath so switching never
  // disposes/rebuilds their TextEditingControllers, only this wrapper
  // animates.
  late final _stepAnimController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
  );
  int _lastStep = 0;
  bool _movingForward = true;

  TextEditingController _numberControllerFor(String fieldId) =>
      _numberControllers.putIfAbsent(fieldId, () => TextEditingController());

  @override
  void initState() {
    super.initState();
    _stepAnimController.value = 1;
  }

  @override
  void dispose() {
    _stepAnimController.dispose();
    _fullNameController.dispose();
    _whatsappController.dispose();
    _addressController.dispose();
    _customerNotesController.dispose();
    _measurementNotesController.dispose();
    _unitPriceController.dispose();
    _orderNotesController.dispose();
    for (final controller in _numberControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String _displayLabel(BuildContext context, {required String en, String? ur}) =>
      context.isUrdu ? (ur ?? en) : en;

  String _fieldLabel(BuildContext context, MeasurementTemplateFieldEntity field) =>
      _displayLabel(context, en: field.labelEn, ur: field.labelUr);

  void _handleNext(BuildContext context, AddCustomerWizardState state) {
    switch (state.currentStep) {
      case 0:
        if (!_customerFormKey.currentState!.validate()) return;
      case 1:
        if (state.selectedCategoryId == null) {
          AppToastsUtils.showInfoTop(context, context.l10n.pleaseSelectGarmentCategoryToContinue);
          return;
        }
      case 2:
        if (!_orderFormKey.currentState!.validate()) return;
    }
    context.read<AddCustomerWizardBloc>().add(WizardNextPressed());
  }

  Future<void> _pickDueDate(BuildContext context, DateTime? current) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null && context.mounted) {
      context.read<AddCustomerWizardBloc>().add(OrderDueDateChanged(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddCustomerWizardBloc, AddCustomerWizardState>(
      listenWhen: (previous, current) =>
          previous.submitStatus != current.submitStatus ||
          previous.currentStep != current.currentStep,
      listener: (context, state) {
        if (state.currentStep != _lastStep) {
          _movingForward = state.currentStep > _lastStep;
          _lastStep = state.currentStep;
          _stepAnimController.forward(from: 0);
        }
        if (state.submitStatus == ApiStatus.SUCCESS && state.result != null) {
          AppToastsUtils.showSuccessTop(context, context.l10n.customerOrderCreatedSuccessfully);
          context.pop(state.result!.customer);
        }
        if (state.submitStatus == ApiStatus.FAILURE && state.failure != null) {
          AppToastsUtils.showErrorTop(context, AppFailureMapper.map(state.failure!).message);
        }
      },
      builder: (context, state) {
        return PopScope(
          canPop: state.currentStep == 0,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) context.read<AddCustomerWizardBloc>().add(WizardBackPressed());
          },
          child: UnfocusWrapper(
            child: Scaffold(
              backgroundColor: context.background,
              appBar: CustomAppBar(
                title: context.l10n.addCustomer,
                leading: IconButton(
                  icon: const Icon(Iconsax.arrow_left),
                  onPressed: () {
                    if (state.currentStep == 0) {
                      context.pop();
                    } else {
                      context.read<AddCustomerWizardBloc>().add(WizardBackPressed());
                    }
                  },
                ),
              ),
              body: Column(
                children: [
                  _WizardStepper(
                    currentStep: state.currentStep,
                    onStepTap: (step) =>
                        context.read<AddCustomerWizardBloc>().add(WizardStepChanged(step)),
                  ),
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _stepAnimController,
                      builder: (context, child) => Opacity(
                        opacity: _stepAnimController.value,
                        child: FractionalTranslation(
                          translation: Offset(
                            (1 - _stepAnimController.value) * (_movingForward ? 0.06 : -0.06),
                            0,
                          ),
                          child: child,
                        ),
                      ),
                      child: IndexedStack(
                        index: state.currentStep,
                        children: [
                          _buildCustomerStep(context),
                          _buildMeasurementStep(context, state),
                          _buildOrderStep(context, state),
                          _buildSummaryStep(context, state),
                        ],
                      ),
                    ),
                  ),
                  _WizardNavBar(
                    currentStep: state.currentStep,
                    isSubmitting: state.submitStatus == ApiStatus.LOADING,
                    onBack: () => context.read<AddCustomerWizardBloc>().add(WizardBackPressed()),
                    onNext: () => _handleNext(context, state),
                    onConfirm: () => context.read<AddCustomerWizardBloc>().add(WizardSubmitted()),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomerStep(BuildContext context) {
    return Form(
      key: _customerFormKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _stepHeading(
            context,
            icon: Iconsax.user,
            title: context.l10n.stepCustomerInfo,
            subtitle: context.l10n.stepCustomerInfoSubtitle,
          ),
          heightBox(20),
          CustomTextFormField(
            label: context.l10n.customerFullName,
            prefixIcon: Iconsax.user,
            controller: _fullNameController,
            validator: (v) =>
                Validator.validateRequired(v, fieldName: context.l10n.customerFullName),
            onChanged: (value) =>
                context.read<AddCustomerWizardBloc>().add(CustomerFullNameChanged(value)),
          ),
          heightBox(16),
          CustomTextFormField(
            label: context.l10n.whatsapp,
            prefixIcon: Iconsax.message,
            keyboardType: TextInputType.phone,
            controller: _whatsappController,
            onChanged: (value) =>
                context.read<AddCustomerWizardBloc>().add(CustomerWhatsappChanged(value)),
          ),
          heightBox(16),
          CustomTextFormField(
            label: context.l10n.address,
            prefixIcon: Iconsax.location,
            maxLines: 2,
            controller: _addressController,
            onChanged: (value) =>
                context.read<AddCustomerWizardBloc>().add(CustomerAddressChanged(value)),
          ),
          heightBox(16),
          CustomTextFormField(
            label: context.l10n.notes,
            prefixIcon: Iconsax.note,
            maxLines: 3,
            controller: _customerNotesController,
            onChanged: (value) =>
                context.read<AddCustomerWizardBloc>().add(CustomerNotesChanged(value)),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementStep(BuildContext context, AddCustomerWizardState state) {
    return ApiStatusBuilder<List<GarmentCategoryEntity>>(
      status: state.categoriesStatus,
      data: state.categories,
      failure: state.failure,
      onRetry: () => context.read<AddCustomerWizardBloc>().add(WizardInitialized(state.unit)),
      isEmpty: (categories) => categories.isEmpty,
      builder: (context, categories) {
        final ordered = categories.sortedByDisplayPriority();
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _stepHeading(
              context,
              icon: Iconsax.ruler,
              title: context.l10n.stepMeasurementInfo,
              subtitle: context.l10n.selectGarmentCategory,
            ),
            heightBox(20),
            Row(
              children: [
                for (var i = 0; i < ordered.length; i++) ...[
                  Expanded(
                    child: PillHeader(
                      icon: Iconsax.ruler,
                      label: _displayLabel(context, en: ordered[i].name, ur: ordered[i].nameUr),
                      selected: state.selectedCategoryId == ordered[i].id,
                      onTap: () => context.read<AddCustomerWizardBloc>().add(
                        WizardCategorySelected(ordered[i].id),
                      ),
                    ),
                  ),
                  if (i != ordered.length - 1) widthBox(10),
                ],
              ],
            ),
            if (state.templateStatus == ApiStatus.LOADING) ...[
              heightBox(40),
              const Center(child: LoadingIndicator()),
            ],
            if (state.templateStatus == ApiStatus.SUCCESS && state.template != null) ...[
              heightBox(24),
              _buildMeasurementFields(context, state),
              heightBox(20),
              CustomTextFormField(
                label: context.l10n.notes,
                prefixIcon: Iconsax.note,
                maxLines: 3,
                borderRadius: 16,
                controller: _measurementNotesController,
                onChanged: (value) =>
                    context.read<AddCustomerWizardBloc>().add(MeasurementNotesChanged(value)),
              ),
            ],
          ],
        );
      },
    );
  }

  /// Flat 2-column field grid, ignoring section grouping/sticky headers
  /// (unlike the full MeasurementFormView) — this step is meant to stay
  /// compact, and every field is optional anyway (no required fields
  /// exist on any template today), so grouping isn't load-bearing here.
  Widget _buildMeasurementFields(BuildContext context, AddCustomerWizardState state) {
    final fields = [...state.template!.fields]
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [for (final field in fields) _buildFieldBox(context, state, field, itemWidth)],
        );
      },
    );
  }

  Widget _buildFieldBox(
    BuildContext context,
    AddCustomerWizardState state,
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
              filled: false,
              hintText: _fieldLabel(context, field),
              hintStyle: context.bodyMedium.copyWith(color: context.textDisabled),
              suffixText: state.unit,
              suffixStyle: context.labelSmall.copyWith(color: context.textSecondary),
            ),
            onChanged: (value) => context.read<AddCustomerWizardBloc>().add(
              WizardFieldValueChanged(
                field.id,
                MeasurementFieldValue(numericValue: double.tryParse(value), unit: state.unit),
              ),
            ),
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
                    ? () => context.read<AddCustomerWizardBloc>().add(
                        WizardFieldValueChanged(
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
                onTap: () => context.read<AddCustomerWizardBloc>().add(
                  WizardFieldValueChanged(
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
              _fieldLabel(context, field),
              style: context.bodyMedium.copyWith(color: context.textDisabled),
            ),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
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
            onChanged: (value) => context.read<AddCustomerWizardBloc>().add(
              WizardFieldValueChanged(field.id, MeasurementFieldValue(selectedOptionId: value)),
            ),
          ),
        );
      case MeasurementFieldInputType.checkbox:
        final checked = (state.fieldValues[field.id]?.numericValue ?? 0) == 1;
        return CheckboxFieldBox(
          width: width,
          label: _fieldLabel(context, field),
          checked: checked,
          onChanged: (value) => context.read<AddCustomerWizardBloc>().add(
            WizardFieldValueChanged(field.id, MeasurementFieldValue(numericValue: value ? 1 : 0)),
          ),
        );
    }
  }

  Widget _buildOrderStep(BuildContext context, AddCustomerWizardState state) {
    final categoryLabel = state.selectedCategoryLabel(context.isUrdu);
    return Form(
      key: _orderFormKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _stepHeading(
            context,
            icon: Iconsax.bag_2,
            title: context.l10n.stepOrderInfo,
            subtitle: categoryLabel ?? '',
          ),
          heightBox(20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.quantity,
                      style: context.labelSmall.copyWith(color: context.textSecondary),
                    ),
                    heightBox(8),
                    Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: context.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: context.border),
                      ),
                      child: Row(
                        children: [
                          StepperButton(
                            icon: Iconsax.minus,
                            onTap: state.quantity > 1
                                ? () => context.read<AddCustomerWizardBloc>().add(
                                    OrderQuantityChanged(state.quantity - 1),
                                  )
                                : null,
                          ),
                          Expanded(
                            child: Text(
                              '${state.quantity}',
                              textAlign: TextAlign.center,
                              style: context.titleMedium.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          StepperButton(
                            icon: Iconsax.add,
                            onTap: () => context.read<AddCustomerWizardBloc>().add(
                              OrderQuantityChanged(state.quantity + 1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              widthBox(16),
              Expanded(
                child: CustomTextFormField(
                  label: context.l10n.unitPrice,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  controller: _unitPriceController,
                  validator: (v) =>
                      Validator.validateMinValue(v, 0.01, fieldName: context.l10n.unitPrice),
                  onChanged: (value) => context.read<AddCustomerWizardBloc>().add(
                    OrderUnitPriceChanged(double.tryParse(value)),
                  ),
                ),
              ),
            ],
          ),
          heightBox(20),
          Text(
            context.l10n.dueDate,
            style: context.labelSmall.copyWith(color: context.textSecondary),
          ),
          heightBox(8),
          _DueDateField(dueDate: state.dueDate, onTap: () => _pickDueDate(context, state.dueDate)),
          heightBox(16),
          CustomTextFormField(
            label: context.l10n.notes,
            prefixIcon: Iconsax.note,
            maxLines: 3,
            controller: _orderNotesController,
            onChanged: (value) =>
                context.read<AddCustomerWizardBloc>().add(OrderNotesChanged(value)),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStep(BuildContext context, AddCustomerWizardState state) {
    final categoryLabel = state.selectedCategoryLabel(context.isUrdu) ?? '';
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _stepHeading(
          context,
          icon: Iconsax.tick_square,
          title: context.l10n.stepSummary,
          subtitle: context.l10n.reviewBeforeConfirming,
        ),
        heightBox(20),
        _SummaryCard(
          icon: Iconsax.user,
          title: context.l10n.stepCustomerInfo,
          rows: [
            (context.l10n.customerFullName, state.fullName),
            if (state.whatsapp.isNotEmpty) (context.l10n.whatsapp, state.whatsapp),
            if (state.address.isNotEmpty) (context.l10n.address, state.address),
          ],
        ),
        heightBox(14),
        _SummaryCard(
          icon: Iconsax.ruler,
          title: context.l10n.stepMeasurementInfo,
          rows: [
            (context.l10n.selectGarmentCategory, categoryLabel),
            (context.l10n.unit, state.unit),
          ],
        ),
        heightBox(14),
        _SummaryCard(
          icon: Iconsax.bag_2,
          title: context.l10n.stepOrderInfo,
          rows: [
            (context.l10n.quantity, '${state.quantity}'),
            (context.l10n.unitPrice, (state.unitPrice ?? 0).asPKR),
            if (state.dueDate != null) (context.l10n.dueDate, state.dueDate!.formattedLong),
          ],
        ),
        heightBox(20),
        _OrderTotalRow(total: state.lineTotal),
      ],
    );
  }

  Widget _stepHeading(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: context.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: context.primary, size: 20),
        ),
        widthBox(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: context.titleSmall.copyWith(fontWeight: FontWeight.bold)),
              if (subtitle.isNotEmpty)
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.bodySmall.copyWith(color: context.textSecondary),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Numbered-circle stepper (1 → 2 → 3 → 4), each circle joined to the next
/// by a connecting line and labelled with that step's name below it — a
/// completed step shows a checkmark and fills solid, the current step is
/// solid with a soft glow and a bold label, an upcoming step is a plain
/// outlined circle. A completed step's circle is tappable to jump back to
/// it directly; nothing lets you jump ahead unvalidated.
class _WizardStepper extends StatelessWidget {
  final int currentStep;
  final ValueChanged<int> onStepTap;
  const _WizardStepper({required this.currentStep, required this.onStepTap});

  @override
  Widget build(BuildContext context) {
    final labels = [
      context.l10n.stepCustomerInfo,
      context.l10n.stepMeasurementInfo,
      context.l10n.stepOrderInfo,
      context.l10n.stepSummary,
    ];

    // Always an Expanded on both sides of the circle, even at the two ends
    // where there's no neighbour to connect to — an invisible (transparent)
    // one there, rather than a zero-width SizedBox. Both sides keep equal
    // flex either way, so the circle sits dead-centre in its column no
    // matter which end it's at, which is what makes the label underneath
    // (centred over that same column) land under the circle instead of
    // drifting toward whichever side had the real connector.
    Widget connector({required bool visible, required bool completed}) => Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        color: !visible ? AppColors.transparent : (completed ? context.primary : context.border),
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < _stepCount; i++)
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      connector(visible: i > 0, completed: i - 1 < currentStep),
                      _StepCircle(
                        number: i + 1,
                        completed: i < currentStep,
                        current: i == currentStep,
                        onTap: i < currentStep ? () => onStepTap(i) : null,
                      ),
                      connector(visible: i < _stepCount - 1, completed: i < currentStep),
                    ],
                  ),
                  heightBox(6),
                  Text(
                    labels[i],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: context.labelSmall.copyWith(
                      color: i == currentStep ? context.primary : context.textSecondary,
                      fontWeight: i == currentStep ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _StepCircle extends StatelessWidget {
  final int number;
  final bool completed;
  final bool current;
  final VoidCallback? onTap;

  const _StepCircle({
    required this.number,
    required this.completed,
    required this.current,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final filled = completed || current;
    final circle = Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? context.primary : context.surfaceElevated,
        border: Border.all(color: filled ? context.primary : context.border, width: 1.5),
        boxShadow: current
            ? [
                BoxShadow(
                  color: context.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: completed
          ? const Icon(Icons.check, size: 16, color: AppColors.white)
          : Text(
              '$number',
              style: context.bodySmall.copyWith(
                color: filled ? AppColors.white : context.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
    return onTap == null ? circle : circle.onTap(onTap!);
  }
}

class _WizardNavBar extends StatelessWidget {
  final int currentStep;
  final bool isSubmitting;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onConfirm;

  const _WizardNavBar({
    required this.currentStep,
    required this.isSubmitting,
    required this.onBack,
    required this.onNext,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final isLastStep = currentStep == _stepCount - 1;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: context.surfaceElevated,
        boxShadow: [BoxShadow(color: context.shadow, blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Row(
        children: [
          if (currentStep > 0) ...[
            Expanded(
              child: CustomButton.outline(label: context.l10n.back, radius: 10, onPressed: onBack),
            ),
            widthBox(12),
          ],
          Expanded(
            flex: currentStep > 0 ? 1 : 2,
            child: CustomButton(
              label: isLastStep ? context.l10n.confirmAndCreate : context.l10n.next,
              isLoading: isLastStep && isSubmitting,
              radius: 10,
              onPressed: isLastStep ? onConfirm : onNext,
            ),
          ),
        ],
      ),
    );
  }
}

class _DueDateField extends StatelessWidget {
  final DateTime? dueDate;
  final VoidCallback onTap;
  const _DueDateField({required this.dueDate, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dueDate = this.dueDate;
    final box = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: context.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.divider),
      ),
      child: Row(
        children: [
          Icon(Iconsax.calendar_1, size: 18, color: context.primary),
          widthBox(10),
          Expanded(
            child: Text(
              dueDate?.formattedLong ?? context.l10n.noDueDateSet,
              style: context.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: dueDate == null ? context.textDisabled : context.textPrimary,
              ),
            ),
          ),
          Icon(Iconsax.arrow_right_3, size: 16, color: context.textSecondary),
        ],
      ),
    );
    return box.onTap(onTap);
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<(String, String)> rows;
  const _SummaryCard({required this.icon, required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: context.primary),
              widthBox(8),
              Text(title, style: context.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          heightBox(10),
          for (final (label, value) in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: context.bodySmall.copyWith(color: context.textSecondary),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      value,
                      textAlign: TextAlign.end,
                      style: context.bodySmall.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _OrderTotalRow extends StatelessWidget {
  final double total;
  const _OrderTotalRow({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: context.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              context.l10n.orderTotal,
              style: context.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            total.asPKR,
            style: context.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: context.primary,
            ),
          ),
        ],
      ),
    );
  }
}
