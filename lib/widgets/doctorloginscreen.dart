
import 'package:docautomations/commonwidget/loadingOverlay.dart';
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
    try
    {
    setState(() => _loading = true);

    

    final tokens  = await LicenseApiService.loginDoctor(
      _usernameController.text.trim(),
      _passwordController.text.trim(),
    );

//     if (tokens != null) {
//   ScaffoldMessenger.of(context).showSnackBar(
//     SnackBar(content: Text('Tokens: ${tokens.toString()}')),
//   );
// } else {
//   ScaffoldMessenger.of(context).showSnackBar(
//     const SnackBar(content: Text('❌ Login failed — no tokens returned')),
//   );
// }

    // ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('after login doctor call')),);

    // ScaffoldMessenger.of(context).showSnackBar(
    //      SnackBar(content: Text('tokens : ${tokens?["accessToken"]}')),);

    setState(() => _loading = false);

    if (tokens != null) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('inside token not null')),);
      final prefs = await SharedPreferences.getInstance();
      final accessTok = tokens["accessToken"] ;
      final refreshTok = tokens["refreshToken"];
      
      // // await prefs.setString("access_token", tokens["accessToken"] ??"");
      // // await prefs.setString("refresh_token", tokens["refreshToken"]??"");
      // await prefs.setString("access_token", accessTok!);
      // await prefs.setString("refresh_token",refreshTok!);
       
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Login successful ✅')),
      // );
      widget.onLoginSuccess();
    } else {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('inside else')),);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed ❌')),
      );
      setState(() {
        _error = "Invalid username or password";
      });
    }
    }
    catch( e)
    {
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
    body: Stack(
  children: [
    /// 🔹 Make screen scrollable
        SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_error != null)
            Text(_error!, style: const TextStyle(color: Colors.red)),

            // Logo
              // Center(
              //   child: Image.asset(
              //     'assets/icon/app_logo.png',
              //     width: 300,  // adjust size as needed
              //     height: 300,
              //   ),
              // ),
// Logo 
Center(
  child: ClipRRect(
    borderRadius: BorderRadius.circular(50), // adjust radius for more/less rounding
    child: Image.asset(
      'assets/icon/app_logo.png',
      width: 300,
      height: 300,
      fit: BoxFit.cover, // ensures the image fills the rounded box
    ),
  ),
),
              
              const SizedBox(height: 24), // spacing between logo and username


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

    /// Reusable overlay
    LoadingOverlay(isLoading: _loading, message: "Logging in…"),
  ],
),

  );
}


  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(title: const Text("Doctor Login")),
  //     body: Padding(
  //       padding: const EdgeInsets.all(24),
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           if (_error != null)
  //             Text(_error!, style: const TextStyle(color: Colors.red)),
  //           TextField(
  //             controller: _usernameController,
  //             decoration: const InputDecoration(labelText: "Username"),
  //           ),
  //           TextField(
  //             controller: _passwordController,
  //             decoration: const InputDecoration(labelText: "Password"),
  //             obscureText: true,
  //           ),
  //           const SizedBox(height: 24),
  //           // _loading
  //           //     ? const CircularProgressIndicator()
  //           //     :
  //                ElevatedButton(
  //                   onPressed: _login,
  //                   child: const Text("Login"),
  //                 ),
  //           TextButton(
  //             onPressed: widget.onRegisterTap,
  //             child: const Text("New user? Register here"),
  //           )
  //         ],
  //       ),
  //     ),
      
  //   );
  // }
}
