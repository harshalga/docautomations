// import 'dart:convert';

// import 'package:docautomations/common/appcolors.dart';
// import 'package:docautomations/common/licenseprovider.dart';
// import 'package:docautomations/commonwidget/loadingOverlay.dart';
// import 'package:docautomations/commonwidget/trialbanner.dart';
// import 'package:docautomations/datamodels/prescriptionData.dart';
// import 'package:docautomations/services/license_api_service.dart';
// import 'package:docautomations/widgets/AddPrescription.dart';
// import 'package:docautomations/widgets/PatientInfo.dart';
// import 'package:docautomations/widgets/doctorinfo.dart';
// import 'package:docautomations/widgets/print_preview_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:intl/intl.dart';
// import 'package:flutter/foundation.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class Addprescriptionscr extends StatefulWidget {
//   const Addprescriptionscr({super.key});

//   @override
//   State<Addprescriptionscr> createState() => _AddprescriptionscrState();
// }

// class _AddprescriptionscrState extends State<Addprescriptionscr> {
//   final _formKey = GlobalKey<FormState>();

// final GlobalKey<PatientinfoState> _patientInfoKey = GlobalKey<PatientinfoState>();
// bool _canGeneratePdf = true;  // initially enabled
// bool _canGenerateNext = false; // initially disabled
// bool _isLoading = false;

  
  
  
//    Uint8List? _doctorLogo;

//   DoctorInfo? _doctorInfo;

// final bool _printLetterhead = true; // default true

//   @override
//   void initState() {
//     super.initState();
//     _loadDoctorInfo(); // load on widget creation
         
//   }

  

// Future<void> _loadDoctorInfo() async {
//   final prefs = await SharedPreferences.getInstance();
//   final stored = prefs.getString("doctor_profile");
//   DoctorInfo? doctor;

//   if (stored != null) {
    
//     doctor = DoctorInfo.fromJson(jsonDecode(stored));
//   } else {
     
//     final apiData = await LicenseApiService.fetchDoctorProfile();
//     if (apiData!= null)
//     {
//     doctor = DoctorInfo.fromJson(apiData["doctor"]);
//     await prefs.setString("doctor_profile", jsonEncode(doctor.toJson()));
//     }
    
//   }

  
//     setState(() {
//       _doctorInfo = doctor;
//       //Decode logo
//       if (_doctorInfo?.logoBase64 != null && _doctorInfo!.logoBase64!.isNotEmpty) {
//         _doctorLogo = base64Decode(_doctorInfo!.logoBase64!);
//       }
//     });
  
// }


  

//   // Instead of a single prescription, maintain a list
//   final List<Prescriptiondata> _prescriptions = [];

//   static const descTextStyle = TextStyle(
//     color: Colors.black,
//     fontWeight: FontWeight.w800,
//     fontFamily: 'Roboto',
//     letterSpacing: 0.5,
//     fontSize: 18,
//     height: 2,
//   );



// void _resetPrescriptionForm() {
//   setState(() {
//     _prescriptions.clear();  // clear medicines
//     _patientInfoKey.currentState?.clearFields(); // reset PatientInfo widget fields
//   });
// }


// void generatePrescriptionPdf(DoctorInfo doctorInfo) async {
//   setState(() => _isLoading = true);   // show loader
//   String doctorName="Dr. ${doctorInfo.name}";
//   final pdf = pw.Document();
//   final name = _patientInfoKey.currentState?.tabNameController.text ?? '';
//   final age = _patientInfoKey.currentState?.ageController.text ?? '';
//   final complaints = _patientInfoKey.currentState?.keyComplaintcontroller.text ?? '';
//   final examination = _patientInfoKey.currentState?.examinationcontroller.text ?? '';
//   final diagnosis = _patientInfoKey.currentState?.diagnoscontroller.text ?? '';
//  // final selectedGenderval = _patientInfoKey.currentState?.selectedGender.toString() ?? '';
//   final selectedGenderval = _patientInfoKey.currentState?.gender.value ?? '';
//   final nextfollowupdate = _patientInfoKey.currentState?.followupDatecontroller.text ?? '';
//   final remarks = _patientInfoKey.currentState?.remarkscontroller.text ?? '';

//   final now = DateTime.now();
//   final formattedDate = DateFormat('dd/MM/yyyy').format(now);

//   pdf.addPage(
//     pw.Page(
//       pageFormat: PdfPageFormat.a4,
//       build: (context) {
//         return pw.Column(
//           crossAxisAlignment: pw.CrossAxisAlignment.start,
//           children: [
//             if (_printLetterhead) ...[
//               pw.Row(
//                 mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                 children: [
//                   pw.Column(
//                     crossAxisAlignment: pw.CrossAxisAlignment.start,
//                     children: [
//                       pw.Text( doctorName, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
//                       pw.Text( doctorInfo.specialization ),
//                       pw.Text( doctorInfo.clinicAddress),
//                       pw.Text("Contact: ${doctorInfo.contact}"),
//                     ],
//                   ),
//                   if (_doctorLogo != null)
//                     pw.Container(
//                       width: 60,
//                       height: 60,
//                       child: pw.Image(pw.MemoryImage(_doctorLogo!)),
//                     ),
//                 ],
//               ),
//               pw.SizedBox(height: 10),
//               pw.Divider(),
//             ] else ...[
//               pw.SizedBox(height: 100),
//               pw.Divider(),
//             ],

//             pw.Row(
//               mainAxisAlignment: pw.MainAxisAlignment.end,
//               children: [
//                 pw.Text("Date: $formattedDate", style: pw.TextStyle(fontSize: 14)),
//               ],
//             ),

//             // ✅ Patient Info
//             pw.Text("Patient Information", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
//             pw.Text("Patient Name: $name", style: pw.TextStyle(fontSize: 16)),
//             pw.Text("Age: $age", style: pw.TextStyle(fontSize: 16)),
//             pw.Text("Gender: $selectedGenderval", style: pw.TextStyle(fontSize: 16)),
//             pw.SizedBox(height: 5),

