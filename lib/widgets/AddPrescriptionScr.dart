import 'dart:convert';

import 'package:docautomations/common/appcolors.dart';
import 'package:docautomations/common/licenseprovider.dart';
import 'package:docautomations/commonwidget/loadingOverlay.dart';
import 'package:docautomations/commonwidget/trialbanner.dart';
import 'package:docautomations/datamodels/prescriptionData.dart';
import 'package:docautomations/services/license_api_service.dart';
import 'package:docautomations/widgets/AddPrescription.dart';
import 'package:docautomations/widgets/PatientInfo.dart';
import 'package:docautomations/widgets/doctorinfo.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:io' as io; // Needed for File IO;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Addprescriptionscr extends StatefulWidget {
  const Addprescriptionscr({super.key});

  @override
  State<Addprescriptionscr> createState() => _AddprescriptionscrState();
}

class _AddprescriptionscrState extends State<Addprescriptionscr> {
  final _formKey = GlobalKey<FormState>();

final GlobalKey<PatientinfoState> _patientInfoKey = GlobalKey<PatientinfoState>();
bool _canGeneratePdf = true;  // initially enabled
bool _canGenerateNext = false; // initially disabled
bool _isLoading = false;

  final String _patientName = '';
  final String _patientAge = '';
  final String _patientGender = '';
  final String _keycomplaint='';
  final String _examination='';
  final String _diagnosis='';
  // String _doctorName='';
  // String _doctorQualification='';
  // String _doctorAddress='';
  // String _doctorContact='';
  
   Uint8List? _doctorLogo;

  DoctorInfo? _doctorInfo;

final bool _printLetterhead = true; // default true

  @override
  void initState() {
    super.initState();
    _loadDoctorInfo(); // load on widget creation
         
  }

  

Future<void> _loadDoctorInfo() async {
  final prefs = await SharedPreferences.getInstance();
  final stored = prefs.getString("doctor_profile");
  DoctorInfo? doctor;

  if (stored != null) {
    
    doctor = DoctorInfo.fromJson(jsonDecode(stored));
  } else {
     
    final apiData = await LicenseApiService.fetchDoctorProfile();
    if (apiData!= null)
    {
    doctor = DoctorInfo.fromJson(apiData["doctor"]);
    await prefs.setString("doctor_profile", jsonEncode(doctor.toJson()));
    }
    
  }

  
    setState(() {
      _doctorInfo = doctor;
      //Decode logo
      if (_doctorInfo?.logoBase64 != null && _doctorInfo!.logoBase64!.isNotEmpty) {
        _doctorLogo = base64Decode(_doctorInfo!.logoBase64!);
      }
    });
  
}

//   Future<void> _loadDoctorInfo() async {
// final prefs = await SharedPreferences.getInstance();
//   final stored = prefs.getString("doctor_profile");
//   DoctorInfo? doctor;
//   late final doctorData;
//   if (stored != null) 
//     {
//       print("Stored doct $stored" );
//       doctorData = jsonDecode(stored) as Map<String, dynamic>;
//     }
//     else{

//      doctorData = await LicenseApiService.fetchDoctorProfile();
//      await prefs.setString("doctor_profile", jsonEncode(doctorData["doctor"]));
// }

//   if (doctorData != null) {
//     setState(() {
//       _doctorName = "Dr. ${doctorData['name'] ?? ''}";
//       _doctorQualification = doctorData['specialization'] ?? '';
//       _doctorAddress = doctorData['clinicAddress'] ?? '';
//       _doctorContact = doctorData['contact'] ?? '';
//        _printLetterhead = doctorData['printLetterhead'] ?? true; // ✅ fetch

//       // // Decode Base64 logo
//       // if (doctorData['logoBase64'] != null && doctorData['logoBase64'].isNotEmpty) {
//       //   _doctorLogo = base64Decode(doctorData['logoBase64']);
//       // }

//       _doctorInfo = DoctorInfo(
//         name: doctorData['name'] ?? '',
//         specialization: doctorData['specialization'] ?? '',
//         clinicName: doctorData['clinicName'] ?? '',
//         clinicAddress: doctorData['clinicAddress'] ?? '',
//         contact: doctorData['contact'] ?? '',
//         loginEmail: doctorData['loginEmail'] ?? '',
//         password: doctorData['password'] ?? '',
//         logoBase64: doctorData['logoBase64'],
//         printLetterhead: doctorData['printLetterhead'] ?? true,
//         prescriptionCount: doctorData['prescriptionCount'] ?? 0,
//         licensedOnDate: doctorData['licensedOnDate'] != null
//             ? DateTime.tryParse(doctorData['licensedOnDate'])
//             : null,
//         nextRenewalDate: doctorData['nextRenewalDate'] != null
//             ? DateTime.tryParse(doctorData['nextRenewalDate'])
//             : null,
//         firstTimeRegistrationDate: doctorData['firstTimeRegistrationDate'] != null
//             ? DateTime.tryParse(doctorData['firstTimeRegistrationDate'])
//             : null,
//       );

//       // Decode logo
//       if (_doctorInfo?.logoBase64 != null && _doctorInfo!.logoBase64!.isNotEmpty) {
//         _doctorLogo = base64Decode(_doctorInfo!.logoBase64!);
//       }


//     });
//   }
//   }
  

