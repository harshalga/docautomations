// import 'package:docautomations/common/appcolors.dart';
// import 'package:docautomations/common/medicineType.dart';
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
//   late String selectedType;
//   late String unit;

//   final tabNameController = TextEditingController();
//   final doseController = TextEditingController();

//   /// Medicine type list
//   final List<MedicineType> types = [
//     MedicineType("Tablet", Icons.medication, "mg"),
//     MedicineType("Capsule", Icons.medication_liquid, "mg"),
//     MedicineType("Syrup", Icons.local_drink, "ml"),
//     MedicineType("Ointment", Icons.brush, "gm"),
//     MedicineType("Injection", Icons.vaccines, "ml"),
//     MedicineType("Inhalation", Icons.air, "puffs"),
//   ];

//   @override
//   void initState() {
//     super.initState();

//     // Default to Tablet unless prescription has a type saved
//     selectedType = widget.prescription.medicineType ?? "Tablet";
//     unit = _unitForType(selectedType);

//     tabNameController.text = widget.prescription.drugName ?? "";
//     doseController.text = widget.prescription.drugUnit?.toString() ?? "";
//   }

//   @override
//   void dispose() {
//     tabNameController.dispose();
//     doseController.dispose();
//     super.dispose();
//   }

//   String _unitForType(String medicine) {
//     return types.firstWhere((e) => e.name == medicine).unit;
//   }

//   void _selectType(String type) {
//     setState(() {
//       selectedType = type;
//       unit = _unitForType(type);

//       // Update prescription model
//       widget.prescription.medicineType = selectedType;
//       widget.prescription.isTablet = (type == "Tablet" || type == "Capsule" || type == "Syrup" || type == "Injection");
//       widget.prescription.isMeasuredInMg =
//           (type == "Tablet" || type == "Capsule");
//     });
//   }

//   Widget _typeOptionTile(MedicineType med) {
//     final bool selected = selectedType == med.name;

//     return GestureDetector(
//       onTap: () => _selectType(med.name),
//       child: Container(
//         width: 110,
//         padding: const EdgeInsets.symmetric(vertical: 14),
//         margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
//         decoration: BoxDecoration(
//           color: selected ? AppColors.primary : Colors.grey.shade100,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: selected ? AppColors.primary : Colors.grey.shade400,
//             width: 1.5,
//           ),
//           boxShadow: selected
//               ? [
//                   BoxShadow(
//                     color: AppColors.primary.withOpacity(0.3),
//                     blurRadius: 6,
//                     offset: const Offset(0, 4),
//                   )
//                 ]
//               : [],
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               med.icon,
//               size: 28,
//               color: selected ? Colors.white : Colors.black87,
//             ),
//             const SizedBox(height: 6),
//             Text(
//               med.name,
//               style: TextStyle(
//                 fontSize: 13,
//                 fontWeight: FontWeight.w600,
//                 color: selected ? Colors.white : Colors.black87,
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.secondary.withOpacity(0.2),
//             blurRadius: 12,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header label
//           const Text(
//             "Select Medicine Type",
//             style: TextStyle(
//               fontSize: 15,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: 12),

//           // ───────────────────────────────
//           //  Option Buttons (Wrap Layout)
//           // ───────────────────────────────
//           Wrap(
//             spacing: 6,
//             runSpacing: 6,
//             children: types.map((t) => _typeOptionTile(t)).toList(),
//           ),

//           const SizedBox(height: 20),

//           // Medicine Name
//           TextFormField(
//             controller: tabNameController,
//             decoration: InputDecoration(
//               border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//               labelText: "Enter $selectedType Name",
//             ),
//             onChanged: (val) => widget.prescription.drugName = val,
//             validator: Validator.apply(context, const [RequiredValidation()]),
//           ),

//           const SizedBox(height: 20),

//           // Dose Entry
//           Row(
//             children: [
//               const Text("Dosage", style: TextStyle(fontWeight: FontWeight.w600)),
//               const SizedBox(width: 12),

