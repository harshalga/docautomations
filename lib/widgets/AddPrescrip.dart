// import 'package:flutter/material.dart';

// import 'package:docautomations/datamodels/master/patient.dart';
// import 'package:docautomations/datamodels/master/patient_doctor.dart';
// import 'package:docautomations/datamodels/master/patient_mode.dart';

// import 'package:docautomations/widgets/AddPrescriptionScr.dart';


// class Addprescrip extends StatefulWidget {

//   //===========================================================================
//   // Properties
//   //===========================================================================

//   final String title;

//   final PatientMode mode;

//   final Patient? patient;

//   final PatientDoctor? patientDoctor;


//   //===========================================================================
//   // Constructor
//   //===========================================================================

//   const Addprescrip({
//     super.key,
//     required this.title,
//     this.mode = PatientMode.existingPatient,
//     this.patient,
//     this.patientDoctor,
//   });


//   //===========================================================================
//   // State
//   //===========================================================================

//   @override
//   State<Addprescrip> createState() =>
//       _AddprescripState();

// }


// //=============================================================================
// // State
// //=============================================================================

// class _AddprescripState
//     extends State<Addprescrip> {

//   @override
//   Widget build(
//     BuildContext context,
//   ) {

//     return Scaffold(

//       //-------------------------------------------------------------------------
//       // App Bar
//       //-------------------------------------------------------------------------

//       appBar: AppBar(
//         title: Text(
//           widget.title,
//           style: Theme.of(context)
//               .textTheme
//               .titleLarge!
//               .copyWith(
//                 color: Theme.of(context)
//                     .colorScheme
//                     .onSecondary,
//               ),
//         ),
//         backgroundColor:
//             Theme.of(context)
//                 .colorScheme
//                 .secondary,
//       ),


//       //-------------------------------------------------------------------------
//       // Prescription Screen
//       //-------------------------------------------------------------------------

//       body: Addprescriptionscr(
//         mode: widget.mode,
//         patient: widget.patient,
//         patientDoctor: widget.patientDoctor,
//       ),
//     );
//   }
// }

