import 'package:docautomations/common/appcolors.dart';
import 'package:docautomations/datamodels/prescriptionData.dart';
import 'package:flutter/material.dart';

class Instructions extends StatefulWidget {
  final Prescriptiondata prescriptionData;  // Accept Prescriptiondata from parent

  const Instructions({super.key, required this.prescriptionData});  // Constructor to accept Prescriptiondata

  @override
  State<Instructions> createState() => InstructionsState();
}

class InstructionsState extends State<Instructions> {
  final TextEditingController remarksController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize the controller with the current remarks from Prescriptiondata
    remarksController.text = widget.prescriptionData.remarks ?? '';
  }

  @override
  void dispose() {
    remarksController.dispose();
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
          Expanded(
            child: TextField(
              controller: remarksController,
              maxLength: 300,
              keyboardType: TextInputType.multiline,
              minLines: 1,
              maxLines: 5,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Instructions',
              ),
              onChanged: (value) {
                // Update remarks directly on the passed Prescriptiondata
                widget.prescriptionData.updateRemarks(value);
              },
            ),
          ),
        ],
      ),
    );
  }
}
