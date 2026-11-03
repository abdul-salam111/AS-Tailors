# Architecture Guide

## Overview

This project follows **Clean Architecture** with a **feature-first** folder structure.
State management uses **BLoC/Cubit**, dependency injection uses **GetIt**, navigation uses
**go_router**, and HTTP calls use **Dio** wrapped in a typed `DioHelper`.

---

## Folder Structure

```
lib/
├── app_exports.dart          # Root barrel — re-exports packages + sub-barrels
├── main.dart                 # Entry point — calls setupLocator(), mounts MyApp
├── core/
│   ├── core_exports.dart     # Core barrel — export gateway for all core files
│   ├── di/                   # Dependency injection
│   │   ├── app_dependencies.dart   # sl instance + setupLocator() orchestrator
│   │   ├── register_network.dart   # Dio, DioHelper
│   │   ├── register_core.dart      # Storage, Session, Splash
│   │   └── register_auth.dart      # Auth datasource, repo, usecase, BLoC
│   ├── constants/            # App-wide constants, enums, asset paths
│   ├── local_storage/        # Secure storage wrapper
│   ├── networks/             # Dio configuration, exceptions, DioHelper
│   ├── services/             # Cross-cutting services (session, splash logic)
│   ├── shared/               # Base classes shared across all features
│   │   ├── datasource/       # BaseRemoteDatasource
│   │   ├── domain/
│   │   │   ├── failures/     # Failure hierarchy (AuthFailure, NetworkFailure…)
│   │   │   ├── repository/   # BaseRepository (execute + error mapping)
│   │   │   └── usecases/     # Usecase<SuccessType, Params> interface + NoParams
│   │   └── presentation/
│   │       └── mixins/       # UsecaseExecuterMixin
│   ├── theme/                # Light/dark MaterialTheme + ThemeBloc
│   ├── utils/                # Extensions, validators, date/math/currency utils,
│   │                         # AppToast, FailureMapper
│   └── widgets/              # Shared reusable widgets (CustomButton, AppLogo…)
├── features/
│   └── <feature>/
│       ├── <feature>_exports.dart  # Feature barrel (public API)
│       ├── data/
│       │   ├── datasources/        # Remote/local datasource implementations
│       │   ├── models/             # Freezed request + response models
│       │   └── repositories_impl/  # Repository implementations
│       ├── domain/
│       │   ├── entities/           # Pure Dart domain objects
│       │   ├── repositories/       # Abstract repository contracts
│       │   └── usecases/           # One file per use-case
│       └── presentation/
│           ├── <screen>/
│           │   ├── blocs/          # BLoC: event, state, bloc files
│           │   └── views/          # Screen widget(s)
│           └── cubit/              # Cubit (for simpler local state)
└── routes/
    ├── route_names.dart      # Named route constants
    ├── route_paths.dart      # Path string constants
    └── routes.dart           # GoRouter configuration
```

---

## Layer Rules

| Layer        | May import                        | Must NOT import          |
|--------------|-----------------------------------|--------------------------|
| Domain       | Nothing (pure Dart + fpdart)      | Data, Presentation       |
| Data         | Domain                            | Presentation             |
| Presentation | Domain (entities, usecases)       | Data layer directly      |
| Core         | Nothing feature-specific          | Features                 |

---

## Adding a New Feature

### 1 — Create the folder skeleton

```
features/
└── <name>/
    ├── <name>_exports.dart
    ├── data/
    │   ├── datasources/<name>_remote_datasource/
    │   ├── models/request_models/
    │   ├── models/response_models/
    │   └── repositories_impl/
    ├── domain/
    │   ├── entities/
    │   ├── repositories/
    │   └── usecases/
    └── presentation/
        └── <screen>/
            ├── blocs/
            └── views/
```

### 2 — Implement the domain layer first

```dart
// domain/repositories/product_repository.dart
abstract interface class ProductRepository {
  Future<Either<Failure, ProductEntity>> getProduct(String id);
}

// domain/usecases/get_product_usecase.dart
class GetProductUsecase implements Usecase<ProductEntity, String> {
  final ProductRepository repository;
  GetProductUsecase({required this.repository});

  @override
  Future<Either<Failure, ProductEntity>> call(String params) =>
      repository.getProduct(params);
}
```

### 3 — Implement the data layer

