import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:merge_voice_coplain/api/api_NotificationsPage.dart';
import 'package:merge_voice_coplain/api/user_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool hasUnreadNotifications = false;
  final NotificationsService notificationsService =
      NotificationsService(); // استدعاء NotificationsService
  String fullName = ''; // متغير لتخزين الاسم
  String email = ''; // متغير لتخزين البريد الإلكتروني
  File? _selectedImage; // المتغير الذي سيخزن الصورة المختارة
  final ImagePicker _picker = ImagePicker();
  String? profileImagePath; // مسار الصورة
  final ApiService apiService = ApiService(); // استدعاء ApiService

  @override
  void initState() {
    super.initState();
    _checkUnreadNotifications(); // استدعاء الدالة للتحقق من الإشعارات
    _loadUserData(); // استدعاء الدالة لجلب البيانات
  }

  // دالة لجلب بيانات المستخدم من ApiService
Future<void> _loadUserData() async {
  final data = await apiService.fetchUserData();
  if (data != null) {
    print('User data: $data'); // طباعة البيانات للتأكد من الاستجابة
    setState(() {
      fullName = data['full_name'] ?? 'No name'; // تخزين الاسم
      email = data['email'] ?? 'No email'; // تخزين البريد الإلكتروني
      profileImagePath = data['profile_image']; // تخزين مسار الصورة
    });
  } else {
    print('No user data received.');
  }
}


  // دالة للتحقق من وجود إشعارات غير مقروءة
  Future<void> _checkUnreadNotifications() async {
    bool hasUnread = await notificationsService
        .checkUnreadNotifications(); // استخدام الدالة من NotificationsService
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

// دالة لاختيار الصورة من معرض الصور
  Future<void> _pickImage() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
      // رفع أو تحديث الصورة في الخادم
      await _uploadImage();
      // بعد الرفع، قم بتحديث واجهة المستخدم
      await _loadUserData();
    }
  }

  // دالة لرفع أو تحديث الصورة
Future<void> _uploadImage() async {
   if (_selectedImage != null) {
     bool success = await apiService.uploadImage(_selectedImage!);
     if (success) {
       print('Image uploaded successfully');
       await _loadUserData();  // تحديث بيانات المستخدم بعد رفع الصورة
     } else {
       print('Failed to upload image');
     }
   }
 }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed:
                _pickImage, // استدعاء اختيار الصورة عند الضغط على "تحرير"
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(20),
              alignment: Alignment.center,
              child: Column(
                children: <Widget>[
              Container(
  width: 100,
  height: 100,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    image: profileImagePath != null
        ? DecorationImage(
            image: NetworkImage(profileImagePath!),
            fit: BoxFit.cover,
          )
        : null,
  ),
  child: profileImagePath == null
      ? SvgPicture.asset(
          'assets/images/File searching-rafiki 1.svg',
          fit: BoxFit.cover,
        )
      : null,
),

                  const SizedBox(height: 10),
                  Text(
                    fullName, // عرض الاسم الكامل
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // تغيير لون النص إلى الأسود
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    email, // عرض البريد الإلكتروني
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black, // تغيير لون النص إلى الأسود
                    ),
                  ),
                ],
              ),
            ),
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
                      Navigator.pushReplacementNamed(
                          context, '/NotificationsPage');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('تسجيل الخروج'),
                    onTap: () {
                      _logout(); // استدعاء دالة تسجيل الخروج عند الضغط
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
