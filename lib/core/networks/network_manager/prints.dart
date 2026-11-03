import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';

void printValue(dynamic value, {String tag = ''}) {
  try {
    final decodedJSON = json.decode(value.toString()) as Map<String, dynamic>;
    log("JSON OUTPUT: $tag ${const JsonEncoder.withIndent('  ').convert(decodedJSON)}\n");
  } catch (_) {
    if (value is Map) {
      log("JSON OUTPUT: $tag ${const JsonEncoder.withIndent('  ').convert(value)}\n");
    } else {
      if (kDebugMode) {
        log("PRINT OUTPUT: $tag $value\n\n");
      }
    }
  }
}
