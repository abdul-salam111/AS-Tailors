import 'dart:io';
import 'package:mason/mason.dart';

// ---------------------------------------------------------------------------
// add_screen
//
// TWO MODES — determined automatically by whether the feature already exists:
//
// ① New feature (no data/ or domain/ folder):
//     → Presentation only (views + bloc/cubit).
//     → Import depth: feature barrel = '../../', core = '../../../../'
//
// ② Existing feature (has data/ or domain/ folder):
//     → Full clean-arch: adds datasource method, repository method,
//       creates usecase, wires usecase into bloc, registers in DI.
//     → Import depth depends on whether featureName == screenName (flat)
//       or featureName != screenName (per-screen subfolder).
//
// Flat  (featureName == screenName): presentation/blocs/   presentation/views/
// Nested (featureName != screenName): presentation/{s}/blocs/  presentation/{s}/views/
// ---------------------------------------------------------------------------

Future<void> run(HookContext context) async {
  final logger = context.logger;

  final featureName = (context.vars['feature_name'] as String).trim();
  final screenName = (context.vars['screen_name'] as String).trim();
  final stateManagement = context.vars['state_management'] as String;

  final featureClass = _toPascalCase(featureName);
  final featureFile = _toSnakeCase(featureName);
  final screenClass = _toPascalCase(screenName);
  final screenFile = _toSnakeCase(screenName);
  final methodName = _toCamelCase(screenFile);

  logger.info('\n🚀 Adding screen "$screenName" to feature "$featureName"');
  logger.info('   State management: $stateManagement');

  // ── Guard: lib/ must exist ────────────────────────────────────────────────
  final libDir = Directory('lib');
  if (!libDir.existsSync()) {
    logger.err('lib/ directory not found. Run this from your Flutter project root.');
    return;
  }

  // ── Guard: reject reserved folder names ──────────────────────────────────
  const reservedNames = [
    'features', 'lib', 'core', 'routes', 'presentation', 'blocs', 'cubit', 'views',
  ];
  if (reservedNames.contains(featureFile)) {
    logger.err(
      '❌ "$featureName" is not a valid feature name.\n'
      '   Enter the name of your new feature, e.g. profile, orders, inventory.\n'
      '   The brick places it inside lib/features/ automatically.',
    );
    return;
  }

  // ── Feature: create scaffold if it doesn't exist ─────────────────────────
  final featureDir = Directory('${libDir.path}/features/$featureFile');
  final bool isNewFeature = !featureDir.existsSync();

  if (isNewFeature) {
    featureDir.createSync(recursive: true);
    logger.info('📁 Created new feature: lib/features/$featureFile/');
    final barrelFile = File('${featureDir.path}/${featureFile}_exports.dart');
    barrelFile
      ..createSync(recursive: true)
      ..writeAsStringSync('// $featureClass feature exports\n');
    logger.success('📦 Created: lib/features/$featureFile/${featureFile}_exports.dart');
  }

  // ── Mode: full clean-arch only for existing features ─────────────────────
  final bool hasDataLayer =
      !isNewFeature &&
      (Directory('${featureDir.path}/data').existsSync() ||
       Directory('${featureDir.path}/domain').existsSync());

  logger.info(
    hasDataLayer
        ? '   Mode: full clean-arch (existing feature with data/domain layer)\n'
        : '   Mode: presentation only\n',
  );

  // ── Layout: flat vs per-screen subfolder ──────────────────────────────────
  final bool useScreenFolder = featureFile != screenFile;
  final presentationDir = Directory('${featureDir.path}/presentation');
  final screenBaseDir = useScreenFolder
      ? Directory('${presentationDir.path}/$screenFile')
      : presentationDir;

  final featureBarrelPrefix = useScreenFolder ? '../../../' : '../../';
  final corePrefix = useScreenFolder ? '../../../../../' : '../../../../';

  // ── Guard: screen must not already exist ──────────────────────────────────
  final stateFolder = stateManagement == 'bloc' ? 'blocs' : 'cubit';
  final viewFile = File('${screenBaseDir.path}/views/${screenFile}_view.dart');
  if (viewFile.existsSync()) {
    logger.err('Screen "$screenFile" already exists. Delete it first or choose a different name.');
    return;
  }

  // ── Create directories ────────────────────────────────────────────────────
  for (final path in [
    '${screenBaseDir.path}/$stateFolder',
    '${screenBaseDir.path}/views',
  ]) {
    Directory(path).createSync(recursive: true);
  }

  // ── Generate presentation files ───────────────────────────────────────────
  if (stateManagement == 'bloc') {
    _createBlocFiles(
      featureDir, featureFile, screenClass, screenFile,
      screenBaseDir, featureBarrelPrefix, corePrefix,
      hasDataLayer, methodName, logger,
    );
  } else {
    _createCubitFiles(
      featureDir, featureFile, screenClass, screenFile,
      screenBaseDir, featureBarrelPrefix, corePrefix, logger,
    );
  }

  _createViewFile(
    featureDir, featureFile, screenClass, screenFile,
    screenBaseDir, featureBarrelPrefix, corePrefix, stateManagement, logger,
  );

  // ── Generate data/domain layer (existing features only) ───────────────────
  if (hasDataLayer) {
    _createEntity(featureDir, featureFile, screenFile, screenClass, logger);
    _addApiEndpoint(libDir, featureFile, screenFile, methodName, logger);
    _addDatasourceMethod(featureDir, featureFile, featureClass, screenFile, screenClass, methodName, logger);
    _addRepositoryMethod(featureDir, featureFile, featureClass, screenFile, screenClass, methodName, logger);
    _createUsecase(featureDir, featureFile, featureClass, screenFile, screenClass, methodName, logger);
  }

  // ── Update project files ──────────────────────────────────────────────────
  _updateFeatureBarrel(
    featureDir, featureFile, screenFile, stateManagement,
    useScreenFolder, hasDataLayer, logger,
  );
  _updateRoutes(libDir, featureFile, screenClass, screenFile, logger);
  _updateDiRegistration(
    libDir, featureFile, featureClass, screenClass, screenFile,
    stateManagement, hasDataLayer, logger,
  );

  logger.success('\n✅ $screenClass screen added to $featureClass!');
  if (hasDataLayer) {
    logger.info('\n📦 Next steps:');
    logger.info('1. Replace Future<dynamic> with your actual response type in the datasource/repository/usecase');
    logger.info('2. Implement the API call in I${featureClass}RemoteDatasourceImpl.$methodName()');
  }
}

