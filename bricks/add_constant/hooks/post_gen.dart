import 'dart:io';
import 'package:mason/mason.dart';

// ---------------------------------------------------------------------------
// add_constant
//
// Zero-prompt brick. Run from the project root.
//
// What it does:
//   1. Scans every .dart file inside lib/features/**/presentation/
//   2. Extracts hardcoded string literals (multi-word OR single uppercase-word)
//   3. Detects context from each line (label, hintText, title, text, toast, return)
//      and appends a semantic suffix: Label | Hint | Title | Btn | SuccessMsg |
//      ErrorMsg | WarningMsg | Msg
//   4. Writes ALL constants into lib/core/constants/app_conts.dart
//      inside AppConstants, grouped by feature using block comments:
//        // ─── Auth ──────────
//        // ─── Product ───────
//        // ─── General ───────   ← cross-feature strings
//   5. Replaces every literal in-place with AppConstants.<constName>
//   6. Adds the correct import to each modified source file
//   7. Adds export to const_exports.dart if app_conts.dart is newly created
// ---------------------------------------------------------------------------

const _commonClass = 'AppConstants';
const _commonFile  = 'lib/core/constants/app_conts.dart';
const _constExportsFile = 'lib/core/constants/const_exports.dart';

// ---------------------------------------------------------------------------
// Data
// ---------------------------------------------------------------------------

class _Replacement {
  final String ref;        // e.g. 'AppConstants.emailLabel'
  final String importFile; // always _commonFile
  const _Replacement({required this.ref, required this.importFile});
}

class _StringInfo {
  final String value;
  final Set<String?> features = {}; // null = not inside a feature
  String category = '';
  String? constName;
  bool isNew = true;

  _StringInfo(this.value);

  void addOccurrence(String? feature, String cat) {
    features.add(feature);
    if (category.isEmpty) category = cat;
  }

  /// The single feature this string belongs to, or null (cross-feature / no feature).
  String? get primaryFeature {
    final f = features.whereType<String>().toSet();
    return f.length == 1 ? f.first : null;
  }
}

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

