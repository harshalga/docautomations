
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:docautomations/providers/authentication_provider.dart';
import 'package:docautomations/validationhandling/validator.dart';
import 'package:docautomations/validationhandling/validation.dart';
import 'package:docautomations/commonwidget/loadingOverlay.dart';

//=============================================================================
// FORGOT PASSWORD SCREEN
//=============================================================================

class ForgotPasswordScreen extends StatefulWidget {
  final String loginEmailId;

  const ForgotPasswordScreen({
    super.key,
    required this.loginEmailId,
  });

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  //-------------------------------------------------------------------------
  // TEXT CONTROLLERS
  //-------------------------------------------------------------------------

  final TextEditingController _newPasswordController =
      TextEditingController();

  final TextEditingController _confirmPasswordController =
      TextEditingController();

  //-------------------------------------------------------------------------
  // STATE
  //-------------------------------------------------------------------------

  bool _loading = false;

  bool _showNewPassword = false;

  bool _showConfirmPassword = false;

  String? _newPasswordError;

  String? _confirmPasswordError;

  
  final TextEditingController _otpController =
      TextEditingController();

  bool _otpRequested = false;

  bool _requestingOtp = false;

  String? _otpError;


  //-------------------------------------------------------------------------
  // LIFECYCLE
  //-------------------------------------------------------------------------

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _otpController.dispose();

    super.dispose();
  }

  //-------------------------------------------------------------------------
  // VALIDATION
  //-------------------------------------------------------------------------

  bool _validateFields() {
    final passwordValidator = Validator.apply<String>(
      context,
      const [
        RequiredValidation(),
        PasswordValidation(
          number: true,
          upperCase: true,
          specialChar: true,
        ),
      ],
    );

    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    final newPasswordError = passwordValidator(newPassword);

    String? confirmPasswordError;

    if (confirmPassword.trim().isEmpty) {
      confirmPasswordError = 'Confirm password is required';
    } else if (newPassword != confirmPassword) {
      confirmPasswordError = 'Passwords do not match';
    }

    setState(() {
      _newPasswordError = newPasswordError;
      _confirmPasswordError = confirmPasswordError;
    });

    return newPasswordError == null &&
        confirmPasswordError == null;
  }



  Future<void> _requestOtp() async {
    if (_requestingOtp || _loading) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _requestingOtp = true;
      _otpError = null;
    });

    try {
      final provider =
          context.read<AuthenticationProvider>();

      final success =
          await provider.requestPasswordResetOtp(
        loginEmail: widget.loginEmailId,
      );

      if (!mounted) return;

      if (success) {
        setState(() {
          _otpRequested = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'If an account exists for this email, '
              'a verification code will be sent.',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to request the code. Please try again.',
            ),
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to request the code. Please try again.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _requestingOtp = false;
        });
      }
    }
  }



  //-------------------------------------------------------------------------
  // RESET PASSWORD
  //-------------------------------------------------------------------------

  Future<void> _resetPassword() async {
    if (_loading) return;

    FocusScope.of(context).unfocus();

    if (!_validateFields()) return;

    if (!_otpRequested) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Please request a verification code first.'),
    ),
  );
  return;
}

final otp = _otpController.text.trim();

if (!RegExp(r'^\d{6}$').hasMatch(otp)) {
  setState(() {
    _otpError = 'Enter the 6-digit verification code';
  });
  return;
}

    setState(() {
      _loading = true;
    });

    try {
      final authenticationProvider =
          context.read<AuthenticationProvider>();

      final success = await authenticationProvider.resetPassword(
  loginEmail: widget.loginEmailId.trim().toLowerCase(),
  otp: otp,
  newPassword: _newPasswordController.text,
);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset successful.'),
          ),
        );

        // Return to the existing login screen.
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Password reset failed. Please try again.',
            ),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to reset password. Please try again.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  //-------------------------------------------------------------------------
  // BUILD
  //-------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 440,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.lock_reset_rounded,
                        size: 64,
                      ),

                      const SizedBox(height: 20),

                      Text(
                        'Create a new password',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        'Enter a new password for ${widget.loginEmailId}.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),

                      const SizedBox(height: 32),


                      
  // OTP REQUEST BUTTON

  SizedBox(
    height: 48,
    child: OutlinedButton(
      onPressed:
          (_loading || _requestingOtp) ? null : _requestOtp,
      child: Text(
        _requestingOtp
            ? 'Requesting code...'
            : _otpRequested
                ? 'Resend verification code'
                : 'Send verification code',
      ),
    ),
  ),

  const SizedBox(height: 20),

  // OTP INPUT

  TextField(
    controller: _otpController,
    enabled: !_loading && _otpRequested,
    keyboardType: TextInputType.number,
    maxLength: 6,
    autocorrect: false,
    enableSuggestions: false,
    textInputAction: TextInputAction.next,
    onChanged: (_) {
      if (_otpError != null) {
        setState(() {
          _otpError = null;
        });
      }
    },
    decoration: InputDecoration(
      labelText: 'Email verification code',
      hintText: 'Enter the 6-digit code',
      border: const OutlineInputBorder(),
      counterText: '',
      errorText: _otpError,
      prefixIcon: const Icon(Icons.mark_email_read_outlined),
    ),
  ),

  const SizedBox(height: 20),


                      // NEW PASSWORD

                      TextField(
                        controller: _newPasswordController,
                        obscureText: !_showNewPassword,
                        enabled: !_loading,
                        autocorrect: false,
                        enableSuggestions: false,
                        textInputAction: TextInputAction.next,
                        onChanged: (_) {
                          if (_newPasswordError != null) {
                            setState(() {
                              _newPasswordError = null;
                            });
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          hintText: 'Enter your new password',
                          border: const OutlineInputBorder(),
                          errorText: _newPasswordError,
                          prefixIcon: const Icon(
                            Icons.lock_outline_rounded,
                          ),
                          suffixIcon: IconButton(
                            tooltip: _showNewPassword
                                ? 'Hide password'
                                : 'Show password',
                            onPressed: _loading
                                ? null
                                : () {
                                    setState(() {
                                      _showNewPassword =
                                          !_showNewPassword;
                                    });
                                  },
                            icon: Icon(
                              _showNewPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // CONFIRM PASSWORD

                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: !_showConfirmPassword,
                        enabled: !_loading,
                        autocorrect: false,
                        enableSuggestions: false,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) {
                          if (!_loading) {
                            _resetPassword();
                          }
                        },
                        onChanged: (_) {
                          if (_confirmPasswordError != null) {
                            setState(() {
                              _confirmPasswordError = null;
                            });
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          hintText: 'Re-enter your new password',
                          border: const OutlineInputBorder(),
                          errorText: _confirmPasswordError,
                          prefixIcon: const Icon(
                            Icons.lock_outline_rounded,
                          ),
                          suffixIcon: IconButton(
                            tooltip: _showConfirmPassword
                                ? 'Hide password'
                                : 'Show password',
                            onPressed: _loading
                                ? null
                                : () {
                                    setState(() {
                                      _showConfirmPassword =
                                          !_showConfirmPassword;
                                    });
                                  },
                            icon: Icon(
                              _showConfirmPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        'Password must contain an uppercase letter, '
                        'a number, and a special character.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),

                      const SizedBox(height: 28),

                      SizedBox(
                        height: 52,
                        child: FilledButton(
                          onPressed: _loading ? null : _resetPassword,
                          child: const Text(
                            'Reset Password',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            LoadingOverlay(
              isLoading: _loading,
              message: 'Resetting password…',
            ),
          ],
        ),
      ),
    );
  }
}
