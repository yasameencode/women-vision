import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:merge_voice_coplain/infoAR.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'variable.dart';
import 'theme/appcolors.dart';
import 'buttomnav.dart';
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
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
 List<String> images = [];
 
 @override
  void initState() {
    super.initState();
    _loadUserId(); 
   _fetchImages();
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
          case 'الفريق الوطني':
        userType = 14;
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
        case 'الفريق الوطني':
        route = '/national_team';
        break;
    }

    // setState(() {
    //   _isLoading = false;
    // });

    if (title == 'اخبار' || title == 'صحة المرأة' || title == 'التدريب' || title == 'الصحة  النفسية والاسرية' || title == 'الفريق الوطني' || title == 'كفاءة متميزة' || title == 'وطني' || userId != null) {
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




Future<void> _fetchImages() async {
  try {
    final response = await http.post(
      Uri.parse('https://eyn.ur.gov.iq/api_staticcontent_user_admin.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'action': 'getad', // تحديد الإجراء المطلوب
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        images = List<String>.from(data['images']); // استخراج الصور من الاستجابة
      });
    } else {
      print('Failed to load images. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: userId != null
                  ? PopupMenuButton<int>(
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
                      MaterialPageRoute(
                          builder: (context) => const Infoar()),
                    );
                  }
                },
              )
                  : const SizedBox.shrink(), // Empty widget if userId is null
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/zahaintro.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
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
                const SizedBox(height: 10),
                // Add the slider here
                CarouselSlider(
  items: images.map((imagePath) { // الصور يتم جلبها من قائمة "images" التي تحتوي على البيانات من API
    return Builder(
      builder: (BuildContext context) {
        return Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.symmetric(horizontal: 5.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              image: NetworkImage('https://eyn.ur.gov.iq/$imagePath'), // تحميل الصور ديناميكيًا من الإنترنت
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }).toList(),
  options: CarouselOptions(
    height: MediaQuery.of(context).size.height * 0.3,
    autoPlay: true,
    enlargeCenterPage: true,
    aspectRatio: MediaQuery.of(context).size.width > 600 ? 16 / 9 : 4 / 3,
    viewportFraction: MediaQuery.of(context).size.width > 600 ? 0.8 : 0.9,
  ),
),


                const SizedBox(height: 20),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 11,
                    childAspectRatio: 1.5,
                    children: [
                      _buildCard(
                          'الشكوى',
                          'assets/images/complaint_2025.svg',
                          const Color(0xFFF9F9F9),
                          const Color(0xFF36623F)),
                      _buildCard(
                          'استشارات قانونية',
                          'assets/images/Legal_consultations_2025.svg',
                          const Color(0xFFF9F9F9),
                          const Color(0xFF36623F)),
                      _buildCard(
                          'كفاءة متميزة',
                          'assets/images/Outstanding efficiency_2025..svg',
                          const Color(0xFFF9F9F9),
                          const Color(0xFF36623F)),
                      _buildCard(
                          'صحة المرأة',
                          'assets/images/health_2025..svg',
                          const Color(0xFFF9F9F9),
                          const Color(0xFF36623F)),
                      _buildCard(
                          'الصحة النفسية والاسرية',
                          'assets/images/Mental_and_family_health_2025..svg',
                          const Color(0xFFF9F9F9),
                          const Color(0xFF36623F)),
                      _buildCard(
                          'التدريب',
                          'assets/images/training_2025..svg',
                          const Color(0xFFF9F9F9),
                          const Color(0xFF36623F)),
                      _buildCard(
                          'وطني',
                          'assets/images/patriotic_2025.svg',
                          const Color(0xFFF9F9F9),
                          const Color(0xFF36623F)),
                      _buildCard(
                          'قصص النجاح',
                          'assets/images/success story_2025..svg',
                          const Color(0xFFF9F9F9),
                          const Color(0xFF36623F)),
                      _buildCard(
                          'اخبار',
                          'assets/images/news_2025..svg',
                          const Color(0xFFF9F9F9),
                          const Color(0xFF36623F)),
                      _buildCard2(
  'الفريق الوطني',
  'assets/images/yasa.png',
  const Color.fromARGB(255, 249, 249, 249),
  const Color(0xFF36623F),
),

                      _buildCard(
                          'مقترحاتي',
                          'assets/images/Suggestions_2025..svg',
                          const Color(0xFFF9F9F9),
                          const Color(0xFF36623F)
                          ),
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


  Widget _buildCard2(
    String title, String imageAsset, Color cardColor, Color textColor) {
  return GestureDetector(
    onTap: () => _checkUserAndNavigate(title),
    child: Card(
      color: cardColor.withOpacity(1),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              imageAsset,
              height: 40,
              width: 40,
              fit: BoxFit.contain, // لضمان عرض الصورة بدون قص
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 13,
                color: textColor, // لون النص
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
