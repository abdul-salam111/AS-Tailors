import 'dart:io';
import 'dart:convert';
import 'package:mason/mason.dart';

Future<void> run(HookContext context) async {
  final logger = context.logger;

  logger.info('🔧 Setting up Clean Architecture with Bloc...');

  await _installBlocDependencies(logger);

  final currentDir = Directory.current;
  final libDir = Directory('${currentDir.path}/lib');
  if (!libDir.existsSync()) {
    libDir.createSync(recursive: true);
  }

  _createCleanFeature(libDir, logger);

  logger.success('✅ Clean Architecture with Bloc setup complete!');
}

// ------------------------------------------------------------------
// 🧩 Install Bloc Dependencies
// ------------------------------------------------------------------
Future<void> _installBlocDependencies(Logger logger) async {
  logger.info('📦 Installing Bloc packages...');

  final pubspecFile = File('pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    logger.err('❌ pubspec.yaml not found in current directory.');
    return;
  }

  String content = await pubspecFile.readAsString();

  bool hasFlutterBloc = false;
  bool hasBloc = false;
  bool hasEquatable = false;
  bool hasGetIt = false;
  bool hasGoRouter = false;

  final lines = content.split('\n');
  bool inDependenciesSection = false;

  for (int i = 0; i < lines.length; i++) {
    final line = lines[i].trim();

    if (line == 'dependencies:') {
      inDependenciesSection = true;
      continue;
    }

    if (line == 'dev_dependencies:' ||
        (line.isNotEmpty &&
            !lines[i].startsWith('  ') &&
            !lines[i].startsWith('\t') &&
            inDependenciesSection)) {
      inDependenciesSection = false;
    }

    if (inDependenciesSection) {
      if (line.contains('flutter_bloc:')) hasFlutterBloc = true;
      if (line.contains('bloc:')) hasBloc = true;
      if (line.contains('equatable:')) hasEquatable = true;
      if (line.contains('get_it:')) hasGetIt = true;
      if (line.contains('go_router:')) hasGoRouter = true;
    }
  }

  final packagesToAdd = <String>[];
  if (!hasFlutterBloc) packagesToAdd.add('  flutter_bloc: ^8.1.3');
  if (!hasBloc) packagesToAdd.add('  bloc: ^8.1.2');
  if (!hasEquatable) packagesToAdd.add('  equatable: ^2.0.5');
  if (!hasGetIt) packagesToAdd.add('  get_it: ^9.0.5');
  if (!hasGoRouter) packagesToAdd.add('  go_router: ^17.0.0');

  if (packagesToAdd.isEmpty) {
    logger.info('✅ All packages are already installed');
    return;
  }

  logger.info('📦 Adding ${packagesToAdd.length} package(s)');

  final backupFile = File('pubspec.yaml.backup');
  await backupFile.writeAsString(content);

  final updatedLines = <String>[];
  inDependenciesSection = false;
  bool packagesAdded = false;

  for (int i = 0; i < lines.length; i++) {
    final line = lines[i];
    updatedLines.add(line);

    final trimmedLine = line.trim();

    if (trimmedLine == 'dependencies:') {
      inDependenciesSection = true;
      continue;
    }

    if (inDependenciesSection && !packagesAdded) {
      if (i + 1 < lines.length) {
        final nextLine = lines[i + 1];
        final trimmedNextLine = nextLine.trim();

        if (trimmedNextLine == 'dev_dependencies:' ||
            (trimmedNextLine.isNotEmpty &&
                !nextLine.startsWith('  ') &&
                !nextLine.startsWith('\t'))) {
          for (final package in packagesToAdd) {
            updatedLines.add(package);
          }
          packagesAdded = true;
        }
      } else {
        for (final package in packagesToAdd) {
          updatedLines.add(package);
        }
        packagesAdded = true;
      }
    }
  }

  final updatedContent = updatedLines.join('\n');
  await pubspecFile.writeAsString(updatedContent);
  logger.success('✅ Added packages to pubspec.yaml');

  logger.info('\n🔄 Running flutter pub get...');
  try {
    final process =
        await Process.start('flutter', ['pub', 'get'], runInShell: true);

    process.stdout.transform(utf8.decoder).listen((data) {
      final output = data.trim();
      if (output.isNotEmpty) logger.info(output);
    });

    process.stderr.transform(utf8.decoder).listen((data) {
      final output = data.trim();
      if (output.isNotEmpty) logger.err(output);
    });

    final exitCode = await process.exitCode;
    if (exitCode == 0) {
      logger.success('✅ Dependencies installed successfully');
      if (backupFile.existsSync()) backupFile.deleteSync();
    } else {
      logger.err('❌ Failed to install dependencies');
      await pubspecFile.writeAsString(content);
      logger.info('Please run "flutter pub get" manually.');
    }
  } catch (e) {
    logger.err('❌ Error running flutter pub get: $e');
    await pubspecFile.writeAsString(content);
    logger.info('Please run "flutter pub get" manually.');
  }
}

