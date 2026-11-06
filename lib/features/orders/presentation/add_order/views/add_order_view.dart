import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_enums.dart';
import '../../../../../core/constants/app_icons.dart';
import '../../../../../core/di/di_exports.dart';
import '../../../../../core/shared/shared_exports.dart';
import '../../../../../core/theme/theme_exports.dart';
import '../../../../../core/utils/utils_exports.dart';
import '../../../../../core/widgets/widgets_exports.dart';
import '../../../../customer/domain/entities/customer_entity.dart';
import '../../../../customer/domain/entities/get_customers_params.dart';
import '../../../../customer/domain/usecases/get_customers_usecase.dart';
import '../../../../measurement/domain/entities/garment_category_entity.dart';
import '../../../../measurement/domain/entities/measurement_profile_entity.dart';
import '../../../../measurement/domain/usecases/get_profiles_for_customer_usecase.dart';
import '../../../../measurement/domain/usecases/get_template_for_category_usecase.dart';
import '../../../domain/entities/order_item_draft_entity.dart';
import '../blocs/add_order_bloc.dart';
import '../blocs/add_order_event.dart';
import '../blocs/add_order_state.dart';

/// Create-order screen (orders/order_items): pick a customer, an optional
/// due date, one or more garment line items — each a category + quantity
/// + manually-entered unit price + an optional link to one of that
/// customer's existing measurement profiles (snapshotted server-side at
/// submit time, see `create_order()` in `0009_orders.sql`) — and notes.
/// There's no price list or payment capture here yet; Payments stays a
/// separate future feature (CLAUDE.md §1a).
///
/// [initialCustomer] pre-fills the customer picker when pushed from a
/// context that already knows one (e.g. a future "New Order" action on
/// Customer Detail); the global "Create Order" FAB pushes this with none,
/// and the customer is picked inside the form instead.
class AddOrderView extends StatelessWidget {
  final CustomerEntity? initialCustomer;

  const AddOrderView({super.key, this.initialCustomer});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AddOrderBloc>()..add(AddOrderInitialized(initialCustomer)),
      child: const _AddOrderBody(),
    );
  }
}

class _AddOrderBody extends StatefulWidget {
  const _AddOrderBody();

  @override
  State<_AddOrderBody> createState() => _AddOrderBodyState();
}

