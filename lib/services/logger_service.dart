import 'dart:developer' as developer;
import 'dart:io';
import 'package:logger/logger.dart';
import 'local_file_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';


class LoggerService {
  static File? _logFile;
static final Logger _logger = Logger(
printer: PrettyPrinter(methodCount: 3, errorMethodCount: 5, lineLength: 80),
);



/// Initialize log file (call once on app start)
  static Future<void> init() async {
    if (kIsWeb) return;

    final dir = await getApplicationDocumentsDirectory();
    final logDir = Directory('${dir.path}');///logs');

    if (!await logDir.exists()) {
      await logDir.create(recursive: true);
    }

    _logFile = File('${logDir.path}/app_logs.txt');

    if (!await _logFile!.exists()) {
      await _logFile!.create();
    }
  }

// Simple wrappers
static Future<void> info(String message) async {
_logger.i(message);
await LocalFileLogger.write('INFO: $message');
}


static Future<void> debug(String message) async {
_logger.d(message);
await LocalFileLogger.write('DEBUG: $message');
}


static Future<void> warn(String message) async {
_logger.w(message);
await LocalFileLogger.write('WARN: $message');
}


static Future<void> error(String message, {dynamic error, StackTrace? stack}) async {
_logger.e(message, error, stack);
await LocalFileLogger.write('ERROR: $message\nError: $error\nStack: $stack');


// Also send to platform logs for integration with adb or crash tools
developer.log(message, name: 'app.logger', error: error, stackTrace: stack);
}


static Future<void> logFlutterError(FlutterErrorDetails details) async {
final msg = 'FlutterError: ${details.exceptionAsString()}';
_logger.e(msg, details.exception, details.stack);
await LocalFileLogger.write('FLUTTER_ERROR: $msg\nStack: ${details.stack}');
}


static Future<void> logZonedError(dynamic error, StackTrace stack) async {
final msg = 'Uncaught zoned error: $error';
_logger.e(msg, error, stack);
await LocalFileLogger.write('ZONED_ERROR: $msg\nStack: $stack');
}


/// ✅ THIS IS WHAT YOU ASKED FOR
  static Future<File?> getLogFile() async {
    if (kIsWeb) return null;

    if (_logFile == null || !await _logFile!.exists()) {
      return null;
    }

    // Return only if file has content
    final length = await _logFile!.length();
    if (length == 0) return null;

    return _logFile;
  }

}