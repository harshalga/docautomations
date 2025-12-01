//Tablet or Syrup Switch button
// import 'package:docautomations/common/appcolors.dart';
// import 'package:docautomations/datamodels/prescriptionData.dart';
// import 'package:flutter/material.dart';
// import 'package:docautomations/validationhandling/validation.dart';
// import 'package:docautomations/validationhandling/validator.dart';

// class MedicineSwitch extends StatefulWidget {
//   final Prescriptiondata prescription; // Passed prescription

//   const MedicineSwitch({
//     super.key,
//     required this.prescription,
//   });

//   @override
//   State<MedicineSwitch> createState() => MedicineSwitchState();
// }

// class MedicineSwitchState extends State<MedicineSwitch> {
//   late bool istabletType;
//   late String unitofmeasure;
//   late String medicinetype;

//   final tabNameController = TextEditingController();
//   final unitofmeasureController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     istabletType = widget.prescription.isTablet; //?? true;
//     unitofmeasure = istabletType ? 'mg' : 'ml';
//     medicinetype = istabletType ? 'Tablet' : 'Syrup';

//     // Initialize text controllers if needed
//     tabNameController.text = widget.prescription.drugName ;//?? '';
//     //unitofmeasureController.text = widget.prescription.drugUnit.toString();
//     unitofmeasureController.text = widget.prescription.drugUnit?.toString() ?? '';

//     }

//   void _toggleSwitch(bool value) {
//     setState(() {
//       istabletType = value;
//       unitofmeasure = istabletType ? 'mg' : 'ml';
//       medicinetype = istabletType ? 'Tablet' : 'Syrup';

//       // Update the prescription object directly
//       widget.prescription.isTablet = istabletType;
//       widget.prescription.isMeasuredInMg = istabletType;
//     });
//   }

//   @override
//   void dispose() {
//     tabNameController.dispose();
//     unitofmeasureController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.secondary.withOpacity(0.3),
//             blurRadius: 10,
//             offset: Offset.zero,
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//            FittedBox(
//             fit :BoxFit.scaleDown,
//           child: Row(
//             children: [
//               const Padding(
//                 padding: EdgeInsets.all(10),
//                 child: 
                
//                 Text('Medicine (Tablet or Syrup)'),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(10),
//                 child: Switch(
//                   value: istabletType,
//                   onChanged: _toggleSwitch,
//                   activeColor: Colors.blue,
//                   inactiveThumbColor: Colors.grey,
//                   inactiveTrackColor: Colors.grey.shade300,
//                 ),
//               ),
//             ],
//           ),),
      
//           Padding(
//             padding: const EdgeInsets.all(8),
//             child: TextFormField(
//               autofocus: true,
//               decoration: InputDecoration(
//                 border: const OutlineInputBorder(),
//                 labelText: 'Enter $medicinetype Name:',
//               ),
//               controller: tabNameController,
//               onChanged: (value) {
//                 widget.prescription.drugName = value;
//               },
//               validator: Validator.apply(
//                 context,
//                 const [RequiredValidation()],
//               ),
//             ),
//           ),
//           FittedBox(
//             fit: BoxFit.scaleDown,
//             child:
          
//           Row(
//             children: [
//               const Padding(
//                 padding: EdgeInsets.all(8),
//                 child: Text('Dose Unit', textAlign: TextAlign.left),
//               ),
//               SizedBox(
//                 width: 150,
//                 child: TextFormField(
//                   decoration: InputDecoration(
//                     border: const OutlineInputBorder(),
//                     hintText: 'Dose Units in $unitofmeasure',
//                     hintTextDirection: TextDirection.rtl,
//                     errorMaxLines: 2,
//                   ),
//                   controller: unitofmeasureController,
//                   keyboardType: TextInputType.number,
//                   onChanged: (value) {
//                     //widget.prescription.drugUnit = int.tryParse(value); //nulll if empty
//                     widget.prescription.drugUnit = value.isEmpty ? null : int.tryParse(value);
//     //                 if (value.isEmpty) {
//     //   widget.prescription.drugUnit = null; // or leave unchanged
//     // } else {
//     //   widget.prescription.drugUnit = int.tryParse(value);
//     // }
//                   },
//                   validator: Validator.apply(
//                     context,
//                     const [RequiredValidation(), NumericValidation()],
//                   ),
//                 ),
//               ),
//               Text('  $unitofmeasure', textAlign: TextAlign.left),
//             ],
//           ),),
//         ],
//       ),
//     );
//   }
// }
//Tablet or Syrup Button 
// import 'package:docautomations/common/appcolors.dart';
// import 'package:docautomations/datamodels/prescriptionData.dart';
// import 'package:flutter/material.dart';
// import 'package:docautomations/validationhandling/validation.dart';
// import 'package:docautomations/validationhandling/validator.dart';

