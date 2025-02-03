import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // استخدام مكتبة فحص الاتصال
import 'dart:async'; // استيراد StreamSubscription
import 'package:merge_voice_coplain/activities/activities.dart';
import 'package:merge_voice_coplain/efficiency/efficiant.dart';
import 'package:merge_voice_coplain/introduction.dart';
import 'package:merge_voice_coplain/logafterlogout.dart';
import 'package:merge_voice_coplain/my_suggestions/suggestions.dart';
import 'package:merge_voice_coplain/profile/notifications.dart';
import 'package:merge_voice_coplain/profile/setting.dart';
import 'package:merge_voice_coplain/psychological_consultation/selffamily.dart';
import 'package:uni_links2/uni_links.dart';
import './news/newsdetails (1).dart';
import 'package:merge_voice_coplain/women_helth.dart/womenhealth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'complain/comp_form.dart';
import 'complain/comp_list.dart';
import 'cards.dart';
import 'login.dart';
import 'legal_consul/legal_consul_list.dart';
import 'legal_consul/legal_consul.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'national_team.dart';
import 'success/success_stories.dart';
import 'courses/training.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './api/api_NotificationsPage.dart';
import '../theme/appcolors.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// إعداد إشعارات محلية
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // إعدادات iOS
  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings();

  // إعدادات Android
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  // إعدادات عامة
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  // تهيئة الإشعارات
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {
      print('Notification clicked with payload: ${notificationResponse.payload}');
    },
  );

  runApp(MyApp());
}

Future<void> onSelectNotification(String? payload) async {
  // منطقك لمعالجة النقر على الإشعار
  print('Notification clicked with payload: $payload');
}

// دالة لمعالجة الرسائل عند وصولها أثناء تشغيل التطبيق في الخلفية
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
}

class MyApp extends StatefulWidget {
  static final GlobalKey<_MyAppState> globalKey = GlobalKey();

  MyApp() : super(key: globalKey);

  @override
  _MyAppState createState() => _MyAppState();

  static _MyAppState? of(BuildContext context) {
    return globalKey.currentState;
  }
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false;
  int? userId; // تعريف userId على مستوى الكلاس
  bool isConnected = true; // حالة الاتصال
  late StreamSubscription<ConnectivityResult> connectivitySubscription;
  final NotificationsService notificationsService =
      NotificationsService(); // إنشاء كائن من NotificationsService


  @override
  void initState() {
    super.initState();
    // _listenToConnectivityChanges(); 
    _loadThemePreference(); // تحميل تفضيلات السمة
    _initFirebaseMessaging(); // تهيئة Firebase Messaging
    fetchAccessToken();
    _deleteOldReadNotifications(); // استدعاء الدالة عند فتح التطبيق
    _loadUserId(); // استدعاء الدالة لتحميل userId
    checkInternetConnection(); // فحص الاتصال عند بدء التطبيق
  }



// void _listenToConnectivityChanges() {
//   connectivitySubscription = Connectivity()
//       .onConnectivityChanged
//       .listen((ConnectivityResult result) {
//     setState(() {
//       isConnected = (result != ConnectivityResult.none); // التحقق من حالة الاتصال
//       if (!isConnected) {
//         showNoInternetDialog(); // إذا تم إطفاء الإنترنت، إظهار رسالة تنبيه
//       }
//     });
//   });
// }





  // فحص الاتصال بالإنترنت عند بدء التطبيق
  Future<void> checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      isConnected = (connectivityResult != ConnectivityResult.none);
      if (!isConnected) {
        showNoInternetDialog(); // إظهار رسالة تنبيه عند انقطاع الإنترنت
      }
    });
  }

// عرض رسالة تنبيه عند عدم وجود اتصال بالإنترنت
void showNoInternetDialog() {
  showDialog(
    context: context,
    barrierDismissible: false, // منع إغلاق الحوار عند النقر خارج النافذة
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // زوايا دائرية للإطار
      ),
      title: const Text(
        'لا يوجد اتصال بالإنترنت',
        style: TextStyle(fontWeight: FontWeight.bold), // تنسيق العنوان
      ),
      content: const Text(
        'يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.',
        textAlign: TextAlign.center, // جعل النص في المنتصف
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(), // إغلاق الرسالة
          child: const Text(
            'إغلاق',
            style: TextStyle(color: Colors.black), // لون النص
          ),
        ),
      ],
    ),
  );
}



  // استدعاء دالة حذف الإشعارات القديمة
  Future<void> _deleteOldReadNotifications() async {
    await notificationsService
        .deleteOldReadNotifications(); // استدعاء الدالة من NotificationsService عبر الكائن
  }

  // تحميل تفضيلات السمة من SharedPreferences
  Future<void> _loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }



  // تهيئة Firebase Messaging لاستقبال الإشعارات
