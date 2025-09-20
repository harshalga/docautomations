import 'package:docautomations/common/appcolors.dart';
import 'package:docautomations/datamodels/prescriptionData.dart';
import 'package:flutter/material.dart';
import 'package:docautomations/validationhandling/validation.dart';
import 'package:docautomations/validationhandling/validator.dart';
import 'package:collection/collection.dart';

class ConsumptionPeriod extends StatefulWidget {
  final Prescriptiondata prescriptionData;  // Accept Prescriptiondata from parent

  const ConsumptionPeriod({super.key, required this.prescriptionData});  // Constructor to accept Prescriptiondata

  @override
  State<ConsumptionPeriod> createState() => ConsumptionPeriodState();
}

typedef PeriodEntry = DropdownMenuEntry<PeriodLabel>;

enum PeriodLabel {
  daysperiod('days', 1),
  monthsperiod('months', 2);

  const PeriodLabel(this.label, this.val);
  final String label;
  final int val;

  static final List<PeriodEntry> entries = UnmodifiableListView<PeriodEntry>(
    values.map<PeriodEntry>(
      (PeriodLabel period) => PeriodEntry(
        value: period,
        label: period.label,
      ),
    ),
  );
}

class ConsumptionPeriodState extends State<ConsumptionPeriod> {
  late TextEditingController periodController;
  late TextEditingController durationController;
  PeriodLabel? selectedPeriod;
  late DateTime now;

  @override
  void initState() {
    super.initState();
    now = DateTime.now();
    
    // Initialize selectedPeriod based on prescriptionData
    selectedPeriod = widget.prescriptionData.inDays ? PeriodLabel.daysperiod : PeriodLabel.monthsperiod;
    periodController = TextEditingController(text: selectedPeriod!.label);
    durationController = TextEditingController(text: widget.prescriptionData.followupDuration?.toString() ?? '');
  }

  @override
  void didUpdateWidget(covariant ConsumptionPeriod oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset controllers if model changes
    setState(() {
      selectedPeriod = widget.prescriptionData.inDays ? PeriodLabel.daysperiod : PeriodLabel.monthsperiod;
      periodController.text = selectedPeriod!.label;
      durationController.text = widget.prescriptionData.followupDuration?.toString() ?? '';
    });
  }

  void _onPeriodSelected(PeriodLabel? period) {
    if (period == null) return;
    setState(() {
      selectedPeriod = period;
    });
    widget.prescriptionData.updateInDays(selectedPeriod == PeriodLabel.daysperiod);
    _updateFollowupDateFromDuration();
  }

  void _onDurationChanged(String value) {
    final int? duration = int.tryParse(value);
    if (duration != null) {
      widget.prescriptionData.updateFollowupDuration(duration);
      _updateFollowupDate(duration);
    }
  }

  void _updateFollowupDateFromDuration() {
    final value = int.tryParse(durationController.text);
    if (value != null) {
      _updateFollowupDate(value);
    }
  }

  void _updateFollowupDate(int duration) {
    if (selectedPeriod == PeriodLabel.daysperiod) {
      widget.prescriptionData.updateFollowupDate(now.add(Duration(days: duration)));
    } else {
      final newDate = DateTime(
        now.year,
        now.month + duration,
        now.day,
      );
      widget.prescriptionData.updateFollowupDate(newDate);
    }
  }

  @override
  void dispose() {
    periodController.dispose();
    durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset.zero,
          ),
        ],
      ),
      child: Row(
        children: [
          DropdownMenu<PeriodLabel>(
            dropdownMenuEntries: PeriodLabel.entries,
            initialSelection: selectedPeriod,
            controller: periodController,
            requestFocusOnTap: true,
            label: const Text('Select Period'),
            onSelected: _onPeriodSelected,
          ),
          const SizedBox(width: 5),
          Expanded(
            child: TextFormField(
              controller: durationController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: ' ${selectedPeriod?.label ?? "days"}',
              ),
              validator: Validator.apply(
                context,
                [
                  const RequiredValidation(),
                  const NumericValidation(),
                  PeriodbasedValidation(selectedlabel: selectedPeriod?.label ?? 'days'),
                ],
              ),
              onChanged: _onDurationChanged,
              keyboardType: TextInputType.number,
            ),
          ),
        ],
      ),
    );
  }
}
