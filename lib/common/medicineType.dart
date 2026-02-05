/* Helper model */
import 'package:flutter/material.dart';

class MedicineType {
  final String name;
  //final IconData icon;
  final Widget icon;   // 👈 change here
  final String unit;

  MedicineType(this.name, this.icon, this.unit);
}
