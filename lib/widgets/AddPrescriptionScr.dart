// import 'package:docautomations/common/appcolors.dart';
// import 'package:docautomations/datamodels/prescriptionData.dart';
// import 'package:docautomations/main.dart';
// import 'package:docautomations/widgets/PatientInfo.dart';
// import 'package:flutter/material.dart';

// class Addprescriptionscr  extends StatefulWidget {
//   const Addprescriptionscr({super.key});

//   @override
//   State<Addprescriptionscr> createState() => _AddprescriptionscrState();
// }

// class _AddprescriptionscrState extends State<Addprescriptionscr> {
 
//   final _formKey = GlobalKey<FormState>();

//   final    _prescriptiondata =Prescriptiondata();
//   static const descTextStyle = TextStyle(
//     color: Colors.black,
//     fontWeight: FontWeight.w800,
//     fontFamily: 'Roboto',
//     letterSpacing: 0.5,
//     fontSize: 18,
//     height: 2,
//   );
//   @override
//   Widget build(BuildContext context) {
//      return 
//     SizedBox(height: MediaQuery.of(context).size.height,
//      child:SingleChildScrollView(

//       child: 
//     Container(
//       padding:const EdgeInsets.all(20),
//       margin: const EdgeInsets.only(left: 20,right: 20,top: 20,bottom: 20),
//       decoration: BoxDecoration(
//         color:Colors.white,
//         borderRadius: BorderRadius.circular(50),
//         boxShadow: [
//           BoxShadow(color:AppColors.primary.withOpacity(0.3),
//           blurRadius: 20,
//           offset: Offset.zero),
          
//         ]
//       ),
//       child:Form(
//         key: _formKey,
//         child: DefaultTextStyle.merge(
//           style: descTextStyle,
//           child: Column(
            
//             children: [
             
//               const Patientinfo(),
//               const SizedBox(
//                 height: 10,
//               ),
             
//               Padding(
//                 padding: const EdgeInsets.all(8),
//                 child: ElevatedButton(
//                   onPressed: () {
//                     _createPrescription(context);
//                   },
//                   child: const Text('Add Medicine'),
//                 ),
//               ),
              
//             ],
//           ),
//         )))));
//   }
//   Future<void> _createPrescription(BuildContext context)async
//   {
//       final prescDataReturned = await Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) => const AddPrescription(
//                             title: "Prescription",
//                           )),
//                 ) as Prescriptiondata;
//             print("Updated freqBitField: ${prescDataReturned.freqBitField.toRadixString(2)}");
//             print("Updated isTablet: ${prescDataReturned.isTablet}");
//             print("Updated drugName: ${prescDataReturned.drugName}");
//             print("Updated isMeasuredinMg: ${prescDataReturned.isMeasuredinMg}");
//             print("Updated drugUnit: ${prescDataReturned.drugUnit}"); 

//             print("Updated isBeforeFood: ${prescDataReturned.isBeforeFood}"); 
//             print("Updated inDays: ${prescDataReturned.inDays}"); 
//             print("Updated followupduration: ${prescDataReturned.followupduration}");
//             print("Updated followupdate: ${prescDataReturned.followupdate}");
//             print("Updated remarks: ${prescDataReturned.remarks}");

//                 _prescriptiondata.isTablet=prescDataReturned.isTablet;
//                 _prescriptiondata.drugName=prescDataReturned.drugName;
//                 _prescriptiondata.isMeasuredinMg = prescDataReturned.isMeasuredinMg;
//                 _prescriptiondata.drugUnit= prescDataReturned.drugUnit;
//                 _prescriptiondata.freqBitField=prescDataReturned.freqBitField;
//                 // _prescriptiondata.morning= prescDataReturned.morning;
//                 // _prescriptiondata.afternoon=prescDataReturned.afternoon;
//                 // _prescriptiondata.evening=prescDataReturned.evening;
//                 // _prescriptiondata.night=prescDataReturned.night;
//                 _prescriptiondata.isBeforeFood=prescDataReturned.isBeforeFood;
//                 _prescriptiondata.inDays=prescDataReturned.inDays;
//                 _prescriptiondata.followupduration= prescDataReturned.followupduration;
//                 _prescriptiondata.followupdate=prescDataReturned.followupdate;
//                 _prescriptiondata.remarks=prescDataReturned.remarks;
//                   }
  
// } 
import 'package:docautomations/common/appcolors.dart';
import 'package:docautomations/datamodels/prescriptionData.dart';
import 'package:docautomations/main.dart';
import 'package:docautomations/widgets/PatientInfo.dart';
import 'package:flutter/material.dart';

class Addprescriptionscr extends StatefulWidget {
  const Addprescriptionscr({super.key});

  @override
  State<Addprescriptionscr> createState() => _AddprescriptionscrState();
}

class _AddprescriptionscrState extends State<Addprescriptionscr> {
  final _formKey = GlobalKey<FormState>();

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
                  const Patientinfo(),
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
                                    "${presc.inDays} days | ${presc.isBeforeFood ? "Before Food" : "After Food"}"),
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
        builder: (context) => const AddPrescription(title: "Prescription"),
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
        builder: (context) => AddPrescription(
          title: "Edit Prescription",
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

  void _deletePrescription(int index) {
    setState(() {
      _prescriptions.removeAt(index);
    });
    print("Deleted medicine at index $index");
  }
}
