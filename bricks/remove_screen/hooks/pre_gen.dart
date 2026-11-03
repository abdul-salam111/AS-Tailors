import 'dart:io';
import 'package:mason/mason.dart';

Future<void> run(HookContext context) async {
  final logger = context.logger;

  final featureName = (context.vars['feature_name'] as String).trim();
  final screenName = (context.vars['screen_name'] as String).trim();
  final confirm = context.vars['confirm'] == true;

  final featureFile = _toSnakeCase(featureName);
  final screenFile = _toSnakeCase(screenName);

  final libDir = Directory('lib');
  final featureDir = Directory('${libDir.path}/features/$featureFile');
  if (!featureDir.existsSync()) {
    logger.err(
      '❌ Feature "$featureFile" not found at lib/features/$featureFile — '
      'nothing to remove.',
    );
    exit(1);
  }

  final useScreenFolder = featureFile != screenFile;
  final screenBaseDir = useScreenFolder
      ? Directory('${featureDir.path}/presentation/$screenFile')
      : Directory('${featureDir.path}/presentation');
  final viewFile = File('${screenBaseDir.path}/views/${screenFile}_view.dart');

  if (!viewFile.existsSync()) {
    logger.err(
      '❌ ${viewFile.path} doesn\'t exist — nothing to remove. Check the '
      'feature/screen names (e.g. `mason make remove_screen '
      '--feature_name auth --screen_name forgot_password`).',
    );
    exit(1);
  }

  // Scan the rest of lib/ for stray references outside files this brick
  // auto-fixes, and warn about them — same pattern as create_feature's own
  // splice targets, so anything outside those is unexpected hand-written
  // code depending on this screen.
  final autoFixedFiles = <String>{
    'lib/routes/route_paths.dart',
    'lib/routes/route_names.dart',
    'lib/routes/routes.dart',
    'lib/features/$featureFile/${featureFile}_exports.dart',
    'lib/core/di/register_$featureFile.dart',
    'lib/core/constants/api_endpoints.dart',
  };

  final externalRefs = <String>[];
  if (libDir.existsSync()) {
    for (final entity in libDir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final relPath = entity.path.replaceAll('\\', '/');
      if (relPath.startsWith(screenBaseDir.path.replaceAll('\\', '/'))) {
        continue; // inside the screen folder being deleted
      }
      final normalizedRel =
          relPath.substring(relPath.indexOf('lib/'));
      if (autoFixedFiles.contains(normalizedRel)) continue;

      final content = entity.readAsStringSync();
      if (content.contains('${screenFile}_bloc.dart') ||
          content.contains('${screenFile}_cubit.dart') ||
          content.contains('${screenFile}_view.dart') ||
          content.contains('${_toPascalCase(screenName)}View(')) {
        externalRefs.add(normalizedRel);
      }
    }
  }

  if (externalRefs.isNotEmpty) {
    logger.warn(
      '⚠️  The following files reference "$screenFile" outside what this '
      'brick auto-fixes — you may need to update them manually:',
    );
    for (final path in externalRefs) {
      logger.warn('   - $path');
    }
  }

  if (!confirm) {
    logger.err(
      '❌ Refusing to delete without confirmation. Re-run with '
      '--confirm=true (or answer "yes" to the prompt) once you\'re sure.',
    );
    exit(1);
  }
}

String _toPascalCase(String text) => text
    .split('_')
    .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
    .join('');

String _toSnakeCase(String text) => text
    .replaceAllMapped(RegExp(r'[A-Z]'), (match) => '_${match.group(0)}')
    .toLowerCase()
    .replaceAll(RegExp(r'^_'), '');
