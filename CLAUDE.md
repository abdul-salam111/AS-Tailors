# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

> **Role:** Senior Flutter developer, architect, and team lead.

---

## 1. STACK

| Concern | Library |
|---|---|
| Architecture | Clean Architecture (Domain / Data / Presentation) |
| State management | flutter_bloc (`Bloc`, `Cubit`) |
| DI | GetIt service locator (`sl`) |
| Navigation | go_router (`GoRouter`, `GoRoute`) |
| Backend | Supabase (`supabase_flutter`) — Postgres + Auth + Storage + RLS; client registered as `sl<SupabaseClient>()`, see §1a |
| HTTP | Dio via `DioHelper` + `BaseRemoteDatasource` (legacy template REST layer — see §1a) |
| Models | Freezed + json_serializable |
| Error handling | fpdart `Either<Failure, T>` |
| Storage | `flutter_secure_storage` via `LocalStorage` singleton |
| Toasts | `another_flushbar` via `AppToastsUtils` |
| Caching | `dio_cache_interceptor` (in-memory, 7-day stale) |
| Secrets | `envied` — `.env` → obfuscated `Env` class, see SECRETS.txt |
| Localization | `flutter_localizations` + ARB files, see §13a |
| Scaffold | Mason CLI bricks |

---

## 1a. PRODUCT CONTEXT — AS Tailors SRS v1.3

This is a tailoring-shop management app, not a generic starter. Full spec:
`docs/AS_Tailors_Complete_SRS_Feature_Specification_v1.3.docx` (kept local
only, not committed to git). Summary for quick orientation:

- **Product**: single-shop tailoring business OS. Phase 1 ships one app —
  "AS Tailors Business" (this repo) — used by the owner and staff to manage
  customers, measurements, garment orders, payments, thermal-printed
  receipts and reports. A separate customer-facing app is Phase 2 and out
  of scope here.
- **Backend**: Supabase (Postgres + Auth + Storage + Realtime + RPC/Edge
  Functions), one shared project, RLS enabled on every table. **Not** a
  generic REST API — see the gap list below before assuming the Dio
  patterns elsewhere in this file apply to real business features.
- **Domain shape**: `shops` → `shop_members` (role: owner/admin/tailor/
  staff) → `customers` → `measurement_profiles`/`measurement_values`
  (versioned, template-driven per garment category) → `orders`/
  `order_items` (immutable price + measurement snapshots) → `payments`/
  `refunds`/`receipts` → `print_jobs`. Garment categories at launch:
  Shalwar Kameez, Shirts. Currency: PKR. Languages: English + Urdu (RTL).
- **Hard rules worth remembering**: money is `NUMERIC(12,2)`, never float;
  totals/balances are server-recalculated, never client-submitted;
  payments use idempotency keys; order/measurement/price snapshots are
  immutable once attached to an order; `shop_id` scoping + RLS is the
  access-control boundary, not client-side filtering; offline support is
  drafts + cached reads only — unconfirmed payments are never shown as
  "received."
- **Brand identity (§27 of the SRS)** is already applied: the teal/gold/
  charcoal/ivory palette lives in `AppColors.brand*` (`core/theme/
  colors.dart`) and is used on the splash screen. The approved logo PNG
  (`assets/icons/logo.png`) must stay pixel-unmodified — no added glow/
  shadow/slogans, per the SRS usage guidance.

### Where this codebase diverges from the SRS today

The repo currently has the generic Flutter-template architecture (Dio/
REST, custom Bearer-token auth) from before the SRS existed. That's fine
as scaffolding, but it is **not** the target architecture for real AS
Tailors features. Resolve these before building customer/order/payment
screens — confirmed by inspection, not assumption:

1. **Backend**: §9 (Network Layer) and the §5 "Adding a Feature" walkthrough
   still teach a Dio + `BaseRemoteDatasource` REST pattern. The SRS stack
   (§8.1) calls for `supabase_flutter` as the primary data/auth SDK, with
   Dio reserved for non-Supabase HTTP only. **Partially resolved**:
   `Supabase.initialize(url: Env.supabaseUrl, publishableKey:
   Env.supabasePublishableKey)` now runs in `main()` before
   `setupLocator()`, and `core/di/register_supabase.dart` registers
   `sl<SupabaseClient>()` (credentials added via `.env` +
   `Env.supabaseUrl`/`Env.supabasePublishableKey`, following the usual
   envied flow — see SECRETS.txt). **Still open**: no datasource yet
   actually queries Supabase — the real per-feature pattern (direct
   `supabase.from()/rpc()` calls, likely wrapped in a thin
   `SupabaseRemoteDatasource` analogous to `BaseRemoteDatasource`) still
   needs to be designed before scaffolding the first real feature with
   `mason make create_feature`.
2. **Auth**: `AuthInterceptor` + `SessionController`
   (`core/services/session_manager.dart`) hand-roll Bearer-token storage
   via `flutter_secure_storage`. Supabase Auth issues/refreshes its own
   session and `supabase_flutter` persists it internally — the existing
   `auth` feature (sign in/up usecases hitting a generic `/auth` REST
   endpoint) will need rebuilding against `Supabase.instance.client.auth`,
   not patching.
3. **Authorization/roles**: `AppRoutes.router`'s redirect guard only checks
   `SessionController.isLoggedIn` (boolean). The SRS requires per-role
   access (owner/admin/tailor/staff — §3, §11.1); `SessionEntity` has no
   role field yet and there's no route/widget-level permission gating.
4. **Localization**: ARB files are `app_en.arb` + `app_es.arb` (Spanish) —
   a template leftover. The SRS requires English + **Urdu**, including RTL
   layout and Urdu receipt-font testing (FR-014). Swap `app_es.arb` for
   `app_ur.arb` before any real localized copy is written.
