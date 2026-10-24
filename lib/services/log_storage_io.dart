import 'dart:io';

import 'package:path_provider/path_provider.dart';

class LogStorage {
  static File? _file;

  static Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();

    _file = File('${directory.path}/app_logs.txt');

    if (!await _file!.exists()) {
      await _file!.create(recursive: true);
    }
  }

  static Future<void> write(String message) async {
    if (_file == null) {
      await init();
    }

    await _file!.writeAsString(
      '$message\n',
      mode: FileMode.append,
      flush: true,
    );
  }

  static Future<String> read() async {
    if (_file == null) {
      await init();
    }

    if (!await _file!.exists()) {
      return '';
    }

    return _file!.readAsString();
  }
}