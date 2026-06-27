import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nexus_ai/models/user_model.dart';
import 'package:url_launcher/url_launcher.dart';

class PublicProfileView extends StatelessWidget {
  final UserModel user;
  const PublicProfileView({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          user.username.isNotEmpty ? user.username : 'الملف الشخصي',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ========== الهيدر ==========
            _buildHeader(),
            const SizedBox(height: 24),

            // ========== السيرة الذاتية (Bio) ==========
            if (user.bio.isNotEmpty) _buildBio(),
            if (user.bio.isNotEmpty) const SizedBox(height: 24),

            // ========== المهارات ==========
            if (user.skills.isNotEmpty) _buildSkillsSection(),
            if (user.skills.isNotEmpty) const SizedBox(height: 24),

            // ========== اللغات ==========
            if (user.languages.isNotEmpty) _buildLanguagesSection(),
            if (user.languages.isNotEmpty) const SizedBox(height: 24),

            // ========== المشاريع ==========
            if (user.projects.isNotEmpty) _buildProjectsSection(),
            if (user.projects.isNotEmpty) const SizedBox(height: 24),

            // ========== الشهادات ==========
            if (user.certificates.isNotEmpty) _buildCertificatesSection(),
            if (user.certificates.isNotEmpty) const SizedBox(height: 24),

            // ========== الروابط الاجتماعية ==========
            if (user.socialLinks.isNotEmpty) _buildSocialLinksSection(),
            if (user.socialLinks.isNotEmpty) const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ========== الهيدر (الصورة + الاسم + اسم المستخدم) ==========
  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 45,
          backgroundColor: const Color(0xFF4F46E5),
          backgroundImage: user.profileImageUrl.isNotEmpty
              ? NetworkImage(user.profileImageUrl)
              : null,
          child: user.profileImageUrl.isEmpty
              ? Text(
            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
            style: const TextStyle(fontSize: 32, color: Colors.white),
          )
              : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name.isEmpty ? 'مستخدم' : user.name,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              if (user.username.isNotEmpty)
                Text(
                  '@${user.username}',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey[500],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ========== السيرة الذاتية ==========
  Widget _buildBio() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        user.bio,
        style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
      ),
    );
  }

  // ========== المهارات ==========
  Widget _buildSkillsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF4F46E5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.code, size: 18, color: Color(0xFF4F46E5)),
              ),
              const SizedBox(width: 10),
              Text(
                'المهارات',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: user.skills.map((skill) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF4F46E5).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
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
    );
  }

  // ========== اللغات ==========
  Widget _buildLanguagesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF4F46E5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.language, size: 18, color: Color(0xFF4F46E5)),
              ),
              const SizedBox(width: 10),
              Text(
                'اللغات',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...user.languages.map((lang) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                const Icon(Icons.check_circle, size: 18, color: Color(0xFF4F46E5)),
                const SizedBox(width: 10),
                Text(
                  lang.name,
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                _buildLevelChip(lang.level),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildLevelChip(String level) {
    String text;
    Color color;
    switch (level) {
      case 'excellent':
        text = 'ممتاز';
        color = Colors.green;
        break;
      case 'good':
        text = 'جيد';
        color = Colors.blue;
        break;
      case 'average':
        text = 'متوسط';
        color = Colors.orange;
        break;
      default:
        text = 'غير محدد';
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(fontSize: 12, color: color, fontWeight: FontWeight.w500),
      ),
    );
  }

  // ========== المشاريع ==========
  Widget _buildProjectsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF4F46E5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.folder, size: 18, color: Color(0xFF4F46E5)),
              ),
              const SizedBox(width: 10),
              Text(
                'المشاريع',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...user.projects.map((project) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            elevation: 0,
            color: Colors.grey[50],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4F46E5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.folder, size: 18, color: Color(0xFF4F46E5)),
              ),
              title: Text(
                project.name,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              subtitle: project.description.isNotEmpty
                  ? Text(project.description, maxLines: 2)
                  : null,
              trailing: project.link.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.open_in_new, size: 18),
                onPressed: () => launchUrl(Uri.parse(project.link)),
              )
                  : null,
            ),
          )),
        ],
      ),
    );
  }

  // ========== الشهادات ==========
  Widget _buildCertificatesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF4F46E5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.verified, size: 18, color: Color(0xFF4F46E5)),
              ),
              const SizedBox(width: 10),
              Text(
                'الشهادات',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...user.certificates.map((cert) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            elevation: 0,
            color: Colors.grey[50],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.verified, color: Colors.green),
              title: Text(
                cert.name,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              subtitle: Text('${cert.issuer} • ${cert.date}'),
            ),
          )),
        ],
      ),
    );
  }

  // ========== الروابط الاجتماعية ==========
  Widget _buildSocialLinksSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF4F46E5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.link, size: 18, color: Color(0xFF4F46E5)),
              ),
              const SizedBox(width: 10),
              Text(
                'روابط التواصل',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: user.socialLinks.map((link) => InkWell(
              onTap: () => launchUrl(Uri.parse(link.url)),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getPlatformColor(link.platform).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getPlatformIcon(link.platform),
                  size: 26,
                  color: _getPlatformColor(link.platform),
                ),
              ),
            )).toList(),
          ),
        ],
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
      default: return const Color(0xFF4F46E5);
    }
  }
}