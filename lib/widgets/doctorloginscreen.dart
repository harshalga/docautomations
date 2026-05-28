





import 'package:docautomations/commonwidget/loadingOverlay.dart';
import 'package:docautomations/services/auth_service.dart';
import 'package:docautomations/services/license_api_service.dart';
import 'package:docautomations/services/logger_service.dart';
import 'package:docautomations/validationhandling/validator.dart';
import 'package:docautomations/widgets/forgot_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
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
  State<DoctorLoginScreen> createState() =>
      _DoctorLoginScreenState();
}

class _DoctorLoginScreenState
    extends State<DoctorLoginScreen> {
  final TextEditingController
      _usernameController =
      TextEditingController();

  final TextEditingController
      _passwordController =
      TextEditingController();

  bool _loading = false;
  bool _showPassword = false;

  String? _usernameError;
  String? _passwordError;

  // ==========================
  // VALIDATION
  // ==========================
  bool _validateFields() {
    final emailValidator =
        Validator.apply<String>(
      context,
      const [
        RequiredValidation(),
        EmailValidation(),
      ],
    );

    final passwordValidator =
        Validator.apply<String>(
      context,
      const [
        RequiredValidation(),
      ],
    );

    final username =
        _usernameController.text.trim();

    final password =
        _passwordController.text.trim();

    final usernameError =
        emailValidator(username);

    final passwordError =
        passwordValidator(password);

    setState(() {
      _usernameError = usernameError;
      _passwordError = passwordError;
    });

    return usernameError == null &&
        passwordError == null;
  }

  // ==========================
  // LOGIN
  // ==========================
  Future<void> _login() async {
    if (!_validateFields()) return;

    setState(() => _loading = true);

    try {
      final tokens =
          await LicenseApiService
              .loginDoctor(
        _usernameController.text
            .trim(),
        _passwordController.text
            .trim(),
      );

      if (!mounted) return;

      setState(() => _loading = false);

      if (tokens != null) {
        // ✅ Use AuthService
        await AuthService.saveTokens(
          accessToken:
              tokens["accessToken"] ??
                  "",
          refreshToken:
              tokens["refreshToken"] ??
                  "",
        );

        widget.onLoginSuccess();
      } else {
        setState(() {
          _passwordError =
              "Invalid username or password";
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _loading = false);

      setState(() {
        _passwordError =
            "Login failed";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _checkExistingLogin();
  }

  // ==========================
  // AUTO LOGIN
  // ==========================
  Future<void>
      _checkExistingLogin() async {
    final token =
        await AuthService.getToken();

    final refreshToken =
        await AuthService
            .getRefreshToken();

    if (token != null) {
      final valid =
          await LicenseApiService
              .verifyToken();

      if (valid) {
        widget.onLoginSuccess();
        return;
      }

      // token invalid -> refresh
      if (refreshToken != null) {
        final refreshed =
            await AuthService
                .refreshAccessToken();

        if (refreshed) {
          widget.onLoginSuccess();
          return;
        }
      }

      await AuthService.logout();
    }
  }

  // ==========================
  // SHARE LOGS
  // ==========================
  Future<void> _shareLogs() async {
    try {
      final file =
          await LoggerService
              .getLogFile();

      if (file == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              "No logs available",
            ),
          ),
        );
        return;
      }

      await Share.shareXFiles(
        [XFile(file.path)],
        subject:
            "Prescriptor App – Login Logs",
        text:
            "Please find attached logs.",
      );
    } catch (_) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text("Unable to share logs"),
        ),
      );
    }
  }

  // ==========================
  // UI
  // ==========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Doctor Login"),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding:
                const EdgeInsets.all(
                    24),
            child: Column(
              children: [
                const SizedBox(
                    height: 24),

                Center(
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius
                            .circular(
                                50),
                    child:
                        Image.asset(
                      'assets/icon/app_logo.png',
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(
                    height: 24),

                TextField(
                  controller:
                      _usernameController,
                  decoration:
                      InputDecoration(
                    labelText:
                        "User Email",
                    border:
                        const OutlineInputBorder(),
                    errorText:
                        _usernameError,
                  ),
                ),

                const SizedBox(
                    height: 16),

                TextField(
                  controller:
                      _passwordController,
                  obscureText:
                      !_showPassword,
                  decoration:
                      InputDecoration(
                    labelText:
                        "Password",
                    border:
                        const OutlineInputBorder(),
                    errorText:
                        _passwordError,
                    suffixIcon:
                        IconButton(
                      icon: Icon(
                        _showPassword
                            ? Icons
                                .visibility
                            : Icons
                                .visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _showPassword =
                              !_showPassword;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(
                    height: 24),

                ElevatedButton(
                  onPressed: _login,
                  child: const Text(
                      "Login"),
                ),

                const SizedBox(
                    height: 10),

                TextButton(
                  onPressed: () async {
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
                    setState(() => _loading = true);
                    final exists = await LicenseApiService.checkEmailExists(email);

                    if (!mounted) return;

                    setState(() => _loading = false);

                    if (!exists) {
                      setState(() {
                        _usernameError = "Email is not registered";
                      });
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ForgotPasswordScreen(
                          loginEmailId:
                              email,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    "Forgot Password?",
                  ),
                ),

                TextButton.icon(
                  icon: const Icon(Icons
                      .email_outlined),
                  label: const Text(
                    "Having trouble logging in? Share logs with support",
                  ),
                  onPressed:
                      _shareLogs,
                ),

                TextButton(
                  onPressed: widget
                      .onRegisterTap,
                  child: const Text(
                    "New user? Register here",
                  ),
                ),
              ],
            ),
          ),

          LoadingOverlay(
            isLoading: _loading,
            message:
                "Logging in…",
          ),
        ],
      ),
    );
  }
}