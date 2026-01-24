import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../services/local_file_logger.dart';


class ShareLogsScreen extends StatefulWidget {
@override
State<ShareLogsScreen> createState() => _ShareLogsScreenState();
}


class _ShareLogsScreenState extends State<ShareLogsScreen> {
String? logPath;


@override
void initState() {
super.initState();
_loadLogFile();
}


Future<void> _loadLogFile() async {
final path = await LocalFileLogger.getLogPath();
setState(() => logPath = path);
}


Future<void> _shareLogs() async {
if (logPath == null) return;
await Share.shareXFiles([XFile(logPath!)], text: 'App logs attached');
}


@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: Text('Share App Logs')),
body: Center(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Text(logPath == null ? 'Loading log file…' : 'Log file ready.'),
SizedBox(height: 20),
ElevatedButton(
onPressed: logPath == null ? null : _shareLogs,
child: Text('Share Logs'),
),
],
),
),
);
}
}