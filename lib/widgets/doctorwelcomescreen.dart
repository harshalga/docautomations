// 

import 'package:docautomations/common/appcolors.dart';
import 'package:docautomations/common/licenseprovider.dart';
import 'package:docautomations/commonwidget/trialbanner.dart';
import 'package:docautomations/services/license_api_service.dart';
import 'package:docautomations/widgets/doctorinfo.dart';
import 'package:docautomations/common/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class DoctorWelcomeScreen extends StatefulWidget {
  const DoctorWelcomeScreen({super.key});

  @override
  State<DoctorWelcomeScreen> createState() => _DoctorWelcomeScreenState();
}

class _DoctorWelcomeScreenState extends State<DoctorWelcomeScreen> {
  String _appVersion = "";

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = "v ${info.version}+${info.buildNumber}";
      });
    } catch (e) {
      setState(() {
        _appVersion = "v 1.0.0"; // fallback
      });
    }
  }

  Future<DoctorInfo> _loadInfo() async {
    try {
      final doctorData = await LicenseApiService.fetchDoctorProfile();

      if (doctorData != null) {
        return DoctorInfo.fromJson(doctorData);
      } else {
        throw Exception("No doctor data from server");
      }
    } catch (e) {
      throw Exception("Error loading doctor info: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LicenseProvider>(
      builder: (context, license, child) {
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
              body: Stack(
                children: [
                  SizedBox.expand(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          if (!license.isSubscribed && license.isTrialActive)
                            const TrialBanner(),
                          Container(
                            padding: const EdgeInsets.all(20),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 20),
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
                                 "Dr.${info.name}",
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

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.print,
                                        color: Colors.blueGrey),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Letterhead Printing: ${info.printLetterhead == true ? "Enabled" : "Disabled"}",
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.medical_services,
                                        color: Colors.green),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Total Prescriptions: ${info.prescriptionCount ?? 0}",
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                               

                                if (license.isTrialActive == false &&
                                    license.isSubscribed == false)
                                  Text(
                                    "Your trial has expired. Please renew your subscription.",
                                    style: TextStyle(
                                      color: Colors.red[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  )
                                else if (license.isSubscribed)
                                  const Text(
                                    "Subscription Active ✅",
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                else
                                  Text(
                                    "Trial Active until ${DateFormat('dd/MM/yyyy HH:mm:ss').format(license.trialEndDate!)}",
                                    style: const TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                
 const SizedBox(height: 30),

                  // ✅ Contact Us Section — App-themed design
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          title: Row(
                            children: [
                              Icon(Icons.email_outlined, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Text(
                                "Contact Us",
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          content: const Text(
                            "We would love to hear from you!\nSend us an email at \n contactprescriptor@zohomail.in",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12),
                          ),
                          actionsAlignment: MainAxisAlignment.spaceEvenly,
                          actions: [
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.grey[700],
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cancel"),
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () async {
//                                 final Uri emailUri = Uri(
//   scheme: 'mailto',
//   path: 'contactprescriptor@zohomail.in',
//   queryParameters: {'subject': 'Feedback for Prescriptor'},
// );
final subject = Uri.encodeComponent('Feedback for Prescriptor');
final Uri emailUri = Uri.parse(
    'mailto:contactprescriptor@zohomail.in?subject=$subject');


try {
  final bool launched = await launchUrl(
    emailUri,
    mode: LaunchMode.externalApplication, // ✅ ensures it opens external apps
  );
  if (!launched) {
    throw Exception('Could not launch');
  }
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('No email app found. Please install Gmail or Outlook.'),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.email_rounded, size: 20, color: AppColors.colorLightSecondary),
                              label: const Text("Email"),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.email_outlined, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          "Contact Us",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ✅ App version (clean and aligned below contact section)
                  Text(
                    _appVersion.isEmpty ? "" : _appVersion,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                 


                ],
              ),
            );
          },
        );
      },
    );
  }
}
