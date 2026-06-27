import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nexus_ai/providers/profile_provider.dart';
import 'package:nexus_ai/views/add_certificate_view.dart';
import 'package:nexus_ai/views/add_project_view.dart';
import 'package:nexus_ai/views/edit_profile_view.dart';
import 'package:nexus_ai/views/job_matches_view.dart';
import 'package:nexus_ai/views/resume_view.dart';
import 'package:nexus_ai/views/PublicProfileView.dart';
import 'package:nexus_ai/views/interview_view.dart';
import 'package:nexus_ai/views/career_score_view.dart';
import 'package:nexus_ai/services/groq_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nexus_ai/models/user_model.dart';
import 'package:flutter/services.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const RadialGradient(
                  colors: [Color(0xFF38BDF8), Color(0xFF6366F1)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF38BDF8).withOpacity(0.5),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.auto_awesome, size: 16, color: Colors.white),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'ملفي الشخصي',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ],
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
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileView()),
              );
            },
          ),
        ],
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, _) {
          final user = provider.user;

          if (provider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                  ),
                  SizedBox(height: 16),
                  Text('جاري تحميل ملفك الشخصي...'),
                ],
              ),
            );
          }

          if (user == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('حدث خطأ في تحميل البيانات'),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(provider),
                const SizedBox(height: 70),
                _buildNameAndBio(user),
                const SizedBox(height: 20),
                _buildActionButtons(context, user),
                const SizedBox(height: 20),
                _buildLinksSection(provider),
                const SizedBox(height: 20),
                _buildSkillsSection(provider),
                const SizedBox(height: 20),
                _buildProjectsSection(context, provider),
                const SizedBox(height: 20),
                _buildCertificatesSection(context, provider),
                const SizedBox(height: 20),
                _buildLanguagesSection(provider),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  // ========== الهيدر (الصورة الشخصية + الخلفية) ==========
  Widget _buildHeader(ProfileProvider provider) {
    final user = provider.user;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 180,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0F172A), Color(0xFF1E1B4B), Color(0xFF312E81)],
            ),
            image: (user?.coverImageUrl?.isNotEmpty ?? false)
                ? DecorationImage(
              image: NetworkImage(user!.coverImageUrl!),
              fit: BoxFit.cover,
            )
                : null,
          ),
        ),
        Positioned(
          top: 130,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 55,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 52,
                  backgroundImage: (user?.profileImageUrl?.isNotEmpty ?? false)
                      ? NetworkImage(user!.profileImageUrl!)
                      : null,
                  child: (user?.profileImageUrl?.isEmpty ?? true)
                      ? const Icon(Icons.person, size: 50, color: Color(0xFF6366F1))
                      : null,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ========== الاسم والوصف ==========
  Widget _buildNameAndBio(UserModel user) {
    return Column(
      children: [
        Text(
          user.name.isEmpty ? 'أضف اسمك' : user.name,
          style: GoogleFonts.poppins(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          user.bio.isEmpty ? 'أضف وصفاً عن نفسك' : user.bio,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ========== الأزرار العلوية (مرتبة) ==========
  Widget _buildActionButtons(BuildContext context, UserModel user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // الصف الأول: زرين (مشاركة + معاينة)
          Row(
            children: [
              Expanded(
                child: user.username.isNotEmpty
                    ? ElevatedButton.icon(
                  onPressed: () {
                    final shareUrl = 'https://nexus.longlake.ai/${user.username}';
                    Clipboard.setData(ClipboardData(text: shareUrl));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('✅ تم نسخ رابط ملفك الشخصي: $shareUrl'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  },
                  icon: const Icon(Icons.share, size: 18),
                  label: const Text('مشاركة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                )
                    : ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('⚠️ الرجاء إضافة اسم مستخدم أولاً'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  },
                  icon: const Icon(Icons.warning, size: 18),
                  label: const Text('أضف اسم مستخدم'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[600],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: user.username.isNotEmpty
                    ? OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PublicProfileView(user: user),
                      ),
                    );
                  },
                  icon: const Icon(Icons.visibility, size: 18),
                  label: const Text('معاينة'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF4F46E5),
                    side: const BorderSide(color: Color(0xFF4F46E5)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                )
                    : const SizedBox(),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // زر القائمة المنسدلة للميزات المتقدمة
          MenuAnchor(
            style: MenuStyle(
              backgroundColor: WidgetStateProperty.all(Colors.white),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              elevation: WidgetStateProperty.all(4),
            ),
            builder: (context, controller, child) {
              return ElevatedButton.icon(
                onPressed: () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
                icon: const Icon(Icons.grid_view, size: 18),
                label: const Text('الميزات المتقدمة'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor: const Color(0xFF7C3AED),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              );
            },
            menuChildren: [
              // Career Score
              PopupMenuItem(
                height: 48,
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.analytics, size: 18, color: Colors.orange),
                    ),
                    const SizedBox(width: 12),
                    const Text('📊 Career Score - قيم جاهزيتك'),
                  ],
                ),
                onTap: () async {
                  final provider = Provider.of<ProfileProvider>(context, listen: false);
                  final currentUser = provider.user;
                  if (currentUser == null) return;

                  final skills = provider.getSkills();
                  final languages = currentUser.languages.map((l) => l.name).toList();
                  final projects = currentUser.projects.map((p) => p.name).toList();
                  final certificates = currentUser.certificates.map((c) => c.name).toList();

                  final result = await GroqService.getCareerScore(
                    name: currentUser.name,
                    bio: currentUser.bio,
                    skills: skills,
                    languages: languages,
                    projects: projects,
                    certificates: certificates,
                  );

                  if (mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CareerScoreView(data: result),
                      ),
                    );
                  }
                },
              ),
              const PopupMenuDivider(),

              // AI Roadmap
              PopupMenuItem(
                height: 48,
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.map, size: 18, color: Colors.green),
                    ),
                    const SizedBox(width: 12),
                    const Text('🗺️ AI Roadmap - خريطة التعلم'),
                  ],
                ),
                onTap: () async {
                  final provider = Provider.of<ProfileProvider>(context, listen: false);
                  final currentUser = provider.user;
                  if (currentUser == null) return;

                  final skills = provider.getSkills();

                  final targetJob = await _showTargetJobDialog(context);
                  if (targetJob == null || targetJob.isEmpty) return;

                  final roadmap = await GroqService.getRoadmap(
                    targetJob: targetJob,
                    currentSkills: skills,
                    experience: currentUser.bio,
                  );

                  _showRoadmapDialog(context, targetJob, roadmap);
                },
              ),
              const PopupMenuDivider(),

              // AI Interview
              PopupMenuItem(
                height: 48,
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.mic, size: 18, color: Color(0xFFF59E0B)),
                    ),
                    const SizedBox(width: 12),
                    const Text('🎤 AI Interview - محاكاة مقابلة'),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const InterviewView()),
                  );
                },
              ),
              const PopupMenuDivider(),

              // Job Match
              PopupMenuItem(
                height: 48,
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4F46E5).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.work, size: 18, color: Color(0xFF4F46E5)),
                    ),
                    const SizedBox(width: 12),
                    const Text('🔍 ابحث عن وظائف مناسبة'),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const JobMatchesView()),
                  );
                },
              ),
              const PopupMenuDivider(),

              // Resume Builder
              PopupMenuItem(
                height: 48,
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C3AED).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.auto_awesome, size: 18, color: Color(0xFF7C3AED)),
                    ),
                    const SizedBox(width: 12),
                    const Text('✨ إنشاء سيرة ذاتية'),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ResumeView()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ========== دوال مساعدة للحوارات ==========
  void _showRoadmapDialog(BuildContext context, String targetJob, String roadmap) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('🗺️ خريطة التعلم: $targetJob', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Text(roadmap, style: GoogleFonts.poppins(fontSize: 12, height: 1.5)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (Navigator.canPop(dialogContext)) {
                Navigator.of(dialogContext).pop();
              }
            },
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  Future<String?> _showTargetJobDialog(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('الوظيفة المستهدفة'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'مثال: مطور Flutter',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text.trim()),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5)),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }

  // ========== قسم الروابط الاجتماعية ==========
  Widget _buildLinksSection(ProfileProvider provider) {
    final links = provider.user?.socialLinks ?? [];

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.link, color: Color(0xFF6366F1), size: 18),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'روابط التواصل',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${links.length} رابط',
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[400]),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (links.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'لا توجد روابط مضافة',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: links.map((link) => _buildSocialIcon(link.platform, link.url)).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialIcon(String platform, String url) {
    return InkWell(
      onTap: () async {
        if (url.isNotEmpty) {
          final Uri uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _getPlatformColor(platform).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getPlatformColor(platform).withOpacity(0.3),
          ),
        ),
        child: Icon(
          _getPlatformIcon(platform),
          size: 24,
          color: _getPlatformColor(platform),
        ),
      ),
    );
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'whatsapp':
        return Icons.chat;
      case 'github':
        return Icons.code;
      case 'linkedin':
        return Icons.business;
      case 'twitter':
        return Icons.chat;
      case 'youtube':
        return Icons.videocam;
      case 'instagram':
        return Icons.camera_alt;
      case 'facebook':
        return Icons.facebook;
      case 'telegram':
        return Icons.send;
      case 'tiktok':
        return Icons.music_note;
      case 'tribe':
        return Icons.people;
      default:
        return Icons.link;
    }
  }

  Color _getPlatformColor(String platform) {
    switch (platform.toLowerCase()) {
      case 'whatsapp':
        return const Color(0xFF25D366);
      case 'github':
        return const Color(0xFF181717);
      case 'linkedin':
        return const Color(0xFF0077B5);
      case 'twitter':
        return const Color(0xFF1DA1F2);
      case 'youtube':
        return const Color(0xFFFF0000);
      case 'instagram':
        return const Color(0xFFE4405F);
      case 'facebook':
        return const Color(0xFF1877F2);
      case 'telegram':
        return const Color(0xFF26A5E4);
      case 'tiktok':
        return const Color(0xFF000000);
      case 'tribe':
        return const Color(0xFF4F46E5);
      default:
        return const Color(0xFF4F46E5);
    }
  }

  // ========== قسم المهارات ==========
  Widget _buildSkillsSection(ProfileProvider provider) {
    final skills = provider.user?.skills ?? [];

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 550),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.code, color: Color(0xFF6366F1), size: 18),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'المهارات',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${skills.length} مهارة',
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[400]),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (skills.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'لا توجد مهارات مضافة',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: skills.map((skill) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF4F46E5).withOpacity(0.3)),
                    ),
                    child: Text(
                      skill,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: const Color(0xFF4F46E5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ========== قسم المشاريع ==========
  Widget _buildProjectsSection(BuildContext context, ProfileProvider provider) {
    final projects = provider.user?.projects ?? [];

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('المشاريع', Icons.folder, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddProjectView()),
              );
            }),
            const SizedBox(height: 12),
            if (projects.isEmpty)
              _buildEmptyState('لا توجد مشاريع مضافة', Icons.folder_open)
            else
              ...projects.map((project) => _buildProjectCard(
                project.name,
                project.description,
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectCard(String title, String description) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.folder, size: 20, color: Color(0xFF6366F1)),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      ),
    );
  }

  // ========== قسم الشهادات ==========
  Widget _buildCertificatesSection(BuildContext context, ProfileProvider provider) {
    final certificates = provider.user?.certificates ?? [];

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 700),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('الشهادات', Icons.verified, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddCertificateView()),
              );
            }),
            const SizedBox(height: 12),
            if (certificates.isEmpty)
              _buildEmptyState('لا توجد شهادات مضافة', Icons.verified_outlined)
            else
              ...certificates.map((cert) => _buildCertificateCard(
                cert.name,
                cert.issuer,
                cert.date,
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildCertificateCard(String name, String issuer, String date) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.verified, size: 20, color: Colors.green),
        ),
        title: Text(
          name,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '$issuer • $date',
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      ),
    );
  }

  // ========== قسم اللغات ==========
  Widget _buildLanguagesSection(ProfileProvider provider) {
    final languages = provider.user?.languages ?? [];

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 650),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.language, color: Color(0xFF6366F1), size: 18),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'اللغات',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${languages.length} لغة',
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[400]),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (languages.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'لا توجد لغات مضافة',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ...languages.map((lang) => _buildLanguageCard(lang)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageCard(Language lang) {
    String levelText = '';
    Color levelColor;

    switch (lang.level) {
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: levelColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.language, size: 20, color: levelColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lang.name,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: levelColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    levelText,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: levelColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========== قسم فارغ ==========
  Widget _buildEmptyState(String message, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              message,
              style: GoogleFonts.poppins(color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  // ========== رأس القسم مع زر الإضافة ==========
  Widget _buildSectionHeader(String title, IconData icon, VoidCallback onAdd) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF6366F1), size: 18),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E293B),
          ),
        ),
        const Spacer(),
        TextButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add, size: 18, color: Color(0xFF6366F1)),
          label: Text(
            'إضافة',
            style: GoogleFonts.poppins(color: const Color(0xFF6366F1)),
          ),
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF6366F1),
          ),
        ),
      ],
    );
  }
}