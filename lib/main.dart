import 'package:docautomations/common/licenseprovider.dart';
import 'package:docautomations/datamodels/prescriptionData.dart';
import 'package:docautomations/widgets/appentrypoint.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  //TODOPR
  
  runApp(
     MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LicenseProvider()..loadStatus()), // ..init  is added for trial/subscription status automatically refreshes when the app opens (or comes back from background)
        // ChangeNotifierProvider(
        //             lazy: false,
        //             create: (_) {
        //               final provider = LicenseProvider();
        //               WidgetsBinding.instance.addPostFrameCallback((_) {
        //                 provider.init();
        //               });
        //               return provider;
        //             },
        //                   ),
        ChangeNotifierProvider(
       create: (context) => Prescriptiondata()),
      ],
      child: const MyApp(),
    ),

    // ChangeNotifierProvider(
    //   create: (context) => Prescriptiondata(),

    //   child: const MyApp(),
    // ),
  );
}


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
        cardTheme: const CardTheme(color: Color.fromARGB(255, 13, 192, 162)),
        textTheme: TextTheme(
          displayLarge: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
          titleLarge: GoogleFonts.aleo(fontSize: 30, fontStyle: FontStyle.italic),
          bodyMedium: GoogleFonts.merriweather(),
          displaySmall: GoogleFonts.pacifico(),
        ),
      ),
      home: const AppEntryPoint(),

    );
  }
}


