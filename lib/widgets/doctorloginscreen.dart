// import 'package:docautomations/commonwidget/loadingOverlay.dart';
// import 'package:docautomations/services/auth_service.dart';
// import 'package:docautomations/services/license_api_service.dart';
// import 'package:docautomations/services/logger_service.dart';
// import 'package:docautomations/validationhandling/validator.dart';
// import 'package:docautomations/widgets/forgot_password_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:docautomations/validationhandling/validation.dart';

// class DoctorLoginScreen extends StatefulWidget {
//   final VoidCallback onLoginSuccess;
//   final VoidCallback onRegisterTap;

//   const DoctorLoginScreen({
//     super.key,
//     required this.onLoginSuccess,
//     required this.onRegisterTap,
//   });

//   @override
//   State<DoctorLoginScreen> createState() =>
//       _DoctorLoginScreenState();
// }

// class _DoctorLoginScreenState
//     extends State<DoctorLoginScreen> {
//   final TextEditingController
//       _usernameController =
//       TextEditingController();

//   final TextEditingController
//       _passwordController =
//       TextEditingController();

//   bool _loading = false;
//   bool _showPassword = false;

//   String? _usernameError;
//   String? _passwordError;

//   // ==========================
//   // VALIDATION
//   // ==========================
//   bool _validateFields() {
//     final emailValidator =
//         Validator.apply<String>(
//       context,
//       const [
//         RequiredValidation(),
//         EmailValidation(),
//       ],
//     );

//     final passwordValidator =
//         Validator.apply<String>(
//       context,
//       const [
//         RequiredValidation(),
//       ],
//     );

//     final username =
//         _usernameController.text.trim();

//     final password =
//         _passwordController.text.trim();

//     final usernameError =
//         emailValidator(username);

//     final passwordError =
//         passwordValidator(password);

//     setState(() {
//       _usernameError = usernameError;
//       _passwordError = passwordError;
//     });

//     return usernameError == null &&
//         passwordError == null;
//   }

//   // ==========================
//   // LOGIN
//   // ==========================
//   Future<void> _login() async {
//     if (!_validateFields()) return;

//     setState(() => _loading = true);

//     try {
//       final tokens =
//           await LicenseApiService
//               .loginDoctor(
//         _usernameController.text
//             .trim(),
//         _passwordController.text
//             .trim(),
//       );

//       if (!mounted) return;

//       setState(() => _loading = false);

//       if (tokens != null) {
//         // ✅ Use AuthService
//         await AuthService.saveTokens(
//           accessToken:
//               tokens["accessToken"] ??
//                   "",
//           refreshToken:
//               tokens["refreshToken"] ??
//                   "",
//         );

//         widget.onLoginSuccess();
//       } else {
//         setState(() {
//           _passwordError =
//               "Invalid username or password";
//         });
//       }
//     } catch (e) {
//       if (!mounted) return;

//       setState(() => _loading = false);

//       setState(() {
//         _passwordError =
//             "Login failed";
//       });
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     _checkExistingLogin();
//   }

//   // ==========================
//   // AUTO LOGIN
//   // ==========================
//   Future<void>
//       _checkExistingLogin() async {
//     final token =
//         await AuthService.getToken();

//     final refreshToken =
//         await AuthService
//             .getRefreshToken();

//     if (token != null) {
//       final valid =
//           await LicenseApiService
//               .verifyToken();

//       if (valid) {
//         widget.onLoginSuccess();
//         return;
//       }

//       // token invalid -> refresh
//       if (refreshToken != null) {
//         final refreshed =
//             await AuthService
//                 .refreshAccessToken();

//         if (refreshed) {
//           widget.onLoginSuccess();
//           return;
//         }
//       }

//       await AuthService.logout();
//     }
//   }

//   // ==========================
//   // SHARE LOGS
//   // ==========================
//   Future<void> _shareLogs() async {
//     try {
//       final file =
//           await LoggerService
//               .getLogFile();

//       if (file == null) {
//         ScaffoldMessenger.of(context)
//             .showSnackBar(
//           const SnackBar(
//             content: Text(
//               "No logs available",
//             ),
//           ),
//         );
//         return;
//       }