5. **Offline/local persistence**: §15 wants cached reads, local order
   drafts and a sync queue (`local_id`/`server_id`/`sync_status`/
   `idempotency_key`/`retry_count`). Nothing in the current stack provides
   structured local storage — `flutter_secure_storage` is key-value only.
   `ConnectivityCubit`/`ConnectivityBanner` (§7b) only signal online/
   offline; they don't queue writes. A local DB (SRS suggests Drift or
   sqflite) is needed before offline drafts can be built.
6. **Printing**: no `core/printer` module, no ESC/POS package, nothing in
   DI. §14 is a whole subsystem (Bluetooth discovery/pairing, 58mm/80mm
   layouts, Urdu glyph rendering, print-job status tracked separately from
   receipt generation) that doesn't exist yet.
7. **Money as floating point**: `currency_utils.dart`'s formatters operate
   on `num`/`double`. That's fine for *display* formatting, but once real
   order/payment totals are implemented, do the arithmetic (subtotal/
   discount/balance) server-side (Postgres `NUMERIC`) and treat
   client-side values as display-only — never accumulate money in
   `double` across multiple operations.
8. **Multi-tenancy**: every table in §9 is `shop_id`-scoped behind RLS.
   There's no shop-scoping convention established yet in this codebase
   (the template's single-tenant "product" example has no owner/shop
   concept) — new repositories should rely on RLS rather than
   re-implementing shop filtering client-side.

None of the above blocks small UI/branding work. The first real domain
feature (customers, most likely) should resolve #1 and #2 first —
everything else (orders, payments, printing) builds on that foundation.

---

## 2. COMMANDS

```bash
# Run
flutter run

# Lint
flutter analyze

# Tests
flutter test
flutter test test/unit/features/auth/domain/signin_usecase_test.dart  # single file

# Code generation (Freezed models)
dart run build_runner build --delete-conflicting-outputs
dart run build_runner watch --delete-conflicting-outputs

# Format & fix
dart format lib/ --line-length 100
dart fix --apply

# Mason scaffolding
mason make create_feature      # full feature scaffold (data + domain + presentation + DI)
mason make add_screen           # add screen to existing feature
mason make remove_screen        # inverse of add_screen
mason make remove_feature       # inverse of create_feature
mason make add_firebase         # drop-in Firebase Auth alternative (not auto-activated)
mason make remove_firebase      # inverse of add_firebase
mason make flutter_architecture # generate full project folder structure from scratch
mason make asset_generator      # regenerate asset constants after adding images/icons
mason make export_generator     # regenerate barrel exports
mason make add_constant         # add a constant to core/constants/
```

**`bricks/create_feature` and `bricks/add_screen` generate slightly
different shapes for an existing feature's datasource/repository**:
`add_screen` matches the real hand-written `auth` feature (I-prefixed
interfaces, `data/datasources/<feature>_remote_datasource/<feature>_remote_datasource.dart`),
while `create_feature` generates a flat
`data/datasources/remote_<feature>_datasource.dart` with different
class names (no I-prefix on the repository interface, reversed word
order on the datasource interface). This is a pre-existing inconsistency
between the two bricks, not something recently introduced — worth fixing
eventually, but `remove_screen`/`remove_feature` were built to tolerate
either shape (discovering actual on-disk structure rather than assuming
one specific naming) rather than silently picking a side.

**`bricks/add_page`/`remove_page` don't exist on this branch** — this
branch calls the concept "screen" (`add_screen`/`remove_screen`), not
"page." Five stray, untracked, content-free `bricks/*/hooks/.dart_tool/`
cache directories (`add_firebase`, `add_page`, `remove_feature`,
`remove_firebase`, `remove_page`) were found and removed before building
the real `remove_screen`/`remove_feature`/`add_firebase`/`remove_firebase`
bricks — they were never in git, just leftover `mason new` scaffolding
with no `brick.yaml` or hook source.

### Multi-environment builds & secrets
Full pattern — `.env` setup, the `Env` class, adding a new secret, CI, and
`--dart-define` for non-secret flavor flags — lives in **[SECRETS.txt](SECRETS.txt)**.
Short version: `cp .env.example .env`, fill in real values, then
`dart run build_runner build --delete-conflicting-outputs`.

---

## 3. DIRECTORY STRUCTURE

