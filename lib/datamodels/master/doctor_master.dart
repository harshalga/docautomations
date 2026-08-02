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
          json["doctorName"] ?? "",

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

      countryid:
          json["countryid"] ?? "",

      pinCode:
          json["pinCode"] ?? "",

      mobileNumber:
          json["mobileNumber"] ?? "",

      alternateMobileNumber:
          json["alternateMobileNumber"] ?? "",

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

  Map<String, dynamic> toJson() {

    return {

      "_id": id,

      "doctorCode": doctorCode,

      "medicalRegistrationNumber":
          medicalRegistrationNumber,

      "registrationCouncil":
          registrationCouncil,

      "doctorName":
          doctorName,

      "qualification":
          qualification,

      "specialization":
          specialization,

      "clinicName":
          clinicName,

      "clinicAddress":
          clinicAddress,

      "city":
          city,

      "district":
          district,

      "state":
          state,

      "country":
          countryid,

      "pinCode":
          pinCode,

      "mobileNumber":
          mobileNumber,

      "alternateMobileNumber":
          alternateMobileNumber,

      "email":
          email,

      "website":
          website,

      
      "isSubscribed":
          isSubscribed,

      "subscriptionExpiry":
          subscriptionExpiry
              ?.toIso8601String(),
    };
  }
}