// ------------------------------------------------------------------
// 🧩 Create Clean Feature Scaffold (signin)
// ------------------------------------------------------------------
void _createCleanFeature(Directory libDir, Logger logger) {
  const featureName = 'signin';
  const screenName = 'signin';
  final featureDir = Directory('${libDir.path}/features/$featureName');

  // Create top-level directories
  for (var folder in [
    'features',
    'features/$featureName',
    'features/$featureName/data',
    'features/$featureName/domain',
    'features/$featureName/presentation',
  ]) {
    Directory('${libDir.path}/$folder').createSync(recursive: true);
    logger.success('📁 Created: lib/$folder');
  }

  // Data layer folders — note: repositories_impl (not repository_impl)
  for (var folder in [
    'datasources',
    'repositories_impl',
    'models/request_models',
    'models/response_models',
  ]) {
    Directory('${featureDir.path}/data/$folder').createSync(recursive: true);
    logger.success('📁 Created: lib/features/$featureName/data/$folder');
  }

  // Domain layer folders
  for (var folder in ['repositories', 'usecases', 'entities']) {
    Directory('${featureDir.path}/domain/$folder').createSync(recursive: true);
    logger.success('📁 Created: lib/features/$featureName/domain/$folder');
  }

  // Presentation layer — screen subfolder pattern: presentation/<screen>/blocs|views
  for (var folder in ['$screenName/blocs', '$screenName/views']) {
    Directory('${featureDir.path}/presentation/$folder')
        .createSync(recursive: true);
    logger.success(
        '📁 Created: lib/features/$featureName/presentation/$folder');
  }

  _createDomainFiles(featureDir, logger);
  _createDataFiles(featureDir, logger);
  _createPresentationFiles(featureDir, screenName, logger);
  _createFeatureBarrel(featureDir, featureName, screenName, logger);
  _createRouteFiles(libDir, featureName, screenName, 'SignIn', logger);
  _updateDependencyInjection(libDir, featureName, screenName, logger);
}

