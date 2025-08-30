

import 'dart:async';
import 'package:docautomations/widgets/AddPrescrip.dart';
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
    _checkTokens();
    _startTokenCheckTimer();
  }

  @override
  void dispose() {
    _tokenCheckTimer?.cancel();
    super.dispose();
  }

  // First check at startup
  Future<void> _checkTokens() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');
    final refreshToken = prefs.getString('refresh_token');

    if (accessToken != null && accessToken.isNotEmpty) {
      final isValid = await LicenseApiService.verifyToken(accessToken);

      if (isValid) {
        setState(() {
          _isLoggedIn = true;
          _checkingLogin = false;
        });
      } else if (refreshToken != null && refreshToken.isNotEmpty) {
        // Try to refresh access token
        final newAccess = await LicenseApiService.refreshAccessToken(refreshToken);
        if (newAccess != null) {
          await prefs.setString('access_token', newAccess);
          setState(() {
            _isLoggedIn = true;
            _checkingLogin = false;
          });
        } else {
          _logout();
        }
      } else {
        _logout();
      }
    } else {
      setState(() {
        _checkingLogin = false;
      });
    }
  }

  /// Re-check token periodically (every 5 min)
  void _startTokenCheckTimer() {
    _tokenCheckTimer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');
      final refreshToken = prefs.getString('refresh_token');

      if (accessToken == null || accessToken.isEmpty) {
        _logout();
        return;
      }

      final isValid = await LicenseApiService.verifyToken(accessToken);
      if (!isValid) {
        if (refreshToken != null && refreshToken.isNotEmpty) {
          final newAccess = await LicenseApiService.refreshAccessToken(refreshToken);
          if (newAccess != null) {
            await prefs.setString('access_token', newAccess);
            return;
          }
        }
        print("before Log out");
        _logout();
      }
    });
  }
  void _logout() async {
    print("inside Log out");
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
    setState(() {
      _isLoggedIn = false;
      _isRegistering = false;
    });
  }
  }

  /// Called when doctor successfully registers
  void _onRegistered(DoctorInfo info) async {
    print ("doctor info :- $info.info.name");
    await _saveDoctorToLocal(info);
    setState(() {
      _isLoggedIn = true;
      _isRegistering = false;
    });
  }

  /// Called when doctor successfully logs in
  void _handleLoginSuccess() async {
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
      return Menubar(
        body: Addprescrip(title: "PatientInfo"),
        onLogout: _logout,
      );
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
