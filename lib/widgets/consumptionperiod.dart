// import 'package:docautomations/common/appcolors.dart';
// import 'package:docautomations/datamodels/prescriptionData.dart';
// import 'package:flutter/material.dart';
// import 'package:docautomations/validationhandling/validation.dart';
// import 'package:docautomations/validationhandling/validator.dart';
// import 'package:collection/collection.dart';

// class ConsumptionPeriod extends StatefulWidget {
//   final Prescriptiondata prescriptionData;  // Accept Prescriptiondata from parent

//   const ConsumptionPeriod({super.key, required this.prescriptionData});  // Constructor to accept Prescriptiondata

//   @override
//   State<ConsumptionPeriod> createState() => ConsumptionPeriodState();
// }

// typedef PeriodEntry = DropdownMenuEntry<PeriodLabel>;

// enum PeriodLabel {
//   daysperiod('days', 1),
//   monthsperiod('months', 2);

//   const PeriodLabel(this.label, this.val);
//   final String label;
//   final int val;

//   static final List<PeriodEntry> entries = UnmodifiableListView<PeriodEntry>(
//     values.map<PeriodEntry>(
//       (PeriodLabel period) => PeriodEntry(
//         value: period,
//         label: period.label,
//       ),
//     ),
//   );
// }

// class ConsumptionPeriodState extends State<ConsumptionPeriod> {
//   late TextEditingController periodController;
//   late TextEditingController durationController;
//   PeriodLabel? selectedPeriod;
//   late DateTime now;

//   @override
//   void initState() {
//     super.initState();
//     now = DateTime.now();
    
//     // Initialize selectedPeriod based on prescriptionData
//     selectedPeriod = widget.prescriptionData.inDays ? PeriodLabel.daysperiod : PeriodLabel.monthsperiod;
//     periodController = TextEditingController(text: selectedPeriod!.label);
//     durationController = TextEditingController(text: widget.prescriptionData.followupDuration?.toString() ?? '');
//   }

//   @override
//   void didUpdateWidget(covariant ConsumptionPeriod oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     // Reset controllers if model changes
//     setState(() {
//       selectedPeriod = widget.prescriptionData.inDays ? PeriodLabel.daysperiod : PeriodLabel.monthsperiod;
//       periodController.text = selectedPeriod!.label;
//       durationController.text = widget.prescriptionData.followupDuration?.toString() ?? '';
//     });
//   }

//   void _onPeriodSelected(PeriodLabel? period) {
//     if (period == null) return;
//     setState(() {
//       selectedPeriod = period;
//     });
//     widget.prescriptionData.updateInDays(selectedPeriod == PeriodLabel.daysperiod);
//     _updateFollowupDateFromDuration();
//   }

//   void _onDurationChanged(String value) {
//     final int? duration = int.tryParse(value);
//     if (duration != null) {
//       widget.prescriptionData.updateFollowupDuration(duration);
//       _updateFollowupDate(duration);
//     }
//   }

//   void _updateFollowupDateFromDuration() {
//     final value = int.tryParse(durationController.text);
//     if (value != null) {
//       _updateFollowupDate(value);
//     }
//   }

//   void _updateFollowupDate(int duration) {
//     if (selectedPeriod == PeriodLabel.daysperiod) {
//       widget.prescriptionData.updateFollowupDate(now.add(Duration(days: duration)));
//     } else {
//       final newDate = DateTime(
//         now.year,
//         now.month + duration,
//         now.day,
//       );
//       widget.prescriptionData.updateFollowupDate(newDate);
//     }
//   }

//   @override
//   void dispose() {
//     periodController.dispose();
//     durationController.dispose();
//     super.dispose();
//   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       padding: const EdgeInsets.all(10),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(10),
// //         boxShadow: [
// //           BoxShadow(
// //             color: AppColors.secondary.withOpacity(0.3),
// //             blurRadius: 10,
// //             offset: Offset.zero,
// //           ),
// //         ],
// //       ),
// //       child: Column(
// //   crossAxisAlignment: CrossAxisAlignment.start,
// //   children: [
// //     DropdownMenu<PeriodLabel>(
// //       dropdownMenuEntries: PeriodLabel.entries,
// //       initialSelection: selectedPeriod,
// //       controller: periodController,
// //       requestFocusOnTap: true,
// //       label: const Text('Select Period'),
// //       onSelected: _onPeriodSelected,
// //     ),

