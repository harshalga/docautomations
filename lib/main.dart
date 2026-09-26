
// // //Old code for reference
// // import 'dart:async';
// // import 'dart:ui';
// // import 'package:docautomations/common/licenseprovider.dart';
// // import 'package:docautomations/datamodels/prescriptionData.dart';
// // import 'package:docautomations/services/local_file_logger.dart';
// // import 'package:docautomations/widgets/appentrypoint.dart';
// // import 'package:flutter/foundation.dart';
// // import 'package:flutter/material.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // import 'package:provider/provider.dart';
// // import 'services/logger_service.dart';


// // Future<void> main() async {
// //   runZonedGuarded<Future<void>>(() async {
// // LoggerService.debug("App started");
// //     /// MUST be inside the 
// //     BindingBase.debugZoneErrorsAreFatal = true;
// //     WidgetsFlutterBinding.ensureInitialized();

// //     /// Flutter framework errors
// //     FlutterError.onError = (FlutterErrorDetails details) async {
// //       FlutterError.presentError(details);

// //       try {
// //         await LoggerService.logFlutterError(details);
// //       } catch (_) {}
// //     };

// //     /// Platform errors
// //     PlatformDispatcher.instance.onError = (error, stack) {
// //       try {
// //         LoggerService.logFlutterError(
// //           FlutterErrorDetails(
// //             exception: error,
// //             stack: stack,
// //           ),
// //         );
// //       } catch (_) {}

// //       return true;
// //     };

// //     /// Init loggers
// //     try {
// //       await LocalFileLogger.init();
// //     } catch (e) {
// //       debugPrint("Logger init failed: $e");
// //     }

// //     try {
// //       await LoggerService.init();
// //     } catch (e) {
// //       debugPrint("LoggerService init failed: $e");
// //     }

// //     runApp(
// //       MultiProvider(
// //         providers: [
// //           ChangeNotifierProvider(
// //             create: (_) => LicenseProvider()..loadStatus(),
// //           ),
// //           ChangeNotifierProvider(
// //             create: (_) => Prescriptiondata(),
// //           ),
// //         ],
// //         child: const MyApp(),
// //       ),
// //     );

// //   }, (error, stack) async {
// //     try {
// //       await LoggerService.logZonedError(error, stack);
// //     } catch (_) {}
// //   });
// // }



// // class MyApp extends StatelessWidget {
// //   const MyApp({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       title: 'Prescriptor',
// //       debugShowCheckedModeBanner: false,
// //       theme: ThemeData(
// //         useMaterial3: true,
// //         colorScheme: ColorScheme.fromSeed(
// //           seedColor: const Color.fromARGB(255, 72, 194, 188),
// //           brightness: Brightness.light,
// //         ),
// //         cardTheme: const CardThemeData(
// //           color: Color.fromARGB(255, 13, 192, 162),
// //         ),
// //         textTheme: TextTheme(
// //           displayLarge: const TextStyle(
// //               fontSize: 72, fontWeight: FontWeight.bold),
// //           titleLarge: GoogleFonts.aleo(
// //               fontSize: 30, fontStyle: FontStyle.italic),
// //           bodyMedium: GoogleFonts.merriweather(),
// //           displaySmall: GoogleFonts.pacifico(),
// //         ),
// //       ),
// //       home: const AppEntryPoint(),
// //     );
// //   }
// // }
// // //===========================================================================


// import 'dart:async';
// import 'dart:ui';

// import 'package:docautomations/application/application_bootstrapper.dart';

// import 'package:docautomations/providers/authentication_provider.dart';

// import 'package:docautomations/datamodels/prescriptionData.dart';

// import 'package:docautomations/device_assets/asset_manager.dart';


// import 'package:docautomations/repositories/doctor_repository.dart';
// import 'package:docautomations/repositories/reference_data_repository.dart';

// import 'package:docautomations/services/doctor_api_service.dart';
// import 'package:docautomations/services/reference_data_api_service.dart';

// import 'package:docautomations/repositories/patient_repository.dart';
// import 'package:docautomations/repositories/prescription_repository.dart';

// import 'package:docautomations/services/patient_api_service.dart';
// import 'package:docautomations/services/prescription_api_service.dart';

// import 'package:docautomations/storage/local_storage_service.dart';

// import 'package:docautomations/services/local_file_logger.dart';
// import 'package:docautomations/services/logger_service.dart';

// import 'package:docautomations/widgets/appentrypoint.dart';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';


