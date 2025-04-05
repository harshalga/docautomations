import 'package:docautomations/common/appcolors.dart';
import 'package:docautomations/datamodels/prescriptionData.dart';
import 'package:docautomations/main.dart';
import 'package:docautomations/widgets/PatientInfo.dart';
import 'package:flutter/material.dart';

class Addprescriptionscr  extends StatefulWidget {
  const Addprescriptionscr({super.key});

  @override
  State<Addprescriptionscr> createState() => _AddprescriptionscrState();
}

class _AddprescriptionscrState extends State<Addprescriptionscr> {
 
  final _formKey = GlobalKey<FormState>();

  final    _prescriptiondata =Prescriptiondata();
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
     return 
    SizedBox(height: MediaQuery.of(context).size.height,
     child:SingleChildScrollView(

      child: 
    Container(
      padding:const EdgeInsets.all(20),
      margin: const EdgeInsets.only(left: 20,right: 20,top: 20,bottom: 20),
      decoration: BoxDecoration(
        color:Colors.white,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(color:AppColors.primary.withOpacity(0.3),
          blurRadius: 20,
          offset: Offset.zero),
          
        ]
      ),
      child:Form(
        key: _formKey,
        child: DefaultTextStyle.merge(
          style: descTextStyle,
          child: Column(
            
            children: [
             
              Patientinfo(),
              const SizedBox(
                height: 10,
              ),
             
              Padding(
                padding: const EdgeInsets.all(8),
                child: ElevatedButton(
                  onPressed: () {
                    _createPrescription(context);
                  },
                  child: const Text('Add Medicine'),
                ),
              ),
              
            ],
          ),
        )))));
  }
  Future<void> _createPrescription(BuildContext context)async
  {
      final prescDataReturned = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddPrescription(
                            title: "Prescribtion",
                          )),
                ) as Prescriptiondata;

                _prescriptiondata.isTablet=prescDataReturned.isTablet;
                _prescriptiondata.drugName=prescDataReturned.drugName;
                _prescriptiondata.isMeasuredinMg = prescDataReturned.isMeasuredinMg;
                _prescriptiondata.drugUnit= prescDataReturned.drugUnit;
                _prescriptiondata.freqBitField=prescDataReturned.freqBitField;
                // _prescriptiondata.morning= prescDataReturned.morning;
                // _prescriptiondata.afternoon=prescDataReturned.afternoon;
                // _prescriptiondata.evening=prescDataReturned.evening;
                // _prescriptiondata.night=prescDataReturned.night;
                _prescriptiondata.isBeforeFood=prescDataReturned.isBeforeFood;
                _prescriptiondata.inDays=prescDataReturned.inDays;
                _prescriptiondata.followupduration= prescDataReturned.followupduration;
                _prescriptiondata.followupdate=prescDataReturned.followupdate;
                _prescriptiondata.remarks=prescDataReturned.remarks;
                  }
  
}
