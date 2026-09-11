// import 'package:docautomations/common/operation_result.dart';
// import 'package:docautomations/datamodels/master/doctor_master.dart';
// import 'package:docautomations/datamodels/request/doctor_registration_request.dart';
// import 'package:docautomations/datamodels/response/doctor_profile.dart';
// import 'package:docautomations/services/doctor_api_service.dart';

// class DoctorRepository {
//   //---------------------------------------------------------------------------
//   // Dependencies
//   //---------------------------------------------------------------------------

//   final DoctorApiService apiService;

//   //---------------------------------------------------------------------------
//   // Constructor
//   //---------------------------------------------------------------------------

//   const DoctorRepository({
//     required this.apiService,
//   });

//   //---------------------------------------------------------------------------
//   // Register Doctor
//   //---------------------------------------------------------------------------

//   Future<OperationResult> registerDoctor(
//     DoctorRegistrationRequest request,
//   ) async {
//     try {
//       return await apiService.registerDoctor(
//         request,
//       );
//     } catch (e) {
//       return OperationResult.failure(
//         e.toString(),
//       );
//     }
//   }

//   //---------------------------------------------------------------------------
//   // Login
//   //---------------------------------------------------------------------------

//   Future<OperationResult> loginDoctor({
//     required String email,
//     required String password,
//   }) async {
//     try {
//       return await apiService.loginDoctor(
//         email: email,
//         password: password,
//       );
//     } catch (e) {
//       return OperationResult.failure(
//         e.toString(),
//       );
//     }
//   }


//  //---------------------------------------------------------------------------
//   // Doctor Profile
//   //---------------------------------------------------------------------------

//   Future<DoctorProfile> fetchDoctorProfile()  async {
//     try {
//       return apiService.fetchDoctorProfileFromServer();
//     } catch (e) {
//       return e.toString();
//     }
//   }


   


  

  
//   //---------------------------------------------------------------------------
//   // Update Doctor Profile
//   //---------------------------------------------------------------------------

//   Future<OperationResult> updateDoctorProfile(DoctorMaster doctor,) async {
//     try {
//       return await apiService.updateDoctorProfile();
//     } catch (e) {
//       return OperationResult.failure(
//         e.toString(),
//       );
//     }
//   }

//   //---------------------------------------------------------------------------
//   // Upload Logo
//   //---------------------------------------------------------------------------

//   Future<OperationResult> uploadDoctorLogo() async {
//     try {
//       return await apiService.uploadDoctorLogo();
//     } catch (e) {
//       return OperationResult.failure(
//         e.toString(),
//       );
//     }
//   }

//   //---------------------------------------------------------------------------
//   // Upload Signature
//   //---------------------------------------------------------------------------

//   Future<OperationResult> uploadDoctorSignature() async {
//     try {
//       return await apiService.uploadDoctorSignature();
//     } catch (e) {
//       return OperationResult.failure(
//         e.toString(),
//       );
//     }
//   }

//   //---------------------------------------------------------------------------
//   // Download Logo
//   //---------------------------------------------------------------------------

//   Future<List<int>> downloadDoctorLogo() {
//     return apiService.downloadDoctorLogo();
//   }

//   //---------------------------------------------------------------------------
//   // Download Signature
//   //---------------------------------------------------------------------------

//   Future<List<int>> downloadDoctorSignature() {
//     return apiService.downloadDoctorSignature();
//   }
// }


import 'package:docautomations/common/operation_result.dart';

import 'package:docautomations/datamodels/master/doctor_master.dart';

import 'package:docautomations/datamodels/request/doctor_registration_request.dart';

import 'package:docautomations/datamodels/response/doctor_profile.dart';

import 'package:docautomations/services/doctor_api_service.dart';


class DoctorRepository {

  //===========================================================================
  // Dependencies
  //===========================================================================

  final DoctorApiService apiService;


  //===========================================================================
  // Constructor
  //===========================================================================

  const DoctorRepository({

    required this.apiService,

  });


  //===========================================================================
  // Register Doctor
  //===========================================================================

  Future<OperationResult> registerDoctor(

    DoctorRegistrationRequest request,

  ) async {

    try {

      final response =
          await apiService.registerDoctor(
        request,
      );


      if (response["success"] == true) {

        return OperationResult.success(

          response["message"] ??
              "Doctor registered successfully.",

          data: response["data"],

        );

      }


      return OperationResult.failure(

        response["message"] ??
            "Doctor registration failed.",

      );

    }
    catch (error) {

      return OperationResult.failure(
        error.toString(),
      );

    }

  }


  //===========================================================================
  // Fetch Doctor Profile
  //===========================================================================

  Future<DoctorProfile> fetchDoctorProfile() async {

    try {

      return await apiService.fetchDoctorProfile();

    }
    catch (error) {

      throw Exception(
        error.toString(),
      );

    }

  }


  //===========================================================================
  // Update Doctor Profile
  //===========================================================================

  Future<OperationResult> updateDoctorProfile(

    DoctorMaster doctor,

  ) async {

    try {

      final response =
          await apiService.updateDoctorProfile(

        doctor.toJson(),

      );


      if (response["success"] == true) {

        return OperationResult.success(

          response["message"] ??
              "Doctor profile updated successfully.",

          data: response["data"],

        );

      }


      return OperationResult.failure(

        response["message"] ??
            "Unable to update doctor profile.",

      );

    }
    catch (error) {

      return OperationResult.failure(
        error.toString(),
      );

    }

  }


  //===========================================================================
  // Upload Doctor Logo
  //===========================================================================

  Future<OperationResult> uploadDoctorLogo({

    required List<int> bytes,

    required String mimeType,

  }) async {

    try {

      final response =
          await apiService.uploadDoctorLogo(

        bytes: bytes,

        mimeType: mimeType,

      );


      if (response["success"] == true) {

        return OperationResult.success(

          response["message"] ??
              "Doctor logo uploaded successfully.",

          data: response["data"],

        );

      }


      return OperationResult.failure(

        response["message"] ??
            "Unable to upload doctor logo.",

      );

    }
    catch (error) {

      return OperationResult.failure(
        error.toString(),
      );

    }

  }


  //===========================================================================
  // Download Doctor Logo
  //===========================================================================

  Future<List<int>> downloadDoctorLogo() async {

    try {

      return await apiService.downloadDoctorLogo();

    }
    catch (error) {

      throw Exception(
        error.toString(),
      );

    }

  }


  //===========================================================================
  // Upload Doctor Signature
  //===========================================================================

  Future<OperationResult> uploadDoctorSignature({

    required List<int> bytes,

    required String mimeType,

  }) async {

    try {

      final response =
          await apiService.uploadDoctorSignature(

        bytes: bytes,

        mimeType: mimeType,

      );


      if (response["success"] == true) {

        return OperationResult.success(

          response["message"] ??
              "Doctor signature uploaded successfully.",

          data: response["data"],

        );

      }


      return OperationResult.failure(

        response["message"] ??
            "Unable to upload doctor signature.",

      );

    }
    catch (error) {

      return OperationResult.failure(
        error.toString(),
      );

    }

  }


  //===========================================================================
  // Download Doctor Signature
  //===========================================================================

  Future<List<int>> downloadDoctorSignature() async {

    try {

      return await apiService.downloadDoctorSignature();

    }
    catch (error) {

      throw Exception(
        error.toString(),
      );

    }

  }

}

