import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/di/di_exports.dart';
import '../../../../core/services/session_manager.dart';
import '../../../../core/theme/theme_exports.dart';
import '../../../../core/utils/utils_exports.dart';
import '../../../../core/widgets/widgets_exports.dart';
import '../../../../routes/routes_exports.dart';
import '../../../auth/auth_exports.dart';

/// Edits the signed-in user's display name and avatar. Both are single
/// values with no server-side state to track beyond loading/error, so
/// this calls `UpdateProfileUsecase`/`UpdateAvatarUsecase` directly rather
/// than going through a Bloc — same reasoning as `ProfileView`'s own
/// direct `SignOutUsecase` call. The avatar uploads immediately on pick
/// (no separate save step, standard for a profile photo); the name
/// still needs the explicit "Save Changes" button.
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
  final _picker = ImagePicker();
  String? _avatarUrl = sl<SessionController>().session.avatarUrl;
  bool _uploadingAvatar = false;
  bool _saving = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked == null || !mounted) return;

    setState(() => _uploadingAvatar = true);
    final result = await sl<UpdateAvatarUsecase>()(picked.path);
    if (!mounted) return;
    setState(() => _uploadingAvatar = false);
    result.fold(
      (failure) => AppToastsUtils.showErrorTop(context, AppFailureMapper.map(failure).message),
      (updated) {
        final sessionController = sl<SessionController>();
        sessionController.setSession(
          sessionController.session.copyWith(avatarUrl: updated.avatarUrl),
        );
        setState(() => _avatarUrl = updated.avatarUrl);
        AppToastsUtils.showSuccessTop(context, context.l10n.profileUpdatedSuccessfully);
      },
    );
  }

  Future<void> _showAvatarSourceSheet() async {
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
              _AvatarSheetOption(
                icon: Iconsax.camera,
                label: context.l10n.takePhoto,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _pickAvatar(ImageSource.camera);
                },
              ),
              heightBox(10),
              _AvatarSheetOption(
                icon: Iconsax.image,
                label: context.l10n.chooseFromGallery,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _pickAvatar(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
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
        // Don't show the success toast here — `another_flushbar` pushes
        // itself as a route onto the nearest Navigator, which for this
        // screen is the same one `context.pop()` below pops from. Doing
        // both in the same frame races the Navigator (push mid-flight when
        // the pop tries to finalize it) and crashes with a
        // '_debugLocked'/'popping' assertion. Instead, pop first and let
        // `ProfileView._openEditProfile` show the toast once this screen
        // is actually gone — see profile_view.dart.
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
              Center(
                child: _AvatarPicker(
                  avatarUrl: _avatarUrl,
                  uploading: _uploadingAvatar,
                  onTap: _uploadingAvatar ? null : _showAvatarSourceSheet,
                ),
              ),
              heightBox(28),
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

class _AvatarPicker extends StatelessWidget {
  final String? avatarUrl;
  final bool uploading;
  final VoidCallback? onTap;

  const _AvatarPicker({required this.avatarUrl, required this.uploading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      height: 96,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.primary.withValues(alpha: 0.12),
              image: avatarUrl != null
                  ? DecorationImage(image: NetworkImage(avatarUrl!), fit: BoxFit.cover)
                  : null,
            ),
            alignment: Alignment.center,
            child: avatarUrl == null
                ? Image.asset(
                    AppIcons.profile,
                    width: 40,
                    height: 40,
                    fit: BoxFit.contain,
                    color: context.primary,
                  )
                : null,
          ),
          if (uploading)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.black.withValues(alpha: 0.4),
                ),
                child: const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                  ),
                ),
              ),
            ),
          PositionedDirectional(
            bottom: 0,
            end: 0,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.primary,
                border: Border.all(color: context.surfaceElevated, width: 2),
              ),
              alignment: Alignment.center,
              child: const Icon(Iconsax.camera, size: 14, color: AppColors.white),
            ).onTap(onTap ?? () {}),
          ),
        ],
      ),
    );
  }
}

class _AvatarSheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AvatarSheetOption({required this.icon, required this.label, required this.onTap});

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
