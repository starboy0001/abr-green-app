class ReferalData {
  final int id;
  final String name;
  final String mobile;
  final String createdAt;

  ReferalData({
    required this.id,
    required this.name,
    required this.mobile,
    required this.createdAt,
  });

  factory ReferalData.fromJson(Map<String, dynamic> json) {
    return ReferalData(
      id: json['id'] ?? 0,
      name: json['name'] ?? "",
      mobile: json['mobile'] ?? "",
      createdAt: json['created_at'] ?? "",
    );
  }
}
