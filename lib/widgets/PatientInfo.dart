
// import 'package:docautomations/common/appcolors.dart';
// import 'package:docautomations/validationhandling/validation.dart';
// import 'package:docautomations/validationhandling/validator.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class Patientinfo extends StatefulWidget {
//   // final void Function(String name, String age, String gender, String keycomplaint,
//   // String examination,String diagnostics )? onChanged;
//   // const Patientinfo({super.key, this.onChanged});
//   const Patientinfo({super.key});
//   @override
//   State<Patientinfo> createState() => PatientinfoState();
// }

// class PatientinfoState extends State<Patientinfo> {
//   final TextEditingController tabNameController = TextEditingController();
//    final TextEditingController keyComplaintcontroller = TextEditingController();
//    final TextEditingController examinationcontroller = TextEditingController();
//    final TextEditingController diagnoscontroller = TextEditingController();
//    final TextEditingController ageController = TextEditingController();
//    final TextEditingController remarkscontroller =TextEditingController();
//    final TextEditingController followupDatecontroller = TextEditingController();
//   String selectedGender = "Male";



// void clearFields() {
//   tabNameController.clear();
//   ageController.clear();
//   keyComplaintcontroller.clear();
//   examinationcontroller.clear();
//   diagnoscontroller.clear();
//   followupDatecontroller.clear();
//   remarkscontroller.clear();
  
//   setState(() {selectedGender = "Male";}); // refresh UI
// }


// Future<void> _selectNextFollowupDate () async
// {
//   DateTime? picked=  await showDatePicker(context: context, firstDate: DateTime(2000),
//    lastDate: DateTime(2100)         
//    ,initialDate: DateTime.now());

//    if (picked != null)
//    {

//     if (!mounted) return;
//     setState(() {
//        String formattedDate = DateFormat('dd/MM/yyyy').format(picked);
//       followupDatecontroller.text = formattedDate;
//     });
          
//    }

// }

  
//   @override
// void dispose() {
//   tabNameController.dispose();
//   ageController.dispose();
//   keyComplaintcontroller.dispose();
//   examinationcontroller.dispose();
//   diagnoscontroller.dispose();
//   followupDatecontroller.dispose();   // <-- MISSING
//   remarkscontroller.dispose();        // <-- MISSING
//   super.dispose();
// }

  
//   @override
//   Widget build(BuildContext context) {
//     return  Container(padding: const EdgeInsets.all(10),
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(10),
//       boxShadow: [BoxShadow(color: AppColors.secondary.withOpacity(0.3),blurRadius:10,
//       offset: Offset.zero)],
//     ),
//     child: Column(
//       children:[
              
//                 TextFormField(
//                   autofocus: true,
                  
//                   decoration:  const InputDecoration(
//                       //border: OutlineInputBorder(),
//                       labelText: 'Enter patient name  '),
//                   controller: tabNameController,
//                   //onChanged: (_) => _notifyParent(),
//                   validator: Validator.apply(context, const [RequiredValidation()])
//                 ) ,  
              
              
// //Age
//               TextFormField(                  
//                   keyboardType:TextInputType.number ,
//                   decoration:  const InputDecoration(
//                      // border: OutlineInputBorder(),
//                       labelText: 'Enter patient Age  '),
//                   controller: ageController,
//                   //onChanged: (_) => _notifyParent(),
//                   validator: Validator.apply(context, const [RequiredValidation(),NumericValidation(),ageValidation()])
//                 )  ,
                   
