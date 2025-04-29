import 'package:docautomations/common/appcolors.dart';
import 'package:docautomations/datamodels/prescriptionData.dart';
import 'package:docautomations/main.dart';
import 'package:docautomations/widgets/AddPrescription.dart';
import 'package:docautomations/widgets/PatientInfo.dart';
import 'package:flutter/material.dart';

class Addprescriptionscr extends StatefulWidget {
  const Addprescriptionscr({super.key});

  @override
  State<Addprescriptionscr> createState() => _AddprescriptionscrState();
}

class _AddprescriptionscrState extends State<Addprescriptionscr> {
  final _formKey = GlobalKey<FormState>();


  String _patientName = '';
  String _patientAge = '';
  String _patientGender = '';
  String _keycomplaint='';
  String _examination='';
  String _diagnosis='';

  // Instead of a single prescription, maintain a list
  final List<Prescriptiondata> _prescriptions = [];

  static const descTextStyle = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.w800,
    fontFamily: 'Roboto',
    letterSpacing: 0.5,
    fontSize: 18,
    height: 2,
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: Offset.zero),
            ],
          ),
          child: Form(
            key: _formKey,
            child: DefaultTextStyle.merge(
              style: descTextStyle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Patientinfo(onChanged: (name, age, gender,keycomplaint,
                    examination, diagnostics) 
                    {
                       setState(() {
                            _patientName = name;
                            _patientAge = age;
                            _patientGender = gender;
                            _keycomplaint=keycomplaint;
                            _examination=examination;
                            _diagnosis=diagnostics;
                    });
                    },),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: ElevatedButton(
                      onPressed: () {
                        _createPrescription(context);
                      },
                      child: const Text('Add Medicine'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // If there are medicines added, show them
                  _prescriptions.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _prescriptions.length,
                          itemBuilder: (context, index) {
                            final presc = _prescriptions[index];
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 5,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                title: Text(presc.drugName ?? "Unnamed"),
                                subtitle: Text(
                                    "For ${presc.followupDuration} ${presc.inDays?"days":"Months"}  | ${presc.isBeforeFood ? "Before Food" : "After Food"} | ${presc.toBitList(4)}"),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _editPrescription(context, index);
                                    } else if (value == 'delete') {
                                      _deletePrescription(index);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Text('Edit'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Delete'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                      : const Text('No medicines added yet.'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _createPrescription(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>  const AddPrescription(title: "Prescription"),
      ),
    );

    if (result != null && result is Prescriptiondata) {
      setState(() {
        _prescriptions.add(result);
      });
      print("Added medicine: ${result.drugName}");
    }
  }

  Future<void> _editPrescription(BuildContext context, int index) async {
    final existing = _prescriptions[index];
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>  AddPrescription(
          title: "Edit Prescription",existingPrescription: existing
          // You can pass existing data here if your AddPrescription page supports it
        ),
      ),
    );

    if (result != null && result is Prescriptiondata) {
      setState(() {
        _prescriptions[index] = result;
      });
      print("Edited medicine at index $index: ${result.drugName}");
    }
  }

  void _deletePrescription(int index) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Prescription'),
      content: const Text('Are you sure you want to delete this prescription?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );

  if (confirm == true) {
    setState(() {
      _prescriptions.removeAt(index);
    });
    print("Deleted medicine at index $index");
  }
}

}
