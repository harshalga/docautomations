import 'dart:typed_data';
import 'dart:convert';

import 'package:docautomations/datamodels/master/prescription_theme.dart';
import 'package:docautomations/device_assets/asset_type.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:docautomations/datamodels/snapshot/prescription_snapshot.dart';
import 'package:docautomations/device_assets/asset_manager.dart';
import 'package:docautomations/datamodels/prescriptionData.dart';


class PrescriptionPdfService {
  final AssetManager assetManager;

  const PrescriptionPdfService({
    required this.assetManager,
  });



String _stringValue(dynamic value) {
  if (value == null) {
    return "-";
  }

  if (value is DateTime) {
    return _formatDate(value);
  }

  return value.toString();
}


  // ===========================================================================
  // PUBLIC API
  // ===========================================================================

  Future<Uint8List> generatePrescriptionPdf({
  required PrescriptionSnapshot snapshot,
  required PrescriptionTheme? selectedTheme,
  String? prescriptionQrData,
  required String prescriptionDate,
}) async {
    final layout = snapshot.layout;

    final pageFormat = _getPageFormat(layout.pageSize);

   final logoAsset =
    await assetManager.loadAsset(AssetType.logo);

final signatureAsset =
    await assetManager.loadAsset(AssetType.signature);

final Uint8List? logoBytes =
    logoAsset == null
        ? null
        : Uint8List.fromList(logoAsset);

final Uint8List? signatureBytes =
    signatureAsset == null
        ? null
        : Uint8List.fromList(signatureAsset);

    final document = pw.Document();

   final headerImage =
    _loadThemeImage(
      selectedTheme,
      isHeader: true,
    );

final footerImage =
    _loadThemeImage(
      selectedTheme,
      isHeader: false,
    );

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

    document.addPage(
      pw.Page(
        pageFormat: pageFormat,

        margin: pw.EdgeInsets.zero,

        build: (context) {
          return _buildPage(
            snapshot: snapshot,
            prescriptionDate: prescriptionDate,
            logoBytes: logoBytes,
            signatureBytes: signatureBytes,
            headerImage: headerImage,
            footerImage: footerImage,
            qrCode: qrCode,
          );
        },
      ),
    );

    return document.save();
  }

  // ===========================================================================
  // PAGE
  // ===========================================================================

  pw.Widget _buildPage({
    required PrescriptionSnapshot snapshot,
    required String prescriptionDate,
    Uint8List? logoBytes,
    Uint8List? signatureBytes,
    pw.MemoryImage? headerImage,
    pw.MemoryImage? footerImage,
    pw.BarcodeWidget? qrCode,
  }) {
    final layout = snapshot.layout;

    final headerHeight =
        _cmToPoints(layout.headerHeightCm);

    final footerHeight =
        _cmToPoints(layout.footerHeightCm);

    final leftMargin =
        _cmToPoints(layout.leftMarginCm);

    final rightMargin =
        _cmToPoints(layout.rightMarginCm);

    final topMargin =
        _cmToPoints(layout.topMarginCm);

    final bottomMargin =
        _cmToPoints(layout.bottomMarginCm);

    return pw.Stack(
      children: [

        // ---------------------------------------------------------------------
        // THEME HEADER
        // ---------------------------------------------------------------------

        if (!layout.printLetterHead &&
    headerImage != null)
  pw.Positioned(
    left: 0,
    right: 0,
    top: 0,
    child: pw.SizedBox(
      height: headerHeight,
      width: double.infinity,
      child: pw.Image(
        headerImage,
        fit: pw.BoxFit.fill,
      ),
    ),
  ),

        // ---------------------------------------------------------------------
        // THEME FOOTER
        // ---------------------------------------------------------------------

        if (!layout.printLetterHead &&
    footerImage != null)
  pw.Positioned(
    left: 0,
    right: 0,
    bottom: 0,
    child: pw.SizedBox(
      height: footerHeight,
      width: double.infinity,
      child: pw.Image(
        footerImage,
        fit: pw.BoxFit.fill,
      ),
    ),
  ),

        // ---------------------------------------------------------------------
        // BODY
        // ---------------------------------------------------------------------

        pw.Positioned(
          left: leftMargin,
          right: rightMargin,
          top: headerHeight + topMargin,
          bottom: footerHeight + bottomMargin,
          child: _buildBody(
            snapshot: snapshot,
            prescriptionDate: prescriptionDate,
            qrCode: qrCode,
          ),
        ),

        // ---------------------------------------------------------------------
        // SIGNATURE
        // ---------------------------------------------------------------------

        if (layout.printSignature &&
            signatureBytes != null)
          pw.Positioned(
            right: rightMargin,
            bottom: footerHeight * 0.30,
            child: _buildSignature(
              signatureBytes,
            ),
          ),

        // ---------------------------------------------------------------------
        // LOGO
        // ---------------------------------------------------------------------

        if (!layout.printLetterHead &&
            logoBytes != null)
          pw.Positioned(
            left: leftMargin,
            bottom: footerHeight * 0.25,
            child: _buildLogo(
              logoBytes,
            ),
          ),

        // ---------------------------------------------------------------------
        // PAGE NUMBER
        // ---------------------------------------------------------------------

        if (layout.showPageNumber)
          pw.Positioned(
            right: rightMargin,
            bottom: 5,
            child: pw.Text(
              "Page 1",
              style: const pw.TextStyle(
                fontSize: 8,
              ),
            ),
          ),
      ],
    );
  }

  // ===========================================================================
  // BODY
  // ===========================================================================

