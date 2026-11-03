import 'dart:io';
import 'package:mason/mason.dart';

Future<void> run(HookContext context) async {
  final logger = context.logger;

  // ── Vars ──────────────────────────────────────────────────────────────────
  final featureName = context.vars['feature_name'] as String;
  final rawScreenName = context.vars['initial_screen_name'] as String;
  // If the user left initial_screen_name blank, fall back to the feature name.
  final screenName =
      rawScreenName.trim().isEmpty ? featureName : rawScreenName.trim();

  final featureClass = _toPascalCase(featureName);
  final featureFile = _toSnakeCase(featureName);
  final screenClass = _toPascalCase(screenName);
  final screenFile = _toSnakeCase(screenName);

  logger.info('\n🚀 Creating feature: $featureName');
  logger.info('   Screen: $screenName');
  logger.info('   Feature class: $featureClass | Screen class: $screenClass\n');

  final libDir = Directory('lib');
  if (!libDir.existsSync()) {
    libDir.createSync(recursive: true);
  }

  _createCleanFeature(
      libDir, featureClass, featureFile, screenClass, screenFile, logger,);

  logger.success('\n✅ $featureClass feature created successfully!');
  logger.info('\n📦 Next steps:');
  logger.info('1. Update API endpoints in datasource');
  logger.info('2. Define your models in data/models/');
  logger.info('3. Implement business logic in usecases');
  logger.info('4. Design UI in presentation/$screenFile/views/');
}

// ---------------------------------------------------------------------------
// 🧩 CREATE CLEAN FEATURE
// ---------------------------------------------------------------------------
void _createCleanFeature(
  Directory libDir,
  String featureClass,
  String featureFile,
  String screenClass,
  String screenFile,
  Logger logger,
) {
  final featureDir = Directory('${libDir.path}/features/$featureFile');

  // ── Directory tree ────────────────────────────────────────────────────────
  final dirs = [
    'features',
    'features/$featureFile',
    // Data layer
    'features/$featureFile/data',
    'features/$featureFile/data/datasources',
    'features/$featureFile/data/models',
    'features/$featureFile/data/models/request_models',
    'features/$featureFile/data/models/response_models',
    'features/$featureFile/data/repositories_impl',
    // Domain layer
    'features/$featureFile/domain',
    'features/$featureFile/domain/entities',
    'features/$featureFile/domain/repositories',
    'features/$featureFile/domain/usecases',
    // Presentation layer — nested under screen name
    'features/$featureFile/presentation',
    'features/$featureFile/presentation/$screenFile',
    'features/$featureFile/presentation/$screenFile/blocs',
    'features/$featureFile/presentation/$screenFile/views',
  ];

  for (final folder in dirs) {
    Directory('${libDir.path}/$folder').createSync(recursive: true);
    logger.success('📁 Created: lib/$folder');
  }

  // ── Files ─────────────────────────────────────────────────────────────────
  _createBlocFiles(
      featureDir, featureClass, featureFile, screenClass, screenFile, logger,);
  _createDataSourceFiles(featureDir, featureClass, featureFile, logger);
  _createRepositoryFiles(featureDir, featureClass, featureFile, logger);
  _createUseCaseFiles(
      featureDir, featureClass, featureFile, screenClass, screenFile, logger,);
  _createEntityFiles(featureDir, featureClass, featureFile, logger);

  _updateRoutes(libDir, featureFile, screenClass, screenFile, logger);
  _createDiRegistration(
      libDir, featureClass, featureFile, screenClass, screenFile, logger,);
  _updateApiEndpoints(libDir, featureFile, logger);
  _createFeatureBarrel(
      libDir, featureDir, featureClass, featureFile, screenFile, logger,);
}