//             // ✅ Only show sections if not empty
//             if (complaints.trim().isNotEmpty) ...[
//               pw.Text("Key Complaints:", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
//               pw.Text(" $complaints", style: pw.TextStyle(fontSize: 14)),
//               pw.SizedBox(height: 10),
//             ],

//             if (examination.trim().isNotEmpty) ...[
//               pw.Text("Examination:", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
//               pw.Text(" $examination", style: pw.TextStyle(fontSize: 14)),
//               pw.SizedBox(height: 10),
//             ],

//             if (diagnosis.trim().isNotEmpty) ...[
//               pw.Text("Diagnostics:", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
//               pw.Text(" $diagnosis", style: pw.TextStyle(fontSize: 14)),
//               pw.SizedBox(height: 10),
//             ],

//             if (remarks.trim().isNotEmpty) ...[
//               pw.Text("Remarks:", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
//               pw.Text(" $remarks", style: pw.TextStyle(fontSize: 14)),
//               pw.SizedBox(height: 10),
//             ],

//             if (nextfollowupdate.trim().isNotEmpty) ...[
//               pw.Text("Next Follow Up Date:", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
//               pw.Text(" $nextfollowupdate", style: pw.TextStyle(fontSize: 14)),
//               pw.SizedBox(height: 10),
//             ],

//             // ✅ Medicines Table
//             pw.Text("Prescribed Medicines:", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
//             pw.SizedBox(height: 5),
//             if (_prescriptions.isEmpty)
//               pw.Text("No medicines added.")
//             else
//               pw.Table(
//                 border: pw.TableBorder.all(color: PdfColors.grey),
//                 columnWidths: {
//                   0: pw.FlexColumnWidth(2),
//                   1: pw.FlexColumnWidth(2),
//                   2: pw.FlexColumnWidth(2),
//                   3: pw.FlexColumnWidth(2),
//                   4: pw.FlexColumnWidth(2),
//                 },
//                 children: [
//                   // Header row
//                   pw.TableRow(
//                     decoration: pw.BoxDecoration(color: PdfColors.grey300),
//                     children: [
//                       pw.Padding(padding: pw.EdgeInsets.all(4), child: pw.Text("Medicine")),
//                       pw.Padding(padding: pw.EdgeInsets.all(4), child: pw.Text("Timing")),
//                       pw.Padding(padding: pw.EdgeInsets.all(4), child: pw.Text("Food")),
//                       pw.Padding(padding: pw.EdgeInsets.all(4), child: pw.Text("Duration")),
//                       pw.Padding(padding: pw.EdgeInsets.all(4), child: pw.Text("Remarks")),
//                     ],
//                   ),
//                   // Data rows
//                   ..._prescriptions.map((med) {
//                     final timeList  = med.toBitList(4);
//                     final time = timeList.join("- "); // join list items into one string
//                     return pw.TableRow(
//                       children: [
//                         pw.Padding(padding: pw.EdgeInsets.all(4), child: pw.Text(med.drugName ?? '')),
//                         pw.Padding(padding: pw.EdgeInsets.all(4), child: pw.Text(time)),
//                         pw.Padding(padding: pw.EdgeInsets.all(4), child: pw.Text(med.isBeforeFood ? 'Before Food' : 'After Food')),
//                         pw.Padding(padding: pw.EdgeInsets.all(4), child: pw.Text("${med.followupDuration} ${med.inDays ? 'Days' : 'Months'}")),
//                         pw.Padding(padding: pw.EdgeInsets.all(4), child: pw.Text(med.remarks ?? '')),
//                       ],
//                     );
//                   }),
//                 ],
//               ),

//             pw.Spacer(),

//             // Footer
//             pw.Align(
//               alignment: pw.Alignment.centerRight,
//               child: pw.Text("Signature", style: pw.TextStyle(fontSize: 14)),
//             ),
//             pw.Divider(),
//           ],
//         );
//       },
//     ),
//   );

//   try {
//     await LicenseApiService.incrementPrescriptionCount();
//     final pdfBytes = await pdf.save();

//     // if (kIsWeb) {
//     //   await Printing.layoutPdf(onLayout: (format) async => pdfBytes);
//     // } else {
//     //   final dir = await getTemporaryDirectory();
//     //   final file = io.File('${dir.path}/prescription.pdf');
//     //   await file.writeAsBytes(pdfBytes);
//     //   await OpenFile.open(file.path);
//     // }

//     // Navigate to print preview screen
//     Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => PrintPreviewScreen(pdfBytes: pdfBytes),
//   ),
// );

//   } catch (e) {
//     print("Error generating or opening PDF: $e");
//   }
//   finally {
//     setState(() => _isLoading = false);  // hide loader
//   }
// }

// // @override
// // Widget build(BuildContext context) {
// //   return   Consumer<LicenseProvider>(
// //       builder: (context, license, child) {
// //         return
// //    Stack(
// //     children: [
// //       Column(children: [
       
// //       (!license.isSubscribed && license.isTrialActive) ?
// //     TrialBanner(): SizedBox.shrink(), // 👈 Reusable banner


// //       Expanded(
        
// //         child: SingleChildScrollView(
// //           child: Container(
// //             padding: const EdgeInsets.all(20),
// //             margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
// //             decoration: BoxDecoration(
// //               color: Colors.white,
// //               borderRadius: BorderRadius.circular(50),
// //               boxShadow: [
// //                 BoxShadow(
// //                   color: AppColors.primary.withOpacity(0.3),
// //                   blurRadius: 20,
// //                   offset: Offset.zero,
// //                 ),
// //               ],
// //             ),
// //             child: Form(
// //               key: _formKey,
// //               child: DefaultTextStyle.merge(
// //                 style: descTextStyle,
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Patientinfo(key: _patientInfoKey),
// //                     const SizedBox(height: 10),
// //                     Padding(
// //                       padding: const EdgeInsets.all(8),
// //                       child: ElevatedButton(
// //                         onPressed: () {
// //                           _createPrescription(context);
// //                         },
// //                         child: const Text('Add Medicine'),
// //                       ),
// //                     ),
// //                     const SizedBox(height: 20),

