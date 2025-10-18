// import 'package:docautomations/commonwidget/advaLoadingOverlay.dart';
// import 'package:flutter/material.dart';
// import 'package:docautomations/services/license_api_service.dart';
// import 'package:docautomations/commonwidget/AdvaLoadingOverlay.dart';

// class ForgotPasswordScreen extends StatefulWidget {
//   final String loginEmailId; 
//   const ForgotPasswordScreen({Key? key, required this.loginEmailId}) : super(key: key);

//   @override
//   State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
// }

// class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _newPassController = TextEditingController();
//   final TextEditingController _confirmPassController = TextEditingController();
//   bool _isLoading = false;

//   Future<void> _resetPassword() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => _isLoading = true);
//     final newPassword = _newPassController.text.trim();

//     try {
//       // Call your backend API here
//       final success = await LicenseApiService().resetPassword(widget.loginEmailId,  newPassword);

//       if (success) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Password updated successfully!")),
//         );
//         Navigator.pop(context);
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Failed to update password.")),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error: $e")),
//       );
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AdvaLoadingOverlay(
//       isLoading: _isLoading,
//       child: Scaffold(
//         appBar: AppBar(title: const Text("Reset Password")),
//         body: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 TextFormField(
//                   controller: _newPassController,
//                   decoration: const InputDecoration(
//                     labelText: "New Password",
//                     border: OutlineInputBorder(),
//                   ),
//                   obscureText: true,
//                   validator: (value) =>
//                       value == null || value.isEmpty ? "Enter new password" : null,
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _confirmPassController,
//                   decoration: const InputDecoration(
//                     labelText: "Confirm Password",
//                     border: OutlineInputBorder(),
//                   ),
//                   obscureText: true,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return "Re-enter password";
//                     }
//                     if (value != _newPassController.text) {
//                       return "Passwords do not match";
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: _resetPassword,
//                   child: const Text("Update Password"),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


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
      const [RequiredValidation(), PasswordValidation(minLength: 6, number: true)],
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
         widget.loginEmailId,
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