// ------------------------------------------------------------------
// 🧩 Domain Layer Files
// ------------------------------------------------------------------
void _createDomainFiles(Directory featureDir, Logger logger) {
  // Entity
  File('${featureDir.path}/domain/entities/signin_entity.dart')
    ..createSync(recursive: true)
    ..writeAsStringSync('''import 'package:equatable/equatable.dart';

class SigninEntity extends Equatable {
  final String accessToken;
  final String? refreshToken;
  final String? tokenType;

  const SigninEntity({
    required this.accessToken,
    this.refreshToken,
    this.tokenType,
  });

  @override
  List<Object?> get props => [accessToken, refreshToken, tokenType];
}
''');
  logger.success('🧱 Created: domain/entities/signin_entity.dart');

  // Params (domain-level input to usecase — keeps usecase free of request models)
  File('${featureDir.path}/domain/entities/signin_params.dart')
    ..createSync(recursive: true)
    ..writeAsStringSync('''class SignInParams {
  final String uid;
  final String password;

  const SignInParams({required this.uid, required this.password});
}
''');
  logger.success('🧱 Created: domain/entities/signin_params.dart');

  // Repository interface
  File('${featureDir.path}/domain/repositories/signin_repository.dart')
    ..createSync(recursive: true)
    ..writeAsStringSync('''import '../../../../core/shared/shared_exports.dart';
import '../entities/signin_entity.dart';
import '../entities/signin_params.dart';

abstract interface class ISigninRepository {
  Future<Either<Failure, SigninEntity>> signInById(SignInParams params);
}
''');
  logger.success('🧱 Created: domain/repositories/signin_repository.dart');

  // Usecase
  File('${featureDir.path}/domain/usecases/signin_usecase.dart')
    ..createSync(recursive: true)
    ..writeAsStringSync('''import '../../../../core/shared/shared_exports.dart';
import '../entities/signin_entity.dart';
import '../entities/signin_params.dart';
import '../repositories/signin_repository.dart';

class SignInUsecase implements Usecase<SigninEntity, SignInParams> {
  final ISigninRepository _repository;

  SignInUsecase({required ISigninRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, SigninEntity>> call(SignInParams params) =>
      _repository.signInById(params);
}
''');
  logger.success('🧱 Created: domain/usecases/signin_usecase.dart');
}

// ------------------------------------------------------------------
// 🧩 Data Layer Files
// ------------------------------------------------------------------
void _createDataFiles(Directory featureDir, Logger logger) {
  // Datasource interface + implementation
  File('${featureDir.path}/data/datasources/remote_signin_datasource.dart')
    ..createSync(recursive: true)
    ..writeAsStringSync('''import '../../../../core/constants/const_exports.dart';
import '../../../../core/shared/shared_exports.dart';
import '../../domain/entities/signin_entity.dart';

abstract interface class IRemoteSigninDatasource {
  Future<SigninEntity> signInById({
    required String uid,
    required String password,
  });
}

class RemoteSigninDatasourceImpl extends BaseRemoteDatasource
    implements IRemoteSigninDatasource {
  RemoteSigninDatasourceImpl({required super.dioHelper});

  @override
  Future<SigninEntity> signInById({
    required String uid,
    required String password,
  }) async {
    return post(
      url: ApiEndPoints.loginByUid,
      parser: (json) {
        final map = json as Map<String, dynamic>;
        return SigninEntity(
          accessToken: map['access_token'] as String? ?? '',
          refreshToken: map['refresh_token'] as String?,
          tokenType: map['token_type'] as String?,
        );
      },
      body: {'uid': uid, 'password': password},
    );
  }
}
''');
  logger.success('🧱 Created: data/datasources/remote_signin_datasource.dart');

  // Repository implementation
  File('${featureDir.path}/data/repositories_impl/signin_repository_impl.dart')
    ..createSync(recursive: true)
    ..writeAsStringSync('''import '../../../../core/shared/shared_exports.dart';
import '../datasources/remote_signin_datasource.dart';
import '../../domain/entities/signin_entity.dart';
import '../../domain/entities/signin_params.dart';
import '../../domain/repositories/signin_repository.dart';

class SigninRepositoryImpl extends BaseRepository implements ISigninRepository {
  final IRemoteSigninDatasource _dataSource;

  SigninRepositoryImpl({required IRemoteSigninDatasource dataSource})
      : _dataSource = dataSource;

  @override
  Future<Either<Failure, SigninEntity>> signInById(SignInParams params) =>
      execute(
        call: () => _dataSource.signInById(
          uid: params.uid,
          password: params.password,
        ),
      );
}
''');
  logger.success(
      '🧱 Created: data/repositories_impl/signin_repository_impl.dart');
}

