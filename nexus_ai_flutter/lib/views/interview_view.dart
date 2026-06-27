import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nexus_ai/providers/profile_provider.dart';
import 'package:nexus_ai/services/groq_service.dart';

class InterviewView extends StatefulWidget {
  const InterviewView({super.key});

  @override
  State<InterviewView> createState() => _InterviewViewState();
}

class _InterviewViewState extends State<InterviewView> {
  List<Map<String, dynamic>> _questions = [];
  int _currentIndex = 0;
  String _userAnswer = '';
  bool _isLoading = false;
  bool _interviewStarted = false;
  String? _evaluationResult;

  Future<void> _startInterview() async {
    setState(() {
      _isLoading = true;
      _questions = [];
      _currentIndex = 0;
      _userAnswer = '';
      _evaluationResult = null;
    });

    final provider = Provider.of<ProfileProvider>(context, listen: false);
    final user = provider.user;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء تسجيل الدخول أولاً')),
      );
      setState(() => _isLoading = false);
      return;
    }

    final skills = provider.getSkills();

    if (skills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إضافة مهارات أولاً')),
      );
      setState(() => _isLoading = false);
      return;
    }

    final targetJob = 'مطور Flutter';

    final result = await GroqService.generateInterviewQuestions(
      jobTitle: targetJob,
      skills: skills,
    );

    setState(() {
      if (result['success'] && result['questions'].isNotEmpty) {
        _questions = result['questions'];
        _interviewStarted = true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ في توليد الأسئلة')),
        );
      }
      _isLoading = false;
    });
  }

  Future<void> _submitAnswer() async {
    if (_userAnswer.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء كتابة إجابتك')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final currentQuestion = _questions[_currentIndex];
    final keyPoints = List<String>.from(currentQuestion['keyPoints'] ?? []);

    final evaluation = await GroqService.evaluateInterviewAnswer(
      question: currentQuestion['question'],
      userAnswer: _userAnswer,
      keyPoints: keyPoints,
    );

    setState(() {
      _evaluationResult = '''
${evaluation['level']} - ${evaluation['score']}%

📝 تقييم: ${evaluation['feedback']}

✅ نقاط جيدة:
${(evaluation['goodPoints'] as List).map((p) => '• $p').join('\n')}

⚠️ نقاط ناقصة:
${(evaluation['missingPoints'] as List).map((p) => '• $p').join('\n')}
''';
      _isLoading = false;
    });
  }

  void _nextQuestion() {
    setState(() {
      if (_currentIndex < _questions.length - 1) {
        _currentIndex++;
        _userAnswer = '';
        _evaluationResult = null;
      } else {
        _interviewStarted = false;
        _questions = [];
        _currentIndex = 0;
        _userAnswer = '';
        _evaluationResult = null;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🎉 شكراً لإكمال المقابلة!')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          '🎤 محاكاة المقابلة الوظيفية',
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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _isLoading
            ? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('جاري تجهيز المقابلة...'),
            ],
          ),
        )
            : !_interviewStarted
            ? _buildStartScreen()
            : _buildInterviewScreen(),
      ),
    );
  }

  Widget _buildStartScreen() {
    return Center(
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
            child: const Icon(Icons.mic, size: 50, color: Color(0xFF4F46E5)),
          ),
          const SizedBox(height: 32),
          Text(
            'محاكاة مقابلة وظيفية',
            style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            'الذكاء الاصطناعي سيحاورك كمدير توظيف\nسيقيم إجاباتك ويعطيك نصائح للتحسين',
            style: GoogleFonts.poppins(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _startInterview,
            icon: const Icon(Icons.play_arrow),
            label: const Text('ابدأ المقابلة الآن'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              backgroundColor: const Color(0xFF4F46E5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterviewScreen() {
    final question = _questions[_currentIndex];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: (_currentIndex + 1) / _questions.length,
            backgroundColor: Colors.grey[200],
            color: const Color(0xFF4F46E5),
          ),
          const SizedBox(height: 16),
          Text(
            'السؤال ${_currentIndex + 1} من ${_questions.length}',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
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
                        color: const Color(0xFF4F46E5).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.help, size: 20, color: Color(0xFF4F46E5)),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'السؤال',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  question['question'],
                  style: GoogleFonts.poppins(fontSize: 16, height: 1.5),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(question['difficulty']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'الصعوبة: ${question['difficulty'] ?? 'متوسط'}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: _getDifficultyColor(question['difficulty']),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          if (_evaluationResult == null) ...[
            TextField(
              onChanged: (value) => _userAnswer = value,
              decoration: InputDecoration(
                labelText: 'اكتب إجابتك هنا',
                hintText: 'اكتب إجابتك بالتفصيل...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _submitAnswer,
              icon: _isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Icon(Icons.send),
              label: const Text('تقييم إجابتي'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: const Color(0xFF7C3AED),
              ),
            ),
          ],

          if (_evaluationResult != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.analytics, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        'نتيجة التقييم',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _evaluationResult!,
                    style: GoogleFonts.poppins(fontSize: 13, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _nextQuestion,
              icon: const Icon(Icons.arrow_forward),
              label: Text(_currentIndex < _questions.length - 1 ? 'السؤال التالي' : 'إنهاء المقابلة'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: const Color(0xFF4F46E5),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getDifficultyColor(String? difficulty) {
    switch (difficulty) {
      case 'سهل':
        return Colors.green;
      case 'صعب':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}