// import 'dart:async';
// import 'dart:io';
// import 'package:dio/dio.dart';
// import 'package:docautomations/widgets/AddPrescrip.dart';
// import 'package:docautomations/widgets/DoctorLoginScreen.dart';
// import 'package:docautomations/widgets/SplashScreen.dart';
// import 'package:docautomations/widgets/doctorinfo.dart';
// import 'package:docautomations/widgets/paywallscreen.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:docautomations/widgets/doctorregisterscreen.dart';
// import 'package:docautomations/widgets/menubar.dart';
// import 'package:docautomations/services/license_api_service.dart';
// import 'package:flutter/services.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:docautomations/common/licenseprovider.dart';
// import 'package:provider/provider.dart';

// class AppEntryPoint extends StatefulWidget {
//   const AppEntryPoint({super.key});

//   @override
//   State<AppEntryPoint> createState() => _AppEntryPointState();
// }

// class _AppEntryPointState extends State<AppEntryPoint> {
//   bool _isLoggedIn = false;
//   bool _isRegistering = false;
//   bool _checkingLogin = true;

//   bool _offline = false; // 👈 ADD THIS

//   Timer? _tokenCheckTimer;

//   @override
//   void initState() {
//     super.initState();
//   //  _checkLoginStatus();   // Run only once on startup
//    _bootstrap();
//   }


// // Future<void> _bootstrap() async {
// //   // 1️⃣ Wake Render backend (cold start absorption)
// //   await  LicenseApiService.warmUpBackend();

// //   // 2️⃣ Small buffer (smooth UX)
// //   await Future.delayed(const Duration(milliseconds: 500));

// //   // 3️⃣ Existing login logic (unchanged)
// //   await _checkLoginStatus(); // Run only once on startup
// // }

// Future<void> _bootstrap() async {
//   // Warm backend but don't block UI
//   LicenseApiService.warmUpBackend();

//   await Future.any([
//     _checkLoginStatus(),
//     Future.delayed(const Duration(seconds: 8)),
//   ]);

//   // If still stuck, force exit splash
//   if (_checkingLogin && mounted) {
//     setState(() {
//       _checkingLogin = false;
//     });
//   }
// }
// Future<bool> _hasInternet() async {
//   try {
//     final result = await InternetAddress.lookup('google.com');
//     return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
//   } catch (_) {
//     return false;
//   }
// }


//   @override
//   void dispose() {
//     _tokenCheckTimer?.cancel();
//     super.dispose();
//   }
// Future<void> _clearCorruptedSession() async {
//   final prefs = await SharedPreferences.getInstance();
//   await prefs.clear();

//   if (mounted) {
//     setState(() {
//       _isLoggedIn = false;
//       _checkingLogin = false;
//       _offline = false; // 👈 reset
//     });
//   }
// }
//   // -------------------------------------------------------------
//   // MAIN LOGIN CHECK — FIXED TO NOT RESET UI EVERY 5 MINUTES
//   // -------------------------------------------------------------
//   Future<void> _checkLoginStatus() async {

//     // 🌐 OFFLINE CHECK — FIRST
//   if (!await _hasInternet()) {
//     if (mounted) {
//       setState(() {
//         _offline = true;
//         _checkingLogin = false;
        
//       });
//     }
//     return; // ⛔ STOP EVERYTHING
//   }

//   // reset offline if internet is back
//   if (_offline) {
//     setState(() => _offline = false);
//   }

//     final prefs = await SharedPreferences.getInstance();

//     final accessToken = prefs.getString('access_token');
//     final refreshToken = prefs.getString('refresh_token');

//     final bool wasLoggedIn = _isLoggedIn;

//     // Not logged in at all
//     if (accessToken == null || accessToken.isEmpty) {
//       await _clearCorruptedSession();
//       return;
//       // if (!_isLoggedIn) {
//       //   setState(() {
//       //     _checkingLogin = false;
//       //      _offline = false; // 👈 reset
//       //   });
//       // }
//       //return;
//     }
  
// try{
//     // Check validity silently
//     //final bool isValid = await LicenseApiService.verifyToken(accessToken);
//     final bool isValid = await LicenseApiService.verifyToken();
//     if (isValid) {
//       if (!wasLoggedIn) _markLoggedInOnce();
//       return;
//     }

