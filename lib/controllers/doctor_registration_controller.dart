// import 'package:docautomations/common/operation_result.dart';

// import 'package:docautomations/services/image/image_service.dart';
// import 'package:docautomations/services/image/procesed_image.dart';
// import 'package:flutter/foundation.dart';

// import 'package:docautomations/controllers/application_controller.dart';
// import 'package:docautomations/datamodels/master/country.dart';
// import 'package:docautomations/datamodels/request/doctor_registration_request.dart';
// import 'package:docautomations/repositories/doctor_repository.dart';


// class DoctorRegistrationController
//     extends ChangeNotifier {

//   //---------------------------------------------------------------------------
//   // Dependencies
//   //---------------------------------------------------------------------------

//   final DoctorRepository repository;

//   final ApplicationController applicationController;

//   final ImageService imageService;

//   //---------------------------------------------------------------------------
//   // Constructor
//   //---------------------------------------------------------------------------

//   DoctorRegistrationController({
//     required this.repository,
//     required this.applicationController,
//     required this.imageService,
//   });

//   //---------------------------------------------------------------------------
//   // State
//   //---------------------------------------------------------------------------

//   DoctorRegistrationRequest _request =
//       const DoctorRegistrationRequest();

//   bool _loading = false;

//   String _confirmPassword = "";

//   String? _errorMessage;

//   Country? _selectedCountry;

//   List<Country> _countries = const [];

//   ProcessedImage? _processedLogo;

//   //---------------------------------------------------------------------------
//   // Public Getters
//   //---------------------------------------------------------------------------

//   ProcessedImage? get processedLogo => 
//     _processedLogo;

//   DoctorRegistrationRequest get request =>
//       _request;

//   bool get isLoading =>
//       _loading;

//   String get confirmPassword =>
//       _confirmPassword;

//   String? get errorMessage =>
//       _errorMessage;

//   Country? get selectedCountry =>
//       _selectedCountry;

//   List<Country> get countries =>
//       _countries;

//   //---------------------------------------------------------------------------
//   // Initialize
//   //---------------------------------------------------------------------------

//   Future<void> initialize() async {

//     _countries =
//         applicationController
//             .masterData
//             .countries;

//     if (_countries.isNotEmpty) {

//       _selectedCountry =
//           null;

//       _request =
//           _request.copyWith(
//         countryId:
//             '',
//       );
//     }

//     notifyListeners();
//   }

//   //---------------------------------------------------------------------------
//   // Loading
//   //---------------------------------------------------------------------------

//   void _setLoading(
//     bool value,
//   ) {

//     _loading = value;

//     notifyListeners();
//   }

//   //---------------------------------------------------------------------------
//   // Error
//   //---------------------------------------------------------------------------

//   void clearError() {

//     _errorMessage = null;

//     notifyListeners();
//   }

//   void _setError(
//     String? message,
//   ) {

//     _errorMessage = message;

//     notifyListeners();
//   }

//   //---------------------------------------------------------------------------
//   // Country
//   //---------------------------------------------------------------------------

//   void setCountry(
//     Country? country,
//   ) {

//     if (country == null) {
//       return;
//     }

//     _selectedCountry = country;

//     _request =
//         _request.copyWith(
//       countryId: country.id,
//     );

//     notifyListeners();
//   }

//   //---------------------------------------------------------------------------
//   // Doctor Information
//   //---------------------------------------------------------------------------

//   void setDoctorName(
//     String value,
//   ) {

//     _request =
//         _request.copyWith(
//       doctorName: value,
//     );

//     notifyListeners();
//   }

//   void setSpecialization(
//     String value,
//   ) {

//     _request =
//         _request.copyWith(
//       specialization: value,
//     );

//     notifyListeners();
//   }

//   void setQualification(
//     String value,
//   ) {

//     _request =
//         _request.copyWith(
//       qualification: value,
//     );

//     notifyListeners();
//   }

//   //---------------------------------------------------------------------------
//   // Clinic
//   //---------------------------------------------------------------------------

//   void setClinicName(
//     String value,
//   ) {

//     _request =
//         _request.copyWith(
//       clinicName: value,
//     );

//     notifyListeners();
//   }

//   void setClinicAddress(
//     String value,
//   ) {

