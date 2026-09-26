import 'package:docautomations/datamodels/master/prescription_theme.dart';

class PrescriptionLayout {

  //===========================================================================
  // Identity
  //===========================================================================

  final String id;

  final String doctorId;


  //===========================================================================
  // Page Layout
  //===========================================================================

  final double headerHeightCm;

  final double footerHeightCm;

  final double leftMarginCm;

  final double rightMarginCm;

  final double topMarginCm;

  final double bottomMarginCm;

  final String pageSize;


  //===========================================================================
  // Printing Options
  //===========================================================================

  final bool printLetterHead;

  final bool printSignature;

  final bool showPrescriptionQRCode;

  final bool showWatermark;

  final bool showPageNumber;


  //===========================================================================
  // Theme
  //===========================================================================

  final PrescriptionTheme? selectedTheme;


  //===========================================================================
  // Constructor
  //===========================================================================

  const PrescriptionLayout({

    required this.id,

    required this.doctorId,

    required this.headerHeightCm,

    required this.footerHeightCm,

    required this.leftMarginCm,

    required this.rightMarginCm,

    required this.topMarginCm,

    required this.bottomMarginCm,

    required this.pageSize,

    required this.printLetterHead,

    required this.printSignature,

    required this.showPrescriptionQRCode,

    required this.showWatermark,

    required this.showPageNumber,

    this.selectedTheme,

  });


  //===========================================================================
  // JSON
  //===========================================================================

  factory PrescriptionLayout.fromJson(
    Map<String, dynamic> json,
  ) {

    final selectedThemeJson =
        json["selectedThemeId"];


    return PrescriptionLayout(

      id:
          json["_id"]?.toString() ?? "",

      doctorId:
          json["doctorId"]?.toString() ?? "",

      headerHeightCm:
          (json["headerHeightCm"] ?? 5.5).toDouble(),

      footerHeightCm:
          (json["footerHeightCm"] ?? 1.5).toDouble(),

      leftMarginCm:
          (json["leftMarginCm"] ?? 1.0).toDouble(),

      rightMarginCm:
          (json["rightMarginCm"] ?? 1.0).toDouble(),

      topMarginCm:
          (json["topMarginCm"] ?? 0.0).toDouble(),

      bottomMarginCm:
          (json["bottomMarginCm"] ?? 0.0).toDouble(),

      pageSize:
          json["pageSize"]?.toString() ?? "A4",

      printLetterHead:
          json["printLetterHead"] ?? true,

      printSignature:
          json["printSignature"] ?? true,

      showPrescriptionQRCode:
          json["showPrescriptionQRCode"] ?? true,

      showWatermark:
          json["showWatermark"] ?? false,

      showPageNumber:
          json["showPageNumber"] ?? false,

      selectedTheme:
          selectedThemeJson is Map
              ? PrescriptionTheme.fromJson(
                  Map<String, dynamic>.from(
                    selectedThemeJson,
                  ),
                )
              : null,
    );
  }


  //===========================================================================
  // To JSON
  //===========================================================================

  Map<String, dynamic> toJson() {

    return {

      "_id":
          id,

      "doctorId":
          doctorId,

      "headerHeightCm":
          headerHeightCm,

      "footerHeightCm":
          footerHeightCm,

      "leftMarginCm":
          leftMarginCm,

      "rightMarginCm":
          rightMarginCm,

      "topMarginCm":
          topMarginCm,

      "bottomMarginCm":
          bottomMarginCm,

      "pageSize":
          pageSize,

      "printLetterHead":
          printLetterHead,

      "printSignature":
          printSignature,

      "showPrescriptionQRCode":
          showPrescriptionQRCode,

      "showWatermark":
          showWatermark,

      "showPageNumber":
          showPageNumber,

      "selectedTheme":
          selectedTheme?.toJson(),

    };
  }
}