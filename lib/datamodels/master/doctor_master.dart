class DoctorMaster {
  //---------------------------------------------------------------------------
  // Identity
  //---------------------------------------------------------------------------

  final String id;

  final String doctorCode;

  //---------------------------------------------------------------------------
  // Registration
  //---------------------------------------------------------------------------

  final String medicalRegistrationNumber;

  final String registrationCouncil;

  //---------------------------------------------------------------------------
  // Doctor
  //---------------------------------------------------------------------------

  final String doctorName;

  final String qualification;

  final String specialization;

  //---------------------------------------------------------------------------
  // Clinic
  //---------------------------------------------------------------------------

  final String clinicName;

  final String clinicAddress;

  final String city;

  final String district;

  final String state;

  final String? countryid;

  final String pinCode;

  //---------------------------------------------------------------------------
  // Contact
  //---------------------------------------------------------------------------

  final String mobileNumber;

  final String alternateMobileNumber;

  final String email;

  final String website;

  

  //---------------------------------------------------------------------------
  // Subscription
  //---------------------------------------------------------------------------

  final bool isSubscribed;

  final DateTime? subscriptionExpiry;

  //---------------------------------------------------------------------------
  // Constructor
  //---------------------------------------------------------------------------

  const DoctorMaster({

    required this.id,

    required this.doctorCode,

    required this.medicalRegistrationNumber,

    required this.registrationCouncil,

    required this.doctorName,

    required this.qualification,

    required this.specialization,

    required this.clinicName,

    required this.clinicAddress,

    required this.city,

    required this.district,

    required this.state,

    required this.countryid,

    required this.pinCode,

    required this.mobileNumber,

    required this.alternateMobileNumber,

    required this.email,

    required this.website,

    
    required this.isSubscribed,

    this.subscriptionExpiry,
  });

  factory DoctorMaster.fromJson(
      Map<String, dynamic> json) {

    return DoctorMaster(

      id: json["_id"] ?? "",

      doctorCode: json["doctorCode"] ?? "",

      medicalRegistrationNumber:
          json["medicalRegistrationNumber"] ?? "",

      registrationCouncil:
          json["registrationCouncil"] ?? "",

      doctorName:
          json["name"] ?? "",

      qualification:
          json["qualification"] ?? "",

      specialization:
          json["specialization"] ?? "",

      clinicName:
          json["clinicName"] ?? "",

      clinicAddress:
          json["clinicAddress"] ?? "",

      city:
          json["city"] ?? "",

      district:
          json["district"] ?? "",

      state:
          json["state"] ?? "",

      countryid: _readId(json["countryId"]),
          //json["countryId"] ?? "",

      pinCode:
          json["pincode"] ?? "",

      mobileNumber:
          json["contact"] ?? "",

      alternateMobileNumber:
          json["alternateContact"] ?? "",

      email:
          json["email"] ?? "",

      website:
          json["website"] ?? "",

      
      isSubscribed:
          json["isSubscribed"] ?? false,

      subscriptionExpiry:
          json["subscriptionExpiry"] != null
              ? DateTime.parse(
                  json["subscriptionExpiry"])
              : null,
    );
  }

  static String _readId(dynamic value) {
  if (value == null) return "";

  if (value is String) return value;

  if (value is Map) {
    return value["_id"]?.toString() ?? "";
  }

  return value.toString();
}

  Map<String, dynamic> toJson() {
  return {
    "_id": id,
    "doctorCode": doctorCode,

    "medicalRegistrationNumber":
        medicalRegistrationNumber,
    "registrationCouncil":
        registrationCouncil,

    "name": doctorName,
    "qualification": qualification,
    "specialization": specialization,

    "clinicName": clinicName,
    "clinicAddress": clinicAddress,
    "city": city,
    "district": district,
    "state": state,

    "countryId": countryid,
    "pincode": pinCode,

    "contact": mobileNumber,
    "alternateContact": alternateMobileNumber,

    "email": email,
    "website": website,

    "isSubscribed": isSubscribed,
    "subscriptionExpiry":
        subscriptionExpiry?.toIso8601String(),
  };
}
}