//     _request =
//         _request.copyWith(
//       clinicAddress: value,
//     );

//     notifyListeners();
//   }

//   void setCity(
//     String value,
//   ) {

//     _request =
//         _request.copyWith(
//       city: value,
//     );

//     notifyListeners();
//   }

//   void setState(
//     String value,
//   ) {

//     _request =
//         _request.copyWith(
//       state: value,
//     );

//     notifyListeners();
//   }

//   void setPincode(
//     String value,
//   ) {

//     _request =
//         _request.copyWith(
//       pincode: value,
//     );

//     notifyListeners();
//   }

//   //---------------------------------------------------------------------------
//   // Contact
//   //---------------------------------------------------------------------------

//   void setContact(
//     String value,
//   ) {

//     _request =
//         _request.copyWith(
//       contact: value,
//     );

//     notifyListeners();
//   }

//   void setAlternateContact(
//     String value,
//   ) {

//     _request =
//         _request.copyWith(
//       alternateContact: value,
//     );

//     notifyListeners();
//   }

//   void setWebsite(
//     String value,
//   ) {

//     _request =
//         _request.copyWith(
//       website: value,
//     );

//     notifyListeners();
//   }

//   //---------------------------------------------------------------------------
//   // Login
//   //---------------------------------------------------------------------------

//   void setLoginEmail(
//     String value,
//   ) {

//     _request =
//         _request.copyWith(
//       loginEmail: value,
//     );

//     notifyListeners();
//   }

//   void setPassword(
//     String value,
//   ) {

//     _request =
//         _request.copyWith(
//       password: value,
//     );

//     notifyListeners();
//   }

//   void setConfirmPassword(
//     String value,
//   ) {

//     _confirmPassword = value;

//     notifyListeners();
//   }
// //--select logo 

// Future<void> selectLogo() async {

//   final image =
//       await imageService.pickImage();

//   if (image == null) {
//     return;
//   }

//   _processedLogo = image;

//   _request =
//       _request.copyWith(
//     logo: image,
//   );

//   notifyListeners();
// }
// //
//   //---------------------------------------------------------------------------
//   // Medical Registration
//   //---------------------------------------------------------------------------

//   void setMedicalRegistrationNumber(
//     String value,
//   ) {

//     _request =
//         _request.copyWith(
//       medicalRegistrationNumber:
//           value,
//     );

//     notifyListeners();
//   }

//   void setRegistrationAuthority(
//     String value,
//   ) {

//     _request =
//         _request.copyWith(
//       registrationAuthority:
//           value,
//     );

//     notifyListeners();
//   }

//   //--------------------------------------------------------------------------
// // Business Validation
// //--------------------------------------------------------------------------

// bool get canRegister {

//   if (!_request.isValid) {
//     return false;
//   }

//   if (_request.password != _confirmPassword) {
//     return false;
//   }

//   if (_selectedCountry == null) {
//     return false;
//   }

//   return true;
// }

// bool get passwordsMatch =>
//     _request.password == _confirmPassword;

// //--------------------------------------------------------------------------
// // Register
// //--------------------------------------------------------------------------

// Future<OperationResult> register() async {

//   clearError();

//   if (!canRegister) {

//    final result = OperationResult.failure(
//       "Please complete all mandatory fields.",
//     );

//     _setError(result.message);

//     return result;
//   }

//   _setLoading(true);

//   try {

//     final result = await repository.registerDoctor(
//       _request,
//     );

//     if (!result.success) {
//       _setError(result.message);
//     }

//     return result;

//   } catch (e) {

//     final result = OperationResult.failure(
//       e.toString(),
//     );

//     _setError(result.message);

//     return result;

//   } finally {

//     _setLoading(false);

//   }
// }

// //--------------------------------------------------------------------------
// // Reset
// //--------------------------------------------------------------------------

// void reset() {

//   _request =
//       const DoctorRegistrationRequest();

//   _confirmPassword = "";

//   _processedLogo = null;

//   _errorMessage = null;


//   _selectedCountry = null;

//   // if (_countries.isNotEmpty) {

//   //   _selectedCountry =
//   //       null;

//   //   _request =
//   //       _request.copyWith(
//   //     countryId:
//   //         '',
//   //   );
//   // }

