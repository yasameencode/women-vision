import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_NotificationsPage.dart'; // تأكد من تعديل المسار الصحيح
import 'dart:convert';
import 'package:http/http.dart' as http;

class OptionPage extends StatefulWidget {
  const OptionPage({super.key});

  @override
  _OptionPageState createState() => _OptionPageState();
}

class _OptionPageState extends State<OptionPage> {
  bool hasUnreadNotifications = false;
  final NotificationsService notificationsService = NotificationsService(); // استدعاء NotificationsService

  @override
  void initState() {
    super.initState();
    _checkUnreadNotifications(); // استدعاء الدالة للتحقق من الإشعارات
  }

  // دالة للتحقق من وجود إشعارات غير مقروءة
  Future<void> _checkUnreadNotifications() async {
    bool hasUnread = await notificationsService.checkUnreadNotifications(); // استخدام الدالة من NotificationsService
    setState(() {
      hasUnreadNotifications = hasUnread;
    });
  }

  // دالة لتسجيل الخروج
Future<void> _logout() async {
  try {
    // الحصول على التوكن من SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final String? accessToken = prefs.getString('accessToken');

    if (accessToken != null) {
      // إرسال طلب الـ Logout
      final url = Uri.parse('https://ur.gov.iq/api/client/user/logout');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken', // إرسال التوكن في الهيدر
        },
      );

      // التحقق من حالة الرد وطباعة النتيجة
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Logout successful: $responseData');
      } else {
        print('Logout failed. Status: ${response.statusCode}, Response: ${response.body}');
      }
    } else {
      print('No Access Token found.');
    }
    // حذف التوكن والبيانات الأخرى
    await prefs.remove('accessToken');
    await prefs.remove('user_id');
    // إعادة التوجيه إلى صفحة تسجيل الخروج
    Navigator.pushReplacementNamed(context, '/logafterlogout');
  } catch (e) {
    print('Error occurred during logout: $e');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Row(
  children: [
    IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.of(context).pop();
      },
    ),
  ],
  
),

      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
      
            const Divider(),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('الاعدادات'),
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/setting');
                    },
                  ),
                  ListTile(
                    leading: Stack(
                      children: [
                        const Icon(Icons.notifications_active),
                        if (hasUnreadNotifications) // عرض الدائرة الحمراء إذا كانت هناك إشعارات غير مقروءة
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 12,
                                minHeight: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                    title: const Text('الاشعارات'),
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/NotificationsPage');
                    },
                  ),
                
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
