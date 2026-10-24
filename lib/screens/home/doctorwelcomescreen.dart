
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:docautomations/common/appcolors.dart';
import 'package:docautomations/device_assets/asset_manager.dart';
import 'package:docautomations/device_assets/asset_type.dart';
import 'package:docautomations/controllers/application_controller.dart';

class DoctorWelcomeScreen extends StatefulWidget {
  const DoctorWelcomeScreen({super.key});

  @override
  State<DoctorWelcomeScreen> createState() =>
      _DoctorWelcomeScreenState();
}

class _DoctorWelcomeScreenState
    extends State<DoctorWelcomeScreen> {
  String _appVersion = '';
  Uint8List? _doctorLogo;

  @override
  void initState() {
    super.initState();
    _loadVersion();

    // Load the logo from the synchronized local asset.
    // Connect this to the read method exposed by AssetManager.
    _loadLogo();
  }

  //--------------------------------------------------------------------------
  // App Version
  //--------------------------------------------------------------------------

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();

      if (!mounted) return;

      setState(() {
        _appVersion =
            'v${info.version}+${info.buildNumber}';
      });
    } catch (error) {
      debugPrint('Unable to load app version: $error');

      if (!mounted) return;

      setState(() {
        _appVersion = '';
      });
    }
  }

  //--------------------------------------------------------------------------
  // Doctor Logo
  //--------------------------------------------------------------------------

  Future<void> _loadLogo() async {
  try {
    final assetManager = context.read<AssetManager>();

    final bytes = await assetManager.loadAsset(
      AssetType.logo,
    );

    if (!mounted) return;

    setState(() {
      _doctorLogo = bytes == null || bytes.isEmpty
          ? null
          : Uint8List.fromList(bytes);
    });
  } catch (error) {
    debugPrint('Unable to load doctor logo: $error');

    if (!mounted) return;

    setState(() {
      _doctorLogo = null;
    });
  }
}

  //--------------------------------------------------------------------------
  // Demo Playlist
  //--------------------------------------------------------------------------

  Future<void> _openDemoPlaylist() async {
    final uri = Uri.parse(
      'https://www.youtube.com/playlist?list=PLLikLK39r_Zo',
    );

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        throw Exception('Unable to open YouTube.');
      }
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open YouTube.'),
        ),
      );
    }
  }

  //--------------------------------------------------------------------------
  // Contact Us
  //--------------------------------------------------------------------------

  Future<void> _contactUs() async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'contactprescriptor@zohomail.in',
      queryParameters: {
        'subject': 'Feedback for Prescriptor',
      },
    );

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        throw Exception('Unable to open email application.');
      }
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No email application found. '
            'Please configure an email app.',
          ),
        ),
      );
    }
  }

  //--------------------------------------------------------------------------
  // Build
  //--------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final masterData =
    context.watch<ApplicationController>().masterData;

    final doctor = masterData.doctorProfile.doctor;
    final theme = Theme.of(context);

    final doctorName = doctor.doctorName.trim();
    final qualification = doctor.qualification.trim();
    final specialization = doctor.specialization.trim();
    final clinicName = doctor.clinicName.trim();

    final address = [
      doctor.clinicAddress,
      doctor.city,
      doctor.district,
      doctor.state,
      doctor.pinCode,
    ]
        .where((value) => value.trim().isNotEmpty)
        .join(', ');

    final contactDetails = [
      doctor.mobileNumber,
      doctor.alternateMobileNumber,
      doctor.loginEmail,
      doctor.website,
    ]
        .where((value) => value.trim().isNotEmpty)
        .toList();

    // IMPORTANT:
    // Replace this with the actual letterhead-printing
    // setting in your PrescriptionLayout model.
    final bool letterheadEnabled =
    masterData.prescriptionLayout.printLetterHead;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome Screen'),
        backgroundColor: theme.colorScheme.secondary,
        foregroundColor: theme.colorScheme.onSecondary,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 20,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 520,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(
                        alpha: 0.18,
                      ),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    //----------------------------------------------------------------
                    // Doctor Logo / Placeholder
                    //----------------------------------------------------------------

                    Container(
                      width: 112,
                      height: 112,
                      decoration: BoxDecoration(
                        color: theme
                            .colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: theme.dividerColor,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _doctorLogo != null &&
                              _doctorLogo!.isNotEmpty
                          ? Image.memory(
                              _doctorLogo!,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) =>
                                  _buildLogoPlaceholder(context),
                            )
                          : _buildLogoPlaceholder(context),
                    ),

                    const SizedBox(height: 20),

                    //----------------------------------------------------------------
                    // Doctor Name
                    //----------------------------------------------------------------

                    Text(
                      doctorName.isEmpty
                          ? 'Doctor Name'
                          : 'Dr. $doctorName',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    if (qualification.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        qualification,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium,
                      ),
                    ],

                    if (specialization.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        specialization,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ],

                    if (clinicName.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        clinicName,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],

                    if (address.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        address,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],

                    if (contactDetails.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      ...contactDetails.map(
                        (detail) => Padding(
                          padding: const EdgeInsets.only(
                            top: 3,
                          ),
                          child: Text(
                            detail,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    //----------------------------------------------------------------
                    // Letterhead Printing
                    //----------------------------------------------------------------

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.print_outlined,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            'Letterhead Printing: '
                            '${letterheadEnabled ? 'Enabled' : 'Disabled'}',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    //----------------------------------------------------------------
                    // Watch App Demo
                    //----------------------------------------------------------------

                    Card(
                      color: Colors.red.shade50,
                      elevation: 2,
                      child: ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: const CircleAvatar(
                          backgroundColor: Colors.red,
                          child: Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                          ),
                        ),
                        title: const Text(
                          'Watch App Demo',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: const Text(
                          'Learn prescriptions, printing and '
                          'sharing through our video tutorials.',
                        ),
                        trailing: const Icon(
                          Icons.open_in_new,
                        ),
                        onTap: _openDemoPlaylist,
                      ),
                    ),

                    const SizedBox(height: 28),

                    //----------------------------------------------------------------
                    // Contact Us
                    //----------------------------------------------------------------

                    InkWell(
                      onTap: _contactUs,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.email_outlined,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Contact Us',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                decoration:
                                    TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    //----------------------------------------------------------------
                    // App Version
                    //----------------------------------------------------------------

                    Text(
                      _appVersion,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  //--------------------------------------------------------------------------
  // Logo Placeholder
  //--------------------------------------------------------------------------

  Widget _buildLogoPlaceholder(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.medical_services_outlined,
          size: 42,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 6),
        Text(
          'Doctor Logo',
          style: theme.textTheme.labelSmall,
        ),
      ],
    );
  }
}