//       await Share.shareXFiles(
//         [XFile(file.path)],
//         subject:
//             "Prescriptor App – Login Logs",
//         text:
//             "Please find attached logs.",
//       );
//     } catch (_) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(
//         const SnackBar(
//           content:
//               Text("Unable to share logs"),
//         ),
//       );
//     }
//   }

//   // ==========================
//   // UI
//   // ==========================
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title:
//             const Text("Doctor Login"),
//       ),
//       body: Stack(
//         children: [
//           SingleChildScrollView(
//             padding:
//                 const EdgeInsets.all(
//                     24),
//             child: Column(
//               children: [
//                 const SizedBox(
//                     height: 24),

//                 Center(
//                   child: ClipRRect(
//                     borderRadius:
//                         BorderRadius
//                             .circular(
//                                 50),
//                     child:
//                         Image.asset(
//                       'assets/icon/app_logo.png',
//                       width: 200,
//                       height: 200,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),

//                 const SizedBox(
//                     height: 24),

//                 TextField(
//                   controller:
//                       _usernameController,
//                   decoration:
//                       InputDecoration(
//                     labelText:
//                         "User Email",
//                     border:
//                         const OutlineInputBorder(),
//                     errorText:
//                         _usernameError,
//                   ),
//                 ),

//                 const SizedBox(
//                     height: 16),

//                 TextField(
//                   controller:
//                       _passwordController,
//                   obscureText:
//                       !_showPassword,
//                   decoration:
//                       InputDecoration(
//                     labelText:
//                         "Password",
//                     border:
//                         const OutlineInputBorder(),
//                     errorText:
//                         _passwordError,
//                     suffixIcon:
//                         IconButton(
//                       icon: Icon(
//                         _showPassword
//                             ? Icons
//                                 .visibility
//                             : Icons
//                                 .visibility_off,
//                       ),
//                       onPressed: () {
//                         setState(() {
//                           _showPassword =
//                               !_showPassword;
//                         });
//                       },
//                     ),
//                   ),
//                 ),

//                 const SizedBox(
//                     height: 24),

//                 ElevatedButton(
//                   onPressed: _login,
//                   child: const Text(
//                       "Login"),
//                 ),

//                 const SizedBox(
//                     height: 10),

//                 TextButton(
//                   onPressed: () async {
//                     final emailValidator = Validator.apply<String>(
//                       context,
//                       const [RequiredValidation(), EmailValidation()],
//                     );
//                     final email = _usernameController.text.trim();
//                     final error = emailValidator(email);

//                     if (error != null) {
//                       setState(() {
//                         _usernameError = error;
//                       });
//                       return;
//                     }
//                     setState(() => _loading = true);
//                     final exists = await LicenseApiService.checkEmailExists(email);

//                     if (!mounted) return;

//                     setState(() => _loading = false);

//                     if (!exists) {
//                       setState(() {
//                         _usernameError = "Email is not registered";
//                       });
//                       return;
//                     }
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) =>
//                             ForgotPasswordScreen(
//                           loginEmailId:
//                               email,
//                         ),
//                       ),
//                     );
//                   },
//                   child: const Text(
//                     "Forgot Password?",
//                   ),
//                 ),

//                 TextButton.icon(
//                   icon: const Icon(Icons
//                       .email_outlined),
//                   label: const Text(
//                     "Having trouble logging in? Share logs with support",
//                   ),
//                   onPressed:
//                       _shareLogs,
//                 ),

