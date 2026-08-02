import 'package:docautomations/datamodels/master/country.dart';
import 'package:docautomations/datamodels/response/doctor_profile.dart';

class MasterData {
  final DoctorProfile doctorProfile;

  final List<Country> countries;

  const MasterData({
    required this.doctorProfile,
    required this.countries,
  });

  MasterData copyWith({
    DoctorProfile? doctorProfile,
    List<Country>? countries,
  }) {
    return MasterData(
      doctorProfile: doctorProfile ?? this.doctorProfile,
      countries: countries ?? this.countries,
    );
  }
}