//                   DropdownButtonFormField<String>(
//           value: selectedGender,
//           decoration: const InputDecoration(labelText: "Gender"),
//           onChanged: (value) {
//             setState(() {
//               selectedGender = value!;
//              // _notifyParent();
//             });
//           },
//           items: const [
//             DropdownMenuItem(value: "Male", child: Text("Male")),
//             DropdownMenuItem(value: "Female", child: Text("Female")),
//             DropdownMenuItem(value: "Other", child: Text("Other")),
//           ],
//         ),    
//                 TextFormField(
//                   keyboardType: TextInputType.multiline,
//                   minLines: 1,
//                    maxLines: 5,
//                   decoration:  const InputDecoration(
//                      // border: OutlineInputBorder(),
//                       labelText: 'Enter key complaint '),
//                        //onChanged: (_) => _notifyParent(),
//                   controller: keyComplaintcontroller,
//                   //validator: Validator.apply(context, const [RequiredValidation()])
//                 ),
//                 TextFormField(
                  
//                   keyboardType: TextInputType.multiline,
//                   minLines: 1,
//                    maxLines: 5,
//                   decoration:  const InputDecoration(
//                      // border: OutlineInputBorder(),
//                       labelText: 'Enter examination inputs '),
//                        //onChanged: (_) => _notifyParent(),
//                   controller: examinationcontroller,
//                   //validator: Validator.apply(context, const [RequiredValidation()])
//                 ), 
//                 TextFormField(
                  
//                   keyboardType: TextInputType.multiline,
//                   minLines: 1,
//                    maxLines: 5,
//                   decoration:  const InputDecoration(
//                       //border: OutlineInputBorder(),
//                       labelText: 'Enter diagnosis inputs '),
//                   controller: diagnoscontroller,
//                   // onChanged: (_) => _notifyParent(),
//                   //validator: Validator.apply(context, const [RequiredValidation()])
//                 ), 
//                 SizedBox(height: 10,),
//                 TextFormField(
//                   keyboardType:TextInputType.number ,
//                   decoration:  const InputDecoration(
//                      // border: OutlineInputBorder(),
//                       labelText: 'Next Follow up date  ',
//                       filled: true,
//                       prefixIcon: Icon(Icons.calendar_today),
//                       enabledBorder: OutlineInputBorder(
//                         borderSide: BorderSide(color: Colors.blue),
//                       )
//                       ),
//                       readOnly: true  ,
//                       onTap: (){_selectNextFollowupDate();},
//                   controller: followupDatecontroller,
//                   //onChanged: (_) => _notifyParent(),
//                   validator: Validator.apply(context, const [FutureDateStringValidation()])
//                 ),
//                  TextFormField(
//                   keyboardType:TextInputType.multiline ,
//                   minLines: 1,
//                    maxLines: 5,
//                   decoration:  const InputDecoration(
//                      // border: OutlineInputBorder(),
//                       labelText: 'Remarks  '),
//                   controller: remarkscontroller,
//                   //onChanged: (_) => _notifyParent(),
//                  // validator: Validator.apply(context, const [RequiredValidation()])
//                 ),
              

//       ]
//     ));
//   }
// }

//Latest
// import 'package:docautomations/common/appcolors.dart';
// import 'package:docautomations/validationhandling/validation.dart';
// import 'package:docautomations/validationhandling/validator.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class Patientinfo extends StatefulWidget {
//   const Patientinfo({super.key});

//   @override
//   State<Patientinfo> createState() => PatientinfoState();
// }

// class PatientinfoState extends State<Patientinfo> {
//   // Controllers
//   final TextEditingController tabNameController = TextEditingController();
//   final TextEditingController keyComplaintcontroller = TextEditingController();
//   final TextEditingController examinationcontroller = TextEditingController();
//   final TextEditingController diagnoscontroller = TextEditingController();
//   final TextEditingController ageController = TextEditingController();
//   final TextEditingController remarkscontroller = TextEditingController();
//   final TextEditingController followupDatecontroller = TextEditingController();

//   // Gender as ValueNotifier 🔥
//   final ValueNotifier<String> gender = ValueNotifier<String>("Male");

//   @override
// void initState() {
//   super.initState();
//   //TODO:Remove
//   print("🟢 PatientInfo INIT called — Widget created fresh");
// }

