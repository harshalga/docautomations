import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DoctorLoginScreen extends StatefulWidget {
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
  String? _error;

  Future<void> _login() async {
    final prefs = await SharedPreferences.getInstance();
    final storedUsername = prefs.getString('doctor_username');
    final storedPassword = prefs.getString('doctor_password');

    if (storedUsername == _usernameController.text &&
        storedPassword == _passwordController.text) {
      widget.onLoginSuccess();
    } else {
      setState(() {
        _error = "Invalid username or password";
      });
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
            if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
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
            ElevatedButton(
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
