import 'package:docautomations/datamodels/master/image_asset.dart';

class DoctorSignature {
  //---------------------------------------------------------------------------
  // Identity
  //---------------------------------------------------------------------------

  final String id;

   final String doctorId;

   


  //---------------------------------------------------------------------------
  // Version
  //---------------------------------------------------------------------------

  /// Incremented whenever the doctor uploads a new logo.
  final int version;
  

  //---------------------------------------------------------------------------
  // Image
  //---------------------------------------------------------------------------

   
  final ImageAsset image;

  //---------------------------------------------------------------------------
  // Constructor
  //---------------------------------------------------------------------------

  const DoctorSignature({
    required this.id,
    required this.doctorId,
    required this.version,
    required this.image,
  });

    factory DoctorSignature.fromJson(Map<String, dynamic> json) {
    return DoctorSignature
    (
      id: json["_id"] ?? "",
      doctorId: json["doctorId"] ?? "",
      version: json["version"] ?? 0,
      image: ImageAsset.fromJson(json),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "doctorId": doctorId,
      "version": version,
      ...image.toJson(),      //Those three dots (...) are called the spread operator in Dart. It takes all the key-value pairs from one Map and inserts them into another Map.
    };
  }

 

  
}