//     // Try refresh token
//     if (refreshToken != null && refreshToken.isNotEmpty) {
//       final String? newAccess = await LicenseApiService.refreshAccessToken(refreshToken);

//       if (newAccess != null) {
//         await prefs.setString('access_token', newAccess);
//         if (!wasLoggedIn) _markLoggedInOnce();
//         return;
//       }
//     }

//     // Logout ONLY if previously logged in
//     if (wasLoggedIn) {
//       _logout();
//     }
//   }
//   catch (e) {

//   // // 🌐 OFFLINE / DNS / NO INTERNET
//   //   if (mounted) {
//   //     setState(() {
//   //       _offline = true;
//   //       _checkingLogin = false;
//   //     });
//   //   }
//   if (e is SocketException || e is DioException) {
//     if (mounted) {
//       setState(() {
//         _offline = true;
//         _checkingLogin = false;
//       });
//     }
//   } else {
//     rethrow; // 👈 real errors should surface
//   }
//   }

// }


//   // -------------------------------------------------------------
//   // MARK LOGGED IN — ONLY RUN ONCE
//   // -------------------------------------------------------------
//   void _markLoggedInOnce() {
//     if (!_isLoggedIn) {
//       setState(() {
//         _isLoggedIn = true;
//         _checkingLogin = false;
//       });
//     }

//     // Start silent refresh
//     _tokenCheckTimer ??= Timer.periodic(const Duration(minutes: 5), (_) => _checkLoginStatus());

//     // Silent status refresh (DOES NOT rebuild UI)
//     context.read<LicenseProvider>().loadStatus();
//   }

//   // -------------------------------------------------------------
//   // LOGOUT
//   // -------------------------------------------------------------
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
//     _tokenCheckTimer = null;
//   }

//   void _onRegistered(DoctorInfo info) async {
//     await _saveDoctorToLocal(info);
//     _markLoggedInOnce();
//   }

//   void _handleLoginSuccess() {
//     _markLoggedInOnce();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_checkingLogin) {
//       //return const Scaffold(body: Center(child: CircularProgressIndicator()));
//       return const SplashScreen();
//     }