// ------------------------------------------------------------------
// 🧩 Presentation Layer Files
// ------------------------------------------------------------------
void _createPresentationFiles(
    Directory featureDir, String screenName, Logger logger) {
  final blocsPath = '${featureDir.path}/presentation/$screenName/blocs';
  final viewsPath = '${featureDir.path}/presentation/$screenName/views';

  // Event
  File('$blocsPath/signin_event.dart')
    ..createSync(recursive: true)
    ..writeAsStringSync('''import '../../../../../core/shared/shared_exports.dart';

abstract class SignInEvent extends Equatable {
  const SignInEvent();

  @override
  List<Object> get props => [];
}

class EmailChangedEvent extends SignInEvent {
  final String email;
  const EmailChangedEvent(this.email);

  @override
  List<Object> get props => [email];
}

class PasswordChangedEvent extends SignInEvent {
  final String password;
  const PasswordChangedEvent(this.password);

  @override
  List<Object> get props => [password];
}

class SignInSubmitted extends SignInEvent {
  const SignInSubmitted();
}
''');
  logger.success(
      '🧱 Created: presentation/$screenName/blocs/signin_event.dart');

  // State
  File('$blocsPath/signin_state.dart')
    ..createSync(recursive: true)
    ..writeAsStringSync('''import '../../../../../core/shared/shared_exports.dart';
import '../../../../../core/constants/app_enums.dart';
import '../../../domain/entities/signin_entity.dart';

class SignInState extends Equatable {
  final SigninEntity? signinEntity;
  final String? message;
  final ApiStatus apiStatus;
  final String email;
  final String password;

  const SignInState({
    this.signinEntity,
    this.message,
    this.apiStatus = ApiStatus.initial,
    this.email = '',
    this.password = '',
  });

  SignInState copyWith({
    SigninEntity? signinEntity,
    String? message,
    ApiStatus? apiStatus,
    String? email,
    String? password,
  }) {
    return SignInState(
      signinEntity: signinEntity ?? this.signinEntity,
      message: message ?? this.message,
      apiStatus: apiStatus ?? this.apiStatus,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  @override
  List<Object?> get props =>
      [signinEntity, message, apiStatus, email, password];
}
''');
  logger.success(
      '🧱 Created: presentation/$screenName/blocs/signin_state.dart');

  // BLoC
  File('$blocsPath/signin_bloc.dart')
    ..createSync(recursive: true)
    ..writeAsStringSync('''import '../../../../../core/shared/shared_exports.dart';
import '../../../domain/entities/signin_params.dart';
import '../../../domain/usecases/signin_usecase.dart';
import 'signin_event.dart';
import 'signin_state.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState>
    with UsecaseExecuterMixin {
  final SignInUsecase _signinUsecase;

  SignInBloc({required SignInUsecase signinUsecase})
      : _signinUsecase = signinUsecase,
        super(const SignInState()) {
    on<SignInSubmitted>(_onSignInSubmitted);
    on<EmailChangedEvent>(
      (event, emit) => emit(state.copyWith(email: event.email)),
    );
    on<PasswordChangedEvent>(
      (event, emit) => emit(state.copyWith(password: event.password)),
    );
  }

  Future<void> _onSignInSubmitted(
    SignInSubmitted event,
    Emitter<SignInState> emit,
  ) async {
    await executeUsecase(
      emit: emit,
      currentState: state,
      usecase: () => _signinUsecase(
        SignInParams(uid: state.email, password: state.password),
      ),
      stateBuilder: (status, {data, error}) =>
          state.copyWith(apiStatus: status, signinEntity: data, message: error),
    );
  }
}
''');
  logger
      .success('🧱 Created: presentation/$screenName/blocs/signin_bloc.dart');

  // View
  File('$viewsPath/signin_view.dart')
    ..createSync(recursive: true)
    ..writeAsStringSync('''import 'package:flutter/material.dart';
import '../../../../../core/shared/shared_exports.dart';
import '../../../../../core/constants/app_enums.dart';
import '../../../../../core/di/di_exports.dart';
import '../../../../../core/widgets/widgets_exports.dart';
import '../../../../../core/utils/utils_exports.dart';
import '../blocs/signin_bloc.dart';
import '../blocs/signin_event.dart';
import '../blocs/signin_state.dart';

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
        if (state.apiStatus == ApiStatus.success) {
          AppToastsUtils.showSuccessTop(
              context, 'You have logged in successfully!');
        }
        if (state.apiStatus == ApiStatus.failure) {
          AppToastsUtils.showErrorTop(
              context, state.message ?? 'Sign-in failed');
        }
      },
      builder: (context, state) {
        return UnfocusWrapper(
          child: Scaffold(
            appBar: AppBar(title: const Text('Sign In')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
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
                            label: 'Email',
                            keyboardType: TextInputType.emailAddress,
                            hintText: 'Enter your email',
                            onChanged: (email) => context
                                .read<SignInBloc>()
                                .add(EmailChangedEvent(email)),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      BlocBuilder<SignInBloc, SignInState>(
                        buildWhen: (p, n) => p.password != n.password,
                        builder: (context, state) {
                          return CustomTextFormField(
                            onChanged: (password) => context
                                .read<SignInBloc>()
                                .add(PasswordChangedEvent(password)),
                            obscureText: true,
                            prefixIcon: Iconsax.lock,
                            label: 'Password',
                            hintText: 'Enter your password',
                            keyboardType: TextInputType.visiblePassword,
                          );
                        },
                      ),
                      heightBox(context.screenHeight * 0.05),
                      BlocBuilder<SignInBloc, SignInState>(
                        buildWhen: (p, n) => p.apiStatus != n.apiStatus,
                        builder: (context, state) {
                          return CustomButton(
                            isLoading: state.apiStatus == ApiStatus.loading,
                            text: 'Sign In',
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                context
                                    .read<SignInBloc>()
                                    .add(const SignInSubmitted());
                              }
                            },
                            radius: 10,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
''');
  logger
      .success('🧱 Created: presentation/$screenName/views/signin_view.dart');
}