// //                     _buildPrescriptionList(),

// //                     _buildGeneratePdfButton(),

// //                     _buildNextPrescriptionButton(),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ),
// //       ),
// //       // 🔽 Overlay on top when loading
// //       LoadingOverlay(
// //         isLoading: _isLoading,
// //         message: "Generating Prescription……",
// //       ),
// //     ],
// //   ),
// //   ],);
// //   });
// // }

// // @override
// // Widget build(BuildContext context) {
// //   return Consumer<LicenseProvider>(
// //     builder: (context, license, child) {
// //       return Stack(
// //         children: [
// //           /// Entire screen content inside Scaffold
// //           Scaffold(
// //             backgroundColor: Colors.white,
// //             body: Column(
// //               children: [
// //                 // ✅ Trial banner if applicable
// //                 (!license.isSubscribed && license.isTrialActive)
// //                     ? TrialBanner()
// //                     : const SizedBox.shrink(),

// //                 /// Form content
// //                 Expanded(
// //                   child: SingleChildScrollView(
// //                     child: Container(
// //                       padding: const EdgeInsets.all(20),
// //                       margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
// //                       decoration: BoxDecoration(
// //                         color: Colors.white,
// //                         borderRadius: BorderRadius.circular(50),
// //                         boxShadow: [
// //                           BoxShadow(
// //                             color: AppColors.primary.withOpacity(0.3),
// //                             blurRadius: 20,
// //                             offset: Offset.zero,
// //                           ),
// //                         ],
// //                       ),
// //                       child: Form(
// //                         key: _formKey,
// //                         child: DefaultTextStyle.merge(
// //                           style: descTextStyle,
// //                           child: Column(
// //                             crossAxisAlignment: CrossAxisAlignment.start,
// //                             children: [
// //                               Patientinfo(key: _patientInfoKey),
// //                               const SizedBox(height: 10),
// //                               Padding(
// //                                 padding: const EdgeInsets.all(8),
// //                                 child: ElevatedButton(
// //                                   onPressed: () {
// //                                     _createPrescription(context);
// //                                   },
// //                                   child: const Text('Add Medicine'),
// //                                 ),
// //                               ),
// //                               const SizedBox(height: 20),
// //                               _buildPrescriptionList(),
// //                               _buildGeneratePdfButton(),
// //                               _buildNextPrescriptionButton(),
// //                             ],
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),

// //           /// ✅ Full-screen overlay
// //           if (_isLoading)
// //             Positioned.fill(
// //               child: LoadingOverlay(
// //                 isLoading: true,
// //                 message: "Generating Prescription…",
// //               ),
// //             ),
// //         ],
// //       );
// //     },
// //   );
// // }
  
// //   @override
// // Widget build(BuildContext context) {
// //   return Stack(
// //     children: [
// //       Scaffold(
// //         backgroundColor: Colors.white,
// //         body: Column(
// //           children: [
// //             Consumer<LicenseProvider>(
// //               builder: (context, license, _) {
// //                 return (!license.isSubscribed && license.isTrialActive)
// //                     ? TrialBanner()
// //                     : const SizedBox.shrink();
// //               },
// //             ),

// //             Expanded(
// //               child: SingleChildScrollView(
// //                 child: _buildFormContent(),   // ⬅️ Patientinfo is inside here (no rebuild!)
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),

// //       if (_isLoading)
// //         LoadingOverlay(
// //           isLoading: true,
// //           message: "Generating Prescription…",
// //         )
// //     ],
// //   );
// // }

// @override
// Widget build(BuildContext context) {
//   return Stack(
//     children: [
      
//       // Keep Patient Form stable
//       Scaffold(
//         backgroundColor: Colors.white,
//         body: Column(
//           children: [
//             // REMOVE Consumer FROM HERE ❌
//             Expanded(
//               child: SingleChildScrollView(
//                 child: _buildFormContent(),
//               ),
//             ),
//           ],
//         ),
//       ),

//       // Put Trial Banner here - OUTSIDE the Scaffold widget tree!
//       Positioned(
//         top: 0,
//         left: 0,
//         right: 0,
//         child: Consumer<LicenseProvider>(
//           builder: (context, license, _) {
//             return (!license.isSubscribed && license.isTrialActive)
//                 ? TrialBanner()
//                 : SizedBox.shrink();
//           },
//         ),
//       ),

//       // Loader overlay stays here
//       if (_isLoading)
//         LoadingOverlay(
//           isLoading: true,
//           message: "Generating Prescription…",
//         )
//     ],
//   );
// }


// Widget _buildFormContent() {
//   return Container(
//     padding: const EdgeInsets.all(20),
//     margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(50),
//       boxShadow: [
//         BoxShadow(
//           color: AppColors.primary.withOpacity(0.3),
//           blurRadius: 20,
//         ),
//       ],
//     ),
//     child: Form(
//       key: _formKey,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Patientinfo(key: _patientInfoKey),   // ❗ persistent now
//           const SizedBox(height: 10),
//           _buildAddMedicineButton(),
//           const SizedBox(height: 20),
//           _buildPrescriptionList(),
//           _buildGeneratePdfButton(),
//           _buildNextPrescriptionButton(),
//         ],
//       ),
//     ),
//   );
// }


// Widget _buildAddMedicineButton() {
//   return Padding(
//     padding: const EdgeInsets.all(8),
//     child: ElevatedButton(
//       onPressed: () {
//         _createPrescription(context);
//       },
//       child: const Text('Add Medicine'),
//     ),
//   );
// }


