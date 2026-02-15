
import 'package:docautomations/common/appcolors.dart';
// 🔹 import the reusable overlay
import 'package:docautomations/commonwidget/loadingOverlay.dart';
import 'package:docautomations/validationhandling/validation.dart';
import 'package:docautomations/validationhandling/validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

import 'package:docautomations/widgets/doctorinfo.dart';
import 'package:docautomations/common/common_widgets.dart';
import 'package:docautomations/services/license_api_service.dart';




class DoctorRegisterScreen extends StatefulWidget {
  final void Function(DoctorInfo) onRegistered;
  const DoctorRegisterScreen({super.key, required this.onRegistered});

  @override
  State<DoctorRegisterScreen> createState() => _DoctorRegisterScreenState();
}

class _DoctorRegisterScreenState extends State<DoctorRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _specController = TextEditingController();
  final _clinicNameController = TextEditingController();
  final _clinicAddressController = TextEditingController();
  final _contactController = TextEditingController();
  final _loginEmailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _confirmPasswordController = TextEditingController();



bool _showPassword = false;
bool _showConfirmPassword = false;

  final _nameKey = GlobalKey<FormFieldState>();
final _specKey = GlobalKey<FormFieldState>();
final _clinicNameKey = GlobalKey<FormFieldState>();
final _clinicAddressKey = GlobalKey<FormFieldState>();
final _contactKey = GlobalKey<FormFieldState>();
final _emailKey = GlobalKey<FormFieldState>();
final _passwordKey = GlobalKey<FormFieldState>();
final _confirmPasswordKey = GlobalKey<FormFieldState>();

String? _emailServerError;


@override
  void initState() {
    super.initState();
    
    _loginEmailController.addListener(() {
        if (_emailServerError != null) {
          setState(() => _emailServerError = null);
        }
      });

      _passwordController.addListener(() {
  if (_confirmPasswordKey.currentState != null) {
    _confirmPasswordKey.currentState!.validate();
  }
});


  }


  String? _logoBase64;
  bool _isLoading = false;

  

//   Future<void> _pickImage() async {
//   final picked = await ImagePicker().pickImage(source: ImageSource.gallery);

//   if (picked != null) {
//     // -------------------------------
//     // 1. EXTENSION VALIDATION
//     // -------------------------------
//     final extension = picked.name.split('.').last.toLowerCase();

//     const allowedExtensions = ['png', 'jpg', 'jpeg', 'webp'];

//     if (!allowedExtensions.contains(extension)) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Only PNG, JPG, JPEG, WEBP formats are allowed"),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     // -------------------------------
//     // 2. SIZE VALIDATION (≤ 200 KB)
//     // -------------------------------
//     final sizeInBytes = await picked.length();
//     const maxSize = 200 * 1024; // 200 KB

//     if (sizeInBytes > maxSize) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Logo must be less than 200 KB"),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     // -------------------------------
//     // 3. Convert to Base64
//     // -------------------------------
//     final bytes = await picked.readAsBytes();
//     setState(() {
//       _logoBase64 = base64Encode(bytes);
//     });
//   }
// }
@override
void dispose() {
  _passwordController.dispose();
  _confirmPasswordController.dispose();
  super.dispose();
}