// ------------------------------------------------------------------
// 🧩 Feature Barrel Export
// ------------------------------------------------------------------
void _createFeatureBarrel(Directory featureDir, String featureName,
    String screenName, Logger logger) {
  // Only export what routes and other features need.
  // DI (register_signin.dart) imports implementation details directly.
  File('${featureDir.path}/${featureName}_exports.dart')
    ..createSync(recursive: true)
    ..writeAsStringSync('''export 'presentation/$screenName/blocs/signin_bloc.dart';
export 'presentation/$screenName/blocs/signin_event.dart';
export 'presentation/$screenName/blocs/signin_state.dart';
export 'presentation/$screenName/views/signin_view.dart';
''');
  logger.success('🧱 Created: ${featureName}_exports.dart');
}

// ------------------------------------------------------------------
// 🧩 Route Files
// ------------------------------------------------------------------
void _createRouteFiles(Directory libDir, String featureName, String screenName,
    String className, Logger logger) {
  final routesDir = Directory('${libDir.path}/routes');
  if (!routesDir.existsSync()) {
    routesDir.createSync(recursive: true);
  }

  File('${routesDir.path}/route_paths.dart').writeAsStringSync('''class RoutePaths {
  static const String $featureName = '/$featureName';
}
''');
  logger.success('🧭 Created: lib/routes/route_paths.dart');

  File('${routesDir.path}/route_names.dart').writeAsStringSync('''class RouteNames {
  static const String $featureName = '$featureName';
}
''');
  logger.success('🧭 Created: lib/routes/route_names.dart');

  File('${routesDir.path}/routes.dart').writeAsStringSync('''import 'package:go_router/go_router.dart';
import '../features/$featureName/presentation/$screenName/views/signin_view.dart';
import 'route_names.dart';
import 'route_paths.dart';

class AppRoutes {
  static final GoRouter router = GoRouter(
    initialLocation: RoutePaths.$featureName,
    routes: [
      GoRoute(
        path: RoutePaths.$featureName,
        name: RouteNames.$featureName,
        builder: (context, state) => const ${className}View(),
      ),
    ],
  );
}
''');
  logger.success('🧭 Created: lib/routes/routes.dart');

  File('${routesDir.path}/routes_exports.dart').writeAsStringSync('''export 'route_names.dart';
export 'route_paths.dart';
export 'routes.dart';
''');
  logger.success('🧭 Created: lib/routes/routes_exports.dart');
}

