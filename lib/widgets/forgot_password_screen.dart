import 'package:docautomations/validationhandling/validator.dart';
import 'package:flutter/material.dart';
import 'package:docautomations/validationhandling/validation.dart';
import 'package:docautomations/services/license_api_service.dart';
import 'package:docautomations/commonwidget/loadingOverlay.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final String loginEmailId;

  const ForgotPasswordScreen({super.key, required this.loginEmailId});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _loading = false;

  // Track password visibility
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  String? _newPasswordError;
  String? _confirmPasswordError;

  /// Validate inputs and set inline error messages
  bool _validateFields() {
    final passwordValidator = Validator.apply<String>(
      context,
      const [RequiredValidation(), PasswordValidation(number: true,upperCase: true, specialChar: true)],
    );

    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    final newPasswordError = passwordValidator(newPassword);
    String? confirmPasswordError;

    if (confirmPassword.isEmpty) {
      confirmPasswordError = "Confirm password is required";
    } else if (newPassword != confirmPassword) {
      confirmPasswordError = "Passwords do not match";
    }

    setState(() {
      _newPasswordError = newPasswordError;
      _confirmPasswordError = confirmPasswordError;
    });

    return newPasswordError == null && confirmPasswordError == null;
  }

  /// Submit to backend
  Future<void> _resetPassword() async {
    if (!_validateFields()) return;

    setState(() => _loading = true);
    try {
      final success = await LicenseApiService().resetPassword(
         widget.loginEmailId.trim().toLowerCase(),
         _newPasswordController.text.trim(),
      );

      setState(() => _loading = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password reset successful ✅")),
        );
        Navigator.pop(context); // go back to login
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password reset failed ❌")),
        );
      }
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reset Password")),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 24),

                // New Password
                TextField(
                  controller: _newPasswordController,
                  obscureText: !_showNewPassword,
                  decoration: InputDecoration(
                    labelText: "New Password",
                    border: const OutlineInputBorder(),
                    errorText: _newPasswordError,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showNewPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() => _showNewPassword = !_showNewPassword);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Confirm Password
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: !_showConfirmPassword,
                  decoration: InputDecoration(
                    labelText: "Confirm Password",
                    border: const OutlineInputBorder(),
                    errorText: _confirmPasswordError,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showConfirmPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() => _showConfirmPassword = !_showConfirmPassword);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Reset Button
                ElevatedButton(
                  onPressed: _resetPassword,
                  child: const Text("Reset Password"),
                ),
              ],
            ),
          ),

          // Loading Overlay
          LoadingOverlay(isLoading: _loading, message: "Resetting password…"),
        ],
      ),
    );
  }
}
