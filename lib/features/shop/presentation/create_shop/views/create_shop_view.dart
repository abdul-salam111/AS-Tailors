import 'package:flutter/material.dart';
import '../../../../../core/constants/app_enums.dart';
import '../../../../../core/di/di_exports.dart';
import '../../../../../core/services/session_manager.dart';
import '../../../../../core/shared/shared_exports.dart';
import '../../../../../core/utils/utils_exports.dart';
import '../../../../../core/widgets/widgets_exports.dart';
import '../../../../../routes/routes_exports.dart';
import '../blocs/create_shop_bloc.dart';
import '../blocs/create_shop_event.dart';
import '../blocs/create_shop_state.dart';

/// Shown once, right after sign-up/sign-in, to whoever has no shop
/// membership yet. For the very first account this is the UI side of SRS
/// §3's "controlled setup process" (see `bootstrap_shop()` in
/// `supabase/migrations/0001_identity_and_shops.sql`); for every account
/// after that, [CreateShopInitialized] auto-joins the existing shop as
/// staff instead (`join_existing_shop()` in
/// `supabase/migrations/0004_join_existing_shop.sql`) and this form never
/// actually renders.
class CreateShopView extends StatelessWidget {
  const CreateShopView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CreateShopBloc>()..add(CreateShopInitialized()),
      child: const _CreateShopBody(),
    );
  }
}

class _CreateShopBody extends StatefulWidget {
  const _CreateShopBody();

  @override
  State<_CreateShopBody> createState() => _CreateShopBodyState();
}

class _CreateShopBodyState extends State<_CreateShopBody> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateShopBloc, CreateShopState>(
      listener: (context, state) {
        if (state.apiStatus == ApiStatus.SUCCESS && state.shop != null) {
          final shop = state.shop!;
          final sessionController = sl<SessionController>();
          sessionController.setSession(
            sessionController.session.copyWith(shopId: shop.id, role: state.role),
          );
          AppToastsUtils.showSuccessTop(
            context,
            state.role == ShopRole.owner
                ? context.l10n.shopCreatedSuccessfully
                : context.l10n.joinedShopSuccessfully,
          );
          context.go(RoutePaths.home);
        }
        if (state.apiStatus == ApiStatus.FAILURE && state.failure != null && !state.autoJoinFailed) {
          final error = AppFailureMapper.map(state.failure!);
          AppToastsUtils.showErrorTop(context, error.message);
        }
      },
      builder: (context, state) {
        if (state.isInitializing) {
          return const Scaffold(body: Center(child: LoadingIndicator()));
        }
        if (state.autoJoinFailed && state.failure != null) {
          return Scaffold(
            body: ErrorStateWidget(
              message: AppFailureMapper.map(state.failure!).message,
              onRetry: () => context.read<CreateShopBloc>().add(CreateShopInitialized()),
            ),
          );
        }
        return UnfocusWrapper(
          child: Scaffold(
            appBar: CustomAppBar(
              title: context.l10n.createShop,
              automaticallyImplyLeading: false,
              actions: const [LanguageToggleButton(), ThemeToggleButton()],
            ),
            body: Center(
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    const AppLogo(),
                    heightBox(context.screenHeight * 0.08),
                    CustomTextFormField(
                      prefixIcon: Iconsax.shop,
                      label: context.l10n.shopName,
                      hintText: context.l10n.enterYourShopName,
                      validator: Validator.validateRequired,
                      onChanged: (name) =>
                          context.read<CreateShopBloc>().add(ShopNameChangedEvent(name)),
                    ),
                    heightBox(context.screenHeight * 0.05),
                    CustomButton(
                      isLoading: state.apiStatus == ApiStatus.LOADING,
                      label: context.l10n.createShopBtn,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<CreateShopBloc>().add(CreateShopSubmitted());
                        }
                      },
                      radius: 10,
                    ),
                  ],
                ),
              ).withPadding(const EdgeInsets.symmetric(horizontal: 16)),
            ),
          ),
        );
      },
    );
  }
}
