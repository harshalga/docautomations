import 'package:docautomations/services/image/procesed_image.dart';

class DoctorRegistrationRequest {

  //--------------------------------------------------------------------------- 
  // Personal Information
  //---------------------------------------------------------------------------

  final String doctorName;
  final String specialization;
  final String qualification;

  //--------------------------------------------------------------------------- 
  // Clinic Information
  //---------------------------------------------------------------------------

  final String clinicName;
  final String clinicAddress;
  final String city;
  final String state;
  final String pincode;

  //--------------------------------------------------------------------------- 
  // Contact Information
  //---------------------------------------------------------------------------

  final String contact;
  final String alternateContact;
  final String website;

  //--------------------------------------------------------------------------- 
  // Login Information
  //---------------------------------------------------------------------------

  final String loginEmail;
  final String password;

  //--------------------------------------------------------------------------- 
  // Medical Registration
  //---------------------------------------------------------------------------

  final String medicalRegistrationNumber;
  final String registrationAuthority;
  final String countryId;

  //--------------------------------------------------------------------------- 
  // Doctor Logo (Optional)
  //---------------------------------------------------------------------------

  final ProcessedImage? logo;

  //--------------------------------------------------------------------------- 
  // Constructor
  //---------------------------------------------------------------------------

  const DoctorRegistrationRequest({
    this.doctorName = '',
    this.specialization = '',
    this.qualification = '',
    this.clinicName = '',
    this.clinicAddress = '',
    this.city = '',
    this.state = '',
    this.pincode = '',
    this.contact = '',
    this.alternateContact = '',
    this.website = '',
    this.loginEmail = '',
    this.password = '',
    this.medicalRegistrationNumber = '',
    this.registrationAuthority = '',
    this.countryId = '',
    this.logo,
  });

  //--------------------------------------------------------------------------- 
  // Copy With
  //---------------------------------------------------------------------------

  DoctorRegistrationRequest copyWith({
    String? doctorName,
    String? specialization,
    String? qualification,
    String? clinicName,
    String? clinicAddress,
    String? city,
    String? state,
    String? pincode,
    String? contact,
    String? alternateContact,
    String? website,
    String? loginEmail,
    String? password,
    String? medicalRegistrationNumber,
    String? registrationAuthority,
    String? countryId,
    ProcessedImage? logo,
  }) {

    return DoctorRegistrationRequest(
      doctorName:
          doctorName ?? this.doctorName,

      specialization:
          specialization ?? this.specialization,

      qualification:
          qualification ?? this.qualification,

      clinicName:
          clinicName ?? this.clinicName,

      clinicAddress:
          clinicAddress ?? this.clinicAddress,

      city:
          city ?? this.city,

      state:
          state ?? this.state,

      pincode:
          pincode ?? this.pincode,

      contact:
          contact ?? this.contact,

      alternateContact:
          alternateContact ?? this.alternateContact,

      website:
          website ?? this.website,

      loginEmail:
          loginEmail ?? this.loginEmail,

      password:
          password ?? this.password,

      medicalRegistrationNumber:
          medicalRegistrationNumber ??
              this.medicalRegistrationNumber,

      registrationAuthority:
          registrationAuthority ??
              this.registrationAuthority,

      countryId:
          countryId ?? this.countryId,

      logo:
          logo ?? this.logo,
    );

  }

  //--------------------------------------------------------------------------- 
  // JSON Deserialization
  //---------------------------------------------------------------------------

  factory DoctorRegistrationRequest.fromJson(
      Map<String, dynamic> json) {

    return DoctorRegistrationRequest(
      doctorName:
          json["name"]?.toString() ?? "",

      specialization:
          json["specialization"]?.toString() ?? "",

      qualification:
          json["qualification"]?.toString() ?? "",

      clinicName:
          json["clinicName"]?.toString() ?? "",

      clinicAddress:
          json["clinicAddress"]?.toString() ?? "",

      city:
          json["city"]?.toString() ?? "",

      state:
          json["state"]?.toString() ?? "",

      pincode:
          json["pincode"]?.toString() ?? "",

      contact:
          json["contact"]?.toString() ?? "",

      alternateContact:
          json["alternateContact"]?.toString() ?? "",

      website:
          json["website"]?.toString() ?? "",

      loginEmail:
          json["loginEmail"]?.toString() ?? "",

      password:
          json["password"]?.toString() ?? "",

      medicalRegistrationNumber:
          json["medicalRegistrationNumber"]?.toString() ?? "",

      registrationAuthority:
          json["registrationAuthority"]?.toString() ?? "",

      countryId:
          json["countryId"]?.toString() ?? "",

      
    );

  }

  //--------------------------------------------------------------------------- 
  // JSON Serialization
  //---------------------------------------------------------------------------

  Map<String, dynamic> toJson() {

    return {

      "name":
          doctorName.trim(),

      "specialization":
          specialization.trim(),

      "qualification":
          qualification.trim(),

      "clinicName":
          clinicName.trim(),

      "clinicAddress":
          clinicAddress.trim(),

      "city":
          city.trim(),

      "state":
          state.trim(),

      "pincode":
          pincode.trim(),

      "contact":
          contact.trim(),

      "alternateContact":
          alternateContact.trim(),

      "website":
          website.trim(),

      "loginEmail":
          loginEmail.trim().toLowerCase(),

      "password":
          password,

      "medicalRegistrationNumber":
          medicalRegistrationNumber
              .trim()
              .toUpperCase(),

      "registrationAuthority":
          registrationAuthority.trim(),

      "countryId":
          countryId.trim(),

      "logo":
          logo?.toJson(),

    };

  }

  //--------------------------------------------------------------------------- 
  // Client-Side Validation
  //---------------------------------------------------------------------------

  bool get isValid {

    return

        // Personal Information
        doctorName.trim().isNotEmpty &&

        specialization.trim().isNotEmpty &&

        qualification.trim().isNotEmpty &&

        // Clinic Information
        clinicName.trim().isNotEmpty &&

        clinicAddress.trim().isNotEmpty &&

        city.trim().isNotEmpty &&

        state.trim().isNotEmpty &&

        pincode.trim().isNotEmpty &&

        // Contact Information
        contact.trim().isNotEmpty &&

        // Login Information
        loginEmail.trim().isNotEmpty &&

        password.trim().isNotEmpty &&

        // Medical Registration
        medicalRegistrationNumber
            .trim()
            .isNotEmpty &&

        registrationAuthority
            .trim()
            .isNotEmpty &&

        countryId.trim().isNotEmpty;

  }

}