  // Instead of a single prescription, maintain a list
  final List<Prescriptiondata> _prescriptions = [];

  static const descTextStyle = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.w800,
    fontFamily: 'Roboto',
    letterSpacing: 0.5,
    fontSize: 18,
    height: 2,
  );



void _resetPrescriptionForm() {
  setState(() {
    _prescriptions.clear();  // clear medicines
    _patientInfoKey.currentState?.clearFields(); // reset PatientInfo widget fields
  });
}


void generatePrescriptionPdf(DoctorInfo doctorInfo) async {
  setState(() => _isLoading = true);   // show loader
  String doctorName="Dr. ${doctorInfo.name}";
  final pdf = pw.Document();
  final name = _patientInfoKey.currentState?.tabNameController.text ?? '';
  final age = _patientInfoKey.currentState?.ageController.text ?? '';
  final complaints = _patientInfoKey.currentState?.keyComplaintcontroller.text ?? '';
  final examination = _patientInfoKey.currentState?.examinationcontroller.text ?? '';
  final diagnosis = _patientInfoKey.currentState?.diagnoscontroller.text ?? '';
  final selectedGenderval = _patientInfoKey.currentState?.selectedGender.toString() ?? '';
  final nextfollowupdate = _patientInfoKey.currentState?.followupDatecontroller.text ?? '';
  final remarks = _patientInfoKey.currentState?.remarkscontroller.text ?? '';

  final now = DateTime.now();
  final formattedDate = DateFormat('dd/MM/yyyy').format(now);

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            if (_printLetterhead) ...[
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text( doctorName, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                      pw.Text( doctorInfo.specialization ),
                      pw.Text( doctorInfo.clinicAddress),
                      pw.Text("Contact: ${doctorInfo.contact}"),
                    ],
                  ),
                  if (_doctorLogo != null)
                    pw.Container(
                      width: 60,
                      height: 60,
                      child: pw.Image(pw.MemoryImage(_doctorLogo!)),
                    ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Divider(),
            ] else ...[
              pw.SizedBox(height: 100),
              pw.Divider(),
            ],

            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text("Date: $formattedDate", style: pw.TextStyle(fontSize: 14)),
              ],
            ),

            // ✅ Patient Info
            pw.Text("Patient Information", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.Text("Patient Name: $name", style: pw.TextStyle(fontSize: 16)),
            pw.Text("Age: $age", style: pw.TextStyle(fontSize: 16)),
            pw.Text("Gender: $selectedGenderval", style: pw.TextStyle(fontSize: 16)),
            pw.SizedBox(height: 5),

            // ✅ Only show sections if not empty
            if (complaints.trim().isNotEmpty) ...[
              pw.Text("Key Complaints:", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.Text(" $complaints", style: pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 10),
            ],

            if (examination.trim().isNotEmpty) ...[
              pw.Text("Examination:", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.Text(" $examination", style: pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 10),
            ],

            if (diagnosis.trim().isNotEmpty) ...[
              pw.Text("Diagnostics:", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.Text(" $diagnosis", style: pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 10),
            ],

            if (remarks.trim().isNotEmpty) ...[
              pw.Text("Remarks:", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.Text(" $remarks", style: pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 10),
            ],

            if (nextfollowupdate.trim().isNotEmpty) ...[
              pw.Text("Next Follow Up Date:", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.Text(" $nextfollowupdate", style: pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 10),
            ],

            // ✅ Medicines Table
            pw.Text("Prescribed Medicines:", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 5),
            if (_prescriptions.isEmpty)
              pw.Text("No medicines added.")
            else
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey),
                columnWidths: {
                  0: pw.FlexColumnWidth(2),
                  1: pw.FlexColumnWidth(2),
                  2: pw.FlexColumnWidth(2),
                  3: pw.FlexColumnWidth(2),
                  4: pw.FlexColumnWidth(2),
                },
                children: [
                  // Header row
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      pw.Padding(padding: pw.EdgeInsets.all(4), child: pw.Text("Medicine")),
                      pw.Padding(padding: pw.EdgeInsets.all(4), child: pw.Text("Timing")),
                      pw.Padding(padding: pw.EdgeInsets.all(4), child: pw.Text("Food")),
                      pw.Padding(padding: pw.EdgeInsets.all(4), child: pw.Text("Duration")),
                      pw.Padding(padding: pw.EdgeInsets.all(4), child: pw.Text("Remarks")),
                    ],
                  ),
                  // Data rows
                  ..._prescriptions.map((med) {
                    final timeList  = med.toBitList(4);
                    final time = timeList.join(", "); // join list items into one string
                    return pw.TableRow(
                      children: [
                        pw.Padding(padding: pw.EdgeInsets.all(4), child: pw.Text(med.drugName ?? '')),
                        pw.Padding(padding: pw.EdgeInsets.all(4), child: pw.Text(time)),
                        pw.Padding(padding: pw.EdgeInsets.all(4), child: pw.Text(med.isBeforeFood ? 'Before Food' : 'After Food')),
                        pw.Padding(padding: pw.EdgeInsets.all(4), child: pw.Text("${med.followupDuration} ${med.inDays ? 'Days' : 'Months'}")),
                        pw.Padding(padding: pw.EdgeInsets.all(4), child: pw.Text(med.remarks ?? '')),
                      ],
                    );
                  }),
                ],
              ),

            pw.Spacer(),

            // Footer
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text("Signature", style: pw.TextStyle(fontSize: 14)),
            ),
            pw.Divider(),
          ],
        );
      },
    ),
  );

  try {
    await LicenseApiService.incrementPrescriptionCount();
    final pdfBytes = await pdf.save();

    if (kIsWeb) {
      await Printing.layoutPdf(onLayout: (format) async => pdfBytes);
    } else {
      final dir = await getTemporaryDirectory();
      final file = io.File('${dir.path}/prescription.pdf');
      await file.writeAsBytes(pdfBytes);
      await OpenFile.open(file.path);
    }
  } catch (e) {
    print("Error generating or opening PDF: $e");
  }
  finally {
    setState(() => _isLoading = false);  // hide loader
  }
}

