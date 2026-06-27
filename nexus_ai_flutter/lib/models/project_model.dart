class ProjectModel {
  String id;
  String name;
  String description;
  String link;

  ProjectModel({
    required this.id,
    required this.name,
    required this.description,
    required this.link,
  });

  factory ProjectModel.empty() {
    return ProjectModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '',
      description: '',
      link: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name ?? '',
      'description': description ?? '',
      'link': link ?? '',
    };
  }

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      link: json['link'] ?? '',
    );
  }
}