//   // RESET FORM — NO setState required!
//   void clearFields() {
//     tabNameController.clear();
//     ageController.clear();
//     keyComplaintcontroller.clear();
//     examinationcontroller.clear();
//     diagnoscontroller.clear();
//     followupDatecontroller.clear();
//     remarkscontroller.clear();

//     gender.value = "Male"; // 🔥 instantly updates UI
//   }

//   // Date picker
//   Future<void> _selectNextFollowupDate() async {
//     DateTime? picked = await showDatePicker(
//       context: context,
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//       initialDate: DateTime.now(),
//     );

//     if (picked != null) {
//       if (!mounted) return;
//       followupDatecontroller.text =
//           DateFormat('dd/MM/yyyy').format(picked);
//     }
//   }

//   @override
//   void dispose() {
//     tabNameController.dispose();
//     ageController.dispose();
//     keyComplaintcontroller.dispose();
//     examinationcontroller.dispose();
//     diagnoscontroller.dispose();
//     followupDatecontroller.dispose();
//     remarkscontroller.dispose();
//     gender.dispose(); // 🔥 IMPORTANT
//     super.dispose();
//     //TODO:Remove
//      print("❌ PatientInfo DISPOSE called — Widget removed from tree");
//   }

//   @override
//   Widget build(BuildContext context) {
//     //TODO:Remove
//     print("BUILD PatientInfo");
//     print("🔄 PatientInfo BUILD triggered at: ${DateTime.now()}");
//     return Container(
//         padding: const EdgeInsets.all(10),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(10),
//           boxShadow: [
//             BoxShadow(
//                 color: AppColors.secondary.withOpacity(0.3),
//                 blurRadius: 10,
//                 offset: Offset.zero)
//           ],
//         ),
//         child: Column(children: [
//           TextFormField(
//               autofocus: true,
//               decoration:
//                   const InputDecoration(labelText: 'Enter patient name'),
//               controller: tabNameController,
//               validator:
//                   Validator.apply(context, const [RequiredValidation()])),

//           // Age
//           TextFormField(
//               keyboardType: TextInputType.number,
//               decoration:
//                   const InputDecoration(labelText: 'Enter patient Age'),
//               controller: ageController,
//               validator: Validator.apply(context,
//                   const [RequiredValidation(), NumericValidation(), AgeValidation()])),

//           // ⭐ Gender using ValueListenableBuilder
//           ValueListenableBuilder<String>(
//             valueListenable: gender,
//             builder: (context, value, _) {
//               return DropdownButtonFormField<String>(
//                 value: value,
//                 decoration: const InputDecoration(labelText: "Gender"),
//                 onChanged: (newValue) {
//                   gender.value = newValue!;
//                 },
//                 items: const [
//                   DropdownMenuItem(value: "Male", child: Text("Male")),
//                   DropdownMenuItem(value: "Female", child: Text("Female")),
//                   DropdownMenuItem(value: "Other", child: Text("Other")),
//                 ],
//               );
//             },
//           ),

//           // key complaint
//           TextFormField(
//             keyboardType: TextInputType.multiline,
//             minLines: 1,
//             maxLines: 5,
//             decoration:
//                 const InputDecoration(labelText: 'Enter key complaint'),
//             controller: keyComplaintcontroller,
//           ),

//           // examination
//           TextFormField(
//             keyboardType: TextInputType.multiline,
//             minLines: 1,
//             maxLines: 5,
//             decoration:
//                 const InputDecoration(labelText: 'Enter examination inputs'),
//             controller: examinationcontroller,
//           ),

//           // diagnosis
//           TextFormField(
//             keyboardType: TextInputType.multiline,
//             minLines: 1,
//             maxLines: 5,
//             decoration:
//                 const InputDecoration(labelText: 'Enter diagnosis inputs'),
//             controller: diagnoscontroller,
//           ),

//           const SizedBox(height: 10),

