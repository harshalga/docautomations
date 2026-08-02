import 'package:docautomations/datamodels/master/image_asset.dart';

class DoctorLogo {
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

  const DoctorLogo({
    required this.id,
    required this.doctorId,
    required this.version,
    required this.image,
  });

    factory DoctorLogo.fromJson(Map<String, dynamic> json) {
    return DoctorLogo(
      id: json["_id"] ?? "",
      doctorId: json["doctorId"] ?? "",
      version: json["version"] ?? 0,
      image: ImageAsset.fromJson(json), // this line is used to create an instance of the ImageAsset class from the JSON data. It assumes that the JSON data contains the necessary fields to construct an ImageAsset object.
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "doctorId": doctorId,
      "version": version,
      ...image.toJson(), //Those three dots (...) are called the spread operator in Dart. It takes all the key-value pairs from one Map and inserts them into another Map.
    };
  }
  

}