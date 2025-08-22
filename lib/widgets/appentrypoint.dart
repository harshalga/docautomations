

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
