import 'package:docautomations/datamodels/master/image_asset.dart';
import 'package:flutter/material.dart';

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

  final DateTime? updatedAt;

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
    this.updatedAt,
  });

  factory PrescriptionTheme.fromJson(
      Map<String, dynamic> json) {

        debugPrint(
  "Header image JSON: ${json['headerBackgroundImage']}",
);
debugPrint(
  "Footer image JSON: ${json['footerBackgroundImage']}",
);
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
      updatedAt: json["updatedAt"] == null     ? null
            : DateTime.tryParse(json["updatedAt"].toString()),
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
      "updatedAt": updatedAt?.toIso8601String(),
    };
  }
}