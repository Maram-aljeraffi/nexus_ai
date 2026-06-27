import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nexus_ai/providers/profile_provider.dart';
import 'package:nexus_ai/services/groq_service.dart';
import 'package:nexus_ai/services/pdf_service.dart';
import 'package:flutter/services.dart';

class ResumeView extends StatefulWidget {
  const ResumeView({super.key});

  @override
  State<ResumeView> createState() => _ResumeViewState();
}

class _ResumeViewState extends State<ResumeView> {
  String _resume = '';
  bool _isLoading = false;
  String? _errorMessage;
  bool _isCopied = false;
  String _selectedLanguage = 'ar'; // 'ar' للعربية، 'en' للإنجليزية

  Future<void> _generateResume() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _resume = '';
    });

    final provider = Provider.of<ProfileProvider>(context, listen: false);
    final user = provider.user;

    if (user == null) {
      setState(() {
        _errorMessage = 'الرجاء تسجيل الدخول أولاً';
        _isLoading = false;
      });
      return;
    }

    if (user.name.isEmpty) {
      setState(() {
        _errorMessage = 'الرجاء إضافة اسمك أولاً في ملفك الشخصي';
        _isLoading = false;
      });
      return;
    }

    final skills = provider.getSkills();
    final projects = user.projects.map((p) => p.name).toList();
    final certificates = user.certificates.map((c) => c.name).toList();
    final socialLinks = user.socialLinks.map((link) {
      return {
        'platform': link.platform,
        'url': link.url,
      };
    }).toList();
    final languages = user.languages.map((lang) {
      return {
        'name': lang.name,
        'level': lang.level,
      };
    }).toList();

    try {
      final resume = await GroqService.generateATSResume(
        name: user.name,
        bio: user.bio,
        skills: skills,
        projects: projects,
        certificates: certificates,
        socialLinks: socialLinks,
        languages: languages,
        language: _selectedLanguage,
      );

      setState(() {
        _resume = resume;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _getResumeTips() async {
    if (_resume.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('قم بإنشاء السيرة الذاتية أولاً'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final tips = await GroqService.getResumeTips(_resume);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              const Icon(Icons.lightbulb, color: Color(0xFFF59E0B)),
              const SizedBox(width: 8),
              Text(
                'نصائح لتحسين سيرتك',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Text(
              tips,
              style: GoogleFonts.poppins(height: 1.6, fontSize: 14),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('حسناً'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _copyToClipboard() {
    if (_resume.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _resume));
      setState(() => _isCopied = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📋 تم نسخ السيرة الذاتية إلى الحافظة'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _isCopied = false);
      });
    }
  }

  Future<void> _saveAsPdf() async {
    if (_resume.isEmpty) return;

    final provider = Provider.of<ProfileProvider>(context, listen: false);
    final user = provider.user;

    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      await PdfService.saveResume(
        name: user.name,
        bio: user.bio,
        skills: provider.getSkills(),
        projects: user.projects.map((p) => p.name).toList(),
        certificates: user.certificates.map((c) => c.name).toList(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ تم حفظ PDF بنجاح'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في حفظ PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _shareAsPdf() async {
    if (_resume.isEmpty) return;

    final provider = Provider.of<ProfileProvider>(context, listen: false);
    final user = provider.user;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء تسجيل الدخول أولاً'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await PdfService.shareResume(
        name: user.name,
        bio: user.bio,
        skills: provider.getSkills(),
        projects: user.projects.map((p) => p.name).toList(),
        certificates: user.certificates.map((c) => c.name).toList(),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في مشاركة PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'السيرة الذاتية',
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
        actions: [
          if (_resume.isNotEmpty)
            IconButton(
              icon: Icon(_isCopied ? Icons.check : Icons.copy, color: Colors.white),
              onPressed: _copyToClipboard,
              tooltip: 'نسخ النص',
            ),
          if (_resume.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.save_alt, color: Colors.white),
              onPressed: _saveAsPdf,
              tooltip: 'حفظ PDF',
            ),
          if (_resume.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: _shareAsPdf,
              tooltip: 'مشاركة PDF',
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8FAFC), Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // ✅ اختيار اللغة (بدون أعلام)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedLanguage,
                    isExpanded: true,
                    icon: const Icon(Icons.language, color: Color(0xFF4F46E5)),
                    items: const [
                      DropdownMenuItem(value: 'ar', child: Text('العربية')),
                      DropdownMenuItem(value: 'en', child: Text('English')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedLanguage = value);
                      }
                    },
                  ),
                ),
              ),

              // زر إنشاء السيرة الذاتية
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 500),
                builder: (context, value, child) =>
                    Transform.scale(scale: value, child: child),
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _generateResume,
                  icon: _isLoading
                      ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.auto_awesome),
                  label: Text(
                    _isLoading ? 'جاري الإنشاء...' : '✨ إنشاء سيرة ذاتية',
                    style: GoogleFonts.poppins(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 55),
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    elevation: 4,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // زر نصائح التحسين
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _getResumeTips,
                icon: const Icon(Icons.tips_and_updates),
                label: const Text('💡 نصائح لتحسين سيرتك الذاتية'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: const Color(0xFF059669),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  elevation: 2,
                ),
              ),
              const SizedBox(height: 20),

              // رسالة الخطأ
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: GoogleFonts.poppins(
                              color: Colors.red, fontSize: 13),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _errorMessage = null),
                        child: Icon(Icons.close, color: Colors.red[300], size: 20),
                      ),
                    ],
                  ),
                ),

              // عرض السيرة الذاتية
              if (_isLoading)
                const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF7C3AED)),
                        ),
                        SizedBox(height: 16),
                        Text('جاري إنشاء سيرتك الذاتية...',
                            style: TextStyle(color: Colors.grey)),
                        SizedBox(height: 8),
                        Text(
                            'الذكاء الاصطناعي يعمل على تحليل بياناتك',
                            style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                )
              else if (_resume.isNotEmpty)
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)],
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(24),
                              topRight: Radius.circular(24),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.description,
                                    color: Colors.white, size: 22),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'سيرتك الذاتية',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${_resume.length} حرف',
                                  style: GoogleFonts.poppins(
                                      color: Colors.white70, fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(20),
                            child: SelectableText(
                              _resume,
                              style: GoogleFonts.poppins(
                                  fontSize: 14, height: 1.6, color: Colors.black87),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _copyToClipboard,
                                  icon: Icon(_isCopied ? Icons.check : Icons.copy,
                                      size: 18),
                                  label: Text(_isCopied ? 'تم النسخ' : 'نسخ النص'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: _isCopied
                                        ? Colors.green
                                        : const Color(0xFF4F46E5),
                                    side: BorderSide(
                                        color: _isCopied
                                            ? Colors.green
                                            : const Color(0xFF4F46E5)),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16)),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _saveAsPdf,
                                  icon: const Icon(Icons.save_alt, size: 18),
                                  label: const Text('حفظ PDF'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF059669),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16)),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4F46E5).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'لا توجد سيرة ذاتية',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'اضغط على الزر أعلاه لإنشاء سيرتك الذاتية',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}