// // 🌐 OFFLINE SCREEN
//   if (_offline) {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
//             const SizedBox(height: 16),
//             const Text(
//               'No internet connection',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               'Please check your network and try again.',
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton(
//               onPressed: () {
//                 setState(() {
//                   _offline = false;
//                   _checkingLogin = true;
//                 });
//                 _bootstrap(); // 🔁 retry warm-up + login
//               },
//               child: const Text('Retry'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
    

//     if (_isLoggedIn) {
//       final license = context.watch<LicenseProvider>();

//       if (license.isLoading) {
//         return const Scaffold(body: Center(child: CircularProgressIndicator()));
//       }

//       if (license.canPrescribe) {
//         return Menubar(
//           body: const Addprescrip(title: "Patient Diagnosis"),
//           onLogout: _logout,
//         );
//       } else {
//         return PaywallScreen(
//           onSubscriptionActivated: () {
//             confirmExit();
//           },
//           onMaybeLater: () {
//             confirmExit();
//           },
//         );
//       }
//     }

//     // Register or Login UI
//     if (_isRegistering) {
//       return DoctorRegisterScreen(onRegistered: _onRegistered);
//     } 
//       return DoctorLoginScreen(
//         onLoginSuccess: _handleLoginSuccess,
//         onRegisterTap: () => setState(() => _isRegistering = true),
//       );
    
//   }

//   Future<void> _saveDoctorToLocal(DoctorInfo info) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('doctor_username', info.name);
//   }

//   String getPlatform() {
//     if (Theme.of(context).platform == TargetPlatform.android) return "android";
//     if (Theme.of(context).platform == TargetPlatform.iOS) return "ios";
//     return "unknown";
//   }

//   Future<void> confirmExit() async {
//     final platform = getPlatform();

//     final result = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Exit App"),
//         content: const Text("Are you sure you want to exit?"),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("No")),
//           TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Yes")),
//         ],
//       ),
//     );

//     if (result == true) {
//       if (kIsWeb) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("You can now close this tab.")),
//         );
//       } else if (platform == 'android') {
//         SystemNavigator.pop();
//       } else if (platform == 'ios') {
//         exit(0);
//       }
//     }
//   }
// }


import 'dart:async';
import 'dart:io';
import 'package:docautomations/network/dio_client.dart';
import 'package:docautomations/widgets/AddPrescrip.dart';
import 'package:docautomations/widgets/DoctorLoginScreen.dart';
import 'package:docautomations/widgets/SplashScreen.dart';
import 'package:docautomations/widgets/doctorinfo.dart';
import 'package:docautomations/widgets/paywallscreen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:docautomations/widgets/doctorregisterscreen.dart';
import 'package:docautomations/widgets/menubar.dart';
import 'package:docautomations/services/license_api_service.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:docautomations/common/licenseprovider.dart';
import 'package:provider/provider.dart';

class AppEntryPoint extends StatefulWidget {
  const AppEntryPoint({super.key});

  @override
  State<AppEntryPoint> createState() => _AppEntryPointState();
}


enum AppStartupState {
  checking,
  loggedOut,
  loggedIn,
  offline,
}

class _AppEntryPointState extends State<AppEntryPoint> {
  bool _bootstrapRunning = false;
  bool _isRegistering = false;   // 👈 ADD THIS

  
AppStartupState _state = AppStartupState.checking;
  

  @override
  void initState() {
    super.initState();
    DioClient.instance;   // initialize dio early
    _bootstrap();
  }

// Future<void> _runStartup() async {

//   final backendOk = await LicenseApiService.checkBackendHealth();

//   if (!mounted) return;

//   if (!backendOk) {
//     setState(() => _state = AppStartupState.offline);
//     return;
//   }

//   final prefs = await SharedPreferences.getInstance();

//   if (!mounted) return;

//   final token = prefs.getString('access_token');

//   if (token == null || token.isEmpty) {
//     setState(() => _state = AppStartupState.loggedOut);
//     return;
//   }

//   setState(() => _state = AppStartupState.loggedIn);

//   context.read<LicenseProvider>().loadStatus();
// }

Future<void> _runStartup() async {
final backendOk = await LicenseApiService.checkBackendHealth();

if (!mounted) return;

if (!backendOk) {
  setState(() => _state = AppStartupState.offline);
  return;
}

  try {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final token = prefs.getString('access_token');

  //   setState(() {
  //   _state = (token == null || token.isEmpty)
  //       ? AppStartupState.loggedOut
  //       : AppStartupState.loggedIn;
  // });

  //   await context.read<LicenseProvider>().loadStatus();

  if (token == null || token.isEmpty) {
      setState(() => _state = AppStartupState.loggedOut);
      return;
    }

    // // ✅ WAIT for license status
    //// await context.read<LicenseProvider>().loadStatus();

    //// if (!mounted) return;

    //// setState(() => _state = AppStartupState.loggedIn);

     // ✅ Just mark logged in
  setState(() => _state = AppStartupState.loggedIn);
  context.read<LicenseProvider>().loadStatus();
  // // ✅ Load license AFTER UI builds
  // Future.microtask(() {
  //   if (mounted) {
  //     context.read<LicenseProvider>().loadStatus();
  //   }
  // });

  } catch (_) {
    if (mounted)
    {    setState(() => _state = AppStartupState.loggedOut);
    }
  }
}


Future<void> _bootstrap() async {
  
 if (_bootstrapRunning) return; // prevent duplicate runs
  _bootstrapRunning = true;
  

  await Future.any([
    _runStartup(),
    Future.delayed(const Duration(seconds: 8)),
  ]);

  if (!mounted) return;

  // If still stuck, exit splash safely
  if (_state == AppStartupState.checking) {
    setState(() => _state = AppStartupState.loggedOut);
  }

  
}






  @override
  void dispose() {
   
    super.dispose();
  }
// Future<void> _clearCorruptedSession() async {
//   await LicenseApiService.clearSession();

//   if (mounted) {
//     setState(() {
//       _state = AppStartupState.loggedOut;
//     });
//   }
// }
  


 

  // -------------------------------------------------------------
  // LOGOUT
  // -------------------------------------------------------------
  void _logout() async {


 final platform = getPlatform();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Switch Doctor / Logout"),
        content: const Text("Are you sure you want to switch doctor or logout?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("No")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Yes")),
        ],
      ),
    );

    if (result == true) {
      if (kIsWeb) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You can now close this tab.")),
        );
      } else if (platform == 'android') {
        final prefs = await SharedPreferences.getInstance();
  await prefs.clear();

  if (mounted) {
    setState(() => _state = AppStartupState.loggedOut);

      }

      
        //SystemNavigator.pop();
      } else if (platform == 'ios') {
        exit(0);
      }
    }
    //33434534543543
  

 
}

  void _onRegistered(DoctorInfo info) async {
  await _saveDoctorToLocal(info);

  if (mounted) {
    setState(() {
      _isRegistering = false;
      _state = AppStartupState.loggedIn;
    });
  }

 
  context.read<LicenseProvider>().loadStatus();
}

