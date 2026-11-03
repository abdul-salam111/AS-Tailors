import 'package:flutter/material.dart';
import '../../../../../core/constants/const_exports.dart';
import '../../../../../core/di/di_exports.dart';
import '../../../../../core/shared/shared_exports.dart';
import '../../../../../core/theme/theme_exports.dart';
import '../../../../../core/utils/utils_exports.dart';
import '../../../../../core/widgets/widgets_exports.dart';
import '../../../../../routes/routes_exports.dart';
import '../../widgets/auth_gradient_background.dart';
import '../../widgets/entrance_choreography.dart';
import '../../widgets/social_sign_in_buttons.dart';
import '../blocs/signup_bloc.dart';
import '../blocs/signup_event.dart';
import '../blocs/signup_state.dart';

const _sheetExpandDuration = Duration(milliseconds: 320);
// How far below the status bar the sheet rests when nothing is focused —
// roughly the height of the back button + logo + title + subtitle hero
// it sits over.
const _sheetCollapsedOffset = 250.0;

/// Public entry point for the Sign-Up screen.
///
/// Public for now — whether this should stay public once there's an
/// owner, or gate to owner-created staff accounts only (SRS §3), is an
/// open product decision, deliberately not enforced here yet. See
/// `CheckShopExistsUsecase`
/// (`features/shop/domain/usecases/check_shop_exists_usecase.dart`) and
/// `supabase/migrations/0003_shop_exists.sql`, which are already built and
/// ready to wire back in once that's decided.
class SignUpView extends StatelessWidget {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => sl<SignupBloc>(), child: const _SignUpBody());
  }
}

/// Private body widget — owns the [GlobalKey<FormState>], the focus
/// nodes driving the sheet's expand/collapse animation, and the
/// staggered entrance choreography, hence [StatefulWidget] +
/// [TickerProviderStateMixin].
class _SignUpBody extends StatefulWidget {
  const _SignUpBody();

  @override
  State<_SignUpBody> createState() => _SignUpBodyState();
}

