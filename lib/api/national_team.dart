import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiNews {
final String _baseUrl = "https://eyn.ur.gov.iq/api_user.php"; 
  final String _imageBaseUrl = "https://eyn.ur.gov.iq/"; 


Future<List<dynamic>> efficiency({required String sectionId, required String lang}) async {
  final response = await http.post(
    Uri.parse(_baseUrl),  // استخدم POST مع URL الأساسي
    headers: {"Content-Type": "application/json"},  // تحديد نوع المحتوى كـ JSON
    body: jsonEncode({
      "action": "getContent",
      "section_id": sectionId,
      "lang": lang,
      "role": "user"
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
    throw Exception('Failed to load efficiency data');
  }
}




}
