import 'package:docautomations/datamodels/master/country.dart';
import 'package:docautomations/datamodels/response/doctor_profile.dart';
import 'package:flutter/material.dart';

class ApplicationController extends ChangeNotifier {
  DoctorProfile? _doctorProfile;

  List<Country> _countries = [];

  bool _initialized = false;

  bool _loading = false;

  String? _errorMessage;

  //-------------------------------------------------------------
  // Getters
  //-------------------------------------------------------------

  DoctorProfile? get doctorProfile => _doctorProfile;

  List<Country> get countries => List.unmodifiable(_countries);

  bool get initialized => _initialized;

  bool get loading => _loading;

  String? get errorMessage => _errorMessage;

  //-------------------------------------------------------------
  // Initialization
  //-------------------------------------------------------------

  Future<void> initialize() async {
    if (_initialized) return;

    _loading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      await _loadMasters();

      _initialized = true;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _loading = false;

      notifyListeners();
    }
  }

  //-------------------------------------------------------------
  // Load Masters
  //-------------------------------------------------------------

  Future<void> _loadMasters() async {
    //
    // Step 1
    // Load DoctorProfile from local cache
    //

    // _doctorProfile =
    //     await LocalStorageService.loadDoctorProfile();

    //
    // Step 2
    // Load Countries from cache
    //

    // _countries =
    //     await LocalStorageService.loadCountries();

    //
    // Step 3
    // Refresh from server if required
    //

    // await _refreshMasters();
  }

  //-------------------------------------------------------------
  // Refresh from Server
  //-------------------------------------------------------------

  Future<void> refreshMasters() async {
    //
    // TODO
    //
    // _doctorProfile =
    //      await DoctorApiService.getDoctorProfile();
    //
    // _countries =
    //      await MasterApiService.getCountries();
    //
    // await LocalStorageService.saveDoctorProfile(_doctorProfile!);
    // await LocalStorageService.saveCountries(_countries);
    //
    // notifyListeners();
  }

  //-------------------------------------------------------------
  // Clear
  //-------------------------------------------------------------

  Future<void> clear() async {
    _doctorProfile = null;

    _countries.clear();

    _initialized = false;

    _errorMessage = null;

    notifyListeners();
  }
}