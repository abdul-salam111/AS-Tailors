import 'package:flutter/material.dart';
import '../../../../../core/constants/const_exports.dart';
import '../../../../../core/shared/shared_exports.dart';
import '../../../../../core/di/di_exports.dart';
import '../../../../../core/widgets/widgets_exports.dart';
import '../../../../../core/utils/utils_exports.dart';
import '../../../../../routes/routes_exports.dart';
import '../blocs/signup_bloc.dart';
import '../blocs/signup_event.dart';
import '../blocs/signup_state.dart';

/// Public entry point for the Sign-Up screen.
/// Provides [SignupBloc] to the subtree and delegates UI to [_SignUpBody].
class SignUpView extends StatelessWidget {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => sl<SignupBloc>(), child: const _SignUpBody());
  }
}

/// Private body widget — owns the [GlobalKey<FormState>] which must
/// survive rebuilds, hence [StatefulWidget] is appropriate here.
class _SignUpBody extends StatefulWidget {
  const _SignUpBody();

  @override
  State<_SignUpBody> createState() => _SignUpBodyState();
}

class _SignUpBodyState extends State<_SignUpBody> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignupBloc, SignupState>(
      listener: (context, state) {
        if (state.apiStatus == ApiStatus.SUCCESS) {
          AppToastsUtils.showSuccessTop(context, context.l10n.youHaveSignedUpSuccessfully);
          context.go(RoutePaths.signin);
        }
        if (state.apiStatus == ApiStatus.FAILURE && state.failure != null) {
          final error = AppFailureMapper.map(state.failure!);
          switch (error.display) {
            case ErrorDisplay.dialog:
              showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(context.l10n.signUp),
                  content: Text(error.message),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            case ErrorDisplay.toast:
            case ErrorDisplay.inline:
            case ErrorDisplay.fullScreen:
              AppToastsUtils.showErrorTop(context, error.message);
          }
        }
      },
      builder: (context, state) {
        return UnfocusWrapper(
          child: Scaffold(
            appBar: CustomAppBar(
              title: context.l10n.signUp,
              actions: const [LanguageToggleButton(), ThemeToggleButton()],
            ),
            body: Center(
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    const AppLogo(),
                    heightBox(context.screenHeight * 0.08),
                    BlocBuilder<SignupBloc, SignupState>(
                      buildWhen: (p, n) => p.name != n.name,
                      builder: (context, state) {
                        return CustomTextFormField(
                          prefixIcon: Iconsax.user,
                          label: context.l10n.name,
                          keyboardType: TextInputType.name,
                          hintText: context.l10n.enterYourName,
                          validator: Validator.validateName,
                          onChanged: (name) {
                            context.read<SignupBloc>().add(NameChangedEvent(name));
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    BlocBuilder<SignupBloc, SignupState>(
                      buildWhen: (p, n) => p.email != n.email,
                      builder: (context, state) {
                        return CustomTextFormField(
                          prefixIcon: Iconsax.sms,
                          label: context.l10n.email,
                          keyboardType: TextInputType.emailAddress,
                          hintText: context.l10n.enterYourEmail,
                          validator: Validator.validateEmail,
                          onChanged: (email) {
                            context.read<SignupBloc>().add(SignupEmailChangedEvent(email));
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    BlocBuilder<SignupBloc, SignupState>(
                      buildWhen: (p, n) => p.password != n.password,
                      builder: (context, state) {
                        return CustomTextFormField(
                          onChanged: (password) {
                            context.read<SignupBloc>().add(SignupPasswordChangedEvent(password));
                          },
                          obscureText: true,
                          prefixIcon: Iconsax.lock,
                          label: context.l10n.password,
                          hintText: context.l10n.enterYourPassword,
                          keyboardType: TextInputType.visiblePassword,
                          validator: Validator.validatePassword,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    BlocBuilder<SignupBloc, SignupState>(
                      buildWhen: (p, n) =>
                          p.confirmPassword != n.confirmPassword || p.password != n.password,
                      builder: (context, state) {
                        return CustomTextFormField(
                          onChanged: (confirmPassword) {
                            context.read<SignupBloc>().add(
                              ConfirmPasswordChangedEvent(confirmPassword),
                            );
                          },
                          obscureText: true,
                          prefixIcon: Iconsax.lock,
                          label: context.l10n.confirmPassword,
                          hintText: context.l10n.enterYourConfirmPassword,
                          keyboardType: TextInputType.visiblePassword,
                          validator: (value) =>
                              Validator.validatePasswordMatch(value, state.password),
                        );
                      },
                    ),
                    heightBox(context.screenHeight * 0.05),
                    BlocBuilder<SignupBloc, SignupState>(
                      buildWhen: (p, n) => p.apiStatus != n.apiStatus,
                      builder: (context, state) {
                        return CustomButton(
                          isLoading: state.apiStatus == ApiStatus.LOADING,
                          label: context.l10n.signUpBtn,
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              context.read<SignupBloc>().add(SignupSubmitted());
                            }
                          },
                          radius: 10,
                        );
                      },
                    ),
                    heightBox(16),
                    CustomButton.text(
                      label: context.l10n.alreadyHaveAnAccount,
                      onPressed: () => context.go(RoutePaths.signin),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
