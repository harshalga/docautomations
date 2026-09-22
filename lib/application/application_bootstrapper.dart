import 'package:docautomations/datamodels/master/master_data.dart';

import 'package:docautomations/device_assets/asset_manager.dart';
import 'package:docautomations/device_assets/asset_type.dart';

import 'package:docautomations/repositories/doctor_repository.dart';
import 'package:docautomations/repositories/reference_data_repository.dart';

import 'package:docautomations/storage/local_storage_service.dart';

class ApplicationBootstrapper {
  //--------------------------------------------------------------------------
  // Dependencies
  //--------------------------------------------------------------------------

  final DoctorRepository doctorRepository;

  final ReferenceDataRepository referenceDataRepository;

  final AssetManager assetManager;

  final LocalStorageService localStorage;

  //--------------------------------------------------------------------------
  // Constructor
  //--------------------------------------------------------------------------

  const ApplicationBootstrapper({
    required this.doctorRepository,
    required this.referenceDataRepository,
    required this.assetManager,
    required this.localStorage,
  });

  //==========================================================================
  // Initialize Application
  //==========================================================================

  Future<MasterData> initialize({
    bool forceRefresh = false,
  }) async {
    //----------------------------------------------------------------------
    // Step 1: Try Local Cache
    //----------------------------------------------------------------------

    if (!forceRefresh) {
      final cached = await localStorage.loadMasterData();

      if (cached != null) {
        return cached;
      }
    }

    //----------------------------------------------------------------------
    // Step 2: Download Doctor Profile
    //----------------------------------------------------------------------

    final doctorProfile =
        await doctorRepository.fetchDoctorProfile();

    //----------------------------------------------------------------------
    // Step 3: Synchronize Doctor Logo
    //----------------------------------------------------------------------

    final logoMetadata =
        doctorProfile.assets.getAsset(AssetType.logo);

    await _synchronizeAsset(
      assetType: AssetType.logo,
      serverExists: logoMetadata.exists,
      serverVersion: logoMetadata.version,
      downloader: doctorRepository.downloadDoctorLogo,
    );

    //----------------------------------------------------------------------
    // Step 4: Synchronize Doctor Signature
    //----------------------------------------------------------------------

    final signatureMetadata =
        doctorProfile.assets.getAsset(AssetType.signature);

    await _synchronizeAsset(
      assetType: AssetType.signature,
      serverExists: signatureMetadata.exists,
      serverVersion: signatureMetadata.version,
      downloader: doctorRepository.downloadDoctorSignature,
    );

    // //----------------------------------------------------------------------
    // // Step 5: Synchronize Header
    // //----------------------------------------------------------------------

    // final headerMetadata =
    //     doctorProfile.assets.getAsset(AssetType.header);

    // await _synchronizeAsset(
    //   assetType: AssetType.header,
    //   serverExists: headerMetadata.exists,
    //   serverVersion: headerMetadata.version,
    //   downloader: doctorRepository.downloadDoctorHeader,
    // );

    // //----------------------------------------------------------------------
    // // Step 6: Synchronize Footer
    // //----------------------------------------------------------------------

    // final footerMetadata =
    //     doctorProfile.assets.getAsset(AssetType.footer);

    // await _synchronizeAsset(
    //   assetType: AssetType.footer,
    //   serverExists: footerMetadata.exists,
    //   serverVersion: footerMetadata.version,
    //   downloader: doctorRepository.downloadDoctorFooter,
    // );

    //----------------------------------------------------------------------
    // Step 7: Load Reference Data
    //----------------------------------------------------------------------

    final countries =
        await referenceDataRepository.fetchCountries(
      forceRefresh: forceRefresh,
    );

    //----------------------------------------------------------------------
    // Step 8: Build Master Data
    //----------------------------------------------------------------------

    final masterData = MasterData(
      doctorProfile: doctorProfile,
      countries: countries,
    );

    //----------------------------------------------------------------------
    // Step 9: Cache Master Data
    //----------------------------------------------------------------------

    await localStorage.saveMasterData(masterData);

    return masterData;
  }

  //==========================================================================
  // Refresh Application Data
  //==========================================================================

  Future<MasterData> refresh() {
    return initialize(forceRefresh: true);
  }

  //==========================================================================
  // Synchronize Asset
  //==========================================================================

  Future<void> _synchronizeAsset({
    required AssetType assetType,
    required bool serverExists,
    required int serverVersion,
    required Future<List<int>> Function() downloader,
  }) async {
    //----------------------------------------------------------------------
    // Step 1: Check Whether Asset Exists on Server
    //----------------------------------------------------------------------

    if (!serverExists) {
      return;
    }

    //----------------------------------------------------------------------
    // Step 2: Check Synchronization Requirement
    //----------------------------------------------------------------------

    final requiredSync =
        await assetManager.needsSynchronization(
      assetType,
      serverVersion,
    );

    if (!requiredSync) {
      return;
    }

    //----------------------------------------------------------------------
    // Step 3: Download Asset
    //----------------------------------------------------------------------

    final bytes = await downloader();

    //----------------------------------------------------------------------
    // Step 4: Update Local Asset
    //----------------------------------------------------------------------

    await assetManager.updateAsset(
      assetType: assetType,
      bytes: bytes,
      serverVersion: serverVersion,
    );
  }

  //==========================================================================
  // Clear Local Cache
  //==========================================================================

  Future<void> clearCache() async {
    await localStorage.clearMasters();

    await assetManager.clearAssets();
  }
}