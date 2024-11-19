import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:merge_voice_coplain/buttomnav.dart';
import '../theme/appcolors.dart';
import 'essay_detail.dart';
import 'event.dart';
import 'jobopp.dart';
import '../api/api_news.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// استيراد المكتبة

class NewsDetailsPage extends StatefulWidget {
  const NewsDetailsPage({super.key});

  @override
  _NewsDetailsPageState createState() => _NewsDetailsPageState();
}

class _NewsDetailsPageState extends State<NewsDetailsPage>with SingleTickerProviderStateMixin {
   late TabController _tabController; 
  int _selectedIndex = 1;
  int _selectedTabIndex = 0; 
  int? userType;
  bool _isLoading = false;
  String lang = 'ar'; // افتراضياً اللغة هي العربية
  int? userId; 

  // المتغيرات النصية
  String title = 'اخبار';
  String subtitle = 'استكشفي مقالات ملهمة، فرص عمل مميزة، وأحداث لا تفوت';
  String articlesTab = 'مقالات';
  String jobsTab = 'فرص عمل';
  String eventsTab = 'احداث اخرى';
  String searchArticleHint = 'ابحث عن مقال';
  String searchJobHint = 'ابحث عن وظيفة';
  String searchEventHint = 'ابحث عن حدث';
  String logoutText = 'تسجيل خروج';

  String _searchQuery = ''; 
  String _eventSearchQuery = ''; 
  String _articleSearchQuery = ''; 

  List<String> articleImages = [];
  List<String> articleTitles = [];
  List<String> articleDescriptions = [];
  List<String> articlesDates = [];



  List<String> filteredArticleImages = [];
  List<String> filteredArticleTitles = [];
  List<String> filteredArticleDescriptions = [];
  List<String> filteredArticlesDates = [];

  List<String> jobImages = [];
  List<String> jobTitles = [];
  List<String> jobDescriptions = [];
  List<String> jobDates = [];

  List<String> filteredJobImages = [];
  List<String> filteredJobTitles = [];
  List<String> filteredJobDescriptions = [];
  List<String> filteredJobDates = [];

  List<String> eventImages = [];
  List<String> eventTitles = [];
  List<String> eventDescriptions = [];
  List<String> eventDates = [];

  List<String> filteredEventImages = [];
  List<String> filteredEventTitles = [];
  List<String> filteredEventDescriptions = [];
  List<String> filteredEventDates = [];


 @override
  void initState() {
    super.initState();
    _loadUserId(); 
    _tabController = TabController(length: 3, vsync: this);
  }
 @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('user_id');
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (arguments != null) {
      setState(() {
        userType = arguments['userType'] as int?;
      });
    }

