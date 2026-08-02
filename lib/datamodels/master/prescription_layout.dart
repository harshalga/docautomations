class PrescriptionLayout {

  final String selectedThemeId;

  final double topMarginCm;

  final double bottomMarginCm;

  final double leftMarginCm;

  final double rightMarginCm;

  final double headerHeightCm;

  final double footerHeightCm;

  final bool printLetterHead;

  final String pageSize;

  final bool printSignature;

  final bool showPrescriptionQRCode;

  final bool showWatermark;

  const PrescriptionLayout({

    required this.selectedThemeId,

    required this.topMarginCm,

    required this.bottomMarginCm,

    required this.leftMarginCm,

    required this.rightMarginCm,
   
    required this.headerHeightCm,

    required this.footerHeightCm,

    required this.printLetterHead,

    required this.showPrescriptionQRCode,

    required this.showWatermark,
    required this.pageSize,
    required this.printSignature,
  });

  factory PrescriptionLayout.fromJson(
      Map<String, dynamic> json) {

    return PrescriptionLayout(

      selectedThemeId:
          json["selectedThemeId"] ?? "",
      topMarginCm:
          (json["topMarginCm"] ?? 0.5).toDouble(),

      bottomMarginCm:
          (json["bottomMarginCm"] ?? 0.5).toDouble(),

      leftMarginCm:
          (json["leftMarginCm"] ?? 0.5).toDouble(),

      rightMarginCm:
          (json["rightMarginCm"] ?? 0.5).toDouble(),

      headerHeightCm:
          (json["headerHeightCm"] ?? 5.5).toDouble(),

      footerHeightCm:
          (json["footerHeightCm"] ?? 2.0).toDouble(),

      printLetterHead:
          json["printLetterHead"] ?? true,

      showPrescriptionQRCode:
          json["showPrescriptionQRCode"] ?? true,

      showWatermark:
          json["showWatermark"] ?? true,

      pageSize:
          json["pageSize"] ?? "A4",

      printSignature:
          json["printSignature"] ?? true,
    );
  }

  Map<String, dynamic> toJson() {

    return {

      "selectedThemeId": selectedThemeId,

      "topMarginCm": topMarginCm,

      "bottomMarginCm": bottomMarginCm,

      "leftMarginCm": leftMarginCm,

      "rightMarginCm": rightMarginCm,

      "headerHeightCm": headerHeightCm,

      "footerHeightCm": footerHeightCm,

      "printLetterHead": printLetterHead,

      "showPrescriptionQRCode": showPrescriptionQRCode,

      "showWatermark": showWatermark,

      "pageSize": pageSize,

      "printSignature": printSignature,
    };
  }
}