import 'dart:io';
import 'package:mason/mason.dart';

// The inverse of add_screen's post_gen.dart. Reverses its exact generated
// shapes (read directly from bricks/add_screen/hooks/post_gen.dart) via
// literal string/line matching — this branch's bricks don't use
// GENERATED_..._START/END markers, so removal has to mirror the precise
// insert shape rather than relying on an anchor comment.
Future<void> run(HookContext context) async {
  final logger = context.logger;

  final featureName = (context.vars['feature_name'] as String).trim();
  final screenName = (context.vars['screen_name'] as String).trim();

  final featureClass = _toPascalCase(featureName);
  final featureFile = _toSnakeCase(featureName);
  final screenClass = _toPascalCase(screenName);
  final screenFile = _toSnakeCase(screenName);
  final methodName = _toCamelCase(screenFile);

  final libDir = Directory('lib');
  final featureDir = Directory('${libDir.path}/features/$featureFile');
  final useScreenFolder = featureFile != screenFile;
  final screenBaseDir = useScreenFolder
      ? Directory('${featureDir.path}/presentation/$screenFile')
      : Directory('${featureDir.path}/presentation');

  final hasDataLayer = Directory('${featureDir.path}/data').existsSync() ||
      Directory('${featureDir.path}/domain').existsSync();

  final isBloc =
      File('${screenBaseDir.path}/blocs/${screenFile}_bloc.dart').existsSync();
  final isCubit =
      File('${screenBaseDir.path}/cubit/${screenFile}_cubit.dart').existsSync();
  final stateManagement = isBloc ? 'bloc' : (isCubit ? 'cubit' : 'bloc');

  logger.info('\n🗑️  Removing screen "$screenName" from feature "$featureName"');

  if (hasDataLayer) {
    _removeDatasourceMethod(featureDir, featureFile, featureClass, methodName, logger);
    _removeRepositoryMethod(
        featureDir, featureFile, screenFile, screenClass, methodName, logger);
    _removeUsecaseFile(featureDir, screenFile, logger);
    _removeEntityFile(featureDir, screenFile, logger);
    _removeApiEndpoint(libDir, methodName, logger);
  }

  _removeDiRegistration(
      libDir, featureFile, screenClass, screenFile, methodName, stateManagement, logger);
  _removeRoutes(libDir, screenFile, screenClass, logger);
  _removeBarrelExports(
      featureDir, featureFile, screenFile, stateManagement, hasDataLayer, logger);

  // Delete presentation files/folder
  if (useScreenFolder) {
    if (screenBaseDir.existsSync()) {
      screenBaseDir.deleteSync(recursive: true);
      logger.success('🗑️  Deleted: ${_rel(screenBaseDir.path)}');
    }
  } else {
    final stateFolder = stateManagement == 'bloc' ? 'blocs' : 'cubit';
    for (final f in [
      File('${screenBaseDir.path}/$stateFolder/${screenFile}_bloc.dart'),
      File('${screenBaseDir.path}/$stateFolder/${screenFile}_cubit.dart'),
      File('${screenBaseDir.path}/$stateFolder/${screenFile}_event.dart'),
      File('${screenBaseDir.path}/$stateFolder/${screenFile}_state.dart'),
      File('${screenBaseDir.path}/views/${screenFile}_view.dart'),
    ]) {
      if (f.existsSync()) {
        f.deleteSync();
        logger.success('🗑️  Deleted: ${_rel(f.path)}');
      }
    }
  }

  _runDartFormat(logger);

  logger.success('\n✅ $screenClass screen removed from $featureClass.');
}

// ---------------------------------------------------------------------------
// Datasource method — reverses add_screen's _addDatasourceMethod exactly
// ---------------------------------------------------------------------------
void _removeDatasourceMethod(
  Directory featureDir,
  String featureFile,
  String featureClass,
  String methodName,
  Logger logger,
) {
  final dsFile = File(
    '${featureDir.path}/data/datasources/${featureFile}_remote_datasource/${featureFile}_remote_datasource.dart',
  );
  if (!dsFile.existsSync()) return;

  String content = dsFile.readAsStringSync();

  final interfaceLine = '  Future<dynamic> $methodName();\n';
  if (content.contains(interfaceLine)) {
    content = content.replaceFirst(interfaceLine, '');
  }

  final implBlock = '\n  @override\n'
      '  Future<dynamic> $methodName() async {\n'
      '    // TODO: implement $methodName API call\n'
      "    throw UnimplementedError('$methodName not implemented');\n"
      '  }\n';
  if (content.contains(implBlock)) {
    content = content.replaceFirst(implBlock, '');
    dsFile.writeAsStringSync(content);
    logger.success('🔌 Removed $methodName() from I${featureClass}RemoteDatasource');
  }
}

