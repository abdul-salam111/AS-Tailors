import 'package:flutter/material.dart';
import '../../../../../core/constants/app_enums.dart';
import '../../../../../core/di/di_exports.dart';
import '../../../../../core/shared/shared_exports.dart';
import '../../../../../core/theme/theme_exports.dart';
import '../../../../../core/utils/utils_exports.dart';
import '../../../../../core/widgets/widgets_exports.dart';
import '../../../../../routes/routes_exports.dart';
import '../../../../measurement/domain/entities/measurement_profile_entity.dart';
import '../../../../measurement/domain/entities/measurement_value_entity.dart';
import '../../../../measurement/domain/usecases/get_profile_detail_usecase.dart';
import '../../../domain/entities/customer_entity.dart';
import '../blocs/customer_detail_bloc.dart';
import '../blocs/customer_detail_event.dart';
import '../blocs/customer_detail_state.dart';

/// Customer profile (SRS §23.4): contact details, archive action, and a
/// measurements section (SRS §23.5) listing saved profiles with an entry
/// point to take a new one. Order/payment history will land here once
/// those features exist.
class CustomerDetailView extends StatelessWidget {
  final String customerId;

  const CustomerDetailView({super.key, required this.customerId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CustomerDetailBloc>()
        ..add(LoadCustomerEvent(customerId))
        ..add(LoadMeasurementsEvent(customerId)),
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

  Future<void> _openMeasurementPreview(BuildContext context, String profileId) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _MeasurementPreviewSheet(profileId: profileId),
    );
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(context.l10n.measurements, style: context.titleMedium),
                    CustomButton.text(
                      label: context.l10n.addMeasurementBtn,
                      onPressed: () => context.push(RoutePaths.addMeasurementPath(customer.id)),
                    ),
                  ],
                ),
                heightBox(8),
                _buildMeasurementsList(context, state),
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

  Widget _buildMeasurementsList(BuildContext context, CustomerDetailState state) {
    if (state.measurementsStatus == ApiStatus.LOADING) {
      return const LoadingIndicator();
    }
    if (state.measurementsStatus == ApiStatus.FAILURE) {
      return Text(
        context.l10n.failedToLoadMeasurements,
        style: context.bodySmall.copyWith(color: context.error),
      );
    }
    if (state.measurementProfiles.isEmpty) {
      return Text(
        context.l10n.noMeasurementsYet,
        style: context.bodySmall.copyWith(color: context.textSecondary),
      );
    }
    return Column(
      children: state.measurementProfiles
          .map(
            (profile) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Iconsax.ruler, color: context.textSecondary),
              title: Text(profile.templateName ?? context.l10n.measurements),
              subtitle: Text(
                '${context.l10n.version} ${profile.version} · ${profile.measuredAt.formatted}',
              ),
              trailing: const Icon(Iconsax.arrow_right_3),
              onTap: () => _openMeasurementPreview(context, profile.id),
            ),
          )
          .toList(),
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

/// Read-only preview of one saved measurement profile — a one-shot fetch
/// via the usecase directly (not routed through `CustomerDetailBloc`,
/// which only tracks the summary list) since this is transient UI with no
/// state anything else needs to observe.
class _MeasurementPreviewSheet extends StatefulWidget {
  final String profileId;

  const _MeasurementPreviewSheet({required this.profileId});

  @override
  State<_MeasurementPreviewSheet> createState() => _MeasurementPreviewSheetState();
}

class _MeasurementPreviewSheetState extends State<_MeasurementPreviewSheet> {
  late final Future<Either<Failure, MeasurementProfileEntity>> _future =
      sl<GetProfileDetailUsecase>()(widget.profileId);

  String _formatValue(BuildContext context, MeasurementValueEntity value) {
    switch (value.inputType) {
      case MeasurementFieldInputType.number:
        return '${value.value} ${value.unit ?? ''}'.trim();
      case MeasurementFieldInputType.counter:
        return '${value.value?.toInt() ?? 0}';
      case MeasurementFieldInputType.checkbox:
        return value.value == 1 ? context.l10n.yes : context.l10n.no;
      case MeasurementFieldInputType.dropdown:
        if (context.isUrdu && value.selectedOptionLabelUr != null) {
          return value.selectedOptionLabelUr!;
        }
        return value.selectedOptionLabelEn ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: 0.75,
        child: FutureBuilder<Either<Failure, MeasurementProfileEntity>>(
          future: _future,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: LoadingIndicator());
            }
            return snapshot.data!.fold(
              (failure) => Center(
                child: Text(
                  AppFailureMapper.map(failure).message,
                  style: context.bodySmall.copyWith(color: context.error),
                ),
              ),
              (profile) => ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    profile.templateName ?? context.l10n.measurements,
                    style: context.titleLarge,
                  ),
                  heightBox(4),
                  Text(
                    '${context.l10n.version} ${profile.version} · ${profile.measuredAt.formatted} · ${profile.unit}',
                    style: context.bodySmall.copyWith(color: context.textSecondary),
                  ),
                  heightBox(16),
                  ...profile.values.map(
                    (value) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.isUrdu ? (value.labelUr ?? value.labelEn) : value.labelEn,
                            style: context.bodyMedium,
                          ),
                          Text(
                            _formatValue(context, value),
                            style: context.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (profile.notes != null && profile.notes!.isNotEmpty) ...[
                    heightBox(16),
                    Text(
                      context.l10n.notes,
                      style: context.bodySmall.copyWith(color: context.textSecondary),
                    ),
                    Text(profile.notes!, style: context.bodyMedium),
                  ],
                  if (profile.imageUrls.isNotEmpty) ...[
                    heightBox(16),
                    Text(
                      context.l10n.referencePhotos,
                      style: context.bodySmall.copyWith(color: context.textSecondary),
                    ),
                    heightBox(8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: profile.imageUrls
                          .map(
                            (url) => ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(url, width: 80, height: 80, fit: BoxFit.cover),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
