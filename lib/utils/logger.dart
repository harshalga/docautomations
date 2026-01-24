// import 'dart:io';
// import 'package:path_provider/path_provider.dart';

// class AppLogger {
//   static Future<File> _getLogFile() async {
//     final directory = await getApplicationDocumentsDirectory();
//     final path = '${directory.path}/app_log.txt';
//     return File(path);
//   }

//   static Future<void> log(String message) async {
//     final file = await _getLogFile();
//     final timestamp = DateTime.now().toIso8601String();
//     await file.writeAsString("[$timestamp] $message\n",
//         mode: FileMode.append, flush: true);
//   }

//   static Future<String> readLogs() async {
//     try {
//       final file = await _getLogFile();
//       return await file.readAsString();
//     } catch (e) {
//       return "No logs found";
//     }
//   }

//   static Future<void> clearLogs() async {
//     final file = await _getLogFile();
//     if (await file.exists()) {
//       await file.writeAsString("");
//     }
//   }
// }


import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Web-safe + Mobile-safe App Logger
class AppLogger {
  static final List<String> _webLogs = [];

  /// 📁 Mobile log file
  static Future<dynamic> _getLogTarget() async {
    if (kIsWeb) {
      return null;
    }

    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/app_log.txt';
  }

  /// 📝 Write log
  static Future<void> log(String message) async {
    final timestamp = DateTime.now().toIso8601String();
    final entry = "[$timestamp] $message";

    if (kIsWeb) {
      _webLogs.add(entry);
      debugPrint(entry);
      return;
    }

    // ignore: avoid_dynamic_calls
    final path = await _getLogTarget();
    final file = File(path);
    await file.writeAsString(
      "$entry\n",
      mode: FileMode.append,
      flush: true,
    );
  }

  /// 📖 Read logs
  static Future<String> readLogs() async {
    if (kIsWeb) {
      return _webLogs.isEmpty
          ? "No logs found"
          : _webLogs.join("\n");
    }

    try {
      // ignore: avoid_dynamic_calls
      final path = await _getLogTarget();
      final file = File(path);
      return await file.readAsString();
    } catch (_) {
      return "No logs found";
    }
  }

  /// 🧹 Clear logs
  static Future<void> clearLogs() async {
    if (kIsWeb) {
      _webLogs.clear();
      return;
    }

    // ignore: avoid_dynamic_calls
    final path = await _getLogTarget();
    final file = File(path);
    if (await file.exists()) {
      await file.writeAsString("");
    }
  }
}
