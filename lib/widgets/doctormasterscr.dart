
import 'package:docautomations/common/appcolors.dart';
import 'package:docautomations/common/licenseprovider.dart';
// 🔹 import reusable loader
import 'package:docautomations/commonwidget/loadingOverlay.dart';
import 'package:docautomations/commonwidget/trialbanner.dart';
import 'package:docautomations/validationhandling/validation.dart';
import 'package:docautomations/validationhandling/validator.dart';
import 'package:docautomations/widgets/doctorwelcomescreen.dart';
import 'package:docautomations/widgets/menubar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

import 'package:docautomations/widgets/doctorinfo.dart';
import 'package:docautomations/common/common_widgets.dart';
import 'package:docautomations/services/license_api_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';




class DoctorMasterScr extends StatefulWidget {
  final DoctorInfo doctorInfo; // doctor info to edit
  final void Function(DoctorInfo) onUpdated;

  const DoctorMasterScr({
    super.key,
    required this.doctorInfo,
    required this.onUpdated,
  });

  @override
  State<DoctorMasterScr> createState() => _DoctorMasterScrState();
}

class _DoctorMasterScrState extends State<DoctorMasterScr> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _specController;
  late TextEditingController _clinicNameController;
  late TextEditingController _clinicAddressController;
  late TextEditingController _contactController;
  late TextEditingController _loginEmailController;

  final _nameKey = GlobalKey<FormFieldState>();
  final _specKey = GlobalKey<FormFieldState>();
  final _clinicNameKey = GlobalKey<FormFieldState>();
  final _clinicAddressKey = GlobalKey<FormFieldState>();
  final _contactKey = GlobalKey<FormFieldState>();
  final _emailKey = GlobalKey<FormFieldState>();


  String? _logoBase64;
  bool _printLetterhead = true;
  bool _isLoading = false; // ✅ loader flag
  late String _originalEmail;
  String? _emailServerError;


  @override
  void initState() {
    super.initState();
    _seedControllers(widget.doctorInfo);
  }

  @override
  void didUpdateWidget(covariant DoctorMasterScr oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.doctorInfo != widget.doctorInfo) {
      _seedControllers(widget.doctorInfo);
      setState(() {});
    }
  }

  void _seedControllers(DoctorInfo d) {
    _nameController = TextEditingController(text: d.name);
    _specController = TextEditingController(text: d.specialization);
    _clinicNameController = TextEditingController(text: d.clinicName);
    _clinicAddressController = TextEditingController(text: d.clinicAddress);
    _contactController = TextEditingController(text: d.contact);
    _loginEmailController = TextEditingController(text: d.loginEmail);
    _originalEmail = d.loginEmail.trim().toLowerCase();
    _logoBase64 = d.logoBase64;
    _printLetterhead = d.printLetterhead;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _specController.dispose();
    _clinicNameController.dispose();
    _clinicAddressController.dispose();
    _contactController.dispose();
    _loginEmailController.dispose();
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



  // Future<void> _submit() async {

  //   final isValid = _formKey.currentState!.validate();

  // if (!isValid) {
  //   await _scrollToFirstError();
  //   return;
  // }
  // else  {
  //     setState(() => _isLoading = true); // ✅ start loader

  //     final updatedInfo = DoctorInfo(
  //       name: _nameController.text,
  //       specialization: _specController.text,
  //       clinicName: _clinicNameController.text,
  //       clinicAddress: _clinicAddressController.text,
  //       contact: _contactController.text,
  //       loginEmail: _loginEmailController.text.trim().toLowerCase(),
  //       password: "", // not needed in edit
  //       logoBase64: _logoBase64,
  //       printLetterhead: _printLetterhead,
  //       prescriptionCount:widget.doctorInfo.prescriptionCount,
  //       licensedOnDate:widget.doctorInfo.licensedOnDate,
  //       nextRenewalDate:widget.doctorInfo.nextRenewalDate,
  //       firstTimeRegistrationDate:widget.doctorInfo.firstTimeRegistrationDate,
        
  //     );

  //     final success = await LicenseApiService.updateDoctorOnServer(updatedInfo);

  //     setState(() => _isLoading = false); // ✅ stop loader

  //     if (success) {
  //       final prefs = await SharedPreferences.getInstance();
  // await prefs.setString("doctor_profile", jsonEncode(updatedInfo.toJson())); 

  //       widget.onUpdated(updatedInfo);

  //      await _showSuccessPopup();  // 👈 show dialog first

      

  //       // ScaffoldMessenger.of(context).showSnackBar(
  //       //   const SnackBar(content: Text("Doctor info updated successfully")),
  //       // );
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text("Error updating doctor info")),
  //       );
  //     }
  //   }
  // }


