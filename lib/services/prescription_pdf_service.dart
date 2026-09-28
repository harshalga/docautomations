import 'dart:typed_data';

import 'package:docautomations/common/appconstants.dart';
import 'package:docautomations/datamodels/prescriptionData.dart';
import 'package:docautomations/datamodels/prescription_snapshot.dart';
import 'package:docautomations/datamodels/prescription_layout.dart';
import 'package:docautomations/datamodels/prescription_theme.dart';

import 'package:flutter/services.dart';

import 'package:intl/intl.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;


class PrescriptionPdfService {

  //===========================================================================
  // Generate Prescription PDF
  //===========================================================================

  Future<Uint8List> generate({
    required PrescriptionSnapshot snapshot,
    required PrescriptionLayout layout,
    required PrescriptionTheme? theme,
    Uint8List? doctorLogo,
    Uint8List? doctorSignature,
  }) async {

    //-----------------------------------------------------------------------
    // Fonts
    //-----------------------------------------------------------------------

    final fontRegular =
        pw.Font.ttf(
      await rootBundle.load(
        "assets/fonts/Roboto-Regular.ttf",
      ),
    );

    final fontBold =
        pw.Font.ttf(
      await rootBundle.load(
        "assets/fonts/Roboto-Bold.ttf",
      ),
    );

    final pdfTheme =
        pw.ThemeData.withFont(
      base: fontRegular,
      bold: fontBold,
    );


    //-----------------------------------------------------------------------
    // Document
    //-----------------------------------------------------------------------

    final pdf =
        pw.Document();


    //-----------------------------------------------------------------------
    // Page format
    //-----------------------------------------------------------------------

    final pageFormat =
        _pageFormat(
      layout.pageSize,
    );


    //-----------------------------------------------------------------------
    // Margins
    //-----------------------------------------------------------------------

    final margins =
        pw.EdgeInsets.only(
      left: _cm(layout.leftMarginCm),
      right: _cm(layout.rightMarginCm),
      top: _cm(layout.topMarginCm),
      bottom: _cm(layout.bottomMarginCm),
    );


    //-----------------------------------------------------------------------
    // Images
    //-----------------------------------------------------------------------

    final logoImage =
        doctorLogo != null
            ? pw.MemoryImage(doctorLogo)
            : null;

    final signatureImage =
        doctorSignature != null
            ? pw.MemoryImage(doctorSignature)
            : null;


    //-----------------------------------------------------------------------
    // QR code
    //-----------------------------------------------------------------------

    final qrCode =
        pw.BarcodeWidget(
      barcode:
          pw.Barcode.qrCode(),
      data:
          AppConstants.playStoreUrl,
      width: 60,
      height: 60,
    );


    //-----------------------------------------------------------------------
    // Add page
    //-----------------------------------------------------------------------

    pdf.addPage(

      pw.MultiPage(

        theme: pdfTheme,

        pageFormat: pageFormat,

        margin: margins,


        //-------------------------------------------------------------------
        // HEADER
        //-------------------------------------------------------------------

        header: (context) {

          return _buildHeader(
            snapshot: snapshot,
            layout: layout,
            theme: theme,
            logo: logoImage,
          );
        },


        //-------------------------------------------------------------------
        // FOOTER
        //-------------------------------------------------------------------

        footer: (context) {

          return _buildFooter(
            context: context,
            layout: layout,
            qrCode: qrCode,
            signature: signatureImage,
          );
        },


        //-------------------------------------------------------------------
        // BODY
        //-------------------------------------------------------------------

        build: (context) {

          return _buildBody(
            snapshot,
            theme,
          );
        },
      ),
    );


    //-----------------------------------------------------------------------
    // Save
    //-----------------------------------------------------------------------

    return pdf.save();
  }


  //===========================================================================
  // HEADER
  //===========================================================================