class _AddOrderBodyState extends State<_AddOrderBody> {
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickCustomer(BuildContext context) async {
    final selected = await showModalBottomSheet<CustomerEntity>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => const _CustomerPickerSheet(),
    );
    if (selected != null && context.mounted) {
      context.read<AddOrderBloc>().add(OrderCustomerSelected(selected));
    }
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
      context.read<AddOrderBloc>().add(OrderDueDateChanged(picked));
    }
  }

  Future<void> _openAddItemSheet(BuildContext context, AddOrderState state) async {
    final customer = state.customer;
    if (customer == null) {
      AppToastsUtils.showInfoTop(context, context.l10n.pleaseSelectCustomerFirst);
      return;
    }
    final draft = await showModalBottomSheet<OrderItemDraftEntity>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) =>
          _AddOrderItemSheet(categories: state.categories, customerId: customer.id),
    );
    if (draft != null && context.mounted) {
      context.read<AddOrderBloc>().add(OrderItemAdded(draft));
    }
  }

  void _submit(BuildContext context, AddOrderState state) {
    if (state.customer == null) {
      AppToastsUtils.showInfoTop(context, context.l10n.pleaseSelectCustomerFirst);
      return;
    }
    if (state.items.isEmpty) {
      AppToastsUtils.showInfoTop(context, context.l10n.pleaseAddAtLeastOneGarment);
      return;
    }
    context.read<AddOrderBloc>().add(AddOrderSubmitted());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddOrderBloc, AddOrderState>(
      listenWhen: (previous, current) => previous.submitStatus != current.submitStatus,
      listener: (context, state) {
        if (state.submitStatus == ApiStatus.SUCCESS) {
          AppToastsUtils.showSuccessTop(context, context.l10n.orderCreatedSuccessfully);
          context.pop(true);
        }
        if (state.submitStatus == ApiStatus.FAILURE && state.failure != null) {
          AppToastsUtils.showErrorTop(context, AppFailureMapper.map(state.failure!).message);
        }
      },
      builder: (context, state) {
        return UnfocusWrapper(
          child: Scaffold(
            backgroundColor: context.background,
            appBar: CustomAppBar(title: context.l10n.newOrder),
            body: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _sectionLabel(context, context.l10n.selectCustomer),
                heightBox(12),
                _CustomerField(customer: state.customer, onTap: () => _pickCustomer(context)),
                heightBox(24),
                _sectionLabel(context, context.l10n.dueDate),
                heightBox(12),
                _DueDateField(
                  dueDate: state.dueDate,
                  onTap: () => _pickDueDate(context, state.dueDate),
                ),
                heightBox(24),
                Row(
                  children: [
                    Expanded(child: _sectionLabel(context, context.l10n.garments)),
                    CustomButton.text(
                      label: context.l10n.addGarment,
                      height: 28,
                      fontSize: 13,
                      onPressed: () => _openAddItemSheet(context, state),
                    ),
                  ],
                ),
                heightBox(8),
                if (state.items.isEmpty)
                  _EmptyItemsHint(onTap: () => _openAddItemSheet(context, state))
                else
                  Column(
                    children: [
                      for (var i = 0; i < state.items.length; i++) ...[
                        _OrderItemCard(
                          item: state.items[i],
                          onRemove: () => context.read<AddOrderBloc>().add(OrderItemRemoved(i)),
                        ),
                        if (i != state.items.length - 1) heightBox(10),
                      ],
                    ],
                  ),
                heightBox(24),
                _sectionLabel(context, context.l10n.notes),
                heightBox(12),
                CustomTextFormField(
                  prefixIcon: Iconsax.note,
                  hintText: context.l10n.notes,
                  maxLines: 3,
                  controller: _notesController,
                  onChanged: (value) => context.read<AddOrderBloc>().add(OrderNotesChanged(value)),
                ),
                heightBox(24),
                _OrderTotalRow(total: state.totalAmount),
                heightBox(20),
                CustomButton(
                  label: context.l10n.createOrder,
                  isLoading: state.submitStatus == ApiStatus.LOADING,
                  radius: 10,
                  onPressed: () => _submit(context, state),
                ),
                heightBox(12),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sectionLabel(BuildContext context, String title) =>
      Text(title, style: context.titleSmall.copyWith(fontWeight: FontWeight.bold));
}

class _CustomerField extends StatelessWidget {
  final CustomerEntity? customer;
  final VoidCallback onTap;
  const _CustomerField({required this.customer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final customer = this.customer;
    final box = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: context.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.divider),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: context.primary.withValues(alpha: 0.12),
            child: Text(
              customer != null && customer.fullName.isNotEmpty
                  ? customer.fullName[0].toUpperCase()
                  : '?',
              style: context.bodyMedium.copyWith(
                color: context.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          widthBox(12),
          Expanded(
            child: Text(
              customer?.fullName ?? context.l10n.selectCustomer,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: customer == null ? context.textDisabled : context.textPrimary,
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

class _EmptyItemsHint extends StatelessWidget {
  final VoidCallback onTap;
  const _EmptyItemsHint({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final box = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: context.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.primary.withValues(alpha: 0.3)),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Iconsax.bag_2, color: context.primary, size: 26),
          heightBox(8),
          Text(
            context.l10n.noGarmentsAddedYet,
            style: context.bodySmall.copyWith(color: context.textSecondary),
          ),
        ],
      ),
    );
    return box.onTap(onTap);
  }
}

class _OrderItemCard extends StatelessWidget {
  final OrderItemDraftEntity item;
  final VoidCallback onRemove;
  const _OrderItemCard({required this.item, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: context.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(Iconsax.bag_2, size: 17, color: context.primary),
          ),
          widthBox(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.categoryName,
                  style: context.bodyMedium.copyWith(fontWeight: FontWeight.w700),
                ),
                heightBox(3),
                Text(
                  '${item.quantity} × ${item.unitPrice.asPKR}',
                  style: context.bodySmall.copyWith(color: context.textSecondary),
                ),
                if (item.measurementProfileLabel != null) ...[
                  heightBox(3),
                  Row(
                    children: [
                      Icon(Iconsax.ruler, size: 12, color: context.primary),
                      widthBox(4),
                      Expanded(
                        child: Text(
                          item.measurementProfileLabel!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.labelSmall.copyWith(color: context.primary),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          widthBox(8),
          Text(
            item.lineTotal.asPKR,
            style: context.bodyMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          IconButton(
            onPressed: onRemove,
            icon: Icon(Iconsax.trash, size: 18, color: context.error),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
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

/// Search-as-you-type customer picker, mirroring `CustomerListView`'s own
/// search+pagination pattern (§7a) but as a standalone sheet that pops
/// with the tapped [CustomerEntity] instead of navigating away.
class _CustomerPickerSheet extends StatefulWidget {
  const _CustomerPickerSheet();

  @override
  State<_CustomerPickerSheet> createState() => _CustomerPickerSheetState();
}

class _CustomerPickerSheetState extends State<_CustomerPickerSheet> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  String _search = '';
  late final _cubit = PaginationCubit<CustomerEntity>(
    fetchPage: (page) =>
        sl<GetCustomersUsecase>()(GetCustomersParams(page: page, limit: 20, search: _search)),
  );

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _cubit.close();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _search = value;
      _cubit.refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.screenHeight * 0.82,
      child: SafeArea(
        child: Column(
          children: [
            heightBox(12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            heightBox(16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                context.l10n.selectCustomer,
                style: context.titleSmall.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            heightBox(14),
            CustomSearchField(
              hintText: context.l10n.searchCustomers,
              controller: _searchController,
              onChanged: _onSearchChanged,
            ).withPadding(const EdgeInsets.symmetric(horizontal: 20)),
            heightBox(8),
            Expanded(
              child: PaginatedListView<CustomerEntity>(
                cubit: _cubit,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                emptyWidget: EmptyStateWidget(
                  iconAsset: AppIcons.customers,
                  title: context.l10n.noCustomersYet,
                ),
                itemBuilder: (context, customer) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: context.primary.withValues(alpha: 0.1),
                    child: Text(
                      customer.fullName.isNotEmpty ? customer.fullName[0].toUpperCase() : '?',
                      style: context.bodyMedium.copyWith(color: context.primary),
                    ),
                  ),
                  title: Text(customer.fullName, style: context.bodyMedium),
                  subtitle:
                      (customer.whatsapp?.isNotEmpty ?? false) ||
                          (customer.phone?.isNotEmpty ?? false)
                      ? Text(
                          (customer.whatsapp?.isNotEmpty ?? false)
                              ? customer.whatsapp!
                              : customer.phone!,
                          style: context.bodySmall,
                        )
                      : null,
                  onTap: () => Navigator.of(context).pop(customer),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Add Garment" sheet — picks a category, optionally links one of the
/// customer's existing measurement profiles for that category (fetched
/// once via direct usecase calls, not through [AddOrderBloc] — the same
/// reasoning `measurement_form_view.dart`'s own image-source sheet
/// follows: a bottom sheet's `builder` context is not a reliable
/// descendant of a screen-level `BlocProvider`), sets quantity/price/
/// notes, then pops with the resulting [OrderItemDraftEntity].
class _AddOrderItemSheet extends StatefulWidget {
  final List<GarmentCategoryEntity> categories;
  final String customerId;

  const _AddOrderItemSheet({required this.categories, required this.customerId});

  @override
  State<_AddOrderItemSheet> createState() => _AddOrderItemSheetState();
}

class _AddOrderItemSheetState extends State<_AddOrderItemSheet> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _itemNotesController = TextEditingController();

  bool _loadingProfiles = true;
  List<MeasurementProfileEntity> _customerProfiles = [];

  GarmentCategoryEntity? _selectedCategory;
  bool _loadingTemplate = false;
  List<MeasurementProfileEntity> _matchingProfiles = [];
  String? _selectedProfileId;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  @override
  void dispose() {
    _priceController.dispose();
    _itemNotesController.dispose();
    super.dispose();
  }

  Future<void> _loadProfiles() async {
    final result = await sl<GetProfilesForCustomerUsecase>()(widget.customerId);
    if (!mounted) return;
    setState(() {
      _loadingProfiles = false;
      _customerProfiles = result.fold((_) => const [], (profiles) => profiles);
    });
  }

  Future<void> _selectCategory(GarmentCategoryEntity category) async {
    setState(() {
      _selectedCategory = category;
      _loadingTemplate = true;
      _matchingProfiles = [];
      _selectedProfileId = null;
    });
    final result = await sl<GetTemplateForCategoryUsecase>()(category.id);
    if (!mounted) return;
    result.fold((_) => setState(() => _loadingTemplate = false), (template) {
      final matches = _customerProfiles.where((p) => p.templateId == template.id).toList();
      setState(() {
        _loadingTemplate = false;
        _matchingProfiles = matches;
        _selectedProfileId = matches.isNotEmpty ? matches.first.id : null;
      });
    });
  }

  String _categoryLabel(BuildContext context, GarmentCategoryEntity category) =>
      context.isUrdu ? (category.nameUr ?? category.name) : category.name;

  String _profileLabel(MeasurementProfileEntity profile) =>
      (profile.name != null && profile.name!.trim().isNotEmpty)
      ? profile.name!
      : 'v${profile.version} • ${profile.measuredAt.formatted}';

  void _submit() {
    final category = _selectedCategory;
    if (category == null || !_formKey.currentState!.validate()) return;

    MeasurementProfileEntity? selectedProfile;
    for (final profile in _matchingProfiles) {
      if (profile.id == _selectedProfileId) {
        selectedProfile = profile;
        break;
      }
    }

    Navigator.of(context).pop(
      OrderItemDraftEntity(
        categoryId: category.id,
        categoryName: _categoryLabel(context, category),
        measurementProfileId: selectedProfile?.id,
        measurementProfileLabel: selectedProfile == null ? null : _profileLabel(selectedProfile),
        quantity: _quantity,
        unitPrice: double.parse(_priceController.text),
        notes: _itemNotesController.text.trim().isEmpty ? null : _itemNotesController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ordered = widget.categories.sortedByDisplayPriority();
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
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
                  heightBox(16),
                  Text(
                    context.l10n.addGarment,
                    style: context.titleSmall.copyWith(fontWeight: FontWeight.bold),
                  ),
                  heightBox(16),
                  Text(
                    context.l10n.selectGarmentCategory,
                    style: context.labelSmall.copyWith(color: context.textSecondary),
                  ),
                  heightBox(8),
                  Row(
                    children: [
                      for (var i = 0; i < ordered.length; i++) ...[
                        Expanded(
                          child: _CategoryChip(
                            label: _categoryLabel(context, ordered[i]),
                            selected: _selectedCategory?.id == ordered[i].id,
                            onTap: () => _selectCategory(ordered[i]),
                          ),
                        ),
                        if (i != ordered.length - 1) widthBox(10),
                      ],
                    ],
                  ),
                  if (_loadingProfiles || _loadingTemplate) ...[
                    heightBox(20),
                    const Center(child: LoadingIndicator()),
                  ],
                  if (!_loadingTemplate && _selectedCategory != null) ...[
                    heightBox(18),
                    Text(
                      context.l10n.measurementProfile,
                      style: context.labelSmall.copyWith(color: context.textSecondary),
                    ),
                    heightBox(8),
                    if (_matchingProfiles.isEmpty)
                      Text(
                        context.l10n.noMeasurementProfilesForCategory,
                        style: context.bodySmall.copyWith(color: context.textDisabled),
                      )
                    else
                      Column(
                        children: [
                          for (final profile in _matchingProfiles) ...[
                            _ProfileOptionTile(
                              label: _profileLabel(profile),
                              selected: _selectedProfileId == profile.id,
                              onTap: () => setState(() => _selectedProfileId = profile.id),
                            ),
                            heightBox(6),
                          ],
                          _ProfileOptionTile(
                            label: context.l10n.noMeasurementProfileOption,
                            selected: _selectedProfileId == null,
                            onTap: () => setState(() => _selectedProfileId = null),
                          ),
                        ],
                      ),
                    heightBox(18),
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
                                    _StepperIconButton(
                                      icon: Iconsax.minus,
                                      onTap: _quantity > 1
                                          ? () => setState(() => _quantity--)
                                          : null,
                                    ),
                                    Expanded(
                                      child: Text(
                                        '$_quantity',
                                        textAlign: TextAlign.center,
                                        style: context.titleMedium.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    _StepperIconButton(
                                      icon: Iconsax.add,
                                      onTap: () => setState(() => _quantity++),
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
                            controller: _priceController,
                            validator: (v) => Validator.validateMinValue(
                              v,
                              0.01,
                              fieldName: context.l10n.unitPrice,
                            ),
                          ),
                        ),
                      ],
                    ),
                    heightBox(16),
                    CustomTextFormField(
                      label: context.l10n.notes,
                      controller: _itemNotesController,
                    ),
                    heightBox(20),
                    CustomButton(label: context.l10n.add, radius: 10, onPressed: _submit),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _CategoryChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? context.primary.withValues(alpha: 0.12) : context.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: selected ? context.primary : context.border),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: context.bodySmall.copyWith(
          color: selected ? context.primary : context.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
    return chip.onTap(onTap);
  }
}

class _ProfileOptionTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ProfileOptionTile({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tile = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? context.primary.withValues(alpha: 0.1) : context.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: selected ? context.primary : context.border),
      ),
      child: Row(
        children: [
          Icon(
            selected ? Iconsax.tick_circle5 : Iconsax.record_circle,
            size: 18,
            color: selected ? context.primary : context.textSecondary,
          ),
          widthBox(10),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.bodySmall.copyWith(
                color: selected ? context.primary : context.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    return tile.onTap(onTap);
  }
}

class _StepperIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _StepperIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final button = Container(
      width: 34,
      height: 34,
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
