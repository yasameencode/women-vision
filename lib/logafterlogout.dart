import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:merge_voice_coplain/theme/appcolors.dart';

class LogAfterLogoutPage extends StatelessWidget {
  const LogAfterLogoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // تعيين الخلفية إلى اللون الأبيض
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // شعار في المنتصف
            SvgPicture.asset(
              'assets/images/wlogo.png', // تأكد من أن هذا هو المسار الصحيح للشعار
              height: 150,
              width: 150,
            ),
            const SizedBox(height: 40),
            // زر الدخول إلى التطبيق
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/'); // العودة إلى الصفحة الرئيسية أو أي صفحة أخرى
              },
            style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(AppColors.buttonColor), // لون خلفية الزر
                foregroundColor: WidgetStateProperty.all(Colors.white), // لون نص الزر
                padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
                textStyle: WidgetStateProperty.all(const TextStyle(fontSize: 16)),
              ),
              child: const Text('الدخول إلى التطبيق'),
            ),
          ],
        ),
      ),
    );
  }
}