// ---------------------------------------------------------------------------
// BLoC files  (bloc + event + state)
// ---------------------------------------------------------------------------
void _createBlocFiles(
  Directory featureDir,
  String featureFile,
  String screenClass,
  String screenFile,
  Directory screenBaseDir,
  String featureBarrelPrefix,
  String corePrefix,
  bool hasDataLayer,
  String methodName,
  Logger logger,
) {
  final dir = '${screenBaseDir.path}/blocs';
  final usecaseType = '${screenClass}Usecase';
  final usecaseParam = '${methodName}Usecase';

  // ── Bloc ──────────────────────────────────────────────────────────────────
  final blocContent = hasDataLayer
      ? '''import 'package:bloc/bloc.dart';

import '${corePrefix}core/shared/shared_exports.dart';
import '$featureBarrelPrefix${featureFile}_exports.dart';

class ${screenClass}Bloc extends Bloc<${screenClass}Event, ${screenClass}State>
    with UsecaseExecuterMixin {
  final $usecaseType $usecaseParam;

  ${screenClass}Bloc({required this.$usecaseParam})
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
      usecase: () => $usecaseParam(NoParams()),
      stateBuilder: (status, {data, error}) =>
          state.copyWith(apiStatus: status, data: data, message: error),
    );
  }
}
'''
      : '''import 'package:bloc/bloc.dart';

import '${corePrefix}core/shared/shared_exports.dart';
import '$featureBarrelPrefix${featureFile}_exports.dart';

class ${screenClass}Bloc extends Bloc<${screenClass}Event, ${screenClass}State>
    with UsecaseExecuterMixin {
  // TODO: Inject required usecases here
  // final SomeUsecase someUsecase;

  ${screenClass}Bloc(/*{required this.someUsecase}*/)
      : super(const ${screenClass}State()) {
    // on<${screenClass}Submitted>(_on${screenClass}Submitted);
  }

  // Future<void> _on${screenClass}Submitted(
  //   ${screenClass}Submitted event,
  //   Emitter<${screenClass}State> emit,
  // ) async {
  //   await executeUsecase(
  //     emit: emit,
  //     currentState: state,
  //     usecase: () => someUsecase(NoParams()),
  //     stateBuilder: (status, {data, error}) =>
  //         state.copyWith(apiStatus: status, data: data, message: error),
  //   );
  // }
}
''';

  File('$dir/${screenFile}_bloc.dart')
    ..createSync(recursive: true)
    ..writeAsStringSync(blocContent);
  logger.success('🧱 Created: ${_relPath(featureFile, screenFile, 'blocs', '${screenFile}_bloc.dart')}');

  // ── Event ─────────────────────────────────────────────────────────────────
  final eventContent = hasDataLayer
      ? '''import 'package:equatable/equatable.dart';

abstract class ${screenClass}Event extends Equatable {
  const ${screenClass}Event();

  @override
  List<Object> get props => [];
}

class ${screenClass}Submitted extends ${screenClass}Event {
  const ${screenClass}Submitted();
}
'''
      : '''import 'package:equatable/equatable.dart';

abstract class ${screenClass}Event extends Equatable {
  const ${screenClass}Event();

  @override
  List<Object> get props => [];
}

// TODO: Define events for this screen
// class ${screenClass}Submitted extends ${screenClass}Event {}
''';

  File('$dir/${screenFile}_event.dart')
    ..createSync(recursive: true)
    ..writeAsStringSync(eventContent);
  logger.success('🧱 Created: ${_relPath(featureFile, screenFile, 'blocs', '${screenFile}_event.dart')}');

  // ── State ─────────────────────────────────────────────────────────────────
  File('$dir/${screenFile}_state.dart')
    ..createSync(recursive: true)
    ..writeAsStringSync('''import 'package:equatable/equatable.dart';

import '${corePrefix}core/constants/app_enums.dart';

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
  logger.success('🧱 Created: ${_relPath(featureFile, screenFile, 'blocs', '${screenFile}_state.dart')}');
}

// ---------------------------------------------------------------------------
// Cubit files  (cubit + state)
// ---------------------------------------------------------------------------
void _createCubitFiles(
  Directory featureDir,
  String featureFile,
  String screenClass,
  String screenFile,
  Directory screenBaseDir,
  String featureBarrelPrefix,
  String corePrefix,
  Logger logger,
) {
  final dir = '${screenBaseDir.path}/cubit';

  File('$dir/${screenFile}_cubit.dart')
    ..createSync(recursive: true)
    ..writeAsStringSync('''import 'package:bloc/bloc.dart';

import '$featureBarrelPrefix${featureFile}_exports.dart';

class ${screenClass}Cubit extends Cubit<${screenClass}State> {
  // TODO: Inject required usecases here

  ${screenClass}Cubit() : super(const ${screenClass}State());

  // TODO: Add state-changing methods here
}
''');
  logger.success('🧱 Created: ${_relPath(featureFile, screenFile, 'cubit', '${screenFile}_cubit.dart')}');

  File('$dir/${screenFile}_state.dart')
    ..createSync(recursive: true)
    ..writeAsStringSync('''import 'package:equatable/equatable.dart';

import '${corePrefix}core/constants/app_enums.dart';

class ${screenClass}State extends Equatable {
  final ApiStatus apiStatus;
  final String? message;

  const ${screenClass}State({
    this.apiStatus = ApiStatus.INITIAL,
    this.message,
  });

  ${screenClass}State copyWith({
    ApiStatus? apiStatus,
    String? message,
  }) {
    return ${screenClass}State(
      apiStatus: apiStatus ?? this.apiStatus,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [apiStatus, message];
}
''');
  logger.success('🧱 Created: ${_relPath(featureFile, screenFile, 'cubit', '${screenFile}_state.dart')}');
}

// ---------------------------------------------------------------------------
// View file
// ---------------------------------------------------------------------------
void _createViewFile(
  Directory featureDir,
  String featureFile,
  String screenClass,
  String screenFile,
  Directory screenBaseDir,
  String featureBarrelPrefix,
  String corePrefix,
  String stateManagement,
  Logger logger,
) {
  final viewPath = '${screenBaseDir.path}/views/${screenFile}_view.dart';
  final controller =
      stateManagement == 'bloc' ? '${screenClass}Bloc' : '${screenClass}Cubit';
  final stateType = '${screenClass}State';

  if (stateManagement == 'bloc') {
    File(viewPath)
      ..createSync(recursive: true)
      ..writeAsStringSync('''import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '${corePrefix}core/di/di_exports.dart';
import '${corePrefix}core/constants/const_exports.dart';
import '${corePrefix}core/utils/utils_exports.dart';
import '${corePrefix}core/widgets/widgets.dart';
import '$featureBarrelPrefix${featureFile}_exports.dart';

class ${screenClass}View extends StatelessWidget {
  const ${screenClass}View({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<$controller>(),
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
    return BlocConsumer<$controller, $stateType>(
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
            body: Form(
              key: _formKey,
              child: const Center(
                child: Text('$screenClass View'),
              ),
            ),
          ),
        );
      },
    );
  }
}
''');
  } else {
    File(viewPath)
      ..createSync(recursive: true)
      ..writeAsStringSync('''import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '${corePrefix}core/di/di_exports.dart';
import '${corePrefix}core/constants/const_exports.dart';
import '${corePrefix}core/utils/utils_exports.dart';
import '${corePrefix}core/widgets/widgets.dart';
import '$featureBarrelPrefix${featureFile}_exports.dart';

class ${screenClass}View extends StatelessWidget {
  const ${screenClass}View({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<$controller>(),
      child: const _${screenClass}Body(),
    );
  }
}

class _${screenClass}Body extends StatelessWidget {
  const _${screenClass}Body();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<$controller, $stateType>(
      builder: (context, state) {
        return Scaffold(
          appBar: CustomAppBar(title: '$screenClass'),
          body: const Center(
            child: Text('$screenClass View'),
          ),
        );
      },
    );
  }
}
''');
  }

  logger.success('🧱 Created: ${_relPath(featureFile, screenFile, 'views', '${screenFile}_view.dart')}');
}

// ---------------------------------------------------------------------------
// Add method to existing datasource  (existing feature only)
// ---------------------------------------------------------------------------
void _addDatasourceMethod(
  Directory featureDir,
  String featureFile,
  String featureClass,
  String screenFile,
  String screenClass,
  String methodName,
  Logger logger,
) {
  final dsPath =
      '${featureDir.path}/data/datasources/${featureFile}_remote_datasource/${featureFile}_remote_datasource.dart';
  final dsFile = File(dsPath);
  if (!dsFile.existsSync()) {
    logger.warn('⚠️  Datasource not found at $dsPath. Add $methodName() manually.');
    return;
  }

  String content = dsFile.readAsStringSync();
  if (content.contains('$methodName()')) {
    logger.warn('⚠️  $methodName() already in datasource.');
    return;
  }

  // Insert abstract method into the interface (before impl class declaration)
  final implMarker = 'class ${featureClass}RemoteDatasourceImpl';
  final implIdx = content.indexOf(implMarker);
  if (implIdx != -1) {
    final interfaceClose = content.lastIndexOf('}', implIdx);
    content =
        '${content.substring(0, interfaceClose)}'
        '  Future<dynamic> $methodName();\n'
        '${content.substring(interfaceClose)}';
  }

  // Re-find impl class position after modification, then insert override before last }
  final updatedImplIdx = content.indexOf(implMarker);
  if (updatedImplIdx != -1) {
    final lastBrace = content.lastIndexOf('}');
    content =
        '${content.substring(0, lastBrace)}'
        '\n  @override\n'
        '  Future<dynamic> $methodName() async {\n'
        '    // TODO: implement $methodName API call\n'
        '    throw UnimplementedError(\'$methodName not implemented\');\n'
        '  }\n'
        '${content.substring(lastBrace)}';
  }

  dsFile.writeAsStringSync(content);
  logger.success('🔌 Added $methodName() to I${featureClass}RemoteDatasource');
}

// ---------------------------------------------------------------------------
// Add method to existing repository interface + impl  (existing feature only)
// ---------------------------------------------------------------------------
void _addRepositoryMethod(
  Directory featureDir,
  String featureFile,
  String featureClass,
  String screenFile,
  String screenClass,
  String methodName,
  Logger logger,
) {
  // ── Repository interface ──────────────────────────────────────────────────
  final repoInterfaceFile = File(
    '${featureDir.path}/domain/repositories/${featureFile}_repository.dart',
  );
  if (repoInterfaceFile.existsSync()) {
    String content = repoInterfaceFile.readAsStringSync();
    if (!content.contains('$methodName()')) {
      // Add entity import if missing
      final entityImport = "import '../entities/${screenFile}_entity.dart';";
      if (!content.contains(entityImport)) {
        final lastImport = RegExp(r"import '[^']+';").allMatches(content);
        if (lastImport.isNotEmpty) {
          final insertAt = lastImport.last.end;
          content = '${content.substring(0, insertAt)}\n$entityImport${content.substring(insertAt)}';
        }
      }
      final lastBrace = content.lastIndexOf('}');
      content =
          '${content.substring(0, lastBrace)}'
          '  Future<Either<Failure, ${screenClass}Entity>> $methodName();\n'
          '${content.substring(lastBrace)}';
      repoInterfaceFile.writeAsStringSync(content);
      logger.success('🗂  Added $methodName() to I${featureClass}Repository interface');
    } else {
      logger.warn('⚠️  $methodName() already in repository interface.');
    }
  } else {
    logger.warn('⚠️  Repository interface not found. Add $methodName() manually.');
  }

  // ── Repository impl ───────────────────────────────────────────────────────
  final repoImplFile = File(
    '${featureDir.path}/data/repositories_impl/${featureFile}_repository_impl.dart',
  );
  if (repoImplFile.existsSync()) {
    String content = repoImplFile.readAsStringSync();
    if (!content.contains('$methodName()')) {
      // Add entity import if missing
      final entityImport = "import '../../domain/entities/${screenFile}_entity.dart';";
      if (!content.contains(entityImport)) {
        final lastImport = RegExp(r"import '[^']+';").allMatches(content);
        if (lastImport.isNotEmpty) {
          final insertAt = lastImport.last.end;
          content = '${content.substring(0, insertAt)}\n$entityImport${content.substring(insertAt)}';
        }
      }
      final lastBrace = content.lastIndexOf('}');
      content =
          '${content.substring(0, lastBrace)}'
          '\n  @override\n'
          '  Future<Either<Failure, ${screenClass}Entity>> $methodName() {\n'
          '    return execute(\n'
          '      call: () async {\n'
          '        final result = await _dataSource.$methodName();\n'
          '        // TODO: map result to ${screenClass}Entity\n'
          '        return ${screenClass}Entity();\n'
          '      },\n'
          '    );\n'
          '  }\n'
          '${content.substring(lastBrace)}';
      repoImplFile.writeAsStringSync(content);
      logger.success('🗂  Added $methodName() to ${featureClass}RepositoryImpl');
    } else {
      logger.warn('⚠️  $methodName() already in repository impl.');
    }
  } else {
    logger.warn('⚠️  Repository impl not found. Add $methodName() manually.');
  }
}

// ---------------------------------------------------------------------------
// Create usecase  (existing feature only)
// ---------------------------------------------------------------------------
void _createUsecase(
  Directory featureDir,
  String featureFile,
  String featureClass,
  String screenFile,
  String screenClass,
  String methodName,
  Logger logger,
) {
  final usecaseDir = Directory('${featureDir.path}/domain/usecases');
  usecaseDir.createSync(recursive: true);

  final usecaseFile = File('${usecaseDir.path}/${screenFile}_usecase.dart');
  if (usecaseFile.existsSync()) {
    logger.warn('⚠️  ${screenFile}_usecase.dart already exists.');
    return;
  }

  // Repository interface class name — read from file to get exact name (handles typo variants)
  String repoInterfaceName = 'I${featureClass}Repository';
  final repoFile = File(
    '${featureDir.path}/domain/repositories/${featureFile}_repository.dart',
  );
  if (repoFile.existsSync()) {
    final repoContent = repoFile.readAsStringSync();
    final match = RegExp(r'abstract\s+interface\s+class\s+(\w+)').firstMatch(repoContent);
    if (match != null) repoInterfaceName = match.group(1)!;
  }

  usecaseFile
    ..createSync(recursive: true)
    ..writeAsStringSync(
      "import '../../../../core/shared/shared_exports.dart';\n"
      "import '../../${featureFile}_exports.dart';\n"
      "\n"
      "class ${screenClass}Usecase implements Usecase<${screenClass}Entity, NoParams> {\n"
      "  final $repoInterfaceName repository;\n"
      "\n"
      "  ${screenClass}Usecase({required this.repository});\n"
      "\n"
      "  @override\n"
      "  Future<Either<Failure, ${screenClass}Entity>> call(NoParams params) {\n"
      "    return repository.$methodName();\n"
      "  }\n"
      "}\n",
    );

  logger.success(
    '🧩 Created: lib/features/$featureFile/domain/usecases/${screenFile}_usecase.dart',
  );
}

// ---------------------------------------------------------------------------
// Update feature barrel
// ---------------------------------------------------------------------------
void _updateFeatureBarrel(
  Directory featureDir,
  String featureFile,
  String screenFile,
  String stateManagement,
  bool useScreenFolder,
  bool hasDataLayer,
  Logger logger,
) {
  final barrelFile = File('${featureDir.path}/${featureFile}_exports.dart');

  if (!barrelFile.existsSync()) {
    logger.warn('⚠️  ${featureFile}_exports.dart not found. Add exports manually.');
    return;
  }

  String content = barrelFile.readAsStringSync();

  final prefix = useScreenFolder ? './presentation/$screenFile' : './presentation';

  final presentationExports = stateManagement == 'bloc'
      ? '\n// Presentation — $screenFile screen\n'
        "export '$prefix/blocs/${screenFile}_bloc.dart';\n"
        "export '$prefix/blocs/${screenFile}_event.dart';\n"
        "export '$prefix/blocs/${screenFile}_state.dart';\n"
        "export '$prefix/views/${screenFile}_view.dart';"
      : '\n// Presentation — $screenFile screen\n'
        "export '$prefix/cubit/${screenFile}_cubit.dart';\n"
        "export '$prefix/cubit/${screenFile}_state.dart';\n"
        "export '$prefix/views/${screenFile}_view.dart';";

  final usecaseExport = hasDataLayer
      ? "\nexport './domain/entities/${screenFile}_entity.dart';"
        "\nexport './domain/usecases/${screenFile}_usecase.dart';"
      : '';

  // Guard: already exported?
  if (content.contains('${screenFile}_view.dart') ||
      content.contains('${screenFile}_bloc.dart') ||
      content.contains('${screenFile}_cubit.dart')) {
    logger.warn('⚠️  Exports for $screenFile already present in ${featureFile}_exports.dart');
    return;
  }

  final lastExport = RegExp(r"export '[^']+';").allMatches(content);
  final insertion = '$presentationExports$usecaseExport\n';
  if (lastExport.isNotEmpty) {
    final insertAt = lastExport.last.end;
    content = '${content.substring(0, insertAt)}\n$insertion${content.substring(insertAt)}';
  } else {
    content = '${content.trimRight()}\n$insertion';
  }

  barrelFile.writeAsStringSync(content);
  logger.success(
    '📦 Appended $screenFile exports to lib/features/$featureFile/${featureFile}_exports.dart',
  );
}

// ---------------------------------------------------------------------------
// Update routes
// ---------------------------------------------------------------------------
void _updateRoutes(
  Directory libDir,
  String featureFile,
  String screenClass,
  String screenFile,
  Logger logger,
) {
  _updateRoutePaths(File('${libDir.path}/routes/route_paths.dart'), screenFile, logger);
  _updateRouteNames(File('${libDir.path}/routes/route_names.dart'), screenFile, logger);
  _updateRoutesFile(
    File('${libDir.path}/routes/routes.dart'), featureFile, screenClass, screenFile, logger,
  );
}

void _updateRoutePaths(File file, String screenFile, Logger logger) {
  if (!file.existsSync()) { logger.warn('⚠️  route_paths.dart not found.'); return; }
  String content = file.readAsStringSync();
  if (content.contains("static const String $screenFile")) {
    logger.warn('⚠️  Path for $screenFile already in route_paths.dart'); return;
  }
  final brace = content.lastIndexOf('}');
  content = '${content.substring(0, brace)}'
      "  static const String $screenFile = '/$screenFile';\n"
      '${content.substring(brace)}';
  file.writeAsStringSync(content);
  logger.success('🧭 Added $screenFile to route_paths.dart');
}

void _updateRouteNames(File file, String screenFile, Logger logger) {
  if (!file.existsSync()) { logger.warn('⚠️  route_names.dart not found.'); return; }
  String content = file.readAsStringSync();
  if (content.contains("static const String $screenFile")) {
    logger.warn('⚠️  Name for $screenFile already in route_names.dart'); return;
  }
  final brace = content.lastIndexOf('}');
  content = '${content.substring(0, brace)}'
      "  static const String $screenFile = '$screenFile';\n"
      '${content.substring(brace)}';
  file.writeAsStringSync(content);
  logger.success('🧭 Added $screenFile to route_names.dart');
}

void _updateRoutesFile(
  File file, String featureFile, String screenClass, String screenFile, Logger logger,
) {
  if (!file.existsSync()) { logger.warn('⚠️  routes.dart not found.'); return; }
  String content = file.readAsStringSync();
  if (content.contains('RoutePaths.$screenFile') || content.contains('${screenClass}View()')) {
    logger.warn('⚠️  Route for $screenFile already in routes.dart'); return;
  }

  final barrelImport = "import '../features/$featureFile/${featureFile}_exports.dart';";
  if (!content.contains("features/$featureFile/")) {
    final lastImport = RegExp(r"import '[^']+';").allMatches(content);
    if (lastImport.isNotEmpty) {
      final insertAt = lastImport.last.end;
      content = '${content.substring(0, insertAt)}\n$barrelImport${content.substring(insertAt)}';
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
      content = '${content.substring(0, insertAt)}\n$newRoute${content.substring(insertAt)}';
    }
  }

  file.writeAsStringSync(content);
  logger.success('🧭 Added $screenClass route to routes.dart');
}

// ---------------------------------------------------------------------------
// Update DI
// ---------------------------------------------------------------------------
void _updateDiRegistration(
  Directory libDir,
  String featureFile,
  String featureClass,
  String screenClass,
  String screenFile,
  String stateManagement,
  bool hasDataLayer,
  Logger logger,
) {
  final controllerType = '$screenClass${stateManagement == 'bloc' ? 'Bloc' : 'Cubit'}';
  final usecaseType = '${screenClass}Usecase';
  final methodName = _toCamelCase(screenFile);
  final usecaseParam = '${methodName}Usecase';

  final registerFile = File('${libDir.path}/core/di/register_$featureFile.dart');

  if (!registerFile.existsSync()) {
    registerFile
      ..createSync(recursive: true)
      ..writeAsStringSync(
        "import 'package:get_it/get_it.dart';\n"
        "import '../../features/$featureFile/${featureFile}_exports.dart';\n"
        '\n'
        'final _sl = GetIt.instance;\n'
        '\n'
        'Future<void> ${featureFile}Dependencies() async {\n'
        '}\n',
      );
    logger.success('🔧 Created: lib/core/di/register_$featureFile.dart');
    _wireIntoDependencies(libDir, featureFile, logger);
  }

  String content = registerFile.readAsStringSync();

  // Ensure feature barrel is imported — new types (usecase, bloc) may not be individually imported
  final barrelImportLine = "import '../../features/$featureFile/${featureFile}_exports.dart';";
  if (!content.contains(barrelImportLine)) {
    final lastImport = RegExp(r"import '[^']+';").allMatches(content);
    if (lastImport.isNotEmpty) {
      final insertAt = lastImport.last.end;
      content = '${content.substring(0, insertAt)}\n$barrelImportLine${content.substring(insertAt)}';
    }
    registerFile.writeAsStringSync(content);
  }

  // Detect which sl variable the file uses — match it to avoid mixing sl / _sl
  final slVar = (content.contains('final _sl') || content.contains('_sl.register'))
      ? '_sl'
      : 'sl';

  // Datasource + repository: register once per feature (only if not already registered)
  if (hasDataLayer &&
      !content.contains('registerLazySingleton<I${featureClass}RemoteDatasource>') &&
      !content.contains('registerLazySingleton<I${featureClass}Repository>')) {
    final closingBrace = content.lastIndexOf('}');
    content =
        '${content.substring(0, closingBrace)}'
        '  // Datasource + Repository — $featureClass feature\n'
        '  $slVar.registerLazySingleton<I${featureClass}RemoteDatasource>(\n'
        '    () => ${featureClass}RemoteDatasourceImpl(dioHelper: $slVar()),\n'
        '  );\n'
        '  $slVar.registerLazySingleton<I${featureClass}Repository>(\n'
        '    () => ${featureClass}RepositoryImpl(dataSource: $slVar()),\n'
        '  );\n'
        '${content.substring(closingBrace)}';
    logger.success('🔧 Registered datasource + repository in register_$featureFile.dart');
  }

  // Usecase
  if (hasDataLayer && !content.contains('registerLazySingleton<$usecaseType>')) {
    content = registerFile.readAsStringSync(); // re-read after potential write above
    final closingBrace = content.lastIndexOf('}');
    content =
        '${content.substring(0, closingBrace)}'
        '  // UseCase — $screenClass\n'
        '  $slVar.registerLazySingleton<$usecaseType>(\n'
        '    () => $usecaseType(repository: $slVar()),\n'
        '  );\n'
        '${content.substring(closingBrace)}';
    registerFile.writeAsStringSync(content);
    logger.success('🔧 Registered $usecaseType in register_$featureFile.dart');
  }

  // Bloc / Cubit factory
  content = registerFile.readAsStringSync();
  if (content.contains('registerFactory<$controllerType>')) {
    logger.warn('⚠️  $controllerType already registered.');
    return;
  }

  final registration = hasDataLayer && stateManagement == 'bloc'
      ? '  // BLoC — $screenClass screen\n'
        '  $slVar.registerFactory<$controllerType>(\n'
        '    () => $controllerType($usecaseParam: $slVar()),\n'
        '  );\n'
      : stateManagement == 'bloc'
          ? '  // BLoC — $screenClass screen\n'
            '  $slVar.registerFactory<$controllerType>(\n'
            '    () => $controllerType(/* inject usecases */),\n'
            '  );\n'
          : '  // Cubit — $screenClass screen\n'
            '  $slVar.registerFactory<$controllerType>(\n'
            '    () => $controllerType(),\n'
            '  );\n';

  final closingBrace = content.lastIndexOf('}');
  content =
      '${content.substring(0, closingBrace)}$registration${content.substring(closingBrace)}';
  registerFile.writeAsStringSync(content);
  logger.success('🔧 Registered $controllerType in core/di/register_$featureFile.dart');
}

// ---------------------------------------------------------------------------
// Wire register_{feature}.dart into app_dependencies.dart
// ---------------------------------------------------------------------------
void _wireIntoDependencies(Directory libDir, String featureFile, Logger logger) {
  final appDepsFile = File('${libDir.path}/core/di/app_dependencies.dart');
  if (!appDepsFile.existsSync()) {
    logger.warn('⚠️  core/di/app_dependencies.dart not found. Wire manually.');
    return;
  }

  String content = appDepsFile.readAsStringSync();

  final importLine = "import 'register_$featureFile.dart';";
  if (!content.contains(importLine)) {
    final lastImport = RegExp(r"import '[^']+';").allMatches(content);
    if (lastImport.isNotEmpty) {
      final insertAt = lastImport.last.end;
      content = '${content.substring(0, insertAt)}\n$importLine${content.substring(insertAt)}';
    }
  }

  if (!content.contains('${featureFile}Dependencies()')) {
    final closingBrace = content.lastIndexOf('}');
    content =
        '${content.substring(0, closingBrace)}'
        '  await ${featureFile}Dependencies();\n'
        '${content.substring(closingBrace)}';
  }

  appDepsFile.writeAsStringSync(content);
  logger.success('🔧 Wired ${featureFile}Dependencies() into core/di/app_dependencies.dart');
}

// ---------------------------------------------------------------------------
// Create entity  (existing feature only)
// ---------------------------------------------------------------------------
void _createEntity(
  Directory featureDir,
  String featureFile,
  String screenFile,
  String screenClass,
  Logger logger,
) {
  final entityDir = Directory('${featureDir.path}/domain/entities');
  entityDir.createSync(recursive: true);

  final entityFile = File('${entityDir.path}/${screenFile}_entity.dart');
  if (entityFile.existsSync()) {
    logger.warn('⚠️  ${screenFile}_entity.dart already exists.');
    return;
  }

  entityFile
    ..createSync(recursive: true)
    ..writeAsStringSync(
      'class ${screenClass}Entity {\n'
      '  // TODO: Add properties\n'
      '  const ${screenClass}Entity();\n'
      '}\n',
    );
  logger.success(
    '🏷  Created: lib/features/$featureFile/domain/entities/${screenFile}_entity.dart',
  );
}

// ---------------------------------------------------------------------------
// Add endpoint to ApiEndPoints  (existing feature only)
// ---------------------------------------------------------------------------
void _addApiEndpoint(
  Directory libDir,
  String featureFile,
  String screenFile,
  String methodName,
  Logger logger,
) {
  final endpointsFile = File('${libDir.path}/core/constants/api_endpoints.dart');
  if (!endpointsFile.existsSync()) {
    logger.warn('⚠️  api_endpoints.dart not found. Add $methodName endpoint manually.');
    return;
  }

  String content = endpointsFile.readAsStringSync();
  if (content.contains(methodName)) {
    logger.warn('⚠️  $methodName endpoint may already exist in api_endpoints.dart.');
    return;
  }

  final lastBrace = content.lastIndexOf('}');
  content =
      '${content.substring(0, lastBrace)}'
      "  static const String $methodName = '\${baseUrl}TODO/$featureFile/$screenFile'; // TODO: replace with real path\n"
      '${content.substring(lastBrace)}';
  endpointsFile.writeAsStringSync(content);
  logger.success('🌐 Added $methodName endpoint to ApiEndPoints');
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------
String _relPath(String featureFile, String screenFile, String subFolder, String fileName) {
  return featureFile != screenFile
      ? 'lib/features/$featureFile/presentation/$screenFile/$subFolder/$fileName'
      : 'lib/features/$featureFile/presentation/$subFolder/$fileName';
}

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

String _toCamelCase(String snake) {
  final parts = snake.split('_');
  if (parts.isEmpty) return snake;
  return parts[0] +
      parts.skip(1).map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1)).join('');
}
