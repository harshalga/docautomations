

//Multipage 

import 'dart:typed_data';
import 'dart:convert';

import 'package:docautomations/datamodels/master/prescription_theme.dart';
import 'package:docautomations/device_assets/asset_type.dart';
import 'package:docautomations/device_assets/asset_manager.dart';
import 'package:flutter/material.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:docautomations/datamodels/snapshot/prescription_snapshot.dart';
import 'package:docautomations/datamodels/prescriptionData.dart';

import 'package:docautomations/datamodels/response/doctor_profile.dart';

class PrescriptionPdfService {
  final AssetManager assetManager;

  const PrescriptionPdfService({
    required this.assetManager,
  });

  //--------------------------------------------------------------------------
  // Load Doctor Image From Local Cache
  //--------------------------------------------------------------------------

  Future<Uint8List?> _loadDoctorImage({
    required String doctorId,
    required AssetType assetType,
  }) async {
    final bytes = await assetManager.loadAsset(
      doctorId,
      assetType,
    );

    if (bytes == null || bytes.isEmpty) {
      return null;
    }

    return Uint8List.fromList(bytes);
  }

String _stringValue(dynamic value) {
  if (value == null) {
    return "-";
  }

  if (value is DateTime) {
    return _formatDate(value);
  }

  return value.toString();
}

pw.Widget _chiefComplaintWithVitals(
  PrescriptionSnapshotData prescription,
) {
  final vitals = <String>[];

  // ---------------------------------------------------------------------
  // HEIGHT
  // ---------------------------------------------------------------------

  if (prescription.heightCm != null) {
    final totalInches =
        prescription.heightCm! / 2.54;

    int feet = totalInches ~/ 12;

    int inches =
        (totalInches - (feet * 12)).round();

    // Normalize 12 inches to the next foot.
    if (inches == 12) {
      feet++;
      inches = 0;
    }

    vitals.add(
      "Height: $feet'${inches}\"",
    );
  }

  // ---------------------------------------------------------------------
  // WEIGHT
  // ---------------------------------------------------------------------

  if (prescription.weightKg != null) {
    vitals.add(
      "Weight: ${prescription.weightKg!.toStringAsFixed(1)} kg",
    );
  }

  // ---------------------------------------------------------------------
  // BLOOD PRESSURE
  // ---------------------------------------------------------------------

  if (prescription.systolicBP != null ||
      prescription.diastolicBP != null) {
    final systolic =
        prescription.systolicBP?.toString() ?? "-";

    final diastolic =
        prescription.diastolicBP?.toString() ?? "-";

    vitals.add(
      "BP: $systolic/$diastolic mmHg",
    );
  }

  // ---------------------------------------------------------------------
  // CHIEF COMPLAINT + VITALS
  // ---------------------------------------------------------------------

  return pw.Padding(
    padding: const pw.EdgeInsets.only(
      bottom: 7,
    ),
    child: pw.Row(
      crossAxisAlignment:
          pw.CrossAxisAlignment.start,
      children: [

        // ===============================================================
        // LEFT SIDE - CHIEF COMPLAINT
        // ===============================================================

        pw.Expanded(
          flex: 3,
          child: pw.Column(
            crossAxisAlignment:
                pw.CrossAxisAlignment.start,
            children: [

              // Heading
              pw.Text(
                "Chief Complaint",
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 2),

              // Details below heading
              pw.Text(
                prescription.chiefComplaint.isEmpty
                    ? "-"
                    : prescription.chiefComplaint,
                style: const pw.TextStyle(
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),

        // ===============================================================
        // RIGHT SIDE - VITALS
        // ===============================================================

        if (vitals.isNotEmpty)
          pw.Expanded(
            flex: 1,
            child: pw.Column(
              crossAxisAlignment:
                  pw.CrossAxisAlignment.end,
              children: vitals.map(
                (value) {
                  return pw.Padding(
                    padding:
                        const pw.EdgeInsets.only(
                      bottom: 2,
                    ),
                    child: pw.Text(
                      value,
                      style: const pw.TextStyle(
                        fontSize: 8,
                      ),
                    ),
                  );
                },
              ).toList(),
            ),
          ),
      ],
    ),
  );
}


  // ===========================================================================
  // PUBLIC API
  // ===========================================================================


  

  Future<Uint8List> generatePrescriptionPdf({
    required String doctorId,
    required DoctorProfile doctorProfile,
    required PrescriptionSnapshot snapshot,
    required PrescriptionTheme? selectedTheme,
    String? prescriptionQrData,
    required String prescriptionDate,
  }) async {
    final layout = snapshot.layout;
    final pageFormat = _getPageFormat(layout.pageSize);

    // -----------------------------------------------------------------------
    // LOAD DOCTOR LOGO AND SIGNATURE
    // -----------------------------------------------------------------------

    final logoBytes = await _loadDoctorImage(
      doctorId: doctorId,
      assetType: AssetType.logo,
    );

    final signatureBytes = await _loadDoctorImage(
      doctorId: doctorId,
      assetType: AssetType.signature,
    );

    // -----------------------------------------------------------------------
    // LOAD THEME HEADER AND FOOTER IMAGES
    // -----------------------------------------------------------------------

    final headerImage = _loadThemeImage(
      selectedTheme,
      isHeader: true,
    );

    final footerImage = _loadThemeImage(
      selectedTheme,
      isHeader: false,
    );

    // -----------------------------------------------------------------------
    // PATIENT QR CODE
    // -----------------------------------------------------------------------

    final qrCode =
        layout.showPrescriptionQRCode &&
                prescriptionQrData != null &&
                prescriptionQrData.trim().isNotEmpty
            ? pw.BarcodeWidget(
                barcode: pw.Barcode.qrCode(),
                data: prescriptionQrData,
                width: 65,
                height: 65,
              )
            : null;

    final document = pw.Document();

    final headerHeight = _cmToPoints(layout.headerHeightCm);
    final footerHeight = _cmToPoints(layout.footerHeightCm);
    final topMargin = _cmToPoints(layout.topMarginCm);
    final bottomMargin = _cmToPoints(layout.bottomMarginCm);
    final leftMargin = _cmToPoints(layout.leftMarginCm);
    final rightMargin = _cmToPoints(layout.rightMarginCm);

    // Space reserved for the signature area. The signature is drawn only
    // on the final page; the same space is reserved on all pages to keep
    // the prescription content from colliding with the footer.
    const signatureAreaHeight = 58.0;

    document.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,

        margin: pw.EdgeInsets.only(
          // Full-width header/footer; body horizontal margins are applied
          // separately to the flowing content.
          left: 0,
          right: 0,
          top: topMargin,
          bottom: footerHeight + bottomMargin,
        ),

        // -------------------------------------------------------------------
        // REPEATING HEADER: THEME IMAGE + DOCTOR INFORMATION + LOGO
        // -------------------------------------------------------------------

        header: (context) {
          if (layout.printLetterHead) {
            return pw.SizedBox();
          }

          return _buildMultiPageHeader(
            doctorProfile: doctorProfile,
            logoBytes: logoBytes,
            headerImage: headerImage,
            headerHeight: headerHeight,
            leftMargin: leftMargin,
            rightMargin: rightMargin,
          );
        },

        // -------------------------------------------------------------------
        // REPEATING FOOTER: BACKGROUND + PAGE NUMBER
        // SIGNATURE: FINAL PAGE ONLY
        // -------------------------------------------------------------------

        footer: (context) {
          return _buildMultiPageFooter(
            context: context,
            printLetterHead: layout.printLetterHead,
            footerImage: footerImage,
            footerHeight: footerHeight,
            rightMargin: rightMargin,
          );
        },

        // -------------------------------------------------------------------
        // FLOWING BODY
        // Return individual widgets so MultiPage can paginate between them.
        // -------------------------------------------------------------------

        build: (context) {
          return _buildMultiPageBody(
            snapshot: snapshot,
            prescriptionDate: prescriptionDate,
            qrCode: qrCode,
            printSignature: layout.printSignature,
            signatureBytes: signatureBytes,
            leftMargin: leftMargin,
            rightMargin: rightMargin,
          );
        },
      ),
    );

    return document.save();
  }

  // ===========================================================================
  // MULTI-PAGE HEADER
  // ===========================================================================

  pw.Widget _buildMultiPageHeader({
    required DoctorProfile doctorProfile,
    Uint8List? logoBytes,
    pw.MemoryImage? headerImage,
    required double headerHeight,
    required double leftMargin,
    required double rightMargin,
  }) {
    // With MultiPage horizontal margins set to zero, this header spans the
    // entire physical page width. Doctor information remains inset.
    return pw.Container(
      height: headerHeight,
      width: double.infinity,
      child: pw.Stack(
        children: [
          if (headerImage != null)
            pw.Positioned.fill(
              child: pw.Image(
                headerImage,
                fit: pw.BoxFit.fill,
              ),
            ),
          pw.Positioned(
            left: leftMargin + 5,
            right: rightMargin + 5,
            top: 5,
            bottom: 5,
            child: _buildDoctorHeader(doctorProfile, logoBytes),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildMultiPageFooter({
    required pw.Context context,
    required bool printLetterHead,
    pw.MemoryImage? footerImage,
    required double footerHeight,
    required double rightMargin,
  }) {
    // Full-width footer background. Page number remains inset from the edge.
    return pw.Container(
      height: footerHeight,
      width: double.infinity,
      child: pw.Stack(
        children: [
          if (!printLetterHead && footerImage != null)
            pw.Positioned.fill(
              child: pw.Image(
                footerImage,
                fit: pw.BoxFit.fill,
              ),
            ),
          pw.Positioned(
            right: rightMargin + 5,
            bottom: 5,
            child: pw.Text(
              "Page ${context.pageNumber}",
              style: const pw.TextStyle(fontSize: 8),
            ),
          ),
        ],
      ),
    );
  }

  List<pw.Widget> _buildMultiPageBody({
    required PrescriptionSnapshot snapshot,
    required String prescriptionDate,
    required pw.BarcodeWidget? qrCode,
    required bool printSignature,
    Uint8List? signatureBytes,
    required double leftMargin,
    required double rightMargin,
  }) {
    final patient = snapshot.patient;
    final prescription = snapshot.prescription;

    pw.Widget inset(pw.Widget child) => pw.Padding(
          padding: pw.EdgeInsets.only(left: leftMargin, right: rightMargin),
          child: child,
        );

    return [
      inset(
        pw.Text(
          prescriptionDate,
          style: const pw.TextStyle(fontSize: 10),
        ),
      ),
      pw.SizedBox(height: 8),
      inset(_buildPatientInformation(patient, qrCode)),
      pw.SizedBox(height: 10),
      inset(_buildConsultation(prescription)),
      pw.SizedBox(height: 10),
      inset(_buildMedicineTable(prescription.medicines)),
      if (printSignature && signatureBytes != null) ...[
        pw.SizedBox(height: 12),
        inset(
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: _buildSignature(signatureBytes),
          ),
        ),
      ],
    ];
  }

//===============================================================================
//Build Header
//===============================================================================
pw.Widget _buildDoctorHeader(
  DoctorProfile doctorProfile,
  Uint8List? logoBytes,
) {
  final doctor = doctorProfile.doctor;

  final address = [
    doctor.clinicAddress,
    doctor.city,
    doctor.district,
    doctor.state,
    doctor.pinCode,
  ].where((value) => value.trim().isNotEmpty).join(", ");

  final qualifications = [
    doctor.qualification,
    doctor.specialization,
  ].where((value) => value.trim().isNotEmpty).join(" | ");

  final contacts = [
    if (doctor.mobileNumber.trim().isNotEmpty)
      "Contact: ${doctor.mobileNumber}",
    if (doctor.alternateMobileNumber.trim().isNotEmpty)
      "Alt: ${doctor.alternateMobileNumber}",
    if (doctor.loginEmail.trim().isNotEmpty)
      doctor.loginEmail,
    if (doctor.website.trim().isNotEmpty)
      doctor.website,
  ].join(" | ");

  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      // ---------------------------------------------------------------
      // DOCTOR / CLINIC INFORMATION
      // ---------------------------------------------------------------

      pw.Expanded(
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            if (doctor.clinicName.isNotEmpty)
              pw.Text(
                doctor.clinicName,
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

            if (doctor.doctorName.isNotEmpty)
              pw.Text(
                doctor.doctorName,
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

            if (qualifications.isNotEmpty)
              pw.Text(
                qualifications,
                style: const pw.TextStyle(fontSize: 8),
              ),

            if (address.isNotEmpty)
              pw.Text(
                address,
                style: const pw.TextStyle(fontSize: 7),
              ),

            if (contacts.isNotEmpty)
              pw.Text(
                contacts,
                style: const pw.TextStyle(fontSize: 7),
              ),

            if (doctor.medicalRegistrationNumber.isNotEmpty)
              pw.Text(
                "Registration No: "
                "${doctor.medicalRegistrationNumber}",
                style: const pw.TextStyle(fontSize: 7),
              ),
          ],
        ),
      ),

      // ---------------------------------------------------------------
      // LOGO - TOP RIGHT
      // ---------------------------------------------------------------

      if (logoBytes != null)
        pw.Container(
          width: 60,
          height: 60,
          alignment: pw.Alignment.topRight,
          child: pw.Image(
            pw.MemoryImage(logoBytes),
            fit: pw.BoxFit.contain,
          ),
        ),
    ],
  );
}
  



  // ===========================================================================
  // PATIENT
  // ===========================================================================
pw.Widget _buildPatientInformation(
  PatientSnapshot patient,
  pw.BarcodeWidget? qrCode,
) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(8),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(
        color: PdfColors.grey400,
        width: 0.5,
      ),
    ),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // -------------------------------------------------------------
        // PATIENT INFORMATION
        // -------------------------------------------------------------

        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                patient.fullName,
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 5),

              pw.Row(
                children: [
                  pw.Expanded(
                    child: _infoText(
                      "PPID",
                      patient.ppid,
                    ),
                  ),
                  pw.Expanded(
                    child: _infoText(
                      "Gender",
                      patient.gender,
                    ),
                  ),
                  pw.Expanded(
                    child: _infoText(
                      "DOB",
                      _stringValue(patient.dob),
                    ),
                  ),
                  pw.Expanded(
                    child: _infoText(
                      "Age",
                      _stringValue(patient.ageAtVisit),
                    ),
                  ),
                ],
              ),

              if (patient.bloodGroup != null &&
                  patient.bloodGroup!.isNotEmpty)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 4),
                  child: _infoText(
                    "Blood Group",
                    patient.bloodGroup!,
                  ),
                ),

