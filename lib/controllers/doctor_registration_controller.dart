import 'package:docautomations/common/operation_result.dart';
import 'package:docautomations/datamodels/master/image_asset.dart';
import 'package:docautomations/services/image/image_service.dart';
import 'package:docautomations/services/image/procesed_image.dart';
import 'package:flutter/foundation.dart';
import '../../datamodels/master/doctor_logo.dart';
import 'package:docautomations/controllers/application_controller.dart';
import 'package:docautomations/datamodels/master/country.dart';
import 'package:docautomations/datamodels/request/doctor_registration_request.dart';
import 'package:docautomations/repositories/doctor_repository.dart';
import 'package:docautomations/services/image/procesed_image.dart';

class DoctorRegistrationController
    extends ChangeNotifier {

  //---------------------------------------------------------------------------
  // Dependencies
  //---------------------------------------------------------------------------

  final DoctorRepository repository;

  final ApplicationController applicationController;

  final ImageService imageService;

  //---------------------------------------------------------------------------
  // Constructor
  //---------------------------------------------------------------------------

  DoctorRegistrationController({
    required this.repository,
    required this.applicationController,
  });

  //---------------------------------------------------------------------------
  // State
  //---------------------------------------------------------------------------

  DoctorRegistrationRequest _request =
      const DoctorRegistrationRequest();

  bool _loading = false;

  String _confirmPassword = "";

  String? _errorMessage;

  Country? _selectedCountry;

  List<Country> _countries = const [];

  ProcessedImage? _processedLogo;

  //---------------------------------------------------------------------------
  // Public Getters
  //---------------------------------------------------------------------------

  ProcessedImage? get processedLogo => 
    _processedLogo;

  DoctorRegistrationRequest get request =>
      _request;

  bool get isLoading =>
      _loading;

  String get confirmPassword =>
      _confirmPassword;

  String? get errorMessage =>
      _errorMessage;

  Country? get selectedCountry =>
      _selectedCountry;

  List<Country> get countries =>
      _countries;

  //---------------------------------------------------------------------------
  // Initialize
  //---------------------------------------------------------------------------

  Future<void> initialize() async {

    _countries =
        applicationController
            .masterData
            .countries;

    if (_countries.isNotEmpty) {

      _selectedCountry =
          _countries.first;

      _request =
          _request.copyWith(
        countryId:
            _selectedCountry!.id,
      );
    }

    notifyListeners();
  }

  //---------------------------------------------------------------------------
  // Loading
  //---------------------------------------------------------------------------

  void _setLoading(
    bool value,
  ) {

    _loading = value;

    notifyListeners();
  }

  //---------------------------------------------------------------------------
  // Error
  //---------------------------------------------------------------------------

  void clearError() {

    _errorMessage = null;

    notifyListeners();
  }

  void _setError(
    String? message,
  ) {

    _errorMessage = message;

    notifyListeners();
  }

  //---------------------------------------------------------------------------
  // Country
  //---------------------------------------------------------------------------

  void setCountry(
    Country? country,
  ) {

    if (country == null) {
      return;
    }

    _selectedCountry = country;

    _request =
        _request.copyWith(
      countryId: country.id,
    );

    notifyListeners();
  }

  //---------------------------------------------------------------------------
  // Doctor Information
  //---------------------------------------------------------------------------

  void setDoctorName(
    String value,
  ) {

    _request =
        _request.copyWith(
      doctorName: value,
    );

    notifyListeners();
  }

  void setSpecialization(
    String value,
  ) {

    _request =
        _request.copyWith(
      specialization: value,
    );

    notifyListeners();
  }

  void setQualification(
    String value,
  ) {

    _request =
        _request.copyWith(
      qualification: value,
    );

    notifyListeners();
  }

  //---------------------------------------------------------------------------
  // Clinic
  //---------------------------------------------------------------------------

  void setClinicName(
    String value,
  ) {

    _request =
        _request.copyWith(
      clinicName: value,
    );

    notifyListeners();
  }

  void setClinicAddress(
    String value,
  ) {

    _request =
        _request.copyWith(
      clinicAddress: value,
    );

    notifyListeners();
  }

  void setCity(
    String value,
  ) {

    _request =
        _request.copyWith(
      city: value,
    );

    notifyListeners();
  }

  void setState(
    String value,
  ) {

    _request =
        _request.copyWith(
      state: value,
    );

    notifyListeners();
  }

  void setPincode(
    String value,
  ) {

    _request =
        _request.copyWith(
      pincode: value,
    );

    notifyListeners();
  }

  //---------------------------------------------------------------------------
  // Contact
  //---------------------------------------------------------------------------

  void setContact(
    String value,
  ) {

    _request =
        _request.copyWith(
      contact: value,
    );

    notifyListeners();
  }

  void setAlternateContact(
    String value,
  ) {

    _request =
        _request.copyWith(
      alternateContact: value,
    );

    notifyListeners();
  }

  void setWebsite(
    String value,
  ) {

    _request =
        _request.copyWith(
      website: value,
    );

    notifyListeners();
  }

  //---------------------------------------------------------------------------
  // Login
  //---------------------------------------------------------------------------

  void setLoginEmail(
    String value,
  ) {

    _request =
        _request.copyWith(
      loginEmail: value,
    );

    notifyListeners();
  }

  void setPassword(
    String value,
  ) {

    _request =
        _request.copyWith(
      password: value,
    );

    notifyListeners();
  }

  void setConfirmPassword(
    String value,
  ) {

    _confirmPassword = value;

    notifyListeners();
  }
//--select logo 

Future<void> selectLogo() async {

  final image =
      await imageService.pickImage();

  if (image == null) {
    return;
  }

  _processedLogo = image;

  _request =
      _request.copyWith(
    logo: image,
  );

  notifyListeners();
}
//
  //---------------------------------------------------------------------------
  // Medical Registration
  //---------------------------------------------------------------------------

  void setMedicalRegistrationNumber(
    String value,
  ) {

    _request =
        _request.copyWith(
      medicalRegistrationNumber:
          value,
    );

    notifyListeners();
  }

  void setRegistrationAuthority(
    String value,
  ) {

    _request =
        _request.copyWith(
      registrationAuthority:
          value,
    );

    notifyListeners();
  }

  //--------------------------------------------------------------------------
// Business Validation
//--------------------------------------------------------------------------

bool get canRegister {

  if (!_request.isValid) {
    return false;
  }

  if (_request.password != _confirmPassword) {
    return false;
  }

  if (_selectedCountry == null) {
    return false;
  }

  return true;
}

bool get passwordsMatch =>
    _request.password == _confirmPassword;

//--------------------------------------------------------------------------
// Register
//--------------------------------------------------------------------------

Future<OperationResult> register() async {

  clearError();

  if (!canRegister) {

   final result = OperationResult.failure(
      "Please complete all mandatory fields.",
    );

    _setError(result.message);

    return result;
  }

  _setLoading(true);

  try {

    final result = await repository.registerDoctor(
      _request,
    );

    if (!result.success) {
      _setError(result.message);
    }

    return result;

  } catch (e) {

    final result = OperationResult.failure(
      e.toString(),
    );

    _setError(result.message);

    return result;

  } finally {

    _setLoading(false);

  }
}

//--------------------------------------------------------------------------
// Reset
//--------------------------------------------------------------------------

void reset() {

  _request =
      const DoctorRegistrationRequest();

  _confirmPassword = "";

  _processedLogo = null;

  _errorMessage = null;

  if (_countries.isNotEmpty) {

    _selectedCountry =
        _countries.first;

    _request =
        _request.copyWith(
      countryId:
          _selectedCountry!.id,
    );
  }

  notifyListeners();
}
}