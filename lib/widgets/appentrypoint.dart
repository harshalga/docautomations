import 'dart:async';
import 'dart:io';
import 'package:docautomations/widgets/AddPrescrip.dart';
import 'package:docautomations/widgets/DoctorLoginScreen.dart';
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
     
     _checkLoginStatus(); // 👈 run only once at startup
    //  //trial/subscription status automatically refreshes when the app opens (or comes back from background)
    //  WidgetsBinding.instance.addObserver(this);
    //TODOPR
     
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
          body: Addprescrip(title: "Patient Diagnosis"),
          onLogout: _logout,
        );
      } else //Force paywall and prevent going back
      {
        return PaywallScreen(
          onSubscriptionActivated:()  {// Navigate to main app after successful subscription
          confirmExit();
        },
        onMaybeLater: () {
          // User declined — exit app safely
            confirmExit();
            },
      );//subscribe
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
String getPlatform() {
    if (Theme.of(context).platform == TargetPlatform.android) return "android";
    if (Theme.of(context).platform == TargetPlatform.iOS) return "ios";
    return "unknown"; //Bydefault we save android as the platform
  }
  Future<void> confirmExit() async {
    
    final platform = getPlatform();
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Exit App"),
        content: const Text("Are you sure you want to exit?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Yes"),
          ),
        ],
      ),
    );

    if (result == true) {

      if (kIsWeb) {

        // Web: just show message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("You can now close the browser tab.")),
        );
      } else if (platform== 'android') {

          SystemNavigator.pop();
        } else if (platform=='ios') {

          exit(0);
        }
    }
  }
}
