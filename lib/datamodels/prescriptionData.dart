import 'package:flutter/foundation.dart';

class Prescriptiondata extends ChangeNotifier {

  bool isTablet;
  String drugName;
  bool isMeasuredInMg;
  double? drugUnit;
  int freqBitField;
  bool isBeforeFood;
  bool inDays;
  int? followupDuration;
  DateTime followupdate;
  String remarks;
  String? medicineType;

  Prescriptiondata({
    this.isTablet = true,
    this.drugName = '',
    this.isMeasuredInMg = true,
    this.drugUnit ,
    this.freqBitField = 0,
    this.isBeforeFood = false,
    this.inDays = true,
    this.followupDuration ,
    DateTime? followupdate,
    this.remarks = '',
    this.medicineType ,
  }) : followupdate = followupdate ?? DateTime.now();
//  late bool isTablet ;
//  late String drugName;
//  late bool isMeasuredInMg;
//  late int drugUnit;
//  late int freqBitField;
// // late BitField morning;
// // late BitField afternoon;
// // late BitField evening;
// // late BitField night;
//  late bool isBeforeFood;
//  late bool inDays;
//  late int  followupDuration;//followupduration;
//  late DateTime followupdate;
//  late String remarks;



// Prescriptiondata({this.freqBitField =0}); // Default: no toggles selected

void updateIsTablet(bool isTabletVal)
{
  isTablet = isTabletVal;
  notifyListeners(); // Notify listeners to rebuild
}
void updateDrugName(String value) {
    drugName = value;
    notifyListeners();
  }

  void updateIsMeasuredInMg(bool value) {
    
    isMeasuredInMg = value;
    notifyListeners();
  }

  void updateDrugUnit(double value) {
    drugUnit = value;
    notifyListeners();
  }

  void updateMedicineType(String value) {
    medicineType = value;
    notifyListeners();
  }

  // void updateMorning(BitField value) {
  //   morning = value;
  //   notifyListeners();
  // }

  // void updateAfternoon(BitField value) {
  //   afternoon = value;
  //   notifyListeners();
  // }

  // void updateEvening(BitField value) {
  //   evening = value;
  //   notifyListeners();
  // }

  // void updateNight(BitField value) {
  //   night = value;
  //   notifyListeners();
  // }

  void updateIsBeforeFood(bool value) {
    isBeforeFood = value;
    notifyListeners();
  }

  void updateInDays(bool value) {
    inDays = value;
    notifyListeners();
  }

  void updateFollowupDuration(int value) {
    followupDuration = value;
    notifyListeners();
  }

  void updateFollowupDate(DateTime value) {
    followupdate = value;
    notifyListeners();
  }

  void updateRemarks(String value) {
    remarks = value;
    notifyListeners();
  }

  // Set a specific toggle button
  void setToggle(int index, bool isSelected) {
    if (isSelected) {
      freqBitField |= (1 << index); // Set the bit
    } else {
      freqBitField &= ~(1 << index); // Clear the bit
    }

  }

    // Get the state of a specific toggle button
  bool isToggleSelected(int index) {
    return (freqBitField & (1 << index)) != 0;
  }
// Convert bit field to a boolean list
  List<bool> toBooleanList(int length) {
    return List.generate(length, (index) => isToggleSelected(index));
  }

  // Convert boolean list to bit field
  void fromBooleanList(List<bool> list) {
    freqBitField = 0; // Reset bitField
    for (int i = 0; i < list.length; i++) {
      if (list[i]) setToggle(i, true);
    }
  }

  // Convert bit field to a list of 0 and 1
List<int> toBitList(int length) {
  return List.generate(length, (index) => isToggleSelected(index) ? 1 : 0);
}

  // Convert bit field to JSON
  Map<String, dynamic> toJson() {
    return {"freqBitField": freqBitField};
  }

  // Convert JSON back to object
  factory Prescriptiondata.fromJson(Map<String, dynamic> json) {
    return Prescriptiondata(freqBitField: json["freqBitField"] ?? 0);
  }


}