// ---------------------------------------------------------------------------
// 🧩 Bloc Files  (nested at presentation/{screenFile}/blocs/)
// ---------------------------------------------------------------------------
void _createBlocFiles(
  Directory featureDir,
  String featureClass,
  String featureFile,
  String screenClass,
  String screenFile,
  Logger logger,
) {
  final blocDir = '${featureDir.path}/presentation/$screenFile/blocs';
  final viewDir = '${featureDir.path}/presentation/$screenFile/views';
  final lc = _toLowerCamelCase(screenClass);

  // ── View ─────────────────────────────────────────────────────────────────

  File('$viewDir/${screenFile}_view.dart')
    ..createSync(recursive: true)
    ..writeAsStringSync('''import 'package:flutter/material.dart';
import '../../../../../core/shared/shared_exports.dart';
import '../../../../../core/constants/const_exports.dart';
import '../../../../../core/di/di_exports.dart';
import '../../../../../core/widgets/widgets_exports.dart';
import '../../../../../core/utils/utils_exports.dart';
import '../blocs/${screenFile}_bloc.dart';
import '../blocs/${screenFile}_event.dart';
import '../blocs/${screenFile}_state.dart';

class ${screenClass}View extends StatelessWidget {
  const ${screenClass}View({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<${screenClass}Bloc>(),
      child: const _${screenClass}Body(),
    );
  }
}

class _${screenClass}Body extends StatefulWidget {
  const _${screenClass}Body();

  @override
  State<_${screenClass}Body> createState() => _${screenClass}BodyState();
}

class _${screenClass}BodyState extends State<_${screenClass}Body> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<${screenClass}Bloc, ${screenClass}State>(
      listener: (context, state) {
        if (state.apiStatus == ApiStatus.SUCCESS) {
          AppToastsUtils.showSuccessTop(context, 'Success!');
        }
        if (state.apiStatus == ApiStatus.FAILURE) {
          AppToastsUtils.showErrorTop(context, state.message.toString());
        }
      },
      builder: (context, state) {
        return UnfocusWrapper(
          child: Scaffold(
            appBar: CustomAppBar(title: '$screenClass'),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      // TODO: Add your UI widgets here
                      const Text('$screenClass View'),
                      heightBox(context.screenHeight * 0.05),
                      BlocBuilder<${screenClass}Bloc, ${screenClass}State>(
                        buildWhen: (p, n) => p.apiStatus != n.apiStatus,
                        builder: (context, state) {
                          return CustomButton(
                            isLoading: state.apiStatus == ApiStatus.LOADING,
                            text: 'Submit',
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                context
                                    .read<${screenClass}Bloc>()
                                    .add(${screenClass}Submitted());
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
  logger.success(
    '🧱 Created: lib/features/$featureFile/presentation/$screenFile/views/${screenFile}_view.dart',
  );

  // ── BLoC ─────────────────────────────────────────────────────────────────
  File('$blocDir/${screenFile}_bloc.dart')
    ..createSync(recursive: true)
    ..writeAsStringSync('''import '../../../../../core/shared/shared_exports.dart';
import '../../../../../core/constants/const_exports.dart';
import '${screenFile}_event.dart';
import '${screenFile}_state.dart';

class ${screenClass}Bloc extends Bloc<${screenClass}Event, ${screenClass}State>
    with UsecaseExecuterMixin {
  final ${featureClass}Usecase ${lc}Usecase;

  ${screenClass}Bloc({required this.${lc}Usecase})
      : super(const ${screenClass}State()) {
    on<${screenClass}Submitted>(_on${screenClass}Submitted);
  }

  Future<void> _on${screenClass}Submitted(
    ${screenClass}Submitted event,
    Emitter<${screenClass}State> emit,
  ) async {
    await executeUsecase(
      emit: emit,
      currentState: state,
      usecase: () => ${lc}Usecase.call(
        // TODO: Pass your parameters here
        NoParams(),
      ),
      stateBuilder: (status, {data, error}) =>
          state.copyWith(apiStatus: status, data: data, message: error),
    );
  }
}
''');
  logger.success(
    '🧱 Created: lib/features/$featureFile/presentation/$screenFile/blocs/${screenFile}_bloc.dart',
  );

  // ── Event ─────────────────────────────────────────────────────────────────
  File('$blocDir/${screenFile}_event.dart')
    ..createSync(recursive: true)
    ..writeAsStringSync('''import '../../../../../core/shared/shared_exports.dart';

abstract class ${screenClass}Event extends Equatable {
  const ${screenClass}Event();

  @override
  List<Object> get props => [];
}

class ${screenClass}Submitted extends ${screenClass}Event {}
''');
  logger.success(
    '🧱 Created: lib/features/$featureFile/presentation/$screenFile/blocs/${screenFile}_event.dart',
  );

  // ── State ─────────────────────────────────────────────────────────────────
  File('$blocDir/${screenFile}_state.dart')
    ..createSync(recursive: true)
    ..writeAsStringSync('''import '../../../../../core/shared/shared_exports.dart';
import '../../../../../core/constants/const_exports.dart';

class ${screenClass}State extends Equatable {
  final dynamic data;
  final String? message;
  final ApiStatus apiStatus;

  const ${screenClass}State({
    this.data,
    this.message,
    this.apiStatus = ApiStatus.INITIAL,
  });

  ${screenClass}State copyWith({
    dynamic data,
    String? message,
    ApiStatus? apiStatus,
  }) {
    return ${screenClass}State(
      data: data ?? this.data,
      message: message ?? this.message,
      apiStatus: apiStatus ?? this.apiStatus,
    );
  }

  @override
  List<Object?> get props => [data, message, apiStatus];
}
''');
  logger.success(
    '🧱 Created: lib/features/$featureFile/presentation/$screenFile/blocs/${screenFile}_state.dart',
  );
}

// ---------------------------------------------------------------------------
// 🧩 DataSource Files
// ---------------------------------------------------------------------------
void _createDataSourceFiles(
  Directory featureDir,
  String featureClass,
  String featureFile,
  Logger logger,
) {
  File(
      '${featureDir.path}/data/datasources/remote_${featureFile}_datasource.dart',)
    ..createSync(recursive: true)
    ..writeAsStringSync('''import '../../../../core/shared/shared_exports.dart';
import '../../../../core/constants/const_exports.dart';

abstract interface class IRemote${featureClass}DataSource {
  // TODO: Define your datasource methods here
  Future<dynamic> performAction();
}

class Remote${featureClass}DataSourceImpl extends BaseRemoteDatasource
    implements IRemote${featureClass}DataSource {
  Remote${featureClass}DataSourceImpl({required super.dioHelper});

  @override
  Future<dynamic> performAction() async {
    return post(
      url: ApiEndPoints.${_toLowerCamelCase(featureFile)},
      parser: (json) => json, // TODO: Replace with your model parser
      body: {}, // TODO: Add your request body
    );
  }
}
''');
  logger.success(
    '🧱 Created: lib/features/$featureFile/data/datasources/remote_${featureFile}_datasource.dart',
  );
}

// ---------------------------------------------------------------------------
// 🧩 Repository Files
// ---------------------------------------------------------------------------
void _createRepositoryFiles(
  Directory featureDir,
  String featureClass,
  String featureFile,
  Logger logger,
) {
  // Abstract interface (Dart convention: no I-prefix)
  File('${featureDir.path}/domain/repositories/${featureFile}_repository.dart')
    ..createSync(recursive: true)
    ..writeAsStringSync('''import '../../../../core/shared/shared_exports.dart';

abstract interface class ${featureClass}Repository {
  // TODO: Define your repository methods here
  Future<Either<Failure, dynamic>> performAction();
}
''');
  logger.success(
    '🧱 Created: lib/features/$featureFile/domain/repositories/${featureFile}_repository.dart',
  );

  // Implementation
  File(
      '${featureDir.path}/data/repositories_impl/${featureFile}_repository_impl.dart',)
    ..createSync(recursive: true)
    ..writeAsStringSync('''import '../../../../core/shared/shared_exports.dart';
import '../../domain/repositories/${featureFile}_repository.dart';
import '../datasources/remote_${featureFile}_datasource.dart';

class ${featureClass}RepositoryImpl extends BaseRepository
    implements ${featureClass}Repository {
  final IRemote${featureClass}DataSource dataSource;

  ${featureClass}RepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, dynamic>> performAction() {
    return execute(
      call: () => dataSource.performAction(),
    );
  }
}
''');
  logger.success(
    '🧱 Created: lib/features/$featureFile/data/repositories_impl/${featureFile}_repository_impl.dart',
  );
}

// ---------------------------------------------------------------------------
// 🧩 UseCase Files — named after the first screen action
// ---------------------------------------------------------------------------
void _createUseCaseFiles(
  Directory featureDir,
  String featureClass,
  String featureFile,
  String screenClass,
  String screenFile,
  Logger logger,
) {
  File('${featureDir.path}/domain/usecases/${screenFile}_usecase.dart')
    ..createSync(recursive: true)
    ..writeAsStringSync('''import '../../../../core/shared/shared_exports.dart';
import '../repositories/${featureFile}_repository.dart';

class ${screenClass}Usecase implements Usecase<dynamic, NoParams> {
  final ${featureClass}Repository repository;

  ${screenClass}Usecase({required this.repository});

  @override
  Future<Either<Failure, dynamic>> call(NoParams params) {
    return repository.performAction();
  }
}
''');
  logger.success(
    '🧱 Created: lib/features/$featureFile/domain/usecases/${screenFile}_usecase.dart',
  );
}

// ---------------------------------------------------------------------------
// 🧩 Entity Files
// ---------------------------------------------------------------------------
void _createEntityFiles(
  Directory featureDir,
  String featureClass,
  String featureFile,
  Logger logger,
) {
  File('${featureDir.path}/domain/entities/${featureFile}_entity.dart')
    ..createSync(recursive: true)
    ..writeAsStringSync('''import 'package:equatable/equatable.dart';

class ${featureClass}Entity extends Equatable {
  final String id;
  // TODO: Add your entity properties here

  const ${featureClass}Entity({required this.id});

  @override
  List<Object> get props => [id];
}
''');
  logger.success(
    '🧱 Created: lib/features/$featureFile/domain/entities/${featureFile}_entity.dart',
  );
}

// ---------------------------------------------------------------------------
// 🧩 Routes
// ---------------------------------------------------------------------------
void _updateRoutes(
  Directory libDir,
  String featureFile,
  String screenClass,
  String screenFile,
  Logger logger,
) {
  final routesDir = Directory('${libDir.path}/routes');
  if (!routesDir.existsSync()) routesDir.createSync(recursive: true);

  _updateRoutePaths(
      File('${routesDir.path}/route_paths.dart'), screenFile, logger,);
  _updateRouteNames(
      File('${routesDir.path}/route_names.dart'), screenFile, logger,);
  _updateRoutesFile(
      File('${routesDir.path}/routes.dart'), featureFile, screenClass, screenFile, logger,);
}

void _updateRoutePaths(File pathsFile, String screenFile, Logger logger) {
  if (!pathsFile.existsSync()) {
    pathsFile
      ..createSync(recursive: true)
      ..writeAsStringSync('''class RoutePaths {
  static const String $screenFile = '/$screenFile';
}
''');
    logger.success('🧭 Created: lib/routes/route_paths.dart');
    return;
  }

  String content = pathsFile.readAsStringSync();
  if (content.contains("static const String $screenFile")) {
    logger.warn('⚠️  Path for $screenFile already exists in route_paths.dart');
    return;
  }

  final closingBrace = content.lastIndexOf('}');
  content = '${content.substring(0, closingBrace)}'
      "  static const String $screenFile = '/$screenFile';\n"
      '${content.substring(closingBrace)}';
  pathsFile.writeAsStringSync(content);
  logger.success('🧭 Added $screenFile path to route_paths.dart');
}

void _updateRouteNames(File namesFile, String screenFile, Logger logger) {
  if (!namesFile.existsSync()) {
    namesFile
      ..createSync(recursive: true)
      ..writeAsStringSync('''class RouteNames {
  static const String $screenFile = '$screenFile';
}
''');
    logger.success('🧭 Created: lib/routes/route_names.dart');
    return;
  }

  String content = namesFile.readAsStringSync();
  if (content.contains("static const String $screenFile")) {
    logger.warn('⚠️  Name for $screenFile already exists in route_names.dart');
    return;
  }

  final closingBrace = content.lastIndexOf('}');
  content = '${content.substring(0, closingBrace)}'
      "  static const String $screenFile = '$screenFile';\n"
      '${content.substring(closingBrace)}';
  namesFile.writeAsStringSync(content);
  logger.success('🧭 Added $screenFile name to route_names.dart');
}

void _updateRoutesFile(
  File routesFile,
  String featureFile,
  String screenClass,
  String screenFile,
  Logger logger,
) {
  if (!routesFile.existsSync()) {
    routesFile
      ..createSync(recursive: true)
      ..writeAsStringSync(
        "import 'package:go_router/go_router.dart';\n"
        "import 'route_names.dart';\n"
        "import 'route_paths.dart';\n"
        "import '../features/$featureFile/${featureFile}_exports.dart';\n"
        '\n'
        'class AppRoutes {\n'
        '  static final GoRouter router = GoRouter(\n'
        '    initialLocation: RoutePaths.$screenFile,\n'
        '    routes: [\n'
        '      GoRoute(\n'
        '        path: RoutePaths.$screenFile,\n'
        '        name: RouteNames.$screenFile,\n'
        '        builder: (context, state) => const ${screenClass}View(),\n'
        '      ),\n'
        '    ],\n'
        '  );\n'
        '}\n',
      );
    logger.success('🧭 Created: lib/routes/routes.dart');
    return;
  }

  String content = routesFile.readAsStringSync();
  if (content.contains('RoutePaths.$screenFile') ||
      content.contains('${screenClass}View()')) {
    logger.warn('⚠️  Route for $screenFile already exists in routes.dart');
    return;
  }

  // Add feature import if not already present
  final featureImport =
      "import '../features/$featureFile/${featureFile}_exports.dart';";
  if (!content.contains(featureImport)) {
    final lastImport = content.lastIndexOf("import '");
    if (lastImport != -1) {
      final endOfImport = content.indexOf(';', lastImport) + 1;
      content =
          '${content.substring(0, endOfImport)}\n$featureImport${content.substring(endOfImport)}';
    }
  }

  final newRoute = '''      GoRoute(
        path: RoutePaths.$screenFile,
        name: RouteNames.$screenFile,
        builder: (context, state) => const ${screenClass}View(),
      ),''';

  final routesMatch = RegExp(r'routes:\s*\[').firstMatch(content);
  if (routesMatch != null) {
    final routesEnd = content.indexOf(']', routesMatch.end);
    final beforeClosing = content.lastIndexOf(')', routesEnd);
    if (beforeClosing != -1) {
      final insertAt = content.indexOf(',', beforeClosing) + 1;
      content =
          '${content.substring(0, insertAt)}\n$newRoute${content.substring(insertAt)}';
    }
  }

  routesFile.writeAsStringSync(content);
  logger.success('🧭 Added $screenClass route to routes.dart');
}

// ---------------------------------------------------------------------------
// 🧩 DI Registration
// ---------------------------------------------------------------------------
void _createDiRegistration(
  Directory libDir,
  String featureClass,
  String featureFile,
  String screenClass,
  String screenFile,
  Logger logger,
) {
  final diDir = Directory('${libDir.path}/core/di');
  if (!diDir.existsSync()) diDir.createSync(recursive: true);

  final registerFile = File('${diDir.path}/register_$featureFile.dart');
  if (registerFile.existsSync()) {
    logger.warn(
      '⚠️  core/di/register_$featureFile.dart already exists. Skipping.',
    );
    return;
  }

  final lc = _toLowerCamelCase(screenClass);
  registerFile.writeAsStringSync(
    '''import '../../features/$featureFile/data/datasources/remote_${featureFile}_datasource.dart';
import '../../features/$featureFile/data/repositories_impl/${featureFile}_repository_impl.dart';
import '../../features/$featureFile/domain/repositories/${featureFile}_repository.dart';
import '../../features/$featureFile/domain/usecases/${screenFile}_usecase.dart';
import '../../features/$featureFile/presentation/$screenFile/blocs/${screenFile}_bloc.dart';
import 'app_dependencies.dart';

Future<void> register$featureClass() async {
  // DataSource
  sl.registerLazySingleton<IRemote${featureClass}DataSource>(
    () => Remote${featureClass}DataSourceImpl(dioHelper: sl()),
  );

  // Repository
  sl.registerLazySingleton<${featureClass}Repository>(
    () => ${featureClass}RepositoryImpl(dataSource: sl()),
  );

  // UseCases
  sl.registerLazySingleton<${screenClass}Usecase>(
    () => ${screenClass}Usecase(repository: sl()),
  );

  // BLoCs
  sl.registerFactory<${screenClass}Bloc>(
    () => ${screenClass}Bloc(${lc}Usecase: sl()),
  );
}
''',
  );
  logger.success('🔧 Created: lib/core/di/register_$featureFile.dart');

  // Wire into app_dependencies.dart
  final depFile = File('${diDir.path}/app_dependencies.dart');
  if (!depFile.existsSync()) {
    logger.warn(
      '⚠️  core/di/app_dependencies.dart not found. Add manually:\n'
      "  import 'register_$featureFile.dart';\n"
      '  await register$featureClass();',
    );
    return;
  }

  String content = depFile.readAsStringSync();
  if (content.contains('register$featureClass()')) {
    logger.warn('⚠️  register$featureClass() already in app_dependencies.dart');
    return;
  }

  final importLine = "import 'register_$featureFile.dart';";
  final lastImportIndex = content.lastIndexOf("import '");
  if (lastImportIndex != -1) {
    final endOfImport = content.indexOf(';', lastImportIndex) + 1;
    content =
        '${content.substring(0, endOfImport)}\n$importLine${content.substring(endOfImport)}';
  }

  final setupMatch =
      RegExp(r'Future<void>\s+setupLocator\s*\(\s*\)\s+async\s*\{')
          .firstMatch(content);
  if (setupMatch != null) {
    final closingBrace = content.indexOf('}', setupMatch.end);
    if (closingBrace != -1) {
      content =
          '${content.substring(0, closingBrace)}  await register$featureClass();\n'
          '${content.substring(closingBrace)}';
    }
  }

  depFile.writeAsStringSync(content);
  logger.success(
    '🔧 Wired register_$featureFile.dart into core/di/app_dependencies.dart',
  );
}

// ---------------------------------------------------------------------------
// 🧩 API Endpoints
// ---------------------------------------------------------------------------
void _updateApiEndpoints(Directory libDir, String featureFile, Logger logger) {
  final endpointsFile =
      File('${libDir.path}/core/constants/api_endpoints.dart');

  if (!endpointsFile.existsSync()) {
    logger.warn('⚠️  api_endpoints.dart not found. Skipping endpoint setup.');
    return;
  }

  String content = endpointsFile.readAsStringSync();
  if (content.contains('static const String $featureFile')) {
    logger.warn(
      '⚠️  Endpoint for $featureFile already exists in api_endpoints.dart',
    );
    return;
  }

  final closingBrace = content.lastIndexOf('}');
  content = '${content.substring(0, closingBrace)}'
      "  static const String $featureFile = '\${baseUrl}$featureFile';\n"
      '${content.substring(closingBrace)}';
  endpointsFile.writeAsStringSync(content);
  logger.success('🔗 Added $featureFile endpoint to api_endpoints.dart');
}

// ---------------------------------------------------------------------------
// 🧩 Feature Barrel
// ---------------------------------------------------------------------------
void _createFeatureBarrel(
  Directory libDir,
  Directory featureDir,
  String featureClass,
  String featureFile,
  String screenFile,
  Logger logger,
) {
  final barrelFile = File('${featureDir.path}/${featureFile}_exports.dart');

  barrelFile
    ..createSync(recursive: true)
    ..writeAsStringSync(
        '''// $featureClass feature barrel — public API of this feature.
// Import this from outside the feature instead of individual file paths.
// Data layer and domain internals (datasources, repository impls, repository
// interfaces, usecases) are intentionally excluded — imported directly by DI.

// Domain
export 'domain/entities/${featureFile}_entity.dart';

// Presentation — $screenFile screen
export 'presentation/$screenFile/blocs/${screenFile}_bloc.dart';
export 'presentation/$screenFile/blocs/${screenFile}_event.dart';
export 'presentation/$screenFile/blocs/${screenFile}_state.dart';
export 'presentation/$screenFile/views/${screenFile}_view.dart';
''');
  logger.success(
    '📦 Created: lib/features/$featureFile/${featureFile}_exports.dart',
  );
  logger.info(
    '   Import it where needed: '
    "import '../features/$featureFile/${featureFile}_exports.dart';",
  );
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------
String _toPascalCase(String text) {
  return text.split('_').map((word) {
    if (word.isEmpty) return '';
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join('');
}

String _toSnakeCase(String text) {
  return text
      .replaceAllMapped(RegExp(r'[A-Z]'), (match) => '_${match.group(0)}')
      .toLowerCase()
      .replaceAll(RegExp(r'^_'), '');
}

String _toLowerCamelCase(String text) {
  final pascal = _toPascalCase(text);
  return pascal[0].toLowerCase() + pascal.substring(1);
}
