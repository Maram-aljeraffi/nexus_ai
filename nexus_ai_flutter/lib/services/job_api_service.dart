import 'dart:convert';
import 'package:http/http.dart' as http;

class JobApiService {
  // مفتاح Apify (يمكنك تغييره لاحقاً)
  static const String apifyToken = "apify_api_NI07YVSdSqoHfWky4QyjCvbpacdLwW11E3OP";

  static Future<List<Map<String, dynamic>>> searchRealJobs({
    required String skills,
    required String projects,
    required String certificates,
  }) async {
    try {
      // محاكاة وظائف للعرض (لأن API Apify قد يحتاج تفعيل)
      // هذا مؤقتاً للهاكاثون
      await Future.delayed(const Duration(seconds: 1));

      // وظائف نموذجية للعرض
      return [
        {
          'title': 'مطور Flutter - عن بعد',
          'company': 'شركة تقنية عالمية',
          'location': 'عن بعد (Remote)',
          'match': '92%',
          'reason': 'مهاراتك في Flutter ممتازة وتناسب هذه الوظيفة',
          'salary': '8,000 - 12,000 ريال',
          'url': 'https://example.com/job1',
          'description': 'نبحث عن مطور Flutter محترف للانضمام إلى فريقنا',
        },
        {
          'title': 'مطور تطبيقات جوال',
          'company': 'شركة ناشئة',
          'location': 'الرياض، السعودية',
          'match': '85%',
          'reason': 'خبرتك في تطوير التطبيقات مطلوبة لهذه الوظيفة',
          'salary': '7,000 - 10,000 ريال',
          'url': 'https://example.com/job2',
          'description': 'مطلوب مطور تطبيقات جوال للعمل في مشاريع مبتكرة',
        },
        {
          'title': 'مهندس برمجيات - Full Stack',
          'company': 'شركة كبرى',
          'location': 'دبي، الإمارات',
          'match': '78%',
          'reason': 'مهاراتك في Laravel و Flutter مناسبة',
          'salary': '10,000 - 15,000 ريال',
          'url': 'https://example.com/job3',
          'description': 'نبحث عن مهندس برمجيات متكامل للمشاركة في تطوير المنتجات',
        },
      ];
    } catch (e) {
      print("خطأ في جلب الوظائف: $e");
      return [];
    }
  }
}