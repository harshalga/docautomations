
import 'package:docautomations/services/license_api_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DoctorLoginScreen extends StatefulWidget {
   //final void Function(String accessToken, String refreshToken) 
  final VoidCallback onLoginSuccess; 
  final VoidCallback onRegisterTap;

  const DoctorLoginScreen({
    super.key,
    required this.onLoginSuccess,
    required this.onRegisterTap,
  });

  @override
  State<DoctorLoginScreen> createState() => _DoctorLoginScreenState();
}

class _DoctorLoginScreenState extends State<DoctorLoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    setState(() => _loading = true);

    

    final tokens  = await LicenseApiService.loginDoctor(
      _usernameController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() => _loading = false);

    if (tokens != null) {
      final prefs = await SharedPreferences.getInstance();
      final accessTok = tokens["accessToken"] ;
      final refreshTok = tokens["refreshToken"];
      
      // // await prefs.setString("access_token", tokens["accessToken"] ??"");
      // // await prefs.setString("refresh_token", tokens["refreshToken"]??"");
      // await prefs.setString("access_token", accessTok!);
      // await prefs.setString("refresh_token",refreshTok!);
       
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login successful ✅')),
      );
      widget.onLoginSuccess();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed ❌')),
      );
      setState(() {
        _error = "Invalid username or password";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _checkExistingLogin();
  }

  Future<void> _checkExistingLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');
    final refreshToken = prefs.getString('refresh_token');

    if (accessToken != null) {
      bool valid = await LicenseApiService.verifyToken(accessToken);
      if (valid) {
        widget.onLoginSuccess();
        return;
      } else if (refreshToken != null) {
        /// try refreshing if access token expired
        final newAccessToken =
            await LicenseApiService.refreshAccessToken(refreshToken);
        if (newAccessToken != null) {
          await prefs.setString("access_token", newAccessToken);
          widget.onLoginSuccess();
          return;
        }
      }
      /// if still not valid → logout
      await LicenseApiService.logoutDoctor();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Doctor Login")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: "Username"),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login,
                    child: const Text("Login"),
                  ),
            TextButton(
              onPressed: widget.onRegisterTap,
              child: const Text("New user? Register here"),
            )
          ],
        ),
      ),
    );
  }
}
