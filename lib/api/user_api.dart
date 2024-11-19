import 'dart:convert';
import 'dart:io'; // لإدارة ملفات الصور
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'dart:async';

// import 'package:path/path.dart'; // للحصول على اسم الملف

class ApiService {
  final String baseUrl =
      "https://eyn.ur.gov.iq/api_user.php";
      //  final String _imageBaseUrl = "https://eyn.ur.gov.iq"; // مسار الخادم


Future<bool> registerUser(String username, String password, String gmail,
    String fullname, String phoneNum, String sectionsId) async {
  final response = await http.post(
    Uri.parse(baseUrl),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "action": "addUser",
      "username": username,
      "password": password,
      "gmail": gmail,
      "fullname": fullname,
      "phone_num": phoneNum,
      "sections_id": sectionsId,
    }),
  );

  print('Response body: ${response.body}');

  try {
    final data = jsonDecode(response.body);
    if (data['success']) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_id', data['user_id']);
      return true;
    } else {
      return false;
    }
  } catch (e) {
    print('Error decoding JSON: $e');
    return false;
  }
}
  

Future<bool> loginUser(String username, String password) async {
  // إرسال طلب تسجيل الدخول
  final response = await http.post(
    Uri.parse(baseUrl),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "action": "login",
      "username": username,
      "password": password,
    }),
  );

  print('Response body: ${response.body}');

  try {
    // تحليل الاستجابة JSON
    final data = jsonDecode(response.body);

    // تحقق من النجاح
    if (data['success'] == true) {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // التحقق من وجود access_token و refresh_token قبل تخزينهما
      // if (data['access_token'] != null && data['refresh_token'] != null) {
        await prefs.setInt('user_id', data['user_id']);
        // await prefs.setString('token', data['access_token']); // تخزين الـ access token
        // await prefs.setString('refresh_token', data['refresh_token']); // تخزين الـ refresh token
        return true;
      // } else {
      //   print('Access token or refresh token is missing');
      //   return false;
      // }
    } else {
      print('Login failed: ${data['message']}');
      return false;
    }
  } catch (e) {
    print('Error decoding JSON: $e');
    return false;
  }
}


Future<void> checkAndRefreshToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? accessToken = prefs.getString('token');
  String? refreshToken = prefs.getString('refresh_token');

  if (accessToken != null) {
    // تحقق من انتهاء صلاحية التوكن
    bool isExpired = isTokenExpired(accessToken);
    if (isExpired) {
      print('Access token is expired.');
      if (refreshToken != null) {
        // استدعاء دالة تجديد التوكن
        await refreshAccessToken(refreshToken);
        print('Access token has been refreshed.');
      } else {
        print('No refresh token available.');
      }
    } else {
      print('Access token is still valid.');
    }
  } else {
    print('No access token available.');
  }
}

// دالة للتحقق من انتهاء صلاحية التوكن
bool isTokenExpired(String token) {
  // استخدام jwt_decoder للتحقق من انتهاء صلاحية التوكن
  return JwtDecoder.isExpired(token);  // سيتم إرجاع true إذا كان التوكن منتهي الصلاحية
}



Future<void> refreshAccessToken(String refreshToken) async {
  final response = await http.post(
    Uri.parse(baseUrl),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "action": "refreshToken",
      "refresh_token": refreshToken,
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data['success']) {
      // احفظ الـ access token الجديد
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['access_token']);
      print('New access token: ${data['access_token']}');
    } else {
      print('Failed to refresh token: ${data['error']}');
    }
  } else {
    print('Request failed with status: ${response.statusCode}');
  }
}


Future<Map<String, dynamic>?> fetchUserData() async {
  // احصل على SharedPreferences instance
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? userId = prefs.getInt('user_id');

  if (userId != null) {
    // إرسال الطلب بدون التوكن
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "action": "getUserData",
        "user_id": userId,
        "role": "user",
      }),
    );

  if (response.statusCode == 200) {
  try {
    if (response.headers['content-type'] == 'application/json') {
      final data = jsonDecode(response.body);
      print('Data received: $data'); // إضافة الطباعة هنا
      if (data['error'] == null) {
        return data;
      } else {
        print('Error: ${data['error']}');
      }
    } else {
      print('Non-JSON response received: ${response.body}');
    }
  } catch (e) {
    print('Error decoding JSON: $e');
  }
} else {
  print('Failed to fetch user data');
}


  } else {
    print('No user ID found in SharedPreferences.');
  }
  return null;
}




Future<bool> uploadImage(File imageFile) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? userId = prefs.getInt('user_id');

  if (userId == null) {
    print('No user ID found in SharedPreferences.');
    return false;
  }

  if (!imageFile.existsSync()) {
    print('Image file does not exist');
    return false;
  }

  var request = http.MultipartRequest('POST', Uri.parse(baseUrl));

  // إضافة الحقول
  request.fields['action'] = 'uploadProfileImage';
  request.fields['user_id'] = userId.toString();

  // إزالة الهدر Authorization المتعلق بالتوكن
  request.headers['Content-Type'] = 'multipart/form-data';
  request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

  try {
    var response = await request.send();
    var responseBody = await response.stream.bytesToString();

    print('Response status code: ${response.statusCode}');
    print('Response body: $responseBody');

    // التحقق من أن الرد بصيغة JSON
    if (response.statusCode == 200) {
      try {
        var jsonResponse = jsonDecode(responseBody);
        if (jsonResponse['success'] == true) {
          print('Image uploaded successfully: ${jsonResponse['message']}');
          return true;
        } else {
          print('Failed to upload image: ${jsonResponse['error']}');
          return false;
        }
      } catch (e) {
        print('Error parsing JSON: $e');
        return false;
      }
    } else {
      print('Failed to upload image. Status code: ${response.statusCode}');
      return false;
    }
  } catch (e) {
    print('Error occurred while sending request: $e');
    return false;
  }
}



}
