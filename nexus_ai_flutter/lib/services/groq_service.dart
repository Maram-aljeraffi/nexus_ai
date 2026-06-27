import 'dart:convert';
import 'package:http/http.dart' as http;

class GroqService {
  static const String apiKey = "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";
  static const String apiUrl = "https://api.groq.com/openai/v1/chat/completions";

  // ==================== 1. إنشاء سيرة ذاتية متوافقة مع ATS ====================
  static Future<String> generateATSResume({
    required String name,
    required String bio,
    required List<String> skills,
    required List<String> projects,
    required List<String> certificates,
    required List<Map<String, String>> socialLinks,
    required List<Map<String, String>> languages,
    required String language,
  }) async {
    final socialLinksText = socialLinks.map((link) {
      return '• ${link['platform']}: ${link['url']}';
    }).join('\n');

    final skillsText = skills.map((s) => '• $s').join('\n');
    final projectsText = projects.asMap().entries.map((entry) {
      final index = entry.key + 1;
      final project = entry.value;
      return '  $index. $project';
    }).join('\n\n');
    final certificatesText = certificates.map((c) => '• $c').join('\n');

    final languagesText = languages.map((lang) {
      String levelText = '';
      String languageName = '';

      if (language == 'ar') {
        switch (lang['name']) {
          case 'العربية': languageName = 'العربية'; break;
          case 'الإنجليزية': languageName = 'الإنجليزية'; break;
          case 'الفرنسية': languageName = 'الفرنسية'; break;
          case 'الألمانية': languageName = 'الألمانية'; break;
          case 'الإسبانية': languageName = 'الإسبانية'; break;
          default: languageName = lang['name']!;
        }
        switch (lang['level']) {
          case 'excellent': levelText = 'ممتاز'; break;
          case 'good': levelText = 'جيد'; break;
          case 'average': levelText = 'متوسط'; break;
          default: levelText = 'غير محدد';
        }
      } else {
        switch (lang['name']) {
          case 'العربية': languageName = 'Arabic'; break;
          case 'الإنجليزية': languageName = 'English'; break;
          case 'الفرنسية': languageName = 'French'; break;
          case 'الألمانية': languageName = 'German'; break;
          case 'الإسبانية': languageName = 'Spanish'; break;
          default: languageName = lang['name']!;
        }
        switch (lang['level']) {
          case 'excellent': levelText = 'Excellent'; break;
          case 'good': levelText = 'Good'; break;
          case 'average': levelText = 'Average'; break;
          default: levelText = 'Not Specified';
        }
      }
      return '• $languageName: $levelText';
    }).join('\n');

    final titles = language == 'ar' ? {
      'title': 'السيرة الذاتية',
      'summary': 'الملخص المهني',
      'skills': 'المهارات التقنية',
      'projects': 'المشاريع',
      'certificates': 'الشهادات',
      'links': 'روابط التواصل',
      'languages': 'اللغات',
    } : {
      'title': 'Resume',
      'summary': 'Professional Summary',
      'skills': 'Technical Skills',
      'projects': 'Projects',
      'certificates': 'Certifications',
      'links': 'Contact Links',
      'languages': 'Languages',
    };

    final prompt = language == 'ar' ? '''
أنت خبير في كتابة السير الذاتية المتوافقة مع أنظمة ATS.

قم بإنشاء سيرة ذاتية احترافية باللغة العربية لهذا المرشح:

الاسم: $name
الملخص: $bio

المهارات:
$skillsText

المشاريع:
$projectsText

الشهادات:
$certificatesText

الروابط:
$socialLinksText

اللغات:
$languagesText

المطلوب:
1. استخدم هذا التنسيق بالضبط:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                          ${titles['title']}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

${titles['summary']}
──────────────────────────────────────────────────────────
$bio

${titles['skills']}
──────────────────────────────────────────────────────────
$skillsText

${titles['projects']}
──────────────────────────────────────────────────────────
$projectsText

${titles['certificates']}
──────────────────────────────────────────────────────────
$certificatesText

${titles['links']}
──────────────────────────────────────────────────────────
$socialLinksText

${titles['languages']}
──────────────────────────────────────────────────────────
$languagesText

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

2. استخدم كلمات مفتاحية واضحة
3. تجنب الجداول والأعمدة
4. اجعل التنسيق بسيطاً ونصياً
''': '''
You are an expert in writing ATS-compliant resumes.

Create a professional resume in English for this candidate:

Name: $name
Summary: $bio

Skills:
$skillsText

Projects:
$projectsText

Certifications:
$certificatesText

Links:
$socialLinksText

Languages:
$languagesText

Requirements:
1. Use this exact format:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                          ${titles['title']}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

${titles['summary']}
──────────────────────────────────────────────────────────
$bio

${titles['skills']}
──────────────────────────────────────────────────────────
$skillsText

${titles['projects']}
──────────────────────────────────────────────────────────
$projectsText

${titles['certificates']}
──────────────────────────────────────────────────────────
$certificatesText

${titles['links']}
──────────────────────────────────────────────────────────
$socialLinksText

${titles['languages']}
──────────────────────────────────────────────────────────
$languagesText

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

2. Use clear keywords
3. Avoid tables and columns
4. Keep format simple and text-based
''';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: json.encode({
          'model': 'llama-3.3-70b-versatile',
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.2,
          'max_tokens': 1500,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        return _formatResumeLocally(name, bio, skills, projects, certificates, socialLinks, languages, language);
      }
    } catch (e) {
      return _formatResumeLocally(name, bio, skills, projects, certificates, socialLinks, languages, language);
    }
  }

