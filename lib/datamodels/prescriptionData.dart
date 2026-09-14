import 'package:flutter/foundation.dart';


class Prescriptiondata extends ChangeNotifier {

  //===========================================================================
  // Medicine Information
  //===========================================================================

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


  //===========================================================================
  // Constructor
  //===========================================================================

  Prescriptiondata({
    this.isTablet = true,
    this.drugName = '',
    this.isMeasuredInMg = true,
    this.drugUnit,
    this.freqBitField = 0,
    this.isBeforeFood = false,
    this.inDays = true,
    this.followupDuration,
    DateTime? followupdate,
    this.remarks = '',
    this.medicineType,
  }) : followupdate =
            followupdate ?? DateTime.now();


  //===========================================================================
  // Update Methods
  //===========================================================================

  void updateIsTablet(bool value) {
    isTablet = value;
    notifyListeners();
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


  void updateIsBeforeFood(bool value) {
    isBeforeFood = value;
    notifyListeners();
  }


  void updateInDays(bool value) {
    inDays = value;
    notifyListeners();
  }


  void updateFollowupDuration(int? value) {
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


  //===========================================================================
  // Frequency Bit Field
  //===========================================================================

  void setToggle(
    int index,
    bool isSelected,
  ) {

    if (isSelected) {

      freqBitField |= (1 << index);

    }
    else {

      freqBitField &= ~(1 << index);

    }

    notifyListeners();
  }


  bool isToggleSelected(
    int index,
  ) {

    return
        (freqBitField & (1 << index)) != 0;
  }


  List<bool> toBooleanList(
    int length,
  ) {

    return List.generate(
      length,
      (index) => isToggleSelected(index),
    );
  }


  void fromBooleanList(
    List<bool> list,
  ) {

    freqBitField = 0;

    for (
      int i = 0;
      i < list.length;
      i++
    ) {

      if (list[i]) {

        freqBitField |= (1 << i);

      }

    }

    notifyListeners();
  }


  List<int> toBitList(
    int length,
  ) {

    return List.generate(
      length,
      (index) =>
          isToggleSelected(index)
              ? 1
              : 0,
    );
  }


  //===========================================================================
  // JSON
  //===========================================================================

  Map<String, dynamic> toJson() {

    return {

      "isTablet": isTablet,

      "drugName": drugName,

      "isMeasuredInMg":
          isMeasuredInMg,

      "drugUnit": drugUnit,

      "freqBitField":
          freqBitField,

      "isBeforeFood":
          isBeforeFood,

      "inDays":
          inDays,

      "followupDuration":
          followupDuration,

      "followupdate":
          followupdate.toIso8601String(),

      "remarks":
          remarks,

      "medicineType":
          medicineType,
    };
  }


  //===========================================================================
  // FROM JSON
  //===========================================================================

  factory Prescriptiondata.fromJson(
    Map<String, dynamic> json,
  ) {

    return Prescriptiondata(

      isTablet:
          json["isTablet"] ?? true,

      drugName:
          json["drugName"] ?? "",

      isMeasuredInMg:
          json["isMeasuredInMg"] ?? true,

      drugUnit:
          json["drugUnit"] != null
              ? (json["drugUnit"] as num)
                  .toDouble()
              : null,

      freqBitField:
          json["freqBitField"] ?? 0,

      isBeforeFood:
          json["isBeforeFood"] ?? false,

      inDays:
          json["inDays"] ?? true,

      followupDuration:
          json["followupDuration"],

      followupdate:
          json["followupdate"] != null
              ? DateTime.tryParse(
                  json["followupdate"].toString(),
                )
              : null,

      remarks:
          json["remarks"] ?? "",

      medicineType:
          json["medicineType"],
    );
  }
}

