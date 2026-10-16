class MobilePayment {
  final int id;
  final String paymentTitle;
  final String paymentImage;
  final String paymentMessage;
  final String createdAt;
  final String updatedAt;

  MobilePayment(
      {required this.id,
      required this.paymentTitle,
      required this.paymentImage,
      required this.paymentMessage,
      required this.createdAt,
      required this.updatedAt});

  factory MobilePayment.fromJson(Map<String, dynamic> json) {
    return MobilePayment(
      id: json['id'] ?? 0,
      paymentTitle: json['payment_title'] ?? "",
      paymentImage: json['payment_image'] ?? "",
      paymentMessage: json['payment_message'] ?? "",
      createdAt: json['created_at'] ?? "",
      updatedAt: json['updated_at'] ?? "",
    );
  }
}
