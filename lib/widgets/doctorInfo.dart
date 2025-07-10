import 'dart:convert';
import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
class DoctorInfo {
  final String name;
  final String specialization;
  final String clinicName;
  final String clinicAddress;
  //final String contactDetails;
  final String contact;
  //final String? logoPath;       // For mobile/desktop
  final String? logoBase64;     // For web

  DoctorInfo({
    required this.name,
    required this.specialization,
    required this.clinicName,
    required this.clinicAddress,
    required this.contact,
    //this.logoPath,
    this.logoBase64,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'specialization': specialization,
        'clinicName': clinicName,
        'clinicAddress': clinicAddress,
        'contact': contact,
        //'logoPath': logoPath,
        'logoBase64': logoBase64,
      };

  static DoctorInfo fromJson(Map<String, dynamic> json) => DoctorInfo(
        name: json['name'],
        specialization: json['specialization'],
        clinicName: json['clinicName'],
        clinicAddress: json['clinicAddress'],
        contact: json['contact'],
        //logoPath: json['logoPath'],
        logoBase64: json['logoBase64'],
      );
}
