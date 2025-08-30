import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

import 'package:docautomations/widgets/doctorinfo.dart';
import 'package:docautomations/common/common_widgets.dart';
import 'package:docautomations/services/license_api_service.dart';

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

  String? _logoBase64;

  @override
  void initState() {
    super.initState();
    // Pre-fill controllers with existing doctor info
    _seedControllers(widget.doctorInfo);
    
  }

   @override
  void didUpdateWidget(covariant DoctorMasterScr oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If parent passes a different doctor, refresh the form
    if (oldWidget.doctorInfo != widget.doctorInfo) {
      _seedControllers(widget.doctorInfo);
      setState(() {}); // refresh preview
    }
  }

void _seedControllers(DoctorInfo d) {

  _nameController = TextEditingController(text:d.name);
    _specController = TextEditingController(text: d.specialization);
    _clinicNameController = TextEditingController(text: d.clinicName);
    _clinicAddressController = TextEditingController(text: d.clinicAddress);
    _contactController = TextEditingController(text: d.contact);
    _loginEmailController = TextEditingController(text: d.loginEmail);
    _logoBase64 = d.logoBase64;
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
      final bytes = await picked.readAsBytes();
      setState(() => _logoBase64 = base64Encode(bytes));
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final updatedInfo = DoctorInfo(
        name: _nameController.text,
        specialization: _specController.text,
        clinicName: _clinicNameController.text,
        clinicAddress: _clinicAddressController.text,
        contact: _contactController.text,
        loginEmail: _loginEmailController.text,
        password: "", // not needed in edit
        logoBase64: _logoBase64,
      );

      final success = await LicenseApiService.updateDoctorOnServer(updatedInfo);

      if (success) {
        widget.onUpdated(updatedInfo);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Doctor info updated successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error updating doctor info")),
        );
      }
    }
  }

  Widget _logoPreview() {
    if (_logoBase64 == null || _logoBase64!.isEmpty) {
      return const Text("No logo selected");
    }
    return Image.memory(
      base64Decode(_logoBase64!),
      height: 96,
      fit: BoxFit.contain,
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Doctor Master")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Doctor Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _specController,
                decoration: const InputDecoration(labelText: 'Specialization'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _clinicNameController,
                decoration: const InputDecoration(labelText: 'Clinic Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _clinicAddressController,
                decoration: const InputDecoration(labelText: 'Clinic Address'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _contactController,
                decoration: const InputDecoration(labelText: 'Contact Details'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _loginEmailController,
                decoration: const InputDecoration(labelText: 'Login Email'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _pickImage, child: const Text("Select Logo")),
              const SizedBox(height: 10),
              displayDoctorImage(_logoBase64),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _submit, child: const Text("Update Info")),
            ],
          ),
        ),
      ),
    );
  }
}
