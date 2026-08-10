import 'package:docautomations/common/operation_result.dart';
import 'package:docautomations/datamodels/master/doctor_master.dart';
import 'package:docautomations/datamodels/request/doctor_registration_request.dart';
import 'package:docautomations/datamodels/response/doctor_profile.dart';
import 'package:docautomations/services/license_api_service.dart';

class DoctorRepository {
  //---------------------------------------------------------------------------
  // Dependencies
  //---------------------------------------------------------------------------

  final LicenseApiService apiService;

  //---------------------------------------------------------------------------
  // Constructor
  //---------------------------------------------------------------------------

  const DoctorRepository({
    required this.apiService,
  });

  //---------------------------------------------------------------------------
  // Register Doctor
  //---------------------------------------------------------------------------

  Future<OperationResult> registerDoctor(
    DoctorRegistrationRequest request,
  ) async {
    try {
      return await apiService.registerDoctor(
        request,
      );
    } catch (e) {
      return OperationResult.failure(
        e.toString(),
      );
    }
  }

  //---------------------------------------------------------------------------
  // Login
  //---------------------------------------------------------------------------

  Future<OperationResult> loginDoctor({
    required String email,
    required String password,
  }) async {
    try {
      return await apiService.loginDoctor(
        email: email,
        password: password,
      );
    } catch (e) {
      return OperationResult.failure(
        e.toString(),
      );
    }
  }


 //---------------------------------------------------------------------------
  // Doctor Profile
  //---------------------------------------------------------------------------

  Future<DoctorProfile> fetchDoctorProfile()  async {
    try {
      return apiService.fetchDoctorProfileFromServer();
    } catch (e) {
      return e.toString();
    }
  }


   


  

  
  //---------------------------------------------------------------------------
  // Update Doctor Profile
  //---------------------------------------------------------------------------

  Future<OperationResult> updateDoctorProfile(DoctorMaster doctor,) async {
    try {
      return await apiService.updateDoctorProfile();
    } catch (e) {
      return OperationResult.failure(
        e.toString(),
      );
    }
  }

  //---------------------------------------------------------------------------
  // Upload Logo
  //---------------------------------------------------------------------------

  Future<OperationResult> uploadDoctorLogo() async {
    try {
      return await apiService.uploadDoctorLogo();
    } catch (e) {
      return OperationResult.failure(
        e.toString(),
      );
    }
  }

  //---------------------------------------------------------------------------
  // Upload Signature
  //---------------------------------------------------------------------------

  Future<OperationResult> uploadDoctorSignature() async {
    try {
      return await apiService.uploadDoctorSignature();
    } catch (e) {
      return OperationResult.failure(
        e.toString(),
      );
    }
  }

  //---------------------------------------------------------------------------
  // Download Logo
  //---------------------------------------------------------------------------

  Future<List<int>> downloadDoctorLogo() {
    return apiService.downloadDoctorLogo();
  }

  //---------------------------------------------------------------------------
  // Download Signature
  //---------------------------------------------------------------------------

  Future<List<int>> downloadDoctorSignature() {
    return apiService.downloadDoctorSignature();
  }
}