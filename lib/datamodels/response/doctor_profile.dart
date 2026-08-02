import 'package:docautomations/datamodels/master/doctor_master.dart';
import 'package:docautomations/datamodels/master/prescription_layout.dart';
import 'package:docautomations/datamodels/master/prescription_theme.dart';
import 'package:docautomations/device_assets/asset_manifest.dart';

class DoctorProfile {
  //---------------------------------------------------------------------------
  // Doctor Information
  //---------------------------------------------------------------------------

  final DoctorMaster doctor;

  //---------------------------------------------------------------------------
  // Prescription Layout
  //---------------------------------------------------------------------------

  final PrescriptionLayout layout;

  //---------------------------------------------------------------------------
  // Prescription Theme
  //---------------------------------------------------------------------------

  final PrescriptionTheme theme;

  //---------------------------------------------------------------------------
  // Server Asset Manifest
  //
  // Contains the latest asset versions available on the server.
  // Example:
  // {
  //    "logo" : 3,
  //    "signature" : 5
  // }
  //---------------------------------------------------------------------------

  final AssetManifest assets;

  //---------------------------------------------------------------------------
  // Constructor
  //---------------------------------------------------------------------------

  const DoctorProfile({
    required this.doctor,
    required this.layout,
    required this.theme,
    required this.assets,
  });

  //---------------------------------------------------------------------------
  // From JSON
  //---------------------------------------------------------------------------

  factory DoctorProfile.fromJson(
    Map<String, dynamic> json,
  ) {
    return DoctorProfile(
      doctor: DoctorMaster.fromJson(
        json["doctor"],
      ),
      layout: PrescriptionLayout.fromJson(
        json["layout"],
      ),
      theme: PrescriptionTheme.fromJson(
        json["theme"],
      ),
      assets: AssetManifest.fromJson(
        json["assets"] ?? const {},
      ),
    );
  }

  //---------------------------------------------------------------------------
  // To JSON
  //---------------------------------------------------------------------------

  Map<String, dynamic> toJson() {
    return {
      "doctor": doctor.toJson(),
      "layout": layout.toJson(),
      "theme": theme.toJson(),
      "assets": assets.toJson(),
    };
  }
}