import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../../core/constants/const_exports.dart';
import '../../../../../core/di/di_exports.dart';
import '../../../../../core/shared/shared_exports.dart';
import '../../../../../core/theme/theme_exports.dart';
import '../../../../../core/utils/utils_exports.dart';
import '../../../../../core/widgets/widgets_exports.dart';
import '../../../../../routes/routes_exports.dart';
import '../../../domain/entities/customer_entity.dart';
import '../../../domain/entities/get_customers_params.dart';
import '../../../domain/usecases/get_customers_usecase.dart';

/// Customer directory (SRS §23.4) — search-as-you-type over an
/// infinite-scroll list, with an action to register a new walk-in.
class CustomerListView extends StatefulWidget {
  const CustomerListView({super.key});

  @override
  State<CustomerListView> createState() => _CustomerListViewState();
}

class _CustomerListViewState extends State<CustomerListView> {
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

  Future<void> _openAddCustomer() async {
    final created = await context.push<CustomerEntity>(RoutePaths.addCustomer);
    if (created != null) await _cubit.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: context.l10n.customers,
        // An AppBar action, not a FloatingActionButton — the bottom nav
        // bar's own "Create Order" FAB already occupies that spot now
        // that the app has a persistent shell (see routes/app_shell.dart);
        // a second FAB here would float right next to it.
        actions: [
          IconButton(
            onPressed: _openAddCustomer,
            icon: Image.asset(
              AppIcons.addCustomer,
              width: 22,
              height: 22,
              fit: BoxFit.contain,
              color: AppColors.white,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          CustomSearchField(
            hintText: context.l10n.searchCustomers,
            controller: _searchController,
            onChanged: _onSearchChanged,
          ).withPadding(const EdgeInsets.all(16)),
          Expanded(
            child: PaginatedListView<CustomerEntity>(
              cubit: _cubit,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              emptyWidget: EmptyStateWidget(
                iconAsset: AppIcons.customers,
                title: context.l10n.noCustomersYet,
                subtitle: context.l10n.addYourFirstCustomer,
              ),
              itemBuilder: (context, customer) => _CustomerListItem(customer: customer),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerListItem extends StatelessWidget {
  final CustomerEntity customer;

  const _CustomerListItem({required this.customer});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: context.primary.withValues(alpha: 0.1),
        child: Text(
          customer.fullName.isNotEmpty ? customer.fullName[0].toUpperCase() : '?',
          style: context.titleMedium.copyWith(color: context.primary),
        ),
      ),
      title: Text(customer.fullName, style: context.bodyLarge),
      subtitle: _buildSubtitle(context),
      trailing: const Icon(Iconsax.arrow_right_3, size: 18),
      onTap: () => context.push(RoutePaths.customerDetailPath(customer.id)),
    ).withPadding(const EdgeInsets.symmetric(vertical: 4));
  }

  Widget? _buildSubtitle(BuildContext context) {
    // WhatsApp is the only number the add/edit form collects now (see
    // customer_form_view.dart) — phone only still exists on customers
    // added back when that field was collected, so it's a fallback here,
    // not the primary line.
    final whatsapp = customer.whatsapp;
    final contactNumber = (whatsapp != null && whatsapp.isNotEmpty) ? whatsapp : customer.phone;
    final address = customer.address;
    if ((contactNumber == null || contactNumber.isEmpty) && (address == null || address.isEmpty)) {
      return null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (contactNumber != null && contactNumber.isNotEmpty)
          Text(contactNumber, style: context.bodySmall),
        if (address != null && address.isNotEmpty)
          Text(
            address,
            style: context.bodySmall.copyWith(color: context.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }
}
