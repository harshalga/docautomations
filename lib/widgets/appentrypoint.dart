

// import 'dart:async';
// import 'package:docautomations/widgets/AddPrescrip.dart';
// import 'package:docautomations/widgets/DoctorLoginScreen.dart';
// import 'package:docautomations/widgets/doctorinfo.dart';
// import 'package:flutter/material.dart';
// import 'package:docautomations/widgets/doctorregisterscreen.dart';
// import 'package:docautomations/widgets/menubar.dart';
// import 'package:docautomations/services/license_api_service.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class AppEntryPoint extends StatefulWidget {
//   const AppEntryPoint({super.key});

//   @override
//   State<AppEntryPoint> createState() => _AppEntryPointState();
// }

// class _AppEntryPointState extends State<AppEntryPoint> {
//   bool _isLoggedIn = false;
//   bool _isRegistering = false;
//   bool _checkingLogin = true;
//   Timer? _tokenCheckTimer;

//   @override
//   void initState() {
//     super.initState();
//      _checkLoginStatus(); // 👈 run only once at startup
    
//   }

//   @override
//   void dispose() {
//     _tokenCheckTimer?.cancel();
//     super.dispose();
//   }


// /// Main method to check tokens (startup + refresh)
//   Future<void> _checkLoginStatus() async {

//      if (_isRegistering) {
//       // ✅ Grace period: don’t log out while registering
//       return;
//     }

//     final prefs = await SharedPreferences.getInstance();
//     final accessToken = prefs.getString('access_token');
//     final refreshToken = prefs.getString('refresh_token');

//     if (accessToken != null && accessToken.isNotEmpty) {
//       final isValid = await LicenseApiService.verifyToken(accessToken);

//       if (isValid) {
//         if (mounted) {
//           setState(() {
//             _isLoggedIn = true;
//             _checkingLogin = false;
//           });
//         }
//         _startTokenCheckTimer();
//         return;
//       } else if (refreshToken != null && refreshToken.isNotEmpty) {
//         final newAccess = await LicenseApiService.refreshAccessToken(refreshToken);
//         if (newAccess != null) {
//           await prefs.setString('access_token', newAccess);
//           if (mounted) {
//             setState(() {
//               _isLoggedIn = true;
//               _checkingLogin = false;
//             });
//           }
//           _startTokenCheckTimer();
//           return;
//         }
//       }
//       _logout();
//     } else {
//       if (mounted) {
//         setState(() {
//           _checkingLogin = false; // show login/register
//         });
//       }
//     }
//   }


//   /// Background token check every 5 minutes
//   void _startTokenCheckTimer() {
//     _tokenCheckTimer?.cancel(); // avoid duplicate timers
//     _tokenCheckTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
//       _checkLoginStatus(); // ✅ reuse the same method
//     });
//   }

//   void _logout() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.clear();
//     if (mounted) {
//       setState(() {
//         _isLoggedIn = false;
//         _isRegistering = false;
//       });
//     }
//     _tokenCheckTimer?.cancel();
//   }

//   /// Called when doctor successfully registers
//   void _onRegistered(DoctorInfo info) async {
//     print ("doctor info :- $info.info.name");
//     await _saveDoctorToLocal(info);
//     if (mounted) {
//     setState(() {
//       _isLoggedIn = true;
//       _isRegistering = false;
//     });}

//  // ✅ Now start background token checks
//   _startTokenCheckTimer();
    
//   }

//   /// Called when doctor successfully logs in
//   void _handleLoginSuccess() async {

//     if (mounted) {
//         setState(() {
//       _isLoggedIn = true;
      
//     });
//     }
//     // ✅ Now start background token checks
//   _startTokenCheckTimer();
//   }


//  @override
//   Widget build(BuildContext context) {
//     if (_checkingLogin) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     if (_isLoggedIn) {
//       return Menubar(
//         body: Addprescrip(title: "PatientInfo"),
//         onLogout: _logout,
//       );
//     } else if (_isRegistering) {
//       return DoctorRegisterScreen(onRegistered: _onRegistered);
//     } else {
//       return DoctorLoginScreen(
//         onLoginSuccess: _handleLoginSuccess,
//         onRegisterTap: () => setState(() => _isRegistering = true),
//       );
//     }
//   }

//   Future<void> _saveDoctorToLocal(DoctorInfo info) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('doctor_username', info.name);
    
//     //await prefs.setString("doctor_profile", jsonEncode(info));
//   }
// }




