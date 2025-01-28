import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:merge_voice_coplain/theme/appcolors.dart';
import 'api/user_api.dart';

final ApiService apiService = ApiService();

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  @override
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  // TextEditingControllers to capture input
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Function to handle login
Future<void> _login(BuildContext context) async {
  String phone = phoneController.text; // Get phone input
  String password = passwordController.text; // Get password input

  bool success = await apiService.loginUser(phone, password); // Use inputs for login
  if (success) {
    Navigator.pushNamed(context, '/cards'); // الانتقال إلى صفحة /cards عند نجاح تسجيل الدخول
  } else {
    // Handle login failure
    print('Login failed');
    _showPopup(context, 'فشل تسجيل الدخول، حاول مرة أخرى', 'خطأ'); // عرض رسالة خطأ
    Navigator.pushNamed(context, '/login'); // إعادة توجيه المستخدم إلى صفحة تسجيل الدخول
  }
}

void _showPopup(BuildContext context, String message, String title) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('تم'),
            onPressed: () {
              Navigator.of(context).pop(); // إغلاق النافذة المنبثقة
            },
          ),
        ],
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFFFCFDFF),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 60, 19, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 70.7),
                    child: Column(
                      children: [
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'عين المرأة',
                                style: GoogleFonts.arefRuqaa(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 36,
                                  letterSpacing: 0.2,
                                  color: const Color(0xFF4e4e4e),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Image.asset(
                                'assets/images/wlogo.png',
                                width: 99.3,
                                height: 42,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 13),
                        Text(
                          'تسجيل الدخول للوصول الى كافة المميزات المتاحة في التطبيق',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.tajawal(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            height: 1.4,
                            letterSpacing: 0.3,
                            color: const Color(0xFF756F6F),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    margin: const EdgeInsets.only(bottom: 69.7),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Phone number input field
                        buildInputField(
                          'اسم المستخدم',
                          const Icon(Icons.person,
                              size: 24,
                              color: Color(
                                  0xFFB2B2B2)), // تغيير الأيقونة إلى Icons.person
                          phoneController, // Bind phoneController
                        ),

                        const SizedBox(height: 25),
                        // Password input field
                        buildInputField(
                          'كلمة السر',
                          const Icon(Icons.lock, size: 24, color: Color(0xFFB2B2B2)),
                          passwordController, // Bind passwordController
                        ),
                        const SizedBox(height: 21),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'نسيتِ كلمة المرور ؟',
                              style: GoogleFonts.tajawal(
                                fontWeight: FontWeight.w400,
                                fontSize: 9,
                                color: const Color(0xFF6C63FF),
                              ),
                            ),
                            // Row(
                            //   children: [
                            //     Text(
                            //       'تذكر معلوماتي',
                            //       style: GoogleFonts.tajawal(
                            //         fontWeight: FontWeight.w400,
                            //         fontSize: 9,
                            //         color: Color(0xFF252525),
                            //       ),
                            //     ),
                            //     SizedBox(width: 5.5),
                            //     Container(
                            //       width: 12,
                            //       height: 12,
                            //       decoration: BoxDecoration(
                            //         border:
                            //             Border.all(color: Color(0xFFCBCBCB)),
                            //         borderRadius: BorderRadius.circular(3),
                            //       ),
                            //     ),
                            //   ],
                            // ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.buttonColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextButton(
                      onPressed: () {
                        _login(context); // Call login function on button press
                      },
                      child: Center(
                        child: Text(
                          'التالي',
                          style: GoogleFonts.tajawal(
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        color: const Color(0xFF252525),
                      ),
                      children: [
                        TextSpan(
                          text: 'عضوة جديدة؟',
                          style: GoogleFonts.tajawal(
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                            height: 1.3,
                          ),
                        ),
                        const TextSpan(text: ' '),
                        TextSpan(
                          //يذهب الى صفحةاور
                          text: 'تسجيل حساب ',
                          style: GoogleFonts.tajawal(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            height: 1.3,
                            color: const Color(0xFF6C63FF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Build input field with a controller to capture input
  Widget buildInputField(
      String labelText, Widget icon, TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9),
        color: const Color(0xFFFFFFFF),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            offset: Offset(0, 2),
            blurRadius: 9.45,
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(22, 9, 18, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          icon,
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: labelText,
                hintStyle: GoogleFonts.tajawal(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  height: 2.3,
                  letterSpacing: 0.2,
                  color: const Color(0xFFB2B2B2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