class _SignUpBodyState extends State<_SignUpBody> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  late final _entrance = EntranceChoreography(this);
  bool _isFormExpanded = false;

  @override
  void initState() {
    super.initState();
    _nameFocusNode.addListener(_handleFocusChange);
    _emailFocusNode.addListener(_handleFocusChange);
    _passwordFocusNode.addListener(_handleFocusChange);
    _confirmPasswordFocusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _nameFocusNode
      ..removeListener(_handleFocusChange)
      ..dispose();
    _emailFocusNode
      ..removeListener(_handleFocusChange)
      ..dispose();
    _passwordFocusNode
      ..removeListener(_handleFocusChange)
      ..dispose();
    _confirmPasswordFocusNode
      ..removeListener(_handleFocusChange)
      ..dispose();
    _entrance.dispose();
    super.dispose();
  }

  // The sheet expands to cover the hero while any field is focused, and
  // settles back down once focus clears (UnfocusWrapper's outside tap).
  void _handleFocusChange() {
    final expanded =
        _nameFocusNode.hasFocus ||
        _emailFocusNode.hasFocus ||
        _passwordFocusNode.hasFocus ||
        _confirmPasswordFocusNode.hasFocus;
    if (expanded != _isFormExpanded) {
      setState(() => _isFormExpanded = expanded);
    }
  }

  @override
  Widget build(BuildContext context) {
    return UnfocusWrapper(
      child: Scaffold(
        body: BlocListener<SignupBloc, SignupState>(
          listenWhen: (previous, current) => previous.apiStatus != current.apiStatus,
          listener: (context, state) {
            if (state.apiStatus == ApiStatus.SUCCESS) {
              AppToastsUtils.showSuccessTop(context, context.l10n.youHaveSignedUpSuccessfully);
              context.go(RoutePaths.signin);
            }
            if (state.apiStatus == ApiStatus.FAILURE && state.failure != null) {
              AppToastsUtils.showErrorTop(context, AppFailureMapper.map(state.failure!).message);
            }
          },
          child: Stack(
            children: [
              Positioned.fill(child: AuthGradientBackground(child: _buildHero(context))),
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
              child: const _LogoCard(),
            ),
            heightBox(18),
            _entrance.fadeSlideUp(
              titleAnim,
              Text(
                context.l10n.appName,
                style: context.headlineLarge.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            heightBox(8),
            _entrance.fadeSlideUp(
              subtitleAnim,
              Text(
                context.l10n.signUpTagline,
                textAlign: TextAlign.center,
                style: context.bodyMedium.copyWith(color: context.textSecondary),
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
                context.l10n.createYourAccount,
                style: context.headlineSmall.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            heightBox(20),
            _entrance.fadeSlideUp(
              _entrance.interval(0.34, 0.72),
              BlocBuilder<SignupBloc, SignupState>(
                buildWhen: (p, n) => p.name != n.name,
                builder: (context, state) => CustomTextFormField(
                  prefixIcon: Iconsax.user,
                  label: context.l10n.name,
                  keyboardType: TextInputType.name,
                  hintText: context.l10n.enterYourName,
                  validator: Validator.validateName,
                  focusNode: _nameFocusNode,
                  onFieldSubmitted: (_) => _emailFocusNode.requestFocus(),
                  onChanged: (name) => context.read<SignupBloc>().add(NameChangedEvent(name)),
                ),
              ),
            ),
            heightBox(14),
            _entrance.fadeSlideUp(
              _entrance.interval(0.38, 0.76),
              BlocBuilder<SignupBloc, SignupState>(
                buildWhen: (p, n) => p.email != n.email,
                builder: (context, state) => CustomTextFormField(
                  prefixIcon: Iconsax.sms,
                  label: context.l10n.email,
                  keyboardType: TextInputType.emailAddress,
                  hintText: context.l10n.enterYourEmail,
                  validator: Validator.validateEmail,
                  focusNode: _emailFocusNode,
                  onFieldSubmitted: (_) => _passwordFocusNode.requestFocus(),
                  onChanged: (email) =>
                      context.read<SignupBloc>().add(SignupEmailChangedEvent(email)),
                ),
              ),
            ),
            heightBox(14),
            _entrance.fadeSlideUp(
              _entrance.interval(0.42, 0.8),
              BlocBuilder<SignupBloc, SignupState>(
                buildWhen: (p, n) => p.password != n.password,
                builder: (context, state) => CustomTextFormField(
                  onChanged: (password) =>
                      context.read<SignupBloc>().add(SignupPasswordChangedEvent(password)),
                  obscureText: true,
                  prefixIcon: Iconsax.lock,
                  label: context.l10n.password,
                  hintText: context.l10n.enterYourPassword,
                  keyboardType: TextInputType.visiblePassword,
                  focusNode: _passwordFocusNode,
                  onFieldSubmitted: (_) => _confirmPasswordFocusNode.requestFocus(),
                  validator: Validator.validatePassword,
                ),
              ),
            ),
            heightBox(14),
            _entrance.fadeSlideUp(
              _entrance.interval(0.46, 0.84),
              BlocBuilder<SignupBloc, SignupState>(
                buildWhen: (p, n) =>
                    p.confirmPassword != n.confirmPassword || p.password != n.password,
                builder: (context, state) => CustomTextFormField(
                  onChanged: (confirmPassword) =>
                      context.read<SignupBloc>().add(ConfirmPasswordChangedEvent(confirmPassword)),
                  obscureText: true,
                  prefixIcon: Iconsax.lock,
                  label: context.l10n.confirmPassword,
                  hintText: context.l10n.enterYourConfirmPassword,
                  keyboardType: TextInputType.visiblePassword,
                  focusNode: _confirmPasswordFocusNode,
                  validator: (value) => Validator.validatePasswordMatch(value, state.password),
                ),
              ),
            ),
            heightBox(24),
            _entrance.fadeSlideUp(
              _entrance.interval(0.58, 0.94),
              BlocBuilder<SignupBloc, SignupState>(
                buildWhen: (p, n) => p.apiStatus != n.apiStatus,
                builder: (context, state) => CustomButton(
                  isLoading: state.apiStatus == ApiStatus.LOADING,
                  label: context.l10n.signUpBtn,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      context.read<SignupBloc>().add(SignupSubmitted());
                    }
                  },
                  radius: 14,
                  height: 54,
                ),
              ),
            ),
            heightBox(20),
            _entrance.fadeSlideUp(_entrance.interval(0.6, 0.96), const SocialSignInButtons()),
            heightBox(20),
            _entrance.fadeSlideUp(_entrance.interval(0.64, 1.0), _buildLoginLink(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginLink(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(context.l10n.alreadyHaveAnAccount, style: context.bodySmall),
          TextButton(
            onPressed: () => context.go(RoutePaths.signin),
            child: Text(
              context.l10n.signIn,
              style: context.bodySmall.copyWith(
                color: context.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoCard extends StatelessWidget {
  const _LogoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 76,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
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
