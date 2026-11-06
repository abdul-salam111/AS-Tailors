import 'package:flutter/material.dart';
import '../../../../../core/constants/app_enums.dart';
import '../../../../../core/di/di_exports.dart';
import '../../../../../core/shared/shared_exports.dart';
import '../../../../../core/utils/utils_exports.dart';
import '../../../../../core/widgets/widgets_exports.dart';
import '../../../../../routes/routes_exports.dart';
import '../../../domain/entities/customer_entity.dart';
import '../blocs/customer_form_bloc.dart';
import '../blocs/customer_form_event.dart';
import '../blocs/customer_form_state.dart';

/// Add-or-edit customer form (SRS §23.4). Pass [customer] to edit an
/// existing record — the title, submit label and pre-filled fields adapt
/// automatically; omit it to register a brand-new walk-in.
class CustomerFormView extends StatelessWidget {
  final CustomerEntity? customer;

  const CustomerFormView({super.key, this.customer});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CustomerFormBloc>()..add(CustomerFormInitialized(customer)),
      child: _CustomerFormBody(customer: customer),
    );
  }
}

class _CustomerFormBody extends StatefulWidget {
  final CustomerEntity? customer;

  const _CustomerFormBody({this.customer});

  @override
  State<_CustomerFormBody> createState() => _CustomerFormBodyState();
}

class _CustomerFormBodyState extends State<_CustomerFormBody> {
  final _formKey = GlobalKey<FormState>();
  late final _fullNameController = TextEditingController(text: widget.customer?.fullName);
  late final _whatsappController = TextEditingController(text: widget.customer?.whatsapp);
  late final _addressController = TextEditingController(text: widget.customer?.address);
  late final _notesController = TextEditingController(text: widget.customer?.notes);

  @override
  void dispose() {
    _fullNameController.dispose();
    _whatsappController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CustomerFormBloc, CustomerFormState>(
      listenWhen: (previous, current) => previous.apiStatus != current.apiStatus,
      listener: (context, state) {
        if (state.apiStatus == ApiStatus.SUCCESS && state.customer != null) {
          AppToastsUtils.showSuccessTop(
            context,
            state.isEditing
                ? context.l10n.customerUpdatedSuccessfully
                : context.l10n.customerCreatedSuccessfully,
          );
          if (state.isEditing) {
            Navigator.of(context).pop(state.customer);
          } else {
            // Decoupled flow: the customer is already saved, so go straight
            // into taking their measurement instead of back to the list —
            // measurements are optional and can always be added later from
            // the customer's detail screen, but most new walk-ins get
            // measured on the spot.
            context.pushReplacement(RoutePaths.addMeasurementPath(state.customer!.id));
          }
        }
        if (state.apiStatus == ApiStatus.FAILURE && state.failure != null) {
          AppToastsUtils.showErrorTop(context, AppFailureMapper.map(state.failure!).message);
        }
      },
      builder: (context, state) {
        return UnfocusWrapper(
          child: Scaffold(
            appBar: CustomAppBar(
              title: state.isEditing ? context.l10n.editCustomer : context.l10n.addCustomer,
            ),
            body: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  CustomTextFormField(
                    label: context.l10n.customerFullName,
                    prefixIcon: Iconsax.user,
                    controller: _fullNameController,
                    validator: (v) =>
                        Validator.validateRequired(v, fieldName: context.l10n.customerFullName),
                    onChanged: (value) =>
                        context.read<CustomerFormBloc>().add(FullNameChangedEvent(value)),
                  ),
                  heightBox(16),
                  CustomTextFormField(
                    label: context.l10n.whatsapp,
                    prefixIcon: Iconsax.message,
                    keyboardType: TextInputType.phone,
                    controller: _whatsappController,
                    onChanged: (value) =>
                        context.read<CustomerFormBloc>().add(WhatsappChangedEvent(value)),
                  ),
                  heightBox(16),
                  CustomTextFormField(
                    label: context.l10n.address,
                    prefixIcon: Iconsax.location,
                    maxLines: 2,
                    controller: _addressController,
                    onChanged: (value) =>
                        context.read<CustomerFormBloc>().add(AddressChangedEvent(value)),
                  ),
                  heightBox(16),
                  CustomTextFormField(
                    label: context.l10n.notes,
                    prefixIcon: Iconsax.note,
                    maxLines: 3,
                    controller: _notesController,
                    onChanged: (value) =>
                        context.read<CustomerFormBloc>().add(NotesChangedEvent(value)),
                  ),
                  heightBox(32),
                  CustomButton(
                    label: state.isEditing ? context.l10n.saveChanges : context.l10n.addCustomerBtn,
                    isLoading: state.apiStatus == ApiStatus.LOADING,
                    radius: 10,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        context.read<CustomerFormBloc>().add(CustomerFormSubmitted());
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
