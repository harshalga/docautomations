import 'dart:convert';
import 'dart:typed_data';
import 'package:docautomations/common/appcolors.dart';
import 'package:docautomations/common/common_widgets.dart';
import 'package:docautomations/common/licenseprovider.dart';
import 'package:docautomations/common/medicineType.dart';
import 'package:docautomations/commonwidget/loadingOverlay.dart';
import 'package:docautomations/commonwidget/trialbanner.dart';
import 'package:docautomations/datamodels/prescriptionData.dart';
import 'package:docautomations/services/license_api_service.dart';
import 'package:docautomations/widgets/AddPrescription.dart';
import 'package:docautomations/widgets/PatientInfo.dart';
import 'package:docautomations/widgets/doctorinfo.dart';
import 'package:docautomations/widgets/print_preview_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final nameFieldKey = GlobalKey();
  final ageFieldKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  final GlobalKey<PatientinfoState> _patientInfoKey = GlobalKey<PatientinfoState>();

  // Keys for specific form fields INSIDE Patientinfo
final GlobalKey<FormFieldState<String>> _nameFieldKey =
    GlobalKey<FormFieldState<String>>();
final GlobalKey<FormFieldState<String>> _ageFieldKey =
    GlobalKey<FormFieldState<String>>();
  final bool _canGeneratePdf = true;
  bool _printLetterhead = true;

  bool _isLoading = false;
  bool _canGenerateNext = false;
  Uint8List? _doctorLogo;
  DoctorInfo? _doctorInfo;

  /// Medicine type list
  final List<MedicineType> types = [
    MedicineType("Tablet",
    Image.asset(
    "assets/icon/tablet.png",
    width: 28,
    height: 28,
    fit: BoxFit.contain,
  ),
     "mg"),
    MedicineType("Capsule",
     //Icons.medication_liquid
     Image.asset(
    "assets/icon/capsule.png",
    width: 28,
    height: 28,
    fit: BoxFit.contain,
  )
    ,
      "mg"),
    MedicineType("Syrup", 
     Image.asset(
    "assets/icon/bottle.png",
    width: 28,
    height: 28,
    fit: BoxFit.contain,
  )
     
    , "ml"),
    MedicineType("Ointment",
     Image.asset(
    "assets/icon/ointment.png",
    width: 28,
    height: 28,
    fit: BoxFit.contain,
  )
    , "gm"),
    MedicineType("Injection", 
     Image.asset(
    "assets/icon/injection.png",
    width: 28,
    height: 28,
    fit: BoxFit.contain,
  )
    , "ml"),
    MedicineType("Inhalation", 
    
    Image.asset(
    "assets/icon/inhaler.png",
    width: 28,
    height: 28,
    fit: BoxFit.contain,
  )
  , "puffs"),
    MedicineType("Drops", 
     Image.asset(
    "assets/icon/eye-dropper.png",
    width: 28,
    height: 28,
    fit: BoxFit.contain,
  )
    , "drops"),
    MedicineType("Others", 
     Image.asset(
    "assets/icon/first-aid-kit.png",
    width: 28,
    height: 28,
    fit: BoxFit.contain,
  )
    , ""), // no unit needed
  ];

  String _unitForType(String medicine) {
    return types.firstWhere((e) => e.name == medicine).unit;
  }

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
     

    if (stored != null && stored.trim().isNotEmpty) {
      try 
      {
      final data = jsonDecode(stored);
      if (data is Map<String, dynamic>) {
        doctor = DoctorInfo.fromJson(data);
      }
      
      }
      catch(e) {
      print("❌ Corrupted doctor_profile JSON → clearing it");
      prefs.remove("doctor_profile");
    }
    } else {
      final apiData = await LicenseApiService.fetchDoctorProfile();
      if (apiData != null && apiData["doctor"] != null) {
        doctor = DoctorInfo.fromJson(apiData["doctor"]);
        await prefs.setString("doctor_profile", jsonEncode(doctor.toJson()));
      }
    }

    if (!mounted) return;
    setState(() {
      _doctorInfo = doctor;
      if (doctor != null) {
      _printLetterhead = doctor.printLetterhead ?? true ;
      
      if (doctor.logoBase64 != null && doctor.logoBase64!.isNotEmpty) {
       // _doctorLogo =  base64Decode(doctor.logoBase64!);
       final base64String = doctor.logoBase64!;

        // Remove prefix safely
        final cleaned = base64String.contains(',')
            ? base64String.split(',')[1]
            : base64String;

        _doctorLogo = base64Decode(cleaned);   // <-- Pure bytes for MemoryImage
      }
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


//Generate pdf 
void generatePrescriptionPdf(DoctorInfo doctorInfo) async {
  setState(() => _isLoading = true);

  final p = _patientInfoKey.currentState!;
  final pdf = pw.Document();

  // Load Unicode-safe fonts
  final fontRegular = pw.Font.ttf(await rootBundle.load("assets/fonts/Roboto-Regular.ttf"));
  final fontBold = pw.Font.ttf(await rootBundle.load("assets/fonts/Roboto-Bold.ttf"));

  final theme = pw.ThemeData.withFont(
    base: fontRegular,
    bold: fontBold,
  );

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
    pw.MultiPage(
      theme: theme,
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(24),

      // ---------------------------------------------------------
      // HEADER (NO DATE here, ever)
      // ---------------------------------------------------------
      header: (context) {
        if (!_printLetterhead) {
          // No letterhead → but keep spacing + divider
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(height: 100),
              pw.Divider(),
            ],
          );
        }

        // Letterhead enabled
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "Dr. ${doctorInfo.name}",
                      style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 2),
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
                  ),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Divider(),
          ],
        );
      },

      // ---------------------------------------------------------
      // FOOTER (only last page)
      // ---------------------------------------------------------
      footer: (context) => context.pageNumber == context.pagesCount
          ? pw.Column(children: [
              pw.Divider(),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  "Signature",
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
              ),
            ])
          : pw.SizedBox(),

      // ---------------------------------------------------------
      // PAGE BODY (Date goes here)
      // ---------------------------------------------------------
      build: (context) => [
        // Print date ONLY here (never in header)
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            "Date: $formattedDate",
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
        ),

        pw.SizedBox(height: 20),

        // PATIENT INFO
        pw.Text(
          "Patient Information",
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 5),
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

        // MEDICINE TABLE
        pw.Text("Prescribed Medicines",
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),

        _prescriptions.isEmpty
            ? pw.Text("No medicines added.")
            : pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: pw.FixedColumnWidth(100),
                  1: pw.FixedColumnWidth(70),
                  2: pw.FixedColumnWidth(80),
                  3: pw.FixedColumnWidth(60),
                  4: pw.FixedColumnWidth(70),
                  5: pw.FixedColumnWidth(70),
                },
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      _cellHeader("Medicine"),
                      _cellHeader("Freq."),
                      _cellHeader("Consumption"),
                      _cellHeader("Duration"),
                      _cellHeader("Consume Till Date"),
                      _cellHeader("Remarks"),
                    ],
                  ),

                  ..._prescriptions.map((med) {
                    final isTablet = med.isTablet;
                    final unit = _unitForType(med.medicineType.toString());
                    final doseValue = med.drugUnit?.toString() ?? "";
                    final unitValue =
                        (med.medicineType == "Ointment" || med.medicineType == "Others")
                            ? ""
                            : unit;

                    final consumption =
                        isTablet ? (med.isBeforeFood ? "Before Food" : "After Food") : "NA";

                    return pw.TableRow(
                      children: [
                        _cell("${med.medicineType} ${med.drugName} $doseValue $unitValue"),
                        _cell(med.toBitList(4).join(" - ")),
                        _cell(consumption),
                        _cell("${med.followupDuration} ${med.inDays ? 'Days' : 'Months'}"),
                        _cell(DateFormat('dd/MM/yyyy').format(med.followupdate)),
                        _cell(med.remarks),
                      ],
                    );
                  }),
                ],
              ),
      ],
    ),
  );

  // Save and show preview
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
                  controller: _scrollController,
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
            Patientinfo(key: _patientInfoKey , 
            nameFieldKey: _nameFieldKey,
            ageFieldKey: _ageFieldKey,),

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
    late String? medicinetype;
    late String displayConsumption;
    if (_prescriptions.isEmpty) {
      return const Text("No medicines added yet.");
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _prescriptions.length,
      itemBuilder: (context, i) {
        
        final med = _prescriptions[i];
        istabletType =med.isTablet ;
        unitofmeasure =  _unitForType(med.medicineType.toString());//istabletType ? 'mg' : 'ml';
        medicinetype = med.medicineType; //istabletType ? 'Tablet' : 'Syrup';
        if (istabletType)
        {
          displayConsumption =  "For ${med.followupDuration} ${med.inDays ? "Days" : "Months"} | "
              "${med.isBeforeFood ? 'Before Food' : 'After Food'} | "
              "${med.toBitList(4).join(" - ")}";
        }
        else
        {
          displayConsumption =  "For ${med.followupDuration} ${med.inDays ? "Days" : "Months"} | "
              
              "${med.toBitList(4).join(" - ")}";
        }

         late String doseValue = (med.drugUnit?.toString() ?? "");
         late String unitValue = med.medicineType == "Ointment" || med.medicineType == "Others"
                            ? ""
                            : (unitofmeasure);


        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ListTile(
            title: Text('$medicinetype ${med.drugName} $doseValue $unitValue'),
            subtitle: Text(
              displayConsumption,
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
            ? () async{
                    final isValid = _formKey.currentState!.validate();

                    if (!isValid) {
                       await _scrollToFirstError();
                      return;
                    }

                    // ⚠️ WARNING IF NO MEDICINES ADDED
        if (_prescriptions.isEmpty) {
          final proceed = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("No medicines added"),
              content: const Text(
                  "You have not added any medicines.\n\nDo you still want to generate the prescription PDF?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("Generate Anyway"),
                ),
              ],
            ),
          );

          if (proceed != true) return;
        }


                    if (_doctorInfo != null) {
                      generatePrescriptionPdf(_doctorInfo!);
                      setState(() => _canGenerateNext = true);
                    }

                // if (_formKey.currentState!.validate() &&
                //     _doctorInfo != null) {
                //   generatePrescriptionPdf(_doctorInfo!);
                //   setState(() => _canGenerateNext = true);
                // }
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

 Future<void> _scrollToFirstError() async {
  // Let Flutter paint the error messages first
  await Future.delayed(const Duration(milliseconds: 100));

  // Fields in the order you want to check
  final fieldKeys = <GlobalKey<FormFieldState<String>>>[
    _nameFieldKey,
    _ageFieldKey,
    
  ];

  for (final key in fieldKeys) {
    final state = key.currentState;
    final context = key.currentContext;

    if (state != null && state.hasError && context != null) {
      await Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.3, // keeps field slightly below top
      );
      return;
    }
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
