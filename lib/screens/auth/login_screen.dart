import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:docautomations/screens/auth/forgot_password_screen.dart';
import 'package:docautomations/services/logger_service.dart';

import 'package:docautomations/providers/authentication_provider.dart';

import 'dart:convert';
import 'dart:typed_data';
import 'dart:io' show Platform, File;

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';







//=============================================================================
// LOGIN SCREEN
//=============================================================================
//
// Responsibilities:
//
//   - Display doctor login form.
//   - Validate login input.
//   - Request authentication through AuthenticationProvider.
//   - Display authentication errors.
//   - Notify AppEntryPoint after successful login.
//   - Request navigation to RegistrationScreen.
//
// This screen does NOT:
//
//   - call AuthService directly
//   - call Dio directly
//   - access SharedPreferences
//   - access secure storage
//   - load doctor profile
//   - load doctor logo/signature
//   - perform application bootstrap
//   - access patient or prescription data
//
// Flow:
//
//   LoginScreen
//        ↓
//   AuthenticationProvider
//        ↓
//   AuthService
//        ↓
//   Backend
//
// On successful login:
//
//   LoginScreen
//        ↓
//   AppEntryPoint
//        ↓
//   ApplicationBootstrapper
//        ↓
//   PatientSearchScreen
//
// Registration:
//
//   LoginScreen
//        ↓
//   onRegisterRequested
//        ↓
//   AppEntryPoint
//        ↓
//   RegistrationScreen
//
//=============================================================================

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.onLoginSuccess,
    required this.onRegisterRequested,
  });

  //-------------------------------------------------------------------------
  // CALLBACKS
  //-------------------------------------------------------------------------

  /// Called after authentication succeeds.
  final Future<void> Function() onLoginSuccess;

  /// Called when the doctor wants to create a new account.
  final VoidCallback onRegisterRequested;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}


//=============================================================================
// LOGIN SCREEN STATE
//=============================================================================

class _LoginScreenState extends State<LoginScreen> {

  //-------------------------------------------------------------------------
  // FORM
  //-------------------------------------------------------------------------

  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();


  //-------------------------------------------------------------------------
  // TEXT CONTROLLERS
  //-------------------------------------------------------------------------

  final TextEditingController _loginEmailController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();


  //-------------------------------------------------------------------------
  // PASSWORD VISIBILITY
  //-------------------------------------------------------------------------

  bool _obscurePassword = true;


  //-------------------------------------------------------------------------
  // LIFECYCLE
  //-------------------------------------------------------------------------

  @override
  void dispose() {

    _loginEmailController.dispose();

    _passwordController.dispose();

    super.dispose();
  }


Future<void> _forgotPassword() async {
  final email = _loginEmailController.text.trim();

  if (email.isEmpty || !email.contains('@')) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Please enter a valid email address first.',
        ),
      ),
    );
    return;
  }

  FocusScope.of(context).unfocus();

  // final authenticationProvider =
  //     context.read<AuthenticationProvider>();

  try {
    // final exists =
    //     await authenticationProvider.checkEmailExists(email);

    // if (!mounted) return;

    // if (!exists) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text(
    //         'No account found for this email address.',
    //       ),
    //     ),
    //   );
    //   return;
    // }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ForgotPasswordScreen(
          loginEmailId: email,
        ),
      ),
    );
  } catch (_) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Unable to verify email. Please try again.',
        ),
      ),
    );
  }
}


Future<void> _openDemoPlaylist() async {
  const String playlistUrl =
      'https://www.youtube.com/playlist?list=PLLikLK39r_Zo';

  final Uri uri = Uri.parse(playlistUrl);

  try {
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched) {
      throw Exception('Unable to launch YouTube.');
    }
  } catch (_) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Unable to open YouTube.'),
      ),
    );
  }
}


// Future<void> _shareLogs() async {
//   try {
//     final content = await LoggerService.getLogContent();

//     if (!mounted) return;

//     if (content == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('No logs available'),
//         ),
//       );
//       return;
//     }

//     final tempDir = await getTemporaryDirectory();
//     final file = File(
//       '${tempDir.path}/prescriptor_logs.txt',
//     );

//     await file.writeAsString(content, flush: true);

//     if (!mounted) return;

//     await Share.shareXFiles(
//       [XFile(file.path)],
//       subject: 'Prescriptor App – Login Logs',
//       text: 'Please find attached logs.',
//     );
//   } catch (error) {
//     if (!mounted) return;

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Unable to share logs'),
//       ),
//     );

