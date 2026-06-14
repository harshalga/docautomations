import 'dart:async';
import 'dart:ui';
import 'package:docautomations/common/licenseprovider.dart';
import 'package:docautomations/datamodels/prescriptionData.dart';
import 'package:docautomations/services/local_file_logger.dart';
import 'package:docautomations/widgets/appentrypoint.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'services/logger_service.dart';


Future<void> main() async {
  runZonedGuarded<Future<void>>(() async {
LoggerService.debug("App started");
    /// MUST be inside the 
    BindingBase.debugZoneErrorsAreFatal = true;
    WidgetsFlutterBinding.ensureInitialized();

    /// Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) async {
      FlutterError.presentError(details);

      try {
        await LoggerService.logFlutterError(details);
      } catch (_) {}
    };

    /// Platform errors
    PlatformDispatcher.instance.onError = (error, stack) {
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

    /// Init loggers
    try {
      await LocalFileLogger.init();
    } catch (e) {
      debugPrint("Logger init failed: $e");
    }

    try {
      await LoggerService.init();
    } catch (e) {
      debugPrint("LoggerService init failed: $e");
    }

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => LicenseProvider()..loadStatus(),
          ),
          ChangeNotifierProvider(
            create: (_) => Prescriptiondata(),
          ),
        ],
        child: const MyApp(),
      ),
    );

  }, (error, stack) async {
    try {
      await LoggerService.logZonedError(error, stack);
    } catch (_) {}
  });
}

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   /// ✅ 1. Flutter framework errors (ONLY ONCE)
//   FlutterError.onError = (FlutterErrorDetails details) async {
//     FlutterError.presentError(details); // show in console

//     try {
//       await LoggerService.logFlutterError(details);
//     } catch (_) {
//       // prevent crash if logger fails
//     }
//   };

//   /// ✅ 2. Platform (native) errors
//   PlatformDispatcher.instance.onError = (error, stack) {
//     try {
//       LoggerService.logFlutterError(
//         FlutterErrorDetails(
//           exception: error,
//           stack: stack,
//         ),
//       );
//     } catch (_) {}

//     return true;
//   };

//   /// ✅ 3. Run app inside safe zone
//   runZonedGuarded<Future<void>>(() async {
//     /// ⚠️ VERY IMPORTANT FIX (prevents white screen)
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prescriptor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 72, 194, 188),
          brightness: Brightness.light,
        ),
        cardTheme: const CardThemeData(
          color: Color.fromARGB(255, 13, 192, 162),
        ),
        textTheme: TextTheme(
          displayLarge: const TextStyle(
              fontSize: 72, fontWeight: FontWeight.bold),
          titleLarge: GoogleFonts.aleo(
              fontSize: 30, fontStyle: FontStyle.italic),
          bodyMedium: GoogleFonts.merriweather(),
          displaySmall: GoogleFonts.pacifico(),
        ),
      ),
      home: const AppEntryPoint(),
    );
  }
}