void _handleLoginSuccess() {
  if (mounted) {
    setState(() {
      _state = AppStartupState.loggedIn;
    });
  }

 
  context.read<LicenseProvider>().loadStatus();
}


@override
Widget build(BuildContext context) {

  Widget screen;

  switch (_state) {

    case AppStartupState.checking:
      screen = const SplashScreen();
      break;

    case AppStartupState.offline:
      screen = _offlineScreen();
      break;

    case AppStartupState.loggedOut:
      if (_isRegistering) {
        screen = DoctorRegisterScreen(onRegistered: _onRegistered);
      } else {
        screen = DoctorLoginScreen(
          onLoginSuccess: _handleLoginSuccess,
          onRegisterTap: () => setState(() => _isRegistering = true),
        );
      }
      break;

    case AppStartupState.loggedIn:
      final license = context.watch<LicenseProvider>();

      if (license.isLoading) {
        screen = const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      } else if (license.canPrescribe) {
        screen = Menubar(
          body: const Addprescrip(title: "Patient Diagnosis"),
          onLogout: _logout,
        );
      } else {
        screen = PaywallScreen(
          onSubscriptionActivated: confirmExit,
          onMaybeLater: confirmExit,
          onRestorePurchase: _restorePurchase,
          onSwitchDoctor: _logout,
        );
      }
      break;
  }

 return AnimatedSwitcher(
  duration: const Duration(milliseconds: 400),
  transitionBuilder: (child, animation) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.05),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  },
  child: screen,
);
}

//   @override
// Widget build(BuildContext context) {

//   switch (_state) {

//     case AppStartupState.checking:
//       return const SplashScreen();

//     case AppStartupState.offline:
//       return _offlineScreen();

//     case AppStartupState.loggedOut:
//       if (_isRegistering) {
//         return DoctorRegisterScreen(onRegistered: _onRegistered);
//       }

//       return DoctorLoginScreen(
//         onLoginSuccess: _handleLoginSuccess,
//         onRegisterTap: () => setState(() => _isRegistering = true),
//       );

//     case AppStartupState.loggedIn:
//       final license = context.watch<LicenseProvider>();

//       if (license.isLoading) {
//         return const Scaffold(
//           body: Center(child: CircularProgressIndicator()),
//         );
//       }

//       if (license.canPrescribe) {
//         return Menubar(
//           body: const Addprescrip(title: "Patient Diagnosis"),
//           onLogout: _logout,
//         );
//       }

//       return PaywallScreen(
//         onSubscriptionActivated: confirmExit,
//         onMaybeLater: confirmExit,
//       );
//   }
// }

Widget _offlineScreen() {
  return Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, size: 64),
          const SizedBox(height: 16),
          const Text("No internet connection"),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {
              _state = AppStartupState.checking ;
              _bootstrapRunning = false; // allow retry
              });
              
              _bootstrap();
            },
            child: const Text("Retry"),
          ),
        ],
      ),
    ),
  );
}

  Future<void> _saveDoctorToLocal(DoctorInfo info) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('doctor_username', info.name);
  }

  String getPlatform() {
    if (Theme.of(context).platform == TargetPlatform.android) return "android";
    if (Theme.of(context).platform == TargetPlatform.iOS) return "ios";
    return "unknown";
  }
Future<void> _restorePurchase() async {

  final licenseProvider = context.read<LicenseProvider>();

  await licenseProvider.loadStatus(); // re-check subscription from backend

  if (mounted) {
    setState(() {
      _state = AppStartupState.loggedIn;
    });
  }
}

  Future<void> confirmExit() async {
    final platform = getPlatform();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Exit App"),
        content: const Text("Are you sure you want to exit?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("No")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Yes")),
        ],
      ),
    );

    if (result == true) {
      if (kIsWeb) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You can now close this tab.")),
        );
      } else if (platform == 'android') {
        
        SystemNavigator.pop();
      } else if (platform == 'ios') {
        exit(0);
      }
    }
  }
}