//   notifyListeners();
// }
// }



import 'package:flutter/foundation.dart';

import 'package:docautomations/datamodels/request/doctor_registration_request.dart';
import 'package:docautomations/repositories/doctor_repository.dart';


//=============================================================================
// DOCTOR REGISTRATION CONTROLLER
//=============================================================================
//
// Responsibilities:
//
//   • Maintain doctor registration screen state.
//   • Receive DoctorRegistrationRequest from the UI.
//   • Perform client-side request validation.
//   • Call DoctorRepository.
//   • Expose loading and error state to the RegistrationScreen.
//
// Architecture:
//
//   RegistrationScreen
//          ↓
//   DoctorRegistrationController
//          ↓
//   DoctorRepository
//          ↓
//   DoctorApiService
//          ↓
//   Backend
//
// The controller does NOT:
//
//   • Call Dio directly.
//   • Call AuthService directly.
//   • Access secure storage.
//   • Access SharedPreferences.
//   • Perform navigation.
//   • Contain UI widgets.
//   • Contain backend business rules.
//
//=============================================================================

class DoctorRegistrationController extends ChangeNotifier {

  //-------------------------------------------------------------------------
  // Constructor
  //-------------------------------------------------------------------------

  DoctorRegistrationController({
    required DoctorRepository doctorRepository,
  }) : _doctorRepository = doctorRepository;


  //-------------------------------------------------------------------------
  // Dependencies
  //-------------------------------------------------------------------------

  final DoctorRepository _doctorRepository;


  //-------------------------------------------------------------------------
  // State
  //-------------------------------------------------------------------------

  bool _isLoading = false;

  String? _errorMessage;


  //-------------------------------------------------------------------------
  // Public Getters
  //-------------------------------------------------------------------------

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;


  //-------------------------------------------------------------------------
  // Register Doctor
  //-------------------------------------------------------------------------
  //
  // The RegistrationScreen creates DoctorRegistrationRequest and passes it
  // here.
  //
  // This keeps all registration fields represented by the request model,
  // including:
  //
  //   • doctorName
  //   • specialization
  //   • qualification
  //   • clinic details
  //   • contact details
  //   • login details
  //   • medical registration details
  //   • country
  //   • optional logo
  //
  //-------------------------------------------------------------------------

  Future<bool> register(
    DoctorRegistrationRequest request,
  ) async {

    //-------------------------------------------------------------------------
    // Prevent duplicate registration requests
    //-------------------------------------------------------------------------

    if (_isLoading) {
      return false;
    }


    //-------------------------------------------------------------------------
    // Clear previous error
    //-------------------------------------------------------------------------

    _errorMessage = null;

    notifyListeners();


    //-------------------------------------------------------------------------
    // Client-side validation
    //-------------------------------------------------------------------------

    if (!request.isValid) {

      _errorMessage =
          "Please enter all required registration details.";

      notifyListeners();

      return false;
    }


    //-------------------------------------------------------------------------
    // Start loading
    //-------------------------------------------------------------------------

    _isLoading = true;

    notifyListeners();


    try {

      //=======================================================================
      // Call repository
      //=======================================================================

      final result =
          await _doctorRepository.registerDoctor(request);


      //=======================================================================
      // Registration successful
      //=======================================================================

      if (result.success) {

        _errorMessage = null;

        return true;
      }


      //=======================================================================
      // Registration failed
      //=======================================================================

      _errorMessage =
          result.message.isNotEmpty
              ? result.message
              : "Doctor registration failed.";

      return false;

    } catch (e, stackTrace) {

      //=======================================================================
      // Unexpected error
      //=======================================================================

      if (kDebugMode) {

        debugPrint(
          "DoctorRegistrationController.register error: $e",
        );

        debugPrintStack(
          stackTrace: stackTrace,
        );
      }


      _errorMessage =
          "Unable to complete registration. Please try again.";

      return false;

    } finally {

      //=======================================================================
      // Stop loading
      //=======================================================================

      _isLoading = false;

      notifyListeners();
    }
  }


  //-------------------------------------------------------------------------
  // Clear Error
  //-------------------------------------------------------------------------

  void clearError() {

    if (_errorMessage == null) {
      return;
    }

    _errorMessage = null;

    notifyListeners();
  }
}


