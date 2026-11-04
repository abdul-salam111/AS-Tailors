import 'package:flutter/material.dart';
import '../../../../../core/constants/const_exports.dart';
import '../../../../../core/di/di_exports.dart';
import '../../../../../core/shared/shared_exports.dart';
import '../../../../../core/theme/theme_exports.dart';
import '../../../../../core/utils/utils_exports.dart';
import '../../../../../core/widgets/widgets_exports.dart';
import '../../widgets/auth_gradient_background.dart';
import '../../widgets/complete_sign_in.dart';
import '../../widgets/entrance_choreography.dart';
import '../../widgets/social_sign_in_buttons.dart';
import '../blocs/signin_bloc.dart';
import '../blocs/signin_event.dart';
import '../blocs/signin_state.dart';

const _sheetExpandDuration = Duration(milliseconds: 320);
// How far below the status bar the sheet rests when nothing is focused —
// roughly the height of the logo + title + subtitle hero it sits over.
const _sheetCollapsedOffset = 260.0;

/// Public entry point for the Sign-In screen.
/// Provides [SignInBloc] to the subtree and delegates UI to [_SignInBody].
class SignInView extends StatelessWidget {
  const SignInView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SignInBloc>(),
      child: const _SignInBody(),
    );
  }
}

/// Private body widget — owns the [GlobalKey<FormState>], the focus
/// nodes driving the sheet's expand/collapse animation, and the
/// staggered entrance choreography, hence [StatefulWidget] +
/// [TickerProviderStateMixin].
///
/// This is a closed, single-shop deployment, not a public signup funnel
/// (SRS §3) — there is deliberately no "Sign up" link here. Accounts are
/// provisioned outside the app and handed to whoever needs one; see
/// `scripts/create_user.dart`.
class _SignInBody extends StatefulWidget {
  const _SignInBody();
  @override
  State<_SignInBody> createState() => _SignInBodyState();
}

class _SignInBodyState extends State<_SignInBody>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  late final _entrance = EntranceChoreography(this);
  bool _isFormExpanded = false;

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(_handleFocusChange);
    _passwordFocusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _emailFocusNode
      ..removeListener(_handleFocusChange)
      ..dispose();
    _passwordFocusNode
      ..removeListener(_handleFocusChange)
      ..dispose();
    _entrance.dispose();
    super.dispose();
  }

  // The sheet expands to cover the hero while any field is focused, and
  // settles back down once focus clears (UnfocusWrapper's outside tap).
  void _handleFocusChange() {
    final expanded = _emailFocusNode.hasFocus || _passwordFocusNode.hasFocus;
    if (expanded != _isFormExpanded) {
      setState(() => _isFormExpanded = expanded);
    }
  }

  @override
  Widget build(BuildContext context) {
    return UnfocusWrapper(
      child: Scaffold(
        body: BlocListener<SignInBloc, SignInState>(
          listenWhen: (previous, current) =>
              previous.apiStatus != current.apiStatus,
          listener: (context, state) {
            if (state.apiStatus == ApiStatus.SUCCESS &&
                state.signinEntity != null) {
              completeSignIn(context, state.signinEntity!);
            }
            if (state.apiStatus == ApiStatus.FAILURE && state.failure != null) {
              AppToastsUtils.showErrorTop(
                context,
                AppFailureMapper.map(state.failure!).message,
              );
            }
          },
          child: Stack(
            children: [
              Positioned.fill(
                child: AuthGradientBackground(child: _buildHero(context)),
              ),
              AnimatedPositioned(
                duration: _sheetExpandDuration,
                curve: Curves.easeOutCubic,
                top: _isFormExpanded
                    ? 0
                    : MediaQuery.paddingOf(context).top + _sheetCollapsedOffset,
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
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [LanguageToggleButton(), ThemeToggleButton()],
              ),
            ),
            heightBox(4),
            AnimatedBuilder(
              animation: logoAnim,
              builder: (context, child) {
                return Opacity(
                  opacity: logoAnim.value,
                  child: Transform.scale(
                    scale: 0.7 + (0.3 * logoAnim.value),
                    child: child,
                  ),
                );
              },
              child: const _LogoCard(),
            ),
            heightBox(20),

            _entrance.fadeSlideUp(
              subtitleAnim,
              Text(
                context.l10n.signInTagline,
                textAlign: TextAlign.center,
                style: context.bodyMedium.copyWith(
                  color: context.textSecondary,
                ),
              ),
            ),
          ],
        ),
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
          top: _isFormExpanded,
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
              Expanded(
                child: SingleChildScrollView(child: _buildForm(context)),
              ),
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
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            heightBox(18),
            _entrance.fadeSlideUp(
              _entrance.interval(0.3, 0.65),
              Text(
                context.l10n.welcomeBack,
                style: context.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            heightBox(20),
            _entrance.fadeSlideUp(
              _entrance.interval(0.34, 0.72),
              BlocBuilder<SignInBloc, SignInState>(
                buildWhen: (p, n) => p.email != n.email,
                builder: (context, state) => CustomTextFormField(
                  prefixIcon: Iconsax.sms,
                  label: context.l10n.email,
                  keyboardType: TextInputType.emailAddress,
                  hintText: context.l10n.enterYourEmail,
                  focusNode: _emailFocusNode,
                  onFieldSubmitted: (_) => _passwordFocusNode.requestFocus(),
                  onChanged: (email) =>
                      context.read<SignInBloc>().add(EmailChangedEvent(email)),
                ),
              ),
            ),
            heightBox(14),
            _entrance.fadeSlideUp(
              _entrance.interval(0.42, 0.8),
              BlocBuilder<SignInBloc, SignInState>(
                buildWhen: (p, n) => p.password != n.password,
                builder: (context, state) => CustomTextFormField(
                  onChanged: (password) => context.read<SignInBloc>().add(
                    PasswordChangedEvent(password),
                  ),
                  obscureText: true,
                  prefixIcon: Iconsax.lock,
                  label: context.l10n.password,
                  hintText: context.l10n.enterYourPassword,
                  keyboardType: TextInputType.visiblePassword,
                  focusNode: _passwordFocusNode,
                ),
              ),
            ),
            heightBox(18),
            _entrance.fadeSlideUp(
              _entrance.interval(0.58, 0.94),
              BlocBuilder<SignInBloc, SignInState>(
                buildWhen: (p, n) => p.apiStatus != n.apiStatus,
                builder: (context, state) => CustomButton(
                  isLoading: state.apiStatus == ApiStatus.LOADING,
                  label: context.l10n.signInBtn,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      context.read<SignInBloc>().add(SignInSubmitted());
                    }
                  },
                  radius: 14,
                  height: 54,
                ),
              ),
            ),
            heightBox(20),
            _entrance.fadeSlideUp(
              _entrance.interval(0.6, 0.96),
              const SocialSignInButtons(),
            ),
            heightBox(16),
          ],
        ),
      ),
    );
  }

}

class _LogoCard extends StatelessWidget {
  const _LogoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandTeal.withValues(alpha: 0.2),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const AppLogo(),
    );
  }
}
