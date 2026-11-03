# Flutter Template — Clean Architecture + BLoC

A production-ready Flutter template with Clean Architecture, BLoC state management, GoRouter navigation, and Mason code generation. Clone this once, ship apps forever.

---

## Features

- **Clean Architecture** — Domain / Data / Presentation layers with strict dependency rules
- **BLoC / Cubit** — Explicit, testable state management
- **GoRouter** — Declarative routing with deep link and named-route support
- **Dio** — HTTP client with interceptors, file upload, and auto error mapping
- **GetIt** — Lightweight service locator (no widget-tree coupling)
- **Freezed + json_serializable** — Immutable models with JSON and copyWith
- **fpdart** — `Either<Failure, Success>` for explicit error handling
- **flutter_secure_storage** — Encrypted token storage (Keychain on iOS, Keystore on Android)
- **Light / Dark theme** — ThemeBloc with persistence
- **Mason CLI bricks** — Scaffold features, screens, and barrel exports in seconds
- **70+ utilities** — Date, currency, validators, extensions, type converters

---

## Prerequisites

| Tool | Version | Install |
|------|---------|---------|
| Flutter SDK | >= 3.10.0 | [flutter.dev/install](https://flutter.dev/docs/get-started/install) |
| Dart SDK | >= 3.0.0 | Bundled with Flutter |
| Mason CLI | latest | `dart pub global activate mason_cli` |
| Git | any | [git-scm.com](https://git-scm.com) |

> **Note:** Run `flutter doctor` after installation to verify your environment.

---

## Quick Start

### macOS / Linux

```bash
# 1. Clone the template into your new project folder
git clone https://github.com/abdul-salam111/Flutter-Template.git my_new_app
cd my_new_app

# 2. Disconnect from the template's git history
rm -rf .git

# 3. Install dependencies
flutter pub get

# 4. Set up your local secrets (never committed — see "Secrets" below)
cp .env.example .env

# 5. Install Mason bricks
dart pub global activate mason_cli   # skip if already installed
mason get

# 6. Run code generation (Freezed / json_serializable / envied)
dart run build_runner build --delete-conflicting-outputs

# 7. Run the app
flutter run
```

### Windows (PowerShell)

```powershell
# 1. Clone the template into your new project folder
git clone https://github.com/abdul-salam111/Flutter-Template.git my_new_app
cd my_new_app

# 2. Disconnect from the template's git history
Remove-Item -Recurse -Force .git

# 3. Install dependencies
flutter pub get

# 4. Set up your local secrets (never committed — see "Secrets" below)
Copy-Item .env.example .env

# 5. Install Mason bricks
dart pub global activate mason_cli   # skip if already installed
mason get

# 6. Run code generation (Freezed / json_serializable / envied)
dart run build_runner build --delete-conflicting-outputs

# 7. Run the app
flutter run
```

---

## Setting Up a New Project from This Template

### Step 1 — Rename the App

**macOS / Linux:**
```bash
# Rename display name (what shows on device)
dart pub global activate rename
dart pub global run rename setAppName --targets ios,android --value "My App"

# Change package/bundle ID
flutter pub global run change_app_package_name:main com.yourcompany.myapp
```

**Windows (PowerShell):**
```powershell
dart pub global activate rename
dart pub global run rename setAppName --targets ios,android --value "My App"
flutter pub global run change_app_package_name:main com.yourcompany.myapp
```

> **Android:** Also update `applicationId` in `android/app/build.gradle.kts`.
> **iOS:** Also update the Bundle Identifier in Xcode -> Runner -> Signing & Capabilities.

### Step 2 — Set Your API Base URL

The base URL and app token are secrets, not literals in source — set them in
`.env` (copied from `.env.example` in the Quick Start steps above), not in
`lib/core/constants/api_endpoints.dart`:

```
# .env
BASE_URL=https://api.yourapp.com/v1/
APP_TOKEN=your-static-app-token
```

Then regenerate: `dart run build_runner build --delete-conflicting-outputs`.
See [SECRETS.txt](SECRETS.txt) for the full secrets-management pattern
(adding new keys, CI setup, why the generated `env.g.dart` isn't committed).

### Step 3 — Scaffold the Architecture

```bash
mason make flutter_architecture
```

### Step 4 — Initialize Your Own Git Repository

**macOS / Linux:**
```bash
git init
git add .
git commit -m "Initial commit from Flutter template"
git remote add origin https://github.com/yourusername/my_new_app.git
git branch -M main
git push -u origin main
```

**Windows (PowerShell):**
```powershell
git init
git add .
git commit -m "Initial commit from Flutter template"
git remote add origin https://github.com/yourusername/my_new_app.git
git branch -M main
git push -u origin main
```

---

## Project Structure

```
lib/
├── main.dart                    # Entry point
├── core/                        # Shared infrastructure
│   ├── constants/               # API endpoints, enums, icon/image paths
│   ├── di/                      # GetIt dependency injection setup
│   ├── local_storage/           # Secure storage wrapper
│   ├── networks/                # Dio HTTP client + exception hierarchy
│   ├── services/                # Session, splash services
│   ├── shared/                  # Base classes: DataSource, Repository, Usecase, Failure
│   ├── theme/                   # Colors, ThemeData, ThemeBloc
│   ├── utils/                   # Extensions, validators, formatters, toasts
│   └── widgets/                 # Reusable UI components
├── features/                    # Feature modules
│   ├── auth/                    # Authentication (signin, signup)
│   └── splash/                  # Splash screen + auth check
└── routes/                      # GoRouter: paths, names, route config
```

Each feature follows this structure:
```
features/<feature>/
├── data/
│   ├── datasources/             # Remote/local datasource implementations
│   ├── models/
│   │   ├── request_models/      # Freezed request DTOs
│   │   └── response_models/     # Freezed response DTOs
│   └── repositories_impl/       # Repository implementations
├── domain/
│   ├── entities/                # Pure Dart entities
│   ├── repositories/            # Abstract interfaces
│   └── usecases/                # One class per use case
└── presentation/
    └── <screen>/
        ├── blocs/               # BLoC event, state, bloc
        └── views/               # Screen widgets
```

---

## UI Patterns

### Extension-first approach
The template ships with 40+ widget extensions. Always prefer them over raw Flutter constructs:

```dart
// ✅ Use extensions
Text(user.name)
  .withPadding(const EdgeInsets.all(12))
  .withBackground(context.surface, borderRadius: BorderRadius.circular(8))
  .onTap(() => context.goNamed(RouteNames.profile))

heightBox(16)   // not SizedBox(height: 16)
widthBox(8)     // not SizedBox(width: 8)
x.center()      // not Center(child: x)
x.expanded()    // not Expanded(child: x)
x.showIf(cond)  // not Visibility/conditional render
```

### Theme-aware colors & typography — always from context
```dart
context.primary        // brand color
context.surface        // card/sheet background (light/dark aware)
context.textPrimary    // main text color
context.isDark         // bool
context.bodyMedium     // TextStyle — never hardcode fontSize
context.titleLarge     // TextStyle
```

### Custom widgets — never use raw Material widgets in feature views
| Use | Instead of |
|-----|-----------|
| `CustomButton(text:, onPressed:, isLoading:)` | `ElevatedButton` |
| `CustomTextFormField(label:, controller:, validator:, asyncValidator:, errorText:)` | `TextFormField` |
| `CustomAppBar(title:)` | `AppBar` |
| `LoadingIndicator()` | `CircularProgressIndicator` |
| `EmptyStateWidget(title:, icon:)` | inline Column |
| `ErrorStateWidget(message:, onRetry:)` | inline Column |
| `ApiStatusBuilder<T>(status:, data:, builder:)` | hand-rolled `if (state.apiStatus == ...)` branching |

Not yet implemented — build inline or add to `core/widgets/` if you need
them: `ShimmerLoading`, `CardWrapper`, `LoadingOverlay`,
`PullToRefreshWrapper`, `DividerWithText`.

### ApiStatus in views — `ApiStatusBuilder` handles all states for you
```dart
BlocBuilder<ProductBloc, ProductState>(
  builder: (context, state) => ApiStatusBuilder<ProductEntity>(
    status: state.apiStatus,
    data: state.product,
    failure: state.failure,
    onRetry: () => context.read<ProductBloc>().add(FetchProductEvent('id')),
    builder: (context, product) => Text(product.name),
  ),
)
```

---

## Mason Code Generation

Mason bricks generate boilerplate so you write only business logic.

```bash
# Scaffold a full clean-arch feature (data + domain + presentation + DI)
mason make create_feature

# Add a new screen to an existing feature
mason make add_screen

# Generate project folder structure from scratch
mason make flutter_architecture

# Generate asset constant classes from assets/ folder
mason make asset_generator

# Generate barrel export files
mason make export_generator

# Add a constant to core/constants/
mason make add_constant
```

### Planned bricks (contribute or request)
| Brick | What it will generate |
|---|---|
| `add_model` | Freezed request + response model pair in the correct feature folder |
| `add_usecase` | Usecase class + DI registration + repository method stub |
| `generate_tests` | BLoC test scaffold with mock repo, happy-path + failure cases |

---

## Code Generation (Freezed / JSON)

Run after creating or editing any `@freezed` model:

```bash
# Single build
dart run build_runner build --delete-conflicting-outputs

# Watch mode (auto-rebuilds on save)
dart run build_runner watch --delete-conflicting-outputs
```

---

## Running & Building

```bash
# Run in debug mode
flutter run

# List connected devices
flutter devices

# Run on a specific device
flutter run -d <device_id>

# Build release APK (Android)
flutter build apk --release

# Build App Bundle (Play Store)
flutter build appbundle --release

# Build iOS — macOS only, requires Xcode
flutter build ios --release

# Build for Web
flutter build web --release

# Build for macOS desktop — macOS only
flutter build macos --release

# Build for Windows desktop — Windows only
flutter build windows --release
```

---

## Running Tests

```bash
# Run all tests
flutter test

# Run a specific test file
flutter test test/unit/features/auth/signin_bloc_test.dart

# Run with coverage
flutter test --coverage

# View coverage report (macOS/Linux)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html

# View coverage report (Windows PowerShell)
genhtml coverage/lcov.info -o coverage/html
start coverage/html/index.html
```

---

## Linting & Formatting

```bash
# Analyze code
flutter analyze

# Format all Dart files
dart format lib/ --line-length 100

# Fix auto-fixable lint issues
dart fix --apply
```

---

## Secrets & Environment Variables

Secrets (API base URL, static app token, and any future key) live in a
gitignored `.env` file, never as literals in source. `envied_generator`
compiles them into an obfuscated `Env` class at build time.

```bash
cp .env.example .env          # macOS/Linux — one-time, per machine
Copy-Item .env.example .env   # Windows PowerShell
# fill in real values, then:
dart run build_runner build --delete-conflicting-outputs
```

- `.env.example` is committed (the template of keys a clone needs).
- `.env` and `lib/core/constants/env.g.dart` are both gitignored — `env.g.dart`
  is the one generated file this template does *not* commit, since it embeds
  your local `.env` values.
- If `build_runner` fails with `Environment variable not found for field
  'baseUrl'`, you skipped the `cp .env.example .env` step above.
- If you just created `.env` and it still fails the same way, run
  `dart run build_runner clean` once — the incremental build cache is stale.

Full pattern (adding a new secret, CI setup) is documented in
[SECRETS.txt](SECRETS.txt).

For a build-time flag that isn't a secret (e.g. which named environment
you're targeting), `--dart-define` is still the right tool:

**macOS / Linux:**
```bash
flutter run --dart-define=ENV=staging
```

**Windows (PowerShell):**
```powershell
flutter run --dart-define=ENV=staging
```

Read in Dart: `const env = String.fromEnvironment('ENV', defaultValue: 'dev');`

---

## Architecture Overview

```
Presentation (BLoC / GoRouter / Views)
        |
        | calls usecases
        v
Domain (Entities / Repositories (abstract) / Usecases)
        |
        | implements
        v
Data (Datasources / Freezed Models / Repo Implementations / Dio)
        
Core (GetIt DI / Theme / Utils / Widgets) -- shared by all layers
```

Error flow:
```
DioException -> AppException -> Failure (Either.left)
    -> BLoC state (ApiStatus.failure) -> Toast / UI error
```

---

## Key Packages

| Package | Purpose |
|---------|---------|
| `flutter_bloc` | BLoC state management |
| `go_router` | Declarative navigation |
| `dio` | HTTP client |
| `get_it` | Service locator / DI |
| `freezed` | Immutable models + unions |
| `fpdart` | Either / functional patterns |
| `flutter_secure_storage` | Encrypted token storage |
| `google_fonts` | Typography |
| `cached_network_image` | Image caching |
| `equatable` | Value equality for BLoC events/states |
| `mason` | Code generation bricks |
| `envied` | Compile-time secrets from `.env`, obfuscated |

---

## Troubleshooting

### `flutter pub get` fails
- Confirm Flutter SDK is on PATH: `flutter --version`
- On Windows: restart PowerShell/terminal after adding Flutter to PATH

### Build runner errors
```bash
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

### `Environment variable not found for field 'baseUrl'`
You haven't created `.env` yet — copy the template and fill in real values:
```bash
cp .env.example .env          # macOS/Linux
Copy-Item .env.example .env   # Windows PowerShell
```
If `.env` already exists and this still happens, the build cache is stale —
run `dart run build_runner clean` first, then rebuild.

### Mason bricks not found
```bash
mason get
```

### iOS build fails (macOS only)
```bash
cd ios && pod install && cd ..
flutter clean && flutter run
```

### "Unable to locate Android SDK"
Set `ANDROID_HOME` in your shell profile (`~/.zshrc`, `~/.bashrc`) or Windows Environment Variables.

### Windows: `rm -rf` not recognized
Use PowerShell: `Remove-Item -Recurse -Force <path>`

### Windows: `open` command not found
Use `start <path>` in PowerShell or Command Prompt.

---

## Recommended Next Steps

After cloning and renaming:

- [ ] Copy `.env.example` to `.env` and set your real API base URL/app token
- [ ] Replace `assets/icons/logo.png` with your app logo
- [ ] Update brand colors in `lib/core/theme/colors.dart`
- [ ] Add features with `mason make create_feature` or screens with `mason make add_screen`
- [ ] Write unit tests for each usecase and BLoC
- [ ] Set up CI/CD (GitHub Actions recommended)
- [ ] Configure Firebase (Analytics + Crashlytics) for release builds
- [ ] Add localization if targeting multiple languages

---

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feat/your-feature`
3. Commit with a descriptive message
4. Open a Pull Request

Please follow the existing architecture conventions. See [CLAUDE.md](CLAUDE.md) for detailed development guidelines.

---

## License

MIT — use freely in personal and commercial projects.
