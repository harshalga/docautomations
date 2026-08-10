import 'package:docautomations/datamodels/master/master_data.dart';
import 'package:docautomations/device_assets/asset_manager.dart';
import 'package:docautomations/device_assets/asset_type.dart';
import 'package:docautomations/repositories/doctor_repository.dart';
import 'package:docautomations/repositories/referenced_data_repository.dart';
import 'package:docautomations/storage/local_storage_service.dart';

class ApplicationBootstrapper {
  //---------------------------------------------------------------------------
  // Dependencies
  //---------------------------------------------------------------------------

  final DoctorRepository doctorRepository;

  final MasterRepository masterRepository;

  final AssetManager assetManager;

  final LocalStorageService localStorage;

  const ApplicationBootstrapper({
    required this.doctorRepository,
    required this.masterRepository,
    required this.assetManager,
    required this.localStorage,
  });

  //---------------------------------------------------------------------------
  // Initialize Application
  //---------------------------------------------------------------------------

  Future<MasterData> initialize({
    bool forceRefresh = false,
  }) async {
    //---------------------------------------------------------
    // Step 1 : Try Local Cache
    //---------------------------------------------------------

    if (!forceRefresh) {
      final cached =
          await localStorage.loadMasterData();

      if (cached != null) {
        return cached;
      }
    }

    //---------------------------------------------------------
    // Step 2 : Download Doctor Profile
    //---------------------------------------------------------

    final doctorProfile =
        await doctorRepository.fetchDoctorProfile();

    //---------------------------------------------------------
    // Step 3 : Synchronize Assets
    //---------------------------------------------------------

    await _synchronizeAsset(
      assetType: AssetType.logo,
      serverVersion: doctorProfile.assets.getVersion(
        AssetType.logo,
      ),
      downloader:
          doctorRepository.downloadDoctorLogo,
    );

    await _synchronizeAsset(
      assetType: AssetType.signature,
      serverVersion:
          doctorProfile.assets.getVersion(
        AssetType.signature,
      ),
      downloader:
          doctorRepository.downloadDoctorSignature,
    );

    //---------------------------------------------------------
    // Step 4 : Load Masters
    //---------------------------------------------------------

    final countries =
        await masterRepository.fetchCountries();

    //---------------------------------------------------------
    // Step 5 : Build MasterData
    //---------------------------------------------------------

    final masterData = MasterData(
      doctorProfile: doctorProfile,
      countries: countries,
    );

    //---------------------------------------------------------
    // Step 6 : Cache
    //---------------------------------------------------------

    await localStorage.saveMasterData(
      masterData,
    );

    return masterData;
  }

  //---------------------------------------------------------------------------
  // Refresh
  //---------------------------------------------------------------------------

  Future<MasterData> refresh() {
    return initialize(
      forceRefresh: true,
    );
  }

  //---------------------------------------------------------------------------
  // Synchronize Asset
  //---------------------------------------------------------------------------

  Future<void> _synchronizeAsset({
    required AssetType assetType,
    required int serverVersion,
    required Future<List<int>> Function()
        downloader,
  }) async {
    final requiredSync =
        await assetManager.needsSynchronization(
      assetType,
      serverVersion,
    );

    if (!requiredSync) {
      return;
    }

    final bytes = await downloader();

    await assetManager.updateAsset(
      assetType: assetType,
      bytes: bytes,
      serverVersion: serverVersion,
    );
  }

  //---------------------------------------------------------------------------
  // Clear Local Cache
  //---------------------------------------------------------------------------

  Future<void> clearCache() async {
    await localStorage.clearMasters();
    await assetManager.clearAssets();
  }
}