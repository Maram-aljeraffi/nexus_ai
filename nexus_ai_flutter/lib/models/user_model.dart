import 'project_model.dart';
import 'certificate_model.dart';

class SocialLink {
  String platform;
  String url;

  SocialLink({
    required this.platform,
    required this.url,
  });

  Map<String, dynamic> toJson() {
    return {
      'platform': platform,
      'url': url,
    };
  }

  factory SocialLink.fromJson(Map<String, dynamic> json) {
    return SocialLink(
      platform: json['platform'] ?? '',
      url: json['url'] ?? '',
    );
  }
}

// ✅ فئة اللغة
class Language {
  String name;
  String level; // 'excellent', 'good', 'average'

  Language({
    required this.name,
    required this.level,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'level': level,
    };
  }

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      name: json['name'] ?? '',
      level: json['level'] ?? 'average',
    );
  }
}

class UserModel {
  String id;
  String username;  // ✅ جديد: اسم المستخدم للرابط العام
  String name;
  String bio;
  String profileImageUrl;
  String coverImageUrl;
  List<SocialLink> socialLinks;
  List<ProjectModel> projects;
  List<CertificateModel> certificates;
  List<String> skills;        // مهارات المستخدم
  List<Language> languages;   // لغات المستخدم

  UserModel({
    required this.id,
    required this.username,
    required this.name,
    required this.bio,
    required this.profileImageUrl,
    required this.coverImageUrl,
    required this.socialLinks,
    required this.projects,
    required this.certificates,
    required this.skills,
    required this.languages,
  });

  // ✅ رابط الملف الشخصي العام
  String get publicProfileUrl => 'https://nexus.ai/${username.isNotEmpty ? username : id}';

  // ✅ مستخدم جديد: كل شيء فاضي
  factory UserModel.empty() {
    return UserModel(
      id: '',
      username: '',
      name: '',
      bio: '',
      profileImageUrl: '',
      coverImageUrl: '',
      socialLinks: [],
      projects: [],
      certificates: [],
      skills: [],
      languages: [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'bio': bio,
      'profileImageUrl': profileImageUrl,
      'coverImageUrl': coverImageUrl,
      'socialLinks': socialLinks.map((l) => l.toJson()).toList(),
      'projects': projects.map((p) => p.toJson()).toList(),
      'certificates': certificates.map((c) => c.toJson()).toList(),
      'skills': skills,
      'languages': languages.map((l) => l.toJson()).toList(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      name: json['name'] ?? '',
      bio: json['bio'] ?? '',
      profileImageUrl: json['profileImageUrl'] ?? '',
      coverImageUrl: json['coverImageUrl'] ?? '',
      socialLinks: (json['socialLinks'] as List?)
          ?.map((l) => SocialLink.fromJson(l))
          .toList() ?? [],
      projects: (json['projects'] as List?)
          ?.map((p) => ProjectModel.fromJson(p))
          .toList() ?? [],
      certificates: (json['certificates'] as List?)
          ?.map((c) => CertificateModel.fromJson(c))
          .toList() ?? [],
      skills: (json['skills'] as List?)?.map((s) => s.toString()).toList() ?? [],
      languages: (json['languages'] as List?)
          ?.map((l) => Language.fromJson(l))
          .toList() ?? [],
    );
  }
}