void run(HookContext context) async {
  final logger = context.logger;
  final progress = logger.progress('Scanning presentation layer for hardcoded strings');

  try {
    if (!Directory('lib').existsSync()) {
      progress.fail('lib/ directory not found — run from project root');
      return;
    }

    final packageName = _readPackageName();
    if (packageName == null) {
      progress.fail('Could not read package name from pubspec.yaml');
      return;
    }

    // ── 1. Collect presentation-layer dart files ───────────────────────────
    final targetFiles = <File>[];
    await for (final entity in Directory('lib').list(recursive: true)) {
      if (entity is! File) continue;
      final rel = entity.path.replaceAll(r'\', '/');
      if (_shouldScan(rel)) targetFiles.add(entity);
    }

    if (targetFiles.isEmpty) {
      progress.complete('No presentation files found to scan');
      return;
    }

    // ── 2. Extract strings with feature + context info ─────────────────────
    final stringMap = <String, _StringInfo>{};

    for (final file in targetFiles) {
      final rel     = file.path.replaceAll(r'\', '/');
      final feature = _featureFromPath(rel);
      final found   = _extractStringsWithContext(file); // value → category

      for (final entry in found.entries) {
        stringMap
            .putIfAbsent(entry.key, () => _StringInfo(entry.key))
            .addOccurrence(feature, entry.value);
      }
    }

    if (stringMap.isEmpty) {
      progress.complete('No eligible hardcoded strings found');
      return;
    }

    progress.complete('Found ${stringMap.length} unique string(s)');

    // ── 3. Read existing constants to avoid duplication ────────────────────
    final existingConstants = _readExistingConstants(_commonFile); // value → name
    final usedNames = existingConstants.values.toSet();

    // ── 4. Assign camelCase names ──────────────────────────────────────────
    for (final info in stringMap.values) {
      if (existingConstants.containsKey(info.value)) {
        info.constName = existingConstants[info.value];
        info.isNew = false;
        continue;
      }
      final name = _uniqueName(_buildName(info.value, info.category), usedNames);
      usedNames.add(name);
      info.constName = name;
      info.isNew = true;
    }

    // ── 5. Write constants file (grouped by feature, block comments) ───────
    final newInfos = stringMap.values.where((i) => i.isNew).toList();

    if (newInfos.isNotEmpty) {
      // Group new entries by feature
      final byFeature = <String?, List<_StringInfo>>{};
      for (final info in newInfos) {
        byFeature.putIfAbsent(info.primaryFeature, () => []).add(info);
      }

      final isCreated = _appendToConstantsFile(_commonFile, _commonClass, byFeature, logger);
      logger.success('✓ Added ${newInfos.length} constant(s) to $_commonFile');
      if (isCreated) _updateConstExports(_commonFile, logger);
    } else {
      logger.info('ℹ All strings already have constants');
    }

    // ── 6. Replace literals in source files ───────────────────────────────
    final replacements = <String, _Replacement>{};
    for (final info in stringMap.values) {
      if (info.constName != null) {
        replacements[info.value] = _Replacement(
          ref: '$_commonClass.${info.constName!}',
          importFile: _commonFile,
        );
      }
    }

    var filesModified = 0;
    for (final file in targetFiles) {
      if (_replaceInFile(file, replacements, packageName)) {
        logger.info('  ✓ ${file.path.replaceAll(r'\', '/')}');
        filesModified++;
      }
    }

    if (filesModified > 0) {
      logger.success('✓ Replaced strings in $filesModified file(s)');
    } else {
      logger.info('ℹ No replacements needed in source files');
    }
  } catch (e, st) {
    progress.fail('Error: $e');
    logger.err(st.toString());
  }
}

// ---------------------------------------------------------------------------
// File filter
// ---------------------------------------------------------------------------

bool _shouldScan(String rel) {
  if (!rel.endsWith('.dart')) return false;
  if (rel.endsWith('.g.dart') || rel.endsWith('.freezed.dart')) return false;
  if (rel.endsWith('_exports.dart')) return false;
  return rel.contains('/features/') && rel.contains('/presentation/');
}

/// 'lib/features/auth/presentation/...' → 'auth'
String? _featureFromPath(String rel) {
  final m = RegExp(r'/features/([^/]+)/').firstMatch(rel);
  return m?.group(1);
}

// ---------------------------------------------------------------------------
// String extraction
// ---------------------------------------------------------------------------

Map<String, String> _extractStringsWithContext(File file) {
  final results = <String, String>{};
  for (final rawLine in file.readAsStringSync().split('\n')) {
    final line = rawLine.trim();
    if (line.startsWith('import ') || line.startsWith('export ')) continue;
    if (line.startsWith('//') || line.startsWith('*') || line.startsWith('/*')) continue;

    final category = _categorySuffix(line);

    for (final m in RegExp(r"'((?:[^'\\]|\\.)*)'").allMatches(line)) {
      final value = _unescape(m.group(1)!);
      if (_isEligible(value)) results.putIfAbsent(value, () => category);
    }
    for (final m in RegExp(r'"((?:[^"\\]|\\.)*)"').allMatches(line)) {
      final value = _unescape(m.group(1)!);
      if (_isEligible(value)) results.putIfAbsent(value, () => category);
    }
  }
  return results;
}

bool _isEligible(String s) {
  if (s.length < 2) return false;
  if (s.contains(r'$')) return false;
  if (s.contains('://')) return false;
  if (s.contains('package:')) return false;
  if (s.startsWith('/')) return false;
  if (RegExp(r'^[\d\s.\-+,]+$').hasMatch(s)) return false;

  // Multi-word strings: eligible if length >= 4
  if (s.contains(' ')) return s.length >= 4;

  // Single-word: only uppercase-start display labels ('Email', 'SignIn')
  return s[0] == s[0].toUpperCase() && s[0] != s[0].toLowerCase();
}

// ---------------------------------------------------------------------------
// Category detection
// ---------------------------------------------------------------------------

String _categorySuffix(String line) {
  final lower = line.toLowerCase().trim();
  if (lower.contains('hinttext:')) return 'Hint';
  if (lower.contains('label:')) return 'Label';
  if (lower.contains('title:')) return 'Title';
  if (lower.contains('errortext:') || lower.contains('errormessage:')) return 'ErrorText';
  if (lower.contains('text:')) return 'Btn';
  if (lower.contains('showsuccesstop') ||
      lower.contains('showsuccessbottom') ||
      lower.contains('showsuccess(')) { return 'SuccessMsg'; }
  if (lower.contains('showerrortop') ||
      lower.contains('showerrorbottom') ||
      lower.contains('showerror(')) { return 'ErrorMsg'; }
  if (lower.contains('showwarning')) return 'WarningMsg';
  if (lower.startsWith('return ')) return 'Msg';
  return '';
}

// ---------------------------------------------------------------------------
// Constant name generation
// ---------------------------------------------------------------------------

String _buildName(String value, String category) {
  final rawWords = value
      .replaceAll(RegExp(r"[^a-zA-Z0-9\s]"), ' ')
      .trim()
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .expand(_splitCamelCase)
      .take(5)
      .toList();

  if (rawWords.isEmpty) return 'constant';

  final base = rawWords.first.toLowerCase() +
      rawWords
          .skip(1)
          .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
          .join('');

  return category.isEmpty ? base : '$base$category';
}

List<String> _splitCamelCase(String word) {
  final result = <String>[];
  final buf = StringBuffer();
  for (var i = 0; i < word.length; i++) {
    final ch = word[i];
    if (i > 0 && ch == ch.toUpperCase() && ch != ch.toLowerCase() && buf.isNotEmpty) {
      result.add(buf.toString());
      buf.clear();
    }
    buf.write(ch);
  }
  if (buf.isNotEmpty) result.add(buf.toString());
  return result.isEmpty ? [word] : result;
}

String _uniqueName(String name, Set<String> used) {
  if (!used.contains(name)) return name;
  var i = 2;
  while (used.contains('$name$i')) { i++; }
  return '$name$i';
}

// ---------------------------------------------------------------------------
// AppConstants file I/O
// ---------------------------------------------------------------------------

/// Reads existing `static const String name = 'value';` (or "value") entries.
/// Returns {value → name}.
Map<String, String> _readExistingConstants(String filePath) {
  final file = File(filePath);
  if (!file.existsSync()) return {};
  final content = file.readAsStringSync();
  final result = <String, String>{};
  // Single-quoted form
  for (final m in RegExp(r"static const \w+ (\w+) = '((?:[^'\\]|\\.)*)';" ).allMatches(content)) {
    result[_unescape(m.group(2)!)] = m.group(1)!;
  }
  // Double-quoted form (manually written)
  for (final m in RegExp(r'static const \w+ (\w+) = "((?:[^"\\]|\\.)*)";').allMatches(content)) {
    result[_unescape(m.group(2)!)] = m.group(1)!;
  }
  return result;
}

/// Writes/appends constants to [filePath], grouped by feature with block comments.
/// Creates the file if it doesn't exist.
/// Returns true if the file was newly created.
bool _appendToConstantsFile(
  String filePath,
  String className,
  Map<String?, List<_StringInfo>> byFeature,
  Logger logger,
) {
  final file = File(filePath);
  final isNew = !file.existsSync();
  final existing = isNew ? '' : file.readAsStringSync();

  // Safety: drop any entry already present by value or name
  final filtered = <String?, List<_StringInfo>>{};
  for (final entry in byFeature.entries) {
    final safe = entry.value.where((info) {
      if (existing.contains("'${_esc(info.value)}'")) return false;
      if (existing.contains('"${info.value}"')) return false;
      if (RegExp('\\b${RegExp.escape(info.constName!)}\\b').hasMatch(existing)) return false;
      return true;
    }).toList();
    if (safe.isNotEmpty) filtered[entry.key] = safe;
  }

  if (filtered.isEmpty) return false;

  String content;
  if (isNew) {
    final header =
        '// $className — auto-generated by add_constant brick.\n'
        '// Run `mason make add_constant` to regenerate.\n\n';
    content = '${header}class $className {\n${_buildBody(filtered)}}\n';
  } else {
    content = _insertIntoExisting(existing, filtered);
  }

  file
    ..createSync(recursive: true)
    ..writeAsStringSync(content);
  return isNew;
}

/// Builds the inner body of the class for a brand-new file.
String _buildBody(Map<String?, List<_StringInfo>> byFeature) {
  final buf = StringBuffer();
  // null (General) first, then alphabetical
  final keys = byFeature.keys.toList()
    ..sort((a, b) {
      if (a == null) return -1;
      if (b == null) return 1;
      return a.compareTo(b);
    });
  for (final feature in keys) {
    final label = feature == null ? 'General' : _toPascalCase(feature);
    final dashes = '─' * (50 - label.length);
    buf.writeln('  // ─── $label $dashes');
    for (final info in byFeature[feature]!) {
      buf.writeln("  static const String ${info.constName} = '${_esc(info.value)}';");
    }
    buf.writeln();
  }
  return buf.toString();
}

/// Inserts new entries into an existing constants file.
/// Finds the right feature block and appends there; creates the block if missing.
String _insertIntoExisting(String existing, Map<String?, List<_StringInfo>> byFeature) {
  var content = existing;

  for (final entry in byFeature.entries) {
    final feature = entry.key;
    final infos = entry.value;
    final label = feature == null ? 'General' : _toPascalCase(feature);
    final blockMarker = '// ─── $label';

    final newLines = infos
        .map((i) => "  static const String ${i.constName} = '${_esc(i.value)}';")
        .join('\n');

    if (content.contains(blockMarker)) {
      // Find the end of this block: next block comment or closing }
      final blockStart = content.indexOf(blockMarker);
      final nextBlock = content.indexOf('\n  // ───', blockStart + blockMarker.length);
      final closingBrace = content.lastIndexOf('}');
      final insertPos = nextBlock != -1 ? nextBlock : closingBrace;
      // Remove trailing blank lines before insertion point, then append
      final before = content.substring(0, insertPos).trimRight();
      content = '$before\n$newLines${content.substring(insertPos)}';
    } else {
      // Append a new section before the closing }
      final closingIdx = content.lastIndexOf('}');
      final before = content.substring(0, closingIdx).trimRight();
      final dashes = '─' * (50 - label.length);
      content = '$before\n\n  // ─── $label $dashes\n$newLines\n}\n';
    }
  }

  return content;
}

/// Adds an export line for [filePath] to const_exports.dart if not already there.
void _updateConstExports(String filePath, Logger logger) {
  final exportsFile = File(_constExportsFile);
  if (!exportsFile.existsSync()) {
    logger.warn('const_exports.dart not found — skipping barrel update');
    return;
  }
  final fileName = filePath.split('/').last;
  final exportLine = "export '$fileName';";
  var content = exportsFile.readAsStringSync();
  if (content.contains(exportLine)) return;
  exportsFile.writeAsStringSync('${content.trimRight()}\n$exportLine\n');
  logger.success('✓ Updated const_exports.dart');
}

// ---------------------------------------------------------------------------
// In-file replacement
// ---------------------------------------------------------------------------

bool _replaceInFile(
  File file,
  Map<String, _Replacement> replacements,
  String packageName,
) {
  var content = file.readAsStringSync();
  var modified = false;
  var needsImport = false;

  for (final entry in replacements.entries) {
    final value = entry.key;
    final ref   = entry.value.ref;

    final singleForm = "'${_esc(value)}'";
    final doubleForm = '"$value"';

    if (content.contains(singleForm)) {
      content = content.replaceAll(singleForm, ref);
      needsImport = true;
      modified = true;
    }
    if (content.contains(doubleForm)) {
      content = content.replaceAll(doubleForm, ref);
      needsImport = true;
      modified = true;
    }
  }

  if (!modified) return false;

  if (needsImport) {
    final pkgPath   = _commonFile.replaceFirst('lib/', '');
    final importLine = "import 'package:$packageName/$pkgPath';";
    if (!content.contains(pkgPath)) {
      final lines = content.split('\n');
      var lastImport = -1;
      for (var i = 0; i < lines.length; i++) {
        if (lines[i].trimLeft().startsWith('import ')) lastImport = i;
      }
      if (lastImport >= 0) {
        lines.insert(lastImport + 1, importLine);
      } else {
        lines.insert(0, importLine);
      }
      content = lines.join('\n');
    }
  }

  file.writeAsStringSync(content);
  return true;
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

String _esc(String s) => s.replaceAll(r'\', r'\\').replaceAll("'", r"\'");

String _unescape(String s) =>
    s.replaceAll(r"\'", "'").replaceAll(r'\"', '"').replaceAll(r'\\', r'\');

String? _readPackageName() {
  final pubspec = File('pubspec.yaml');
  if (!pubspec.existsSync()) return null;
  final m = RegExp(r'^name:\s*(\S+)', multiLine: true).firstMatch(pubspec.readAsStringSync());
  return m?.group(1);
}

String _toPascalCase(String snake) {
  return snake.split('_').map((w) {
    if (w.isEmpty) return '';
    return w[0].toUpperCase() + w.substring(1).toLowerCase();
  }).join('');
}
