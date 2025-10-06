import 'package:docautomations/common/appcolors.dart';
import 'package:docautomations/commonwidget/trialbanner.dart';
import 'package:docautomations/services/license_api_service.dart';
import 'package:flutter/material.dart';

import 'package:docautomations/widgets/doctorinfo.dart';
import 'package:docautomations/common/common_widgets.dart';

class DoctorWelcomeScreen extends StatelessWidget {
  const DoctorWelcomeScreen({super.key});

  Future<DoctorInfo> _loadInfo() async {
    try {

      final doctorData = await LicenseApiService.fetchDoctorProfile();

  if (doctorData != null)
  {
    
    return DoctorInfo.fromJson(doctorData);
       
  }
  else {
        throw Exception("No doctor data from server");
      }
    } catch (e) {
      throw Exception("Error loading doctor info: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DoctorInfo>(
      future: _loadInfo(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Welcome Screen',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
              ),
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text("Welcome Screen")),
            body: Center(child: Text("Error: ${snapshot.error}")),
          );
        }

        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text("Welcome Screen")),
            body: const Center(child: Text("No doctor data available")),
          );
        }

        final info = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Welcome Screen',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
            ),
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
          body: SizedBox.expand(
            child:Column(
              children: [
                TrialBanner(),
                 Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(child: displayDoctorImage(info.logoBase64)),
                  const SizedBox(height: 20),
                  Text(
                    info.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(info.specialization),
                  Text(info.clinicName),
                  Text(info.clinicAddress),
                  Text(info.contact),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 10),

                  // ✅ Show letterhead status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.print, color: Colors.blueGrey),
                      const SizedBox(width: 8),
                      Text(
                        "Letterhead Printing: ${info.printLetterhead == true ? "Enabled" : "Disabled"}",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // ✅ Show prescription count
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.medical_services, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        "Total Prescriptions: ${info.prescriptionCount ?? 0}",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
              ],
            )
          ),
        );
      },
    );
  }
}
