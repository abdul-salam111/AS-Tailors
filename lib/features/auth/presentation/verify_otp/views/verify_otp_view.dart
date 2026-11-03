import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/constants/const_exports.dart';
import '../../../../../core/di/di_exports.dart';
import '../../../../../core/shared/shared_exports.dart';
import '../../../../../core/theme/theme_exports.dart';
import '../../../../../core/utils/utils_exports.dart';
import '../../../../../core/widgets/widgets_exports.dart';
import '../../../../../routes/routes_exports.dart';
import '../../widgets/auth_gradient_background.dart';
import '../../widgets/complete_sign_in.dart';
import '../../widgets/entrance_choreography.dart';
import '../blocs/verify_otp_bloc.dart';
import '../blocs/verify_otp_event.dart';
import '../blocs/verify_otp_state.dart';

const _resendCooldown = Duration(seconds: 30);

/// Public entry point for the post-signup email verification screen —
/// reached from [SignUpView] once `signUp` succeeds, since the Supabase
/// project requires email confirmation and `signUp` never yields a
/// session on its own (see `AuthRepositoryImpl.signUp`). [email] is the
/// address the 6-digit code was sent to.
class VerifyOtpView extends StatelessWidget {
  const VerifyOtpView({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<VerifyOtpBloc>()..add(VerifyOtpInitialized(email)),
      child: _VerifyOtpBody(email: email),
    );
  }
}

/// Takes [email] directly (rather than reading it back off the bloc)
/// purely for display — the bloc's `VerifyOtpInitialized` event is
/// processed asynchronously, so a `context.read` in the first `build()`
/// would briefly render an empty subtitle. The bloc still gets its own
/// copy via that event, since it's what `_onSubmit`/`_onResend` use.
class _VerifyOtpBody extends StatefulWidget {
  const _VerifyOtpBody({required this.email});

  final String email;

  @override
  State<_VerifyOtpBody> createState() => _VerifyOtpBodyState();
}