// Future<void> main() async {

//   runZonedGuarded<Future<void>>(

//     () async {

//       //========================================================================
//       // Flutter Initialization
//       //========================================================================

//       WidgetsFlutterBinding.ensureInitialized();

//       BindingBase.debugZoneErrorsAreFatal = true;


//       //========================================================================
//       // Flutter Errors
//       //========================================================================

//       FlutterError.onError = (

//         FlutterErrorDetails details,

//       ) async {

//         FlutterError.presentError(
//           details,
//         );

//         try {

//           await LoggerService.logFlutterError(
//             details,
//           );

//         } catch (_) {}

//       };


//       //========================================================================
//       // Platform Errors
//       //========================================================================

//       PlatformDispatcher.instance.onError = (

//         error,
//         stack,

//       ) {

//         try {

//           LoggerService.logFlutterError(

//             FlutterErrorDetails(

//               exception: error,

//               stack: stack,

//             ),

//           );

//         } catch (_) {}

//         return true;

//       };


//       //========================================================================
//       // Initialize Local Logger
//       //========================================================================

//       try {

//         await LocalFileLogger.init();

//       } catch (e) {

//         debugPrint(
//           "Logger init failed: $e",
//         );

//       }


//       //========================================================================
//       // Initialize Logger Service
//       //========================================================================

//       try {

//         await LoggerService.init();

//         LoggerService.debug(
//           "Prescriptor application started.",
//         );

//       } catch (e) {

//         debugPrint(
//           "LoggerService init failed: $e",
//         );

//       }


//       //========================================================================
//       // Application Dependencies
//       //
//       // These objects form the dependency graph for the application.
//       // They are created once and shared through Provider.
//       //========================================================================

//       final localStorage =
//           const LocalStorageService();


//       final assetManager =
//           AssetManager();


//       //========================================================================
//       // API Services
//       //
//       // Both API services automatically use DioClient.instance when no
//       // Dio instance is supplied.
//       //========================================================================

//       final doctorApiService =
//           DoctorApiService();


//       final referenceDataApiService =
//           ReferenceDataApiService();

//           final patientApiService =
//           PatientApiService();


//       final prescriptionApiService =
//           PrescriptionApiService();


//       //========================================================================
//       // Repositories
//       //========================================================================

//       final doctorRepository =
//           DoctorRepository(

//         apiService:
//             doctorApiService,

//       );


//       final referenceDataRepository =
//           ReferenceDataRepository(

//         apiService:
//             referenceDataApiService,

//         localStorage:
//             localStorage,

//       );

//       final patientRepository =
//            PatientRepository(

//         apiService:
//             patientApiService,

//         );


//       final prescriptionRepository =
//             PrescriptionRepository(

//         apiService:
//           prescriptionApiService,

//         );


//       //========================================================================
//       // Application Bootstrapper
//       //
//       // Responsible for loading:
//       //
//       // - Doctor profile
//       // - Countries
//       // - Doctor logo
//       // - Doctor signature
//       // - Local cached master data
//       //
//       //========================================================================

//       final applicationBootstrapper =
//           ApplicationBootstrapper(

//         doctorRepository:
//             doctorRepository,

//         referenceDataRepository:
//             referenceDataRepository,

//         assetManager:
//             assetManager,

//         localStorage:
//             localStorage,

//       );


//       //========================================================================
//       // Start Application
//       //========================================================================

//       runApp(

//         MultiProvider(

//           providers: [

//             //------------------------------------------------------------------
//             // Authentication
//             //------------------------------------------------------------------

//             ChangeNotifierProvider(

//               create: (_) =>
//                   AuthenticationProvider(),

//             ),


//             //------------------------------------------------------------------
//             // Doctor Repository
//             //------------------------------------------------------------------

//             Provider<DoctorRepository>.value(

//               value:
//                   doctorRepository,

//             ),


//             //------------------------------------------------------------------
//             // Reference Data Repository
//             //------------------------------------------------------------------

//             Provider<ReferenceDataRepository>.value(

//               value:
//                   referenceDataRepository,

//             ),


//             //------------------------------------------------------------------
// // Patient Repository
// //------------------------------------------------------------------

// Provider<PatientRepository>.value(

//   value:
//       patientRepository,

// ),


// //------------------------------------------------------------------
// // Prescription Repository
// //------------------------------------------------------------------

// Provider<PrescriptionRepository>.value(

//   value:
//       prescriptionRepository,

