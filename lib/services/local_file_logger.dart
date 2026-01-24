import 'dart:io';
import 'package:path_provider/path_provider.dart';


class LocalFileLogger {
static File? _file;


static Future<void> init() async {
final dir = await getApplicationDocumentsDirectory();
_file = File('${dir.path}/app_logs.txt');


if (!await _file!.exists()) {
await _file!.create(recursive: true);
}


final header = '--- App logs started at ${DateTime.now().toIso8601String()} ---\n';
await _file!.writeAsString(header, mode: FileMode.append);
}


static Future<void> write(String text) async {
try {
if (_file == null) await init();
final timestamp = DateTime.now().toIso8601String();
await _file!.writeAsString('$timestamp - $text\n', mode: FileMode.append);
} catch (e) {
// If file logging fails, ignore to avoid crash loop.
}
}


// Optional: expose logs for sharing
static Future<String?> getLogPath() async {
if (_file == null) await init();
return _file?.path;
}
}