//                 TextButton(
//                   onPressed: widget
//                       .onRegisterTap,
//                   child: const Text(
//                     "New user? Register here",
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           LoadingOverlay(
//             isLoading: _loading,
//             message:
//                 "Logging in…",
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:docautomations/commonwidget/loadingOverlay.dart';
import 'package:docautomations/services/auth_service.dart';
import 'package:docautomations/services/license_api_service.dart';
import 'package:docautomations/services/logger_service.dart';
import 'package:docautomations/validationhandling/validator.dart';
import 'package:docautomations/widgets/forgot_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:docautomations/validationhandling/validation.dart';
import 'package:url_launcher/url_launcher.dart';

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


Future<void> _openDemoVideo() async {
  // Replace with your actual YouTube video ID
  const String videoId = "https://youtu.be/ZsmBEu_lzKw";

  final Uri youtubeApp =
      Uri.parse("vnd.youtube://$videoId");

  final Uri youtubeWeb =
      Uri.parse("https://youtu.be/$videoId");

  if (await canLaunchUrl(youtubeApp)) {
    await launchUrl(
      youtubeApp,
      mode: LaunchMode.externalApplication,
    );
  } else {
    await launchUrl(
      youtubeWeb,
      mode: LaunchMode.externalApplication,
    );
  }
}

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
                    height: 10),

                Center(
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius
                            .circular(
                                50),
                    child:
                        Image.asset(
                      'assets/icon/app_logo.png',
                      width:150,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(
                    height: 24),

                    Text(
  "Already registered? Login below",
  style: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  ),
),
 const SizedBox(
                    height: 10),

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

                const SizedBox(
                    height: 5),

                ElevatedButton(
                  onPressed: _login,
                  child: const Text(
                      "Login"),
                ),

               

                const SizedBox(height: 10),

// OutlinedButton.icon(
//   onPressed: widget.onRegisterTap,
//   icon: const Icon(Icons.person_add),
//   label: const Text(
//     "New Doctor? Register Here",
//     style: TextStyle(
//       fontWeight: FontWeight.bold,
//     ),
//   ),
// ),

// SizedBox(
//   width: double.infinity,
//   child: OutlinedButton.icon(
//     onPressed: widget.onRegisterTap,
//     icon: const Icon(Icons.person_add_alt_1),
//     label: const Text(
//       "New Doctor? Register Here",
//     ),
//     style: OutlinedButton.styleFrom(
//       backgroundColor:
//           Theme.of(context)
//               .colorScheme
//               .primary
//               .withOpacity(0.06),
//       foregroundColor:
//           Theme.of(context)
//               .colorScheme
//               .primary,
//       side: BorderSide(
//         color: Theme.of(context)
//             .colorScheme
//             .primary,
//       ),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(14),
//       ),
//       padding: const EdgeInsets.symmetric(
//         vertical: 14,
//       ),
//     ),
//   ),
// ),



//eye cachy second ver 
SizedBox(
  width: double.infinity,
  height: 56,
  child: ElevatedButton.icon(
    onPressed: widget.onRegisterTap,
    icon: const Icon(Icons.person_add_alt_1),
    label: const Text(
      "New Doctor? Register Here",
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
    style: ElevatedButton.styleFrom(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 14,
      ),
    ),
  ),
),
//first version ..
// SizedBox(
//   width: double.infinity,
//   height: 52,
//   child: OutlinedButton.icon(
//     onPressed: widget.onRegisterTap,
//     icon: const Icon(Icons.person_add_alt_1),
//     label: const Text(
//       "New Doctor? Register Here",
//       style: TextStyle(
//         fontSize: 16,
//         fontWeight: FontWeight.w600,
//       ),
//     ),
//     style: OutlinedButton.styleFrom(
//       foregroundColor: Theme.of(context).colorScheme.primary,
//       side: BorderSide(
//         color: Theme.of(context).colorScheme.primary,
//         width: 1.5,
//       ),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//     ),
//   ),
// ),

const SizedBox(height: 12),

Card(
  color: Colors.red.shade50,
  child: ListTile(
    leading: const Icon(
      Icons.play_circle_fill,
      color: Colors.red,
      size: 36,
    ),
    title: const Text(
      "Watch App Demo",
      style: TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),
    subtitle: const Text(
      "See how to create prescriptions in just 2 minutes",
    ),
    trailing: const Icon(Icons.arrow_forward_ios),
    onTap: _openDemoVideo,
  ),
),
const SizedBox(height: 10),

Card(
  color:  Colors.blue.shade50,
  child: ListTile(
    leading: const Icon(
      Icons.support_agent,
      color:  Color.fromARGB(255, 30, 124, 218),
    ),
    title: const Text(
      "Login Problem?",
      style: TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),
    subtitle: const Text(
      "Tap here to send logs to support",
    ),
    trailing: const Icon(Icons.arrow_forward_ios),
    onTap: _shareLogs,
  ),
),

                // TextButton.icon(
                //   icon: const Icon(Icons
                //       .email_outlined),
                //   label: const Text(
                //     "Having trouble logging in? Share logs with support",
                //   ),
                //   onPressed:
                //       _shareLogs,
                // ),

                // TextButton(
                //   onPressed: widget
                //       .onRegisterTap,
                //   child: const Text(
                //     "New user? Register here",
                //   ),
                // ),
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