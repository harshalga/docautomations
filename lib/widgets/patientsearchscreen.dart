// import 'package:docautomations/common/licenseprovider.dart';
// import 'package:docautomations/commonwidget/trialbanner.dart';
// import 'package:docautomations/widgets/AddPrescrip.dart';
// import 'package:flutter/material.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:provider/provider.dart';

// /// The starting point for finding an existing patient or creating one.
// class PatientSearchScreen extends StatefulWidget {
//   const PatientSearchScreen({super.key, this.title = 'Find Patient'});

//   final String title;

//   @override
//   State<PatientSearchScreen> createState() => _PatientSearchScreenState();
// }

// class _PatientSearchScreenState extends State<PatientSearchScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _ppidController = TextEditingController();
//   bool _isSearching = false;

//   @override
//   void dispose() {
//     _ppidController.dispose();
//     super.dispose();
//   }

//   Future<void> _searchPatient() async {
//     if (!_formKey.currentState!.validate()) return;

//     FocusScope.of(context).unfocus();
//     setState(() => _isSearching = true);

//     try {
//       // Connect PatientApiService.searchPatientByPPID here when the patient
//       // search endpoint is available.
//       await Future<void>.delayed(const Duration(milliseconds: 250));
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Searching for ${_ppidController.text.trim()}')),
//       );
//     } catch (_) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Unable to search for this patient.')),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _isSearching = false);
//     }
//   }

//   Future<void> _scanQRCode() async {
//     final ppid = await Navigator.of(context).push<String>(
//       MaterialPageRoute(builder: (_) => const _PpidQrScannerScreen()),
//     );

//     if (!mounted || ppid == null || ppid.trim().isEmpty) return;
//     setState(() => _ppidController.text = ppid.trim());
//   }

//   void _forgotPPID() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Patient lookup by name, DOB, gender and mobile is coming soon.'),
//       ),
//     );
//   }

//   void _newPatient() {
//     //TODO: Need to call the Diagnosis screen with the new patient creation flow. 

//     Navigator.push(
//   context,
//   MaterialPageRoute(
//     builder: (_) => const Addprescrip(
//       title: "Diagnosis",
//       mode: PatientMode.newPatient,
//     ),
//   ),
// );
//     // ScaffoldMessenger.of(context).showSnackBar(
//     //   const SnackBar(content: Text('New patient registration will open here.')),
//     // );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Consumer<LicenseProvider>(
//       builder: (context, license, child) => Scaffold(
//         appBar: AppBar(
//           backgroundColor: theme.colorScheme.secondary,
//           foregroundColor: theme.colorScheme.onSecondary,
//           elevation: 0,
//           centerTitle: true,
//           title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w700)),
//         ),
//         body: Stack(
//           children: [
//             SingleChildScrollView(
//               padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   children: [
//                     if (!license.isSubscribed && license.isTrialActive) ...[
//                       const TrialBanner(),
//                       const SizedBox(height: 16),
//                     ],
//                     _WelcomeCard(
//                       ppidController: _ppidController,
//                       onScan: _scanQRCode,
//                       onSearch: _searchPatient,
//                       onForgotPpid: _forgotPPID,
//                       onNewPatient: _newPatient,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             if (_isSearching)
//               ColoredBox(
//                 color: Colors.black26,
//                 child: const Center(child: CircularProgressIndicator()),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _WelcomeCard extends StatelessWidget {
//   const _WelcomeCard({
//     required this.ppidController,
//     required this.onScan,
//     required this.onSearch,
//     required this.onForgotPpid,
//     required this.onNewPatient,
//   });

//   final TextEditingController ppidController;
//   final VoidCallback onScan;
//   final VoidCallback onSearch;
//   final VoidCallback onForgotPpid;
//   final VoidCallback onNewPatient;

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     const primary = Colors.orange;