Future<void> _initFirebaseMessaging() async {
 FirebaseMessaging messaging = FirebaseMessaging.instance;

  // طلب إذن الإشعارات
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

 if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('Permission granted');
    String? token = await messaging.getToken();
    if (token != null) {
      print('Device Token: $token');
      await _sendTokenToServer(token); // تمرير التوكن بعد التأكد أنه غير null
    } else {
      print('Token is null');
    }
  } else {
    print('Permission denied');
  }

  // التعامل مع الإشعارات الواردة أثناء فتح التطبيق
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Received a message: ${message.messageId}');
    if (message.notification != null) {
      String? title = message.notification!.title;
      String? body = message.notification!.body;

      _showNotification(title, body); // تمرير العنوان والمحتوى بعد التأكد من أنهما غير null
        }
  });
}


  // دالة لعرض الإشعارات المحلية
  Future<void> _showNotification(String? title, String? body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'Default_Sound',
    );
  }

  // دالة لتحميل userId من SharedPreferences
  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('user_id');
      print('Loaded userId: $userId'); // طباعة userId بعد تحميله
    });
  }

  Future<void> _sendTokenToServer(String token) async {
    final response = await http.post(
      Uri.parse(
          'https://eyn.ur.gov.iq/api_staticcontent_user_admin.php'), // رابط الخادم الخاص بك
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'action': 'store_device_token',
        'user_id':
            userId, // إذا كان userId موجودًا سيتم إرساله، وإلا سيتم إرسال null
        'device_token': token,
      }),
    );

    if (response.statusCode == 200) {
      print('Token stored successfully');
    } else {
      print('Failed to store token');
    }
  }


  Future<void> fetchAccessToken() async {
    try {
      final response = await http.post(
        Uri.parse('https://eyn.ur.gov.iq/api_staticcontent_user_admin.php'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'action': 'getAccessToken', // إرسال action في جسم الطلب
        }),
      );

      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        String accessToken = responseBody['access_token'] ?? '';
        print('Access Token: $accessToken');
      } else {
        print('Failed to fetch access token: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error fetching access token: $e');
    }
  }

  // تغيير السمة (الوضع الداكن/الفاتح)
  void changeTheme(bool isDark) {
    setState(() {
      isDarkMode = isDark;
    });
    _saveThemePreference(isDark); // حفظ التفضيلات
  }

  // حفظ تفضيلات السمة في SharedPreferences
  Future<void> _saveThemePreference(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
  }

  @override
  Widget build(BuildContext context) {
    if (!isConnected) {
      return MaterialApp(
        debugShowCheckedModeBanner: false, // Remove debug banner
        home: Scaffold(
          backgroundColor: Colors.black, // Background color for better visual appeal
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0), // Add padding for better spacing
              child: Container(
                padding: EdgeInsets.all(20.0), // Add padding inside the container
                decoration: BoxDecoration(
                  color: Colors.white, // White background for the message box
                  borderRadius: BorderRadius.circular(15.0), // Rounded corners
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 3,
                      blurRadius: 7,
                      offset: Offset(0, 3), // Shadow effect
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.wifi_off, // No internet connection icon
                      color: Colors.black,
                      size: 40.0, // Icon size
                    ),
                    SizedBox(height: 20), // Add space between icon and text
                    Text(
                      'نأسف لايوجد اتصال بألانترنت ..يرجى اعادة الاتصال والمحاولة مرة اخرى',
                      textAlign: TextAlign.center, // Center the text
                      style: TextStyle(
                        fontSize: 18.0, // Text size
                        fontWeight: FontWeight.bold, // Bold text
                        color: Colors.black, // Text color
                      ),
                    ),
                    SizedBox(height: 20), // Add space below the text
                    ElevatedButton(
                      onPressed: _retryConnection, // Function to retry connection
                      style: ElevatedButton.styleFrom(
                        backgroundColor:AppColors.primaryColor , // Button color
                        padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0), // Button padding
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0), // Rounded button
                        ),
                      ),
                      child: Text(
                        'إعادة الاتصال',
                        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold,
                          color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      // عرض شاشة تمنع المستخدم من استخدام التطبيق في حالة عدم وجود اتصال
      // return const MaterialApp(
      //   debugShowCheckedModeBanner: false,
      //   home: Scaffold(
      //     body: Center(
      //       child: Text('لا يوجد اتصال بالإنترنت. يرجى إعادة المحاولة لاحقًا.'),
      //     ),
      //   ),
      // );
    }

    return MaterialApp(
      locale: const Locale('ar'), // اللغة الافتراضية
      supportedLocales: const [
        Locale('en', ''), // الإنجليزية
        Locale('ar', ''), // العربية
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      title: 'عين المرأة',
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home:  const SplashOrLinkReceiver(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (context) => const LoginWidget(),
        '/cards': (context) => const CardsPage(),
        '/skip': (context) => const CardsPage(),
        '/complaints': (context) =>  ComplainPage(),
        '/complaints_list': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map?;
          final userType = args?['userType'] ?? 0;
          return ComplainListView(userType: userType);
        },
        '/legal_advice': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map?;
          final userType = args?['userType'] ?? 0;
          return LegalListView(userType: userType);
        },
        '/legal_consul': (context) => const LegalConsulPage(),
        '/StoriesPage': (context) => const StoriesPage(),
        '/suggestions': (context) => const suggestions(),
        '/logafterlogout': (context) => const LogAfterLogoutPage(),
        '/NewsDetailsPage': (context) => const NewsDetailsPage(),
        '/WhealthPage': (context) => const WhealthPage(),
        '/TrainingPage': (context) => const TrainingPage(),
        '/setting': (context) => const SettingsPage(),
        '/NotificationsPage': (context) => const NotificationsPage(),
        '/SelffamilyPage': (context) => const SelffamilyPage(),
        '/EfficiantPage': (context) => const EfficiantPage(),
        '/ActivitiesPage': (context) => const ActivitiesPage(),
        '/national_team': (context) => const national_team(),

      },
    );
  }
}