```
lib/
├── main.dart                         # Entry: setupLocator() → Bloc.observer → BlocProvider<ThemeBloc>
├── core/
│   ├── constants/                    # API endpoints, app constants, enums (ApiStatus), icons/images
│   │   ├── env.dart                  # @Envied secrets class — committed, see SECRETS.txt
│   │   └── env.g.dart                # generated, gitignored (embeds local .env values)
│   ├── di/
│   │   ├── app_dependencies.dart     # setupLocator() orchestrator + global `sl` GetIt instance
│   │   ├── register_network.dart     # Dio + DioHelper (with DioCacheInterceptor)
│   │   ├── register_core.dart        # LocalStorage, SessionController, ConnectivityService
│   │   ├── register_splash.dart      # SplashCubit
│   │   ├── register_auth.dart        # Auth DS → Repo → Usecase → Bloc (factory)
│   │   └── register_supabase.dart    # sl<SupabaseClient>() — needs Supabase.initialize() called first in main()
│   ├── local_storage/storage.dart    # LocalStorage singleton + StorageKeys
│   ├── networks/
│   │   ├── exceptions/app_exceptions.dart  # AppException hierarchy
│   │   ├── interceptors/auth_interceptor.dart
│   │   └── network_manager/dio_helper.dart  # HTTP verbs; useAppToken flag
│   ├── services/
│   │   ├── session_manager.dart      # SessionController (plain Dart, DI via GetIt)
│   │   ├── session_entity.dart
│   │   ├── splash_services.dart
│   │   ├── connectivity_service.dart # Thin wrapper over internet_connection_checker_plus
│   │   └── connectivity_cubit.dart   # App-wide online/offline Cubit<bool>, drives ConnectivityBanner
│   ├── shared/
│   │   ├── datasource/base_datasource.dart   # BaseRemoteDatasource (typed HTTP helpers)
│   │   ├── domain/
│   │   │   ├── failures/failure.dart         # Failure hierarchy (pure Dart)
│   │   │   ├── repository/base_repository.dart  # BaseRepository.execute() error wrapper
│   │   │   ├── usecases/usecase.dart         # Usecase<SuccessType, Params> interface + NoParams
│   │   │   └── usecases/pagination_params.dart   # PaginationParams(page, limit) for paginated usecases
│   │   ├── presentation/
│   │   │   ├── bloc_observer/app_bloc_observer.dart
│   │   │   ├── mixins/usecase_executer_mixin.dart  # UsecaseExecuterMixin for Bloc
│   │   │   └── pagination/                   # PaginationCubit<T> + PaginationState<T>, see §7a
│   │   └── shared_exports.dart       # Re-exports equatable, flutter_bloc, fpdart, base classes
│   ├── theme/
│   │   ├── theme.dart                # AppThemes (light/dark ThemeData)
│   │   ├── colors.dart               # AppColors
│   │   ├── theme_utils.dart          # BuildContext extensions (context.primary, context.bodyMedium…)
│   │   └── theme_bloc/               # ThemeBloc, ThemeEvent, ThemeState
│   ├── utils/
│   │   ├── apptoast_utils.dart       # AppToastsUtils (requires BuildContext)
│   │   ├── failure_mapper.dart       # AppFailureMapper → UserFacingError + ErrorDisplay
│   │   ├── extensions.dart           # heightBox / widthBox + misc
│   │   ├── widget_utils.dart         # Chainable Widget extensions
│   │   ├── validators.dart           # Validator.*
│   │   ├── date_utils.dart           # DateTimeExtensions, DurationExtensions, StringToDateTime
│   │   ├── currency_utils.dart       # CurrencyFormatting, StringToNumber extensions on num/String
│   │   ├── math_utils.dart           # PercentageFormatting, DecimalFormatting, FileSizeFormatting
│   │   └── type_conversion.dart      # safeToInt/Double/String/Bool/List/Map/DateTime/Color/Enum…
│   └── widgets/                      # Reusable UI components
├── features/
│   └── <feature>/
│       ├── <feature>_exports.dart    # Barrel export
│       ├── data/
│       │   ├── datasources/          # Extends BaseRemoteDatasource
│       │   ├── models/{request_models,response_models}/   # Freezed
│       │   └── repositories_impl/   # Extends BaseRepository
│       ├── domain/
│       │   ├── entities/
│       │   ├── repositories/         # Abstract interfaces
│       │   └── usecases/             # Implements Usecase<T, P>
│       └── presentation/<screen>/
│           ├── blocs/                # Bloc + events + state  (or cubit/ for Cubit)
│           └── views/
├── l10n/                             # ARB source files + generated/, see §13a
│   ├── app_en.arb
│   ├── app_es.arb
│   └── generated/
└── routes/
    ├── route_names.dart              # RouteNames string constants (named routes)
    ├── route_paths.dart              # RoutePaths string constants (URL paths)
    └── routes.dart                   # AppRoutes.router (GoRouter with redirect guard)
```

---

## 4. ARCHITECTURE RULES

**Layer dependency direction:** `Presentation → Domain ← Data`, `Core` shared by all.

1. **Domain** — pure Dart only. No Flutter, Dio, GetIt, or BLoC imports.
2. **Data** — implements Domain interfaces; uses Freezed models; extends `BaseRepository` for error mapping.
3. **Presentation** — imports Domain only. Never imports Data. Uses `BlocProvider`/`BlocConsumer`/`BlocBuilder`.
4. **Core** — no feature-specific imports.

All repository methods return `Future<Either<Failure, T>>`.

---

## 5. ADDING A FEATURE

### Step 1: Domain
```dart
// entities/product_entity.dart
class ProductEntity { final String id; final String name; ... }

// repositories/i_product_repository.dart
abstract class IProductRepository {
  Future<Either<Failure, ProductEntity>> getProduct(String id);
}

// usecases/get_product_usecase.dart
class GetProductUsecase implements Usecase<ProductEntity, String> {
  final IProductRepository _repo;
  GetProductUsecase({required IProductRepository repository}) : _repo = repository;

  @override
  Future<Either<Failure, ProductEntity>> call(String id) => _repo.getProduct(id);
}
```

### Step 2: Data — Freezed model
```dart
@freezed
class ProductModel with _$ProductModel {
  const factory ProductModel({
    required String id,
    @JsonKey(name: 'product_name') required String name,
  }) = _ProductModel;
  factory ProductModel.fromJson(Map<String, dynamic> json) => _$ProductModelFromJson(json);
}
```
Run: `dart run build_runner build --delete-conflicting-outputs`

### Step 3: Data — Datasource & Repository
```dart
// Datasource extends BaseRemoteDatasource — use typed helpers instead of DioHelper directly
class ProductRemoteDatasourceImpl extends BaseRemoteDatasource
    implements IProductRemoteDatasource {
  const ProductRemoteDatasourceImpl({required super.dioHelper});

  @override
  Future<ProductModel> getProduct(String id) => get(
        url: ApiEndPoints.product(id),
        parser: (data) => ProductModel.fromJson(data as Map<String, dynamic>),
      );
}

// Repository extends BaseRepository — execute() handles AppException → Failure mapping
class ProductRepositoryImpl extends BaseRepository implements IProductRepository {
  final IProductRemoteDatasource _ds;
  ProductRepositoryImpl({required IProductRemoteDatasource dataSource}) : _ds = dataSource;

  @override
  Future<Either<Failure, ProductEntity>> getProduct(String id) => execute(
        call: () async {
          final model = await _ds.getProduct(id);
          return ProductEntity(id: model.id, name: model.name);
        },
      );
}
```

