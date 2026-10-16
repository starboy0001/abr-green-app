class LuckyDraw {
  final String name;
  final String surname;
  final String createdAt;
  final String dob;
  final String ticketNo;
  final String customerId;
  final String allottedPlot;
  final String discountAmount;
  final String projectName;

  LuckyDraw({
    required this.name,
    required this.surname,
    required this.createdAt,
    required this.dob,
    required this.ticketNo,
    required this.customerId,
    required this.allottedPlot,
    this.discountAmount = '₹ 1,50,000 Allotment Discount',
    this.projectName = 'ABR Green Meadows Phase 1',
  });

  factory LuckyDraw.fromJson(Map<String, dynamic> json) {
    return LuckyDraw(
      name: json['name'] ?? "",
      surname: json['surname'] ?? "",
      createdAt: json['created_at'] ?? "",
      dob: json['dob'] ?? "",
      ticketNo: json['ticket_no'] ?? "",
      customerId: json['customer_id']?.toString() ?? "",
      allottedPlot: json['allotted_plot'] ?? "",
      discountAmount: json['discount_amount'] ?? json['prize'] ?? '₹ 1,50,000 Discount',
      projectName: json['project_name'] ?? 'ABR Green Meadows Phase 1',
    );
  }
}
