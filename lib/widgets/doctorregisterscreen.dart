// doctorregisterscreen.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:convert';
import 'package:docautomations/widgets/doctorinfo.dart';
//import 'dart:io' as io;
//import 'package:path_provider/path_provider.dart';
import 'package:docautomations/common/common_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  String? _logoPath;
  String? _logoBase64;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {

      final bytes = await picked.readAsBytes(); // works on all platforms
      setState(() => _logoBase64 = base64Encode(bytes));

      // if (kIsWeb) {
      //   final bytes = await picked.readAsBytes();
      //   setState(() => _logoBase64 = base64Encode(bytes));
      // } else {
      //   setState(() => _logoPath = picked.path);
      // }
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final info = DoctorInfo(
        name: _nameController.text,
        specialization: _specController.text,
        clinicName: _clinicNameController.text,
        clinicAddress: _clinicAddressController.text,
        contact: _contactController.text,      
        logoBase64: _logoBase64,
      );

      //final prefs = await SharedPreferences.getInstance();
      //prefs.setString('doctor_info', jsonEncode(info.toJson()));
      print("Registered: ${info.name}");
      print("Registered: ${info.specialization}");
      print("Registered: ${info.clinicName}");
      print("Registered: ${info.clinicAddress}");
      print("Registered: ${info.contact}");
      print("Registered: ${info.logoBase64}");

      final success = await LicenseApiService.registerDoctorOnServer(info);

    if (success) {
      widget.onRegistered(info);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error saving doctor info")),
      );
    }

      //widget.onRegistered(info);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register Doctor")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Doctor Name'), validator: (v) => v!.isEmpty ? 'Required' : null),
              TextFormField(controller: _specController, decoration: const InputDecoration(labelText: 'Specialization'), validator: (v) => v!.isEmpty ? 'Required' : null),
              TextFormField(controller: _clinicNameController, decoration: const InputDecoration(labelText: 'Clinic Name'), validator: (v) => v!.isEmpty ? 'Required' : null),
              TextFormField(controller: _clinicAddressController, decoration: const InputDecoration(labelText: 'Clinic Address'), validator: (v) => v!.isEmpty ? 'Required' : null),
              TextFormField(controller: _contactController, decoration: const InputDecoration(labelText: 'Contact Details'), validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _pickImage, child: const Text("Select Logo")),
              const SizedBox(height: 10),
              displayDoctorImage( _logoBase64),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _submit, child: const Text("Register"))
            ],
          ),
        ),
      ),
    );
  }
}