### Step 4: BLoC
```dart
// State — extend Equatable, not Freezed
class ProductState extends Equatable {
  final ProductEntity? product;
  final ApiStatus apiStatus;
  final String? message;
  final Failure? failure;
  const ProductState({
    this.product,
    this.apiStatus = ApiStatus.INITIAL,
    this.message,
    this.failure,
  });

  ProductState copyWith({...}) => ProductState(...);

  @override
  List<Object?> get props => [product, apiStatus, message, failure];
}

// Events
abstract class ProductEvent {}
class FetchProductEvent extends ProductEvent { final String id; FetchProductEvent(this.id); }

// BLoC — use UsecaseExecuterMixin for standard load/success/failure flows
class ProductBloc extends Bloc<ProductEvent, ProductState> with UsecaseExecuterMixin {
  final GetProductUsecase _usecase;
  ProductBloc({required GetProductUsecase getProductUsecase})
      : _usecase = getProductUsecase,
        super(const ProductState()) {
    on<FetchProductEvent>(_onFetch);
  }

  Future<void> _onFetch(FetchProductEvent event, Emitter<ProductState> emit) =>
      executeUsecase(
        emit: emit,
        currentState: state,
        usecase: () => _usecase(event.id),
        stateBuilder: (status, {data, error, failure}) => state.copyWith(
          apiStatus: status,
          product: data,
          message: error,
          failure: failure,
        ),
      );
}
```

### Step 5: Register with GetIt
```dart
// core/di/register_product.dart
Future<void> registerProduct() async {
  sl.registerLazySingleton<IProductRemoteDatasource>(
    () => ProductRemoteDatasourceImpl(dioHelper: sl()),
  );
  sl.registerLazySingleton<IProductRepository>(
    () => ProductRepositoryImpl(dataSource: sl()),
  );
  sl.registerLazySingleton<GetProductUsecase>(
    () => GetProductUsecase(repository: sl()),
  );
  // Factory so each screen navigation gets a fresh BLoC instance
  sl.registerFactory<ProductBloc>(() => ProductBloc(getProductUsecase: sl()));
}
```
Call `await registerProduct()` inside `setupLocator()` in `app_dependencies.dart`.

### Step 6: View — provide BLoC via `BlocProvider`, consume via `BlocConsumer`
```dart
// Public screen entry — wraps private body
class ProductView extends StatelessWidget {
  const ProductView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProductBloc>()..add(FetchProductEvent('id')),
      child: const _ProductBody(),
    );
  }
}

// Private body — use StatefulWidget only when local state is needed (e.g. FormKey)
class _ProductBody extends StatelessWidget {
  const _ProductBody();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductBloc, ProductState>(
      listener: (context, state) {
        if (state.apiStatus == ApiStatus.SUCCESS) {
          AppToastsUtils.showSuccessTop(context, 'Loaded!');
        }
        if (state.apiStatus == ApiStatus.FAILURE) {
          AppToastsUtils.showErrorTop(context, state.message ?? 'Error');
        }
      },
      builder: (context, state) => ApiStatusBuilder<ProductEntity>(
        status: state.apiStatus,
        data: state.product,
        failure: state.failure,
        emptyWidget: const EmptyStateWidget(title: 'No product'),
        onRetry: () => context.read<ProductBloc>().add(FetchProductEvent('id')),
        builder: (context, product) => Text(product.name),
      ),
    );
  }
}
```

### Step 7: Route
```dart
// route_paths.dart
static const String product = '/product';

// route_names.dart
static const String product = 'product';

// routes.dart
GoRoute(
  path: RoutePaths.product,
  name: RouteNames.product,
  builder: (context, state) => const ProductView(),
),
```

---

## 6. DEPENDENCY INJECTION (GetIt)

| Scope | Method | Typical use |
|---|---|---|
| Network / Core | `sl.registerLazySingleton` | Dio, DioHelper, LocalStorage, SessionController |
| Data (DS/Repo/Usecase) | `sl.registerLazySingleton` | One instance app-wide |
| BLoC per screen | `sl.registerFactory` | Fresh instance each navigation |

Registration order per feature: DataSource → Repository → Usecase → Bloc.

Retrieve: `sl<T>()` or `sl.get<T>()`.

---

## 7. `UsecaseExecuterMixin` (BLoC helper)

Add `with UsecaseExecuterMixin` to a `Bloc` to get `executeUsecase`:

```dart
Future<void> _onEvent(MyEvent event, Emitter<MyState> emit) =>
    executeUsecase(
      emit: emit,
      currentState: state,
      usecase: () => _usecase(params),
      stateBuilder: (status, {data, error, failure}) =>
          state.copyWith(apiStatus: status, data: data, message: error, failure: failure),
    );
```

Emits `ApiStatus.LOADING` → then `ApiStatus.SUCCESS` (with `data`) or `ApiStatus.FAILURE`
(with both `error` — the plain message string — and `failure` — the original `Failure`
object, so listeners can run it through `AppFailureMapper` to pick a display strategy).
**Do not use this mixin** for pagination or multi-step/optimistic-update flows — pagination
has its own dedicated pattern below; other multi-step flows should be handled inline.

---

## 7a. Pagination (`PaginationCubit` + `PaginatedListView`)

Don't hand-roll page/hasReachedMax bookkeeping per feature — use the generic
`PaginationCubit<T>` (in `core/shared/shared_exports.dart`) paired with the
`PaginatedListView<T>` widget (in `core/widgets/widgets_exports.dart`).