//     return Container(
//       width: double.infinity,
//       constraints: const BoxConstraints(maxWidth: 560),
//       padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(32),
//         boxShadow: [
//           BoxShadow(
//             color: primary.withValues(alpha: 0.14),
//             blurRadius: 24,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           CircleAvatar(
//             radius: 38,
//             backgroundColor: primary.withValues(alpha: 0.10),
//             child: Icon(Icons.person_search_rounded, color: primary, size: 42),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'Find Patient',
//             style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
//           ),
//           const SizedBox(height: 10),
//           Text(
//             'Search an existing patient using PPID, scan QR code or create a new patient.',
//             textAlign: TextAlign.center,
//             style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700, height: 1.45),
//           ),
//           const SizedBox(height: 28),
//           const Divider(),
//           const SizedBox(height: 20),
//           Align(
//             alignment: Alignment.centerLeft,
//             child: Text('Patient PPID', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
//           ),
//           const SizedBox(height: 8),
//           TextFormField(
//             controller: ppidController,
//             textCapitalization: TextCapitalization.characters,
//             textInputAction: TextInputAction.search,
//             onFieldSubmitted: (_) => onSearch(),
//             decoration: InputDecoration(
//               hintText: 'PP______________',
//               prefixIcon: Icon(Icons.badge_outlined, color: primary),
//               suffixIcon: IconButton(
//                 tooltip: 'Scan prescription QR code',
//                 onPressed: onScan,
//                 icon: Icon(Icons.qr_code_scanner_rounded, color: primary),
//               ),
//               border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(14),
//                 borderSide: BorderSide(color: Colors.grey.shade400),
//               ),
//             ),
//             validator: (value) => value == null || value.trim().isEmpty ? 'Enter a Patient PPID' : null,
//           ),
//           const SizedBox(height: 16),
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton.icon(
//               onPressed: onSearch,
//               icon: const Icon(Icons.search_rounded),
//               label: const Text('Search'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: primary,
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//               ),
//             ),
//           ),
//           const SizedBox(height: 22),
//           const Divider(),
//           const SizedBox(height: 14),
//           TextButton(
//             onPressed: onForgotPpid,
//             child: const Text('Forgot Patient PPID?', style: TextStyle(fontWeight: FontWeight.w700)),
//           ),
//           Text(
//             'Search using Name, DOB, Gender & Mobile',
//             textAlign: TextAlign.center,
//             style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade700),
//           ),
//           const SizedBox(height: 12),
//           OutlinedButton(
//             onPressed: onForgotPpid,
//             child: const Text('Find Patient'),
//           ),
//           const SizedBox(height: 22),
//           const Divider(),
//           const SizedBox(height: 14),
//           Text('New Patient', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
//           const SizedBox(height: 5),
//           Text('Create a patient and begin consultation', style: TextStyle(color: Colors.grey.shade700)),
//           const SizedBox(height: 12),
//           SizedBox(
//             width: double.infinity,
//             child: OutlinedButton.icon(
//               onPressed: onNewPatient,
//               icon: const Icon(Icons.person_add_alt_1_rounded),
//               label: const Text('New Patient'),
//               style: OutlinedButton.styleFrom(
//                 foregroundColor: primary,
//                 side: BorderSide(color: primary),
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _PpidQrScannerScreen extends StatefulWidget {
//   const _PpidQrScannerScreen();

//   @override
//   State<_PpidQrScannerScreen> createState() => _PpidQrScannerScreenState();
// }

// class _PpidQrScannerScreenState extends State<_PpidQrScannerScreen> {
//   bool _hasScanned = false;

//   void _onDetect(BarcodeCapture capture) {
//     if (_hasScanned) return;
//     final value = capture.barcodes.firstOrNull?.rawValue?.trim();
//     if (value == null || value.isEmpty) return;
//     _hasScanned = true;
//     Navigator.of(context).pop(value);
//   }

//   @override
//   Widget build(BuildContext context) => Scaffold(
//         backgroundColor: Colors.black,
//         appBar: AppBar(
//           title: const Text('Scan Patient QR Code'),
//           backgroundColor: Colors.black,
//           foregroundColor: Colors.white,
//         ),
//         body: Stack(
//           fit: StackFit.expand,
//           children: [
//             MobileScanner(onDetect: _onDetect),
//             Center(
//               child: Container(
//                 width: 240,
//                 height: 240,
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.white, width: 3),
//                   borderRadius: BorderRadius.circular(18),
//                 ),
//               ),
//             ),
//             const Positioned(
//               left: 24,
//               right: 24,
//               bottom: 40,
//               child: Text(
//                 'Align the QR code on the prescription within the frame.',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(color: Colors.white, fontSize: 16),
//               ),
//             ),
//           ],
//         ),
//       );
// }