//     debugPrint('Unable to share logs: $error');
//   }
// }




  //-------------------------------------------------------------------------
  // LOGIN
  //-------------------------------------------------------------------------

  Future<void> _login() async {

    //-------------------------------------------------------------------------
    // VALIDATE FORM
    //-------------------------------------------------------------------------

    if (!_formKey.currentState!.validate()) {
      return;
    }


    FocusScope.of(context).unfocus();


    //-------------------------------------------------------------------------
    // GET AUTHENTICATION PROVIDER
    //-------------------------------------------------------------------------

    final authenticationProvider =
        context.read<AuthenticationProvider>();


    //-------------------------------------------------------------------------
    // CLEAR PREVIOUS ERROR
    //-------------------------------------------------------------------------

    authenticationProvider.clearError();


    //-------------------------------------------------------------------------
    // AUTHENTICATE
    //-------------------------------------------------------------------------

    final success =
        await authenticationProvider.login(

      loginEmail:
          _loginEmailController.text.trim(),

      password:
          _passwordController.text,

    );


    if (!mounted) {
      return;
    }


    //-------------------------------------------------------------------------
    // LOGIN FAILED
    //
    // AuthenticationProvider already contains the error message.
    //
    //-------------------------------------------------------------------------

    if (!success) {
      return;
    }


    //-------------------------------------------------------------------------
    // LOGIN SUCCESS
    //
    // AppEntryPoint now performs application bootstrap.
    //
    //-------------------------------------------------------------------------

    await widget.onLoginSuccess();
  }


  //-------------------------------------------------------------------------
  // REGISTER
  //-------------------------------------------------------------------------
  //
  // This callback means:
  //
  //     "The user is requesting to open RegistrationScreen."
  //
  // It does NOT mean registration has completed.
  //
  //-------------------------------------------------------------------------

  void _requestRegistration() {

    FocusScope.of(context).unfocus();

    widget.onRegisterRequested();
  }


  //-------------------------------------------------------------------------
  // BUILD
  //-------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    return Scaffold(

      body: SafeArea(

        child: Consumer<AuthenticationProvider>(

          builder: (
            context,
            authentication,
            child,
          ) {

            return Center(

              child: SingleChildScrollView(

                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),

                child: ConstrainedBox(

                  constraints: const BoxConstraints(
                    maxWidth: 440,
                  ),

                  child: Form(

                    key: _formKey,

                    child: Column(

                      crossAxisAlignment:
                          CrossAxisAlignment.stretch,

                      children: [

                        //=======================================================
                        // BRANDING
                        //=======================================================

                        _buildBranding(theme),

                        const SizedBox(height: 40),


                        //=======================================================
                        // LOGIN TITLE
                        //=======================================================

                        Text(
                          'Doctor Login',

                          textAlign: TextAlign.center,

                          style:
                              theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 8),


                        Text(
                          'Already registered? Login below',

                          textAlign: TextAlign.center,

                          style:
                              theme.textTheme.bodyMedium?.copyWith(
                            color:
                                theme.colorScheme.onSurfaceVariant,
                          ),
                        ),

                        const SizedBox(height: 32),


                        //=======================================================
                        // ERROR MESSAGE
                        //=======================================================

                        if (authentication.errorMessage != null)
                          _buildErrorMessage(
                            theme,
                            authentication.errorMessage!,
                          ),

                        if (authentication.errorMessage != null)
                          const SizedBox(height: 16),


                        //=======================================================
                        // loginEmail
                        //=======================================================

                        TextFormField(

                          controller:
                              _loginEmailController,

                          keyboardType:
                              TextInputType.emailAddress,

                          textInputAction:
                              TextInputAction.next,

                          enabled:
                              !authentication.isLoading,

                          autocorrect:
                              false,

                          decoration:
                              const InputDecoration(

                            labelText:
                                'Email',

                            hintText:
                                'Enter your email',

                            prefixIcon:
                                Icon(
                              Icons.email_outlined,
                            ),
                          ),

                          validator: (value) {

                            final loginEmail =
                                value?.trim() ?? '';

                            if (loginEmail.isEmpty) {

                              return 'Please enter your email';
                            }

                            if (!loginEmail.contains('@')) {

                              return 'Please enter a valid email';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 20),


                        //=======================================================
                        // PASSWORD
                        //=======================================================

                        TextFormField(

                          controller:
                              _passwordController,

                          obscureText:
                              _obscurePassword,

                          textInputAction:
                              TextInputAction.done,

                          enabled:
                              !authentication.isLoading,

                          onFieldSubmitted: (_) {

                            if (!authentication.isLoading) {
                              _login();
                            }
                          },

                          decoration:
                              InputDecoration(

                            labelText:
                                'Password',

                            hintText:
                                'Enter your password',

                            prefixIcon:
                                const Icon(
                              Icons.lock_outline_rounded,
                            ),

                            suffixIcon:
                                IconButton(

                              tooltip:
                                  _obscurePassword
                                      ? 'Show password'
                                      : 'Hide password',

                              onPressed:
                                  authentication.isLoading
                                      ? null
                                      : () {

                                          setState(() {

                                            _obscurePassword =
                                                !_obscurePassword;

                                          });
                                        },

                              icon:
                                  Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),

                          validator: (value) {

                            if (value == null ||
                                value.isEmpty) {

                              return 'Please enter your password';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 28),


                        //Forgot Password
                          // Align(
                          //   alignment: Alignment.centerRight,
                          //   child: TextButton(
                          //     onPressed: authentication.isLoading
                          //         ? null
                          //         : _openForgotPassword,
                          //     child: const Text(
                          //       'Forgot Password?',
                          //       style: TextStyle(
                          //         fontWeight: FontWeight.w600,
                          //       ),
                          //     ),
                          //   ),
                          // ),

Align(
  alignment: Alignment.centerRight,
  child: TextButton(
    onPressed: authentication.isLoading
        ? null
        : _forgotPassword,
    child: const Text(
      'Forgot Password?',
      style: TextStyle(
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
),

const SizedBox(height: 12),

                          const SizedBox(height: 12),



                        //=======================================================
                        // LOGIN BUTTON
                        //=======================================================

                        SizedBox(

                          height: 52,

                          child: FilledButton(

                            onPressed:
                                authentication.isLoading
                                    ? null
                                    : _login,

                            child:
                                authentication.isLoading

                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,

                                        child:
                                            CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                        ),
                                      )

                                    : const Text(
                                        'Login',

                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight:
                                              FontWeight.w700,
                                        ),
                                      ),
                          ),
                        ),

                        const SizedBox(height: 28),


                        //=======================================================
                        // REGISTRATION DIVIDER
                        //=======================================================

                        Row(

                          children: [

                            Expanded(
                              child: Divider(
                                color:
                                    theme.colorScheme.outlineVariant,
                              ),
                            ),

                            Padding(

                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),

                              child: Text(
                                'New to Prescriptor?',

                                style:
                                    theme.textTheme.bodySmall?.copyWith(
                                  color:
                                      theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),

                            Expanded(
                              child: Divider(
                                color:
                                    theme.colorScheme.outlineVariant,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),


                        //=======================================================
                        // REGISTER BUTTON
                        //=======================================================

                        SizedBox(

                          height: 50,

                          child: OutlinedButton.icon(

                            onPressed:
                                authentication.isLoading
                                    ? null
                                    : _requestRegistration,

                            icon:
                                const Icon(
                              Icons.person_add_alt_1_rounded,
                            ),

                            label:
                                const Text(
                              'Create Doctor Account',

                              style: TextStyle(
                                fontWeight:
                                    FontWeight.w700,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

const SizedBox(height: 24),

                            // =====================================================
                            // WATCH APP DEMO
                            // =====================================================

                            Card(
                              color: Colors.red.shade50,
                              elevation: 0,
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                leading: const Icon(
                                  Icons.play_circle_fill,
                                  color: Colors.red,
                                  size: 36,
                                ),
                                title: const Text(
                                  'Watch App Demo',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: const Text(
                                  'See how to create prescriptions in just 2 minutes',
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                ),
                                onTap: _openDemoPlaylist,
                              ),
                            ),

                            const SizedBox(height: 10),

                            // =====================================================
                            // LOGIN SUPPORT / SHARE LOGS
                            // =====================================================

                            Card(
                              color: Colors.blue.shade50,
                              elevation: 0,
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                leading: const Icon(
                                  Icons.support_agent,
                                  color: Color.fromARGB(255, 30, 124, 218),
                                  size: 36,
                                ),
                                title: const Text(
                                  'Login Problem?',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: const Text(
                                  'Tap here to send logs to support',
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                ),
                                onTap: _shareLogs,
                              ),
                            ),

                            const SizedBox(height: 24),


                        //=======================================================
                        // FOOTER
                        //=======================================================

                        Text(
                          'Prescriptor',

                          textAlign: TextAlign.center,

                          style:
                              theme.textTheme.bodySmall?.copyWith(
                            color:
                                theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }


  //-------------------------------------------------------------------------
  // BRANDING
  //-------------------------------------------------------------------------


//-------------------------------------------------------------------------
// BRANDING
//-------------------------------------------------------------------------

Widget _buildBranding(
  ThemeData theme,
) {

  return Column(

    children: [

      //=====================================================================
      // PRESCRIPTOR LOGO
      //=====================================================================

      Container(

        width:
            150,

        height:
            150,

        decoration:
            BoxDecoration(

          borderRadius:
              BorderRadius.circular(35),

          boxShadow: const [

            BoxShadow(
              color:
                  Color(0x18000000),

              blurRadius:
                  10,

              offset:
                  Offset(0, 4),
            ),
          ],
        ),


        child:
            ClipRRect(

          borderRadius:
              BorderRadius.circular(35),

          child:
              Image.asset(

            'assets/icon/app_logo.png',

            width:
                150,

            height:
                150,

            fit:
                BoxFit.cover,
          ),
        ),
      ),


      const SizedBox(
        height: 18,
      ),


      //=====================================================================
      // APPLICATION NAME
      //=====================================================================

      Text(

        'PRESCRIPTOR',

        style:
            theme.textTheme.headlineMedium?.copyWith(

          fontWeight:
              FontWeight.w800,

          letterSpacing:
              1.5,
        ),
      ),
    ],
  );
}


Future<void> _openForgotPassword() async {

    final email =
        _loginEmailController.text.trim().toLowerCase();

  if (email.isEmpty || !email.contains('@')) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Please enter a valid email address first.',
        ),
      ),
    );
    return;
  }

  FocusScope.of(context).unfocus();

  final authenticationProvider =
      context.read<AuthenticationProvider>();

  try {
        final exists =
            await authenticationProvider.checkEmailExists(
                email,
            );

        if (!mounted) return;

        if (!exists) {

            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text(
                        "No account was found for this email address.",
                    ),
                ),
            );

            return;
        }

        await Navigator.of(context).push(
            MaterialPageRoute(
                builder: (_) => ForgotPasswordScreen(
                    loginEmailId: email,
                ),
            ),
        );

    } catch (error) {

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    "Unable to verify the email. Please try again.",
                ),
            ),
        );

    }

}


// //-------------------------------------------------------------------------
//   //forgot password
//   //-------------------------------------------------------------------------

// Future<void> _forgotPassword() async {
//   final email = _loginEmailController.text.trim();

//   if (email.isEmpty || !email.contains('@')) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text(
//           'Please enter a valid email address first.',
//         ),
//       ),
//     );
//     return;
//   }

//   FocusScope.of(context).unfocus();

//   final authenticationProvider =
//       context.read<AuthenticationProvider>();

//   try {
//     final exists =
//         await authenticationProvider.checkEmailExists(email);

//     if (!mounted) return;

//     if (!exists) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text(
//             'No account found for this email address.',
//           ),
//         ),
//       );
//       return;
//     }

//     await Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (_) => ForgotPasswordScreen(
//           loginEmailId: email,
//         ),
//       ),
//     );
//   } catch (_) {
//     if (!mounted) return;

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text(
//           'Unable to verify email. Please try again.',
//         ),
//       ),
//     );
//   }
// }

//-------------------------------------------------------------------------
  // Share Logs
  //-------------------------------------------------------------------------

// Future<void> _shareLogs() async {
//   try {
//     final file = await LoggerService.getLogFile();

//     if (!mounted) return;

//     if (file == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('No logs available'),
//         ),
//       );
//       return;
//     }

//     await Share.shareXFiles(
//       [XFile(file.path)],
//       subject: 'Prescriptor App – Login Logs',
//       text: 'Please find attached logs.',
//     );
//   } catch (_) {
//     if (!mounted) return;

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Unable to share logs'),
//       ),
//     );
//   }
// }





Future<void> _shareLogs() async {
  try {
    final content = await LoggerService.getLogContent();

    if (!mounted) return;

    if (content == null || content.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No logs available'),
        ),
      );
      return;
    }

    final bytes = Uint8List.fromList(
      utf8.encode(content),
    );

    await Share.shareXFiles(
      [
        XFile.fromData(
          bytes,
          mimeType: 'text/plain',
          name: 'app_logs.txt',
        ),
      ],
      subject: 'Prescriptor App – Login Logs',
      text: 'Please find attached logs.',
    );
  } catch (error) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Unable to share logs'),
      ),
    );

    debugPrint('Unable to share logs: $error');
  }
}



  //-------------------------------------------------------------------------
  // ERROR MESSAGE
  //-------------------------------------------------------------------------

  Widget _buildErrorMessage(
    ThemeData theme,
    String message,
  ) {

    return Container(

      padding:
          const EdgeInsets.all(14),

      decoration:
          BoxDecoration(

        color:
            theme.colorScheme.errorContainer,

        borderRadius:
            BorderRadius.circular(12),

        border: Border.all(
          color:
              theme.colorScheme.error
                  .withValues(alpha: 0.30),
        ),
      ),

      child: Row(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Icon(
            Icons.error_outline_rounded,

            color:
                theme.colorScheme.onErrorContainer,
          ),

          const SizedBox(width: 12),

          Expanded(

            child: Text(
              message,

              style: TextStyle(
                color:
                    theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

