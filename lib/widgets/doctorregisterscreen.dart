
import 'package:docautomations/common/appcolors.dart';
// 🔹 import the reusable overlay
import 'package:docautomations/commonwidget/loadingOverlay.dart';
import 'package:flutter/material.dart';
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
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final info = DoctorInfo(
        name: _nameController.text,
        specialization: _specController.text,
        clinicName: _clinicNameController.text,
        clinicAddress: _clinicAddressController.text,
        contact: _contactController.text,
        loginEmail: _loginEmailController.text,
        password: _passwordController.text,
        logoBase64: _logoBase64,

        // extra defaults
        printLetterhead: true,
        prescriptionCount: 0,
        licensedOnDate: null,
        firstTimeRegistrationDate: DateTime.now(),
        nextRenewalDate: null,
      );

      final success = await LicenseApiService.registerDoctorOnServer(info);

      setState(() => _isLoading = false);

      if (success) {
        widget.onRegistered(info);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error saving doctor info")),
        );
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
                          decoration:
                              const InputDecoration(labelText: 'Doctor Name'),
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                        TextFormField(
                          controller: _specController,
                          decoration:
                              const InputDecoration(labelText: 'Specialization'),
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                        TextFormField(
                          controller: _clinicNameController,
                          decoration:
                              const InputDecoration(labelText: 'Clinic Name'),
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                        TextFormField(
                          controller: _clinicAddressController,
                          decoration:
                              const InputDecoration(labelText: 'Clinic Address'),
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                        TextFormField(
                          controller: _contactController,
                          decoration:
                              const InputDecoration(labelText: 'Contact Details'),
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                        TextFormField(
                          controller: _loginEmailController,
                          decoration:
                              const InputDecoration(labelText: 'Login Email'),
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                        TextFormField(
                          controller: _passwordController,
                          decoration:
                              const InputDecoration(labelText: 'Password'),
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                          obscureText: true,
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
}
