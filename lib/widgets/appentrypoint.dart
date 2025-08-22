


// import 'package:docautomations/widgets/DoctorLoginScreen.dart';
// import 'package:docautomations/widgets/doctorinfo.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:docautomations/widgets/doctorregisterscreen.dart';
// import 'package:docautomations/widgets/doctorwelcomescreen.dart';
// import 'package:docautomations/widgets/menubar.dart';
// import 'package:docautomations/services/license_api_service.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class AppEntryPoint extends StatefulWidget {
//   const AppEntryPoint({super.key});

//   @override
//   State<AppEntryPoint> createState() => _AppEntryPointState();
// }

// // class _AppEntryPointState extends State<AppEntryPoint> {
// //   // Future<bool> _doctorInfoExists() async {
// //   //   final prefs = await SharedPreferences.getInstance();
// //   //   return prefs.containsKey('doctor_info');
// //   // }
// //   late Future<bool> _doctorFuture;

// //    @override
// //   void initState() {
// //     super.initState();
// //     _doctorFuture = _doctorExistsOnServer();
// //   }

// //   Future<bool> _doctorExistsOnServer() async {
// //     final info = await LicenseApiService.fetchRegisteredDoctor();
// //     return info != null;
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return FutureBuilder<bool>(
// //       future: _doctorFuture,
// //       builder: (context, snapshot) {
// //         if (snapshot.connectionState != ConnectionState.done) {
// //           return const Scaffold(body: Center(child: CircularProgressIndicator()));
// //         }

// //         final exists = snapshot.data ?? false;

// //         if (exists) {
// //           // Show Menubar with Welcome screen as body
// //           return const Menubar(body: DoctorWelcomeScreen());
// //         } else {
// //           // Show Register screen
// //           return DoctorRegisterScreen(
// //             onRegistered: (info) {
// //               print("Registered: ${info.name}");
// //               // Rebuild to show welcome screen after registration
// //               setState(() {

// //                 _doctorFuture = _doctorExistsOnServer();
// //               });
// //               // Navigator.pushReplacement(
// //               //   context,
// //               //   MaterialPageRoute(
// //               //     builder: (_) => const Menubar(body: DoctorWelcomeScreen()),
// //               //   ),
// //               // );
// //             },
// //           );
// //         }
// //       },
// //     );
// //   }
// // }

// class _AppEntryPointState extends State<AppEntryPoint> {
//   bool _isLoggedIn = false;
//   bool _isRegistering = false;
//   bool _checkingLogin = true;


//   @override
//   void initState() {
//     super.initState();
//     _checkJwtToken();
    
//     //_checkIfDoctorExists();
//   }

  

// Future<void> _checkJwtToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('jwt_token');

//     if (token != null && token.isNotEmpty) {
//       // Verify token with backend
//       //final isValid = await _verifyToken(token);
//       final isValid = await LicenseApiService.verifyToken(token);
//       setState(() {
//         _isLoggedIn = isValid;
//         _checkingLogin = false;
//       });
//     } else {
//       setState(() {
//         _checkingLogin = false;
//       });
//     }
//   }

//   Future<bool> _verifyToken(String token) async {
//     try {
//       final response = await http.get(
//         Uri.parse('${LicenseApiService.baseUrl}/api/doctor/current'),
//         headers: {'Authorization': 'Bearer $token'},
//       );
//       return response.statusCode == 200;
//     } catch (e) {
//       print("Token verification failed: $e");
//       return false;
//     }
//   }

//   Future<void> _checkIfDoctorExists() async {
//     final prefs = await SharedPreferences.getInstance();
//     final isRegistered = prefs.containsKey('doctor_username');
//     setState(() {
//       _isLoggedIn = isRegistered; // will trigger login screen
//     });
//   }

//   void _onRegistered() {
//     setState(() {
//       _isLoggedIn = true;
//       _isRegistering = false;
//     });
//   }
// /// Called when user successfully logs in
//   void _handleLoginSuccess() {
//     setState(() {
//       _isLoggedIn = true;
//     });
//   }
//   @override
//   Widget build(BuildContext context) {
//     if (_checkingLogin) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     if (_isLoggedIn) {
//       return const Menubar(body: DoctorWelcomeScreen());
//     } else if (_isRegistering) {
//       return DoctorRegisterScreen(onRegistered: (info) async {
//         await _saveDoctorToLocal(info); // 🔽 called here
//         setState(() {
//           _isLoggedIn = true;
//           _isRegistering = false;
//         });
//       });
//     } else {
//       return DoctorLoginScreen(        onLoginSuccess: _handleLoginSuccess,
//         onRegisterTap: () => setState(() => _isRegistering = true),
//       );
//     }
//   }

//   Future<void> _saveDoctorToLocal(DoctorInfo info) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('doctor_username', info.name);
//     await prefs.setString('doctor_password', info.password); // ⚠️ store safely
//   }
// }

import 'dart:async';
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

class _AppEntryPointState extends State<AppEntryPoint> {
  bool _isLoggedIn = false;
  bool _isRegistering = false;
  bool _checkingLogin = true;
  Timer? _tokenCheckTimer;

  @override
  void initState() {
    super.initState();
    _checkJwtToken();
    _startTokenCheckTimer();
  }

  @override
  void dispose() {
    _tokenCheckTimer?.cancel();
    super.dispose();
  }

  /// First check at startup
  Future<void> _checkJwtToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token != null && token.isNotEmpty) {
      final isValid = await LicenseApiService.verifyToken(token);
      setState(() {
        _isLoggedIn = isValid;
        _checkingLogin = false;
      });
    } else {
      setState(() {
        _checkingLogin = false;
      });
    }
  }

  /// Re-check token periodically
  void _startTokenCheckTimer() {
    _tokenCheckTimer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token == null || token.isEmpty) {
        _logout();
        return;
      }

      final isValid = await LicenseApiService.verifyToken(token);
      if (!isValid) {
        _logout();
      }
    });
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('doctor_username');
    await prefs.remove('doctor_password');
    setState(() {
      _isLoggedIn = false;
      _isRegistering = false;
    });
  }

  /// Called when doctor successfully registers
  void _onRegistered(DoctorInfo info) async {
    await _saveDoctorToLocal(info);
    setState(() {
      _isLoggedIn = true;
      _isRegistering = false;
    });
  }

  /// Called when doctor successfully logs in
  void _handleLoginSuccess() {
    setState(() {
      _isLoggedIn = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingLogin) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_isLoggedIn) {
      return const Menubar(body: DoctorWelcomeScreen());
    } else if (_isRegistering) {
      return DoctorRegisterScreen(onRegistered: _onRegistered);
    } else {
      return DoctorLoginScreen(
        onLoginSuccess: _handleLoginSuccess,
        onRegisterTap: () => setState(() => _isRegistering = true),
      );
    }
  }

  Future<void> _saveDoctorToLocal(DoctorInfo info) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('doctor_username', info.name);
    //await prefs.setString('doctor_password', info.password); // ⚠️ Ideally hash this
  }
}
