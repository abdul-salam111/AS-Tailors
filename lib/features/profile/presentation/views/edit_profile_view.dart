import 'package:flutter/material.dart';
import '../../../../core/di/di_exports.dart';
import '../../../../core/services/session_manager.dart';
import '../../../../core/utils/utils_exports.dart';
import '../../../../core/widgets/widgets_exports.dart';
import '../../../../routes/routes_exports.dart';
import '../../../auth/auth_exports.dart';

/// Edits the signed-in user's display name. A single field with no
/// server-side state to track beyond loading/error, so this calls
/// `UpdateProfileUsecase` directly rather than going through a Bloc — same
/// reasoning as `ProfileView`'s own direct `SignOutUsecase` call.
class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  late final _fullNameController = TextEditingController(
    text: sl<SessionController>().session.fullName,
  );
  bool _saving = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final result = await sl<UpdateProfileUsecase>()(_fullNameController.text.trim());
    if (!mounted) return;
    setState(() => _saving = false);
    result.fold(
      (failure) => AppToastsUtils.showErrorTop(context, AppFailureMapper.map(failure).message),
      (updated) {
        final sessionController = sl<SessionController>();
        sessionController.setSession(
          sessionController.session.copyWith(fullName: updated.fullName),
        );
        AppToastsUtils.showSuccessTop(context, context.l10n.profileUpdatedSuccessfully);
        context.pop(true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return UnfocusWrapper(
      child: Scaffold(
        appBar: CustomAppBar(title: context.l10n.editProfile),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              CustomTextFormField(
                label: context.l10n.fullName,
                prefixIcon: Iconsax.user,
                controller: _fullNameController,
                validator: (v) => Validator.validateRequired(v, fieldName: context.l10n.fullName),
              ),
              heightBox(32),
              CustomButton(
                label: context.l10n.saveChanges,
                isLoading: _saving,
                radius: 10,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
