


import 'package:docautomations/widgets/DoctorLoginScreen.dart';
import 'package:docautomations/widgets/doctorinfo.dart';
import 'package:flutter/material.dart';

import 'package:docautomations/widgets/doctorregisterscreen.dart';
import 'package:docautomations/widgets/doctorwelcomescreen.dart';
import 'package:docautomations/widgets/menubar.dart';
import 'package:docautomations/services/license_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppEntryPoint extends StatefulWidget {
  const AppEntryPoint({super.key});

  @override
  State<AppEntryPoint> createState() => _AppEntryPointState();
}

// class _AppEntryPointState extends State<AppEntryPoint> {
//   // Future<bool> _doctorInfoExists() async {
//   //   final prefs = await SharedPreferences.getInstance();
//   //   return prefs.containsKey('doctor_info');
//   // }
//   late Future<bool> _doctorFuture;

//    @override
//   void initState() {
//     super.initState();
//     _doctorFuture = _doctorExistsOnServer();
//   }

//   Future<bool> _doctorExistsOnServer() async {
//     final info = await LicenseApiService.fetchRegisteredDoctor();
//     return info != null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<bool>(
//       future: _doctorFuture,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState != ConnectionState.done) {
//           return const Scaffold(body: Center(child: CircularProgressIndicator()));
//         }

//         final exists = snapshot.data ?? false;

//         if (exists) {
//           // Show Menubar with Welcome screen as body
//           return const Menubar(body: DoctorWelcomeScreen());
//         } else {
//           // Show Register screen
//           return DoctorRegisterScreen(
//             onRegistered: (info) {
//               print("Registered: ${info.name}");
//               // Rebuild to show welcome screen after registration
//               setState(() {

//                 _doctorFuture = _doctorExistsOnServer();
//               });
//               // Navigator.pushReplacement(
//               //   context,
//               //   MaterialPageRoute(
//               //     builder: (_) => const Menubar(body: DoctorWelcomeScreen()),
//               //   ),
//               // );
//             },
//           );
//         }
//       },
//     );
//   }
// }

class _AppEntryPointState extends State<AppEntryPoint> {
  bool _isLoggedIn = false;
  bool _isRegistering = false;

  @override
  void initState() {
    super.initState();
    _checkIfDoctorExists();
  }

  Future<void> _checkIfDoctorExists() async {
    final prefs = await SharedPreferences.getInstance();
    final isRegistered = prefs.containsKey('doctor_username');
    setState(() {
      _isLoggedIn = isRegistered; // will trigger login screen
    });
  }

  void _onRegistered() {
    setState(() {
      _isLoggedIn = true;
      _isRegistering = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoggedIn) {
      return const Menubar(body: DoctorWelcomeScreen());
    } else if (_isRegistering) {
      return DoctorRegisterScreen(onRegistered: (info) async {
        await _saveDoctorToLocal(info); // 🔽 called here
        setState(() {
          _isLoggedIn = true;
          _isRegistering = false;
        });
      });
    } else {
      return DoctorLoginScreen(
        onLoginSuccess: () => setState(() => _isLoggedIn = true),
        onRegisterTap: () => setState(() => _isRegistering = true),
      );
    }
  }

  Future<void> _saveDoctorToLocal(DoctorInfo info) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('doctor_username', info.name);
    await prefs.setString('doctor_password', info.password); // ⚠️ store safely
  }
}