  pw.Widget _buildHeader({
    required PrescriptionSnapshot snapshot,
    required PrescriptionLayout layout,
    required PrescriptionTheme? theme,
    pw.ImageProvider? logo,
  }) {

    //-----------------------------------------------------------------------
    // Letterhead disabled
    //-----------------------------------------------------------------------

    if (!layout.printLetterHead) {

      return pw.SizedBox(
        height: _cm(
          layout.headerHeightCm,
        ),
      );
    }


    //-----------------------------------------------------------------------
    // Doctor information
    //-----------------------------------------------------------------------

    final doctor =
        snapshot.doctor;

    final clinic =
        snapshot.clinic;


    return pw.Container(

      height:
          _cm(layout.headerHeightCm),

      child:
          pw.Column(

        crossAxisAlignment:
            pw.CrossAxisAlignment.start,

        children: [

          pw.Row(

            crossAxisAlignment:
                pw.CrossAxisAlignment.start,

            mainAxisAlignment:
                pw.MainAxisAlignment.spaceBetween,

            children: [

              pw.Expanded(

                child: pw.Column(

                  crossAxisAlignment:
                      pw.CrossAxisAlignment.start,

                  children: [

                    pw.Text(
                      "Dr. ${doctor.doctorName}",
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight:
                            pw.FontWeight.bold,
                      ),
                    ),

                    if (doctor.qualification
                        .trim()
                        .isNotEmpty)
                      pw.Text(
                        doctor.qualification,
                      ),

                    if (doctor.specialization
                        .trim()
                        .isNotEmpty)
                      pw.Text(
                        doctor.specialization,
                      ),

                    if (doctor.registrationNumber
                        .trim()
                        .isNotEmpty)
                      pw.Text(
                        "Reg. No.: "
                        "${doctor.registrationNumber}",
                      ),

                    if (clinic.clinicName
                        .trim()
                        .isNotEmpty)
                      pw.Text(
                        clinic.clinicName,
                      ),

                    if (clinic.clinicAddress
                        .trim()
                        .isNotEmpty)
                      pw.Text(
                        clinic.clinicAddress,
                      ),

                    _clinicLocation(clinic),

                    if (doctor.mobileNumber
                        .trim()
                        .isNotEmpty)
                      pw.Text(
                        "Contact: "
                        "${doctor.mobileNumber}",
                      ),

                  ],
                ),
              ),


              //----------------------------------------------------------------
              // Logo
              //----------------------------------------------------------------

              if (logo != null)

                pw.Container(

                  width: 60,
                  height: 60,

                  child:
                      pw.Image(logo),
                ),
            ],
          ),


          pw.Spacer(),

          pw.Divider(),
        ],
      ),
    );
  }


  //===========================================================================
  // CLINIC LOCATION
  //===========================================================================

  String _clinicLocation(
    ClinicSnapshot clinic,
  ) {

    final parts = <String>[];

    if (clinic.city.trim().isNotEmpty) {
      parts.add(clinic.city.trim());
    }

    if (clinic.state.trim().isNotEmpty) {
      parts.add(clinic.state.trim());
    }

    if (clinic.country.trim().isNotEmpty) {
      parts.add(clinic.country.trim());
    }

    if (clinic.pinCode.trim().isNotEmpty) {
      parts.add(clinic.pinCode.trim());
    }

    if (parts.isEmpty) {
      return "";
    }

    return parts.join(", ");
  }


  //===========================================================================
  // BODY
  //===========================================================================

  List<pw.Widget> _buildBody(
    PrescriptionSnapshot snapshot,
    PrescriptionTheme? theme,
  ) {

    final prescription =
        snapshot.prescription;

    final patient =
        snapshot.patient;


    final formattedDate =
        DateFormat(
          "dd/MM/yyyy",
        ).format(
          DateTime.now(),
        );


    final widgets =
        <pw.Widget>[

          //-------------------------------------------------------------------
          // Prescription date
          //-------------------------------------------------------------------

          pw.Align(

            alignment:
                pw.Alignment.centerRight,

            child: pw.Text(

              "Date: $formattedDate",

              style: pw.TextStyle(
                fontSize: 12,
                fontWeight:
                    pw.FontWeight.bold,
              ),
            ),
          ),


          pw.SizedBox(
            height: 16,
          ),


          //-------------------------------------------------------------------
          // Patient information
          //-------------------------------------------------------------------

          _sectionTitle(
            "Patient Information",
          ),

          pw.SizedBox(
            height: 5,
          ),

          pw.Text(
            "Patient Name: "
            "${patient.fullName}",
          ),

          if (patient.ppid.trim().isNotEmpty)
            pw.Text(
              "Patient ID: ${patient.ppid}",
            ),

          pw.Text(
            "Age: ${patient.ageAtVisit}",
          ),

          if (patient.gender.trim().isNotEmpty)
            pw.Text(
              "Gender: ${patient.gender}",
            ),

          if (patient.mobileNumber.trim().isNotEmpty)
            pw.Text(
              "Mobile: ${patient.mobileNumber}",
            ),

          pw.SizedBox(
            height: 10,
          ),


          //-------------------------------------------------------------------
          // Clinical information
          //-------------------------------------------------------------------

          _section(
            "Chief Complaints",
            prescription.chiefComplaint,
          ),

          _section(
            "Findings of Examination",
            prescription.examination,
          ),

          _section(
            "Diagnosis",
            prescription.diagnosis,
          ),

          _section(
            "Advice",
            prescription.advice,
          ),

          _section(
            "Remarks",
            prescription.remarks,
          ),

          if (prescription.followUpDate != null)

            _section(
              "Next Follow Up Date",
              DateFormat(
                "dd/MM/yyyy",
              ).format(
                prescription.followUpDate!,
              ),
            ),


          pw.SizedBox(
            height: 10,
          ),


          //-------------------------------------------------------------------
          // Medicines
          //-------------------------------------------------------------------

          _sectionTitle(
            "Prescribed Medicines",
          ),

          pw.SizedBox(
            height: 10,
          ),


          if (prescription.medicines.isEmpty)

            pw.Text(
              "No medicines added.",
            )

          else

            _medicineTable(
              prescription.medicines,
            ),
        ];


    return widgets;
  }


  //===========================================================================
  // SECTION TITLE
  //===========================================================================

  pw.Widget _sectionTitle(
    String title,
  ) {

    return pw.Text(

      title,

      style: pw.TextStyle(
        fontSize: 16,
        fontWeight:
            pw.FontWeight.bold,
      ),
    );
  }


  //===========================================================================
  // SECTION
  //===========================================================================

  pw.Widget _section(
    String title,
    String value,
  ) {

    if (value.trim().isEmpty) {
      return pw.SizedBox();
    }

    return pw.Column(

      crossAxisAlignment:
          pw.CrossAxisAlignment.start,

      children: [

        pw.Text(

          title,

          style: pw.TextStyle(
            fontSize: 13,
            fontWeight:
                pw.FontWeight.bold,
          ),
        ),

        pw.Text(
          value,
        ),

        pw.SizedBox(
          height: 8,
        ),
      ],
    );
  }


  //===========================================================================
  // MEDICINE TABLE
  //===========================================================================

  pw.Widget _medicineTable(
    List<Prescriptiondata> medicines,
  ) {

    return pw.TableHelper.fromTextArray(

      border:
          pw.TableBorder.all(),

      headerDecoration:
          pw.BoxDecoration(
        color: PdfColors.grey300,
      ),

      headerStyle:
          pw.TextStyle(
        fontWeight:
            pw.FontWeight.bold,
        fontSize: 10,
      ),

      cellStyle:
          const pw.TextStyle(
        fontSize: 9,
      ),

      columnWidths: {

        0: const pw.FlexColumnWidth(3.5),

        1: const pw.FlexColumnWidth(1.4),

        2: const pw.FlexColumnWidth(2.0),

        3: const pw.FlexColumnWidth(1.5),

        4: const pw.FlexColumnWidth(2.0),

        5: const pw.FlexColumnWidth(2.2),
      },

      headers: [

        "Medicine",

        "Freq.",

        "Consumption",

        "Duration",

        "Consume Till Date",

        "Remarks",
      ],


      data:
          medicines.map(

        (medicine) {

          final unit =
              _unitForMedicine(
                medicine.medicineType,
              );


          final dose =
              medicine.drugUnit
                  ?.toString() ??
              "";


          final unitValue =

              medicine.medicineType ==
                          "Ointment" ||
                      medicine.medicineType ==
                          "Others"

                  ? ""

                  : unit;


          final consumption =

              medicine.isTablet

                  ? medicine.isBeforeFood
                      ? "Before Food"
                      : "After Food"

                  : "NA";


          final frequency =
              medicine
                  .toBitList(4)
                  .join(" - ");


          final duration =
              medicine.followupDuration == null

                  ? ""

                  : "${medicine.followupDuration} "
                    "${medicine.inDays ? 'Days' : 'Months'}";


          final tillDate =
              DateFormat(
                "dd/MM/yyyy",
              ).format(
                medicine.followupdate,
              );


          return [

            "${medicine.medicineType ?? ''} "
            "${medicine.drugName} "
            "$dose "
            "$unitValue",

            frequency,

            consumption,

            duration,

            tillDate,

            medicine.remarks,
          ];
        },
      ).toList(),
    );
  }


  //===========================================================================
  // MEDICINE UNIT
  //===========================================================================

  String _unitForMedicine(
    String? medicineType,
  ) {

    switch (medicineType) {

      case "Tablet":
      case "Capsule":
        return "mg";

      case "Syrup":
        return "ml";

      case "Ointment":
        return "gm";

      case "Injection":
        return "ml";

      case "Inhalation":
        return "puffs";

      case "Drops":
        return "drops";

      case "Others":
      default:
        return "";
    }
  }


  //===========================================================================
  // FOOTER
  //===========================================================================

  pw.Widget _buildFooter({
    required pw.Context context,
    required PrescriptionLayout layout,
    required pw.Widget qrCode,
    pw.ImageProvider? signature,
  }) {

    return pw.Container(

      height:
          _cm(layout.footerHeightCm),

      child: pw.Column(

        children: [

          pw.Spacer(),


          //-------------------------------------------------------------------
          // Signature
          //-------------------------------------------------------------------

          if (layout.printSignature)

            pw.Align(

              alignment:
                  pw.Alignment.centerRight,

              child: pw.Column(

                children: [

                  if (signature != null)

                    pw.Container(
                      width: 140,
                      height: 45,
                      child: pw.Image(
                        signature,
                        fit: pw.BoxFit.contain,
                      ),
                    )

                  else

                    pw.SizedBox(
                      height: 35,
                    ),


                  pw.Container(

                    width: 140,

                    child: pw.Divider(
                      thickness: 1,
                    ),
                  ),

                  pw.Text(
                    "Doctor's Signature",
                    style:
                        const pw.TextStyle(
                      fontSize: 10,
                    ),
                  ),

                  pw.SizedBox(
                    height: 5,
                  ),
                ],
              ),
            ),


          //-------------------------------------------------------------------
          // Prescriptor QR
          //-------------------------------------------------------------------

          if (layout.printQRCode)

            pw.Row(

              crossAxisAlignment:
                  pw.CrossAxisAlignment.center,

              children: [

                qrCode,

                pw.SizedBox(
                  width: 12,
                ),

                pw.Expanded(

                  child: pw.Column(

                    crossAxisAlignment:
                        pw.CrossAxisAlignment.start,

                    children: [

                      pw.Text(
                        "Digitally generated using Prescriptor®",
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight:
                              pw.FontWeight.bold,
                        ),
                      ),

                      pw.SizedBox(
                        height: 2,
                      ),

                      pw.Text(
                        "Helping healthcare professionals "
                        "create clear, professional and "
                        "paper-efficient prescriptions.",
                        style:
                            const pw.TextStyle(
                          fontSize: 7,
                        ),
                      ),

                      pw.Text(
                        "Have your doctor scan the QR code "
                        "to download the Prescriptor App.",
                        style:
                            const pw.TextStyle(
                          fontSize: 7,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),


          //-------------------------------------------------------------------
          // Page number
          //-------------------------------------------------------------------

          if (layout.showPageNumber)

            pw.Padding(

              padding:
                  const pw.EdgeInsets.only(
                top: 4,
              ),

              child: pw.Center(

                child: pw.Text(
                  "Page ${context.pageNumber} "
                  "of ${context.pagesCount}",

                  style:
                      const pw.TextStyle(
                    fontSize: 8,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }


  //===========================================================================
  // PAGE FORMAT
  //===========================================================================

  PdfPageFormat _pageFormat(
    String pageSize,
  ) {

    switch (
        pageSize.toUpperCase()) {

      case "LETTER":
        return PdfPageFormat.letter;

      case "LEGAL":
        return PdfPageFormat.legal;

      case "A4":
      default:
        return PdfPageFormat.a4;
    }
  }


  //===========================================================================
  // CM -> PDF POINTS
  //===========================================================================

  double _cm(
    double value,
  ) {

    return value * PdfPageFormat.cm;
  }
}