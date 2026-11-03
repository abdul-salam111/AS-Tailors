import 'package:flutter/material.dart';
import '../../../../../core/constants/const_exports.dart';
import '../../../../../core/shared/shared_exports.dart';
import '../../../../../core/di/di_exports.dart';
import '../../../../../core/widgets/widgets_exports.dart';
import '../../../../../core/utils/utils_exports.dart';
import '../../../../../routes/routes_exports.dart';
import '../blocs/signin_bloc.dart';
import '../blocs/signin_event.dart';
import '../blocs/signin_state.dart';



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

/// Private body widget — owns the [GlobalKey<FormState>] which must
/// survive rebuilds, hence [StatefulWidget] is appropriate here.
class _SignInBody extends StatefulWidget {
  const _SignInBody();

  @override
  State<_SignInBody> createState() => _SignInBodyState();
}

class _SignInBodyState extends State<_SignInBody> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignInBloc, SignInState>(
      listener: (context, state) {
        if (state.apiStatus == ApiStatus.SUCCESS) {
          AppToastsUtils.showSuccessTop(
            context,
            context.l10n.youHaveLoggedInSuccessfully,
          );
        }
        if (state.apiStatus == ApiStatus.FAILURE && state.failure != null) {
          final error = AppFailureMapper.map(state.failure!);
          switch (error.display) {
            case ErrorDisplay.dialog:
              showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(context.l10n.signIn),
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
            appBar: CustomAppBar(title: context.l10n.signIn),
            body: Center(
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    const AppLogo(),
                    heightBox(context.screenHeight * 0.1),
                    BlocBuilder<SignInBloc, SignInState>(
                      buildWhen: (p, n) => p.email != n.email,
                      builder: (context, state) {
                        return CustomTextFormField(
                          prefixIcon: Iconsax.sms,
                          label: context.l10n.email,
                          keyboardType: TextInputType.emailAddress,
                          hintText: context.l10n.enterYourEmail,
                          onChanged: (email) {
                            context.read<SignInBloc>().add(
                              EmailChangedEvent(email),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    BlocBuilder<SignInBloc, SignInState>(
                      buildWhen: (p, n) => p.password != n.password,
                      builder: (context, state) {
                        return CustomTextFormField(
                          onChanged: (password) {
                            context.read<SignInBloc>().add(
                              PasswordChangedEvent(password),
                            );
                          },
                          obscureText: true,
                          prefixIcon: Iconsax.lock,
                          label: context.l10n.password,
                          hintText: context.l10n.enterYourPassword,
                          keyboardType: TextInputType.visiblePassword,
                        );
                      },
                    ),
                    heightBox(context.screenHeight * 0.05),
                    BlocBuilder<SignInBloc, SignInState>(
                      buildWhen: (p, n) => p.apiStatus != n.apiStatus,
                      builder: (context, state) {
                        return CustomButton(
                          isLoading: state.apiStatus == ApiStatus.LOADING,
                          label: context.l10n.signInBtn,
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              context.read<SignInBloc>().add(SignInSubmitted());
                            }
                          },
                          radius: 10,
                        );
                      },
                    ),
                    heightBox(16),
                    CustomButton.text(
                      label: context.l10n.dontHaveAnAccount,
                      onPressed: () => context.go(RoutePaths.signup),
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
