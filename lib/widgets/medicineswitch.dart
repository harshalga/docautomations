import 'package:docautomations/common/appcolors.dart';
import 'package:docautomations/common/medicineType.dart';
import 'package:docautomations/datamodels/prescriptionData.dart';
import 'package:flutter/material.dart';
import 'package:docautomations/validationhandling/validation.dart';
import 'package:docautomations/validationhandling/validator.dart';
import 'package:flutter/services.dart';

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
    MedicineType("Tablet", Image.asset(
    "assets/icon/tablet.png",
    width: 28,
    height: 28,
    fit: BoxFit.contain,
  ), "mg"),
    MedicineType("Capsule", Image.asset(
    "assets/icon/capsule.png",
    width: 28,
    height: 28,
    fit: BoxFit.contain,
  ), "mg"),
    MedicineType("Syrup", Image.asset(
    "assets/icon/bottle.png",
    width: 28,
    height: 28,
    fit: BoxFit.contain,
  ) , "ml"),
    MedicineType("Ointment", Image.asset(
    "assets/icon/ointment.png",
    width: 28,
    height: 28,
    fit: BoxFit.contain,
  ) , "gm"), // tube-like icon
    MedicineType("Injection",Image.asset(
    "assets/icon/injection.png",
    width: 28,
    height: 28,
    fit: BoxFit.contain,
  ) , "ml"),
    MedicineType("Inhalation", Image.asset(
    "assets/icon/inhaler.png",
    width: 28,
    height: 28,
    fit: BoxFit.contain,
  ) , "puffs"),
    MedicineType("Drops",Image.asset(
    "assets/icon/eye-dropper.png",
    width: 28,
    height: 28,
    fit: BoxFit.contain,
  ) , "drops"),
    MedicineType("Others", Image.asset(
    "assets/icon/first-aid-kit.png",
    width: 28,
    height: 28,
    fit: BoxFit.contain,
  ) , ""), // no unit needed
  ];

  @override
  void initState() {
    super.initState();

    selectedType = widget.prescription.medicineType ?? "Tablet";
    unit = _unitForType(selectedType);
    
    // Update prescription model
    widget.prescription.medicineType = selectedType;

    tabNameController.text = widget.prescription.drugName ;
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
              : double.tryParse(doseController.text);
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
            IconTheme(
      data: IconThemeData(
        color: selected  ? Colors.white : Colors.black87,
        size: 26,
      ),
      child: med.icon,
    ),
            // Icon(
            //   med.icon,
            //   size: 28,
            //   color: selected ? Colors.white : Colors.black87,
            // ),
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
          const SizedBox(height: 10),

          /// Medicine Name
          TextFormField(
            key:widget.medicinenameKey,
            controller: tabNameController,
            maxLength: 50,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              labelText:  selectedType == 'Others'
              ? 'Enter other medicine type'
              : 'Enter $selectedType Name' ,//"Enter $selectedType Name",
              errorMaxLines: 3,
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
                      errorMaxLines: 3,
                    ),
                    onChanged: (val) {
                      widget.prescription.drugUnit =
                          val.isEmpty ? null : double.tryParse(val);
                    },
                    validator: Validator.apply(
                      context,
                       [RequiredValidation(), DoubleValidation(), DosageValidation(selectedType)],
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
              height: 96,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isSelected
                    ? Colors.red.shade900
                    : Colors.grey.shade200,
                border: Border.all(
                  color: isSelected
                      ? const Color.fromARGB(255, 218, 3, 57)
                      : Colors.grey.shade400,
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.secondary.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        )
                      ]
                    : [],
              ),

//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   // Icon(
//                   //   type.icon,
//                   //   size: 26,
//                   //   color: isSelected ? Colors.white : Colors.black87,
//                   // ),
//                   IconTheme(
//   data: IconThemeData(
//     color: isSelected ? Colors.white : Colors.black87,
//     size: 26,
//   ),
//   child: type.icon,
// ),
//                   const SizedBox(height: 6),
//                   Text(
//                     type.name,
//                     style: TextStyle(
//                       fontWeight: FontWeight.w600,
//                       fontSize: 12,
//                       color: isSelected ? Colors.white : Colors.black87,
//                     ),
//                     textAlign: TextAlign.center,
//                   )
//                 ],
//               ),
child: Column(
  mainAxisAlignment: MainAxisAlignment.center,
  crossAxisAlignment: CrossAxisAlignment.center, // 👈 ADD HERE
  children: [
    SizedBox(
      height: 32,
      child: type.icon,
    ),
    const SizedBox(height: 4),
    // Text(
    //   type.name,
    //   textAlign: TextAlign.center,
    //   maxLines: 1,
    //   overflow: TextOverflow.ellipsis,
    //   style: TextStyle(
    //     fontWeight: FontWeight.w600,
    //     fontSize: 12,
    //     color: isSelected ? Colors.white : Colors.black87,
    //   ),
    // ),
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
