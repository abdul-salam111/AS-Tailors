import 'package:flutter/material.dart';
import '../../../../../core/di/di_exports.dart';
import '../../../../../core/shared/shared_exports.dart';
import '../../../../../core/theme/theme_exports.dart';
import '../../../../../core/utils/utils_exports.dart';
import '../../../../../core/widgets/widgets_exports.dart';
import '../../../../../routes/routes_exports.dart';
import '../../../domain/entities/customer_entity.dart';
import '../blocs/customer_detail_bloc.dart';
import '../blocs/customer_detail_event.dart';
import '../blocs/customer_detail_state.dart';

/// Customer profile (SRS §23.4): contact details plus the archive action.
/// Order/payment/measurement history will land here once those features
/// exist — for now this shows what the customer record itself holds.
class CustomerDetailView extends StatelessWidget {
  final String customerId;

  const CustomerDetailView({super.key, required this.customerId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CustomerDetailBloc>()..add(LoadCustomerEvent(customerId)),
      child: _CustomerDetailBody(customerId: customerId),
    );
  }
}

class _CustomerDetailBody extends StatelessWidget {
  final String customerId;

  const _CustomerDetailBody({required this.customerId});

  Future<void> _confirmArchive(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.archiveCustomer),
        content: Text(context.l10n.archiveCustomerConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.archiveCustomer),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<CustomerDetailBloc>().add(ArchiveCustomerRequested(customerId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CustomerDetailBloc, CustomerDetailState>(
      listenWhen: (previous, current) =>
          previous.isArchiving != current.isArchiving && !current.isArchiving,
      listener: (context, state) {
        if (state.failure != null) {
          AppToastsUtils.showErrorTop(context, AppFailureMapper.map(state.failure!).message);
        } else if (state.customer != null && !state.customer!.isActive) {
          AppToastsUtils.showSuccessTop(context, context.l10n.customerArchivedSuccessfully);
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        final customer = state.customer;
        return Scaffold(
          appBar: CustomAppBar(
            title: context.l10n.customerDetails,
            actions: [
              if (customer != null)
                IconButton(
                  icon: const Icon(Iconsax.edit, color: AppColors.white),
                  onPressed: () async {
                    await context.push(RoutePaths.editCustomerPath(customer.id), extra: customer);
                    if (context.mounted) {
                      context.read<CustomerDetailBloc>().add(LoadCustomerEvent(customerId));
                    }
                  },
                ),
            ],
          ),
          body: ApiStatusBuilder<CustomerEntity>(
            status: state.apiStatus,
            data: customer,
            failure: state.failure,
            onRetry: () => context.read<CustomerDetailBloc>().add(LoadCustomerEvent(customerId)),
            builder: (context, customer) => ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(customer.fullName, style: context.titleLarge),
                heightBox(4),
                if (!customer.isActive)
                  Text(
                    context.l10n.archived,
                    style: context.bodySmall.copyWith(color: context.error),
                  ),
                heightBox(24),
                _DetailRow(icon: Iconsax.call, label: context.l10n.phone, value: customer.phone),
                _DetailRow(
                  icon: Iconsax.message,
                  label: context.l10n.whatsapp,
                  value: customer.whatsapp,
                ),
                _DetailRow(icon: Iconsax.sms, label: context.l10n.email, value: customer.email),
                _DetailRow(
                  icon: Iconsax.location,
                  label: context.l10n.address,
                  value: customer.address,
                ),
                _DetailRow(icon: Iconsax.note, label: context.l10n.notes, value: customer.notes),
                heightBox(32),
                if (customer.isActive)
                  CustomButton.outline(
                    label: context.l10n.archiveCustomer,
                    outlineColor: context.error,
                    textColor: context.error,
                    isLoading: state.isArchiving,
                    onPressed: () => _confirmArchive(context),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;

  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: context.textSecondary),
          widthBox(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: context.bodySmall.copyWith(color: context.textSecondary)),
                Text(value!, style: context.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