  pw.Widget _buildBody({
    required PrescriptionSnapshot snapshot,
    required String prescriptionDate,
    required pw.BarcodeWidget? qrCode,
  }) {
    final patient = snapshot.patient;
    final prescription = snapshot.prescription;

    return pw.Column(
      crossAxisAlignment:
          pw.CrossAxisAlignment.start,

      children: [

        // ---------------------------------------------------------------------
        // DATE + QR
        // ---------------------------------------------------------------------

        pw.Row(
          crossAxisAlignment:
              pw.CrossAxisAlignment.start,

          children: [

            pw.Expanded(
              child: pw.Text(
                prescriptionDate,
                style: const pw.TextStyle(
                  fontSize: 10,
                ),
              ),
            ),

            if (qrCode != null)
              pw.Column(
                crossAxisAlignment:
                    pw.CrossAxisAlignment.end,
                children: [
                  qrCode,
                  pw.SizedBox(height: 2),
                  pw.Text(
                    "Scan to view prescription",
                    style: const pw.TextStyle(
                      fontSize: 6,
                    ),
                  ),
                ],
              ),
          ],
        ),

        pw.SizedBox(height: 8),

        // ---------------------------------------------------------------------
        // PATIENT INFORMATION
        // ---------------------------------------------------------------------

        _buildPatientInformation(
          patient,
        ),

        pw.SizedBox(height: 10),

        // ---------------------------------------------------------------------
        // CONSULTATION
        // ---------------------------------------------------------------------

        _buildConsultation(
          prescription,
        ),

        pw.SizedBox(height: 10),

        // ---------------------------------------------------------------------
        // MEDICINES
        // ---------------------------------------------------------------------

        _buildMedicineTable(
          prescription.medicines,
        ),
      ],
    );
  }



  // ===========================================================================
  // PATIENT
  // ===========================================================================

  pw.Widget _buildPatientInformation(
    PatientSnapshot patient,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),

      decoration: pw.BoxDecoration(
        border: pw.Border.all(
          color: PdfColors.grey400,
          width: 0.5,
        ),
      ),

      child: pw.Column(
        crossAxisAlignment:
            pw.CrossAxisAlignment.start,

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

          if (patient.mobile.isNotEmpty)
            pw.Padding(
              padding:
                  const pw.EdgeInsets.only(top: 4),
              child: _infoText(
                "Mobile",
                patient.mobile,
              ),
            ),

          if (patient.addressLine1.isNotEmpty ||
              patient.addressLine2.isNotEmpty)
            pw.Padding(
              padding:
                  const pw.EdgeInsets.only(top: 4),
              child: _infoText(
                "Address",
                [
                  patient.addressLine1,
                  patient.addressLine2,
                  patient.country,
                  patient.pinCode,
                ]
                    .where(
                      (value) =>
                          value.trim().isNotEmpty,
                    )
                    .join(", "),
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

    if (prescription.chiefComplaint.isNotEmpty) {
      rows.add(
        _consultationRow(
          "Chief Complaint",
          prescription.chiefComplaint,
        ),
      );
    }

    if (prescription.examination.isNotEmpty) {
      rows.add(
        _consultationRow(
          "Examination",
          prescription.examination,
        ),
      );
    }

    if (prescription.diagnosis.isNotEmpty) {
      rows.add(
        _consultationRow(
          "Diagnosis",
          prescription.diagnosis,
        ),
      );
    }

    if (prescription.advice.isNotEmpty) {
      rows.add(
        _consultationRow(
          "Advice",
          prescription.advice,
        ),
      );
    }

    if (prescription.remarks.isNotEmpty) {
      rows.add(
        _consultationRow(
          "Remarks",
          prescription.remarks,
        ),
      );
    }

    if (prescription.followUpDate != null) {
  rows.add(
    _consultationRow(
      "Follow-up",
      _formatDate(
        prescription.followUpDate!,
      ),
    ),
  );
}


    return pw.Column(
      crossAxisAlignment:
          pw.CrossAxisAlignment.start,
      children: rows,
    );
  }

  pw.Widget _consultationRow(
    String label,
    String value,
  ) {
    return pw.Padding(
      padding:
          const pw.EdgeInsets.only(bottom: 5),

      child: pw.Row(
        crossAxisAlignment:
            pw.CrossAxisAlignment.start,

        children: [

          pw.SizedBox(
            width: 90,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 9,
                fontWeight:
                    pw.FontWeight.bold,
              ),
            ),
          ),

          pw.Expanded(
            child: pw.Text(
              value,
              style: const pw.TextStyle(
                fontSize: 9,
              ),
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
  // LOGO
  // ===========================================================================

  pw.Widget _buildLogo(
    Uint8List logoBytes,
  ) {
    return pw.Image(
      pw.MemoryImage(logoBytes),
      width: 55,
      height: 55,
      fit: pw.BoxFit.contain,
    );
  }

  // ===========================================================================
  // THEME IMAGE
  // ===========================================================================

  pw.MemoryImage? _loadThemeImage(
  PrescriptionTheme? theme, {
  required bool isHeader,
}) {
  if (theme == null) {
    return null;
  }

  final asset =
      isHeader
          ? theme.headerBackgroundImage
          : theme.footerBackgroundImage;

  if (asset == null || !asset.hasImage) {
    return null;
  }

  try {
    var value = asset.imageData;

    // Supports:
    // data:image/png;base64,.....
    // and plain base64.
    if (value.contains(",")) {
      value = value.substring(
        value.indexOf(",") + 1,
      );
    }

    final bytes = base64Decode(value);

    return pw.MemoryImage(bytes);
  } catch (_) {
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