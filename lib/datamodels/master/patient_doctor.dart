class PatientDoctor {
  final String id;

  final String patientId;

  final String doctorId;

  final DateTime? firstVisitDate;

  final DateTime? lastVisitDate;

  final int visitCount;

  const PatientDoctor({
    required this.id,
    required this.patientId,
    required this.doctorId,
    this.firstVisitDate,
    this.lastVisitDate,
    required this.visitCount,
  });

  factory PatientDoctor.fromJson(
      Map<String, dynamic> json) {
    return PatientDoctor(
      id: json["_id"] ?? "",

      patientId: json["patientId"] ?? "",

      doctorId: json["doctorId"] ?? "",

      firstVisitDate:
          json["firstVisitDate"] != null
              ? DateTime.parse(
                  json["firstVisitDate"])
              : null,

      lastVisitDate:
          json["lastVisitDate"] != null
              ? DateTime.parse(
                  json["lastVisitDate"])
              : null,

      visitCount:
          json["visitCount"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "patientId": patientId,
      "doctorId": doctorId,
      "firstVisitDate":
          firstVisitDate?.toIso8601String(),
      "lastVisitDate":
          lastVisitDate?.toIso8601String(),
      "visitCount": visitCount,
    };
  }
}