// class MedicineSwitch extends StatefulWidget {
//   final Prescriptiondata prescription;

//   const MedicineSwitch({super.key, required this.prescription});

//   @override
//   State<MedicineSwitch> createState() => MedicineSwitchState();
// }

// class MedicineSwitchState extends State<MedicineSwitch> {
//   late bool isTablet;
//   late String unit;
//   late String typeLabel;

//   final tabNameController = TextEditingController();
//   final doseController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();

//     isTablet = widget.prescription.isTablet ?? true;
//     unit = isTablet ? "mg" : "ml";
//     typeLabel = isTablet ? "Tablet" : "Syrup";

//     tabNameController.text = widget.prescription.drugName ?? "";
//     doseController.text = widget.prescription.drugUnit?.toString() ?? "";
//   }

//   @override
//   void dispose() {
//     tabNameController.dispose();
//     doseController.dispose();
//     super.dispose();
//   }

//   // ───────────────────────────────────────────────
//   //  Custom Option Button (Tablet / Syrup)
//   // ───────────────────────────────────────────────
//   Widget _buildOptionButton({
//     required String label,
//     required bool isSelected,
//     required VoidCallback onTap,
//   }) {
//     return Expanded(
//       child: GestureDetector(
//         onTap: onTap,
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 12),
//           margin: const EdgeInsets.symmetric(horizontal: 6),
//           decoration: BoxDecoration(
//             color: isSelected ? Colors.lightBlue.shade900 : Colors.grey.shade200,
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(
//               color: isSelected ? Colors.lightBlue.shade900 : Colors.grey.shade400,
//               width: 1.5,
//             ),
//             boxShadow: isSelected
//                 ? [
//                     BoxShadow(
//                       color: AppColors.primary.withOpacity(0.3),
//                       blurRadius: 6,
//                       offset: const Offset(0, 3),
//                     )
//                   ]
//                 : [],
//           ),
//           child: Center(
//             child: Text(
//               label,
//               style: TextStyle(
//                 color: isSelected ? Colors.white : Colors.black87,
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _selectType(bool tablet) {
//     setState(() {
//       isTablet = tablet;
//       unit = isTablet ? "mg" : "ml";
//       typeLabel = isTablet ? "Tablet" : "Syrup";

//       widget.prescription.isTablet = isTablet;
//       widget.prescription.isMeasuredInMg = isTablet;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.secondary.withOpacity(0.2),
//             blurRadius: 10,
//             offset: Offset.zero,
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Title
//           const Padding(
//             padding: EdgeInsets.only(bottom: 8),
//             child: Text(
//               "Medicine Type",
//               style: TextStyle(
//                 fontSize: 15,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),

//           // ────────────── OPTION BUTTONS (Tablet / Syrup) ──────────────
//           Row(
//             children: [
//               _buildOptionButton(
//                 label: "Tablet",
//                 isSelected: isTablet == true,
//                 onTap: () => _selectType(true),
//               ),
//               _buildOptionButton(
//                 label: "Syrup",
//                 isSelected: isTablet == false,
//                 onTap: () => _selectType(false),
//               ),
//             ],
//           ),

//           const SizedBox(height: 20),

//           // ────────────── MEDICINE NAME ──────────────
//           TextFormField(
//             controller: tabNameController,
//             decoration: InputDecoration(
//               border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//               labelText: "Enter $typeLabel Name",
//             ),
//             onChanged: (val) => widget.prescription.drugName = val,
//             validator: Validator.apply(context, const [RequiredValidation()]),
//           ),

//           const SizedBox(height: 20),

//           // ────────────── DOSAGE UNIT ──────────────
//           Row(
//             children: [
//               const Text("Dose Unit", style: TextStyle(fontWeight: FontWeight.w500)),
//               const SizedBox(width: 12),

//               Expanded(
//                 child: TextFormField(
//                   controller: doseController,
//                   keyboardType: TextInputType.number,
//                   decoration: InputDecoration(
//                     hintText: "Enter dose in $unit",
//                     hintTextDirection: TextDirection.ltr,
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   onChanged: (value) {
//                     widget.prescription.drugUnit =
//                         value.isEmpty ? null : int.tryParse(value);
//                   },
//                   validator: Validator.apply(
//                     context,
//                     const [RequiredValidation(), NumericValidation()],
//                   ),
//                 ),
//               ),

//               const SizedBox(width: 10),

//               Text(
//                 unit,
//                 style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }


//New code with all the 6 medicine type 
import 'package:docautomations/common/appcolors.dart';
import 'package:docautomations/common/medicineType.dart';
import 'package:docautomations/datamodels/prescriptionData.dart';
import 'package:flutter/material.dart';
import 'package:docautomations/validationhandling/validation.dart';
import 'package:docautomations/validationhandling/validator.dart';

class MedicineSwitch extends StatefulWidget {
  final Prescriptiondata prescription;

  const MedicineSwitch({super.key, required this.prescription});

  @override
  State<MedicineSwitch> createState() => MedicineSwitchState();
}

class MedicineSwitchState extends State<MedicineSwitch> {
  late String selectedType;
  late String unit;

  final tabNameController = TextEditingController();
  final doseController = TextEditingController();

  /// Medicine type list
  final List<MedicineType> types = [
    MedicineType("Tablet", Icons.medication, "mg"),
    MedicineType("Capsule", Icons.medication_liquid, "mg"),
    MedicineType("Syrup", Icons.local_drink, "ml"),
    MedicineType("Ointment", Icons.brush, "gm"),
    MedicineType("Injection", Icons.vaccines, "ml"),
    MedicineType("Inhalation", Icons.air, "puffs"),
  ];

  @override
  void initState() {
    super.initState();

    // Default to Tablet unless prescription has a type saved
    selectedType = widget.prescription.medicineType ?? "Tablet";
    unit = _unitForType(selectedType);

    tabNameController.text = widget.prescription.drugName ?? "";
    doseController.text = widget.prescription.drugUnit?.toString() ?? "";
  }

  @override
  void dispose() {
    tabNameController.dispose();
    doseController.dispose();
    super.dispose();
  }

  String _unitForType(String medicine) {
    return types.firstWhere((e) => e.name == medicine).unit;
  }

  void _selectType(String type) {
    setState(() {
      selectedType = type;
      unit = _unitForType(type);

      // Update prescription model
      widget.prescription.medicineType = selectedType;
      widget.prescription.isTablet = (type == "Tablet" || type == "Capsule" || type == "Syrup" || type == "Injection");
      widget.prescription.isMeasuredInMg =
          (type == "Tablet" || type == "Capsule");
    });
  }

  Widget _typeOptionTile(MedicineType med) {
    final bool selected = selectedType == med.name;

    return GestureDetector(
      onTap: () => _selectType(med.name),
      child: Container(
        width: 110,
        padding: const EdgeInsets.symmetric(vertical: 14),
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.grey.shade400,
            width: 1.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              med.icon,
              size: 28,
              color: selected ? Colors.white : Colors.black87,
            ),
            const SizedBox(height: 6),
            Text(
              med.name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : Colors.black87,
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header label
          const Text(
            "Select Medicine Type",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          // ───────────────────────────────
          //  Option Buttons (Wrap Layout)
          // ───────────────────────────────
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: types.map((t) => _typeOptionTile(t)).toList(),
          ),

          const SizedBox(height: 20),

          // Medicine Name
          TextFormField(
            controller: tabNameController,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              labelText: "Enter $selectedType Name",
            ),
            onChanged: (val) => widget.prescription.drugName = val,
            validator: Validator.apply(context, const [RequiredValidation()]),
          ),

          const SizedBox(height: 20),

          // Dose Entry
          Row(
            children: [
              const Text("Dosage", style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(width: 12),

              Expanded(
                child: TextFormField(
                  controller: doseController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Enter dose in $unit",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (val) {
                    widget.prescription.drugUnit =
                        val.isEmpty ? null : int.tryParse(val);
                  },
                  validator: Validator.apply(
                    context,
                    const [RequiredValidation(), NumericValidation()],
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Text(
                unit,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}


