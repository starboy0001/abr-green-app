class FormType {
  final int id;
  final String name;

  FormType({required this.id, required this.name});

  factory FormType.fromJson(Map<String, dynamic> json) {
    return FormType(
      id: json['id'],
      name: json['name'],
    );
  }
}

class PlotSize {
  final int id;
  final String name;

  PlotSize({required this.id, required this.name});

  factory PlotSize.fromJson(Map<String, dynamic> json) {
    return PlotSize(
      id: json['id'],
      name: json['name'],
    );
  }
}

class AgentName {
  final int id;
  final String name;

  AgentName({required this.id, required this.name});

  factory AgentName.fromJson(Map<String, dynamic> json) {
    return AgentName(
      id: json['id'],
      name: json['name'],
    );
  }
}

class PaymentMode {
  final int id;
  final String name;

  PaymentMode({required this.id, required this.name});

  factory PaymentMode.fromJson(Map<String, dynamic> json) {
    return PaymentMode(
      id: json['id'],
      name: json['name'],
    );
  }
}

class PaymentPlan {
  final int id;
  final String name;

  PaymentPlan({required this.id, required this.name});

  factory PaymentPlan.fromJson(Map<String, dynamic> json) {
    return PaymentPlan(
      id: json['id'],
      name: json['name'],
    );
  }
}

class PlotFacing {
  final int id;
  final String name;

  PlotFacing({required this.id, required this.name});

  factory PlotFacing.fromJson(Map<String, dynamic> json) {
    return PlotFacing(
      id: json['id'],
      name: json['name'],
    );
  }
}
