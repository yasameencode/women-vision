import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiNews {
final String _baseUrl = "https://eyn.ur.gov.iq/api_user.php";
  final String _imageBaseUrl = "https://eyn.ur.gov.iq/"; 


  
Future<List<dynamic>> activities({required String sectionId, required String lang}) async {
  final response = await http.post(
    Uri.parse(_baseUrl),  // استخدم POST مع URL أساسي
    headers: {"Content-Type": "application/json"},  // تحديد نوع المحتوى كـ JSON
    body: jsonEncode({
      "action": "getContent",
      "section_id": sectionId,
      "lang": lang,
      "role": "user",  // الدور هنا هو "user"
      "t_id": 14       // t_id=14 خاص بالأنشطة
    }),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    // تعديل كل عنصر ليحتوي على URL الصورة وتاريخ الإنشاء
    return data.map((activity) {
      activity['file_path'] = '$_imageBaseUrl${activity['file_path']}';  // مسار الصورة الكامل
      return activity;
    }).toList();
  } else {
    throw Exception('Failed to load activities');
  }
}




Future<List<dynamic>> other({required String sectionId, required String lang}) async {
  final response = await http.post(
    Uri.parse(_baseUrl),  // استخدم POST مع URL الأساسي
    headers: {"Content-Type": "application/json"},  // تحديد نوع المحتوى كـ JSON
    body: jsonEncode({
      "action": "getContent",
      "section_id": sectionId,
      "lang": lang,
      "role": "user",  // الدور هنا هو "user"
      "t_id": 15       // t_id=15 للبيانات الأخرى
    }),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    // تعديل كل عنصر ليحتوي على URL الصورة وتاريخ الإنشاء
    return data.map((event) {
      event['file_path'] = '$_imageBaseUrl${event['file_path']}'; // إضافة المسار الكامل للصورة
      return event;
    }).toList();
  } else {
    throw Exception('Failed to load other events');
  }
}

}