@override
Widget build(BuildContext context) {
  return   Consumer<LicenseProvider>(
      builder: (context, license, child) {
        return
   Stack(
    children: [
      Column(children: [
       
      //(!license.isSubscribed && license.isTrialActive) ?
    TrialBanner(),
    //: SizedBox.shrink(), // 👈 Reusable banner


      Expanded(
        
        child: SingleChildScrollView(
          child: Container(
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
            child: Form(
              key: _formKey,
              child: DefaultTextStyle.merge(
                style: descTextStyle,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Patientinfo(key: _patientInfoKey),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: ElevatedButton(
                        onPressed: () {
                          _createPrescription(context);
                        },
                        child: const Text('Add Medicine'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // _prescriptions.isNotEmpty
                    //     ? ListView.builder(
                    //         shrinkWrap: true,
                    //         physics: const NeverScrollableScrollPhysics(),
                    //         itemCount: _prescriptions.length,
                    //         itemBuilder: (context, index) {
                    //           final presc = _prescriptions[index];
                    //           return Card(
                    //             shape: RoundedRectangleBorder(
                    //               borderRadius: BorderRadius.circular(20),
                    //             ),
                    //             elevation: 5,
                    //             margin: const EdgeInsets.symmetric(vertical: 8),
                    //             child: ListTile(
                    //               title: Text(presc.drugName ?? "Unnamed"),
                    //               subtitle: Text(
                    //                 "For ${presc.followupDuration} ${presc.inDays ? "days" : "Months"} | ${presc.isBeforeFood ? "Before Food" : "After Food"} | ${presc.toBitList(4)}",
                    //               ),
                    //               trailing: PopupMenuButton<String>(
                    //                 onSelected: (value) {
                    //                   if (value == 'edit') {
                    //                     _editPrescription(context, index);
                    //                   } else if (value == 'delete') {
                    //                     _deletePrescription(index);
                    //                   }
                    //                 },
                    //                 itemBuilder: (context) => [
                    //                   const PopupMenuItem(
                    //                     value: 'edit',
                    //                     child: Text('Edit'),
                    //                   ),
                    //                   const PopupMenuItem(
                    //                     value: 'delete',
                    //                     child: Text('Delete'),
                    //                   ),
                    //                 ],
                    //               ),
                    //             ),
                    //           );
                    //         },
                    //       )
                    //     : const Text('No medicines added yet.'),
                    _buildPrescriptionList(),
                    
                    // Padding(
                    //   padding: const EdgeInsets.only(top: 20),
                    //   child: ElevatedButton.icon(
                    //     style: ElevatedButton.styleFrom(
                    //       backgroundColor: _canGeneratePdf
                    //           ? Colors.blue
                    //           : Colors.grey,
                    //     ),
                    //     onPressed: _canGeneratePdf
                    //         ? () {
                    //             final isFormValid =
                    //                 _formKey.currentState!.validate();
                    //             if (isFormValid && _doctorInfo != null) {
                    //               generatePrescriptionPdf(_doctorInfo!);
                    //               setState(() {
                    //                 _canGeneratePdf = false;
                    //                 _canGenerateNext = true;
                    //               });
                    //             }
                    //           }
                    //         : null,
                    //     icon: const Icon(Icons.picture_as_pdf),
                    //     label: const Text("Generate PDF Prescription"),
                    //   ),
                    // ),
                    _buildGeneratePdfButton(),
                    // Padding(
                    //   padding: const EdgeInsets.only(top: 10),
                    //   child: ElevatedButton.icon(
                    //     style: ElevatedButton.styleFrom(
                    //       backgroundColor: _canGenerateNext
                    //           ? Colors.redAccent
                    //           : Colors.grey,
                    //     ),
                    //     onPressed: _canGenerateNext
                    //         ? () {
                    //             _resetPrescriptionForm();
                    //             setState(() {
                    //               _canGeneratePdf = true;
                    //               _canGenerateNext = false;
                    //             });
                    //           }
                    //         : null,
                    //     icon: const Icon(Icons.refresh),
                    //     label: const Text("Generate Next Prescription"),
                    //   ),
                    // ),
                    _buildNextPrescriptionButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      // 🔽 Overlay on top when loading
      LoadingOverlay(
        isLoading: _isLoading,
        message: "Generating Prescription……",
      ),
    ],
  ),
  ],);
  });
}

  //@override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: MediaQuery.of(context).size.height,
//       child: SingleChildScrollView(
//         child: Container(
//           padding: const EdgeInsets.all(20),
//           margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(50),
//             boxShadow: [
//               BoxShadow(
//                   color: AppColors.primary.withOpacity(0.3),
//                   blurRadius: 20,
//                   offset: Offset.zero),
//             ],
//           ),
//           child: Form(
//             key: _formKey,
//             child: DefaultTextStyle.merge(
//               style: descTextStyle,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Patientinfo(key: _patientInfoKey),
//                   //  Patientinfo(onChanged: (name, age, gender,keycomplaint,
//                   //   examination, diagnostics) 
//                   //   {
//                   //      setState(() {
//                   //           _patientName = name;
//                   //           _patientAge = age;
//                   //           _patientGender = gender;
//                   //           _keycomplaint=keycomplaint;
//                   //           _examination=examination;
//                   //           _diagnosis=diagnostics;
//                   //   });
//                   //   },),
//                   const SizedBox(height: 10),
//                   Padding(
//                     padding: const EdgeInsets.all(8),
//                     child: ElevatedButton(
//                       onPressed: () {
//                         _createPrescription(context);
//                       },
//                       child: const Text('Add Medicine'),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   // If there are medicines added, show them
//                   _prescriptions.isNotEmpty
//                       ? ListView.builder(
//                           shrinkWrap: true,
//                           physics: const NeverScrollableScrollPhysics(),
//                           itemCount: _prescriptions.length,
//                           itemBuilder: (context, index) {
//                             final presc = _prescriptions[index];
//                             return Card(
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                               elevation: 5,
//                               margin: const EdgeInsets.symmetric(vertical: 8),
//                               child: ListTile(
//                                 title: Text(presc.drugName ?? "Unnamed"),
//                                 subtitle: Text(
//                                     "For ${presc.followupDuration} ${presc.inDays?"days":"Months"}  | ${presc.isBeforeFood ? "Before Food" : "After Food"} | ${presc.toBitList(4)}"),
//                                 trailing: PopupMenuButton<String>(
//                                   onSelected: (value) {
//                                     if (value == 'edit') {
//                                       _editPrescription(context, index);
//                                     } else if (value == 'delete') {
//                                       _deletePrescription(index);
//                                     }
//                                   },
//                                   itemBuilder: (context) => [
//                                     const PopupMenuItem(
//                                       value: 'edit',
//                                       child: Text('Edit'),
//                                     ),
//                                     const PopupMenuItem(
//                                       value: 'delete',
//                                       child: Text('Delete'),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             );
//                           },
//                         )
//                       : const Text('No medicines added yet.'),
// Padding(
//   padding: const EdgeInsets.only(top: 20),
//   child: ElevatedButton.icon(
//     style: ElevatedButton.styleFrom(
//       backgroundColor: _canGeneratePdf ? Colors.blue : Colors.grey, // ✅ greyed out
//     ),
//     onPressed: _canGeneratePdf
//         ? () {
//             final isFormValid = _formKey.currentState!.validate();
//             if (isFormValid && _doctorInfo != null) {
//               generatePrescriptionPdf(_doctorInfo!);
//               setState(() {
//                 _canGeneratePdf = false;   // disable this button
//                 _canGenerateNext = true;   // enable next prescription button
//               });
//             }
//           }
//         : null, // disabled if false
//     icon: const Icon(Icons.picture_as_pdf),
//     label: const Text("Generate PDF Pres  cription"),
//   ),
// ),

// Padding(
//   padding: const EdgeInsets.only(top: 10),
//   child: ElevatedButton.icon(
//     style: ElevatedButton.styleFrom(
//       backgroundColor: _canGenerateNext ? Colors.redAccent : Colors.grey, // ✅ greyed out
//     ),
//     onPressed: _canGenerateNext
//         ? () {
//             _resetPrescriptionForm();
//             setState(() {
//               _canGeneratePdf = true;    // enable PDF button again
//               _canGenerateNext = false;  // disable this one
//             });
//           }
//         : null, // disabled if false
//     icon: const Icon(Icons.refresh),
//     label: const Text("Generate Next Prescription"),
//   ),
// ),



//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

Widget _buildPrescriptionList() {
    // your existing prescription list widget code
    return Container(
    child:   _prescriptions.isNotEmpty
                        ? ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _prescriptions.length,
                            itemBuilder: (context, index) {
                              final presc = _prescriptions[index];
                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 5,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  title: Text(presc.drugName ?? "Unnamed"),
                                  subtitle: Text(
                                    "For ${presc.followupDuration} ${presc.inDays ? "days" : "Months"} | ${presc.isBeforeFood ? "Before Food" : "After Food"} | ${presc.toBitList(4)}",
                                  ),
                                  trailing: PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        _editPrescription(context, index);
                                      } else if (value == 'delete') {
                                        _deletePrescription(index);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Text('Edit'),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Delete'),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          )
                        : const Text('No medicines added yet.'),
    );
  }

  Widget _buildGeneratePdfButton() {
    // your existing generate PDF button code
    return Container(
      child:   Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _canGeneratePdf
                              ? Colors.blue
                              : Colors.grey,
                        ),
                        onPressed: _canGeneratePdf
                            ? () {
                                final isFormValid =
                                    _formKey.currentState!.validate();
                                if (isFormValid && _doctorInfo != null) {
                                  generatePrescriptionPdf(_doctorInfo!);
                                  setState(() {
                                    _canGeneratePdf = false;
                                    _canGenerateNext = true;
                                  });
                                }
                              }
                            : null,
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text("Generate PDF Prescription"),
                      ),
                    ),
    );
  }

  Widget _buildNextPrescriptionButton() {
    // your existing next prescription button code
    return Container(
      child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _canGenerateNext
                              ? Colors.redAccent
                              : Colors.grey,
                        ),
                        onPressed: _canGenerateNext
                            ? () {
                                _resetPrescriptionForm();
                                setState(() {
                                  _canGeneratePdf = true;
                                  _canGenerateNext = false;
                                });
                              }
                            : null,
                        icon: const Icon(Icons.refresh),
                        label: const Text("Generate Next Prescription"),
                      ),
                    ),
    );
  }




  Future<void> _createPrescription(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>  const AddPrescription(title: "Prescription"),
      ),
    );

    if (result != null && result is Prescriptiondata) {
      setState(() {
        _prescriptions.add(result);
      });
      
    }
  }

  Future<void> _editPrescription(BuildContext context, int index) async {
    final existing = _prescriptions[index];
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>  AddPrescription(
          title: "Edit Prescription",existingPrescription: existing
          // You can pass existing data here if your AddPrescription page supports it
        ),
      ),
    );

    if (result != null && result is Prescriptiondata) {
      setState(() {
        _prescriptions[index] = result;
      });
      print("Edited medicine at index $index: ${result.drugName}");
    }
  }

  void _deletePrescription(int index) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Prescription'),
      content: const Text('Are you sure you want to delete this prescription?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );

  if (confirm == true) {
    setState(() {
      _prescriptions.removeAt(index);
    });
    print("Deleted medicine at index $index");
  }
}

}