// Widget _buildPrescriptionList() {
//     // your existing prescription list widget code
//     return Container(
//     child:   _prescriptions.isNotEmpty
//                         ? ListView.builder(
//                             shrinkWrap: true,
//                             physics: const NeverScrollableScrollPhysics(),
//                             itemCount: _prescriptions.length,
//                             itemBuilder: (context, index) {
//                               final presc = _prescriptions[index];
//                               return Card(
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(20),
//                                 ),
//                                 elevation: 5,
//                                 margin: const EdgeInsets.symmetric(vertical: 8),
//                                 child: ListTile(
//                                   title: Text(presc.drugName ?? "Unnamed"),
//                                   subtitle: Text(
//                                     "For ${presc.followupDuration} ${presc.inDays ? "days" : "Months"} | ${presc.isBeforeFood ? "Before Food" : "After Food"} | ${presc.toBitList(4)}",
//                                   ),
//                                   trailing: PopupMenuButton<String>(
//                                     onSelected: (value) {
//                                       if (value == 'edit') {
//                                         _editPrescription(context, index);
//                                       } else if (value == 'delete') {
//                                         _deletePrescription(index);
//                                       }
//                                     },
//                                     itemBuilder: (context) => [
//                                       const PopupMenuItem(
//                                         value: 'edit',
//                                         child: Text('Edit'),
//                                       ),
//                                       const PopupMenuItem(
//                                         value: 'delete',
//                                         child: Text('Delete'),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               );
//                             },
//                           )
//                         : const Text('No medicines added yet.'),
//     );
//   }

//   Widget _buildGeneratePdfButton() {
//     // your existing generate PDF button code
//     return Container(
//       child:   Padding(
//                       padding: const EdgeInsets.only(top: 20),
//                       child: ElevatedButton.icon(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: _canGeneratePdf
//                               ? Colors.blue
//                               : Colors.grey,
//                         ),
//                         onPressed: _canGeneratePdf
//                             ? () {
//                                 final isFormValid =
//                                     _formKey.currentState!.validate();
//                                 if (isFormValid && _doctorInfo != null) {
//                                   generatePrescriptionPdf(_doctorInfo!);
//                                   setState(() {
//                                     //_canGeneratePdf =  false;
//                                     _canGenerateNext = true;
//                                   });
//                                 }
//                               }
//                             : null,
//                         icon: const Icon(Icons.picture_as_pdf),
//                         label: const Text("Generate PDF Prescription",style: TextStyle( color: Colors.black,)),
//                       ),
//                     ),
//     );
//   }

//   Widget _buildNextPrescriptionButton() {
//     // your existing next prescription button code
//     return Container(
//       child: Padding(
//                       padding: const EdgeInsets.only(top: 10),
//                       child: ElevatedButton.icon(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: _canGenerateNext
//                               ? Colors.redAccent
//                               : Colors.grey,
//                         ),
//                         onPressed: _canGenerateNext
//                             ? () {
//                                 _resetPrescriptionForm();
//                                 setState(() {
//                                   //_canGeneratePdf = true;
//                                   _canGenerateNext = false;
//                                 });
//                               }
//                             : null,
//                         icon: const Icon(Icons.refresh),
//                         label: const Text("Generate Next Prescription",style: TextStyle( color: Colors.black,)),
//                       ),
//                     ),
//     );
//   }




//   Future<void> _createPrescription(BuildContext context) async {
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) =>  const AddPrescription(title: "Prescription"),
//       ),
//     );

//     if (result != null && result is Prescriptiondata) {
//       setState(() {
//         _prescriptions.add(result);
//       });
      
//     }
//   }