              if (patient.mobile.isNotEmpty ||
                  patient.loginEmail.isNotEmpty)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 4),
                  child: pw.Row(
                    children: [
                      if (patient.mobile.isNotEmpty)
                        pw.SizedBox(
                          width: 200,
                          child: _infoText(
                            "Mobile",
                            patient.mobile,
                          ),
                        ),

                      if (patient.loginEmail.isNotEmpty)
                        pw.Expanded(
                          child: _infoText(
                            "Email",
                            patient.loginEmail,
                          ),
                        ),
                    ],
                  ),
                ),

              if (patient.addressLine1.isNotEmpty ||
                  patient.addressLine2.isNotEmpty)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 4),
                  child: _infoText(
                    "Address",
                    [
                      patient.addressLine1,
                      patient.addressLine2,
                      patient.city,
                      patient.state,
                      patient.country,
                      patient.pinCode,
                    ]
                        .where(
                          (value) => value.trim().isNotEmpty,
                        )
                        .join(", "),
                  ),
                ),
            ],
          ),
        ),

        // -------------------------------------------------------------
        // QR CODE - RIGHT SIDE
        // -------------------------------------------------------------

        if (qrCode != null)
          pw.Container(
            width: 75,
            margin: const pw.EdgeInsets.only(left: 8),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                qrCode,

                pw.SizedBox(height: 2),

                pw.Text(
                  "Patient QR",
                  style: const pw.TextStyle(
                    fontSize: 7,
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}
 

  // ===========================================================================
  // CONSULTATION
  // ===========================================================================


pw.Widget _buildConsultation(
  PrescriptionSnapshotData prescription,
) {
  final rows = <pw.Widget>[];

  // ---------------------------------------------------------------------
  // CHIEF COMPLAINT + VITALS
  // ---------------------------------------------------------------------

  if (prescription.chiefComplaint.isNotEmpty ||
      prescription.heightCm != null ||
      prescription.weightKg != null ||
      prescription.systolicBP != null ||
      prescription.diastolicBP != null) {
    rows.add(
      _chiefComplaintWithVitals(
        prescription,
      ),
    );
  }

  // ---------------------------------------------------------------------
  // EXAMINATION
  // ---------------------------------------------------------------------

  if (prescription.examination.isNotEmpty) {
    rows.add(
      _consultationSection(
        "Examination",
        prescription.examination,
      ),
    );
  }

  // ---------------------------------------------------------------------
  // DIAGNOSIS
  // ---------------------------------------------------------------------

  if (prescription.diagnosis.isNotEmpty) {
    rows.add(
      _consultationSection(
        "Diagnosis",
        prescription.diagnosis,
      ),
    );
  }

  // ---------------------------------------------------------------------
  // ADVICE
  // ---------------------------------------------------------------------

  if (prescription.advice.isNotEmpty) {
    rows.add(
      _consultationSection(
        "Advice",
        prescription.advice,
      ),
    );
  }

  // ---------------------------------------------------------------------
  // REMARKS
  // ---------------------------------------------------------------------

  if (prescription.remarks.isNotEmpty) {
    rows.add(
      _consultationSection(
        "Remarks",
        prescription.remarks,
      ),
    );
  }

  // ---------------------------------------------------------------------
  // FOLLOW-UP
  // ---------------------------------------------------------------------

  if (prescription.followUpDate != null) {
    rows.add(
      _consultationSection(
        "Follow-up",
        _formatDate(
          prescription.followUpDate!,
        ),
      ),
    );
  }

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: rows,
  );
}

pw.Widget _consultationSection(
  String label,
  String value,
) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(
      bottom: 7,
    ),
    child: pw.Column(
      crossAxisAlignment:
          pw.CrossAxisAlignment.start,
      children: [
        // ---------------------------------------------------------------
        // HEADING
        // ---------------------------------------------------------------

        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
          ),
        ),

        pw.SizedBox(height: 2),

        // ---------------------------------------------------------------
        // DETAILS
        // ---------------------------------------------------------------

        pw.Text(
          value.isEmpty ? "-" : value,
          style: const pw.TextStyle(
            fontSize: 9,
          ),
        ),
      ],
    ),
  );
}
  // ===========================================================================
  // MEDICINES
  // ===========================================================================

  pw.Widget _buildMedicineTable(
    List<Prescriptiondata>  medicines,
  ) {
    if (medicines.isEmpty) {
      return pw.SizedBox();
    }

    return pw.Table(
      border: pw.TableBorder.all(
        color: PdfColors.grey400,
        width: 0.5,
      ),

      columnWidths: const {
        0: pw.FlexColumnWidth(2.8),
        1: pw.FlexColumnWidth(0.8),
        2: pw.FlexColumnWidth(1.3),
        3: pw.FlexColumnWidth(1.0),
        4: pw.FlexColumnWidth(1.5),
        5: pw.FlexColumnWidth(1.8),
      },

      children: [

        pw.TableRow(
          decoration: const pw.BoxDecoration(
            color: PdfColors.grey200,
          ),

          children: [
            _tableHeader("Medicine"),
            _tableHeader("Freq."),
            _tableHeader("Consumption"),
            _tableHeader("Duration"),
            _tableHeader("Till"),
            _tableHeader("Remarks"),
          ],
        ),

        ...medicines.map(
          (medicine) =>
              _medicineRow(medicine),
        ),
      ],
    );
  }

  pw.TableRow _medicineRow(
  Prescriptiondata medicine,
) {
    final frequency =
        _frequencyText(
          medicine.freqBitField,
        );

    final consumption =
        medicine.isBeforeFood
            ? "Before food"
            : "After food";

    final duration =
        medicine.followupDuration == null
            ? "-"
            : "${medicine.followupDuration} "
              "${medicine.inDays ? "Days" : "Months"}";

    final till =
        _formatDateValue(
          medicine.followupdate,
        );

    final medicineName =
        _medicineName(medicine);

    return pw.TableRow(
      children: [

        _tableCell(medicineName),
        _tableCell(frequency),
        _tableCell(consumption),
        _tableCell(duration),
        _tableCell(till),
        _tableCell(
          medicine.remarks,
        ),
      ],
    );
  }

  // ===========================================================================
  // SIGNATURE
  // ===========================================================================

  pw.Widget _buildSignature(
    Uint8List signatureBytes,
  ) {
    return pw.Column(
      crossAxisAlignment:
          pw.CrossAxisAlignment.end,

      children: [

        pw.Image(
          pw.MemoryImage(signatureBytes),
          width: 100,
          height: 45,
          fit: pw.BoxFit.contain,
        ),

        pw.SizedBox(height: 2),

        pw.Text(
          "Signature",
          style: const pw.TextStyle(
            fontSize: 7,
          ),
        ),
      ],
    );
  }

  

  // ===========================================================================
  // THEME IMAGE
  // ===========================================================================
