import 'dart:io';
import 'package:path_provider/path_provider.dart';

class AppLogger {
  static Future<File> _getLogFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/app_log.txt';
    return File(path);
  }

  static Future<void> log(String message) async {
    final file = await _getLogFile();
    final timestamp = DateTime.now().toIso8601String();
    await file.writeAsString("[$timestamp] $message\n",
        mode: FileMode.append, flush: true);
  }

  static Future<String> readLogs() async {
    try {
      final file = await _getLogFile();
      return await file.readAsString();
    } catch (e) {
      return "No logs found";
    }
  }

  static Future<void> clearLogs() async {
    final file = await _getLogFile();
    if (await file.exists()) {
      await file.writeAsString("");
    }
  }
}
