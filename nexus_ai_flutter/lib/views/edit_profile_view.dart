import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nexus_ai/providers/profile_provider.dart';
import 'package:nexus_ai/views/add_image_view.dart';

// فئة مساعدة لتخزين الروابط المؤقتة
class SocialLinkCopy {
  String platform;
  String url;

  SocialLinkCopy({
    required this.platform,
    required this.url,
  });
}

// فئة لتخزين المهارات المؤقتة
class SkillCopy {
  String name;
  SkillCopy({required this.name});
}

// فئة لتخزين اللغات المؤقتة
class LanguageCopy {
  String name;
  String level; // 'excellent', 'good', 'average'
  LanguageCopy({required this.name, required this.level});
}

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _usernameController; // ✅ جديد
  late List<SocialLinkCopy> _tempLinks;
  late List<SkillCopy> _tempSkills;
  late List<LanguageCopy> _tempLanguages;

  final List<Map<String, dynamic>> _availablePlatforms = [
    {'name': 'WhatsApp', 'icon': Icons.chat, 'color': const Color(0xFF25D366)},
    {'name': 'Twitter', 'icon': Icons.chat, 'color': const Color(0xFF1DA1F2)},
    {'name': 'YouTube', 'icon': Icons.videocam, 'color': const Color(0xFFFF0000)},
    {'name': 'Instagram', 'icon': Icons.camera_alt, 'color': const Color(0xFFE4405F)},
    {'name': 'Facebook', 'icon': Icons.facebook, 'color': const Color(0xFF1877F2)},
    {'name': 'Telegram', 'icon': Icons.send, 'color': const Color(0xFF26A5E4)},
    {'name': 'TikTok', 'icon': Icons.music_note, 'color': const Color(0xFF000000)},
    {'name': 'Snapchat', 'icon': Icons.camera, 'color': const Color(0xFFFFFC00)},
    {'name': 'LinkedIn', 'icon': Icons.business, 'color': const Color(0xFF0077B5)},
    {'name': 'GitHub', 'icon': Icons.code, 'color': const Color(0xFF181717)},
    {'name': 'Tribe', 'icon': Icons.people, 'color': const Color(0xFF4F46E5)},
  ];

  String? _selectedPlatform;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<ProfileProvider>(context, listen: false).user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
    _usernameController = TextEditingController(text: user?.username ?? ''); // ✅ جديد

    _tempLinks = (user?.socialLinks ?? []).map((link) {
      return SocialLinkCopy(
        platform: link.platform,
        url: link.url,
      );
    }).toList();

    _tempSkills = (user?.skills ?? []).map((skill) {
      return SkillCopy(name: skill);
    }).toList();

    _tempLanguages = (user?.languages ?? []).map((lang) {
      return LanguageCopy(name: lang.name, level: lang.level);
    }).toList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _usernameController.dispose(); // ✅ جديد
    super.dispose();
  }

  // ========== دوال الروابط ==========
  void _addPlatformLink() {
    if (_selectedPlatform != null && _selectedPlatform!.isNotEmpty) {
      setState(() {
        _tempLinks.add(SocialLinkCopy(platform: _selectedPlatform!, url: ''));
        _selectedPlatform = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إضافة $_selectedPlatform، قم بلصق الرابط'),
          duration: const Duration(seconds: 1),
          backgroundColor: const Color(0xFF4F46E5),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار منصة أولاً'), backgroundColor: Colors.orange),
      );
    }
  }

  void _removeLink(int index) {
    setState(() {
      _tempLinks.removeAt(index);
    });
  }

  void _updateUrl(int index, String url) {
    setState(() {
      _tempLinks[index].url = url;
    });
  }

  // ========== دوال المهارات ==========
  void _addNewSkill() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('إضافة مهارة'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'مثال: Flutter, Laravel, UI/UX Design',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() {
                    _tempSkills.add(SkillCopy(name: controller.text.trim()));
                  });
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5)),
              child: const Text('إضافة'),
            ),
          ],
        );
      },
    );
  }

  void _removeSkill(int index) {
    setState(() {
      _tempSkills.removeAt(index);
    });
  }

  // ========== دوال اللغات ==========
  void _addNewLanguage() {
    String selectedLanguage = 'العربية';
    String selectedLevel = 'excellent';

    final List<String> languagesList = [
      'العربية', 'الإنجليزية', 'الفرنسية', 'الألمانية',
      'الإسبانية', 'الصينية', 'التركية', 'الفارسية', 'الأردية'
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('إضافة لغة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedLanguage,
                decoration: InputDecoration(
                  labelText: 'اختر اللغة',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
                items: languagesList.map((lang) {
                  return DropdownMenuItem(value: lang, child: Text(lang));
                }).toList(),
                onChanged: (value) => setState(() => selectedLanguage = value!),
              ),
              const SizedBox(height: 20),
              const Text('المستوى:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildLevelRadio(
                      value: 'excellent',
                      groupValue: selectedLevel,
                      label: 'ممتاز',
                      color: Colors.green,
                      onChanged: (v) => setState(() => selectedLevel = v!),
                    ),
                  ),
                  Expanded(
                    child: _buildLevelRadio(
                      value: 'good',
                      groupValue: selectedLevel,
                      label: 'جيد',
                      color: Colors.blue,
                      onChanged: (v) => setState(() => selectedLevel = v!),
                    ),
                  ),
                  Expanded(
                    child: _buildLevelRadio(
                      value: 'average',
                      groupValue: selectedLevel,
                      label: 'متوسط',
                      color: Colors.orange,
                      onChanged: (v) => setState(() => selectedLevel = v!),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _tempLanguages.add(LanguageCopy(name: selectedLanguage, level: selectedLevel));
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5)),
              child: const Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelRadio({
    required String value,
    required String groupValue,
    required String label,
    required Color color,
    required Function(String?) onChanged,
  }) {
    return Row(
      children: [
        Radio<String>(
          value: value,
          groupValue: groupValue,
          onChanged: onChanged,
          activeColor: color,
        ),
        Text(label, style: TextStyle(color: color)),
      ],
    );
  }

  void _removeLanguage(int index) {
    setState(() {
      _tempLanguages.removeAt(index);
    });
  }

  void _updateLanguageLevel(int index, String level) {
    setState(() {
      _tempLanguages[index].level = level;
    });
  }

  Future<void> _changeProfileImage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddImageView(type: 'profile')),
    );
    if (result != null) {
      final provider = Provider.of<ProfileProvider>(context, listen: false);
      await provider.updateProfileImage(result);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث الصورة الشخصية بنجاح'), backgroundColor: Colors.green),
      );
    }
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);

    final provider = Provider.of<ProfileProvider>(context, listen: false);

    // تحديث الاسم والوصف واسم المستخدم
    await provider.updateProfile(
      name: _nameController.text.trim(),
      bio: _bioController.text.trim(),
    );
    await provider.updateUsername(_usernameController.text.trim()); // ✅ جديد

    // حفظ الروابط
    final currentLinksCount = provider.user?.socialLinks.length ?? 0;
    for (int i = currentLinksCount - 1; i >= 0; i--) {
      await provider.removeSocialLink(i);
    }
    for (var link in _tempLinks) {
      if (link.platform.trim().isNotEmpty && link.url.trim().isNotEmpty) {
        await provider.addSocialLink(link.platform.trim(), link.url.trim());
      }
    }

    // حفظ المهارات
    final currentSkillsCount = provider.user?.skills.length ?? 0;
    for (int i = currentSkillsCount - 1; i >= 0; i--) {
      await provider.removeSkill(i);
    }
    for (var skill in _tempSkills) {
      if (skill.name.trim().isNotEmpty) {
        await provider.addSkill(skill.name.trim());
      }
    }

    // حفظ اللغات
    final currentLanguagesCount = provider.user?.languages.length ?? 0;
    for (int i = currentLanguagesCount - 1; i >= 0; i--) {
      await provider.removeLanguage(i);
    }
    for (var lang in _tempLanguages) {
      if (lang.name.trim().isNotEmpty) {
        await provider.addLanguage(lang.name.trim(), lang.level);
      }
    }

    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حفظ التغييرات بنجاح'), backgroundColor: Colors.green),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<ProfileProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'تعديل الملف الشخصي',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0F172A), Color(0xFF1E1B4B), Color(0xFF312E81)],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8FAFC), Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ========== قسم الصورة الشخصية ==========
              Center(
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 55,
                        backgroundColor: const Color(0xFF4F46E5),
                        backgroundImage: (user?.profileImageUrl?.isNotEmpty ?? false) &&
                            File(user!.profileImageUrl!).existsSync()
                            ? FileImage(File(user.profileImageUrl!))
                            : null,
                        child: (user?.profileImageUrl?.isEmpty ?? true)
                            ? const Icon(Icons.person, size: 55, color: Colors.white)
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _changeProfileImage,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFF4F46E5),
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(6),
                          child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ========== قسم المعلومات الأساسية ==========
              _buildSectionTitle('المعلومات الأساسية', Icons.person_outline),
              const SizedBox(height: 16),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _nameController,
                        label: 'الاسم',
                        icon: Icons.badge_outlined,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _bioController,
                        label: 'الوصف',
                        icon: Icons.description_outlined,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      // ✅ حقل اسم المستخدم للرابط العام
                      _buildTextField(
                        controller: _usernameController,
                        label: 'اسم المستخدم (للرابط العام)',
                        icon: Icons.link,
                        hintText: 'maram',
                      ),
                      if (_usernameController.text.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'رابط ملفك: nexus.ai/${_usernameController.text}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: const Color(0xFF4F46E5),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ========== قسم الروابط ==========
              Row(
                children: [
                  _buildSectionTitle('روابط التواصل', Icons.link),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 16),

              // بطاقة إضافة رابط جديد
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedPlatform,
                      hint: Text(
                        'اختر منصة التواصل',
                        style: GoogleFonts.poppins(color: Colors.grey[500]),
                      ),
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF4F46E5)),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      items: _availablePlatforms.map((platform) {
                        return DropdownMenuItem<String>(
                          value: platform['name'],
                          child: Row(
                            children: [
                              Icon(platform['icon'], size: 20, color: platform['color']),
                              const SizedBox(width: 12),
                              Text(
                                platform['name'],
                                style: GoogleFonts.poppins(),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedPlatform = value),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _addPlatformLink,
                        icon: const Icon(Icons.add, size: 18),
                        label: Text(
                          'إضافة رابط',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F46E5),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // قائمة الروابط المضافة
              if (_tempLinks.isNotEmpty) ...[
                Text(
                  'الروابط المضافة (${_tempLinks.length})',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              ..._tempLinks.asMap().entries.map((entry) => _buildLinkCard(entry.key, entry.value)).toList(),
              if (_tempLinks.isEmpty)
                _buildEmptySection(Icons.link_off, 'لا توجد روابط مضافة', 'اختر منصة وأضف رابطاً'),

              const SizedBox(height: 24),

              // ========== قسم المهارات ==========
              Row(
                children: [
                  _buildSectionTitle('المهارات', Icons.code),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _addNewSkill,
                    icon: const Icon(Icons.add, size: 18, color: Color(0xFF4F46E5)),
                    label: Text('إضافة مهارة', style: GoogleFonts.poppins(color: const Color(0xFF4F46E5))),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_tempSkills.isNotEmpty) ...[
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _tempSkills.asMap().entries.map((entry) {
                    final index = entry.key;
                    final skill = entry.value;
                    return Chip(
                      label: Text(skill.name, style: GoogleFonts.poppins()),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () => _removeSkill(index),
                      backgroundColor: const Color(0xFF4F46E5).withOpacity(0.1),
                      side: BorderSide.none,
                    );
                  }).toList(),
                ),
              ] else
                _buildEmptySection(Icons.code_off, 'لا توجد مهارات مضافة', 'أضف المهارات التي تتقنها'),

              const SizedBox(height: 24),

              // ========== قسم اللغات ==========
              Row(
                children: [
                  _buildSectionTitle('اللغات', Icons.language),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _addNewLanguage,
                    icon: const Icon(Icons.add, size: 18, color: Color(0xFF4F46E5)),
                    label: Text('إضافة لغة', style: GoogleFonts.poppins(color: const Color(0xFF4F46E5))),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_tempLanguages.isNotEmpty) ...[
                ..._tempLanguages.asMap().entries.map((entry) => _buildLanguageCard(entry.key, entry.value)).toList(),
              ] else
                _buildEmptySection(Icons.language_outlined, 'لا توجد لغات مضافة', 'أضف اللغات التي تتحدثها'),

              const SizedBox(height: 32),

              // زر الحفظ الرئيسي
              ElevatedButton(
                onPressed: _isSaving ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 2,
                ),
                child: _isSaving
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
                    : Text(
                  'حفظ التغييرات',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hintText,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        labelStyle: GoogleFonts.poppins(),
        prefixIcon: Icon(icon, color: const Color(0xFF4F46E5), size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      style: GoogleFonts.poppins(),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF4F46E5).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF4F46E5), size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildLinkCard(int index, SocialLinkCopy link) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getPlatformColor(link.platform).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getPlatformIcon(link.platform),
                  size: 24,
                  color: _getPlatformColor(link.platform),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      link.platform.isEmpty ? 'منصة غير محددة' : link.platform,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              link.url.isEmpty ? 'اضغط زر اللصق لإضافة الرابط' : link.url,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: link.url.isEmpty ? Colors.grey[400] : Colors.grey[700],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () async {
                              final ClipboardData? data = await Clipboard.getData('text/plain');
                              if (data?.text != null && data!.text!.isNotEmpty) {
                                _updateUrl(index, data.text!);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('✅ تم لصق الرابط بنجاح'),
                                    backgroundColor: Colors.green,
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4F46E5).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.content_paste,
                                size: 18,
                                color: Color(0xFF4F46E5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
                onPressed: () => _removeLink(index),
                tooltip: 'حذف الرابط',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageCard(int index, LanguageCopy language) {
    String levelText = '';
    Color levelColor;

    switch (language.level) {
      case 'excellent':
        levelText = 'ممتاز';
        levelColor = Colors.green;
        break;
      case 'good':
        levelText = 'جيد';
        levelColor = Colors.blue;
        break;
      case 'average':
        levelText = 'متوسط';
        levelColor = Colors.orange;
        break;
      default:
        levelText = 'غير محدد';
        levelColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: levelColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.language, size: 24, color: levelColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language.name,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildLevelRadioInline(
                        value: 'excellent',
                        groupValue: language.level,
                        label: 'ممتاز',
                        color: Colors.green,
                        onChanged: (v) => _updateLanguageLevel(index, v!),
                      ),
                      const SizedBox(width: 8),
                      _buildLevelRadioInline(
                        value: 'good',
                        groupValue: language.level,
                        label: 'جيد',
                        color: Colors.blue,
                        onChanged: (v) => _updateLanguageLevel(index, v!),
                      ),
                      const SizedBox(width: 8),
                      _buildLevelRadioInline(
                        value: 'average',
                        groupValue: language.level,
                        label: 'متوسط',
                        color: Colors.orange,
                        onChanged: (v) => _updateLanguageLevel(index, v!),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
              onPressed: () => _removeLanguage(index),
              tooltip: 'حذف اللغة',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelRadioInline({
    required String value,
    required String groupValue,
    required String label,
    required Color color,
    required Function(String?) onChanged,
  }) {
    return Row(
      children: [
        Radio<String>(
          value: value,
          groupValue: groupValue,
          onChanged: onChanged,
          activeColor: color,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
        Text(label, style: TextStyle(color: color, fontSize: 12)),
      ],
    );
  }

  Widget _buildEmptySection(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.poppins(color: Colors.grey[500]),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'whatsapp': return Icons.chat;
      case 'github': return Icons.code;
      case 'linkedin': return Icons.business;
      case 'twitter': return Icons.chat;
      case 'youtube': return Icons.videocam;
      case 'instagram': return Icons.camera_alt;
      case 'facebook': return Icons.facebook;
      case 'telegram': return Icons.send;
      case 'tiktok': return Icons.music_note;
      case 'tribe': return Icons.people;
      default: return Icons.link;
    }
  }

  Color _getPlatformColor(String platform) {
    switch (platform.toLowerCase()) {
      case 'whatsapp': return const Color(0xFF25D366);
      case 'github': return const Color(0xFF181717);
      case 'linkedin': return const Color(0xFF0077B5);
      case 'twitter': return const Color(0xFF1DA1F2);
      case 'youtube': return const Color(0xFFFF0000);
      case 'instagram': return const Color(0xFFE4405F);
      case 'facebook': return const Color(0xFF1877F2);
      case 'telegram': return const Color(0xFF26A5E4);
      case 'tiktok': return const Color(0xFF000000);
      case 'tribe': return const Color(0xFF4F46E5);
      default: return const Color(0xFF4F46E5);
    }
  }
}