Future<void> _pickImage() async {
  final picked = await ImagePicker().pickImage(source: ImageSource.gallery);

  if (picked != null) {
    // -------------------------------
    // 1. EXTENSION VALIDATION
    // -------------------------------
    final extension = picked.name.split('.').last.toLowerCase();

    const allowedExtensions = ['png', 'jpg', 'jpeg', 'webp'];

    if (!allowedExtensions.contains(extension)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Only PNG, JPG, JPEG, WEBP formats are allowed"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // -------------------------------
    // 2. SIZE VALIDATION (≤ 200 KB)
    // -------------------------------
    final sizeInBytes = await picked.length();
    const maxSize = 200 * 1024; // 200 KB

    if (sizeInBytes > maxSize) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Logo must be less than 200 KB"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // -------------------------------
    // 3. Convert to Base64 WITH MIME PREFIX
    // -------------------------------
    final bytes = await picked.readAsBytes();
    final rawBase64 = base64Encode(bytes);

    // Detect image type -> build correct prefix
    String mimeType;
    if (extension == "png") {
      mimeType = "image/png";
    } else if (extension == "webp") {
      mimeType = "image/webp";
    } else {
      mimeType = "image/jpeg"; // default for jpg / jpeg
    }

    // FINAL Base64 string expected by backend
    final fullBase64 = "data:$mimeType;base64,$rawBase64";

    setState(() {
      _logoBase64 = fullBase64;
    });
  }
}



  Future<void> _submit() async {
    final isValid = _formKey.currentState!.validate();
     if (!isValid) {
    await _scrollToFirstError();
    return;
      }
    else {
      
     
      setState(() => _isLoading = true);

      final info = DoctorInfo(
        name: _nameController.text,
        specialization: _specController.text,
        clinicName: _clinicNameController.text,
        clinicAddress: _clinicAddressController.text,
        contact: _contactController.text,
        loginEmail: _loginEmailController.text.trim().toLowerCase() ,
        password: _passwordController.text,
        logoBase64: _logoBase64,

        // extra defaults
        printLetterhead: true,
        prescriptionCount: 0,
        licensedOnDate: null,
        firstTimeRegistrationDate: DateTime.now(),
        nextRenewalDate: null,
      );

      final result = await LicenseApiService.registerDoctorOnServer(info);

      setState(() => _isLoading = false);

      if (result["success"]) {
        widget.onRegistered(info);
      } else {
        // ScaffoldMessenger.of(context).showSnackBar(
        //    SnackBar(content: Text(result["message"])),
        //);
        // Read backend response message
        final message = LicenseApiService.lastErrorMessage;

          if (message == "Email already registered") {
            setState(() {
              _emailServerError = message; // 👈 show under textbox
            });
            // Scroll to email field
              await Scrollable.ensureVisible(
                _emailKey.currentContext!,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                alignment: 0.3,
              );
              return; // ⛔ stop here
      }
    setState(() {
          _emailServerError = message; // fallback error
        });
       return;
  //     //TODO:
  //     //If email is taken → scroll to email field
  // if (result["message"].toString().contains("Email")) {
  //   await Scrollable.ensureVisible(
  //     _emailKey.currentContext!,
  //     duration: const Duration(milliseconds: 500),
  //   );
  // }
    }
  }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register Doctor")),
      body: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: Offset.zero,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _nameController,
                          key: _nameKey,
                           maxLength: 50,
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          decoration:
                              const InputDecoration(labelText: 'Doctor Name',
                               prefix: Padding(
                                padding: EdgeInsets.only(right: 6),
                                child: Text(
                                    "Dr.",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
    ),),
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                        TextFormField(
                          controller: _specController,
                           key: _specKey,
                          maxLength: 100,
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          decoration:
                              const InputDecoration(labelText: 'Specialization'),
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                        TextFormField(
                          controller: _clinicNameController,
                          key: _clinicNameKey,
                           maxLength: 50,
                            maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          decoration:
                              const InputDecoration(labelText: 'Clinic Name'),
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                        TextFormField(
                          controller: _clinicAddressController,
                          key: _clinicAddressKey,
                          maxLength: 200,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          decoration:
                              const InputDecoration(labelText: 'Clinic Address'),
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                        TextFormField(
                          controller: _contactController,
                          key: _contactKey,
                           maxLength: 10,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          decoration:
                              const InputDecoration(labelText: 'Contact Details'),
                          validator:  Validator.apply(context, const [RequiredValidation(),NumericValidation()]),
                        ),
                        TextFormField(
                          controller: _loginEmailController,
                          key: _emailKey,
                          maxLength: 50,
                          
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          decoration:
                               InputDecoration(labelText: 'Login Email' ,errorText: _emailServerError,),
                          validator:  Validator.apply(context, const [RequiredValidation(),EmailValidation()]),
                        ),
                        // TextFormField(
                        //   controller: _passwordController,
                        //   key: _passwordKey,
                        //   decoration:
                        //       const InputDecoration(labelText: 'Password'),
                        //   validator: Validator.apply(context, const [RequiredValidation(),PasswordValidation(number: true,upperCase: true,
                        //   specialChar: true)]),
                        //   obscureText: true,
                        // ),
                        TextFormField(
  controller: _passwordController,
  key: _passwordKey,
  obscureText: !_showPassword,
  decoration: InputDecoration(
    labelText: 'Password',
    suffixIcon: IconButton(
      icon: Icon(
        _showPassword ? Icons.visibility : Icons.visibility_off,
      ),
      onPressed: () {
        setState(() => _showPassword = !_showPassword);
      },
    ),
  ),
  validator: Validator.apply(context, const [
    RequiredValidation(),
    PasswordValidation(number: true, upperCase: true, specialChar: true),
  ]),
),
TextFormField(
  controller: _confirmPasswordController,
  key: _confirmPasswordKey,
  obscureText: !_showConfirmPassword,
  decoration: InputDecoration(
    labelText: 'Confirm Password',
    suffixIcon: IconButton(
      icon: Icon(
        _showConfirmPassword ? Icons.visibility : Icons.visibility_off,
      ),
      onPressed: () {
        setState(() => _showConfirmPassword = !_showConfirmPassword);
      },
    ),
  ),
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Required';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  },
),


                        const SizedBox(height: 12),
                        ElevatedButton(
                            onPressed: _pickImage,
                            child: const Text("Select Logo")),
                        const SizedBox(height: 10),
                        displayDoctorImage(_logoBase64),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          child: const Text("Register"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 🔹 use the reusable loading overlay
          LoadingOverlay(isLoading: _isLoading, message: "Registering…"),
        ],
      ),
    );
  }

  Future<void> _scrollToFirstError() async {
  await Future.delayed(const Duration(milliseconds: 50));

  final fields = [
    _nameKey,
    _specKey,
    _clinicNameKey,
    _clinicAddressKey,
    _contactKey,
    _emailKey,
    _passwordKey,
    _confirmPasswordKey,
  ];

  for (final key in fields) {
    final state = key.currentState;
    final context = key.currentContext;

    if (state != null && state.hasError && context != null) {
      await Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.3,
      );
      return;
    }
  }
}

}
