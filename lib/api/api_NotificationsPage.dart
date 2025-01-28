import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationsService {
  final String apiUrl = 'https://eyn.ur.gov.iq/api_staticcontent_user_admin.php';

// دالة لجلب جميع الإشعارات من الـ API
Future<List<dynamic>> fetchNotifications() async {
  final response = await http.post(
    Uri.parse(apiUrl),  // استبدل '$apiUrl' برابط الـ API الكامل
    headers: {
      "Content-Type": "application/json",
    },
    body: jsonEncode({
      "action": "getNotifications"
    }),
  );

  print('Response body: ${response.body}'); // طباعة الاستجابة للتحقق من المحتوى

  if (response.statusCode == 200) {
    final data = json.decode(response.body);

    // تحقق إذا كانت الاستجابة قائمة
    if (data is List) {
      return data;
    } else if (data is Map && data.containsKey('error')) {
      throw Exception(data['error']);  // إذا كانت الاستجابة تحتوي على خطأ
    } else {
      throw Exception('Unexpected response format');
    }
  } else {
    throw Exception('Failed to load notifications');
  }
}





  // دالة للتحقق من وجود إشعارات غير مقروءة
Future<bool> checkUnreadNotifications() async {
  try {
    // إرسال طلب POST مع body يحتوي على action
    final response = await http.post(
      Uri.parse(apiUrl),  // يُرسل الطلب إلى الرابط بدون action في الـ URL
      headers: {"Content-Type": "application/json"},  // تحديد نوع المحتوى كـ JSON
      body: jsonEncode({
        "action": "getNotifications"  // إرسال action في body
      }),
    );

    if (response.statusCode == 200) {
      List<dynamic> notifications = jsonDecode(response.body);

      // تحقق من وجود إشعارات غير مقروءة
      return notifications.any((notification) => notification['status'] == 'unread');
    } else {
      throw Exception('Failed to fetch notifications');
    }
  } catch (e) {
    print('Error fetching notifications: $e');
    return false;
  }
}






  // دالة لحذف الإشعار من قاعدة البيانات
Future<void> deleteNotification(int notificationId) async {
  // طباعة notificationId للتحقق منه
  print('Notification ID to delete: $notificationId');

  final response = await http.post(
    Uri.parse(apiUrl),  // تأكد من أن $apiUrl هو رابط الـ API الكامل
    headers: {
      "Content-Type": "application/json",
    },
    body: jsonEncode({
      "action": "deleteNotification",
      "notification_id": notificationId
    }),
  );

  print('Response body: ${response.body}');  // طباعة الاستجابة للتحقق

  if (response.statusCode != 200) {
    throw Exception('Failed to delete notification');
  }
}







  // دالة لتحديث جميع الإشعارات إلى "read"
Future<void> markAllAsRead() async {
  final response = await http.post(
    Uri.parse(apiUrl),  // هنا يُرسل الطلب إلى الرابط بدون action في الـ URL
    headers: {"Content-Type": "application/json"},  // تحديد نوع المحتوى كـ JSON
    body: jsonEncode({
      "action": "markAllAsRead"  // إرسال action في body
    }),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to mark all notifications as read');
  }
}





  // دالة لحذف الإشعارات المقروءة التي مر عليها أكثر من 7 أيام
  Future<void> deleteOldReadNotifications() async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'action': 'deleteOldReadNotifications', // تحديد action الصحيح
        }),
      );

      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        if (responseBody['success'] == true) {
          print('Old read notifications deleted successfully');
        } else {
          print('Failed to delete old read notifications: ${responseBody['error']}');
        }
      } else {
        print('Failed to connect to API: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting old read notifications: $e');
    }
  }
}