```dart
// 1. Usecase takes PaginationParams, returns Either<Failure, List<T>>
class GetProductsUsecase implements Usecase<List<ProductEntity>, PaginationParams> {
  final IProductRepository _repo;
  GetProductsUsecase({required IProductRepository repository}) : _repo = repository;

  @override
  Future<Either<Failure, List<ProductEntity>>> call(PaginationParams params) =>
      _repo.getProducts(page: params.page, limit: params.limit);
}

// 2. Create the cubit where the screen is built (not registered in GetIt —
//    it closes over one usecase call, so build it per-screen)
final cubit = PaginationCubit<ProductEntity>(
  fetchPage: (page) => sl<GetProductsUsecase>()(PaginationParams(page: page)),
);

// 3. Drop it into the view — first page loads on mount, next page loads
//    automatically near the bottom of the scroll, loading/empty/error states
//    are handled for you
PaginatedListView<ProductEntity>(
  cubit: cubit,
  itemBuilder: (context, product) => ListTile(title: Text(product.name)),
)
```

Dispose the cubit (`cubit.close()`) in the screen's `dispose()`/`BlocProvider` teardown
the same as any other Bloc/Cubit you construct manually.

---

## 7b. Connectivity (offline banner)

`ConnectivityService` (in `core/services/connectivity_service.dart`) wraps
`internet_connection_checker_plus`. `ConnectivityCubit` (in
`core/services/connectivity_cubit.dart`) turns that into an app-wide
`Cubit<bool>` (`true` = offline) — it's provided once at the app root in
`main.dart`'s `MyApp` via `MultiBlocProvider`, alongside `ThemeBloc`.

`ConnectivityBanner` wraps `MaterialApp.router`'s `builder`, so a "No internet
connection" banner appears at the top of **every** screen automatically the
moment `ConnectivityCubit` reports offline, and disappears on reconnect — no
per-screen wiring needed. Don't add your own connectivity checks/banners in
individual features; read `context.watch<ConnectivityCubit>().state` if a
screen needs to react to connectivity itself (e.g. disable a submit button).

---

## 8. ROUTING (go_router)

```dart
// Navigate (push onto stack)
context.push(RoutePaths.product);
context.push(RoutePaths.product, extra: {'id': id});

// Replace current route
context.go(RoutePaths.home);

// Pop
context.pop();
context.pop(result);  // with return value

// Named navigation
context.goNamed(RouteNames.product);
context.pushNamed(RouteNames.product, queryParameters: {'id': id});

// Read extra in builder
final args = state.extra as Map<String, dynamic>;
```

`AppRoutes.router` has a `redirect` guard — checks `sl<SessionController>().isLoggedIn` and redirects unauthenticated users to `RoutePaths.signin`. Add new protected routes inside `routes` list; add public ones to `_publicRoutes`.

Never use `Navigator.push()`.

---

## 9. NETWORK LAYER

### `DioHelper` — low-level verbs
> **Parameter names are `url:` and `requestBody:`.**

```dart
_dio.getApi(url: ..., queryParameters: {...})
_dio.postApi(url: ..., requestBody: body)
_dio.putApi(url: ..., requestBody: body)
_dio.patchApi(url: ..., requestBody: body)
_dio.deleteApi(url: ...)
```

Pass `useAppToken: true` for public endpoints that need the static API key instead of the user Bearer token.

### `BaseRemoteDatasource` — preferred in datasources
```dart
// Single object
await get(url: ..., parser: (data) => Model.fromJson(data))
await post(url: ..., body: {...}, parser: (data) => Model.fromJson(data))
await put / patch / delete(...)

// List
await getList(url: ..., parser: (json) => Model.fromJson(json))

// File upload
await uploadFile(url: ..., fieldName: 'avatar', filePath: '/path/file.jpg')
await uploadMultipleFiles(url: ..., fieldName: 'files', filePaths: [...])
```

`AuthInterceptor` (`lib/core/networks/interceptors/auth_interceptor.dart`) only implements `onRequest` — it auto-attaches the `Bearer` token on every request (unless `useAppToken: true`, which injects a static app token instead). **It does not implement `onError`** — there is no automatic session-clear/logout on a 401 response anywhere in this codebase today. Don't assume 401 handling exists; if you need it, it has to be added.

Base URL and the static app token come from `Env.baseUrl`/`Env.appToken`
(`lib/core/constants/api_endpoints.dart`), sourced from `.env` — see SECRETS.txt.
Don't hardcode a URL directly in `ApiEndPoints`; set it in `.env` instead.

---

## 10. ERROR HANDLING CHAIN

```
DioException → AppException  (in DioHelper._handleDioError)
    → BaseRepository.execute() catches AppException → Left(Failure)
    → UsecaseExecuterMixin folds Either → emits ApiStatus.FAILURE with error message
    → BlocConsumer listener shows toast / dialog based on AppFailureMapper
```

**Failure types** (`core/shared/domain/failures/failure.dart`):
`AuthFailure`, `NetworkFailure`, `ServerFailure`, `ValidationFailure`,
`NotFoundFailure`, `RateLimitFailure`, `UnexpectedFailure`

**`AppFailureMapper`** (`core/utils/failure_mapper.dart`) maps a `Failure` to `UserFacingError`:
```dart
final error = AppFailureMapper.map(failure);
// error.message — localised user-facing string
// error.display — ErrorDisplay.toast / .inline / .fullScreen / .dialog
```
Use this in `BlocConsumer` listeners to decide *how* to surface errors.

---

## 11. THEME

**ThemeBloc** (global, provided in `main.dart`):
```dart
context.read<ThemeBloc>().add(const ToggleTheme());
context.read<ThemeBloc>().add(SetTheme(isDark: true));
context.read<ThemeBloc>().add(const LoadTheme());   // called on startup
```

**Context color extensions** (`theme_utils.dart`):
```dart
context.primary / context.secondary / context.tertiary
context.success / context.error / context.warning / context.info
context.background / context.surface / context.surfaceElevated
context.textPrimary / context.textSecondary / context.textDisabled
context.border / context.divider / context.overlay
context.isDark  // bool
```

