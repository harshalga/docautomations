import 'dart:convert';

import 'package:docautomations/common/appcolors.dart';
import 'package:docautomations/datamodels/prescriptionData.dart';
import 'package:docautomations/main.dart';
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
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Addprescriptionscr extends StatefulWidget {
  const Addprescriptionscr({super.key});

  @override
  State<Addprescriptionscr> createState() => _AddprescriptionscrState();
}

class _AddprescriptionscrState extends State<Addprescriptionscr> {
  final _formKey = GlobalKey<FormState>();

final GlobalKey<PatientinfoState> _patientInfoKey = GlobalKey<PatientinfoState>();


  final String _patientName = '';
  final String _patientAge = '';
  final String _patientGender = '';
  final String _keycomplaint='';
  final String _examination='';
  final String _diagnosis='';
  String _doctorName='';
  String _doctorQualification='';
  String _doctorAddress='';
  String _doctorContact='';
  Uint8List? _doctorLogo;

  DoctorInfo? _doctorInfo;

bool _printLetterhead = true; // default true

  @override
  void initState() {
    super.initState();
    _loadDoctorInfo(); // load on widget creation
     
  }
  Future<void> _loadDoctorInfo() async {
    final doctorData = await LicenseApiService.fetchDoctorProfile();

  if (doctorData != null) {
    setState(() {
      _doctorName = "Dr. ${doctorData['name'] ?? ''}";
      _doctorQualification = doctorData['specialization'] ?? '';
      _doctorAddress = doctorData['clinicAddress'] ?? '';
      _doctorContact = doctorData['contact'] ?? '';
       _printLetterhead = doctorData['printLetterhead'] ?? true; // ✅ fetch

      // // Decode Base64 logo
      // if (doctorData['logoBase64'] != null && doctorData['logoBase64'].isNotEmpty) {
      //   _doctorLogo = base64Decode(doctorData['logoBase64']);
      // }

      _doctorInfo = DoctorInfo(
        name: doctorData['name'] ?? '',
        specialization: doctorData['specialization'] ?? '',
        clinicName: doctorData['clinicName'] ?? '',
        clinicAddress: doctorData['clinicAddress'] ?? '',
        contact: doctorData['contact'] ?? '',
        loginEmail: doctorData['loginEmail'] ?? '',
        password: doctorData['password'] ?? '',
        logoBase64: doctorData['logoBase64'],
        printLetterhead: doctorData['printLetterhead'] ?? true,
        prescriptionCount: doctorData['prescriptionCount'] ?? 0,
        licensedOnDate: doctorData['licensedOnDate'] != null
            ? DateTime.tryParse(doctorData['licensedOnDate'])
            : null,
        nextRenewalDate: doctorData['nextRenewalDate'] != null
            ? DateTime.tryParse(doctorData['nextRenewalDate'])
            : null,
        firstTimeRegistrationDate: doctorData['firstTimeRegistrationDate'] != null
            ? DateTime.tryParse(doctorData['firstTimeRegistrationDate'])
            : null,
      );

      // Decode logo
      if (_doctorInfo?.logoBase64 != null && _doctorInfo!.logoBase64!.isNotEmpty) {
        _doctorLogo = base64Decode(_doctorInfo!.logoBase64!);
      }


    });
  }
  }

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
void generatePrescriptionPdf(DoctorInfo doctorInfo) async {
  // 1️⃣ Increment the prescription count
  // final updatedDoctor = doctorInfo.copyWith(
  //   prescriptionCount: (doctorInfo.prescriptionCount ?? 0) + 1,
  // );

  final pdf = pw.Document();
  final imageLogo = await imageFromAssetBundle('images/DrLogo.png');
  final name = _patientInfoKey.currentState?.tabNameController.text ?? '';
  final age =  _patientInfoKey.currentState?.ageController.text ?? '';
  final complaints = _patientInfoKey.currentState?.keyComplaintcontroller.text ?? '';
  final examination = _patientInfoKey.currentState?.examinationcontroller.text ?? '';
  final diagnosis = _patientInfoKey.currentState?.diagnoscontroller.text ?? '';
  final selectedGenderval = _patientInfoKey.currentState?.selectedGender.toString()??'';
  final nextfollowupdate = _patientInfoKey.currentState?.followupDatecontroller.text ?? '';
  final remarks = _patientInfoKey.currentState?.remarkscontroller.text ?? '';
  
  late DateTime now;
  now = DateTime.now();
  String formattedDate = DateFormat('dd/MM/yyyy').format(now);
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            if (_printLetterhead) ...[   // ✅ conditionally render
            // Header section
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                //pw.Text("Clinic Name", style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
                pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(_doctorName, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                pw.Text(_doctorQualification),
                pw.Text(_doctorAddress),
                pw.Text("Contact:$_doctorContact"),
              ],
            ),
             if (_doctorLogo != null)
                pw.Container(
                  width: 60,
                  height: 60,
                  color: PdfColors.grey300, // Placeholder for logo
                  //child: pw.Center(child: pw.Image(imageLogo)),//Text("Logo")),
                  child: pw.Center(child:pw.Image(pw.MemoryImage(_doctorLogo!))),//Text("Logo")),
                ),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Divider(),
             ] else ...[
  // ✅ reserve same vertical space for pre-printed letterhead
  pw.SizedBox(height: 100),   // adjust height to match your header block
  pw.Divider(),
],
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
              pw.Text("Date: $formattedDate", style: pw.TextStyle(fontSize: 14)),
              ]
            ),
            // Patient Info
            pw.Text("Patient Information", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.Text("Patient Name: $name", style: pw.TextStyle(fontSize: 16)),
            pw.Text("Age: $age", style: pw.TextStyle(fontSize: 16)),
            pw.Text("Gender: $selectedGenderval", style: pw.TextStyle(fontSize: 16)),
            pw.SizedBox(height: 5),
            pw.Text("Key Complaints:", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.Text(" $complaints", style: pw.TextStyle(fontSize: 14)),
            pw.SizedBox(height: 10),
            pw.Text("Examination:", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.Text(" $examination", style: pw.TextStyle(fontSize: 14)),
            pw.SizedBox(height: 10),
            pw.Text("Diagnostics:", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.Text(" $diagnosis", style: pw.TextStyle(fontSize: 14)),
            pw.SizedBox(height: 10),
            pw.Text("Remarks:", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.Text(" $remarks", style: pw.TextStyle(fontSize: 14)),
            pw.SizedBox(height: 10),
            pw.Text("Next Follow Up Date :", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.Text(" $nextfollowupdate", style: pw.TextStyle(fontSize: 14)),
            pw.SizedBox(height: 10),

            // Medicines
            pw.Text("Prescribed Medicines:", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 5),
            if (_prescriptions.isEmpty)
              pw.Text("No medicines added."),
            ..._prescriptions.map((med) {
              final time = med.toBitList(4);
              return pw.Bullet(
                  text: "${med.drugName ?? ''} - $time  - ${med.isBeforeFood ? 'Before Food' : 'After Food'} - ${med.followupDuration} ${med.inDays ? 'Days' : 'Months'} - ${med.remarks ?? ''}");
            }),

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

  //await Printing.layoutPdf(onLayout: (format) async => pdf.save());
try
{
  // final output = await getTemporaryDirectory();
  // final file = File('${output.path}/prescription.pdf');
  // await file.writeAsBytes(await pdf.save());

  // OpenFile.open(file.path);
  // await Printing.layoutPdf(
  // onLayout: (PdfPageFormat format) async => pdf.save(),

  // 3️⃣ Save updated doctor info back to server
 // await LicenseApiService.updateDoctorOnServer(updatedDoctor);
 print("before pdf save and actually calling LicenseApiService.incrementPrescriptionCount");
await LicenseApiService.incrementPrescriptionCount();
  final pdfBytes = await pdf.save();

    if (kIsWeb) {
      // Web: Show print dialog or download
      await Printing.layoutPdf(onLayout: (format) async => pdfBytes);
      // OR use sharePdf to offer download
      // await Printing.sharePdf(bytes: pdfBytes, filename: 'prescription.pdf');
    } else {
      // Android/iOS/Desktop
      final dir = await getTemporaryDirectory();
      final file = io.File('${dir.path}/prescription.pdf');
      await file.writeAsBytes(pdfBytes);
      await OpenFile.open(file.path);
    }




}
catch(e)
{print("Error generating or opening PDF: $e");}
}

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
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
                  offset: Offset.zero),
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
                  //  Patientinfo(onChanged: (name, age, gender,keycomplaint,
                  //   examination, diagnostics) 
                  //   {
                  //      setState(() {
                  //           _patientName = name;
                  //           _patientAge = age;
                  //           _patientGender = gender;
                  //           _keycomplaint=keycomplaint;
                  //           _examination=examination;
                  //           _diagnosis=diagnostics;
                  //   });
                  //   },),
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
                  // If there are medicines added, show them
                  _prescriptions.isNotEmpty
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
                                    "For ${presc.followupDuration} ${presc.inDays?"days":"Months"}  | ${presc.isBeforeFood ? "Before Food" : "After Food"} | ${presc.toBitList(4)}"),
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

                      Padding(
  padding: const EdgeInsets.only(top: 20),
  child: ElevatedButton.icon(
    onPressed: (){
      final isFormValid = _formKey.currentState!.validate();
      if (isFormValid)
       {
         // generatePrescriptionPdf(_doctorInfo!);  
          if (_doctorInfo != null) {
  generatePrescriptionPdf(_doctorInfo!);
}         
       }

    }
    ,
    icon: const Icon(Icons.picture_as_pdf),
    label: const Text("Generate PDF Prescription"),
  ),
),
                ],
              ),
            ),
          ),
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
      print("Added medicine: ${result.drugName}");
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