//               Expanded(
//                 child: TextFormField(
//                   controller: doseController,
//                   keyboardType: TextInputType.number,
//                   decoration: InputDecoration(
//                     hintText: "Enter dose in $unit",
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   onChanged: (val) {
//                     widget.prescription.drugUnit =
//                         val.isEmpty ? null : int.tryParse(val);
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
//                 style: const TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.bold,
//                 ),
//               )
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:docautomations/common/appcolors.dart';
import 'package:docautomations/common/medicineType.dart';
import 'package:docautomations/datamodels/prescriptionData.dart';
import 'package:flutter/material.dart';
import 'package:docautomations/validationhandling/validation.dart';
import 'package:docautomations/validationhandling/validator.dart';

class MedicineSwitch extends StatefulWidget {
  final Prescriptiondata prescription;
  //final GlobalKey medicinenameKey ;
  final GlobalKey<FormFieldState<String>> medicinenameKey;
  final GlobalKey<FormFieldState<String>> dosageFieldKey;
  const MedicineSwitch({required this.medicinenameKey,  required this.dosageFieldKey,  required this.prescription ,super.key,});

  //const MedicineSwitch({required this.medicinenameKey,  required this.dosageFieldKey,  required this.prescription ,Key? key,}): super(key: key);

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
    MedicineType("Ointment", Icons.handyman, "gm"), // tube-like icon
    MedicineType("Injection", Icons.vaccines, "ml"),
    MedicineType("Inhalation", Icons.air, "puffs"),
    MedicineType("Drops", Icons.opacity, "drops"),
    MedicineType("Others", Icons.category, ""), // no unit needed
  ];

  @override
  void initState() {
    super.initState();

    selectedType = widget.prescription.medicineType ?? "Tablet";
    unit = _unitForType(selectedType);
    
    // Update prescription model
    widget.prescription.medicineType = selectedType;

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

      widget.prescription.isTablet = (type == "Tablet" ||
          type == "Capsule" ||
          type == "Syrup" ||
          type == "Injection" );

      widget.prescription.isMeasuredInMg = (type == "Tablet" || type == "Capsule");

      // Reset dose when type changes to Others or Ointment (no dosage)
      if (type == "Others" || type == "Ointment") {
        doseController.text = "";
        widget.prescription.drugUnit = null;
      }
      else {
      // FIX: Ensure drugUnit is restored correctly
      widget.prescription.drugUnit =
          doseController.text.isEmpty
              ? null
              : int.tryParse(doseController.text);
    }
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
          children: [
            Icon(
              med.icon,
              size: 28,
              color: selected ? Colors.white : Colors.black87,
            ),
            const SizedBox(height: 6),
            Text(
              med.name,
              textAlign: TextAlign.center,
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
          // const Text(
          //   "Select Medicine Type",
          //   style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          // ),
          //const SizedBox(height: 12),

          /// Medicine type selection buttons
          // Wrap(
          //   spacing: 6,
          //   runSpacing: 6,
          //   children: types.map((t) => _typeOptionTile(t)).toList(),
          // ),
          _buildMedicineTypeSelector(),
          const SizedBox(height: 20),

          /// Medicine Name
          TextFormField(
            key:widget.medicinenameKey,
            controller: tabNameController,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              labelText: "Enter $selectedType Name",
            ),
            onChanged: (val) => widget.prescription.drugName = val,
            validator: Validator.apply(context, const [RequiredValidation()]),
          ),

          const SizedBox(height: 20),

          /// Hide dosage when Ointment or Others selected
          if (selectedType != "Ointment" && selectedType != "Others")
            Row(
              children: [
                const Text("Dosage", style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(width: 12),

                Expanded(
                  child: TextFormField(
                    key: widget.dosageFieldKey,
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


  Widget _buildMedicineTypeSelector() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "Medicine Type",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 10),

      GridView.count(
        crossAxisCount: 4,              // ⭐️ 4 per row
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),

        children: types.map((type) {
          final bool isSelected =
              widget.prescription.medicineType == type.name;

          return GestureDetector(
            onTap:  ()=>_selectType(type.name),
 
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isSelected
                    ? Colors.lightBlue.shade900
                    : Colors.grey.shade200,
                border: Border.all(
                  color: isSelected
                      ? Colors.lightBlue.shade900
                      : Colors.grey.shade400,
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.blue.shade900.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        )
                      ]
                    : [],
              ),

              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    type.icon,
                    size: 26,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    type.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
          );
        }).toList(),
      ),
    ],
  );
}

}
