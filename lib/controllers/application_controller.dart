
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:docautomations/application/application_bootstrapper.dart';

import 'package:docautomations/datamodels/master/master_data.dart';
import 'package:docautomations/datamodels/response/doctor_profile.dart';

import 'package:docautomations/device_assets/asset_manager.dart';
import 'package:docautomations/device_assets/asset_type.dart';

class ApplicationController extends ChangeNotifier {
  //-------------------------------------------------------------------------
  // Dependencies
  //-------------------------------------------------------------------------

  final ApplicationBootstrapper initializer;

  final AssetManager assetManager;

  //-------------------------------------------------------------------------
  // Constructor
  //-------------------------------------------------------------------------

  ApplicationController({
    required this.initializer,
    required this.assetManager,
  });

  //-------------------------------------------------------------------------
  // State
  //-------------------------------------------------------------------------

  MasterData? _masterData;

  bool _initialized = false;

  bool _loading = false;

  String? _errorMessage;

  String? _currentDoctorId;

  Uint8List? _doctorLogoBytes;

  Uint8List? _doctorSignatureBytes;

  //-------------------------------------------------------------------------
  // Getters
  //-------------------------------------------------------------------------

  MasterData get masterData {
    if (_masterData == null) {
      throw StateError(
        'ApplicationController has not been initialized.',
      );
    }

    return _masterData!;
  }

  bool get initialized => _initialized;

  bool get loading => _loading;

  String? get errorMessage => _errorMessage;

  Uint8List? get doctorLogoBytes => _doctorLogoBytes;

  Uint8List? get doctorSignatureBytes => _doctorSignatureBytes;

  String? get currentDoctorId => _currentDoctorId;

  //=========================================================================
  // Initialize
  //=========================================================================

  Future<MasterData> initialize({
    bool forceRefresh = false,
  }) async {
    if (_initialized && !forceRefresh) {
      return masterData;
    }

    _loading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final updatedMasterData =
          await initializer.initialize(
        forceRefresh: forceRefresh,
      );

      final doctorId =
          updatedMasterData.doctorProfile.doctor.id;

      if (doctorId.trim().isEmpty) {
        throw StateError(
          'Doctor ID is missing.',
        );
      }

      // Clear previous doctor's displayed images.

      if (_currentDoctorId != doctorId) {
        _doctorLogoBytes = null;
        _doctorSignatureBytes = null;
      }

      _currentDoctorId = doctorId;

      _masterData = updatedMasterData;

      // Load synchronized local images.

      await _loadDoctorAssets(doctorId);

      _initialized = true;

      return _masterData!;
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  //=========================================================================
  // Synchronize One Doctor Asset
  //=========================================================================

  Future<void> synchronizeDoctorAsset(
    AssetType assetType,
  ) async {
    final doctorId = _currentDoctorId;
    final currentMasterData = _masterData;

    if (doctorId == null || currentMasterData == null) {
      throw StateError(
        'Application is not initialized.',
      );
    }

    //----------------------------------------------------------------------
    // Step 1: Fetch Latest Doctor Profile
    //----------------------------------------------------------------------

    final latestProfile =
        await initializer.doctorRepository.fetchDoctorProfile();

    if (latestProfile.doctor.id != doctorId) {
      throw StateError(
        'Doctor account changed during asset synchronization.',
      );
    }

    //----------------------------------------------------------------------
    // Step 2: Synchronize Requested Asset
    //----------------------------------------------------------------------

    await initializer.synchronizeDoctorAsset(
      doctorId: doctorId,
      doctorProfile: latestProfile,
      assetType: assetType,
    );

    //----------------------------------------------------------------------
    // Step 3: Update Master Data
    //----------------------------------------------------------------------

    _masterData = currentMasterData.copyWith(
      doctorProfile: latestProfile,
    );

    //----------------------------------------------------------------------
    // Step 4: Load Updated Local Asset
    //----------------------------------------------------------------------

    final bytes = await assetManager.loadAsset(
      doctorId,
      assetType,
    );

    final imageBytes =
        bytes == null || bytes.isEmpty
            ? null
            : Uint8List.fromList(bytes);

    //----------------------------------------------------------------------
    // Step 5: Update In-Memory Image
    //----------------------------------------------------------------------

    switch (assetType) {
      case AssetType.logo:
        _doctorLogoBytes = imageBytes;
        break;

      case AssetType.signature:
        _doctorSignatureBytes = imageBytes;
        break;

      case AssetType.header:
      case AssetType.footer:
        break;
    }

    //----------------------------------------------------------------------
    // Step 6: Notify UI
    //----------------------------------------------------------------------

    notifyListeners();
  }

  //=========================================================================
  // Load Doctor Assets
  //=========================================================================

  Future<void> _loadDoctorAssets(
    String doctorId,
  ) async {
    final logoBytes =
        await assetManager.loadAsset(
      doctorId,
      AssetType.logo,
    );

    final signatureBytes =
        await assetManager.loadAsset(
      doctorId,
      AssetType.signature,
    );

    _doctorLogoBytes =
        logoBytes == null || logoBytes.isEmpty
            ? null
            : Uint8List.fromList(logoBytes);

    _doctorSignatureBytes =
        signatureBytes == null || signatureBytes.isEmpty
            ? null
            : Uint8List.fromList(signatureBytes);
  }

  //=========================================================================
  // Update Doctor Logo
  //=========================================================================

  Future<void> updateDoctorLogo(
    List<int>? bytes,
  ) async {
    _doctorLogoBytes =
        bytes == null || bytes.isEmpty
            ? null
            : Uint8List.fromList(bytes);

    notifyListeners();
  }

  //=========================================================================
  // Update Doctor Signature
  //=========================================================================

  Future<void> updateDoctorSignature(
    List<int>? bytes,
  ) async {
    _doctorSignatureBytes =
        bytes == null || bytes.isEmpty
            ? null
            : Uint8List.fromList(bytes);

    notifyListeners();
  }

  //=========================================================================
  // Update Doctor Profile
  //=========================================================================

  void updateDoctorProfile(
    DoctorProfile doctorProfile,
  ) {
    final currentData = _masterData;

    if (currentData == null) {
      throw StateError(
        'ApplicationController has not been initialized.',
      );
    }

    if (doctorProfile.doctor.id != _currentDoctorId) {
      throw StateError(
        'Cannot update profile for a different doctor.',
      );
    }

    _masterData = currentData.copyWith(
      doctorProfile: doctorProfile,
    );

    notifyListeners();
  }

  //=========================================================================
  // Refresh
  //=========================================================================

  Future<void> refresh() async {
    await initialize(
      forceRefresh: true,
    );
  }

  //=========================================================================
  // Clear
  //=========================================================================

  Future<void> clear() async {
    final doctorId = _currentDoctorId;

    // Clear in-memory state first.

    _masterData = null;

    _doctorLogoBytes = null;

    _doctorSignatureBytes = null;

    _currentDoctorId = null;

    _initialized = false;

    _loading = false;

    _errorMessage = null;

    notifyListeners();

    await initializer.clearCache(
      doctorId: doctorId,
    );
  }
}
