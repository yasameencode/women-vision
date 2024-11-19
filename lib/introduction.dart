import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';  // أضف هذه السطر
import 'theme/appcolors.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Onboarding',
//       theme: ThemeData(
//         primarySwatch: Colors.purple,
//       ),
//       home: const SplashScreen(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const OnboardingPageView()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 250,
              height: 200,
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              child: SvgPicture.asset(
                'assets/images/wilogo.svg',
                fit: BoxFit.contain,
              ),
            ),
            Text(
              'عين المرأة',
              style: GoogleFonts.arefRuqaa(
                fontWeight: FontWeight.w700,
                fontSize: 60,
                height: 1.6,
                color: AppColors.buttonColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'رؤيتك نحو التمكين والتغيير',
              style: GoogleFonts.arefRuqaa(
                fontWeight: FontWeight.w400,
                fontSize: 30,
                height: 1.6,
                color: AppColors.buttonColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingScreen extends StatelessWidget {
  final String imagePath;
  final int currentIndex;
  final int totalPages;

  const OnboardingScreen({
    super.key,
    required this.imagePath,
    required this.currentIndex,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height * 0.7;

    return Stack(
      children: [
        Positioned(
          top: 0,
          left: -screenWidth * currentIndex,
          child: SizedBox(
            width: screenWidth * totalPages,
            height: screenHeight,
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }
}

class OnboardingPageView extends StatefulWidget {
  const OnboardingPageView({super.key});

  @override
  _OnboardingPageViewState createState() => _OnboardingPageViewState();
}

class _OnboardingPageViewState extends State<OnboardingPageView> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  bool _showSkipButton = false;
  String? userId;

  final List<Map<String, String>> onboardingData = [
    {
      'title': 'مرحبآ بك في عين المرأة',
      'description': 'حيث يكون صوتك مسموع ودعمك مستمر',
    },
    {
      'title': 'قوتك تكمن في وعيك',
      'description': 'نحن نؤمن بأن قوتك تكمن في وعيك',
    },
    {
      'title': 'كوني جزءآ من التغيير',
      'description': 'شاركي قصصك الملهمة واغتنمي الفرصة',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUserId();  // تحميل userId من SharedPreferences
    _pageController.addListener(() {
      setState(() {
        _currentIndex = _pageController.page!.toInt();
      });
    });
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('user_id')?.toString();
      _showSkipButton = userId != null;  // عرض زر التخطي إذا كان userId موجودًا
    });
  }

  void _onNext() async {
    if (_currentIndex < onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
        Navigator.of(context, rootNavigator: true).pushReplacementNamed('/cards');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: onboardingData.length,
            itemBuilder: (context, index) {
              return OnboardingScreen(
                imagePath: 'assets/images/t1.png',
                currentIndex: index,
                totalPages: onboardingData.length,
              );
            },
          ),
          Positioned(
            bottom: 70,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    onboardingData[_currentIndex]['title']!,
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.headerColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    onboardingData[_currentIndex]['description']!,
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 14,
                      color: AppColors.textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF36623F),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 15,
                        ),
                      ),
                      child: const Text(
                        'التالي',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 20,
            child: SmoothPageIndicator(
              controller: _pageController,
              count: onboardingData.length,
              effect: const WormEffect(
                dotHeight: 10,
                dotWidth: 10,
                spacing: 8,
                activeDotColor: Color(0xFF36623F),
                dotColor: Colors.grey,
              ),
            ),
          ),
          if (_showSkipButton) 
            Positioned(
              bottom: 10,
              right: 20,
              child: TextButton(
                onPressed: () {
                    Navigator.of(context, rootNavigator: true).pushReplacementNamed('/cards');
                },
                child: const Text(
                  'تخطي',
                  style: TextStyle(
                    color: AppColors.textColor,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}




