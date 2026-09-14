class PatientDoctor {
  final String id;

  final String patientId;
  final String doctorId;

  final DateTime? firstVisitDate;
  final DateTime? lastVisitDate;

  final bool isActive;

  const PatientDoctor({
    required this.id,
    required this.patientId,
    required this.doctorId,
    this.firstVisitDate,
    this.lastVisitDate,
    required this.isActive,
  });

  //-------------------------------------------------------------------------
  // FROM JSON
  //-------------------------------------------------------------------------

  factory PatientDoctor.fromJson(
    Map<String, dynamic> json,
  ) {
    return PatientDoctor(
      id: json["_id"]?.toString() ?? "",

      patientId:
          json["patientId"]?.toString() ?? "",

      doctorId:
          json["doctorId"]?.toString() ?? "",

      firstVisitDate:
          json["firstVisitDate"] != null
              ? DateTime.tryParse(
                  json["firstVisitDate"].toString(),
                )
              : null,

      lastVisitDate:
          json["lastVisitDate"] != null
              ? DateTime.tryParse(
                  json["lastVisitDate"].toString(),
                )
              : null,

      isActive:
          json["isActive"] ?? true,
    );
  }

  //-------------------------------------------------------------------------
  // TO JSON
  //-------------------------------------------------------------------------

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "patientId": patientId,
      "doctorId": doctorId,
      "firstVisitDate":
          firstVisitDate?.toIso8601String(),
      "lastVisitDate":
          lastVisitDate?.toIso8601String(),
      "isActive": isActive,
    };
  }
}

