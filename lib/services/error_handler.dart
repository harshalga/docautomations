import 'package:flutter/material.dart';
import 'logger_service.dart';
import 'local_file_logger.dart';


class ErrorHandler {
// Generic handler used from try/catch blocks
static Future<void> handle(dynamic error, {StackTrace? stack, BuildContext? context}) async {
await LoggerService.error('Handled exception: $error', error: error, stack: stack);


// Optionally show friendly UI
if (context != null) {
try {
final messenger = ScaffoldMessenger.of(context);
messenger.showSnackBar(SnackBar(content: Text('Something went wrong. Try again.')));
} catch (e) {
// ignore
}
}
}


// If you want to collect and return the log file for sharing
static Future<String?> getLocalLogPath() async {
return await LocalFileLogger.getLogPath();
}
}