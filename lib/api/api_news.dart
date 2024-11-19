import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiNews {
final String _baseUrl = "https://eyn.ur.gov.iq/api_user.php"; 
  final String _imageBaseUrl = "https://eyn.ur.gov.iq/"; 

Future<List<dynamic>> fetchArticles({required String sectionId, required String lang}) async {
  final response = await http.post(
    Uri.parse(_baseUrl),  // استخدم POST مع URL أساسي
    headers: {"Content-Type": "application/json"},  // حدد نوع المحتوى
    body: jsonEncode({
      "action": "getContent",
      "section_id": sectionId,
      "lang": lang,
      // "role": "admin",  // أو "user" بناءً على احتياجاتك
      "t_id": 8
    }),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    // Add base URL to each image path
    return data.map((article) {
      article['file_path'] = '$_imageBaseUrl${article['file_path']}'; // Ensure full URL for images
      return article;
    }).toList();
  } else {
    throw Exception('Failed to load articles');
  }
}


  // Fetch Job Opportunities
  
Future<List<dynamic>> fetchJobs({required String sectionId, required String lang}) async {
  final response = await http.post(
    Uri.parse(_baseUrl),  // استخدم POST مع URL أساسي
    headers: {"Content-Type": "application/json"},  // تحديد نوع المحتوى كـ JSON
    body: jsonEncode({
      "action": "getContent",
      "section_id": sectionId,
      "lang": lang,
      // "role": "admin",  // استخدم "admin" أو "user" حسب الحاجة
      "t_id": 9         // t_id=9 خاص بفرص العمل
    }),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    // تعديل كل عنصر ليحتوي على URL الصورة وتاريخ الإنشاء
    return data.map((job) {
      job['file_path'] = '$_imageBaseUrl${job['file_path']}';  // مسار الصورة الكامل
      return job;
    }).toList();
  } else {
    throw Exception('Failed to load jobs');
  }
}



  // Fetch Events

Future<List<dynamic>> fetchEvents({required String sectionId, required String lang}) async {
  final response = await http.post(
    Uri.parse(_baseUrl),  // استخدم POST مع URL أساسي
    headers: {"Content-Type": "application/json"},  // تحديد نوع المحتوى كـ JSON
    body: jsonEncode({
      "action": "getContent",
      "section_id": sectionId,
      "lang": lang,
      // "role": "admin",  // استخدم "admin" أو "user" بناءً على احتياجاتك
      "t_id": 10        // t_id=10 خاص بالأحداث
    }),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    // تعديل كل عنصر ليحتوي على URL الصورة وتاريخ الإنشاء
    return data.map((event) {
      event['file_path'] = '$_imageBaseUrl${event['file_path']}'; // مسار الصورة الكامل
      return event;
    }).toList();
  } else {
    throw Exception('Failed to load events');
  }
}

}