Future<void> _submit() async {
// Clear old server error before validating
 _emailServerError = null;
    final isValid = _formKey.currentState!.validate();

  if (!isValid) {
    await _scrollToFirstError();
    return;
  }
  final newEmail =
      _loginEmailController.text.trim().toLowerCase();

  // 🔐 Check only if email changed
  if (newEmail != _originalEmail) {
    setState(() => _isLoading = true);

    final exists =
        await LicenseApiService.isEmailAlreadyRegistered(newEmail);

    setState(() => _isLoading = false);

    if (exists) {
      setState(() {
        _emailServerError = "Email already registered";
      });
// Re-run validation so ServerEmailValidation shows error
      _emailKey.currentState?.validate();
      await _scrollToFirstError();
      return;
    }
  }
   // ✅ Continue with normal update
      setState(() => _isLoading = true); // ✅ start loader

      final updatedInfo = DoctorInfo(
        name: _nameController.text,
        specialization: _specController.text,
        clinicName: _clinicNameController.text,
        clinicAddress: _clinicAddressController.text,
        contact: _contactController.text,
        loginEmail: _loginEmailController.text.trim().toLowerCase(),
        password: "", // not needed in edit
        logoBase64: _logoBase64,
        printLetterhead: _printLetterhead,
        prescriptionCount:widget.doctorInfo.prescriptionCount,
        licensedOnDate:widget.doctorInfo.licensedOnDate,
        nextRenewalDate:widget.doctorInfo.nextRenewalDate,
        firstTimeRegistrationDate:widget.doctorInfo.firstTimeRegistrationDate,
        
      );

      final success = await LicenseApiService.updateDoctorOnServer(updatedInfo);

      setState(() => _isLoading = false); // ✅ stop loader

      if (success) {
        final prefs = await SharedPreferences.getInstance();
  await prefs.setString("doctor_profile", jsonEncode(updatedInfo.toJson())); 

        widget.onUpdated(updatedInfo);

       await _showSuccessPopup();  // 👈 show dialog first

      

        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text("Doctor info updated successfully")),
        // );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error updating doctor info")),
        );
      }
    
  }

  @override
Widget build(BuildContext context) {
  return Consumer<LicenseProvider>(
    builder: (context, license, child) {
      return Scaffold(
        backgroundColor: Colors.white,

        body: Stack(
          children: [
            // ===========================
            // MAIN SCROLLABLE PAGE
            // ===========================
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  // ─────────────────────────
                  // Trial Banner (only when needed)
                  // ─────────────────────────
                  if (!license.isSubscribed && license.isTrialActive)
                    TrialBanner(),

                  const SizedBox(height: 10),

                  // ─────────────────────────
                  // FORM CARD
                  // ─────────────────────────
                  Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.25),
                          blurRadius: 18,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),

                    child: _buildFormContent(),
                  ),
                ],
              ),
            ),

            // ===========================
            // FULL-SCREEN LOADING OVERLAY
            // ===========================
            if (_isLoading)
              Positioned.fill(
                child: LoadingOverlay(
                  isLoading: true,
                  message: "Updating…",
                ),
              ),
          ],
        ),
      );
    },
  );
}


Widget _buildFormContent() {
  return Form(
    key: _formKey,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [

        TextFormField(
          controller: _nameController,
          key: _nameKey,
          maxLength: 50,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          decoration:  InputDecoration(labelText: 'Doctor Name', 
                               prefix: Padding(
                                padding: EdgeInsets.only(right: 6),
                                child: Text(
                                    "Dr.",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
    ),
          ),
          validator: (v) => v!.isEmpty ? 'Required' : null,
        ),

        TextFormField(
          controller: _specController,
          key: _specKey,
          maxLength: 100,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          decoration: const InputDecoration(labelText: 'Specialization'),
          validator: (v) => v!.isEmpty ? 'Required' : null,
        ),

        TextFormField(
          controller: _clinicNameController,
          key: _clinicNameKey,
          maxLength: 50,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          decoration: const InputDecoration(labelText: 'Clinic Name'),
          validator: (v) => v!.isEmpty ? 'Required' : null,
        ),

        TextFormField(
          controller: _clinicAddressController,
          key: _clinicAddressKey,
          maxLength: 200,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          decoration: const InputDecoration(labelText: 'Clinic Address'),
          validator: (v) => v!.isEmpty ? 'Required' : null,
        ),

        TextFormField(
          controller: _contactController,
          key: _contactKey,
          maxLength: 10,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          decoration: const InputDecoration(labelText: 'Contact Details'),
          validator: Validator.apply(
            context,
            const [RequiredValidation(), NumericValidation()],
          ),
        ),

        TextFormField(
          controller: _loginEmailController,
          onChanged: (_) {
          if (_emailServerError != null) {
              setState(() => _emailServerError = null);
               }
            },
          key: _emailKey,
          maxLength: 50,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          decoration: const InputDecoration(labelText: 'Login Email'),
          validator: Validator.apply(
            context,
             [const RequiredValidation(),  const EmailValidation(), 
             ServerValidation(() => _emailServerError)],
          ),
        ),

        const SizedBox(height: 12),

        SwitchListTile(
          title: const Text("Print on Letterhead"),
          value: _printLetterhead,
          onChanged: (val) => setState(() => _printLetterhead = val),
        ),

        ElevatedButton(
          onPressed: _pickImage,
          child: const Text("Select Logo"),
        ),

        const SizedBox(height: 10),

        displayDoctorImage(_logoBase64),

        const SizedBox(height: 20),

        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: const Text("Update Info"),
        ),
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

Future<void> _showSuccessPopup() async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        "Success",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: const Text("Profile updated successfully!"),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // close popup ONLY

            final menuState = Menubar.of(context);

            if (menuState != null) {
              menuState.changeScreen(const DoctorWelcomeScreen());
            }
          },
          child: const Text("OK"),
        ),
      ],
    ),
  );
}






}

