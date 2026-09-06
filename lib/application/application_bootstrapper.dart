import 'package:docautomations/datamodels/master/master_data.dart';

import 'package:docautomations/device_assets/asset_manager.dart';
import 'package:docautomations/device_assets/asset_type.dart';

import 'package:docautomations/repositories/doctor_repository.dart';
import 'package:docautomations/repositories/reference_data_repository.dart';

import 'package:docautomations/storage/local_storage_service.dart';


class ApplicationBootstrapper {

  //---------------------------------------------------------------------------
  // Dependencies
  //---------------------------------------------------------------------------

  final DoctorRepository doctorRepository;

  final ReferenceDataRepository referenceDataRepository;

  final AssetManager assetManager;

  final LocalStorageService localStorage;


  //---------------------------------------------------------------------------
  // Constructor
  //---------------------------------------------------------------------------

  const ApplicationBootstrapper({

    required this.doctorRepository,

    required this.referenceDataRepository,

    required this.assetManager,

    required this.localStorage,

  });


  //===========================================================================
  // Initialize Application
  //===========================================================================

  Future<MasterData> initialize({

    bool forceRefresh = false,

  }) async {

    //-----------------------------------------------------------------------
    // Step 1 : Try Local Cache
    //-----------------------------------------------------------------------

    if (!forceRefresh) {

      final cached =
          await localStorage.loadMasterData();

      if (cached != null) {

        return cached;

      }

    }


    //-----------------------------------------------------------------------
    // Step 2 : Download Doctor Profile
    //-----------------------------------------------------------------------

    final doctorProfile =
        await doctorRepository.fetchDoctorProfile();


    //-----------------------------------------------------------------------
    // Step 3 : Synchronize Doctor Logo
    //-----------------------------------------------------------------------

    await _synchronizeAsset(

      assetType:
          AssetType.logo,

      serverVersion:
          doctorProfile.assets.getVersion(
        AssetType.logo,
      ),

      downloader:
          doctorRepository.downloadDoctorLogo,

    );


    //-----------------------------------------------------------------------
    // Step 4 : Synchronize Doctor Signature
    //-----------------------------------------------------------------------

    await _synchronizeAsset(

      assetType:
          AssetType.signature,

      serverVersion:
          doctorProfile.assets.getVersion(
        AssetType.signature,
      ),

      downloader:
          doctorRepository.downloadDoctorSignature,

    );


    //-----------------------------------------------------------------------
    // Step 5 : Load Reference Data
    //-----------------------------------------------------------------------

    final countries =
        await referenceDataRepository.fetchCountries(
      forceRefresh: forceRefresh,
    );


    //-----------------------------------------------------------------------
    // Step 6 : Build Master Data
    //-----------------------------------------------------------------------

    final masterData =
        MasterData(

      doctorProfile:
          doctorProfile,

      countries:
          countries,

    );


    //-----------------------------------------------------------------------
    // Step 7 : Cache Master Data
    //-----------------------------------------------------------------------

    await localStorage.saveMasterData(
      masterData,
    );


    return masterData;

  }


  //===========================================================================
  // Refresh Application Data
  //===========================================================================

  Future<MasterData> refresh() {

    return initialize(
      forceRefresh: true,
    );

  }


  //===========================================================================
  // Synchronize Asset
  //===========================================================================

  Future<void> _synchronizeAsset({

    required AssetType assetType,

    required int serverVersion,

    required Future<List<int>> Function()
        downloader,

  }) async {

    //-----------------------------------------------------------------------
    // Check Synchronization Requirement
    //-----------------------------------------------------------------------

    final requiredSync =
        await assetManager.needsSynchronization(

      assetType,

      serverVersion,

    );


    if (!requiredSync) {

      return;

    }


    //-----------------------------------------------------------------------
    // Download Asset
    //-----------------------------------------------------------------------

    final bytes =
        await downloader();


    //-----------------------------------------------------------------------
    // Update Local Asset
    //-----------------------------------------------------------------------

    await assetManager.updateAsset(

      assetType:
          assetType,

      bytes:
          bytes,

      serverVersion:
          serverVersion,

    );

  }


  //===========================================================================
  // Clear Local Cache
  //===========================================================================

  Future<void> clearCache() async {

    await localStorage.clearMasters();

    await assetManager.clearAssets();

  }

}