// ---------------------------------------------------------------------------
// Repository method — reverses add_screen's _addRepositoryMethod exactly
// ---------------------------------------------------------------------------
void _removeRepositoryMethod(
  Directory featureDir,
  String featureFile,
  String screenFile,
  String screenClass,
  String methodName,
  Logger logger,
) {
  final repoInterfaceFile =
      File('${featureDir.path}/domain/repositories/${featureFile}_repository.dart');
  if (repoInterfaceFile.existsSync()) {
    String content = repoInterfaceFile.readAsStringSync();
    final methodLine =
        '  Future<Either<Failure, ${screenClass}Entity>> $methodName();\n';
    if (content.contains(methodLine)) {
      content = content.replaceFirst(methodLine, '');
      final entityImport = "import '../entities/${screenFile}_entity.dart';";
      content = content.replaceFirst('\n$entityImport', '');
      content = content.replaceFirst('$entityImport\n', '');
      repoInterfaceFile.writeAsStringSync(content);
      logger.success('🗂  Removed $methodName() from repository interface');
    }
  }

  final repoImplFile =
      File('${featureDir.path}/data/repositories_impl/${featureFile}_repository_impl.dart');
  if (repoImplFile.existsSync()) {
    String content = repoImplFile.readAsStringSync();
    final implBlock = '\n  @override\n'
        '  Future<Either<Failure, ${screenClass}Entity>> $methodName() {\n'
        '    return execute(\n'
        '      call: () async {\n'
        '        final result = await _dataSource.$methodName();\n'
        '        // TODO: map result to ${screenClass}Entity\n'
        '        return ${screenClass}Entity();\n'
        '      },\n'
        '    );\n'
        '  }\n';
    if (content.contains(implBlock)) {
      content = content.replaceFirst(implBlock, '');
      final entityImport = "import '../../domain/entities/${screenFile}_entity.dart';";
      content = content.replaceFirst('\n$entityImport', '');
      content = content.replaceFirst('$entityImport\n', '');
      repoImplFile.writeAsStringSync(content);
      logger.success('🗂  Removed $methodName() from repository impl');
    }
  }
}

void _removeUsecaseFile(Directory featureDir, String screenFile, Logger logger) {
  final file = File('${featureDir.path}/domain/usecases/${screenFile}_usecase.dart');
  if (file.existsSync()) {
    file.deleteSync();
    logger.success('🗑️  Deleted: ${_rel(file.path)}');
  }
}

void _removeEntityFile(Directory featureDir, String screenFile, Logger logger) {
  final file = File('${featureDir.path}/domain/entities/${screenFile}_entity.dart');
  if (file.existsSync()) {
    file.deleteSync();
    logger.success('🗑️  Deleted: ${_rel(file.path)}');
  }
}

void _removeApiEndpoint(Directory libDir, String methodName, Logger logger) {
  final file = File('${libDir.path}/core/constants/api_endpoints.dart');
  if (!file.existsSync()) return;
  final updated = _removeLineContaining(
    file.readAsStringSync(),
    'static const String $methodName =',
  );
  file.writeAsStringSync(updated);
  logger.success('🌐 Removed $methodName endpoint from ApiEndPoints');
}

// ---------------------------------------------------------------------------
// DI — reverses add_screen's _updateDiRegistration exactly
// ---------------------------------------------------------------------------
void _removeDiRegistration(
  Directory libDir,
  String featureFile,
  String screenClass,
  String screenFile,
  String methodName,
  String stateManagement,
  Logger logger,
) {
  final registerFile = File('${libDir.path}/core/di/register_$featureFile.dart');
  if (!registerFile.existsSync()) return;

  String content = registerFile.readAsStringSync();
  final slVar =
      (content.contains('final _sl') || content.contains('_sl.register')) ? '_sl' : 'sl';

  final controllerType = '$screenClass${stateManagement == 'bloc' ? 'Bloc' : 'Cubit'}';
  final usecaseParam = '${methodName}Usecase';

  final blocBlock = '  // BLoC — $screenClass screen\n'
      '  $slVar.registerFactory<$controllerType>(\n'
      '    () => $controllerType($usecaseParam: $slVar()),\n'
      '  );\n';
  final blocBlockNoUsecase = '  // BLoC — $screenClass screen\n'
      '  $slVar.registerFactory<$controllerType>(\n'
      '    () => $controllerType(/* inject usecases */),\n'
      '  );\n';
  final cubitBlock = '  // Cubit — $screenClass screen\n'
      '  $slVar.registerFactory<$controllerType>(\n'
      '    () => $controllerType(),\n'
      '  );\n';

  var changed = false;
  for (final block in [blocBlock, blocBlockNoUsecase, cubitBlock]) {
    if (content.contains(block)) {
      content = content.replaceFirst(block, '');
      changed = true;
    }
  }

  final usecaseType = '${screenClass}Usecase';
  final usecaseBlock = '  // UseCase — $screenClass\n'
      '  $slVar.registerLazySingleton<$usecaseType>(\n'
      '    () => $usecaseType(repository: $slVar()),\n'
      '  );\n';
  if (content.contains(usecaseBlock)) {
    content = content.replaceFirst(usecaseBlock, '');
    changed = true;
  }

  if (changed) {
    registerFile.writeAsStringSync(content);
    logger.success('🔧 Removed $controllerType registration from register_$featureFile.dart');
  }
}

