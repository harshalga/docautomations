// import 'package:docautomations/datamodels/master/master_data.dart';
// import 'package:docautomations/device_assets/asset_manager.dart';
// import 'package:docautomations/device_assets/asset_type.dart';
// import 'package:docautomations/services/license_api_service.dart';
// import 'package:docautomations/storage/local_storage_service.dart';

// class MasterRepository {
//   final LicenseApiService apiService;

//   final AssetManager assetManager;

//   final LocalStorageService localStorage;

//   const MasterRepository({
//     required this.apiService,
//     required this.assetManager,
//     required this.localStorage,
//   });

//   //---------------------------------------------------------
//   // MasterData
//   //---------------------------------------------------------

//   Future<MasterData> initialize({
//     bool forceRefresh = false,
//   }) async {
//     //-------------------------------------------------------
//     // Try Local Cache
//     //-------------------------------------------------------

//     if (!forceRefresh) {
//       final cached =
//           await localStorage.loadMasterData();

//       if (cached != null) {
//         return cached;
//       }
//     }

//     //-------------------------------------------------------
//     // Fetch From Server
//     //-------------------------------------------------------

//     final doctorProfile =
//         await apiService.fetchDoctorProfileFromServer();

//     final countries =
//         await apiService.fetchCountriesFromServer();

//     //-------------------------------------------------------
//     // Synchronize Doctor Assets
//     //-------------------------------------------------------

//     await _synchronizeAsset(
//       assetType: AssetType.logo,
//       serverVersion: doctorProfile.assets
//           .getVersion(AssetType.logo),
//       downloader: apiService.downloadDoctorLogo,
//     );

//     await _synchronizeAsset(
//       assetType: AssetType.signature,
//       serverVersion: doctorProfile.assets
//           .getVersion(AssetType.signature),
//       downloader: apiService.downloadDoctorSignature,
//     );

//     //-------------------------------------------------------
//     // Build MasterData
//     //-------------------------------------------------------

//     final masterData = MasterData(
//       doctorProfile: doctorProfile,
//       countries: countries,
//     );

//     //-------------------------------------------------------
//     // Cache
//     //-------------------------------------------------------

//     await localStorage.saveMasterData(
//       masterData,
//     );

//     return masterData;
//   }

//   //---------------------------------------------------------
//   // Refresh
//   //---------------------------------------------------------

//   Future<MasterData> refreshMasterData() async {
//     return initialize(
//       forceRefresh: true,
//     );
//   }

//   //---------------------------------------------------------
//   // Synchronize Asset
//   //---------------------------------------------------------

//   Future<void> _synchronizeAsset({
//     required AssetType assetType,
//     required int serverVersion,
//     required Future<List<int>> Function()
//         downloader,
//   }) async {
//     final requiredSync =
//         await assetManager.needsSynchronization(
//       assetType,
//       serverVersion,
//     );

//     if (!requiredSync) {
//       return;
//     }

//     final bytes =
//         await downloader();

//     await assetManager.updateAsset(
//       assetType: assetType,
//       bytes: bytes,
//       serverVersion: serverVersion,
//     );
//   }

//   //---------------------------------------------------------
//   // Clear Cache
//   //---------------------------------------------------------

//   Future<void> clearCache() async {
//     await localStorage.clearMasters();

//     await assetManager.clearAssets();
//   }
// }



import 'package:docautomations/datamodels/master/country.dart';
import 'package:docautomations/services/reference_data_api_service.dart';
import 'package:docautomations/storage/local_storage_service.dart';

class ReferenceDataRepository {

  final ReferenceDataApiService apiService;
  final LocalStorageService localStorage;

  const ReferenceDataRepository({
    required this.apiService,
    required this.localStorage,
  });

  //-------------------------------------------------------------------------
  // Fetch Countries
  //-------------------------------------------------------------------------

  Future<List<Country>> fetchCountries({
    bool forceRefresh = false,
  }) async {

    //-------------------------------------------------------------------------
    // Try Local Cache First
    //-------------------------------------------------------------------------

    if (!forceRefresh) {

      final cachedCountries =
          await localStorage.loadCountries();

      if (cachedCountries.isNotEmpty) {
        return cachedCountries;
      }

    }

    //-------------------------------------------------------------------------
    // Fetch From Server
    //-------------------------------------------------------------------------

    final countries =
        await apiService.fetchCountries();

    //-------------------------------------------------------------------------
    // Save To Local Cache
    //-------------------------------------------------------------------------

    await localStorage.saveCountries(
      countries,
    );

    return countries;
  }

  //-------------------------------------------------------------------------
  // Refresh Countries
  //-------------------------------------------------------------------------

  Future<List<Country>> refreshCountries() async {

    return await fetchCountries(
      forceRefresh: true,
    );

  }

  //-------------------------------------------------------------------------
  // Clear Country Cache
  //-------------------------------------------------------------------------

  Future<void> clearCache() async {

    await localStorage.clearCountries();

  }

}

