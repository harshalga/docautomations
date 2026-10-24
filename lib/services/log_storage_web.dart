import 'dart:html' as html;

class LogStorage {
  static const String _storageKey = 'prescriptor_app_logs';

  static Future<void> init() async {
    // Access browser storage to verify it is available.
    html.window.localStorage[_storageKey] ??= '';
  }

  static Future<void> write(String message) async {
    final storage = html.window.localStorage;
    final existing = storage[_storageKey] ?? '';

    storage[_storageKey] = '$existing$message\n';
  }

  static Future<String> read() async {
    return html.window.localStorage[_storageKey] ?? '';
  }
}