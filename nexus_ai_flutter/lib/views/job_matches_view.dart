import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nexus_ai/providers/profile_provider.dart';
import 'package:nexus_ai/services/groq_service.dart';
import 'package:nexus_ai/services/job_api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class JobMatchesView extends StatefulWidget {
  const JobMatchesView({super.key});

  @override
  State<JobMatchesView> createState() => _JobMatchesViewState();
}

class _JobMatchesViewState extends State<JobMatchesView> {
  List<Map<String, dynamic>> _matches = [];
  bool _isLoading = false;
  String? _errorMessage;
  final Set<int> _savedJobs = {};
  bool _useRealJobs = true;

  Future<void> _findMatches() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _matches = [];
      _savedJobs.clear();
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

    if (user.projects.isEmpty && user.certificates.isEmpty) {
      setState(() {
        _errorMessage = 'الرجاء إضافة مشاريع أو شهادات أولاً لنتمكن من البحث عن وظائف مناسبة';
        _isLoading = false;
      });
      return;
    }

    final skills = provider.getSkills().join(', ');
    final projects = user.projects.map((p) => p.description).join(', ');
    final certificates = user.certificates.map((c) => c.name).join(', ');

    try {
      List<Map<String, dynamic>> matches;

      if (_useRealJobs) {
        matches = await JobApiService.searchRealJobs(
          skills: skills,
          projects: projects,
          certificates: certificates,
        );

        if (matches.isEmpty) {
          matches = await GroqService.matchJobs(
            skills: skills,
            projects: projects,
            certificates: certificates,
          );
          if (matches.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم عرض وظائف مقترحة بواسطة الذكاء الاصطناعي'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      } else {
        matches = await GroqService.matchJobs(
          skills: skills,
          projects: projects,
          certificates: certificates,
        );
      }

      setState(() {
        _matches = matches;
        _isLoading = false;
      });

      if (matches.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لم يتم العثور على وظائف مناسبة حالياً'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _toggleSaveJob(int index) {
    setState(() {
      if (_savedJobs.contains(index)) {
        _savedJobs.remove(index);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إزالة ${_matches[index]['title']} من المفضلة'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 1),
          ),
        );
      } else {
        _savedJobs.add(index);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم حفظ ${_matches[index]['title']} في المفضلة'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    });
  }

  Future<void> _launchJobUrl(String url) async {
    if (url.isNotEmpty) {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لا يمكن فتح الرابط')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'وظائف مناسبة لك',
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
          Row(
            children: [
              Text(
                'وظائف حقيقية',
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
              ),
              Switch(
                value: _useRealJobs,
                onChanged: (value) {
                  setState(() {
                    _useRealJobs = value;
                    _matches = [];
                  });
                },
                activeColor: const Color(0xFF38BDF8),
              ),
            ],
          ),
          if (_matches.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _findMatches,
              tooltip: 'تحديث',
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
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 500),
                builder: (context, value, child) =>
                    Transform.scale(scale: value, child: child),
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _findMatches,
                  icon: _isLoading
                      ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.search),
                  label: Text(
                    _isLoading ? 'جاري البحث...' : 'ابحث عن وظائف مناسبة',
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 55),
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    elevation: 3,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              if (!_isLoading && _useRealJobs && _matches.isEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          size: 20, color: Color(0xFF4F46E5)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'وظائف حقيقية من Himalayas Remote Jobs. اضغط زر البحث أعلاه.',
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: Color(0xFF4F46E5)),
                        ),
                      ),
                    ],
                  ),
                ),

              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: GoogleFonts.poppins(color: Colors.red),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: () => setState(() => _errorMessage = null),
                      ),
                    ],
                  ),
                ),

              if (_isLoading)
                const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF4F46E5)),
                        ),
                        SizedBox(height: 16),
                        Text('جاري البحث عن وظائف مناسبة...',
                            style: TextStyle(color: Colors.grey)),
                        SizedBox(height: 8),
                        Text('قد يستغرق البحث بضع ثوانٍ',
                            style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                )
              else if (_matches.isNotEmpty)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4F46E5).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${_matches.length} وظيفة ${_useRealJobs ? 'حقيقية' : 'مقترحة'}',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF4F46E5),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (_savedJobs.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${_savedJobs.length} محفوظة',
                                style: GoogleFonts.poppins(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _matches.length,
                          itemBuilder: (context, index) {
                            final job = _matches[index];
                            final isSaved = _savedJobs.contains(index);
                            return _buildJobCard(job, index, isSaved);
                          },
                        ),
                      ),
                    ],
                  ),
                )
              else
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.work_outline,
                            size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'لا توجد وظائف',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'اضغط على الزر أعلاه للبحث عن وظائف مناسبة',
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

  Widget _buildJobCard(Map<String, dynamic> job, int index, bool isSaved) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isSaved ? Colors.green.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
        border: isSaved
            ? Border.all(color: Colors.green.withOpacity(0.5))
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showJobDetails(job),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: _getMatchGradient(job['match'] ?? '70%'),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        job['match'] ?? '70%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        isSaved ? Icons.favorite : Icons.favorite_border,
                        size: 20,
                        color: isSaved ? Colors.red : Colors.grey,
                      ),
                      onPressed: () => _toggleSaveJob(index),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  job['title'] ?? 'وظيفة',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.business, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        job['company'] ?? 'شركة',
                        style: GoogleFonts.poppins(
                            fontSize: 14, color: Colors.grey[600]),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        job['location'] ?? 'موقع',
                        style: GoogleFonts.poppins(
                            fontSize: 14, color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
                if (job['salary'] != null && job['salary']!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Icon(Icons.attach_money,
                            size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          job['salary'],
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lightbulb,
                          size: 18, color: Color(0xFF4F46E5)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          job['reason'] ?? 'مناسب لمهاراتك',
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: Colors.black54),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _applyForJob(job),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7C3AED),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 40),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(
                          'تقدّم الآن',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    if (job['url'] != null && job['url']!.isNotEmpty)
                      const SizedBox(width: 8),
                    if (job['url'] != null && job['url']!.isNotEmpty)
                      OutlinedButton(
                        onPressed: () => _launchJobUrl(job['url']),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF4F46E5),
                          side: const BorderSide(color: Color(0xFF4F46E5)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(
                          'تفاصيل',
                          style: GoogleFonts.poppins(),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Gradient _getMatchGradient(String match) {
    final percentage = int.tryParse(match.replaceAll('%', '')) ?? 70;
    if (percentage >= 80)
      return const LinearGradient(
          colors: [Color(0xFF34D399), Color(0xFF6EE7B7)]);
    if (percentage >= 60)
      return const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF818CF8)]);
    return const LinearGradient(
        colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)]);
  }

  void _showJobDetails(Map<String, dynamic> job) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                job['title'] ?? 'وظيفة',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${job['company'] ?? 'شركة'} • ${job['location'] ?? 'موقع'}',
                style: GoogleFonts.poppins(color: Colors.grey[600]),
              ),
              if (job['salary'] != null && job['salary']!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '💰 ${job['salary']}',
                    style: GoogleFonts.poppins(color: Colors.green[700]),
                  ),
                ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'تفاصيل الوظيفة',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                job['description'] ??
                    job['reason'] ??
                    'هذه الوظيفة مناسبة لمهاراتك وخبراتك',
                style: GoogleFonts.poppins(height: 1.5),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _applyForJob(job);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text(
                    'تقدّم الآن',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _applyForJob(Map<String, dynamic> job) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text('تم التقديم على وظيفة ${job['title']} بنجاح'),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}