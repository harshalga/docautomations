import 'dart:developer' as developer;
import 'package:logger/logger.dart';
import 'local_file_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


class LoggerService {
static final Logger _logger = Logger(
printer: PrettyPrinter(methodCount: 3, errorMethodCount: 5, lineLength: 80),
);


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
}