// //     const SizedBox(height: 10),

// //     TextFormField(
// //       controller: durationController,
// //       decoration: InputDecoration(
// //         border: const OutlineInputBorder(),
// //         labelText: ' ${selectedPeriod?.label ?? "days"}',
// //       ),
// //       validator: Validator.apply(
// //         context,
// //         [
// //           const RequiredValidation(),
// //           const NumericValidation(),
// //           PeriodbasedValidation(selectedlabel: selectedPeriod?.label ?? 'days'),
// //         ],
// //       ),
// //       onChanged: _onDurationChanged,
// //       keyboardType: TextInputType.number,
// //     ),
// //   ],
// // ),

// //     );
// //   }
//   @override
//  Widget build(BuildContext context) {
//   return buildPeriodDurationField();
//  }

// Widget buildPeriodDurationField() {
//   return Container(
//     margin: const EdgeInsets.symmetric(vertical: 10),
//     padding: const EdgeInsets.all(14),
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(16),
//       boxShadow: [
//         BoxShadow(
//           color: AppColors.secondary.withOpacity(0.3),
//           blurRadius: 12,
//           offset: const Offset(0, 4),
//         ),
//       ],
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "Select Duration Type",
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w600,
//             color: Colors.grey[800],
//           ),
//         ),
//         const SizedBox(height: 6),

//         DropdownButtonFormField<PeriodLabel>(
//           value: selectedPeriod,
//           items: PeriodLabel.values.map((e) {
//             return DropdownMenuItem<PeriodLabel>(
//               value: e,
//               child: Text(e.label), // Use your custom label getter
//             );
//           }).toList(),
//           decoration: InputDecoration(
//             filled: true,
//             fillColor: Colors.grey[100],
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(color: Colors.grey.shade400),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(color: Colors.grey.shade300),
//             ),
//           ),
//           onChanged: _onPeriodSelected,
//         ),

//         const SizedBox(height: 20),

//         Text(
//           "Enter Duration",
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w600,
//             color: Colors.grey[800],
//           ),
//         ),
//         const SizedBox(height: 6),

//         TextFormField(
//           controller: durationController,
//           keyboardType: TextInputType.number,
//           decoration: InputDecoration(
//             hintText: "Enter number of ${selectedPeriod?.label ?? "days"}",
//             filled: true,
//             fillColor: Colors.grey[100],
//             prefixIcon: const Icon(Icons.timer_outlined),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(color: Colors.grey.shade400),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(color: Colors.grey.shade300),
//             ),
//           ),
//           validator: Validator.apply(
//             context,
//             [
//               const RequiredValidation(),
//               const NumericValidation(),
//               PeriodbasedValidation(
//                 selectedlabel: selectedPeriod?.label ?? 'days',
//               ),
//             ],
//           ),
//           onChanged: _onDurationChanged,
//         ),
//       ],
//     ),
//   );
// }



// }


import 'package:docautomations/common/appcolors.dart';
import 'package:docautomations/datamodels/prescriptionData.dart';
import 'package:flutter/material.dart';
import 'package:docautomations/validationhandling/validation.dart';
import 'package:docautomations/validationhandling/validator.dart';

class ConsumptionPeriod extends StatefulWidget {
  final Prescriptiondata prescriptionData;

  const ConsumptionPeriod({super.key, required this.prescriptionData});

  @override
  State<ConsumptionPeriod> createState() => ConsumptionPeriodState();
}

enum PeriodLabel { daysperiod, monthsperiod }

extension PeriodLabelExt on PeriodLabel {
  String get label => this == PeriodLabel.daysperiod ? "days" : "months";
}

class ConsumptionPeriodState extends State<ConsumptionPeriod> {
  late TextEditingController durationController;
  PeriodLabel selectedPeriod = PeriodLabel.daysperiod;
  late DateTime now;

