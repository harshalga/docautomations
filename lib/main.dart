
import 'package:docautomations/common/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//-----------------------------------------------------------------------------
// APPLICATION
//-----------------------------------------------------------------------------

import 'package:docautomations/widgets/app_entry_point.dart';

//-----------------------------------------------------------------------------
// Controller
//-----------------------------------------------------------------------------

import 'package:docautomations/controllers/application_controller.dart';

//-----------------------------------------------------------------------------
// PROVIDERS
//-----------------------------------------------------------------------------

import 'package:docautomations/providers/authentication_provider.dart';

//-----------------------------------------------------------------------------
// REPOSITORIES
//-----------------------------------------------------------------------------

import 'package:docautomations/repositories/doctor_repository.dart';
import 'package:docautomations/repositories/reference_data_repository.dart';
import 'package:docautomations/repositories/layout_repository.dart';
import 'package:docautomations/repositories/prescription_repository.dart';
import 'package:docautomations/repositories/patient_repository.dart';

//-----------------------------------------------------------------------------
// API SERVICES
//-----------------------------------------------------------------------------

import 'package:docautomations/services/doctor_api_service.dart';
import 'package:docautomations/services/reference_data_api_service.dart';
import 'package:docautomations/services/layout_api_service.dart';
import 'package:docautomations/services/prescription_api_service.dart';
import 'package:docautomations/services/patient_api_service.dart';

//-----------------------------------------------------------------------------
// APPLICATION SERVICES
//-----------------------------------------------------------------------------

import 'package:docautomations/application/application_bootstrapper.dart';
import 'package:docautomations/device_assets/asset_manager.dart';
import 'package:docautomations/storage/local_storage_service.dart';

import 'package:docautomations/services/logger_service.dart';

//-----------------------------------------------------------------------------
// MAIN
//-----------------------------------------------------------------------------

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //-------------------------------------------------------------------------
  // LOGGING SERVICE
  //-------------------------------------------------------------------------

  await LoggerService.init();

  //-------------------------------------------------------------------------
  // LOCAL SERVICES
  //-------------------------------------------------------------------------

  final localStorage = const LocalStorageService();

  final assetManager = AssetManager();

  //-------------------------------------------------------------------------
  // API SERVICES
  //-------------------------------------------------------------------------

  final doctorApiService = DoctorApiService();

  final referenceDataApiService = ReferenceDataApiService();


  final layoutApiService =     LayoutApiService();

  final prescriptionApiService =   PrescriptionApiService();

  final patientApiService =     PatientApiService();
  //-------------------------------------------------------------------------
  // REPOSITORIES
  //-------------------------------------------------------------------------

  final doctorRepository = DoctorRepository(
    apiService: doctorApiService,
  );

  final referenceDataRepository = ReferenceDataRepository(
    apiService: referenceDataApiService,
    localStorage: localStorage,
  );

  final layoutRepository =   LayoutRepository(
  apiService: layoutApiService,
);


final prescriptionRepository =
    PrescriptionRepository(
  apiService: prescriptionApiService,
);

final patientRepository =
    PatientRepository(
  apiService: patientApiService,
);
  //-------------------------------------------------------------------------
  // APPLICATION BOOTSTRAPPER
  //-------------------------------------------------------------------------

  final applicationBootstrapper = ApplicationBootstrapper(
    doctorRepository: doctorRepository,
    referenceDataRepository: referenceDataRepository,
    layoutRepository: layoutRepository,
    assetManager: assetManager,
    localStorage: localStorage,
  );

  //-------------------------------------------------------------------------
  // RUN APPLICATION
  //-------------------------------------------------------------------------

  runApp(
    MultiProvider(
     providers: [

  //---------------------------------------------------------------------
  // AUTHENTICATION
  //---------------------------------------------------------------------

  ChangeNotifierProvider(
    create: (_) => AuthenticationProvider(),
  ),

  //---------------------------------------------------------------------
  // APPLICATION DEPENDENCIES
  //---------------------------------------------------------------------

  Provider<DoctorRepository>.value(
    value: doctorRepository,
  ),

  Provider<ReferenceDataRepository>.value(
    value: referenceDataRepository,
  ),

  Provider<LayoutRepository>.value(
    value: layoutRepository,
  ),

  Provider<PrescriptionRepository>.value(
    value: prescriptionRepository,
  ),

  Provider<PatientRepository>.value(
  value: patientRepository,
),

 

  Provider<AssetManager>.value(
    value: assetManager,
  ),

  Provider<LocalStorageService>.value(
    value: localStorage,
  ),

  Provider<ApplicationBootstrapper>.value(
    value: applicationBootstrapper,
  ),

  ChangeNotifierProvider(
    create: (_) => ApplicationController(
      initializer: applicationBootstrapper,
      assetManager: assetManager,
    ),
  ),
],
      child: const PrescriptorApp(),
    ),
  );
}

//-----------------------------------------------------------------------------
// PRESCRIPTOR APPLICATION
//-----------------------------------------------------------------------------

class PrescriptorApp extends StatelessWidget {
  const PrescriptorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Prescriptor',

      //-------------------------------------------------------------------------
      // THEME
      //-------------------------------------------------------------------------

       theme: AppTheme.light,
       // ThemeData(
      //   useMaterial3: true,

      //   colorScheme: ColorScheme.fromSeed(
      //     seedColor: Colors.orange,
      //   ),

      //   scaffoldBackgroundColor: Colors.white,

      //   appBarTheme: const AppBarTheme(
      //     centerTitle: true,
      //   ),

      //   inputDecorationTheme: const InputDecorationTheme(
      //     border: OutlineInputBorder(),
      //   ),
      // ),

      //-------------------------------------------------------------------------
      // APPLICATION ENTRY POINT
      //-------------------------------------------------------------------------

      home: const AppEntryPoint(),
    );
  }
}




