import 'dart:convert';

import 'package:docautomations/datamodels/master/country.dart';
import 'package:docautomations/datamodels/master/master_data.dart';
import 'package:docautomations/datamodels/master/prescription_layout.dart';
import 'package:docautomations/datamodels/response/doctor_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _doctorProfileKey = "doctor_profile";

  static const String _countriesKey = "countries";

  static const String _prescriptionLayoutKey =
      "prescription_layout";

  const LocalStorageService();

  //==============================================================
  // Generic Helpers
  //==============================================================

  Future<void> saveJson(
    String key,
    Map<String, dynamic> json,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
      key,
      jsonEncode(json),
    );
  }

  Future<Map<String, dynamic>?> loadJson(
    String key,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    final value =
        prefs.getString(key);

    if (value == null || value.isEmpty) {
      return null;
    }

    return Map<String, dynamic>.from(
      jsonDecode(value),
    );
  }

  Future<void> saveList(
    String key,
    List<Map<String, dynamic>> list,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
      key,
      jsonEncode(list),
    );
  }

  Future<List<dynamic>> loadList(
    String key,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    final value =
        prefs.getString(key);

    if (value == null || value.isEmpty) {
      return [];
    }

    return List<dynamic>.from(
      jsonDecode(value),
    );
  }

  Future<void> remove(
    String key,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.remove(key);
  }

  Future<void> clear() async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.clear();
  }

  //==============================================================
  // MasterData
  //==============================================================

  Future<MasterData?> loadMasterData() async {
    final doctor =
        await loadDoctorProfile();

    if (doctor == null) {
      return null;
    }

    final layout =
        await loadPrescriptionLayout();

    if (layout == null) {
      return null;
    }

    return MasterData(
      doctorProfile: doctor,
      countries: await loadCountries(),
      prescriptionLayout: layout,
    );
  }

  Future<void> saveMasterData(
    MasterData data,
  ) async {
    await saveDoctorProfile(
      data.doctorProfile,
    );

    await saveCountries(
      data.countries,
    );

    await savePrescriptionLayout(
      data.prescriptionLayout,
    );
  }

  //==============================================================
  // Doctor Profile
  //==============================================================

  Future<void> saveDoctorProfile(
    DoctorProfile profile,
  ) async {
    await saveJson(
      _doctorProfileKey,
      profile.toJson(),
    );
  }

  Future<DoctorProfile?> loadDoctorProfile() async {
    final json =
        await loadJson(
      _doctorProfileKey,
    );

    if (json == null) {
      return null;
    }

    return DoctorProfile.fromJson(
      json,
    );
  }

  Future<void> clearDoctorProfile() async {
    await remove(
      _doctorProfileKey,
    );
  }

  //==============================================================
  // Countries
  //==============================================================

  Future<void> saveCountries(
    List<Country> countries,
  ) async {
    await saveList(
      _countriesKey,
      countries
          .map(
            (e) => e.toJson(),
          )
          .toList(),
    );
  }

  Future<List<Country>> loadCountries() async {
    final list =
        await loadList(
      _countriesKey,
    );

    return list
        .map(
          (e) => Country.fromJson(
            Map<String, dynamic>.from(e),
          ),
        )
        .toList();
  }

  Future<void> clearCountries() async {
    await remove(
      _countriesKey,
    );
  }

  //==============================================================
  // Prescription Layout
  //==============================================================

  Future<void> savePrescriptionLayout(
    PrescriptionLayout layout,
  ) async {
    await saveJson(
      _prescriptionLayoutKey,
      layout.toJson(),
    );
  }

  Future<PrescriptionLayout?>
      loadPrescriptionLayout() async {
    final json =
        await loadJson(
      _prescriptionLayoutKey,
    );

    if (json == null) {
      return null;
    }

    return PrescriptionLayout.fromJson(
      json,
    );
  }

  Future<void> clearPrescriptionLayout() async {
    await remove(
      _prescriptionLayoutKey,
    );
  }

  //==============================================================
  // Masters
  //==============================================================

  Future<void> clearMasters() async {
    await clearDoctorProfile();
    await clearCountries();
    await clearPrescriptionLayout();
  }
}