
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:docautomations/common/appcolors.dart';


//=============================================================================
// PRESCRIPTOR APPLICATION THEME
//=============================================================================
//
// AppColors
//     ↓
// AppTheme
//     ↓
// MaterialApp
//     ↓
// All Screens
//
// AppColors contains the actual color definitions.
// AppTheme converts those colors into Flutter Material components.
//
//=============================================================================

class AppTheme {

  //-------------------------------------------------------------------------
  // LIGHT THEME
  //-------------------------------------------------------------------------

  static ThemeData get light {

    final ColorScheme colorScheme =
        ColorScheme.light(

      //=======================================================================
      // Primary
      //=======================================================================

      primary:
          AppColors.prescriptorTeal,

      onPrimary:
          Colors.white,

      primaryContainer:
          const Color(0xFFD4EFEB),

      onPrimaryContainer:
          const Color(0xFF003B38),


      //=======================================================================
      // Secondary
      //=======================================================================

      secondary:
          AppColors.prescriptorTeal,

      onSecondary:
          Colors.white,

      secondaryContainer:
          const Color(0xFFDCEFEA),

      onSecondaryContainer:
          const Color(0xFF003B38),


      //=======================================================================
      // Surface
      //=======================================================================

      surface:
          AppColors.prescriptorBackground,

      onSurface:
          AppColors.prescriptorText,

      surfaceContainer:
          AppColors.prescriptorSurface,

      surfaceContainerHighest:
          const Color(0xFFE2EAE7),

      onSurfaceVariant:
          AppColors.prescriptorSecondaryText,


      //=======================================================================
      // Borders
      //=======================================================================

      outline:
          AppColors.prescriptorBorder,

      outlineVariant:
          const Color(0xFFC5CFCC),


      //=======================================================================
      // Error
      //=======================================================================

      error:
          const Color(0xFFD93025),

      onError:
          Colors.white,

      errorContainer:
          const Color(0xFFFFEDEA),

      onErrorContainer:
          const Color(0xFF8B1A12),
    );


    //-------------------------------------------------------------------------
    // TEXT THEME
    //-------------------------------------------------------------------------

    final TextTheme textTheme =
        GoogleFonts.robotoTextTheme();


    return ThemeData(

      useMaterial3:
          true,

      colorScheme:
          colorScheme,

      scaffoldBackgroundColor:
          AppColors.prescriptorBackground,

      textTheme:
          textTheme.copyWith(

        //=====================================================================
        // Headings
        //=====================================================================

        displayLarge:
            GoogleFonts.merriweather(
          color:
              AppColors.prescriptorText,
          fontWeight:
              FontWeight.w500,
        ),

        displayMedium:
            GoogleFonts.merriweather(
          color:
              AppColors.prescriptorText,
          fontWeight:
              FontWeight.w500,
        ),

        displaySmall:
            GoogleFonts.merriweather(
          color:
              AppColors.prescriptorText,
          fontWeight:
              FontWeight.w500,
        ),

        headlineLarge:
            GoogleFonts.merriweather(
          color:
              AppColors.prescriptorText,
          fontWeight:
              FontWeight.w500,
        ),

        headlineMedium:
            GoogleFonts.merriweather(
          color:
              AppColors.prescriptorText,
          fontWeight:
              FontWeight.w500,
        ),

        headlineSmall:
            GoogleFonts.merriweather(
          color:
              AppColors.prescriptorText,
          fontWeight:
              FontWeight.w500,
        ),


        //=====================================================================
        // Titles
        //=====================================================================

        titleLarge:
            GoogleFonts.roboto(
          color:
              AppColors.prescriptorText,
          fontWeight:
              FontWeight.w700,
        ),

        titleMedium:
            GoogleFonts.roboto(
          color:
              AppColors.prescriptorText,
          fontWeight:
              FontWeight.w700,
        ),

        titleSmall:
            GoogleFonts.roboto(
          color:
              AppColors.prescriptorText,
          fontWeight:
              FontWeight.w700,
        ),


        //=====================================================================
        // Body
        //=====================================================================

        bodyLarge:
            GoogleFonts.roboto(
          color:
              AppColors.prescriptorText,
        ),

        bodyMedium:
            GoogleFonts.roboto(
          color:
              AppColors.prescriptorSecondaryText,
        ),

        bodySmall:
            GoogleFonts.roboto(
          color:
              AppColors.prescriptorSecondaryText,
        ),


        //=====================================================================
        // Labels
        //=====================================================================

        labelLarge:
            GoogleFonts.roboto(
          color:
              AppColors.prescriptorTeal,
          fontWeight:
              FontWeight.w700,
        ),

        labelMedium:
            GoogleFonts.roboto(
          color:
              AppColors.prescriptorTeal,
          fontWeight:
              FontWeight.w700,
        ),

        labelSmall:
            GoogleFonts.roboto(
          color:
              AppColors.prescriptorTeal,
          fontWeight:
              FontWeight.w700,
        ),
      ),


      //-------------------------------------------------------------------------
      // APP BAR
      //-------------------------------------------------------------------------

      appBarTheme:
          AppBarTheme(

        backgroundColor:
            AppColors.prescriptorBackground,

        foregroundColor:
            AppColors.prescriptorText,

        elevation:
            0,

        centerTitle:
            false,

        titleTextStyle:
            GoogleFonts.roboto(

          fontSize:
              22,

          fontWeight:
              FontWeight.w700,

          color:
              AppColors.prescriptorText,
        ),
      ),


      //-------------------------------------------------------------------------
      // INPUT DECORATION
      //-------------------------------------------------------------------------

      inputDecorationTheme:
          InputDecorationTheme(

        labelStyle:
            GoogleFonts.roboto(

          fontSize:
              18,

          color:
              AppColors.prescriptorSecondaryText,
        ),

        floatingLabelStyle:
            GoogleFonts.roboto(

          color:
              AppColors.prescriptorTeal,

          fontWeight:
              FontWeight.w600,
        ),

        hintStyle:
            GoogleFonts.roboto(

          color:
              AppColors.prescriptorSecondaryText
                  .withValues(alpha: 0.75),
        ),

        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 19,
        ),

        border:
            OutlineInputBorder(

          borderRadius:
              BorderRadius.circular(9),

          borderSide:
              const BorderSide(

            color:
                AppColors.prescriptorBorder,

            width:
                1.5,
          ),
        ),

        enabledBorder:
            OutlineInputBorder(

          borderRadius:
              BorderRadius.circular(9),

          borderSide:
              const BorderSide(

            color:
                AppColors.prescriptorBorder,

            width:
                1.5,
          ),
        ),

        focusedBorder:
            OutlineInputBorder(

          borderRadius:
              BorderRadius.circular(9),

          borderSide:
              const BorderSide(

            color:
                AppColors.prescriptorTeal,

            width:
                2,
          ),
        ),

        errorBorder:
            OutlineInputBorder(

          borderRadius:
              BorderRadius.circular(9),

          borderSide:
              const BorderSide(

            color:
                Color(0xFFD93025),

            width:
                1.5,
          ),
        ),

        focusedErrorBorder:
            OutlineInputBorder(

          borderRadius:
              BorderRadius.circular(9),

          borderSide:
              const BorderSide(

            color:
                Color(0xFFD93025),

            width:
                2,
          ),
        ),
      ),


      //-------------------------------------------------------------------------
      // FILLED BUTTON
      //-------------------------------------------------------------------------

      filledButtonTheme:
          FilledButtonThemeData(

        style:
            FilledButton.styleFrom(

          backgroundColor:
              AppColors.prescriptorTeal,

          foregroundColor:
              Colors.white,

          minimumSize:
              const Size(
            0,
            50,
          ),

          shape:
              RoundedRectangleBorder(

            borderRadius:
                BorderRadius.circular(28),
          ),

          textStyle:
              GoogleFonts.roboto(

            fontSize:
                16,

            fontWeight:
                FontWeight.w700,
          ),
        ),
      ),


      //-------------------------------------------------------------------------
      // OUTLINED BUTTON
      //-------------------------------------------------------------------------

      outlinedButtonTheme:
          OutlinedButtonThemeData(

        style:
            OutlinedButton.styleFrom(

          foregroundColor:
              AppColors.prescriptorTeal,

          minimumSize:
              const Size(
            0,
            50,
          ),

          side:
              const BorderSide(

            color:
                AppColors.prescriptorTeal,

            width:
                1.5,
          ),

          shape:
              RoundedRectangleBorder(

            borderRadius:
                BorderRadius.circular(16),
          ),

          textStyle:
              GoogleFonts.roboto(

            fontSize:
                16,

            fontWeight:
                FontWeight.w700,
          ),
        ),
      ),


      //-------------------------------------------------------------------------
      // TEXT BUTTON
      //-------------------------------------------------------------------------

      textButtonTheme:
          TextButtonThemeData(

        style:
            TextButton.styleFrom(

          foregroundColor:
              AppColors.prescriptorTeal,

          textStyle:
              GoogleFonts.roboto(

            fontWeight:
                FontWeight.w700,
          ),
        ),
      ),


      //-------------------------------------------------------------------------
      // CARD
      //-------------------------------------------------------------------------

      cardTheme:
          CardThemeData(

        color:
            AppColors.prescriptorSurface,

        elevation:
            0,

        margin:
            EdgeInsets.zero,

        shape:
            RoundedRectangleBorder(

          borderRadius:
              BorderRadius.circular(20),
        ),
      ),


      //-------------------------------------------------------------------------
      // DIVIDER
      //-------------------------------------------------------------------------

      dividerTheme:
          const DividerThemeData(

        color:
            Color(0xFFC5CFCC),

        thickness:
            1,
      ),


      //-------------------------------------------------------------------------
      // ICONS
      //-------------------------------------------------------------------------

      iconTheme:
          const IconThemeData(

        color:
            AppColors.prescriptorSecondaryText,

        size:
            24,
      ),


      //-------------------------------------------------------------------------
      // SNACKBAR
      //-------------------------------------------------------------------------

      snackBarTheme:
          SnackBarThemeData(

        backgroundColor:
            AppColors.prescriptorTealDark,

        contentTextStyle:
            GoogleFonts.roboto(

          color:
              Colors.white,

          fontWeight:
              FontWeight.w500,
        ),

        behavior:
            SnackBarBehavior.floating,

        shape:
            RoundedRectangleBorder(

          borderRadius:
              BorderRadius.circular(12),
        ),
      ),
    );
  }
}

