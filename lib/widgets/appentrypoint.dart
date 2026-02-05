import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
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

class _AppEntryPointState extends State<AppEntryPoint> {
  bool _isLoggedIn = false;
  bool _isRegistering = false;
  bool _checkingLogin = true;

  bool _offline = false; // 👈 ADD THIS

  Timer? _tokenCheckTimer;

  @override
  void initState() {
    super.initState();
  //  _checkLoginStatus();   // Run only once on startup
   _bootstrap();
  }


Future<void> _bootstrap() async {
  // 1️⃣ Wake Render backend (cold start absorption)
  await  LicenseApiService.warmUpBackend();

  // 2️⃣ Small buffer (smooth UX)
  await Future.delayed(const Duration(milliseconds: 500));

  // 3️⃣ Existing login logic (unchanged)
  await _checkLoginStatus(); // Run only once on startup
}

Future<bool> _hasInternet() async {
  try {
    final result = await InternetAddress.lookup('google.com');
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } catch (_) {
    return false;
  }
}


  @override
  void dispose() {
    _tokenCheckTimer?.cancel();
    super.dispose();
  }

  // -------------------------------------------------------------
  // MAIN LOGIN CHECK — FIXED TO NOT RESET UI EVERY 5 MINUTES
  // -------------------------------------------------------------
  Future<void> _checkLoginStatus() async {

    // 🌐 OFFLINE CHECK — FIRST
  if (!await _hasInternet()) {
    if (mounted) {
      setState(() {
        _offline = true;
        _checkingLogin = false;
      });
    }
    return; // ⛔ STOP EVERYTHING
  }

  // reset offline if internet is back
  if (_offline) {
    setState(() => _offline = false);
  }

    final prefs = await SharedPreferences.getInstance();

    final accessToken = prefs.getString('access_token');
    final refreshToken = prefs.getString('refresh_token');

    final bool wasLoggedIn = _isLoggedIn;

    // Not logged in at all
    if (accessToken == null || accessToken.isEmpty) {
      if (!_isLoggedIn) {
        setState(() {
          _checkingLogin = false;
           _offline = false; // 👈 reset
        });
      }
      return;
    }
  
try{
    // Check validity silently
    //final bool isValid = await LicenseApiService.verifyToken(accessToken);
    final bool isValid = await LicenseApiService.verifyToken();
    if (isValid) {
      if (!wasLoggedIn) _markLoggedInOnce();
      return;
    }

    // Try refresh token
    if (refreshToken != null && refreshToken.isNotEmpty) {
      final String? newAccess = await LicenseApiService.refreshAccessToken(refreshToken);

      if (newAccess != null) {
        await prefs.setString('access_token', newAccess);
        if (!wasLoggedIn) _markLoggedInOnce();
        return;
      }
    }

    // Logout ONLY if previously logged in
    if (wasLoggedIn) {
      _logout();
    }
  }
  catch (e) {

  // // 🌐 OFFLINE / DNS / NO INTERNET
  //   if (mounted) {
  //     setState(() {
  //       _offline = true;
  //       _checkingLogin = false;
  //     });
  //   }
  if (e is SocketException || e is DioException) {
    if (mounted) {
      setState(() {
        _offline = true;
        _checkingLogin = false;
      });
    }
  } else {
    rethrow; // 👈 real errors should surface
  }
  }

}


  // -------------------------------------------------------------
  // MARK LOGGED IN — ONLY RUN ONCE
  // -------------------------------------------------------------
  void _markLoggedInOnce() {
    if (!_isLoggedIn) {
      setState(() {
        _isLoggedIn = true;
        _checkingLogin = false;
      });
    }

    // Start silent refresh
    _tokenCheckTimer ??= Timer.periodic(const Duration(minutes: 5), (_) => _checkLoginStatus());

    // Silent status refresh (DOES NOT rebuild UI)
    context.read<LicenseProvider>().loadStatus();
  }

  // -------------------------------------------------------------
  // LOGOUT
  // -------------------------------------------------------------
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
    _tokenCheckTimer = null;
  }

  void _onRegistered(DoctorInfo info) async {
    await _saveDoctorToLocal(info);
    _markLoggedInOnce();
  }

  void _handleLoginSuccess() {
    _markLoggedInOnce();
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingLogin) {
      //return const Scaffold(body: Center(child: CircularProgressIndicator()));
      return const SplashScreen();
    }

// 🌐 OFFLINE SCREEN
  if (_offline) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No internet connection',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please check your network and try again.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _offline = false;
                  _checkingLogin = true;
                });
                _bootstrap(); // 🔁 retry warm-up + login
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
    

    if (_isLoggedIn) {
      final license = context.watch<LicenseProvider>();

      if (license.isLoading) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      if (license.canPrescribe) {
        return Menubar(
          body: const Addprescrip(title: "Patient Diagnosis"),
          onLogout: _logout,
        );
      } else {
        return PaywallScreen(
          onSubscriptionActivated: () {
            confirmExit();
          },
          onMaybeLater: () {
            confirmExit();
          },
        );
      }
    }

    // Register or Login UI
    if (_isRegistering) {
      return DoctorRegisterScreen(onRegistered: _onRegistered);
    } 
      return DoctorLoginScreen(
        onLoginSuccess: _handleLoginSuccess,
        onRegisterTap: () => setState(() => _isRegistering = true),
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