  static String _formatResumeLocally(
      String name,
      String bio,
      List<String> skills,
      List<String> projects,
      List<String> certificates,
      List<Map<String, String>> socialLinks,
      List<Map<String, String>> languages,
      String language,
      ) {
    final projectsText = projects.asMap().entries.map((entry) {
      final index = entry.key + 1;
      final project = entry.value;
      return '  $index. $project';
    }).join('\n\n');

    final skillsText = skills.map((s) => '• $s').join('\n');
    final certificatesText = certificates.map((c) => '• $c').join('\n');
    final socialLinksText = socialLinks.map((link) {
      return '• ${link['platform']}: ${link['url']}';
    }).join('\n');

    final languagesText = languages.map((lang) {
      String levelText = '';
      String languageName = '';

      if (language == 'ar') {
        switch (lang['name']) {
          case 'العربية': languageName = 'العربية'; break;
          case 'الإنجليزية': languageName = 'الإنجليزية'; break;
          case 'الفرنسية': languageName = 'الفرنسية'; break;
          case 'الألمانية': languageName = 'الألمانية'; break;
          case 'الإسبانية': languageName = 'الإسبانية'; break;
          default: languageName = lang['name']!;
        }
        switch (lang['level']) {
          case 'excellent': levelText = 'ممتاز'; break;
          case 'good': levelText = 'جيد'; break;
          case 'average': levelText = 'متوسط'; break;
          default: levelText = 'غير محدد';
        }
      } else {
        switch (lang['name']) {
          case 'العربية': languageName = 'Arabic'; break;
          case 'الإنجليزية': languageName = 'English'; break;
          case 'الفرنسية': languageName = 'French'; break;
          case 'الألمانية': languageName = 'German'; break;
          case 'الإسبانية': languageName = 'Spanish'; break;
          default: languageName = lang['name']!;
        }
        switch (lang['level']) {
          case 'excellent': levelText = 'Excellent'; break;
          case 'good': levelText = 'Good'; break;
          case 'average': levelText = 'Average'; break;
          default: levelText = 'Not Specified';
        }
      }
      return '• $languageName: $levelText';
    }).join('\n');

    final titles = language == 'ar' ? {
      'title': 'السيرة الذاتية',
      'summary': 'الملخص المهني',
      'skills': 'المهارات التقنية',
      'projects': 'المشاريع',
      'certificates': 'الشهادات',
      'links': 'روابط التواصل',
      'languages': 'اللغات',
    } : {
      'title': 'Resume',
      'summary': 'Professional Summary',
      'skills': 'Technical Skills',
      'projects': 'Projects',
      'certificates': 'Certifications',
      'links': 'Contact Links',
      'languages': 'Languages',
    };

    return '''
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                          ${titles['title']}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

${titles['summary']}
──────────────────────────────────────────────────────────
$bio

${titles['skills']}
──────────────────────────────────────────────────────────
$skillsText

${titles['projects']}
──────────────────────────────────────────────────────────
$projectsText

${titles['certificates']}
──────────────────────────────────────────────────────────
$certificatesText

${titles['links']}
──────────────────────────────────────────────────────────
$socialLinksText

${titles['languages']}
──────────────────────────────────────────────────────────
$languagesText

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
''';
  }