// ),


//             //------------------------------------------------------------------
//             // Asset Manager
//             //------------------------------------------------------------------

//             Provider<AssetManager>.value(

//               value:
//                   assetManager,

//             ),


//             //------------------------------------------------------------------
//             // Local Storage
//             //------------------------------------------------------------------

//             Provider<LocalStorageService>.value(

//               value:
//                   localStorage,

//             ),


//             //------------------------------------------------------------------
//             // Application Bootstrap / Master Data
//             //------------------------------------------------------------------

//             Provider<ApplicationBootstrapper>.value(

//               value:
//                   applicationBootstrapper,

//             ),


//             //------------------------------------------------------------------
//             // Current Prescription State
//             //------------------------------------------------------------------

//             ChangeNotifierProvider(

//               create: (_) =>
//                   Prescriptiondata(),

//             ),

//           ],

//           child:
//               const MyApp(),

//         ),

//       );

//     },


//     //==========================================================================
//     // Unhandled Zoned Errors
//     //==========================================================================

//     (

//       error,
//       stack,

//     ) async {

//       try {

//         await LoggerService.logZonedError(
//           error,
//           stack,
//         );

//       } catch (_) {}

//     },

//   );

// }


// class MyApp extends StatelessWidget {

//   const MyApp({
//     super.key,
//   });


//   @override
//   Widget build(
//     BuildContext context,
//   ) {

//     return MaterialApp(

//       title:
//           'Prescriptor',

//       debugShowCheckedModeBanner:
//           false,

//       theme:
//           ThemeData(

//         useMaterial3:
//             true,

//         colorScheme:
//             ColorScheme.fromSeed(

//           seedColor:
//               const Color.fromARGB(
//             255,
//             72,
//             194,
//             188,
//           ),

//           brightness:
//               Brightness.light,

//         ),

//         cardTheme:
//             const CardThemeData(

//           color:
//               Color.fromARGB(
//             255,
//             13,
//             192,
//             162,
//           ),

//         ),

//         textTheme:
//             TextTheme(

//           displayLarge:
//               const TextStyle(

//             fontSize:
//                 72,

//             fontWeight:
//                 FontWeight.bold,

//           ),

//           titleLarge:
//               GoogleFonts.aleo(

//             fontSize:
//                 30,

//             fontStyle:
//                 FontStyle.italic,

//           ),

//           bodyMedium:
//               GoogleFonts.merriweather(),

//           displaySmall:
//               GoogleFonts.pacifico(),

//         ),

//       ),

//       home:
//           const AppEntryPoint(),

//     );

//   }

// }


//the first brick

import 'package:docautomations/common/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:docautomations/services/layout_api_service.dart';
import 'package:docautomations/repositories/layout_repository.dart';
//-----------------------------------------------------------------------------
// APPLICATION
//-----------------------------------------------------------------------------

import 'package:docautomations/widgets/app_entry_point.dart';

//-----------------------------------------------------------------------------
// PROVIDERS
//-----------------------------------------------------------------------------

import 'package:docautomations/providers/authentication_provider.dart';

//-----------------------------------------------------------------------------
// REPOSITORIES
//-----------------------------------------------------------------------------

import 'package:docautomations/repositories/doctor_repository.dart';
import 'package:docautomations/repositories/reference_data_repository.dart';

//-----------------------------------------------------------------------------
// API SERVICES
//-----------------------------------------------------------------------------

import 'package:docautomations/services/doctor_api_service.dart';
import 'package:docautomations/services/reference_data_api_service.dart';

//-----------------------------------------------------------------------------
// APPLICATION SERVICES
//-----------------------------------------------------------------------------

import 'package:docautomations/application/application_bootstrapper.dart';
import 'package:docautomations/device_assets/asset_manager.dart';
import 'package:docautomations/storage/local_storage_service.dart';

//-----------------------------------------------------------------------------
// MAIN
//-----------------------------------------------------------------------------

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  //-------------------------------------------------------------------------
  // APPLICATION BOOTSTRAPPER
  //-------------------------------------------------------------------------

  final applicationBootstrapper = ApplicationBootstrapper(
    doctorRepository: doctorRepository,
    referenceDataRepository: referenceDataRepository,
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
        
        Provider<AssetManager>.value(
          value: assetManager,
        ),

        Provider<LocalStorageService>.value(
          value: localStorage,
        ),

        Provider<ApplicationBootstrapper>.value(
          value: applicationBootstrapper,
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




