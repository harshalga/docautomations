import 'package:docautomations/common/appcolors.dart';
import 'package:docautomations/datamodels/prescriptionData.dart';
import 'package:flutter/material.dart';
import 'package:docautomations/validationhandling/validation.dart';
import 'package:docautomations/validationhandling/validator.dart';
import 'package:flutter/services.dart';

class ConsumptionPeriod extends StatefulWidget {
  final Prescriptiondata prescriptionData;

  final GlobalKey<FormFieldState<String>> durationFieldKey;

  const ConsumptionPeriod({super.key, required this.durationFieldKey, required this.prescriptionData});

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

    //clear the text field and model duration when switching period type
final text =
      durationController.text.trim();

  final value =
      int.tryParse(text);

  if (value != null) {

    // -----------------------------
    // If switched to Days
    // Max = 31
    // -----------------------------
    if (period ==
        PeriodLabel.daysperiod) {

      if (value > 31) {
        durationController.clear();

        widget.prescriptionData
            .updateFollowupDuration(
                null);

        widget.durationFieldKey
            .currentState
            ?.reset();
      }

    }

    // -----------------------------
    // If switched to Months
    // Max = 12
    // -----------------------------
    else {

      if (value > 12) {
        durationController.clear();

        widget.prescriptionData
            .updateFollowupDuration(
                null);

        widget.durationFieldKey
            .currentState
            ?.reset();
      }
    }
  }

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
            key: widget.durationFieldKey,
            controller: durationController,
            keyboardType: TextInputType.number,
            inputFormatters: [
    FilteringTextInputFormatter.digitsOnly,

    // ✅ Dynamic max digits
    LengthLimitingTextInputFormatter(
      selectedPeriod ==
              PeriodLabel.daysperiod
          ? 2
          : 2,
    ),
  ],
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