//   Future<void> _editPrescription(BuildContext context, int index) async {
//     final existing = _prescriptions[index];
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) =>  AddPrescription(
//           title: "Edit Prescription",existingPrescription: existing
//           // You can pass existing data here if your AddPrescription page supports it
//         ),
//       ),
//     );

//     if (result != null && result is Prescriptiondata) {
//       setState(() {
//         _prescriptions[index] = result;
//       });
//       print("Edited medicine at index $index: ${result.drugName}");
//     }
//   }

//   void _deletePrescription(int index) async {
//   final confirm = await showDialog<bool>(
//     context: context,
//     builder: (context) => AlertDialog(
//       title: const Text('Delete Prescription'),
//       content: const Text('Are you sure you want to delete this prescription?'),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context, false),
//           child: const Text('Cancel'),
//         ),
//         TextButton(
//           onPressed: () => Navigator.pop(context, true),
//           child: const Text('Delete', style: TextStyle(color: Colors.red)),
//         ),
//       ],
//     ),
//   );

//   if (confirm == true) {
//     setState(() {
//       _prescriptions.removeAt(index);
//     });
//     print("Deleted medicine at index $index");
//   }
// }

// }

//Latest
// import 'dart:convert';

// import 'package:docautomations/common/appcolors.dart';
// import 'package:docautomations/common/licenseprovider.dart';
// import 'package:docautomations/commonwidget/loadingOverlay.dart';
// import 'package:docautomations/commonwidget/trialbanner.dart';
// import 'package:docautomations/datamodels/prescriptionData.dart';
// import 'package:docautomations/services/license_api_service.dart';
// import 'package:docautomations/widgets/AddPrescription.dart';
// import 'package:docautomations/widgets/PatientInfo.dart';
// import 'package:docautomations/widgets/doctorinfo.dart';
// import 'package:docautomations/widgets/print_preview_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:intl/intl.dart';
// import 'package:flutter/foundation.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class Addprescriptionscr extends StatefulWidget {
//   const Addprescriptionscr({super.key});

//   @override
//   State<Addprescriptionscr> createState() => _AddprescriptionscrState();
// }

// class _AddprescriptionscrState extends State<Addprescriptionscr> {
//   final _formKey = GlobalKey<FormState>();
//   final GlobalKey<PatientinfoState> _patientInfoKey = GlobalKey<PatientinfoState>();

//   bool _canGeneratePdf = true;
//   bool _canGenerateNext = false;
//   bool _isLoading = false;

//   Uint8List? _doctorLogo;
//   DoctorInfo? _doctorInfo;

//   final bool _printLetterhead = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadDoctorInfo();
//   }

//   Future<void> _loadDoctorInfo() async {
//     final prefs = await SharedPreferences.getInstance();
//     final stored = prefs.getString("doctor_profile");
//     DoctorInfo? doctor;

//     if (stored != null) {
//       doctor = DoctorInfo.fromJson(jsonDecode(stored));
//     } else {
//       final apiData = await LicenseApiService.fetchDoctorProfile();
//       if (apiData != null) {
//         doctor = DoctorInfo.fromJson(apiData["doctor"]);
//         await prefs.setString("doctor_profile", jsonEncode(doctor.toJson()));
//       }
//     }

//     setState(() {
//       _doctorInfo = doctor;

//       if (_doctorInfo?.logoBase64 != null &&
//           _doctorInfo!.logoBase64!.isNotEmpty) {
//         _doctorLogo = base64Decode(_doctorInfo!.logoBase64!);
//       }
//     });
//   }

//   final List<Prescriptiondata> _prescriptions = [];

//   static const descTextStyle = TextStyle(
//     color: Colors.black,
//     fontWeight: FontWeight.w800,
//     fontFamily: 'Roboto',
//     letterSpacing: 0.5,
//     fontSize: 18,
//     height: 2,
//   );

//   void _resetPrescriptionForm() {
//     setState(() {
//       _prescriptions.clear();
//       _patientInfoKey.currentState?.clearFields();
//     });
//   }

//   // ===========================================================
//   // GENERATE PDF — unchanged except gender fix
//   // ===========================================================
//   void generatePrescriptionPdf(DoctorInfo doctorInfo) async {
//     setState(() => _isLoading = true);

//     final pdf = pw.Document();
//     final name = _patientInfoKey.currentState?.tabNameController.text ?? '';
//     final age = _patientInfoKey.currentState?.ageController.text ?? '';
//     final complaints = _patientInfoKey.currentState?.keyComplaintcontroller.text ?? '';
//     final examination = _patientInfoKey.currentState?.examinationcontroller.text ?? '';
//     final diagnosis = _patientInfoKey.currentState?.diagnoscontroller.text ?? '';
//     final gender = _patientInfoKey.currentState?.gender.value ?? '';
//     final nextfollowupdate = _patientInfoKey.currentState?.followupDatecontroller.text ?? '';
//     final remarks = _patientInfoKey.currentState?.remarkscontroller.text ?? '';
//     final now = DateTime.now();
//     final formattedDate = DateFormat('dd/MM/yyyy').format(now);

//     pdf.addPage(
//       pw.Page(
//         pageFormat: PdfPageFormat.a4,
//         build: (context) {
//           return pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               if (_printLetterhead) ...[
//                 pw.Row(
//                   mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                   children: [
//                     pw.Column(
//                       crossAxisAlignment: pw.CrossAxisAlignment.start,
//                       children: [
//                         pw.Text("Dr. ${doctorInfo.name}",
//                             style: pw.TextStyle(
//                                 fontSize: 20, fontWeight: pw.FontWeight.bold)),
//                         pw.Text(doctorInfo.specialization),
//                         pw.Text(doctorInfo.clinicAddress),
//                         pw.Text("Contact: ${doctorInfo.contact}"),
//                       ],
//                     ),
//                     if (_doctorLogo != null)
//                       pw.Container(
//                         width: 60,
//                         height: 60,
//                         child: pw.Image(pw.MemoryImage(_doctorLogo!)),
//                       ),
//                   ],
//                 ),
//                 pw.SizedBox(height: 10),
//                 pw.Divider(),
//               ],

//               pw.Row(
//                 mainAxisAlignment: pw.MainAxisAlignment.end,
//                 children: [
//                   pw.Text("Date: $formattedDate"),
//                 ],
//               ),

//               pw.Text("Patient Information",
//                   style: pw.TextStyle(
//                       fontSize: 18, fontWeight: pw.FontWeight.bold)),
//               pw.Text("Name: $name"),
//               pw.Text("Age: $age"),
//               pw.Text("Gender: $gender"),
//               pw.SizedBox(height: 10),

//               if (complaints.isNotEmpty) pw.Text("Complaints: $complaints"),
//               if (examination.isNotEmpty) pw.Text("Examination: $examination"),
//               if (diagnosis.isNotEmpty) pw.Text("Diagnosis: $diagnosis"),
//               if (remarks.isNotEmpty) pw.Text("Remarks: $remarks"),
//               if (nextfollowupdate.isNotEmpty)
//                 pw.Text("Next Follow Up: $nextfollowupdate"),

//               pw.SizedBox(height: 20),

//               pw.Text("Prescribed Medicines:",
//                   style: pw.TextStyle(
//                       fontSize: 18, fontWeight: pw.FontWeight.bold)),

//               _prescriptions.isEmpty
//                   ? pw.Text("No medicines added.")
//                   : pw.Table(
//                       border: pw.TableBorder.all(),
//                       children: [
//                         pw.TableRow(children: [
//                           pw.Text("Medicine"),
//                           pw.Text("Timing"),
//                           pw.Text("Food"),
//                           pw.Text("Duration"),
//                           pw.Text("Remarks"),
//                         ]),
//                         ..._prescriptions.map((med) {
//                           final time = med.toBitList(4).join("- ");

//                           return pw.TableRow(children: [
//                             pw.Text(med.drugName ?? ""),
//                             pw.Text(time),
//                             pw.Text(med.isBeforeFood ? "Before Food" : "After Food"),
//                             pw.Text("${med.followupDuration} ${med.inDays ? 'Days' : 'Months'}"),
//                             pw.Text(med.remarks ?? ""),
//                           ]);
//                         })
//                       ],
//                     ),

//               pw.Spacer(),
//               pw.Align(
//                 alignment: pw.Alignment.centerRight,
//                 child: pw.Text("Signature"),
//               ),
//               pw.Divider(),
//             ],
//           );
//         },
//       ),
//     );

//     try {
//       await LicenseApiService.incrementPrescriptionCount();
//       final pdfBytes = await pdf.save();

//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) =>
//               PrintPreviewScreen(pdfBytes: pdfBytes),
//         ),
//       );
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   // ===========================================================
//   // MAIN BUILD — FINAL FIXED ARCHITECTURE
//   // ===========================================================
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         Scaffold(
//           backgroundColor: Colors.white,
//           body: Column(
//             children: [
//               Expanded(
//                 child: SingleChildScrollView(
//                   child: _buildFormContent(), // PATIENTINFO IS SAFE HERE
//                 ),
//               ),
//             ],
//           ),
//         ),

//         // TRIAL BANNER — DOES NOT REBUILD FORM
//         Positioned(
//           top: 0,
//           left: 0,
//           right: 0,
//           child: Consumer<LicenseProvider>(
//             builder: (context, license, _) {
//               return (!license.isSubscribed && license.isTrialActive)
//                   ? TrialBanner()
//                   : SizedBox.shrink();
//             },
//           ),
//         ),

//         if (_isLoading)
//           LoadingOverlay(
//             isLoading: true,
//             message: "Generating Prescription…",
//           )
//       ],
//     );
//   }

//   // ===========================================================
//   // FORM CONTENT — Patientinfo is PERSISTENT
//   // ===========================================================
//   Widget _buildFormContent() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(50),
//         boxShadow: [
//           BoxShadow(
//               color: AppColors.primary.withOpacity(0.3), blurRadius: 20),
//         ],
//       ),
//       child: Form(
//         key: _formKey,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Patientinfo(key: _patientInfoKey),
//             const SizedBox(height: 10),
//             _buildAddMedicineButton(),
//             const SizedBox(height: 20),
//             _buildPrescriptionList(),
//             _buildGeneratePdfButton(),
//             _buildNextPrescriptionButton(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAddMedicineButton() {
//     return Padding(
//       padding: const EdgeInsets.all(8),
//       child: ElevatedButton(
//         onPressed: () => _createPrescription(context),
//         child: const Text('Add Medicine'),
//       ),
//     );
//   }

//   Widget _buildPrescriptionList() {
//     if (_prescriptions.isEmpty) {
//       return const Text("No medicines added yet.");
//     }

//     return ListView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: _prescriptions.length,
//       itemBuilder: (context, index) {
//         final med = _prescriptions[index];
//         return Card(
//           shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(20)),
//           elevation: 5,
//           child: ListTile(
//             title: Text(med.drugName ?? "Unnamed"),
//             subtitle: Text(
//                 "For ${med.followupDuration} ${med.inDays ? "days" : "Months"} | ${med.isBeforeFood ? "Before Food" : "After Food"} | ${med.toBitList(4)}"),
//             trailing: PopupMenuButton<String>(
//               onSelected: (value) {
//                 if (value == 'edit') {
//                   _editPrescription(context, index);
//                 } else if (value == 'delete') {
//                   _deletePrescription(index);
//                 }
//               },
//               itemBuilder: (_) => [
//                 const PopupMenuItem(value: 'edit', child: Text('Edit')),
//                 const PopupMenuItem(value: 'delete', child: Text('Delete')),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildGeneratePdfButton() {
//     return Padding(
//       padding: const EdgeInsets.only(top: 20),
//       child: ElevatedButton.icon(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: _canGeneratePdf ? Colors.blue : Colors.grey,
//         ),
//         onPressed: _canGeneratePdf
//             ? () {
//                 if (_formKey.currentState!.validate() &&
//                     _doctorInfo != null) {
//                   generatePrescriptionPdf(_doctorInfo!);
//                   setState(() => _canGenerateNext = true);
//                 }
//               }
//             : null,
//         icon: const Icon(Icons.picture_as_pdf),
//         label: const Text(
//           "Generate PDF Prescription",
//           style: TextStyle(color: Colors.black),
//         ),
//       ),
//     );
//   }

//   Widget _buildNextPrescriptionButton() {
//     return Padding(
//       padding: const EdgeInsets.only(top: 10),
//       child: ElevatedButton.icon(
//         style: ElevatedButton.styleFrom(
//           backgroundColor:
//               _canGenerateNext ? Colors.redAccent : Colors.grey,
//         ),
//         onPressed: _canGenerateNext
//             ? () {
//                 _resetPrescriptionForm();
//                 setState(() => _canGenerateNext = false);
//               }
//             : null,
//         icon: const Icon(Icons.refresh),
//         label: const Text("Generate Next Prescription",
//             style: TextStyle(color: Colors.black)),
//       ),
//     );
//   }

//   Future<void> _createPrescription(BuildContext context) async {
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(
//           builder: (context) => const AddPrescription(title: "Prescription")),
//     );

//     if (result != null && result is Prescriptiondata) {
//       setState(() => _prescriptions.add(result));
//     }
//   }

//   Future<void> _editPrescription(BuildContext context, int index) async {
//     final existing = _prescriptions[index];
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) =>
//             AddPrescription(title: "Edit Prescription", existingPrescription: existing),
//       ),
//     );

//     if (result != null && result is Prescriptiondata) {
//       setState(() => _prescriptions[index] = result);
//     }
//   }

//   void _deletePrescription(int index) async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Delete Prescription'),
//         content: const Text('Are you sure you want to delete this?'),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
//           TextButton(onPressed: () => Navigator.pop(context, true),
//               child: const Text('Delete', style: TextStyle(color: Colors.red))),
//         ],
//       ),
//     );

//     if (confirm == true) {
//       setState(() => _prescriptions.removeAt(index));
//     }
//   }
// }



import 'dart:convert';
import 'dart:typed_data';
import 'package:docautomations/common/appcolors.dart';
import 'package:docautomations/common/licenseprovider.dart';
import 'package:docautomations/commonwidget/loadingOverlay.dart';
import 'package:docautomations/commonwidget/trialbanner.dart';
import 'package:docautomations/datamodels/prescriptionData.dart';
import 'package:docautomations/services/license_api_service.dart';
import 'package:docautomations/widgets/AddPrescription.dart';
import 'package:docautomations/widgets/PatientInfo.dart';
import 'package:docautomations/widgets/doctorinfo.dart';
import 'package:docautomations/widgets/print_preview_screen.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Addprescriptionscr extends StatefulWidget {
  //final String title;
  const Addprescriptionscr({super.key});

  @override
  State<Addprescriptionscr> createState() => _AddprescriptionscrState();
}

class _AddprescriptionscrState extends State<Addprescriptionscr> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<PatientinfoState> _patientInfoKey = GlobalKey<PatientinfoState>();
  bool _canGeneratePdf = true;


  bool _isLoading = false;
  bool _canGenerateNext = false;
  Uint8List? _doctorLogo;
  DoctorInfo? _doctorInfo;

  final List<Prescriptiondata> _prescriptions = [];

  @override
  void initState() {
    super.initState();
    _loadDoctorInfo();
  }

  // ===================================================================
  //  LOAD DOCTOR PROFILE ONLY ONCE
  // ===================================================================
  Future<void> _loadDoctorInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString("doctor_profile");
    DoctorInfo? doctor;

    if (stored != null) {
      doctor = DoctorInfo.fromJson(jsonDecode(stored));
    } else {
      final apiData = await LicenseApiService.fetchDoctorProfile();
      if (apiData != null) {
        doctor = DoctorInfo.fromJson(apiData["doctor"]);
        await prefs.setString("doctor_profile", jsonEncode(doctor.toJson()));
      }
    }

    if (!mounted) return;
    setState(() {
      _doctorInfo = doctor;
      if (doctor?.logoBase64 != null && doctor!.logoBase64!.isNotEmpty) {
        _doctorLogo = base64Decode(doctor.logoBase64!);
      }
    });
  }

  // ===================================================================
  //  RESET FORM (NO REBUILD OF PATIENTINFO)
  // ===================================================================
  void _resetPrescriptionForm() {
    _prescriptions.clear();
    _patientInfoKey.currentState?.clearFields();
    setState(() {
      _canGenerateNext = false;
    });
  }

  // ===================================================================
  //  GENERATE PDF
  // ===================================================================
  void generatePrescriptionPdf(DoctorInfo doctorInfo) async {
    setState(() => _isLoading = true);

    final p = _patientInfoKey.currentState!;
    final pdf = pw.Document();

    final name = p.tabNameController.text;
    final age = p.ageController.text;
    final gender = p.gender.value;
    final complaints = p.keyComplaintcontroller.text;
    final exam = p.examinationcontroller.text;
    final diagnosis = p.diagnoscontroller.text;
    final remarks = p.remarkscontroller.text;
    final nextDate = p.followupDatecontroller.text;

    final formattedDate = DateFormat('dd/MM/yyyy').format(DateTime.now());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ----------------------------------------------------
              //  Letterhead
              // ----------------------------------------------------
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("Dr. ${doctorInfo.name}",
                          style: pw.TextStyle(
                              fontSize: 20, fontWeight: pw.FontWeight.bold)),
                      pw.Text(doctorInfo.specialization),
                      pw.Text(doctorInfo.clinicAddress),
                      pw.Text("Contact: ${doctorInfo.contact}"),
                    ],
                  ),
                  if (_doctorLogo != null)
                    pw.Container(
                      width: 60,
                      height: 60,
                      child: pw.Image(pw.MemoryImage(_doctorLogo!)),
                    )
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Divider(),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text("Date: $formattedDate"),
                ],
              ),
              pw.SizedBox(height: 10),

              // ----------------------------------------------------
              //  PATIENT INFO
              // ----------------------------------------------------
              pw.Text("Patient Information",
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Text("Patient Name: $name"),
              pw.Text("Age: $age"),
              pw.Text("Gender: $gender"),
              pw.SizedBox(height: 10),

              _section("Key Complaints", complaints),
              _section("Examination", exam),
              _section("Diagnostics", diagnosis),
              _section("Remarks", remarks),
              _section("Next Follow Up Date", nextDate),

              pw.SizedBox(height: 20),

              // ----------------------------------------------------
              //  MEDICINE TABLE
              // ----------------------------------------------------
              pw.Text("Prescribed Medicines:",
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),

              _prescriptions.isEmpty
                  ? pw.Text("No medicines added.")
                  : pw.Table(
                      border: pw.TableBorder.all(),
                      columnWidths: {
        0: pw.FixedColumnWidth(90),   // Medicine
        1: pw.FixedColumnWidth(70),   // Frequency
        2: pw.FixedColumnWidth(90),   // Consumption Pattern
        3: pw.FixedColumnWidth(60),   // Duration
        4: pw.FixedColumnWidth(70),   // Dosage Till Date
        5: pw.FixedColumnWidth(70),   // Remarks
      },
                      children: [
                        pw.TableRow(
                          decoration: pw.BoxDecoration(color: PdfColors.grey300),
                          children: [
                            _cellHeader("Medicine"),
                            _cellHeader("Frequency"),
                            _cellHeader("Consumption "),
                            _cellHeader("Duration"),
                            _cellHeader("Dosage Till Date "),
                            _cellHeader("Remarks"),
                          ],
                        ),
                        ..._prescriptions.map((med) {

                          late bool istabletType;
                          late String unitofmeasure;
                          late String medicinetype;

                          istabletType =med.isTablet ?? true;
                          unitofmeasure = istabletType ? 'mg' : 'ml';
                          medicinetype = istabletType ? 'Tab' : 'Syrup';

                          return pw.TableRow(
                            children: [
                              _cell(medicinetype + ' ' + med.drugName + ' ' + med.drugUnit.toString() + ' '+ unitofmeasure ),
                              _cell(med.toBitList(4).join(" - ")),
                              _cell(med.isBeforeFood ? "Before Food" : "After Food"),
                              _cell("${med.followupDuration} ${med.inDays ? 'Days' : 'Months'}"),
                              _cell(DateFormat('dd/MM/yyyy').format(med.followupdate) ),
                              _cell(med.remarks),
                            ],
                          );
                        })
                      ],
                    ),

              //pw.SizedBox(height: 30),
              //footer
              pw.Spacer(),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text("Signature"),
              ),
               pw.Divider(),
            ],
          );
        },
      ),
    );

    final pdfBytes = await pdf.save();
    await LicenseApiService.incrementPrescriptionCount();

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PrintPreviewScreen(pdfBytes: pdfBytes),
      ),
    );

    setState(() => _isLoading = false);
  }

  pw.Widget _section(String title, String value) {
    if (value.trim().isEmpty) return pw.SizedBox();
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.Text(value),
        pw.SizedBox(height: 10),
      ],
    );
  }

  pw.Widget _cell(String? text) =>
      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(text ?? "", ));

  pw.Widget _cellHeader(String text) => pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(text, style: pw.TextStyle(fontWeight: pw.FontWeight.bold), maxLines: 1,) );

  // ===================================================================
  //  UI BUILD
  // ===================================================================
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // MAIN SCREEN
        Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              const SizedBox(height: 60), // space for banner

              Expanded(
                child: SingleChildScrollView(
                  child: _buildFormContent(),
                ),
              ),
            ],
          ),
        ),

        // TRIAL BANNER — SAFE — DOES NOT REBUILD FORM
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Consumer<LicenseProvider>(
            builder: (context, license, _) {
              return (!license.isSubscribed && license.isTrialActive)
                  ? TrialBanner()
                  : const SizedBox.shrink();
            },
          ),
        ),

        // LOADING OVERLAY
        if (_isLoading)
          LoadingOverlay(isLoading: true, message: "Generating prescription…")
      ],
    );
  }

  // ===================================================================
  //  FORM CONTENT
  // ===================================================================
  Widget _buildFormContent() {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
          )
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Patientinfo(key: _patientInfoKey),

            const SizedBox(height: 20),
            _buildAddMedicineButton(),
            const SizedBox(height: 20),
            _buildPrescriptionList(),
            _buildGeneratePdfButton(),
            _buildNextPrescriptionButton(),
          ],
        ),
      ),
    );
  }

  // ===================================================================
  //  BUTTONS / MEDICINE LIST
  // ===================================================================
  Widget _buildAddMedicineButton() {
    return ElevatedButton(
      onPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AddPrescription(title: "Prescription"),
          ),
        );

        if (result != null && result is Prescriptiondata) {
          setState(() => _prescriptions.add(result));
        }
      },
      child: const Text("Add Medicine"),
    );
  }

  Widget _buildPrescriptionList() {
    late bool istabletType;
    late String unitofmeasure;
    late String medicinetype;
    if (_prescriptions.isEmpty) {
      return const Text("No medicines added yet.");
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _prescriptions.length,
      itemBuilder: (context, i) {
        
        final med = _prescriptions[i];
        istabletType =med.isTablet ?? true;
        unitofmeasure = istabletType ? 'mg' : 'ml';
        medicinetype = istabletType ? 'Tablet' : 'Syrup';

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ListTile(
            title: Text(medicinetype + ' ' + med.drugName + ' ' +  med.drugUnit.toString() + unitofmeasure ?? ""),
            subtitle: Text(
              "For ${med.followupDuration} ${med.inDays ? "Days" : "Months"} | "
              "${med.isBeforeFood ? 'Before Food' : 'After Food'} | "
              "${med.toBitList(4).join(" - ")}",
            ),
            trailing: PopupMenuButton(
              onSelected: (value) {
                if (value == 'edit') {
                   _editPrescription(context, i);
                 } else
                if (value == "delete") {
                  _deletePrescription(i);
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: "delete", child: Text("Delete")),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGeneratePdfButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: _canGeneratePdf ? Colors.blue : Colors.grey,
        ),
        onPressed: _canGeneratePdf
            ? () {
                if (_formKey.currentState!.validate() &&
                    _doctorInfo != null) {
                  generatePrescriptionPdf(_doctorInfo!);
                  setState(() => _canGenerateNext = true);
                }
              }
            : null,
        icon: const Icon(Icons.picture_as_pdf),
        label: const Text(
          "Generate PDF Prescription",
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildNextPrescriptionButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              _canGenerateNext ? Colors.redAccent : Colors.grey,
        ),
        onPressed: _canGenerateNext
            ? () {
                _resetPrescriptionForm();
                setState(() => _canGenerateNext = false);
              }
            : null,
        icon: const Icon(Icons.refresh),
        label: const Text("Generate Next Prescription",
            style: TextStyle(color: Colors.black)),
      ),
    );
  }

    Future<void> _editPrescription(BuildContext context, int index) async {
    final existing = _prescriptions[index];
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddPrescription(title: "Edit Prescription", existingPrescription: existing),
      ),
    );

    if (result != null && result is Prescriptiondata) {
      setState(() => _prescriptions[index] = result);
    }
  }

  void _deletePrescription(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Prescription'),
        content: const Text('Are you sure you want to delete this?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _prescriptions.removeAt(index));
    }
  }
}

  // Widget _buildGeneratePdfButton() {
  //   return ElevatedButton.icon(
  //     icon: const Icon(Icons.picture_as_pdf),
  //     label: const Text("Generate PDF Prescription",
  //         style: TextStyle(color: Colors.black)),
  //     onPressed: () {
  //       if (_formKey.currentState!.validate() && _doctorInfo != null) {
  //         generatePrescriptionPdf(_doctorInfo!);
  //         setState(() => _canGenerateNext = true);
  //       }
  //     },
  //   );
  // }

  // Widget _buildNextPrescriptionButton() {
  //   return ElevatedButton.icon(
  //     icon: const Icon(Icons.refresh),
  //     label: const Text("Generate Next Prescription",
  //         style: TextStyle(color: Colors.black)),
  //     onPressed: _canGenerateNext ? _resetPrescriptionForm : null,
  //     style: ElevatedButton.styleFrom(
  //       backgroundColor:
  //           _canGenerateNext ? Colors.redAccent : Colors.grey.shade400,
  //     ),
  //   );
  // }
//}
