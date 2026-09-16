
import 'package:flutter/material.dart';


//=============================================================================
// APPLICATION COLORS
//=============================================================================
//
// Centralized color definitions for the Prescriptor application.
//
// All screens should use AppColors or Theme.of(context).colorScheme.
// Avoid defining Color(...) directly inside individual screens.
//
//=============================================================================

class AppColors {

  //-------------------------------------------------------------------------
  // APPLICATION BACKGROUND
  //-------------------------------------------------------------------------

  static const Color background =
      Color(0xFFF7F7F7);


  //-------------------------------------------------------------------------
  // MAIN COLORS
  //-------------------------------------------------------------------------

  static const Color primary =
      Color(0xFF6200EA);

  static const Color secondary =
      Color(0xFF03DAC6);

  static const Color accent =
      Color(0xFFFFC107);


  //-------------------------------------------------------------------------
  // PRESCRIPTOR COLORS
  //-------------------------------------------------------------------------
  //
  // Colors used by the new Prescriptor application UI.
  //
  // Based on the LoginScreen visual design.
  //
  //-------------------------------------------------------------------------

  static const Color prescriptorTeal =
      Color(0xFF006B67);

  static const Color prescriptorTealDark =
      Color(0xFF00534F);

  static const Color prescriptorBackground =
      Color(0xFFF5FBF9);

  static const Color prescriptorSurface =
      Color(0xFFEFF5F3);

  static const Color prescriptorSupportSurface =
      Color(0xFFE4F2FD);

  static const Color prescriptorText =
      Color(0xFF202626);

  static const Color prescriptorSecondaryText =
      Color(0xFF4F5957);

  static const Color prescriptorBorder =
      Color(0xFF78827F);


  //-------------------------------------------------------------------------
  // LIGHT COLORS
  //-------------------------------------------------------------------------

  static const Color colorLightPrimary =
      Color(0xFF5C93C4);

  static const Color colorLightSecondary =
      Color(0xFFF9F6E5);

  static const Color colorLightCardColors =
      Color(0xFFFFFFFF);


  //-------------------------------------------------------------------------
  // DARK COLORS
  //-------------------------------------------------------------------------

  static const Color colorDarkPrimary =
      Color(0xFF222831);

  static const Color colorDarkSecondary =
      Color(0xFF30475E);

  static const Color colorDarkThird =
      Color(0xFFF2A365);

  static const Color colorDarkTitle =
      Color(0xFFECECEC);


  //-------------------------------------------------------------------------
  // GET STARTED
  //-------------------------------------------------------------------------

  static const Color colorStarted =
      Color(0xFF274C71);

  static const Color colorStartedTitle =
      Color(0xFF352641);

  static const Color colorStartedDescription =
      Color(0xFF767676);

  static const Color colorStartedShadow =
      Color(0x60274C71);


  //-------------------------------------------------------------------------
  // ALERT DIALOG
  //-------------------------------------------------------------------------

  static const Color colorAlertDialogBack =
      Color(0xFFF8F7F2);


  //-------------------------------------------------------------------------
  // OTHER COLOR GROUPS
  //-------------------------------------------------------------------------

  static const Map<String, Color> Main_Colors = {

    'primary':
        primary,

    'secondary':
        secondary,

    'accent':
        accent,
  };
}