// ------------------------------------------------------------------
// 🧩 Dependency Injection
// ------------------------------------------------------------------
void _updateDependencyInjection(Directory libDir, String featureName,
    String screenName, Logger logger) {
  final diDir = Directory('${libDir.path}/core/di');
  if (!diDir.existsSync()) {
    diDir.createSync(recursive: true);
  }

  // Create register_signin.dart following register_auth.dart pattern
  File('${diDir.path}/register_$featureName.dart')
    ..createSync(recursive: true)
    ..writeAsStringSync(
        '''import '../../features/$featureName/data/datasources/remote_${featureName}_datasource.dart';
import '../../features/$featureName/data/repositories_impl/${featureName}_repository_impl.dart';
import '../../features/$featureName/domain/repositories/${featureName}_repository.dart';
import '../../features/$featureName/domain/usecases/${featureName}_usecase.dart';
import '../../features/$featureName/presentation/$screenName/blocs/${featureName}_bloc.dart';
import 'app_dependencies.dart';

Future<void> registerSignin() async {
  sl.registerLazySingleton<IRemoteSigninDatasource>(
    () => RemoteSigninDatasourceImpl(dioHelper: sl()),
  );
  sl.registerLazySingleton<ISigninRepository>(
    () => SigninRepositoryImpl(dataSource: sl()),
  );
  sl.registerLazySingleton<SignInUsecase>(
    () => SignInUsecase(repository: sl()),
  );
  sl.registerFactory<SignInBloc>(
    () => SignInBloc(signinUsecase: sl()),
  );
}
''');
  logger.success('🧩 Created: lib/core/di/register_$featureName.dart');

  final depFile = File('${diDir.path}/app_dependencies.dart');
  if (!depFile.existsSync()) {
    depFile
      ..createSync(recursive: true)
      ..writeAsStringSync('''import 'package:get_it/get_it.dart';
import 'register_$featureName.dart';

final sl = GetIt.instance;

Future<void> setupLocator() async {
  await registerSignin();
}
''');
    logger.success('🧩 Created: lib/core/di/app_dependencies.dart');
    return;
  }

  // Update existing app_dependencies.dart
  String content = depFile.readAsStringSync();

  if (content.contains('registerSignin')) {
    logger.warn('⚠️  registerSignin already registered in app_dependencies.dart');
    return;
  }

  // Inject import at top
  const importLine = "import 'register_signin.dart';";
  if (!content.contains(importLine)) {
    final firstImport = content.indexOf('import ');
    if (firstImport >= 0) {
      content = '${content.substring(0, firstImport)}$importLine\n'
          '${content.substring(firstImport)}';
    }
  }

  // Inject call inside setupLocator
  final setupMatch =
      RegExp(r'Future<void>\s+setupLocator\s*\(\s*\)\s+async\s*\{')
          .firstMatch(content);
  if (setupMatch != null) {
    final closingBrace = content.indexOf('}', setupMatch.end);
    if (closingBrace != -1) {
      content =
          '${content.substring(0, closingBrace)}  await registerSignin();\n'
          '${content.substring(closingBrace)}';
    }
  }

  depFile.writeAsStringSync(content);
  logger.success(
      '🔧 Updated: lib/core/di/app_dependencies.dart with registerSignin()');
}