//           // Follow-up date
//           TextFormField(
//             readOnly: true,
//             keyboardType: TextInputType.number,
//             decoration: const InputDecoration(
//               labelText: 'Next Follow up date',
//               filled: true,
//               prefixIcon: Icon(Icons.calendar_today),
//               enabledBorder: OutlineInputBorder(
//                 borderSide: BorderSide(color: Colors.blue),
//               ),
//             ),
//             onTap: _selectNextFollowupDate,
//             controller: followupDatecontroller,
//             validator:
//                 Validator.apply(context, const [FutureDateStringValidation()]),
//           ),

//           // Remarks
//           TextFormField(
//             keyboardType: TextInputType.multiline,
//             minLines: 1,
//             maxLines: 5,
//             decoration: const InputDecoration(labelText: 'Remarks'),
//             controller: remarkscontroller,
//           ),
//         ]));
//   }
// }


import 'package:docautomations/validationhandling/validation.dart';
import 'package:docautomations/validationhandling/validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class Patientinfo extends StatefulWidget {
  final GlobalKey<FormFieldState<String>> nameFieldKey;
  final GlobalKey<FormFieldState<String>> ageFieldKey;
  
  
  const Patientinfo({ super.key,
                      required this.nameFieldKey,
                      required this.ageFieldKey,
                    });

  @override
  PatientinfoState createState() => PatientinfoState();
}