```dart
// data/repositories_impl/product_repository_impl.dart
class ProductRepositoryImpl extends BaseRepository implements ProductRepository {
  final ProductRemoteDatasource _datasource;
  ProductRepositoryImpl({required ProductRemoteDatasource datasource})
      : _datasource = datasource;

  @override
  Future<Either<Failure, ProductEntity>> getProduct(String id) =>
      execute(call: () async {
        final dto = await _datasource.fetchProduct(id);
        return dto.toEntity();
      });
}
```

### 4 — Wire up the BLoC (use `UsecaseExecuterMixin` for simple flows)

```dart
class ProductBloc extends Bloc<ProductEvent, ProductState>
    with UsecaseExecuterMixin {
  ProductBloc({required GetProductUsecase getProductUsecase})
      : super(const ProductState()) {
    on<FetchProductEvent>((event, emit) => executeUsecase(
          emit: emit,
          currentState: state,
          usecase: () => getProductUsecase(event.id),
          stateBuilder: (status, {data, error}) =>
              state.copyWith(apiStatus: status, product: data, message: error),
        ));
  }
}
```

### 5 — Register dependencies in `core/di/register_<name>.dart`

```dart
// core/di/register_product.dart
Future<void> registerProduct() async {
  sl.registerLazySingleton<ProductRemoteDatasource>(
      () => ProductRemoteDatasourceImpl(dioHelper: sl()));
  sl.registerLazySingleton<ProductRepository>(
      () => ProductRepositoryImpl(datasource: sl()));
  sl.registerLazySingleton(() => GetProductUsecase(repository: sl()));
  sl.registerFactory(() => ProductBloc(getProductUsecase: sl()));
}
```

Then call it from `core/di/app_dependencies.dart`:

```dart
import 'register_product.dart';

Future<void> setupLocator() async {
  await registerNetwork();
  await registerCore();
  await registerAuth();
  await registerProduct(); // ← add here
}
```

### 6 — Add route + feature barrel

```dart
// features/product/product_exports.dart
export 'data/...';
export 'domain/...';
export 'presentation/...';

// app_exports.dart — add one line
export 'features/product/product_exports.dart';

// routes/routes.dart — add GoRoute
GoRoute(
  path: RoutePaths.product,
  name: RouteNames.product,
  builder: (_, __) => const ProductView(),
),
```

---

## Key Conventions

### Naming

| Concept              | Convention                                   | Example                        |
|----------------------|----------------------------------------------|--------------------------------|
| Repository contract  | `<Feature>Repository` (abstract interface)   | `AuthRepository`               |
| Repository impl      | `<Feature>RepositoryImpl`                    | `AuthRepositoryImpl`           |
| Datasource contract  | `I<Feature>RemoteDatasource`                 | `IAuthRemoteDatasource`        |
| Datasource impl      | `<Feature>RemoteDatasourceImpl`              | `AuthRemoteDatasourceImpl`     |
| Use-case             | `<Action><Feature>Usecase`                   | `SignInUsecase`                |
| BLoC event           | `<Action>Event`                              | `SignInSubmitted`, `EmailChangedEvent` |
| BLoC state field     | `apiStatus` + `<entity>` + `message`         | see `SignInState`              |
| Screen widget        | `<Screen>View`                               | `SignInView`                   |

### State Management

- Use **BLoC** when there are multiple distinct events (form fields, API calls).
- Use **Cubit** for simple one-action state (e.g., `SplashCubit`).
- **Always** provide the BLoC inside the view (`BlocProvider` at the top of the view's `build`), never in the router.
- Views are `StatelessWidget`. Use a private inner `StatefulWidget` only when a lifecycle artifact (e.g., `GlobalKey`, `AnimationController`) must survive rebuilds.

### Error Handling

Use `AppFailureMapper.map(failure)` in BLoC listeners to get a `UserFacingError`
with the correct display strategy (`toast`, `inline`, `dialog`, `fullScreen`).

```dart
listener: (context, state) {
  if (state.apiStatus == ApiStatus.failure && state.failure != null) {
    final error = AppFailureMapper.map(state.failure!);
    // route to the right UI based on error.display
  }
},
```

### Barrel Imports

- Inside a feature, import `app_exports.dart` (relative path) for cross-cutting needs.
- From outside a feature, import the feature's `<name>_exports.dart` barrel.
- Never import `core/di/app_dependencies.dart` via the barrel inside DI registration files.