import 'dart:async';
import 'package:docautomations/widgets/AddPrescrip.dart';
import 'package:docautomations/widgets/DoctorLoginScreen.dart';
import 'package:docautomations/widgets/doctorinfo.dart';
import 'package:docautomations/widgets/paywallscreen.dart';
import 'package:flutter/material.dart';
import 'package:docautomations/widgets/doctorregisterscreen.dart';
import 'package:docautomations/widgets/menubar.dart';
import 'package:docautomations/services/license_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:docautomations/common/licenseprovider.dart';
import 'package:provider/provider.dart';

class AppEntryPoint extends StatefulWidget {
  const AppEntryPoint({super.key});

  @override
  State<AppEntryPoint> createState() => _AppEntryPointState();
}

class _AppEntryPointState extends State<AppEntryPoint> with WidgetsBindingObserver {
  bool _isLoggedIn = false;
  bool _isRegistering = false;
  bool _checkingLogin = true;
  Timer? _tokenCheckTimer;

// //trial/subscription status automatically refreshes when the app opens (or comes back from background)
// @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       /// 🔄 Refresh subscription + trial status on resume
//       Provider.of<LicenseProvider>(context, listen: false).refreshStatus();
//     }
//   }
  @override
  void initState() {
    super.initState();
    //TODOPR
     print(" inside initState app entry point ");
     _checkLoginStatus(); // 👈 run only once at startup
    //  //trial/subscription status automatically refreshes when the app opens (or comes back from background)
    //  WidgetsBinding.instance.addObserver(this);
    //TODOPR
     print(" after chk login status ");
  }

  

  @override
  void dispose() {
    // //trial/subscription status automatically refreshes when the app opens (or comes back from background)
    // WidgetsBinding.instance.removeObserver(this);
    _tokenCheckTimer?.cancel();
    super.dispose();
  }


/// Main method to check tokens (startup + refresh)
  Future<void> _checkLoginStatus() async {

     if (_isRegistering) {
      // ✅ Grace period: don’t log out while registering
      return;
    }

    //TODOPR
     print(" inside _checkLoginstatus ");

    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');
    final refreshToken = prefs.getString('refresh_token');

    if (accessToken != null && accessToken.isNotEmpty) {
      final isValid = await LicenseApiService.verifyToken(accessToken);

      if (isValid) {
        _markLoggedIn();
        return;
      } else if (refreshToken != null && refreshToken.isNotEmpty) {
        final newAccess = await LicenseApiService.refreshAccessToken(refreshToken);
        if (newAccess != null) {
          await prefs.setString('access_token', newAccess);
          _markLoggedIn();
          return;
        }
      }
      _logout();
    } else {
      if (mounted) {
        setState(() {
          _checkingLogin = false; // show login/register
        });
      }
    }
    //TODOPR
     print(" outside initState app entry point ");
  }


 void _markLoggedIn() {
    if (mounted) {
      setState(() {
        _isLoggedIn = true;
        _checkingLogin = false;
      });
    }
    _startTokenCheckTimer();

    // 👇 Immediately load trial/subscription status
    context.read<LicenseProvider>().loadStatus();
  }

  /// Background token check every 5 minutes
  void _startTokenCheckTimer() {
    _tokenCheckTimer?.cancel(); // avoid duplicate timers
    _tokenCheckTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _checkLoginStatus(); // ✅ reuse the same method
    });
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      setState(() {
        _isLoggedIn = false;
        _isRegistering = false;
      });
    }
    _tokenCheckTimer?.cancel();
  }

  /// Called when doctor successfully registers
  void _onRegistered(DoctorInfo info) async {
    
    await _saveDoctorToLocal(info);
    _markLoggedIn();
//     if (mounted) {
//     setState(() {
//       _isLoggedIn = true;
//       _isRegistering = false;
//     });}

//  // ✅ Now start background token checks
//   _startTokenCheckTimer();
//    context.read<LicenseProvider>().loadStatus();
    
  }

  /// Called when doctor successfully logs in
  void _handleLoginSuccess() async {
_markLoggedIn();
  //   if (mounted) {
  //       setState(() {
  //     _isLoggedIn = true;
      
  //   });
  //   }
  //   // ✅ Now start background token checks
  // _startTokenCheckTimer();
  // context.read<LicenseProvider>().loadStatus();
  }


 @override
  Widget build(BuildContext context) {
    if (_checkingLogin) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_isLoggedIn) {
      final license = context.watch<LicenseProvider>();

      if (license.isLoading) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      if (license.canPrescribe) {
        return Menubar(
          body: Addprescrip(title: "PatientInfo"),
          onLogout: _logout,
        );
      } else {
        return PaywallScreen(); // 👈 force user to subscribe
      }
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
    
    
  }
}