class PatientinfoState extends State<Patientinfo>
    with AutomaticKeepAliveClientMixin {
  // ==============================
  // CONTROLLERS
  // ==============================
  final TextEditingController tabNameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController keyComplaintcontroller = TextEditingController();
  final TextEditingController examinationcontroller = TextEditingController();
  final TextEditingController diagnoscontroller = TextEditingController();
  final TextEditingController followupDatecontroller = TextEditingController();
  final TextEditingController remarkscontroller = TextEditingController();

  // ==============================
  // VALUE NOTIFIER FOR GENDER
  // No rebuild on change
  // ==============================
  final ValueNotifier<String> gender = ValueNotifier<String>("Male");

  // ==============================
  // DATE PICKER
  // ==============================
  Future<void> _selectNextFollowupDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selected != null) {
      followupDatecontroller.text = DateFormat("dd/MM/yyyy").format(selected);
    }
  }

  // ==============================
  // CLEAR FIELDS WITHOUT ANY SETSTATE
  // ==============================
  void clearFields() {
    tabNameController.clear();
    ageController.clear();
    keyComplaintcontroller.clear();
    examinationcontroller.clear();
    diagnoscontroller.clear();
    followupDatecontroller.clear();
    remarkscontroller.clear();

    // RESET GENDER WITHOUT setState()
    gender.value = "Male";
  }

  // ==============================
  // DEBUG BUILD TRACKER
  // ==============================

  @override
  void dispose() {
    //print("❌ PatientInfo DISPOSE called — Widget removed");

    tabNameController.dispose();
    ageController.dispose();
    keyComplaintcontroller.dispose();
    examinationcontroller.dispose();
    diagnoscontroller.dispose();
    followupDatecontroller.dispose();
    remarkscontroller.dispose();
    gender.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    //print("🔄 PatientInfo BUILD triggered at: ${DateTime.now()}");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Patient Information",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        // ==============================
        // NAME FIELD
        // ==============================
        TextFormField(
          key: widget.nameFieldKey,
          controller: tabNameController,
          // inputFormatters: [
          //   LengthLimitingTextInputFormatter(50),  // ⭐ MAX 25 CHARACTERS
          //   ],
          maxLength: 50,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          decoration: const InputDecoration(
            labelText: "Enter patient name",
            //border: OutlineInputBorder(),
          ),
          validator:  Validator.apply(context, const [RequiredValidation()]),
          // validator: (v) => v == null || v.trim().isEmpty
          //     ? "Please enter patient name"
          //     : null,
        ),
        const SizedBox(height: 20),

        // ==============================
        // AGE FIELD
        // ==============================
        TextFormField(
          key: widget.ageFieldKey,
          controller: ageController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Enter patient age",
            //border: OutlineInputBorder(),
          ),
          // validator: (v) {
          //   if (v == null || v.trim().isEmpty) return "Age is required";
          //   final n = int.tryParse(v);
          //   if (n == null || n < 1 || n > 120) return "Enter valid age";
          //   return null;
          // },
          validator: Validator.apply(context,
                   const [RequiredValidation(), NumericValidation(), AgeValidation()])
        ),
        const SizedBox(height: 20),

        // ==============================
        // GENDER — ValueNotifier
        // ==============================
            ValueListenableBuilder<String>(
            valueListenable: gender,
            builder: (context, value, _) {
              return DropdownButtonFormField<String>(
                value: value,
                decoration: const InputDecoration(labelText: "Gender"),
                onChanged: (newValue) {
                  gender.value = newValue!;
                },
                items: const [
                  DropdownMenuItem(value: "Male", child: Text("Male")),
                  DropdownMenuItem(value: "Female", child: Text("Female")),
                  DropdownMenuItem(value: "Other", child: Text("Other")),
                ],
              );
            },
          ),
        // ValueListenableBuilder(
        //   valueListenable: gender,
        //   builder: (_, val, __) {
        //     return Row(
        //       children: [
        //         Radio<String>(
        //           value: "Male",
        //           groupValue: val,
        //           onChanged: (v) => gender.value = v!,
        //         ),
        //         const Text("Male"),
        //         const SizedBox(width: 20),
        //         Radio<String>(
        //           value: "Female",
        //           groupValue: val,
        //           onChanged: (v) => gender.value = v!,
        //         ),
        //         const Text("Female"),
        //       ],
        //     );
        //   },
        // ),
        const SizedBox(height: 20),

        // ==============================
        // KEY COMPLAINTS
        // ==============================
        TextFormField(
          controller: keyComplaintcontroller,
          maxLength: 500,
          decoration: const InputDecoration(
            labelText: "Enter chief complaints",
            //border: OutlineInputBorder(),
          ),
          minLines: 1,
          maxLines: 5,
          keyboardType: TextInputType.multiline,
        ),
        const SizedBox(height: 20),

        // ==============================
        // EXAMINATION
        // ==============================
        TextFormField(
          controller: examinationcontroller,
          maxLength: 500,
          decoration: const InputDecoration(
            labelText: "Enter findings on examination",
            //border: OutlineInputBorder(),
          ),
           minLines: 1,
          maxLines: 5,
          keyboardType: TextInputType.multiline,
        ),
        const SizedBox(height: 20),

        // ==============================
        // DIAGNOSIS
        // ==============================
        TextFormField(
          controller: diagnoscontroller,
          maxLength: 500,
          decoration: const InputDecoration(
            labelText: "Enter diagnosis inputs",
            //border: OutlineInputBorder(),
          ),
          minLines: 1,
          maxLines: 5,
          keyboardType: TextInputType.multiline,
        ),
        const SizedBox(height: 20),

        // ==============================
        // NEXT FOLLOWUP DATE
        // ==============================
        TextFormField(
          controller: followupDatecontroller,
          keyboardType:TextInputType.number ,
          readOnly: true,
          decoration: const InputDecoration(
            labelText: "Next Follow-up Date",
            prefixIcon: Icon(Icons.calendar_today),
            filled: true,
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
              )
            //border: OutlineInputBorder(),
          ),
          onTap: _selectNextFollowupDate,
          validator: Validator.apply(context, const [FutureDateStringValidation()]),
        ),
        const SizedBox(height: 20),

        // ==============================
        // REMARKS
        // ==============================
        TextFormField(
          controller: remarkscontroller,
          maxLength: 500,
          keyboardType: TextInputType.multiline,
            minLines: 1,
            maxLines: 5,
          decoration: const InputDecoration(
            labelText: "Remarks",
            //border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
