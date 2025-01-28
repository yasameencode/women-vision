import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'cards.dart'; // استيراد صفحة البطاقات

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;




Future<void> _login() async {
  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  final url = Uri.parse('https://eyn.ur.gov.iq/api_user.php');
  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "username": _usernameController.text.trim(),
      "password": _passwordController.text.trim(),
      "action": "login"
    }),
  );

  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');

  setState(() {
    _isLoading = false;
  });

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    if (data['success'] == true) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_id', data['user_id']); // تخزين user_id الحقيقي
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CardsPage()),
      );
    } else {
      setState(() {
        _errorMessage = data['message'];
      });
    }
  } else {
    setState(() {
      _errorMessage = "خطأ في الاتصال بالخادم. حاول مرة أخرى.";
    });
  }
}





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل الدخول'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'اسم المستخدم',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'كلمة المرور',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            if (_isLoading)
              const Center(child: CircularProgressIndicator()),
            if (!_isLoading)
              ElevatedButton(
                onPressed: _login,
                child: const Text('تسجيل الدخول'),
              ),
          ],
        ),
      ),
    );
  }
}
