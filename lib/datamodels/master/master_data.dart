import 'package:docautomations/datamodels/master/country.dart';
import 'package:docautomations/datamodels/master/prescription_layout.dart';
import 'package:docautomations/datamodels/response/doctor_profile.dart';

class MasterData {
  final DoctorProfile doctorProfile;

  final List<Country> countries;

  final PrescriptionLayout prescriptionLayout;

  const MasterData({
    required this.doctorProfile,
    required this.countries,
    required this.prescriptionLayout,
  });

  MasterData copyWith({
    DoctorProfile? doctorProfile,
    List<Country>? countries,
    PrescriptionLayout? prescriptionLayout,
  }) {
    return MasterData(
      doctorProfile:
          doctorProfile ?? this.doctorProfile,

      countries:
          countries ?? this.countries,

      prescriptionLayout:
          prescriptionLayout ?? this.prescriptionLayout,
    );
  }
}