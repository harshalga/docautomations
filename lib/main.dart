import 'package:docautomations/common/appcolors.dart';
import 'package:docautomations/datamodels/prescriptionData.dart';
import 'package:docautomations/widgets/consumptionpattern.dart';
import 'package:docautomations/widgets/consumptionperiod.dart';
import 'package:docautomations/widgets/frequency.dart';
import 'package:docautomations/widgets/instructions.dart';
import 'package:docautomations/widgets/medicineswitch.dart';
import 'package:docautomations/widgets/menubar.dart';
import 'package:flutter/material.dart';
// Include the Google Fonts package to provide more text format options
// https://pub.dev/packages/google_fonts
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';


void main() {
  //runApp(const MyApp());
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

class AddPrescription extends StatefulWidget {
  final String title;

  const AddPrescription({super.key, required this.title});

  @override
  State<AddPrescription> createState() => AddPrescriptionState();
}

class AddPrescriptionState extends State<AddPrescription> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onSecondary,
                )),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      body: const Center(
        child: AddPrescriptionScreen(),
      ),
    );
  }
}

class AddPrescriptionScreen extends StatefulWidget {
  const AddPrescriptionScreen({super.key});

  @override
  State<AddPrescriptionScreen> createState() => AddPrescriptionScreenState();
}


class AddPrescriptionScreenState extends State<AddPrescriptionScreen> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();
  
  bool istabletSel = true;
  String unitofmeasure = 'mg';
  String medicinetype = 'Tablet';

  final GlobalKey<MedicineSwitchState> _MedicineSwitchKey = GlobalKey<MedicineSwitchState>();

  

  

  static const descTextStyle = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.w800,
    fontFamily: 'Roboto',
    letterSpacing: 0.5,
    fontSize: 18,
    height: 2,
  );

  @override
  Widget build(BuildContext context) {
    //ToDO:

    return 
    SizedBox(height: MediaQuery.of(context).size.height,
     child:SingleChildScrollView(

      child: 
    Container(
      padding:const EdgeInsets.all(20),
      margin: const EdgeInsets.only(left: 20,right: 20,top: 20,bottom: 20),
      decoration: BoxDecoration(
        color:Colors.white,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(color:AppColors.primary.withOpacity(0.3),
          blurRadius: 20,
          offset: Offset.zero),
          
        ]
      ),
      child:Form(
        key: _formKey,
        child: DefaultTextStyle.merge(
          style: descTextStyle,
          child: Column(
            
            children: [
             
              MedicineSwitch(key:_MedicineSwitchKey),
              const SizedBox(
                height: 10,
              ),
              const FrequencyWidget(),
              const SizedBox(
                height: 10,
              ),
              const SizedBox(
                height: 10,
              ),
              const ConsumptionPattern(),
              const SizedBox(height: 10,),
              const ConsumptionPeriod(),
               const SizedBox(height: 10,),
              const Instructions(),
              const SizedBox(height: 10,),
              Padding(
                padding: const EdgeInsets.all(8),
                child: ElevatedButton(
                  onPressed: () {
                    // Validate returns true if the form is valid, or false otherwise.
                    if (_formKey.currentState!.validate()) {
                      Navigator.pop(context,context.read<Prescriptiondata>());
                    }
                  },
                  child: const Text('Go back!'),
                ),
              ),
            ],
          ),
        )))));
  }
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