**Context text style extensions** — full M3 scale:
`context.displayLarge/Medium/Small`, `context.headlineLarge/Medium/Small`,
`context.titleLarge/Medium/Small`, `context.bodyLarge/Medium/Small`, `context.labelLarge/Medium/Small`

Colors: `AppColors.*`. Never hardcode `Colors.*` or raw font sizes.

---

## 12. LOCAL STORAGE

```dart
await storage.setValues(StorageKeys.token, accessToken);
final token = await storage.readValues(StorageKeys.token);  // String?
await storage.clearValues(StorageKeys.token);
await storage.clearAll();
```

`StorageKeys`: `loggedIn`, `token`, `refreshToken`, `userId`, `userDetails`, `isDarkMode`

---

## 13. UTILITIES

### Spacing helpers (`extensions.dart`)
```dart
heightBox(16)   // SizedBox(height: 16)
widthBox(8)     // SizedBox(width: 8)
```

### Widget extensions (`widget_utils.dart`) — chainable on any `Widget`
`.center()`, `.expanded(flex?)`, `.flexible(flex?, fit?)`, `.withPadding(EdgeInsets)`,
`.withMargin(EdgeInsets)`, `.onTap(fn)`, `.onLongPress(fn)`, `.onDoubleTap(fn)`,
`.showIf(bool)`, `.visible(bool, replacement?)`, `.withSize(width?, height?)`,
`.withBorder(color, width, borderRadius?)`, `.withBackground(color, borderRadius?)`,
`.withHero(tag:)`, `.withRoundedCorners(radius)`, `.withOpacity(opacity)`,
`.withShadow(...)`, `.scrollable()`, `.safeArea(...)`, `.absorbPointer()`,
`.ignorePointer()`, `.fitted(fit?)`, `.clipOval()`, `.asCard(...)`,
`.align(alignment)`, `.container(...)`, `.color(color)`, `.withAspectRatio(ratio)`,
`.constrained(...)`, `.intrinsicHeight()`, `.intrinsicWidth()`,
`.withFadeAnimation(controller)`, `.withScaleAnimation(scale)`,
`.withSlideAnimation(position)`, `.withRotation(angle)`,
`.positioned(top?, bottom?, left?, right?)`

### Toasts — **require `BuildContext`**
```dart
AppToastsUtils.showSuccessTop(context, message);
AppToastsUtils.showErrorTop(context, message);
AppToastsUtils.showWarningTop(context, message);
AppToastsUtils.showInfoTop(context, message);
AppToastsUtils.show(context, message: '...', type: ToastType.warning, position: ToastPosition.bottom);
AppToastsUtils.showLoading(context, 'Processing...');
AppToastsUtils.showWithAction(context, message: '...', actionText: 'Undo', onActionPressed: fn);
AppToastsUtils.dismissCurrent();
```

### Validators
```dart
Validator.email(value) / Validator.password(value) / Validator.phone(value)
Validator.required(value) / Validator.minLength(value, 6)
```

### Logging (debug-only, uses `logger` package)
```dart
appLogger.d('debug message');   // from core/networks/network_manager/app_logger.dart
```

### Date/time (`date_utils.dart`) — extensions on `DateTime`, `Duration`, `int`, `String`
```dart
// DateTime checks & formatting
date.isToday() / date.isYesterday() / date.isPast() / date.isFuture()
date.isSameDay(other) / date.isWeekend() / date.isThisWeek()
date.formatted          // "Jan 15, 2024"
date.formattedLong      // "January 15, 2024"
date.timeAgo            // "2 hours ago"
date.timeAgoShort       // "2h ago"
date.timeUntil          // "in 3 days"
date.time12Hour         // "10:30 AM"
date.timeOnly           // "14:30"
date.fullFormat         // "15 Jan 2024, 10:30 AM"
date.format('dd/MM/yyyy') // custom pattern
date.dayName / date.shortDayName   // "Monday" / "Mon"
date.monthName / date.shortMonthName  // "January" / "Jan"
date.startOfDay() / date.endOfDay()
date.startOfWeek() / date.startOfMonth() / date.startOfQuarter()
date.addDays(7) / date.subtractDays(3)
date.addMonths(1) / date.addYears(1)
date.addBusinessDays(5) / date.nextBusinessDay
date.getAge()            // years since date
date.differenceInDays(other) / date.differenceInMonths(other)
date.daysInMonth / date.weekOfYear / date.quarter
date.isLeapYear
date.copyWith(year: 2025, month: 1)

// Nullable DateTime
date?.orNow              // DateTime (now if null)
date?.timeAgoOrEmpty     // "" if null
date?.isNullOrPast       // bool
date?.isNullOrFuture     // bool
date?.formatOrEmpty('dd/MM/yyyy')

// Duration formatting
duration.formatted       // "01:30:00"
duration.formattedShort  // "1h 30m"
duration.readable        // "1 hour"

// int → Duration
5.days / 2.hours / 30.minutes / 10.seconds / 500.milliseconds

// num → duration string
90.asMinutesSeconds      // "01:30"
3661.asDuration          // "1h 1m 1s"

// String parsing
'2024-01-15'.toDateTime        // DateTime?
'15/01/2024'.parseCommonDate   // tries 6 common formats
'2024-01-15'.isValidDate       // bool
'2024-01-15'.parseDate('yyyy-MM-dd')
```