  @override
  void initState() {
    super.initState();
    now = DateTime.now();

    // Initialize from existing model
    selectedPeriod =
        widget.prescriptionData.inDays ? PeriodLabel.daysperiod : PeriodLabel.monthsperiod;

    durationController = TextEditingController(
      text: widget.prescriptionData.followupDuration?.toString() ?? "",
    );
  }

  @override
  void didUpdateWidget(covariant ConsumptionPeriod oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Sync UI with updated data model
    setState(() {
      selectedPeriod =
          widget.prescriptionData.inDays ? PeriodLabel.daysperiod : PeriodLabel.monthsperiod;
      durationController.text =
          widget.prescriptionData.followupDuration?.toString() ?? "";
    });
  }

  // When the user taps Days / Months button
  void _onPeriodSelected(PeriodLabel period) {
    setState(() => selectedPeriod = period);

    // Update model
    widget.prescriptionData.updateInDays(period == PeriodLabel.daysperiod);

    _updateFollowupBasedOnInputs();
  }

  // When the user types duration
  void _onDurationChanged(String value) {
    final d = int.tryParse(value);
    if (d == null) return;

    widget.prescriptionData.updateFollowupDuration(d);
    _updateFollowupBasedOnInputs();
  }

  void _updateFollowupBasedOnInputs() {
    final d = int.tryParse(durationController.text);
    if (d == null) return;

    if (selectedPeriod == PeriodLabel.daysperiod) {
      if (d>31) return;
      widget.prescriptionData.updateFollowupDate(now.add(Duration(days: d)));
    } else {
      if (d>12) return;
      final newDate = addMonthsSafe(now, d);
      widget.prescriptionData.updateFollowupDate(
        newDate
      );
    }
  }
DateTime addMonthsSafe(DateTime date, int monthsToAdd) {
  int newYear = date.year + ((date.month + monthsToAdd - 1) ~/ 12);
  int newMonth = ((date.month + monthsToAdd - 1) % 12) + 1;

  int day = date.day;
  int lastDayOfNewMonth = DateTime(newYear, newMonth + 1, 0).day;

  // Clamp day to last valid day of target month
  if (day > lastDayOfNewMonth) {
    day = lastDayOfNewMonth;
  }

  return DateTime(newYear, newMonth, day);
}


  @override
  void dispose() {
    durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildPeriodDurationField();
  }

  // =====================================
  //      BEAUTIFUL NEW UI
  // =====================================
  Widget buildPeriodDurationField() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -----------------------------
          // 🔘 SELECTION BUTTONS
          // -----------------------------
          Text(
            "Select Duration Unit For Medication",
            // style: TextStyle(
            //   fontSize: 14,
            //   fontWeight: FontWeight.w700,
            //   color: Colors.grey[800],
            // ),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              _buildOptionButton(
                label: "Days",
                selected: selectedPeriod == PeriodLabel.daysperiod,
                onTap: () => _onPeriodSelected(PeriodLabel.daysperiod),
              ),
              const SizedBox(width: 10),
              _buildOptionButton(
                label: "Months",
                selected: selectedPeriod == PeriodLabel.monthsperiod,
                onTap: () => _onPeriodSelected(PeriodLabel.monthsperiod),
              ),
            ],
          ),

          const SizedBox(height: 25),

          // --------------------------------
          // 🔢 DURATION INPUT
          // --------------------------------
          Text(
            "Enter Duration For Taking Medication",
            // style: TextStyle(
            //   fontSize: 14,
            //   fontWeight: FontWeight.w700,
            //   color: Colors.grey[800],
            // ),
          ),
          const SizedBox(height: 6),

          TextFormField(
            controller: durationController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: "Enter number of ${selectedPeriod.label}",
              filled: true,
              fillColor: Colors.grey[100],
              prefixIcon: const Icon(Icons.timer_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            validator: Validator.apply(
              context,
              [
                const RequiredValidation(),
                const NumericValidation(),
                PeriodbasedValidation(
                  selectedlabel: selectedPeriod.label,
                ),
              ],
            ),
            onChanged: _onDurationChanged,
          ),
        ],
      ),
    );
  }

  // ================================
  //  OPTION BUTTON WIDGET
  // ================================
  Widget _buildOptionButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ?Colors.lightBlue.shade900 : Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ?Colors.lightBlue.shade900 : Colors.grey.shade400,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
