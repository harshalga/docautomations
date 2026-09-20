import 'package:docautomations/datamodels/master/image_asset.dart';

class PrescriptionTheme {
  //---------------------------------------------------------------------------
  // Identity
  //---------------------------------------------------------------------------

  final String id;

  final String name;

  final String description;

  //---------------------------------------------------------------------------
  // Status
  //---------------------------------------------------------------------------

  final bool isPremium;

  final bool isActive;

  //---------------------------------------------------------------------------
  // Theme
  //---------------------------------------------------------------------------

  final String fontFamily;

  final double fontSize;

  final String primaryColor;

  final String secondaryColor;

  final bool showBorder;

  final ImageAsset? headerBackgroundImage;

  final ImageAsset? footerBackgroundImage;

  //---------------------------------------------------------------------------
  // Constructor
  //---------------------------------------------------------------------------

  const PrescriptionTheme({
    required this.id,
    required this.name,
    required this.description,
    required this.isPremium,
    required this.isActive,
    required this.fontFamily,
    required this.fontSize,
    required this.primaryColor,
    required this.secondaryColor,
    required this.showBorder,
     this.headerBackgroundImage,
     this.footerBackgroundImage,
  });

  factory PrescriptionTheme.fromJson(
      Map<String, dynamic> json) {
    return PrescriptionTheme(
      id: json["_id"] ?? "",
      name: json["themename"] ?? "",
      description: json["themedescription"] ?? "",
      isPremium: json["isPremium"] ?? false,
      isActive: json["isActive"] ?? true,
      fontFamily: json["fontFamily"] ?? "Roboto",
      fontSize: (json["fontSize"] ?? 12).toDouble(),
      primaryColor: json["primaryColor"] ?? "#000000",
      secondaryColor: json["secondaryColor"] ?? "#666666",
      showBorder: json["showBorder"] ?? false,
      headerBackgroundImage: json["headerBackgroundImage"] == null
          ? null
          : ImageAsset.fromJson(json["headerBackgroundImage"]),
      footerBackgroundImage: json["footerBackgroundImage"] == null
          ? null
          : ImageAsset.fromJson(json["footerBackgroundImage"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "themename": name,
      "themedescription": description,
      "isPremium": isPremium,
      "isActive": isActive,
      "fontFamily": fontFamily,
      "fontSize": fontSize,
      "primaryColor": primaryColor,
      "secondaryColor": secondaryColor,
      "showBorder": showBorder,
      "headerBackgroundImage": headerBackgroundImage?.toJson(),
      "footerBackgroundImage": footerBackgroundImage?.toJson(),
    };
  }
}