### Currency & numbers (`currency_utils.dart`, `math_utils.dart`) — extensions on `num`/`String`
```dart
// Currency formatting
1000.withCommas             // "1,000"
1000.asCurrency             // "$1,000.00"
1000.asPrice                // "1,000"  (no decimals if whole number)
1500.asCompact              // "1.5K"
1500.asCompactCurrency      // "$1.5K"
1500.asSocialCount          // "1.5k"  (lowercase, social style)
1000.asPKR                  // "₨1,000"
1000.asEUR                  // "€1,000.00"
1000.asGBP                  // "£1,000.00"
1000.formatCurrency(symbol: '₹', decimalDigits: 0)
1000.formatPrice(symbol: '₹')

// Percentage & decimals
0.75.asPercentage           // "75%"
0.05.asPercentageWithSign   // "+5%"
0.756.toPercentage(decimals: 1)  // "75.6%"
10.99.to2Decimals           // "10.99"
10.99.to0Decimals           // "11"
10.50.withoutTrailingZeros  // "10.5"
10.6.rounded / 10.1.roundedUp / 10.9.roundedDown

// File size
1048576.asFileSize          // "1.00 MB"
1073741824.toFileSize(decimals: 1)  // "1.0 GB"

// Ordinal
3.asPosition                // "3rd"  (1st, 2nd, 3rd, 4th…)

// Validation
n.isBetween(0, 100)
n.isPositive / n.isNegative / n.isZero / n.isEven / n.isOdd
n.clampValue(0, 255)

// Nullable num
num?.orZero                 // 0 if null
num?.orDefault(99)
num?.asCurrencyOrEmpty      // "" if null
num?.withCommasOrEmpty      // "" if null
num?.isNullOrZero           // bool

// String → number
'1,000'.parseNumber         // 1000  (int?, strips commas)
'$1,000.50'.parseCurrency   // 1000.5  (double?, strips symbols)
'42'.toIntOrNull            // int?
'3.14'.toDoubleOrNull       // double?
'42'.toIntOr(0)
'bad'.toDoubleOr(0.0)
```

### Safe type conversion (`type_conversion.dart`) — top-level functions
```dart
safeToInt(dynamic)                    // null / wrong type → 0
safeToDouble(dynamic)                 // → 0.0
safeToString(dynamic, defaultValue: '') 
safeToBool(dynamic)                   // handles "true" / "1" / "yes"
safeToNum(dynamic)                    // → 0
safeToList<T>(dynamic)                // → []
safeToMap<K, V>(dynamic)              // → {}
safeToDateTime(dynamic)               // String ISO or int epoch → DateTime?
safeToColor(dynamic)                  // int ARGB or "#RRGGBB" → Color?
safeToDuration(dynamic)               // int ms or Duration → Duration?
safeToEnum<T>(dynamic, MyEnum.values) // string or index → enum value
safeAs<T>(dynamic)                    // safe cast → T?
safeJsonDecode(dynamic)               // JSON string → dynamic (null on error)
safeJsonEncode(dynamic)               // object → JSON String?
safeGetNested<T>(map, ['user', 'address', 'city'])  // deep map access
safeToUri(dynamic)                    // String → Uri?
```

---

## 13a. LOCALIZATION (intl / ARB)

User-facing copy lives in ARB files, not `AppConstants`. `AppConstants` is
still correct for non-translatable values (storage keys, timeouts, default
exception messages that get overridden by `AppFailureMapper` anyway).

```
lib/l10n/
├── app_en.arb          # template-arb-file — source of truth for keys
├── app_es.arb           # add one ARB file per locale, same keys
└── generated/           # committed, regenerated by `flutter pub get`
    ├── app_localizations.dart
    ├── app_localizations_en.dart
    └── app_localizations_es.dart
```

