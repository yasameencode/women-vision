import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:merge_voice_coplain/infoAR.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'variable.dart';
import 'theme/appcolors.dart';
import 'buttomnav.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;

class CardsPage extends StatefulWidget {
  const CardsPage({super.key});

  @override
  _CardsPageState createState() => _CardsPageState();
}

class _CardsPageState extends State<CardsPage> {
  int _selectedIndex = 0;
  // bool _isLoading = false;
  String lang = 'ar';
    int? userId; // To store the userId
 @override
  void initState() {
    super.initState();
    _loadUserId(); // Load userId when the widget initializes
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('user_id');
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _checkUserAndNavigate(String title) async {
    // setState(() {
    //   _isLoading = true;
    // });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');
    int userType = 0;
    switch (title) {
      case 'الشكوى':
        userType = 8;
        break;
      case 'استشارات قانونية':
        userType = 7;
        break;
      case 'قصص النجاح':
        userType = 12;
        break;
      case 'مقترحاتي':
        userType = 13;
        break;
      case 'اخبار':
        userType = 9;
        break;
      case 'صحة المرأة':
        userType = 10;
        break;
      case 'التدريب':
        userType = 5;
        break;
          case 'الصحة النفسية والاسرية':
        userType = 6;
        break;
          case 'كفاءة متميزة':
        userType = 3;
        break;
          case 'وطني':
        userType = 11;
        break;
      default:
        return;
    }

    // تحديد المسار بناءً على title
    String route = '';
    switch (title) {
      case 'الشكوى':
        route = '/complaints_list';
        break;
      case 'استشارات قانونية':
        route = '/legal_advice';
        break;
      case 'قصص النجاح':
        route = '/StoriesPage';
        break;
      case 'مقترحاتي':
        route = '/suggestions';
        break;
      case 'اخبار':
        route = '/NewsDetailsPage';
        break;
      case 'صحة المرأة':
        route = '/WhealthPage';
        break;
          case 'التدريب':
        route = '/TrainingPage';
        break;
          case 'الصحة النفسية والاسرية':
        route = '/SelffamilyPage';
        break;
          case 'كفاءة متميزة':
        route = '/EfficiantPage';
        break;
          case 'وطني':
        route = '/ActivitiesPage';
        break;
    }

    // setState(() {
    //   _isLoading = false;
    // });

    if (title == 'اخبار' || title == 'صحة المرأة' || title == 'التدريب' || title == 'الصحة  النفسية والاسرية' || title == 'كفاءة متميزة' || title == 'وطني' || userId != null) {
      Navigator.pushNamed(
        context,
        route,
        arguments: {'userType': userType},
      );
    } else {
      _showVariablePage(userType);
    }
  }

  void _showVariablePage(int userType) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => VariablePage(
        togglePage: () => Navigator.of(context).pop(),
        userType: userType,
      ),
    );
  }



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
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white, // تعيين لون الخلفية إلى الأبيض
        elevation: 0, // إزالة الظل إذا كان موجودًا
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Logo on the left
            const CircleAvatar(
              backgroundColor: Colors.white, // تعيين لون الخلفية إلى الأبيض
              radius: 20,
              child: CircleAvatar(
                backgroundColor: AppColors.backgroundColor,
                backgroundImage: AssetImage('assets/images/wlogo.png'),
                radius: 18,
              ),
            ),
            const Text(
              'عين المرأة',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            // PopupMenuButton on the right
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: userId != null
            ?  PopupMenuButton<int>(
  icon: SvgPicture.asset(
    'assets/images/menu.svg',
    width: 24,
    height: 24,
    color: AppColors.secondaryColor,
  ),
  itemBuilder: (context) => [
    const PopupMenuItem(
      value: 1,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.logout, color: Colors.black),
          SizedBox(width: 8),
          Text('تسجيل خروج'),
        ],
      ),
    ),
    const PopupMenuItem(
      value: 2,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, color: Colors.black),
          SizedBox(width: 8),
          Text('عن التطبيق'),
        ],
      ),
    ),
  ],
  onSelected: (value) {
    if (value == 1) {
      _logout();
    } else if (value == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>const Infoar()),
      );
    }
  },
) // Conditionally show the logout option
                  // ? PopupMenuButton<int>(
                  //     icon: SvgPicture.asset(
                  //       'assets/images/menu.svg',
                  //       width: 24,
                  //       height: 24,
                  //       color: AppColors.secondaryColor,
                  //     ),
                  //     itemBuilder: (context) => [
                  //       const PopupMenuItem(
                  //         value: 1,
                  //         child: Row(
                  //           mainAxisAlignment: MainAxisAlignment.center,
                  //           children: [
                  //             Icon(Icons.logout, color: Colors.black),
                  //             SizedBox(width: 8),
                  //             Text('تسجيل خروج'),
                  //           ],
                  //         ),
                  //       ),
                  //     ],
                  //     onSelected: (value) {
                  //       if (value == 1) {
                  //         _logout();
                  //       }
                  //     },
                  //   )
                  : const SizedBox.shrink(), // Empty widget if userId is null
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/backgroun.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // White background container
          Container(
            color: Colors.white.withOpacity(0.8),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              textDirection: TextDirection.rtl,
              children: [
                const Text(
                  'مرحبآ',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'بماذا يمكننا مساعدتك اليوم ؟',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child:  // إذا كان هناك تحميل، عرض مؤشر الدوران
                     GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 11,
                          childAspectRatio: 1.5,
                          children: [
                            _buildCard(
                                'الشكوى',
                                'assets/images/complain_icon.svg',
                                const Color(0xFFF9F9F9),
                                const Color(0xFF36623F)),
                            _buildCard(
                                'استشارات قانونية',
                                'assets/images/low_icon.svg',
                                const Color(0xFFF9F9F9),
                                const Color(0xFF36623F)),
                            _buildCard(
                                'كفاءة متميزة',
                                'assets/images/efficiancycard.svg',
                                const Color(0xFFF9F9F9),
                                const Color(0xFF36623F)),
                            _buildCard(
                                'صحة المرأة',
                                'assets/images/healthcard.svg',
                                const Color(0xFFF9F9F9),
                                const Color(0xFF36623F)),
                            _buildCard(
                                'الصحة النفسية والاسرية',
                                'assets/images/selfcard.svg',
                                const Color(0xFFF9F9F9),
                                const Color(0xFF36623F)),
                            _buildCard(
                                'التدريب',
                                'assets/images/traincard.svg',
                                const Color(0xFFF9F9F9),
                                const Color(0xFF36623F)),
                            _buildCard(
                                'وطني',
                                'assets/images/adscard.svg',
                                const Color(0xFFF9F9F9),
                                const Color(0xFF36623F)),
                            _buildCard(
                                'قصص النجاح',
                                'assets/images/success_icon.svg',
                                const Color(0xFFF9F9F9),
                                const Color(0xFF36623F)),
                            _buildCard(
                                'اخبار',
                                'assets/images/newscard.svg',
                                const Color(0xFFF9F9F9),
                                const Color(0xFF36623F)),
                            _buildCard(
                                'مقترحاتي',
                                'assets/images/compcard.svg',
                                const Color(0xFFF9F9F9),
                                const Color(0xFF36623F)),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
          lang: lang,

        ),
    );
  }

  Widget _buildCard(
      String title, String svgAsset, Color cardColor, Color svgColor) {
    return GestureDetector(
      onTap: () => _checkUserAndNavigate(title),
      child: Card(
        color: cardColor.withOpacity(1),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                svgAsset,
                height: 40,
                width: 40,
                color: svgColor,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 13,
                  color: svgColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
