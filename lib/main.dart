
// //Old code for reference
// import 'dart:async';
// import 'dart:ui';
// import 'package:docautomations/common/licenseprovider.dart';
// import 'package:docautomations/datamodels/prescriptionData.dart';
// import 'package:docautomations/services/local_file_logger.dart';
// import 'package:docautomations/widgets/appentrypoint.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import 'services/logger_service.dart';


// Future<void> main() async {
//   runZonedGuarded<Future<void>>(() async {
// LoggerService.debug("App started");
//     /// MUST be inside the 
//     BindingBase.debugZoneErrorsAreFatal = true;
//     WidgetsFlutterBinding.ensureInitialized();

//     /// Flutter framework errors
//     FlutterError.onError = (FlutterErrorDetails details) async {
//       FlutterError.presentError(details);

//       try {
//         await LoggerService.logFlutterError(details);
//       } catch (_) {}
//     };

//     /// Platform errors
//     PlatformDispatcher.instance.onError = (error, stack) {
//       try {
//         LoggerService.logFlutterError(
//           FlutterErrorDetails(
//             exception: error,
//             stack: stack,
//           ),
//         );
//       } catch (_) {}

//       return true;
//     };

//     /// Init loggers
//     try {
//       await LocalFileLogger.init();
//     } catch (e) {
//       debugPrint("Logger init failed: $e");
//     }

//     try {
//       await LoggerService.init();
//     } catch (e) {
//       debugPrint("LoggerService init failed: $e");
//     }

//     runApp(
//       MultiProvider(
//         providers: [
//           ChangeNotifierProvider(
//             create: (_) => LicenseProvider()..loadStatus(),
//           ),
//           ChangeNotifierProvider(
//             create: (_) => Prescriptiondata(),
//           ),
//         ],
//         child: const MyApp(),
//       ),
//     );

//   }, (error, stack) async {
//     try {
//       await LoggerService.logZonedError(error, stack);
//     } catch (_) {}
//   });
// }



// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Prescriptor',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         useMaterial3: true,
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: const Color.fromARGB(255, 72, 194, 188),
//           brightness: Brightness.light,
//         ),
//         cardTheme: const CardThemeData(
//           color: Color.fromARGB(255, 13, 192, 162),
//         ),
//         textTheme: TextTheme(
//           displayLarge: const TextStyle(
//               fontSize: 72, fontWeight: FontWeight.bold),
//           titleLarge: GoogleFonts.aleo(
//               fontSize: 30, fontStyle: FontStyle.italic),
//           bodyMedium: GoogleFonts.merriweather(),
//           displaySmall: GoogleFonts.pacifico(),
//         ),
//       ),
//       home: const AppEntryPoint(),
//     );
//   }
// }
// //===========================================================================

import 'dart:async';
import 'dart:ui';

import 'package:docautomations/application/application_bootstrapper.dart';
import 'package:docautomations/providers/authentication_provider.dart';
import 'package:docautomations/datamodels/prescriptionData.dart';
import 'package:docautomations/services/local_file_logger.dart';
import 'package:docautomations/services/logger_service.dart';
import 'package:docautomations/widgets/appentrypoint.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

Future<void> main() async {

  runZonedGuarded<Future<void>>(

    () async {

      //----------------------------------------------------------
      // Flutter Initialization
      //----------------------------------------------------------

      WidgetsFlutterBinding.ensureInitialized();

      BindingBase.debugZoneErrorsAreFatal = true;

      //----------------------------------------------------------
      // Flutter Errors
      //----------------------------------------------------------

      FlutterError.onError = (

        FlutterErrorDetails details,

      ) async {

        FlutterError.presentError(
          details,
        );

        try {

          await LoggerService.logFlutterError(
            details,
          );

        } catch (_) {}

      };

      //----------------------------------------------------------
      // Platform Errors
      //----------------------------------------------------------

      PlatformDispatcher.instance.onError = (

        error,
        stack,

      ) {

        try {

          LoggerService.logFlutterError(

            FlutterErrorDetails(

              exception: error,

              stack: stack,

            ),

          );

        } catch (_) {}

        return true;

      };

      //----------------------------------------------------------
      // Initialize Local Logger
      //----------------------------------------------------------

      try {

        await LocalFileLogger.init();

      } catch (e) {

        debugPrint(
          "Logger init failed: $e",
        );

      }

      //----------------------------------------------------------
      // Initialize Logger Service
      //----------------------------------------------------------

      try {

        await LoggerService.init();

        LoggerService.debug(
          "Prescriptor application started.",
        );

      } catch (e) {

        debugPrint(
          "LoggerService init failed: $e",
        );

      }

      //----------------------------------------------------------
      // Start Application
      //----------------------------------------------------------

      runApp(

        MultiProvider(

          providers: [

            //----------------------------------------------------
            // Authentication
            //----------------------------------------------------

            ChangeNotifierProvider(

              create: (_) =>
                  AuthenticationProvider(),

            ),

            //----------------------------------------------------
            // Application Bootstrap / Master Data
            //----------------------------------------------------

            Provider(
      create: (_) =>
          ApplicationBootstrapper(
        doctorRepository:
            doctorRepository,
        referenceDataRepository:
            referenceDataRepository,
        assetManager:
            assetManager,
        localStorage:
            localStorage,
      ),
    ),

            //----------------------------------------------------
            // Current Prescription State
            //----------------------------------------------------

            ChangeNotifierProvider(

              create: (_) =>
                  Prescriptiondata(),

            ),

          ],

          child: const MyApp(),

        ),

      );

    },

    //------------------------------------------------------------
    // Unhandled Zoned Errors
    //------------------------------------------------------------

    (

      error,
      stack,

    ) async {

      try {

        await LoggerService.logZonedError(
          error,
          stack,
        );

      } catch (_) {}

    },

  );

}


class MyApp extends StatelessWidget {

  const MyApp({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {

    return MaterialApp(

      title: 'Prescriptor',

      debugShowCheckedModeBanner: false,

      theme: ThemeData(

        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(

          seedColor:
              const Color.fromARGB(
            255,
            72,
            194,
            188,
          ),

          brightness:
              Brightness.light,

        ),

        cardTheme:
            const CardThemeData(

          color:
              Color.fromARGB(
            255,
            13,
            192,
            162,
          ),

        ),

        textTheme: TextTheme(

          displayLarge:

              const TextStyle(

            fontSize: 72,

            fontWeight:
                FontWeight.bold,

          ),

          titleLarge:

              GoogleFonts.aleo(

            fontSize: 30,

            fontStyle:
                FontStyle.italic,

          ),

          bodyMedium:

              GoogleFonts.merriweather(),

          displaySmall:

              GoogleFonts.pacifico(),

        ),

      ),

      home:
          const AppEntryPoint(),

    );

  }

}