Config lives in `l10n.yaml` at the repo root. `generate: true` under
`flutter:` in `pubspec.yaml` means **`flutter pub get` regenerates
`lib/l10n/generated/` automatically** — no manual `flutter gen-l10n` step,
no synthetic package. The generated files are committed (same convention as
this repo's committed `.freezed.dart`/`.g.dart` files) so a fresh clone
builds without running codegen first.

```dart
// Add a string: add the key to lib/l10n/app_en.arb (and every other
// app_<locale>.arb), then `flutter pub get` to regenerate.

// Use it in a widget:
Text(context.l10n.signIn)
```

`context.l10n` (from `core/utils/localization_utils.dart`, exported via
`utils_exports.dart`) is a `BuildContext` extension shorthand for
`AppLocalizations.of(context)`. `MyApp` in `main.dart` already wires
`AppLocalizations.localizationsDelegates` / `.supportedLocales` into
`MaterialApp.router` — new locales only need a new ARB file, nothing else
in `main.dart` changes.

---

## 14. CORE WIDGETS REFERENCE

```dart
// Buttons — three variants
CustomButton(label: 'Submit', onPressed: fn, isLoading: bool, radius: 50, width: double.infinity)
CustomButton.outline(label: 'Cancel', onPressed: fn, outlineColor: color)
CustomButton.text(label: 'Skip', onPressed: fn, textColor: color)

// Inputs
CustomTextFormField(label: 'Email', hintText: '...', controller: ctrl, validator: Validator.email)
CustomTextFormField(  // async validation (e.g. availability check) + server-side error
  label: 'Username',
  controller: ctrl,
  asyncValidator: (value) => checkUsernameAvailableUsecase(value),
  errorText: state.usernameServerError,  // e.g. from a FAILURE state
  onChanged: (v) => bloc.add(UsernameChanged(v)),  // clear the server error in your event handler
)
SearchableDropdown(items: [...], controller: ctrl, onChanged: fn, label: 'Category')
CustomSearchField(onChanged: fn)
```

`CustomTextFormField` already has a built-in password-visibility toggle
whenever `obscureText: true` is passed — don't build a second one.
`asyncValidator` debounces (500ms default, override via
`asyncValidatorDebounce`) and merges with `validator` (`validator` wins if
both return an error); `errorText` is an always-shown external override for
server-side errors — the widget does not clear it itself, so clear the
corresponding state field in your own `onChanged`/event handler.

```dart

// App chrome
CustomAppBar(title: 'Screen')
AppLogo()

// Loading / state
LoadingIndicator()    // inline spinner
LoadingPopup()        // blocking overlay popup
EmptyStateWidget(title: 'No results', subtitle: '...', icon: Iconsax.box, action: retryBtn)
ErrorStateWidget(message: '...', onRetry: fn)
ApiStatusBuilder<T>(     // collapses loading/empty/error/success branching — see below
  status: state.apiStatus,
  data: state.item,
  failure: state.failure,
  onRetry: fn,
  builder: (context, item) => Text(item.name),
)

// Lists / connectivity — see §7a and §7b
PaginatedListView<T>(cubit: cubit, itemBuilder: (context, item) => ...)
ConnectivityBanner(child: ...)   // wraps MaterialApp.router's builder in main.dart
```

`ApiStatusBuilder<T>` (`core/widgets/api_status_builder.dart`) is the
standard way to render a `BlocBuilder`'s `ApiStatus` — don't hand-roll the
`if (state.apiStatus == ApiStatus.LOADING) ...` branching per screen.
`LOADING`/`INITIAL` → `LoadingIndicator` (override via `loadingWidget`);
`FAILURE` → `ErrorStateWidget` with the message run through
`AppFailureMapper` (override via `onRetry`); `SUCCESS` with null/empty
data (see `isEmpty`) → `EmptyStateWidget` (override via `emptyWidget`);
otherwise your `builder` renders the real content. `PaginatedListView`
(§7a) already uses `EmptyStateWidget`/`ErrorStateWidget` internally for
the same reason — reuse these three instead of writing another inline
`Column` per feature.

> **Note:** `ShimmerLoading`, `CardWrapper`, `PullToRefreshWrapper`, `LoadingOverlay`,
> `DividerWithText`, and similar widgets mentioned in older docs are **not yet
> implemented**. Build them inline or add them to `core/widgets/` following the
> existing patterns.

---

## 15. UI STANDARDS

| Instead of | Use |
|---|---|
| `ElevatedButton` | `CustomButton` |
| `TextField` / `TextFormField` | `CustomTextFormField` |
| `AppBar` | `CustomAppBar` (or `AppBar` if no custom needed) |
| `CircularProgressIndicator` | `LoadingIndicator()` |
| `SizedBox(height: x)` | `heightBox(x)` |
| `SizedBox(width: x)` | `widthBox(x)` |
| `Center(child: x)` | `x.center()` |
| `Padding(padding: p, child: x)` | `x.withPadding(p)` |
| `GestureDetector(onTap: fn, child: x)` | `x.onTap(fn)` |
| `Expanded(child: x)` | `x.expanded()` |
| `Theme.of(context).colorScheme.primary` | `context.primary` |
| `MediaQuery.of(context).size.width` | `context.screenWidth` |

Use `BlocBuilder` with `buildWhen` to scope rebuilds — wrap only the subtree that reads that state field, not the entire screen.

---

## 16. FILE NAMING

| Type | Convention | Example |
|---|---|---|
| Files | `snake_case.dart` | `product_bloc.dart` |
| Classes | `PascalCase` | `ProductBloc` |
| Variables/methods | `camelCase` | `fetchProductById` |
| Barrel files | `<feature>_exports.dart` | `auth_exports.dart` |
| BLoC event | `<action>Event` | `FetchProductEvent` |
| BLoC state | `<Feature>State` | `ProductState` |
| Cubit | `<Feature>Cubit` | `SplashCubit` |

---

## 17. TESTING

```
test/
├── unit/features/<feature>/
│   ├── domain/       # Usecase tests — mock repository with Mockito
│   ├── data/         # Repository impl tests — mock datasource
│   └── presentation/ # Bloc tests — mock usecase; use bloc_test package
└── widget/features/<feature>/
```

```dart
setUp(() {
  mockRepo = MockIProductRepository();
  bloc = ProductBloc(getProductUsecase: GetProductUsecase(repository: mockRepo));
});
tearDown(() => bloc.close());
```

---

## 18. SELF-AUDIT CHECKLIST

**Architecture**
- [ ] No Data layer imports in Presentation
- [ ] Domain layer: zero Flutter/Dio/GetIt/BLoC imports
- [ ] All repository methods return `Future<Either<Failure, T>>`
- [ ] Datasources extend `BaseRemoteDatasource`; repositories extend `BaseRepository`
- [ ] BLoCs registered as `sl.registerFactory` (not `registerLazySingleton`)

**UI**
- [ ] No raw `ElevatedButton`, `TextField`, `AppBar`, `CircularProgressIndicator` in feature views
- [ ] No `SizedBox(height/width: x)` — use `heightBox`/`widthBox`
- [ ] Colors from `context.*` or `AppColors.*`, never `Colors.*`
- [ ] Text styles from `context.bodyMedium` etc., never hardcoded sizes
- [ ] `BlocBuilder` uses `buildWhen` where possible
- [ ] Loading: `ApiStatus.LOADING` → `LoadingIndicator()`; failure: `ApiStatus.FAILURE` → toast/dialog via `AppFailureMapper`

**Code quality**
- [ ] No `print()` — use `appLogger.d/e/w`
- [ ] No `Navigator.push()` — use `context.go()` / `context.push()`
- [ ] No business logic inside view widgets
- [ ] No commented-out code committed
- [ ] No secrets/API keys/tokens as literals — add them via `.env` + `Env`, see SECRETS.txt

---

*Last updated: 2026-11-03 — added §1a Product Context summarizing the AS
Tailors SRS v1.3 and the architecture gaps (Supabase, auth, roles,
localization, offline, printing, money handling, multi-tenancy) to resolve
before building real business features. Previous update (2026-08-28): added
pagination pattern, offline banner, localization scaffold, and
envied-based secrets management (see SECRETS.txt).*
