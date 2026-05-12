


import 'dart:async';
import 'dart:io';
import 'package:docautomations/network/dio_client.dart';
import 'package:docautomations/services/auth_service.dart';
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

class _AppEntryPointState extends State<AppEntryPoint> with WidgetsBindingObserver {
  bool _bootstrapRunning = false;
  bool _isRegistering = false;   // 👈 ADD THIS

  
AppStartupState _state = AppStartupState.checking;
  

  @override
  void initState() {
    super.initState();
      WidgetsBinding.instance.addObserver(this); // 👈 ADD HERE

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
    //final token = prefs.getString('access_token');
 final token = await AuthService.getToken();
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
  await context.read<LicenseProvider>().loadStatus(force: true); // then load license in parallel
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
  setState(() => _state = AppStartupState.offline);
}

  
}



@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.resumed) {
    // 👇 Force refresh subscription when app comes to foreground
    final provider = context.read<LicenseProvider>();

  if (!provider.isLoading) {
    provider.loadStatus(force: true);
  }
  }
}


  @override
  void dispose() {
   WidgetsBinding.instance.removeObserver(this); // 👈 ADD HERE
    super.dispose();
  }

  


 

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
if (result != true) return;
try {
    // -----------------------------------
    // Clear JWT / Refresh Token
    // -----------------------------------
    await AuthService.logout();

    // -----------------------------------
    // Optional old prefs cleanup
    // -----------------------------------
    final prefs =
        await SharedPreferences
            .getInstance();

    await prefs.clear();

    // -----------------------------------
    // Switch doctor inside app
    // -----------------------------------
    if (mounted) {
      setState(() {
        _state =
            AppStartupState
                .loggedOut;
                _isRegistering = false;
      });
    }

    // -----------------------------------
    // Optional messages
    // -----------------------------------
    if (kIsWeb) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Logged out successfully You can now close this tab.",
          ),
        ),
      );
    } else if (platform ==
        "android") {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Switched doctor successfully",
          ),
        ),
      );
        if (mounted) {
          setState(() {
        _state =
            AppStartupState
                .loggedOut;
                _isRegistering = false;
      });
    //setState(() => _state = AppStartupState.loggedOut);

      }
    }else if (platform == 'ios') {
        exit(0);
      }

  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          "Logout failed: $e",
        ),
      ),
    );
  }
    //3334324234
  //     if (kIsWeb) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text("You can now close this tab.")),
  //       );
  //     } else if (platform == 'android') {
  //       final prefs = await SharedPreferences.getInstance();
  // await prefs.clear();

  // if (mounted) {
  //   setState(() => _state = AppStartupState.loggedOut);

  //     }

      
  //       //SystemNavigator.pop();
  //     } else if (platform == 'ios') {
  //       exit(0);
  //     }
    

  

 
}

  void _onRegistered(DoctorInfo info) async {
  await _saveDoctorToLocal(info);

  if (mounted) {
    setState(() {
      _isRegistering = false;
      _state = AppStartupState.loggedIn;
    });
  }

 setState(() => _state = AppStartupState.loggedIn);
  context.read<LicenseProvider>().loadStatus(force: true);
}

void _handleLoginSuccess() {
  if (mounted) {
    setState(() {
      _state = AppStartupState.loggedIn;
    });
  }

 
  context.read<LicenseProvider>().loadStatus(force: true);
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
// 🔥 ADD LOGS HERE
print("🔥 STEP 10: UI decision");

  print("🔥 canPrescribe = ${license.canPrescribe}");
  print("🔥 expiry = ${license.subscriptionExpiry}");
  print("🔥 isSubscribed = ${license.isSubscribed}");
  print("🔥 isLoading = ${license.isLoading}");
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
          onSubscriptionActivated: _onSubscriptionActivated,//confirmExit,
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

  await licenseProvider.loadStatus(force: true); // re-check subscription from backend

  if (mounted) {
    setState(() {
      _state = AppStartupState.loggedIn;
    });
  }
}
Future<void> _onSubscriptionActivated() async {
  print("🔥 NAVIGATION TRIGGERED not doing any thing ");
  final license =
      context.read<LicenseProvider>();

  await license.loadStatus(force: true);

  
  setState(() {
    _state = AppStartupState.loggedIn;
  });
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
