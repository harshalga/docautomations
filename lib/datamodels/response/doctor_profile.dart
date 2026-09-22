import 'package:docautomations/datamodels/master/doctor_master.dart';
import 'package:docautomations/datamodels/master/prescription_layout.dart';
import 'package:docautomations/datamodels/master/prescription_theme.dart';
import 'package:docautomations/datamodels/master/server_assets.dart';
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

  final ServerAssets assets;

  //---------------------------------------------------------------------------
  // Constructor
  //---------------------------------------------------------------------------

  const DoctorProfile({
    required this.doctor,
    required this.layout,
    required this.theme,
    required this.assets,
  });

  
factory DoctorProfile.fromJson(
  Map<String, dynamic> json,
) {
  Map<String, dynamic> requireMap(
    String key,
  ) {
    final value = json[key];

    if (value is Map<String, dynamic>) {
      return value;
    }

    throw FormatException(
      'DoctorProfile: "$key" must be a JSON object. '
      'Received: ${value.runtimeType}; value: $value',
    );
  }

  return DoctorProfile(
    doctor: DoctorMaster.fromJson(
      requireMap("doctor"),
    ),

    layout: PrescriptionLayout.fromJson(
      requireMap("layout"),
    ),

    theme: PrescriptionTheme.fromJson(
      requireMap("theme"),
    ),

    assets: ServerAssets.fromJson(
      json["assets"] is Map<String, dynamic>
          ? json["assets"] as Map<String, dynamic>
          : const <String, dynamic>{},
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
      "assets": {
  "logo": {
    "exists": assets.logo.exists,
    "version": assets.logo.version,
    "mimeType": assets.logo.mimeType,
  },
  "signature": {
    "exists": assets.signature.exists,
    "version": assets.signature.version,
    "mimeType": assets.signature.mimeType,
  },
  "header": {
    "exists": assets.header.exists,
    "version": assets.header.version,
    "mimeType": assets.header.mimeType,
  },
  "footer": {
    "exists": assets.footer.exists,
    "version": assets.footer.version,
    "mimeType": assets.footer.mimeType,
  },
},
    };
  }
}