// ---------------------------------------------------------------------------
// Routes — reverses add_screen's _updateRoutes exactly. Does NOT touch the
// feature barrel import in routes.dart — other screens in this feature may
// still need it.
// ---------------------------------------------------------------------------
void _removeRoutes(Directory libDir, String screenFile, String screenClass, Logger logger) {
  final pathsFile = File('${libDir.path}/routes/route_paths.dart');
  if (pathsFile.existsSync()) {
    final updated = _removeLineContaining(
      pathsFile.readAsStringSync(),
      'static const String $screenFile =',
    );
    pathsFile.writeAsStringSync(updated);
    logger.success('🧭 Removed $screenFile from route_paths.dart');
  }

  final namesFile = File('${libDir.path}/routes/route_names.dart');
  if (namesFile.existsSync()) {
    final updated = _removeLineContaining(
      namesFile.readAsStringSync(),
      'static const String $screenFile =',
    );
    namesFile.writeAsStringSync(updated);
    logger.success('🧭 Removed $screenFile from route_names.dart');
  }

  final routesFile = File('${libDir.path}/routes/routes.dart');
  if (routesFile.existsSync()) {
    String content = routesFile.readAsStringSync();
    final block = '      GoRoute(\n'
        '        path: RoutePaths.$screenFile,\n'
        '        name: RouteNames.$screenFile,\n'
        '        builder: (context, state) => const ${screenClass}View(),\n'
        '      ),';
    if (content.contains(block)) {
      content = content.replaceFirst('\n$block', '');
      content = content.replaceFirst(block, '');
      routesFile.writeAsStringSync(content);
      logger.success('🧭 Removed $screenClass route from routes.dart');
    } else {
      logger.warn('⚠️  Could not find the exact GoRoute block for $screenClass — remove it manually.');
    }
  }
}

// ---------------------------------------------------------------------------
// Barrel exports — reverses add_screen's _updateFeatureBarrel
// ---------------------------------------------------------------------------
void _removeBarrelExports(
  Directory featureDir,
  String featureFile,
  String screenFile,
  String stateManagement,
  bool hasDataLayer,
  Logger logger,
) {
  final barrelFile = File('${featureDir.path}/${featureFile}_exports.dart');
  if (!barrelFile.existsSync()) return;

  String content = barrelFile.readAsStringSync();
  content = _removeLineContaining(content, '// Presentation — $screenFile screen');
  content = _removeLineContaining(content, '${screenFile}_bloc.dart');
  content = _removeLineContaining(content, '${screenFile}_event.dart');
  content = _removeLineContaining(content, '${screenFile}_state.dart');
  content = _removeLineContaining(content, '${screenFile}_cubit.dart');
  content = _removeLineContaining(content, '${screenFile}_view.dart');
  if (hasDataLayer) {
    content = _removeLineContaining(content, '${screenFile}_entity.dart');
    content = _removeLineContaining(content, '${screenFile}_usecase.dart');
  }
  barrelFile.writeAsStringSync(content);
  logger.success('📦 Removed $screenFile exports from ${featureFile}_exports.dart');
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------
String _removeLineContaining(String content, String needle) {
  final lines = content.split('\n');
  return lines.where((line) => !line.contains(needle)).join('\n');
}

void _runDartFormat(Logger logger) {
  try {
    final result = Process.runSync('dart', ['format', 'lib']);
    if (result.exitCode == 0) {
      logger.success('🎨 Formatted updated files');
    } else {
      logger.warn('⚠️  dart format failed: ${result.stderr}');
    }
  } catch (e) {
    logger.warn('⚠️  Could not run dart format: $e');
  }
}

String _rel(String path) {
  final normalized = path.replaceAll('\\', '/');
  final idx = normalized.indexOf('lib/');
  return idx == -1 ? normalized : normalized.substring(idx);
}

String _toPascalCase(String text) => text
    .split('_')
    .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
    .join('');

String _toSnakeCase(String text) => text
    .replaceAllMapped(RegExp(r'[A-Z]'), (match) => '_${match.group(0)}')
    .toLowerCase()
    .replaceAll(RegExp(r'^_'), '');

String _toCamelCase(String snake) {
  final parts = snake.split('_');
  if (parts.isEmpty) return snake;
  return parts[0] +
      parts.skip(1).map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1)).join('');
}
