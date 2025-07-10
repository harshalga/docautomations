import 'package:docautomations/widgets/menubar.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:docautomations/widgets/doctorinfo.dart';
import 'package:docautomations/common/common_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DoctorWelcomeScreen extends StatelessWidget {
  const DoctorWelcomeScreen({super.key});

  Future<DoctorInfo> _loadInfo() async {
    print("Inside welcome screen load info");

    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('doctor_info');

    if (jsonStr != null && jsonStr.isNotEmpty) {
      print("Inside jsonstr exist");
      try {
        final decoded = jsonDecode(jsonStr);
        print("Decoded JSON: $decoded");
        final info = DoctorInfo.fromJson(decoded);
        print("DoctorInfo loaded: ${info.name}");
        return info;
      } catch (e) {
        print("⚠️ Error parsing doctor_info: $e");
        rethrow;
      }
    } else {
      print("Fallback: no doctor_info found, returning default");
      return DoctorInfo(
        name: 'Dr. Web',
        specialization: 'General Physician',
        clinicName: 'Web Clinic',
        clinicAddress: '123 Internet Ave',
        contact: 'web@example.com',
        logoBase64: '',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Inside welcome screen build");
    return FutureBuilder<DoctorInfo>(
      future: _loadInfo(),
      builder: (context, snapshot) {
        print("Inside builder");

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          print("❌ Snapshot error: ${snapshot.error}");
          return Scaffold(
            body: Center(child: Text("Error: ${snapshot.error}")),
          );
        }

        if (!snapshot.hasData) {
          print("❌ Snapshot has no data");
          return const Scaffold(
            body: Center(child: Text("No doctor data available")),
          );
        }

        final info = snapshot.data!;
        print("✅ Loaded doctor info: ${info.name}");

        return 
           Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                displayDoctorImage(info.logoBase64),
                const SizedBox(height: 20),
                Text("Dr. ${info.name}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text(info.specialization),
                Text(info.clinicName),
                Text(info.clinicAddress),
                Text(info.contact),
              ],
            ),
          );
        
      },
    );
  }
}
