class Country {
  final String id;

  final String countryCode;

  final String countryName;

  const Country({
    required this.id,
    required this.countryCode,
    required this.countryName,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json["_id"]?.toString() ?? "",
      countryCode: json["countryCode"] ?? "",
      countryName: json["countryName"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "countryCode": countryCode,
      "countryName": countryName,
    };
  }

  @override
  String toString() => countryName;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Country &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}