    // تحميل المقالات افتراضياً عند دخول الصفحة
    if (userType != null) {
      _fetchArticles(userType!);
    }
  }

  // دالة لتحديث النصوص بناءً على اللغة
  void _updateTexts(String selectedLang) {
    setState(() {
      if (selectedLang == 'ar') {
        title = 'اخبار';
        subtitle = 'استكشفي مقالات ملهمة، فرص عمل مميزة، وأحداث لا تفوت';
        articlesTab = 'مقالات';
        jobsTab = 'فرص عمل';
        eventsTab = 'احداث اخرى';
        searchArticleHint = 'ابحث عن مقال';
        searchJobHint = 'ابحث عن وظيفة';
        searchEventHint = 'ابحث عن حدث';
        logoutText = 'تسجيل خروج';
      } else {
        title = 'News';
        subtitle = 'Discover inspiring articles, great job opportunities, and unmissable events';
        articlesTab = 'Articles';
        jobsTab = 'Jobs';
        eventsTab = 'Events';
        searchArticleHint = 'Search for an article';
        searchJobHint = 'Search for a job';
        searchEventHint = 'Search for an event';
        logoutText = 'Logout';
      }
    });
  }

  Future<void> _fetchArticles(int sectionId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiNews = ApiNews();
      final articles = await apiNews.fetchArticles(
          sectionId: sectionId.toString(), lang: lang); // استخدام lang

      setState(() {
        articleImages =
            articles.map((article) => article['file_path'] as String).toList();
        articleTitles =
            articles.map((article) => article['title'] as String).toList();
        articleDescriptions =
            articles.map((article) => article['content_text'] as String).toList();
          articlesDates = articles.map((article) => article['created_at'] as String).toList();
        _filterArticles();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching articles: $e');
    }
  }

  void _filterArticles() {
    setState(() {
      if (_articleSearchQuery.isEmpty) {
        filteredArticleImages = articleImages;
        filteredArticleTitles = articleTitles;
        filteredArticleDescriptions = articleDescriptions;
        filteredArticlesDates = articlesDates;
      } else {
        filteredArticleImages = [];
        filteredArticleTitles = [];
        filteredArticleDescriptions = [];
        filteredArticlesDates = [];

        for (int i = 0; i < articleTitles.length; i++) {
          if (articleTitles[i].contains(_articleSearchQuery)) {
            filteredArticleImages.add(articleImages[i]);
            filteredArticleTitles.add(articleTitles[i]);
            filteredArticleDescriptions.add(articleDescriptions[i]);
            filteredArticlesDates.add(articlesDates[i]);
          }
        }
      }
    });
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

  Future<void> _fetchJobs(int sectionId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiNews = ApiNews();
      final jobs = await apiNews.fetchJobs(
          sectionId: sectionId.toString(), lang: lang); // استخدام lang

      setState(() {
        jobImages = jobs.map((job) => job['file_path'] as String).toList();
        jobTitles = jobs.map((job) => job['title'] as String).toList();
        jobDescriptions =
            jobs.map((job) => job['content_text'] as String).toList();
        jobDates = jobs.map((job) => job['start_date'] as String).toList();
        _filterJobs();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching jobs: $e');
    }
  }

  void _filterJobs() {
    setState(() {
      if (_searchQuery.isEmpty) {
        filteredJobImages = jobImages;
        filteredJobTitles = jobTitles;
        filteredJobDescriptions = jobDescriptions;
        filteredJobDates = jobDates;
      } else {
        filteredJobImages = [];
        filteredJobTitles = [];
        filteredJobDescriptions = [];
        filteredJobDates = [];

        for (int i = 0; i < jobTitles.length; i++) {
          if (jobTitles[i].contains(_searchQuery)) {
            filteredJobImages.add(jobImages[i]);
            filteredJobTitles.add(jobTitles[i]);
            filteredJobDescriptions.add(jobDescriptions[i]);
            filteredJobDates.add(jobDates[i]);
          }
        }
      }
    });
  }

  Future<void> _fetchEvents(int sectionId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiNews = ApiNews();
      final events = await apiNews.fetchEvents(
          sectionId: sectionId.toString(), lang: lang); // استخدام lang

      setState(() {
        eventImages = events.map((event) => event['file_path'] as String).toList();
        eventTitles = events.map((event) => event['title'] as String).toList();
        eventDescriptions =
            events.map((event) => event['content_text'] as String).toList();
        eventDates = events.map((event) => event['start_date'] as String).toList();
        _filterEvents();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching events: $e');
    }
  }

  void _filterEvents() {
    setState(() {
      if (_eventSearchQuery.isEmpty) {
        filteredEventImages = eventImages;
        filteredEventTitles = eventTitles;
        filteredEventDescriptions = eventDescriptions;
        filteredEventDates = eventDates;
      } else {
        filteredEventImages = [];
        filteredEventTitles = [];
        filteredEventDescriptions = [];
        filteredEventDates = [];

        for (int i = 0; i < eventTitles.length; i++) {
          if (eventTitles[i].contains(_eventSearchQuery)) {
            filteredEventImages.add(eventImages[i]);
            filteredEventTitles.add(eventTitles[i]);
            filteredEventDescriptions.add(eventDescriptions[i]);
            filteredEventDates.add(eventDates[i]);
          }
        }
      }
    });
  }

  void _fetchDataBasedOnLanguage(String lang) {
    _updateTexts(lang);
    if (_selectedTabIndex == 0) {
      _fetchArticles(userType!);
    } else if (_selectedTabIndex == 1) {
      _fetchJobs(userType!);
    } else if (_selectedTabIndex == 2) {
      _fetchEvents(userType!);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // تعيين العنصر النشط في الـ BottomNavigationBar
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return DefaultTabController(
      length: 3,
      initialIndex: 0, 
      child: Scaffold(
        body: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: screenHeight * 0.25,
                decoration: const BoxDecoration(
                  color: AppColors.secondaryColor,
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: screenWidth * 0.06,
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_rounded,
                              color: Colors.black,
                              size: 18,
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                        PopupMenuButton<int>(
  icon: SvgPicture.asset(
    'assets/images/menu.svg',
    width: 24,
    height: 24,
    color: const Color.fromARGB(255, 255, 255, 255),
  ),
  itemBuilder: (context) => [
    if (userId != null) // Conditionally show the logout option
      PopupMenuItem(
        value: 1,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout, color: Color.fromARGB(255, 0, 0, 0)),
            const SizedBox(width: 8),
            Text(logoutText),
          ],
        ),
      ),
    const PopupMenuItem(
      value: 2,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.language, color: Colors.black),
          SizedBox(width: 8),
          Text('العربية'),
        ],
      ),
    ),
    const PopupMenuItem(
      value: 3,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.language, color: Colors.black),
          SizedBox(width: 8),
          Text('English'),
        ],
      ),
    ),
  ],
  onSelected: (value) {
    if (value == 1) {
      if (userId != null) {
        _logout(); // Perform logout if user is logged in
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لا يوجد مستخدم لتسجيل الخروج')),
        );
      }
    } else if (value == 2) {
      setState(() {
        lang = 'ar'; // Switch to Arabic
      });
      _fetchDataBasedOnLanguage(lang);
    } else if (value == 3) {
      setState(() {
        lang = 'en'; // Switch to English
      });
      _fetchDataBasedOnLanguage(lang);
    }
  },
),

                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 180,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 327,
                  height: 90,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.tajawal(
                            fontSize: 18,
                            color: AppColors.headerColor,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          subtitle,
                          style: GoogleFonts.tajawal(
                            fontSize: 12,
                            color: AppColors.textColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              top: 300,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    // عرض مربع البحث بناءً على التبويب النشط
                    if (_selectedTabIndex == 0)
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: searchArticleHint,
                                prefixIcon: const Icon(Icons.search),
                                filled: true,
                                fillColor: Colors.grey[200],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              onChanged: (query) {
                                setState(() {
                                  _articleSearchQuery = query;
                                  _filterArticles();
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    if (_selectedTabIndex == 1)
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: searchJobHint,
                                prefixIcon: const Icon(Icons.search),
                                filled: true,
                                fillColor: Colors.grey[200],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              onChanged: (query) {
                                setState(() {
                                  _searchQuery = query;
                                  _filterJobs();
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    if (_selectedTabIndex == 2)
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: searchEventHint,
                                prefixIcon: const Icon(Icons.search),
                                filled: true,
                                fillColor: Colors.grey[200],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              onChanged: (query) {
                                setState(() {
                                  _eventSearchQuery = query;
                                  _filterEvents();
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 20),
                    TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                          color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                        
                      ),
                      labelColor: AppColors.backgroundColor,
                      unselectedLabelColor: Colors.grey,
                      // overlayColor:WidgetStateProperty.all(Colors.transparent) ,
                    
                      onTap: (index) {
                        setState(() {
                          _selectedTabIndex = index; // تغيير التبويب النشط
                        });
                        if (index == 0) {
                          _fetchArticles(userType!);
                        } else if (index == 1) {
                          _fetchJobs(userType!);
                        } else if (index == 2) {
                          _fetchEvents(userType!);
                        }
                      },
                      tabs: [
                        Tab(


                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                               color: _selectedTabIndex == 0
                              ? Colors.grey // No border for selected tab
                            : const Color(0xFF6B7280), // Border for unselected tabs
                            
                              ),
                        // color: _selectedTabIndex == 0
                        //   ? AppColors.primaryColor // Primary color for selected tab
                        //  : Colors.white, // Transparent for unselected tabs
                            ),
                            child: Center(child: Text(articlesTab ,
                            style: TextStyle(
              color: _selectedTabIndex == 0
                  ? Colors.grey // White text for selected tab
                  : Colors.grey, // Black text for unselected tabs
            ),


                            )),
                          ),
                        ),
                    
                          Tab(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedTabIndex == 1
                ? Colors.grey // No border for selected tab
                : const Color(0xFF6B7280), // Border for unselected tabs
          ),
          // color: _selectedTabIndex == 1
          //     ? AppColors.primaryColor // Primary color for selected tab
          //     : Colors.transparent, // Transparent for unselected tabs
        ),
        child: Center(
          child: Text(
            jobsTab,
            style: TextStyle(
              color: _selectedTabIndex == 1
                  ? Colors.white // White text for selected tab
                  : Colors.grey, // Black text for unselected tabs
            ),
          ),
        ),
      ),
    ),
                        Tab(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedTabIndex == 2
                ? Colors.transparent // No border for selected tab
                : const Color(0xFF6B7280), // Border for unselected tabs
          ),
          // color: _selectedTabIndex == 2
          //     ? AppColors.primaryColor // Primary color for selected tab
          //     : Colors.transparent, // Transparent for unselected tabs
        ),
        child: Center(
          child: Text(
            eventsTab,
            style: TextStyle(
              color: _selectedTabIndex == 2
                  ? Colors.white // White text for selected tab
                  : Colors.grey, // Black text for unselected tabs
            ),
          ),
        ),
      ),
    ),

                      ],
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _isLoading
                              ? const Center(
                                  child: CircularProgressIndicator())
                              : _buildVerticalListView(filteredArticleImages,
                                  filteredArticleTitles, filteredArticleDescriptions,filteredArticlesDates ), // مقالات
                          _isLoading
                              ? const Center(
                                  child: CircularProgressIndicator())
                              : _buildJobListView(
                                  filteredJobImages,
                                  filteredJobTitles,
                                  filteredJobDescriptions,
                                  filteredJobDates), // فرص عمل
                          _isLoading
                              ? const Center(
                                  child: CircularProgressIndicator())
                              : _buildEventListView(
                                  filteredEventImages,
                                  filteredEventTitles,
                                  filteredEventDescriptions,
                                  filteredEventDates), // أحداث أخرى
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
          lang: lang,

        ),
      ),
    );
  }

  Widget _buildVerticalListView(
      List<String> images, List<String> titles, List<String> descriptions, List<String> date ) {
    return ListView.builder(
      itemCount: images.length,
      itemBuilder: (context, index) {
        String truncateDescription(String description) {
          List<String> words = description.split(' ');
          if (words.length > 10) {
            return '${words.sublist(0, 10).join(' ')}...';
          } else {
            return description;
          }
        }

        String shortDescription = truncateDescription(descriptions[index]);

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EssayPage(
                  title: titles[index],
                  image: images[index],
                  description: descriptions[index],
                  date: date[index],
  
                ),
              ),
            );
          },
          child: Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                height: 240,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(images[index]),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 70,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(16),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          titles[index],
                          style: GoogleFonts.tajawal(
                            color: AppColors.headerColor,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.right,
                        ),
                        const SizedBox(height: 4),
                      //    HtmlWidget(
                      //   shortDescription, // عرض النصوص مع تنسيق HTML
                      //   textStyle: GoogleFonts.tajawal(
                      //     color: AppColors.textColor,
                      //     fontSize: 12,
                      //   ),
                      // ),
                        Text(
                          shortDescription,
                          style: GoogleFonts.tajawal(
                            color: AppColors.textColor,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  Widget _buildJobListView(
      List<String> jobImages,
      List<String> jobTitles,
      List<String> jobDescriptions,
      List<String> jobDates) {
    return ListView.builder(
      itemCount: jobImages.length,
      itemBuilder: (context, index) {
        String truncateDescription(String description) {
          List<String> words = description.split(' ');
          if (words.length > 10) {
            return '${words.sublist(0, 10).join(' ')}...';
          } else {
            return description;
          }
        }

        String shortDescription = truncateDescription(jobDescriptions[index]);

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => JoboppPage(
                  title: jobTitles[index],
                  image: jobImages[index],
                  description: jobDescriptions[index],
                  date: jobDates[index],
  
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          jobTitles[index],
                          style: GoogleFonts.tajawal(
                            color: AppColors.headerColor,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          shortDescription,
                          style: GoogleFonts.tajawal(
                            color: AppColors.textColor,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/images/agenda.svg',
                              width: 16,
                              height: 16,
                              color: AppColors.buttonColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              jobDates[index],
                              style: const TextStyle(
                                color: AppColors.textColor,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(jobImages[index]),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEventListView(List<String> eventImages, List<String> eventTitles,
      List<String> eventDescriptions, List<String> eventDatess) {
    return ListView.builder(
      itemCount: eventImages.length,
      itemBuilder: (context, index) {
        String truncateDescription(String description) {
          List<String> words = description.split(' ');
          if (words.length > 10) {
            return '${words.sublist(0, 10).join(' ')}...';
          } else {
            return description;
          }
        }

        String shortDescription = truncateDescription(eventDescriptions[index]);

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EventPage(
                  title: eventTitles[index],
                  image: eventImages[index],
                  description: eventDescriptions[index],
                  date: eventDates[index],
  
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title of the event
                        Text(
                          eventTitles[index],
                          style: GoogleFonts.tajawal(
                            color: AppColors.headerColor,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Short description of the event
                        Text(
                          shortDescription,
                          style: GoogleFonts.tajawal(
                            color: AppColors.textColor,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Display the created_at date with an icon
                        Row(
                          children: [
                            // Add the calendar icon (agenda)
                            SvgPicture.asset(
                              'assets/images/agenda.svg',
                              width: 16,
                              height: 16,
                              color: AppColors.buttonColor,
                            ),
                            const SizedBox(
                                width:
                                    4), // Add some spacing between the icon and the text
                            // Display the created_at date
                            Text(
                              eventDates[index],
                              style: const TextStyle(
                                color: AppColors.textColor,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Event image
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(eventImages[index]),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToJobDetails(
      BuildContext context, String title, String image, String description , String date) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JoboppPage(
          title: title,
          image: image,
          description: description,
          date: date,

        ),
      ),
    );
  }

  void _navigateToEventDetails(
      BuildContext context, String title, String image, String description , String date) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventPage(
          title: title,
          image: image,
          description: description,
          date: date,

        ),
      ),
    );
  }
}


