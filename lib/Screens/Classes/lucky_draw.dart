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
  final String drawDate;
  final String imageUrl;
  final String customText;

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
    this.drawDate = '22 October 2026',
    this.imageUrl = '',
    this.customText = '',
  });

  String get displayName {
    final full = '$name $surname'.trim();
    return full.isNotEmpty ? full : (name.isNotEmpty ? name : 'Verified Winner');
  }

  String get displayCustomText {
    if (customText.trim().isNotEmpty) {
      return customText.trim();
    }
    if (allottedPlot.isNotEmpty && discountAmount.isNotEmpty) {
      return '$allottedPlot • $discountAmount';
    }
    return discountAmount.isNotEmpty ? discountAmount : allottedPlot;
  }

  String get initials {
    final n = name.trim();
    final s = surname.trim();
    if (n.isNotEmpty && s.isNotEmpty) {
      return (n[0] + s[0]).toUpperCase();
    } else if (n.isNotEmpty) {
      return n.length > 1 ? n.substring(0, 2).toUpperCase() : n[0].toUpperCase();
    }
    return 'AW';
  }

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
      drawDate: json['draw_date'] ?? json['created_at'] ?? '22 October 2026',
      imageUrl: json['image_url'] ?? json['profile_url'] ?? json['user_image'] ?? "",
      customText: json['custom_text'] ?? json['company_text'] ?? json['remarks'] ?? "",
    );
  }
}

