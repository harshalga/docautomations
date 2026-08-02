import 'package:docautomations/widgets/AddPrescriptionScr.dart';
import 'package:flutter/material.dart';

enum PatientMode {
  newPatient,
  existingPatient,
}


class Addprescrip extends StatefulWidget {
   final String title;
   final PatientMode mode; // New Patient or Existing Patient
  const Addprescrip({super.key, required this.title, this.mode=PatientMode.existingPatient});

  @override
  State<Addprescrip> createState() => _AddprescripState();
}

class _AddprescripState extends State<Addprescrip> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text(widget.title,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onSecondary,
                )),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      body: const Center(
        child: Addprescriptionscr(),
      ),
    );
  }
}