void _retryConnection() {
  // Logic to retry the connection
}





class SplashOrLinkReceiver extends StatefulWidget {
  const SplashOrLinkReceiver({super.key});

  @override
  _SplashOrLinkReceiverState createState() => _SplashOrLinkReceiverState();
}

class _SplashOrLinkReceiverState extends State<SplashOrLinkReceiver> {
  StreamSubscription? _sub;
  String? receivedCode;
  String? accessToken;
  String? userInfo;

  @override
  void initState() {
    super.initState();
    _initDeepLinkListener();
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
          _sendCodeToApi(code);
        }
      }
    }, onError: (err) {
      print('Failed to receive link: $err');
    });
  }

  Future<void> _sendCodeToApi(String code) async {
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
      accessToken = responseData['access_token'];
      print('Access Token: $accessToken');
      _getUserInfo();
    } else {
      print('Failed to get access token. Status: ${response.statusCode}, Response: ${response.body}');
    }
  }

Future<void> _getUserInfo() async {
  if (accessToken == null) return;
  
  final url = Uri.parse('https://ur.gov.iq/api/client/user/show/allInfo');
  final response = await http.get(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    },
  );

  if (response.statusCode == 200) {
    setState(() {
      userInfo = response.body;
    });
    print('User Info: ${response.body}');

    // استخراج بيانات المستخدم من حقل `data`
    final userData = jsonDecode(response.body)['data'];
    await _sendUserDataToApi(userData);
  } else {
    print('Failed to get user info. Status: ${response.statusCode}, Response: ${response.body}');
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
    ).timeout(const Duration(seconds: 15));

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
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: receivedCode == null 
      ? const SplashScreen() // عرض SplashScreen عند عدم وجود receivedCode فقط
      : const SizedBox.shrink(), // عرض عنصر فارغ في حالة وجود receivedCode
  );
}

}





