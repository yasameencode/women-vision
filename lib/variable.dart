import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uni_links2/uni_links.dart'; // تأكد من استيراد uni_links2
import 'api/user_api.dart';
import 'theme/appcolors.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'GuestPage.dart';
import 'package:flutter/services.dart';
import 'dart:io';


class VariablePage extends StatefulWidget {
  final int userType; // استلام رقم المستخدم
  final VoidCallback togglePage; // التبديل بين الصفحات

  const VariablePage({super.key, required this.togglePage, required this.userType});

  @override
  _VariablePageState createState() => _VariablePageState();
}

class _VariablePageState extends State<VariablePage> {
   static const platform = MethodChannel('com.yourapp.channel/universal_links'); 
  final ApiService apiService = ApiService();
  StreamSubscription? _sub;
  String? receivedCode;
    String? accessToken;
  String? userInfo;

  @override
  void initState() {
    super.initState();
    _initDeepLinkListener();
    _setupMethodChannelListener();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

void _initDeepLinkListener() {
  _sub = uriLinkStream.listen((Uri? uri) {
    if (uri != null) {
      final code = uri.queryParameters['code'];
      if (code != null) {
        print('Received code from deep link: $code');
        setState(() {
          receivedCode = code;
        });
        _sendCodeToApi(code); // إرسال الكود إلى API
      } else {
        print('No "code" parameter found in the URI.');
      }
    }
  }, onError: (err) {
    print('Failed to receive link: $err');
  });
}


void _setupMethodChannelListener() {
  platform.setMethodCallHandler((MethodCall call) async {
    if (call.method == "onReceivedCode") {
      final String? code = call.arguments;
      if (code != null) {
        print('Received code from iOS: $code');
        setState(() {
          receivedCode = code;
        });
        _sendCodeToApi(code); // إرسال الكود إلى الخادم
      } else {
        print("No code received.");
      }
    }
  });
}









  Future<void> _register(BuildContext context) async {
    const urlString = 'https://ur.gov.iq/verify-auth?client_id=212&redirect_uri=https://eyn.ur.gov.iq/callback.php/';
    final Uri url = Uri.parse(urlString);

    if (Platform.isIOS) {
      try {
        await platform.invokeMethod('openSafariView', {"url": urlString});
      } catch (e) {
        print('Failed to open Safari View Controller: $e');
        _showPopup(context, 'تعذر فتح الرابط. حاول مرة أخرى.', 'تم');
      }
    } else {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        _showPopup(context, 'تعذر فتح الرابط. حاول مرة أخرى.', 'تم');
      }
    }
  }

  void _showPopup(BuildContext context, String message, String buttonText) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.tajawal(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: AppColors.headerColor,
            ),
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  buttonText,
                  style: GoogleFonts.tajawal(
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: AppColors.buttonColor,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }



Future<void> _sendCodeToApi(String code) async {
  try {
    final url = Uri.parse('https://ur.gov.iq/api/oauth/token');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "code": code,
        "grant_type": "authorization_code",
        "client_secret": "ujtgthFZZVTPHzCg5NkOD40c1DKQPcMnA8am0fAT",
        "client_id": 212,
        "redirect_uri": "https://eyn.ur.gov.iq/callback.php/",
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);

      // التحقق من وجود access_token في الرد
      final String? accessToken = responseData['access_token'];
      if (accessToken != null) {
        print('Access Token: $accessToken');

        // تخزين الـ accessToken في SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', accessToken);

        print('Access Token stored successfully.');

        // استدعاء معلومات المستخدم
        _getUserInfo();
      } else {
        print('Access Token not found in the response.');
      }
    } else {
      print('Failed to get access token. Status: ${response.statusCode}, Response: ${response.body}');
    }
  } catch (e) {
    print('Error occurred while sending code to API: $e');
  }
}



Future<void> _getUserInfo() async {
  try {
    // Retrieve the accessToken from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final storedAccessToken = prefs.getString('accessToken');

    if (storedAccessToken == null) {
      print('Access Token not found in SharedPreferences.');
      return;
    }

    print('Using Access Token: $storedAccessToken');

    final url = Uri.parse('https://ur.gov.iq/api/client/user/show/allInfo');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $storedAccessToken',
      },
    );

    if (response.statusCode == 200) {
      print('User Info Retrieved: ${response.body}');
      final responseData = jsonDecode(response.body);

      // Check if user data is available
      final userData = responseData['data'];
      if (userData != null) {
        await _sendUserDataToApi(userData);
      } else {
        print('No user data found in the response.');
      }
    } else {
      print('Failed to retrieve user info. Status: ${response.statusCode}, Response: ${response.body}');
    }
  } catch (e) {
    print('Error in _getUserInfo: $e');
  }
}




Future<void> _sendUserDataToApi(Map<String, dynamic> userData) async {
  final url = Uri.parse('https://eyn.ur.gov.iq/api_user.php');
  try {
    final userId = userData['ur_id'];
    final firstName = userData['first_name'] ?? '';
    final middleName = userData['middle_name'] ?? '';
    final lastName = userData['last_name'] ?? '';
    final fullName = "$firstName $middleName $lastName".trim();
    final email = userData['email'];
    final phoneNum = userData['phone_num'];

    if (userId == null) {
      print('Invalid user_id');
      return;
    }

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "action": "saveUserData",
        "user_id": userId,
        "full_name": fullName,
        "email": email,
        "phone_num": phoneNum,
      }),
    );

    if (response.statusCode == 200) {
      print('User data sent successfully: ${response.body}');

      // تخزين user_id في SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_id', userId);

      // الانتقال إلى صفحة /cards
      Navigator.of(context).pushNamed('/cards');
    } else {
      print('Failed to send user data. Status: ${response.statusCode}, Response: ${response.body}');
    }
  } on TimeoutException catch (e) {
    print('Request timed out: $e');
  } catch (e) {
    print('An error occurred: $e');
  }
}



  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.5,
      child: Center(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.backgroundColor,
            borderRadius: BorderRadius.circular(32),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                width: 72,
                height: 24,
                child: SvgPicture.asset(
                  'assets/images/network.svg',
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'يجب تسجيل الدخول اولاً',
                  style: GoogleFonts.tajawal(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    height: 1.6,
                    color: const Color(0xFFD92D20),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                child: Text(
                  'تحتاج الى تسجيل حساب للوصول الى معلومات هذه الصفحة يمكنك تسجيل حساب عبر الزر الموجود في الاسفل',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.tajawal(
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    height: 1.6,
                    letterSpacing: 0.3,
                    color: AppColors.textColor,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 7),
                Expanded(
  child: GestureDetector(
    onTap: () => _register(context),
    child: Container(
      decoration: BoxDecoration(
        color: AppColors.buttonColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        child: Center(
          child: Text(
            'تسجيل دخول',
            style: GoogleFonts.tajawal(
              fontWeight: FontWeight.w400,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
      ),
    ),
  ),
),
const SizedBox(height: 16), // إضافة مسافة بين الزرين
Expanded(
  child: GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(), // استبدل بـ الصفحة المطلوبة
        ),
      );
    },
    child: Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade300, // لون مختلف لتمييز الزر
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        child: Center(
          child: Text(
            'صفحة الضيف',
            style: GoogleFonts.tajawal(
              fontWeight: FontWeight.w400,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ),
      ),
    ),
  ),
),


                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
























