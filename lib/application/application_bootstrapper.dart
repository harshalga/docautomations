
import 'package:docautomations/datamodels/master/master_data.dart';
import 'package:docautomations/datamodels/master/prescription_layout.dart';

import 'package:docautomations/device_assets/asset_manager.dart';
import 'package:docautomations/device_assets/asset_type.dart';

import 'package:docautomations/repositories/doctor_repository.dart';
import 'package:docautomations/repositories/reference_data_repository.dart';
import 'package:docautomations/repositories/layout_repository.dart';

import 'package:docautomations/storage/local_storage_service.dart';

import 'package:docautomations/datamodels/response/doctor_profile.dart';

class ApplicationBootstrapper {
  //--------------------------------------------------------------------------
  // Dependencies
  //--------------------------------------------------------------------------

  final DoctorRepository doctorRepository;
  final ReferenceDataRepository referenceDataRepository;
  final LayoutRepository layoutRepository;
  final AssetManager assetManager;
  final LocalStorageService localStorage;

  //--------------------------------------------------------------------------
  // Constructor
  //--------------------------------------------------------------------------

  const ApplicationBootstrapper({
    required this.doctorRepository,
    required this.referenceDataRepository,
    required this.layoutRepository,
    required this.assetManager,
    required this.localStorage,
  });

  //==========================================================================
  // Initialize Application
  //==========================================================================

  Future<MasterData> initialize({
    bool forceRefresh = false,
  }) async {
    final doctorProfile =
        await doctorRepository.fetchDoctorProfile();

    final doctorId = doctorProfile.doctor.id;

    if (doctorId.trim().isEmpty) {
      throw Exception(
        'Doctor ID is missing. Cannot synchronize doctor assets.',
      );
    }

    await synchronizeDoctorAssets(
      doctorId: doctorId,
      doctorProfile: doctorProfile,
    );

    final countries =
        await referenceDataRepository.fetchCountries(
      forceRefresh: forceRefresh,
    );

    final layoutResult =
        await layoutRepository.getDoctorLayout();

    if (!layoutResult.success) {
      throw Exception(layoutResult.message);
    }

    final prescriptionLayout =
        layoutResult.data as PrescriptionLayout;

    final masterData = MasterData(
      doctorProfile: doctorProfile,
      countries: countries,
      prescriptionLayout: prescriptionLayout,
    );

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
  // Synchronize Both Doctor Assets
  //==========================================================================

  Future<void> synchronizeDoctorAssets({
    required String doctorId,
    required DoctorProfile doctorProfile,
  }) async {
    await synchronizeDoctorAsset(
      doctorId: doctorId,
      doctorProfile: doctorProfile,
      assetType: AssetType.logo,
    );

    await synchronizeDoctorAsset(
      doctorId: doctorId,
      doctorProfile: doctorProfile,
      assetType: AssetType.signature,
    );
  }

  //==========================================================================
  // Synchronize One Doctor Asset
  //==========================================================================

  Future<void> synchronizeDoctorAsset({
    required String doctorId,
    required DoctorProfile doctorProfile,
    required AssetType assetType,
  }) async {
    final metadata = doctorProfile.assets.getAsset(assetType);

    final Future<List<int>> Function() downloader;

    switch (assetType) {
      case AssetType.logo:
        downloader = doctorRepository.downloadDoctorLogo;
        break;

      case AssetType.signature:
        downloader = doctorRepository.downloadDoctorSignature;
        break;

      case AssetType.header:
      case AssetType.footer:
        throw UnsupportedError(
          'Server synchronization is not implemented for ${assetType.name}.',
        );
    }

    await _synchronizeAsset(
      doctorId: doctorId,
      assetType: assetType,
      serverExists: metadata.exists,
      serverVersion: metadata.version,
      downloader: downloader,
    );
  }


  // //==========================================================================
  // // Synchronize Both Doctor Assets
  // //==========================================================================

  // Future<void> synchronizeDoctorAssets({
  //   required String doctorId,
  //   required DoctorProfile doctorProfile,
  // }) async {
  //   final logoMetadata =
  //       doctorProfile.assets.getAsset(AssetType.logo);

  //   await _synchronizeAsset(
  //     doctorId: doctorId,
  //     assetType: AssetType.logo,
  //     serverExists: logoMetadata.exists,
  //     serverVersion: logoMetadata.version,
  //     downloader: doctorRepository.downloadDoctorLogo,
  //   );

  //   final signatureMetadata =
  //       doctorProfile.assets.getAsset(AssetType.signature);

  //   await _synchronizeAsset(
  //     doctorId: doctorId,
  //     assetType: AssetType.signature,
  //     serverExists: signatureMetadata.exists,
  //     serverVersion: signatureMetadata.version,
  //     downloader: doctorRepository.downloadDoctorSignature,
  //   );
  // }

  // //==========================================================================
  // // Synchronize One Doctor Asset
  // //==========================================================================

  // Future<void> synchronizeDoctorAsset({
  //   required String doctorId,
  //   required DoctorProfile doctorProfile,
  //   required AssetType assetType,
  // }) async {
  //   final metadata =
  //       doctorProfile.assets.getAsset(assetType);

  //   final Future<List<int>> Function() downloader;

  //   switch (assetType) {
  //     case AssetType.logo:
  //       downloader = doctorRepository.downloadDoctorLogo;
  //       break;

  //     case AssetType.signature:
  //       downloader = doctorRepository.downloadDoctorSignature;
  //       break;

  //     case AssetType.header:
  //     case AssetType.footer:
  //       throw UnsupportedError(
  //         'Server synchronization is not implemented for ${assetType.name}.',
  //       );
  //   }

  //   await _synchronizeAsset(
  //     doctorId: doctorId,
  //     assetType: assetType,
  //     serverExists: metadata.exists,
  //     serverVersion: metadata.version,
  //     downloader: downloader,
  //   );
  // }

  //==========================================================================
  // Synchronize Asset
  //==========================================================================

  Future<void> _synchronizeAsset({
    required String doctorId,
    required AssetType assetType,
    required bool serverExists,
    required int serverVersion,
    required Future<List<int>> Function() downloader,
  }) async {
    if (!serverExists) {
      await assetManager.deleteAsset(
        doctorId,
        assetType,
      );

      return;
    }

    final requiredSync =
        await assetManager.needsSynchronization(
      doctorId,
      assetType,
      serverVersion,
    );

    if (!requiredSync) return;

    final bytes = await downloader();

    if (bytes.isEmpty) {
      throw Exception(
        'Downloaded asset is empty: ${assetType.name}',
      );
    }

    await assetManager.updateAsset(
      doctorId: doctorId,
      assetType: assetType,
      bytes: bytes,
      serverVersion: serverVersion,
    );
  }

  //==========================================================================
  // Clear Local Cache
  //==========================================================================

  Future<void> clearCache({
    String? doctorId,
  }) async {
    await localStorage.clearMasters();

    if (doctorId != null && doctorId.trim().isNotEmpty) {
      await assetManager.clearAssets(doctorId);
    }
  }
}