  // ==================== 2. البحث عن وظائف مناسبة ====================
  static Future<List<Map<String, dynamic>>> matchJobs({
    required String skills,
    required String projects,
    required String certificates,
  }) async {
    final prompt = '''
أنت مساعد توظيف ذكي.

لدي مرشح:
- المهارات: $skills
- المشاريع: $projects
- الشهادات: $certificates

اقترح 3 وظائف مناسبة بصيغة JSON فقط:
[
  {
    "title": "عنوان الوظيفة",
    "company": "اسم الشركة",
    "location": "الموقع",
    "match": "95%",
    "reason": "سبب الترشيح"
  }
]
''';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: json.encode({
          'model': 'llama-3.3-70b-versatile',
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.5,
          'max_tokens': 1000,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['choices'][0]['message']['content'];
        try {
          return List<Map<String, dynamic>>.from(json.decode(content));
        } catch (e) {
          return [];
        }
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // ==================== 3. نصائح لتحسين السيرة الذاتية ====================
  static Future<String> getResumeTips(String currentResume) async {
    final prompt = '''
أنت خبير في كتابة السير الذاتية الاحترافية.

هذه سيرة ذاتية حالية لمستخدم:
$currentResume

أعط 5 نصائح عملية ومحددة لتحسين هذه السيرة الذاتية.
اجعل النصائح:
1. محددة وليست عامة
2. قابلة للتنفيذ
3. متعلقة بـ ATS والمحتوى والتنسيق

أخرج النصائح بهذا الشكل:
💡 النصيحة 1: ...
💡 النصيحة 2: ...
💡 النصيحة 3: ...
💡 النصيحة 4: ...
💡 النصيحة 5: ...
''';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: json.encode({
          'model': 'llama-3.3-70b-versatile',
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.5,
          'max_tokens': 800,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['choices'][0]['message']['content'];
      }
      return 'لم نتمكن من جلب النصائح حالياً. حاول مرة أخرى.';
    } catch (e) {
      return 'حدث خطأ: ${e.toString()}';
    }
  }

  // ==================== 4. Career Score - نسبة الجاهزية ====================
  static Future<Map<String, dynamic>> getCareerScore({
    required String name,
    required String bio,
    required List<String> skills,
    required List<String> languages,
    required List<String> projects,
    required List<String> certificates,
  }) async {
    final prompt = '''
أنت خبير تقييم مهني متخصص في تحليل المرشحين لسوق العمل.

حلل هذا المرشح وأعط تقييماً دقيقاً:

الاسم: $name
الملخص المهني: $bio
المهارات التقنية: ${skills.join(', ')}
اللغات: ${languages.join(', ')}
المشاريع: ${projects.join(', ')}
الشهادات: ${certificates.join(', ')}

أخرج النتيجة بصيغة JSON فقط (بدون أي كلام إضافي):
{
  "score": 75,
  "level": "متوسط",
  "color": "orange",
  "message": "نصيحة قصيرة للتحسين (سطر واحد فقط)",
  "strengths": ["نقطة قوة 1", "نقطة قوة 2"],
  "weaknesses": ["نقطة ضعف 1", "نقطة ضعف 2"],
  "recommendations": ["توصية 1", "توصية 2"]
}

ملاحظات:
- score من 0 إلى 100
- level: ممتاز (80-100) / جيد (60-79) / متوسط (40-59) / ضعيف (0-39)
- color: green / blue / orange / red
- اجعل التقييم واقعياً بناءً على البيانات المتاحة
''';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: json.encode({
          'model': 'llama-3.3-70b-versatile',
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.3,
          'max_tokens': 600,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['choices'][0]['message']['content'];
        try {
          return json.decode(content);
        } catch (e) {
          return _getDefaultScore();
        }
      } else {
        return _getDefaultScore();
      }
    } catch (e) {
      return _getDefaultScore();
    }
  }

  static Map<String, dynamic> _getDefaultScore() {
    return {
      'score': 50,
      'level': 'متوسط',
      'color': 'orange',
      'message': 'أضف المزيد من البيانات للحصول على تقييم دقيق',
      'strengths': ['لديك مهارات تقنية', 'لديك مشاريع'],
      'weaknesses': ['تحتاج إلى المزيد من الخبرة'],
      'recommendations': ['طور مهاراتك باستمرار', 'أضف مشاريع جديدة']
    };
  }

  // ==================== 5. AI Roadmap - خريطة تعلم شخصية ====================
  static Future<String> getRoadmap({
    required String targetJob,
    required List<String> currentSkills,
    required String experience,
  }) async {
    final prompt = '''
أنت خبير تطوير مهني ومدرب وظيفي.

الوظيفة المستهدفة: $targetJob
المهارات الحالية: ${currentSkills.join(', ')}
الخبرة الحالية: $experience

المطلوب: اكتب خطة تعلم شخصية تفصيلية لمدة 8 أسابيع لمساعدة هذا الشخص للوصول إلى الوظيفة المستهدفة.

استخدم هذا التنسيق بالضبط:

🎯 الهدف: $targetJob

📊 المستوى الحالي: (تقييم سريع)

🗺️ خطة التعلم (8 أسابيع):

الأسبوع 1: [عنوان الأسبوع]
• المهمة 1
• المهمة 2
• المهمة 3

الأسبوع 2: [عنوان الأسبوع]
• المهمة 1
• المهمة 2
• المهمة 3

... (استمر حتى الأسبوع 8)

💡 نصائح إضافية:
• نصيحة 1
• نصيحة 2

المصادر المقترحة:
• مصدر 1
• مصدر 2
''';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: json.encode({
          'model': 'llama-3.3-70b-versatile',
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.4,
          'max_tokens': 1200,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        return 'حدث خطأ في إنشاء خريطة التعلم. حاول مرة أخرى.';
      }
    } catch (e) {
      return 'حدث خطأ: ${e.toString()}';
    }
  }

  // ==================== 6. AI Interview - أسئلة المقابلة ====================
  static Future<Map<String, dynamic>> generateInterviewQuestions({
    required String jobTitle,
    required List<String> skills,
  }) async {
    final prompt = '''
أنت مدير توظيف محترف.

الوظيفة: $jobTitle
المهارات المطلوبة: ${skills.join(', ')}

قم بإنشاء 5 أسئلة مقابلة وظيفية شائعة لهذه الوظيفة.
لكل سؤال، حدد:
- السؤال
- مستوى الصعوبة (سهل/متوسط/صعب)
- النقاط التي يبحث عنها المدير في الإجابة

أخرج النتيجة بصيغة JSON فقط:
[
  {
    "question": "السؤال هنا",
    "difficulty": "متوسط",
    "keyPoints": ["نقطة 1", "نقطة 2"]
  }
]
''';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: json.encode({
          'model': 'llama-3.3-70b-versatile',
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.5,
          'max_tokens': 1000,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['choices'][0]['message']['content'];
        try {
          return {
            'success': true,
            'questions': List<Map<String, dynamic>>.from(json.decode(content)),
          };
        } catch (e) {
          return {'success': false, 'questions': []};
        }
      } else {
        return {'success': false, 'questions': []};
      }
    } catch (e) {
      return {'success': false, 'questions': []};
    }
  }

  // ==================== 7. تقييم إجابة المستخدم ====================
  static Future<Map<String, dynamic>> evaluateInterviewAnswer({
    required String question,
    required String userAnswer,
    required List<String> keyPoints,
  }) async {
    final prompt = '''
أنت خبير تقييم مقابلات وظيفية.

سؤال المقابلة: $question
إجابة المرشح: $userAnswer
النقاط المطلوبة في الإجابة: ${keyPoints.join(', ')}

قم بتقييم الإجابة وأخرج النتيجة بصيغة JSON فقط:
{
  "score": 75,
  "level": "جيد",
  "feedback": "نصيحة قصيرة للتحسين (سطر واحد)",
  "missingPoints": ["نقطة ناقصة 1", "نقطة ناقصة 2"],
  "goodPoints": ["نقطة جيدة 1", "نقطة جيدة 2"]
}

ملاحظات:
- score من 0 إلى 100
- level: ممتاز (80-100) / جيد (60-79) / متوسط (40-59) / ضعيف (0-39)
- feedback: نصيحة واحدة محددة
''';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: json.encode({
          'model': 'llama-3.3-70b-versatile',
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.3,
          'max_tokens': 500,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['choices'][0]['message']['content'];
        try {
          return json.decode(content);
        } catch (e) {
          return _getDefaultEvaluation();
        }
      } else {
        return _getDefaultEvaluation();
      }
    } catch (e) {
      return _getDefaultEvaluation();
    }
  }

  static Map<String, dynamic> _getDefaultEvaluation() {
    return {
      'score': 50,
      'level': 'متوسط',
      'feedback': 'حاول أن تكون أكثر تحديداً في إجابتك',
      'missingPoints': [],
      'goodPoints': []
    };
  }
}