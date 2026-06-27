import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nexus_ai/models/user_model.dart';
import 'package:nexus_ai/models/project_model.dart';
import 'package:nexus_ai/models/certificate_model.dart';

class ProfileProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserModel? _user;
  UserModel? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ProfileProvider() {
    _loadUser();
  }

  // تحميل بيانات المستخدم من Firebase
  Future<void> _loadUser() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        _user = UserModel.fromJson(doc.data()!);
      } else {
        _user = UserModel.empty();
        await _saveUser();
      }
    } catch (e) {
      print("خطأ في تحميل المستخدم: $e");
      _user = UserModel.empty();
    }

    _isLoading = false;
    notifyListeners();
  }

  // حفظ بيانات المستخدم في Firebase
  Future<void> _saveUser() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null || _user == null) return;

    await _firestore.collection('users').doc(userId).set(_user!.toJson());
  }

  // ✅ جلب ملف مستخدم عام باستخدام username
  Future<UserModel?> getPublicProfile(String username) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return UserModel.fromJson(querySnapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      print("خطأ في جلب الملف العام: $e");
      return null;
    }
  }

  // تحديث الملف الشخصي (الاسم والوصف)
  Future<void> updateProfile({
    required String name,
    required String bio,
  }) async {
    if (_user == null) return;

    _user!.name = name.trim();
    _user!.bio = bio.trim();
    await _saveUser();
    notifyListeners();
  }

  // ✅ تحديث اسم المستخدم (للرابط العام)
  Future<void> updateUsername(String username) async {
    if (_user == null) return;

    _user!.username = username.trim();
    await _saveUser();
    notifyListeners();
  }

  // تحديث الصورة الشخصية
  Future<void> updateProfileImage(String url) async {
    if (_user == null) return;

    _user!.profileImageUrl = url ?? '';
    await _saveUser();
    notifyListeners();
  }

  // تحديث صورة الخلفية
  Future<void> updateCoverImage(String url) async {
    if (_user == null) return;

    _user!.coverImageUrl = url ?? '';
    await _saveUser();
    notifyListeners();
  }

  // ========== الروابط ==========
  Future<void> addSocialLink(String platform, String url) async {
    if (_user == null) return;

    final platformTrimmed = platform.trim();
    final urlTrimmed = url.trim();

    if (platformTrimmed.isEmpty || urlTrimmed.isEmpty) {
      return;
    }

    _user!.socialLinks.add(SocialLink(
      platform: platformTrimmed,
      url: urlTrimmed,
    ));
    await _saveUser();
    notifyListeners();
  }

  Future<void> removeSocialLink(int index) async {
    if (_user == null) return;
    if (index >= 0 && index < _user!.socialLinks.length) {
      _user!.socialLinks.removeAt(index);
      await _saveUser();
      notifyListeners();
    }
  }

  // ========== المشاريع ==========
  Future<void> addProject(ProjectModel project) async {
    if (_user == null) return;
    if (project.name.trim().isNotEmpty) {
      _user!.projects.add(project);
      await _saveUser();
      notifyListeners();
    }
  }

  Future<void> deleteProject(int index) async {
    if (_user == null) return;
    if (index >= 0 && index < _user!.projects.length) {
      _user!.projects.removeAt(index);
      await _saveUser();
      notifyListeners();
    }
  }

  // ========== الشهادات ==========
  Future<void> addCertificate(CertificateModel certificate) async {
    if (_user == null) return;
    if (certificate.name.trim().isNotEmpty) {
      _user!.certificates.add(certificate);
      await _saveUser();
      notifyListeners();
    }
  }

  Future<void> deleteCertificate(int index) async {
    if (_user == null) return;
    if (index >= 0 && index < _user!.certificates.length) {
      _user!.certificates.removeAt(index);
      await _saveUser();
      notifyListeners();
    }
  }

  // ========== المهارات ==========
  Future<void> addSkill(String skill) async {
    if (_user == null) return;
    if (skill.trim().isNotEmpty) {
      _user!.skills.add(skill.trim());
      await _saveUser();
      notifyListeners();
    }
  }

  Future<void> removeSkill(int index) async {
    if (_user == null) return;
    if (index >= 0 && index < _user!.skills.length) {
      _user!.skills.removeAt(index);
      await _saveUser();
      notifyListeners();
    }
  }

  // ========== اللغات ==========
  Future<void> addLanguage(String name, String level) async {
    if (_user == null) return;
    if (name.trim().isNotEmpty) {
      _user!.languages.add(Language(name: name.trim(), level: level));
      await _saveUser();
      notifyListeners();
    }
  }

  Future<void> removeLanguage(int index) async {
    if (_user == null) return;
    if (index >= 0 && index < _user!.languages.length) {
      _user!.languages.removeAt(index);
      await _saveUser();
      notifyListeners();
    }
  }

  Future<void> updateLanguageLevel(int index, String level) async {
    if (_user == null) return;
    if (index >= 0 && index < _user!.languages.length) {
      _user!.languages[index].level = level;
      await _saveUser();
      notifyListeners();
    }
  }

  // ========== استخراج المهارات ==========
  List<String> getSkills() {
    if (_user == null) return [];

    final skills = <String>[];
    // من المشاريع
    for (var project in _user!.projects) {
      if (project.name.isNotEmpty) skills.add(project.name);
    }
    // من الشهادات
    for (var cert in _user!.certificates) {
      if (cert.name.isNotEmpty) skills.add(cert.name);
    }
    // من المهارات المضافة يدوياً
    for (var skill in _user!.skills) {
      if (skill.isNotEmpty) skills.add(skill);
    }
    return skills;
  }
}