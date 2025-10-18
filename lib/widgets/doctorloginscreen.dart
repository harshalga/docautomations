



import 'package:docautomations/commonwidget/loadingOverlay.dart';
import 'package:docautomations/services/license_api_service.dart';
import 'package:docautomations/validationhandling/validator.dart';
import 'package:docautomations/widgets/forgot_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:docautomations/validationhandling/validation.dart';

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

  bool _loading = false;
  bool _showPassword = false; // toggle for password visibility

  String? _usernameError;
  String? _passwordError;

  /// Validate fields and set inline errors
  bool _validateFields() {
    final emailValidator = Validator.apply<String>(
      context,
      const [RequiredValidation(), EmailValidation()],
    );
    final passwordValidator = Validator.apply<String>(
      context,
      const [RequiredValidation()],
    );

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    final usernameError = emailValidator(username);
    final passwordError = passwordValidator(password);

    setState(() {
      _usernameError = usernameError;
      _passwordError = passwordError;
    });

    return usernameError == null && passwordError == null;
  }

  /// Login API call
  Future<void> _login() async {
    if (!_validateFields()) return;

    setState(() => _loading = true);
    try {
      final tokens = await LicenseApiService.loginDoctor(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );

      setState(() => _loading = false);

      if (tokens != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("access_token", tokens["accessToken"]??"");
        await prefs.setString("refresh_token", tokens["refreshToken"]??"");
        widget.onLoginSuccess();
      } else {
        setState(() {
          _passwordError = "Invalid username or password";
        });
      }
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
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
        final newAccessToken =
            await LicenseApiService.refreshAccessToken(refreshToken);
        if (newAccessToken != null) {
          await prefs.setString("access_token", newAccessToken);
          widget.onLoginSuccess();
          return;
        }
      }
      await LicenseApiService.logoutDoctor();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Doctor Login")),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 24),

                // Logo
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.asset(
                      'assets/icon/app_logo.png',
                      
                      width: 300,
                      height: 300,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Username / Email
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: "User Email",
                    border: const OutlineInputBorder(),
                    errorText: _usernameError,
                  ),
                ),
                const SizedBox(height: 16),

                // Password with show/hide toggle
                TextField(
                  controller: _passwordController,
                  obscureText: !_showPassword,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: const OutlineInputBorder(),
                    errorText: _passwordError,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() => _showPassword = !_showPassword);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Login Button
                ElevatedButton(
                  onPressed: _login,
                  child: const Text("Login"),
                ),
                const SizedBox(height: 24),

                // Forgot Password
                TextButton(
                  onPressed: () {
                    final emailValidator = Validator.apply<String>(
                      context,
                      const [RequiredValidation(), EmailValidation()],
                    );
                    final email = _usernameController.text.trim();
                    final error = emailValidator(email);

                    if (error != null) {
                      setState(() {
                        _usernameError = error;
                      });
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ForgotPasswordScreen(loginEmailId: email),
                      ),
                    );
                  },
                  child: const Text("Forgot Password?"),
                ),

                // Register
                TextButton(
                  onPressed: widget.onRegisterTap,
                  child: const Text("New user? Register here"),
                ),
              ],
            ),
          ),

          // Loading overlay
          LoadingOverlay(isLoading: _loading, message: "Logging in…"),
        ],
      ),
    );
  }
}
