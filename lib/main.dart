import 'package:docautomations/datamodels/prescriptionData.dart';
import 'package:docautomations/widgets/AddPrescription.dart';
import 'package:docautomations/widgets/menubar.dart';
import 'package:flutter/material.dart';
// Include the Google Fonts package to provide more text format options
// https://pub.dev/packages/google_fonts
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

 
void main() {
  //runApp(const MyApp());
  WidgetsFlutterBinding.ensureInitialized(); // ← this is important
  runApp(
    ChangeNotifierProvider(
      create: (context) => Prescriptiondata(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const appName = 'Prescriptor';
    //'Electronic prescription system'
    // 'Clinical Applications';

    return MaterialApp(
      title: appName,
      theme: ThemeData(
        useMaterial3: true,

        // Define the default brightness and colors.
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 72, 194, 188),
          // TRY THIS: Change to "Brightness.light"
          //           and see that all colors change
          //           to better contrast a light background.
          brightness: Brightness.light,
        ),
        cardTheme: const CardTheme(color: Color.fromARGB(255, 13, 192, 162)),

        // Define the default `TextTheme`. Use this to specify the default
        // text styling for headlines, titles, bodies of text, and more.
        textTheme: TextTheme(
          displayLarge: const TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.bold,
          ),
          // TRY THIS: Change one of the GoogleFonts
          //           to "lato", "poppins", or "lora".
          //           The title uses "titleLarge"
          //           and the middle text uses "bodyMedium".
          titleLarge: GoogleFonts.aleo(
            fontSize: 30,
            fontStyle: FontStyle.italic,
          ),
          bodyMedium: GoogleFonts.merriweather(),
          displaySmall: GoogleFonts.pacifico(),
        ),
      ),
      home: const Menubar(),
      // home: const MyHomePage(
      //   title: appName,
      //),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({super.key, required this.title});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onSecondary,
                )),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      body: const Center(
        child: MainListMenu(),
      ),
    );
  }
}

enum _TileType { textTile, labelTile, multilineText, textTileAutoFocus }

class MainListMenu extends StatefulWidget {
  const MainListMenu({super.key});

  @override
  State<MainListMenu> createState() => _MainListMenuState();
}



class _MainListMenuState extends State<MainListMenu> {
  final TextEditingController _namecontroller = TextEditingController();
  final TextEditingController _keyComplaintcontroller = TextEditingController();
  final TextEditingController _examinationcontroller = TextEditingController();
  final TextEditingController _diagnoscontroller = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    // This also removes the _printLatestValue listener.
    _namecontroller.dispose();
    _keyComplaintcontroller.dispose();
    _examinationcontroller.dispose();
    _diagnoscontroller.dispose();
    super.dispose();
  }

  Card _card(String title, String caVal, _TileType tiletype,
      [TextEditingController? lcontroller]) {
    return Card(
      child: SizedBox(
          height: 100,
          child: Center(
            child: _tile(title, caVal, tiletype, lcontroller),
          )),
    );
  }

  ListTile _tile(String title, String caVal, _TileType tiletype,
      [TextEditingController? lcontroller]) {
    switch (tiletype) {
      case _TileType.textTileAutoFocus:
        return ListTile(
          title: TextField(
            controller: lcontroller,
            autofocus: true,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
            decoration:
                InputDecoration(border: const OutlineInputBorder(), labelText: title),
          ),
          leading: CircleAvatar(child: Text(caVal)),
        );

      case _TileType.labelTile:
        return ListTile(
          title: Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.w500, fontSize: 20)),
          leading: CircleAvatar(child: Text(caVal)),
          trailing: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddPrescription(
                            title: title,
                          )),
                );
              },
              child: const Text('Add')),
        );
      case _TileType.textTile:
        return ListTile(
          title: TextField(
            controller: lcontroller,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
            decoration:
                InputDecoration(border: const OutlineInputBorder(), labelText: title),
          ),
          leading: CircleAvatar(child: Text(caVal)),
        );
      case _TileType.multilineText:
        return ListTile(
          title: TextField(
            controller: lcontroller,
            keyboardType: TextInputType.multiline,
            minLines: 1,
            maxLines: 5,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
            decoration:
                InputDecoration(border: const OutlineInputBorder(), labelText: title),
          ),
          leading: CircleAvatar(child: Text(caVal)),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ListView(
      children: [
        _card('Name', 'NA', _TileType.textTileAutoFocus, _namecontroller),
        _card('Key Complaints', 'KC', _TileType.textTile,
            _keyComplaintcontroller),
        _card('Examination', 'E', _TileType.multilineText,
            _examinationcontroller),
        _card('Diagnostics', 'D', _TileType.multilineText, _diagnoscontroller),
        _card('Prescription', 'PC', _TileType.labelTile),
      ],
    );
  }
}
