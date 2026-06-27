import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ImageUploadService {
  // ✅ استبدلي 192.168.43.153 برقم IP الخاص بجهاز الكمبيوتر
  static const String baseUrl = 'http://192.168.43.153:8000/api';

  // ✅ إذا كنت تستخدمين المحاكي، استخدمي هذا الرابط بدلاً من السابق:
  // static const String baseUrl = 'http://10.0.2.2:8000/api';

  // دالة رفع الصورة
  static Future<String?> uploadImage(File imageFile, String type) async {
    try {
      print("🔵 جاري رفع الصورة...");
      print("📁 نوع الصورة: $type");
      print("📂 مسار الملف: ${imageFile.path}");
      print("🌐 الرابط: $baseUrl/upload-image");

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload-image'),
      );

      // إضافة الملف
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      // إضافة نوع الصورة
      request.fields['type'] = type;

      // إرسال الطلب
      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      print("📡 Response status: ${response.statusCode}");
      print("📄 Response body: $responseData");

      if (response.statusCode == 200) {
        final Map<String, dynamic> result = json.decode(responseData);
        if (result['success'] == true) {
          print("✅ تم رفع الصورة بنجاح: ${result['url']}");
          return result['url'];
        } else {
          print("❌ فشل رفع الصورة: ${result['message']}");
          return null;
        }
      } else {
        print("❌ خطأ في الخادم: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("❌ استثناء: $e");
      return null;
    }
  }

  // دالة اختبار الاتصال بالـ API
  static Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/upload-image'),
      );
      // حتى لو كان 405 (Method Not Allowed)، هذا يعني أن الخادم يعمل ✅
      return response.statusCode == 405 || response.statusCode == 200;
    } catch (e) {
      print("❌ فشل الاتصال: $e");
      return false;
    }
  }
}