pw.MemoryImage? _loadThemeImage(
  PrescriptionTheme? theme, {
  required bool isHeader,
}) {
  if (theme == null) return null;

  final asset = isHeader
      ? theme.headerBackgroundImage
      : theme.footerBackgroundImage;

  if (asset == null || !asset.hasImage) {
    return null;
  }

  try {
    final dynamic imageData = asset.imageData;

    Uint8List bytes;

    if (imageData is Uint8List) {
      bytes = imageData;
    } else if (imageData is List<int>) {
      bytes = Uint8List.fromList(imageData);
    } else if (imageData is Map &&
        imageData['data'] is List) {
      bytes = Uint8List.fromList(
        List<int>.from(imageData['data']),
      );
    } else if (imageData is String) {
      var value = imageData.trim();

      // Handle data URI.
      if (value.startsWith('data:')) {
        value = value.substring(
          value.indexOf(',') + 1,
        );
      }

      // Handle JSON-serialized Buffer.
      if (value.startsWith('{"type":"Buffer"')) {
        final decoded = jsonDecode(value);

        bytes = Uint8List.fromList(
          List<int>.from(decoded['data']),
        );
      } else {
        // Standard Base64.
        bytes = base64Decode(value);
      }
    } else {
      debugPrint(
        'Unsupported image data type: ${imageData.runtimeType}',
      );

      return null;
    }

    debugPrint(
      '${isHeader ? "HEADER" : "FOOTER"} '
      'decoded bytes: ${bytes.length}',
    );

    return pw.MemoryImage(bytes);
  } catch (e, stackTrace) {
    debugPrint('Theme image decoding failed: $e');
    debugPrintStack(stackTrace: stackTrace);

    return null;
  }
}


  // ===========================================================================
  // HELPERS
  // ===========================================================================

  PdfPageFormat _getPageFormat(
    String pageSize,
  ) {
    switch (pageSize.toUpperCase()) {
      case "A5":
        return PdfPageFormat.a5;

      case "LETTER":
        return PdfPageFormat.letter;

      case "LEGAL":
        return PdfPageFormat.legal;

      case "A4":
      default:
        return PdfPageFormat.a4;
    }
  }

  double _cmToPoints(
    double cm,
  ) {
    return cm * PdfPageFormat.cm;
  }

  pw.Widget _infoText(
    String label,
    String value,
  ) {
    return pw.RichText(
      text: pw.TextSpan(
        children: [
          pw.TextSpan(
            text: "$label: ",
            style: pw.TextStyle(
              fontSize: 8,
              fontWeight:
                  pw.FontWeight.bold,
            ),
          ),
          pw.TextSpan(
            text: value.isEmpty
                ? "-"
                : value,
            style: const pw.TextStyle(
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _tableHeader(
    String text,
  ) {
    return pw.Padding(
      padding:
          const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 7,
          fontWeight:
              pw.FontWeight.bold,
        ),
      ),
    );
  }

  pw.Widget _tableCell(
    String? text,
  ) {
    return pw.Padding(
      padding:
          const pw.EdgeInsets.all(4),
      child: pw.Text(
        text == null || text.isEmpty
            ? "-"
            : text,
        style: const pw.TextStyle(
          fontSize: 7,
        ),
      ),
    );
  }

  String _medicineName(
    dynamic medicine,
  ) {
    final type =
        medicine.medicineType;

    final unit =
        medicine.drugUnit;

    final name =
        medicine.drugName;

    if (type == null ||
        type.toString().isEmpty) {
      return name;
    }

    if (unit == null) {
      return "$name $type";
    }

    return "$name $unit $type";
  }

  String _frequencyText(
    int bitField,
  ) {
    final bits = List<int>.generate(
      4,
      (index) =>
          (bitField & (1 << index)) != 0
              ? 1
              : 0,
    );

    final labels = [
      "M",
      "A",
      "E",
      "N",
    ];

    final selected = <String>[];

    for (var i = 0; i < bits.length; i++) {
      if (bits[i] == 1) {
        selected.add(labels[i]);
      }
    }

    return selected.isEmpty
        ? "-"
        : selected.join("-");
  }

  String _formatDateValue(
    dynamic value,
  ) {
    if (value == null) {
      return "-";
    }

    if (value is DateTime) {
      return _formatDate(value);
    }

    final parsed =
        DateTime.tryParse(
      value.toString(),
    );

    if (parsed == null) {
      return value.toString();
    }

    return _formatDate(parsed);
  }

  String _formatDate(
    DateTime date,
  ) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }


}