class _VerifyOtpBodyState extends State<_VerifyOtpBody> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  late final _entrance = EntranceChoreography(this);
  Timer? _cooldownTimer;
  int _secondsLeft = 0;

  @override
  void dispose() {
    _otpController.dispose();
    _cooldownTimer?.cancel();
    _entrance.dispose();
    super.dispose();
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    setState(() => _secondsLeft = _resendCooldown.inSeconds);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft -= 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return UnfocusWrapper(
      child: Scaffold(
        body: BlocListener<VerifyOtpBloc, VerifyOtpState>(
          listenWhen: (previous, current) =>
              previous.apiStatus != current.apiStatus ||
              previous.resendStatus != current.resendStatus,
          listener: (context, state) {
            if (state.apiStatus == ApiStatus.SUCCESS && state.authEntity != null) {
              AppToastsUtils.showSuccessTop(context, context.l10n.emailVerifiedSuccessfully);
              completeSignIn(context, state.authEntity!);
            }
            if (state.apiStatus == ApiStatus.FAILURE && state.failure != null) {
              AppToastsUtils.showErrorTop(context, AppFailureMapper.map(state.failure!).message);
            }
            if (state.resendStatus == ApiStatus.SUCCESS) {
              AppToastsUtils.showSuccessTop(context, context.l10n.codeResentSuccessfully);
              _startCooldown();
            }
            if (state.resendStatus == ApiStatus.FAILURE && state.failure != null) {
              AppToastsUtils.showErrorTop(context, AppFailureMapper.map(state.failure!).message);
            }
          },
          child: Stack(
            children: [
              Positioned.fill(child: AuthGradientBackground(child: _buildHero(context))),
              Positioned(
                top: MediaQuery.paddingOf(context).top + 240,
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildSheet(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    final logoAnim = _entrance.interval(0.0, 0.45);
    final titleAnim = _entrance.interval(0.1, 0.55);
    final subtitleAnim = _entrance.interval(0.18, 0.6);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(alignment: Alignment.centerLeft, child: _buildBackButton(context)),
            heightBox(4),
            AnimatedBuilder(
              animation: logoAnim,
              builder: (context, child) {
                return Opacity(
                  opacity: logoAnim.value,
                  child: Transform.scale(scale: 0.7 + (0.3 * logoAnim.value), child: child),
                );
              },
              child: const _IconCard(),
            ),
            heightBox(18),
            _entrance.fadeSlideUp(
              titleAnim,
              Text(
                context.l10n.verifyYourEmail,
                style: context.headlineSmall.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            heightBox(8),
            _entrance.fadeSlideUp(
              subtitleAnim,
              Column(
                children: [
                  Text(
                    context.l10n.verificationCodeSentTo,
                    textAlign: TextAlign.center,
                    style: context.bodyMedium.copyWith(color: context.textSecondary),
                  ),
                  Text(
                    widget.email,
                    textAlign: TextAlign.center,
                    style: context.bodyMedium.copyWith(
                      color: context.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go(RoutePaths.signin),
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.surfaceElevated,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: context.shadow, blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Icon(Icons.arrow_back, size: 20, color: context.textPrimary),
      ),
    );
  }

  Widget _buildSheet(BuildContext context) {
    return _entrance.fadeSlideUp(
      _entrance.interval(0.22, 0.65),
      DecoratedBox(
        decoration: BoxDecoration(
          color: context.surfaceElevated,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.brandTeal.withValues(alpha: 0.12),
              blurRadius: 28,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          bottom: false,
          child: Column(
            children: [
              heightBox(10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(child: SingleChildScrollView(child: _buildForm(context))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _entrance.fadeSlideUp(
              _entrance.interval(0.3, 0.65),
              Text(
                context.l10n.checkYourEmailForCode,
                style: context.bodyMedium.copyWith(color: context.textSecondary),
              ),
            ),
            heightBox(20),
            _entrance.fadeSlideUp(
              _entrance.interval(0.34, 0.72),
              CustomTextFormField(
                controller: _otpController,
                label: context.l10n.verificationCode,
                hintText: context.l10n.enterVerificationCode,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                validator: (value) =>
                    (value == null || value.length != 6) ? context.l10n.enterVerificationCode : null,
                onChanged: (otp) => context.read<VerifyOtpBloc>().add(OtpChangedEvent(otp)),
              ),
            ),
            heightBox(20),
            _entrance.fadeSlideUp(
              _entrance.interval(0.4, 0.8),
              BlocBuilder<VerifyOtpBloc, VerifyOtpState>(
                buildWhen: (p, n) => p.apiStatus != n.apiStatus,
                builder: (context, state) => CustomButton(
                  isLoading: state.apiStatus == ApiStatus.LOADING,
                  label: context.l10n.verifyBtn,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      context.read<VerifyOtpBloc>().add(VerifyOtpSubmitted());
                    }
                  },
                  radius: 14,
                  height: 54,
                ),
              ),
            ),
            heightBox(18),
            _entrance.fadeSlideUp(_entrance.interval(0.5, 0.9), _buildResendRow(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildResendRow(BuildContext context) {
    return BlocBuilder<VerifyOtpBloc, VerifyOtpState>(
      buildWhen: (p, n) => p.resendStatus != n.resendStatus,
      builder: (context, state) {
        final isCoolingDown = _secondsLeft > 0;
        final isLoading = state.resendStatus == ApiStatus.LOADING;
        return Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(context.l10n.didntReceiveCode, style: context.bodySmall),
              TextButton(
                onPressed: (isCoolingDown || isLoading)
                    ? null
                    : () => context.read<VerifyOtpBloc>().add(ResendOtpRequested()),
                child: Text(
                  isCoolingDown ? '${context.l10n.resendCode} (${_secondsLeft}s)' : context.l10n.resendCode,
                  style: context.bodySmall.copyWith(
                    color: (isCoolingDown || isLoading) ? context.textDisabled : context.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _IconCard extends StatelessWidget {
  const _IconCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: AppColors.brandTeal.withValues(alpha: 0.2), blurRadius: 24, spreadRadius: 2),
        ],
      ),
      child: const Icon(Iconsax.sms, size: 40, color: AppColors.brandTeal),
    );
  }
}
