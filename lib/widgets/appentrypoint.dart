// import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart';
// import 'dart:io';
// import 'dart:convert';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:docautomations/datamodels/prescriptionData.dart';
// import 'package:docautomations/widgets/doctorregisterscreen.dart';
// import 'package:docautomations/widgets/doctorwelcomescreen.dart';

// class AppEntryPoint extends StatefulWidget {
//   const AppEntryPoint({super.key});

//   @override
//   State<AppEntryPoint> createState() => _AppEntryPointState();
// }

// class _AppEntryPointState extends State<AppEntryPoint> {
//   Future<bool> _doctorInfoExists() async {
//   //if (kIsWeb) {
//     // Web can't use File API; use localStorage instead or skip check
//     final prefs = await SharedPreferences.getInstance();
//       return prefs.containsKey('doctor_info');
    
//   // } else {
//   //   final dir = await getApplicationDocumentsDirectory();
//   //   final file = File('${dir.path}/doctor_info.json');
//   //   return file.exists();
//   // }
// }


//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<bool>(
//       future: _doctorInfoExists(),
//       builder: (context, snapshot) {
// if (snapshot.connectionState == ConnectionState.waiting) {
//     return const Scaffold(body: Center(child: CircularProgressIndicator()));
//   }
//          print('Snapshot state: ${snapshot.connectionState}');
//   print('Snapshot data: ${snapshot.data}');
// final exists = snapshot.data ?? false; //  fallback to false if null


       

//         if (exists) {
//     return  DoctorWelcomeScreen();
//   } else {
//     return DoctorRegisterScreen(
//       onRegistered: (info) {
//          print("Registered: ${info.name}"); // ✅ test if this is hit
//         setState(() {});
       
//     //     Navigator.pushReplacement(
//     //   context,
//     //   MaterialPageRoute(builder: (_) => const DoctorWelcomeScreen()),
//     // );
//       },
//       );
//       }
//       },
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:docautomations/widgets/doctorregisterscreen.dart';
import 'package:docautomations/widgets/doctorwelcomescreen.dart';
import 'package:docautomations/widgets/menubar.dart';
import 'package:docautomations/services/license_api_service.dart';

class AppEntryPoint extends StatefulWidget {
  const AppEntryPoint({super.key});

  @override
  State<AppEntryPoint> createState() => _AppEntryPointState();
}

class _AppEntryPointState extends State<AppEntryPoint> {
  // Future<bool> _doctorInfoExists() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   return prefs.containsKey('doctor_info');
  // }
  late Future<bool> _doctorFuture;

   @override
  void initState() {
    super.initState();
    _doctorFuture = _doctorExistsOnServer();
  }

  Future<bool> _doctorExistsOnServer() async {
    final info = await LicenseApiService.fetchRegisteredDoctor();
    return info != null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _doctorFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final exists = snapshot.data ?? false;

        if (exists) {
          // Show Menubar with Welcome screen as body
          return const Menubar(body: DoctorWelcomeScreen());
        } else {
          // Show Register screen
          return DoctorRegisterScreen(
            onRegistered: (info) {
              print("Registered: ${info.name}");
              // Rebuild to show welcome screen after registration
              setState(() {

                _doctorFuture = _doctorExistsOnServer();
              });
              // Navigator.pushReplacement(
              //   context,
              //   MaterialPageRoute(
              //     builder: (_) => const Menubar(body: DoctorWelcomeScreen()),
              //   ),
              // );
            },
          );
        }
      },
    );
  }
}
