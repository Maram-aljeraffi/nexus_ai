class CertificateModel {
  String id;
  String name;
  String issuer;
  String date;

  CertificateModel({
    required this.id,
    required this.name,
    required this.issuer,
    required this.date,
  });

  factory CertificateModel.empty() {
    return CertificateModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '',
      issuer: '',
      date: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name ?? '',
      'issuer': issuer ?? '',
      'date': date ?? '',
    };
  }

  factory CertificateModel.fromJson(Map<String, dynamic> json) {
    return CertificateModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      issuer: json['issuer'] ?? '',
      date: json['date'] ?? '',
    );
  }
}