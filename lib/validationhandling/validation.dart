


import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
//import 'package:flutter_validation/src/models/role.dart';

/// base class for all validations.
abstract class Validation<T> {
  const Validation();

  /// Validates the given [value] and returns an error message if validation fails.
  /// 
  /// if the validation passes, it should return `null`.
  String? validate(BuildContext context, T? value);
}

class RequiredSwitchVAlidation<T> extends Validation<T>
{//final bool isSelected;
final bool Function(T value)? isSelected;
  const RequiredSwitchVAlidation({this.isSelected});
  @override
  String? validate(BuildContext context, T? value) {
    if (value == false) return 'Please select medicine type.';
                return null;
  }}

/// a validation that checks if the value is required.
class RequiredValidation<T> extends Validation<T> {
  
  const RequiredValidation({this.isExist});

 
  final bool Function(T value)? isExist;

  @override
  String? validate(BuildContext context, T? value) {
    if (value == null) {
      return 'This field is required';
    }

    if (isExist != null && !isExist!(value)) {
      return 'This field is required';
    }

    if (value is String && (value as String).isEmpty) {
      return 'This field is required';
    }
    return null;
  }
}

class PeriodbasedValidation extends Validation<String>
{ String? selectedlabel;
   PeriodbasedValidation( {required this.selectedlabel});
  @override
  String? validate(BuildContext context,String?  value) {
    if (value == null) return null;


    try{
   // print('The value $selectedlabel??' );
    // TODO: implement validate
    if (selectedlabel=='days')
    {
      if (int.parse(value) >31)
      {
        return 'Days cannot be greater than 31 !!!';
      }
      else 
      {return null;}
    }
    else
    {
      if (int.parse(value)>12)
      {
        return 'Months cannot be greater than 12 !!!';
      }else 
      {return null;}
    }
   }on Exception
    catch (e)
    {
      print(e.toString());
      throw e.toString();
    } 
  }}

  class DosageValidation extends Validation<String> {
  final String medicineType;

  DosageValidation(this.medicineType);

  @override
  String? validate(BuildContext context, String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter dosage";
    }

    final num? dose = num.tryParse(value);
    if (dose == null) return "Enter a valid number";

    switch (medicineType) {
      case "Tablet":
      case "Capsule":
        if (dose < 1 || dose > 2000) {
          return "Tablet dosage must be between 1–2000 mg";
        }
        break;

      case "Syrup":
        if (dose < 1 || dose > 50) {
          return "Syrup dosage must be between 1–50 ml";
        }
        break;

      case "Drops":
        if (dose < 1 || dose > 10) {
          return "Drops must be between 1–10";
        }
        break;

      case "Inhalation":
        if (dose < 1 || dose > 10) {
          return "Puffs must be between 1–10";
        }
        break;

      default:
        return null; // Ointment / Others → No dosage
    }

    return null;
  }
}


class AgeValidation  extends Validation<String> {
  const AgeValidation ();

  @override
  String? validate(BuildContext context, String? value) {
    

    if ( value == null) return null;
    final int age = int.parse(value);
    if (  age >=110) {
      return 'Enter a valid age between 0 and 100 years !!!';
    }
    return null;
  }
}
/// a validation that checks if the value is a valid email.
class NumericValidation extends Validation<String> {
  const NumericValidation();

  @override
  String? validate(BuildContext context, String? value) {
    final numericRegex = RegExp(r'^\d+$');

    if (value == null) return null;
    if (!numericRegex.hasMatch(value)) {
      return 'Please enter numeric value only!!!';
    }
    return null;
  }
}

/// A validation that checks if the value is a strict valid double.
/// Only integers or proper decimals allowed (e.g., 12 or 12.34).
class DoubleValidation extends Validation<String> {
  const DoubleValidation();

  @override
  String? validate(BuildContext context, String? value) {
    if (value == null || value.trim().isEmpty) return null;

    // Strict pattern: at least one digit, optional decimal with digits
    final strictDoubleRegex = RegExp(r'^\d+(\.\d+)?$');

    if (!strictDoubleRegex.hasMatch(value)) {
      return 'Please enter a valid number (e.g., 12 or 12.5)';
    }

    return null;
  }
}


/// a validation that checks if the value is a valid email.
class EmailValidation extends Validation<String> {
  const EmailValidation();

  @override
  String? validate(BuildContext context, String? value) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (value == null) return null;
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }
}

// /// a validation that checks if the value is a valid phone number.
// class RoleValidation extends Validation<Role> {
//   const RoleValidation();

//   @override
//   String? validate(BuildContext context, Role? value) {
//     if (value == Role.member) {
//       return 'Require Admin or Editor role';
//     }

//     return null;
//   }
// }

//Validation for Next follow-up date must be greater than today\'s date
class FutureDateStringValidation extends Validation<String> {
  const FutureDateStringValidation();

  @override
  String? validate(BuildContext context, String? value) {
    if (value == null || value.isEmpty) return null;

try
{
  final parsed = DateFormat("dd/MM/yyyy").parseStrict(value);

    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final selected = DateTime(parsed.year, parsed.month, parsed.day);

    if (selected.isBefore(todayOnly)) {
      return "Next follow-up date must be after today";
    }
    if (selected.isAtSameMomentAs(todayOnly)) {
      return "Next follow-up date cannot be today";
    }

    return null;
}
catch(e)
{
  return "Enter date as DD/MM/YYYY";
}
    
  }
}

//We can perform server side validation by passing a function that returns the error message if any, otherwise null. This allows us to integrate async server checks into our validation flow.
class ServerValidation extends Validation<String> {
  final String? Function() errorProvider;

  const ServerValidation(this.errorProvider);

  @override
  String? validate(BuildContext context, String? value) {
    return errorProvider();
  }
}


/// a validation that checks if the value is a valid password.
class PasswordValidation extends Validation<String> {
  const PasswordValidation({
    this.minLength = 8,
    this.number = false,
    this.upperCase = false,
    this.specialChar = false,
  });

  final int minLength;
  final bool number;
  final bool upperCase;
  final bool specialChar;

  static final _numberRegex = RegExp(r'[0-9]');
  static final _upperCaseRegex = RegExp(r'[A-Z]');
  static final _specialCharRegex = RegExp(r'[!@#$%^&*(),.?":{}|<>]');

  @override
  String? validate(BuildContext context, String? value) {
    if (value?.isEmpty == true) return null;

    if (value!.length < minLength) {
      return 'Password must be at least $minLength characters';
    }

    if (number && !_numberRegex.hasMatch(value)) {
      return 'Password must contain at least one number';
    }

    if (upperCase && !_upperCaseRegex.hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }

    if (specialChar && !_specialCharRegex.hasMatch(value)) {
      return 'Password must contain at least one special character';
    }

    return null;
  }
}
