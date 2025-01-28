import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:merge_voice_coplain/buttomnav.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/appcolors.dart';
import '../api/api_activities.dart';
import 'myactivities.dart';
import 'package:flutter_html/flutter_html.dart';
class ActivitiesPage extends StatefulWidget {
  const ActivitiesPage({super.key});

  @override
  _ActivitiesPageState createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage>with SingleTickerProviderStateMixin {
   late TabController _tabController; 
  int _selectedIndex = 1;
  int _selectedTabIndex = 0;
  int? userType;
  bool _isLoading = false;
  String lang = 'ar';
  String _searchQuery = '';
  int? userId; 


  // النصوص المتغيرة بناءً على اللغة
  String title = 'وطني';
  String subtitle = 'الانشطة الخاصة بالمجلس واخرى';
  String womenTab = 'انشطة خاصة بالمجلس';
  String childTab = 'انشطة اخرى';
  String searchHint = 'ابحث عن مقال';
  String logoutText = 'تسجيل خروج';

  // Women Health data
  List<String> womenHealthImages = [];
  List<String> womenHealthTitles = [];
  List<String> womenHealthDescriptions = [];
  List<String> womenHealthDates = [];

  // Child Health data
  List<String> childHealthImages = [];
  List<String> childHealthTitles = [];
  List<String> childHealthDescriptions = [];
  List<String> childHealthDates = [];

  // Filtered Data
  List<String> filteredWomenHealthImages = [];
  List<String> filteredWomenHealthTitles = [];
  List<String> filteredWomenHealthDescriptions = [];
  List<String> filteredWomenHealthDates = [];

  List<String> filteredChildHealthImages = [];
  List<String> filteredChildHealthTitles = [];
  List<String> filteredChildHealthDescriptions = [];
  List<String> filteredChildHealthDates = [];


  
 @override
  void initState() {
    super.initState();
    _loadUserId(); 
    _tabController = TabController(length:2, vsync: this);
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

    // Fetch data when the page is entered
    if (userType != null) {
      _fetchactivitiesl();
    }
  }

  // دالة تحديث النصوص بناءً على اللغة
  void _updateTexts(String selectedLang) {
    setState(() {
    if (selectedLang == 'ar') {
   title = 'وطني';
   subtitle = 'الانشطة الخاصة بالمجلس واخرى';
   womenTab = 'انشطة خاصة بالمجلس';
   childTab = 'انشطة اخرى';
   searchHint = 'ابحث عن مقال';
   logoutText = 'تسجيل خروج';

} else {
title = 'My Activities';
subtitle = 'Council activities and others';
womenTab = 'Council Activities';
childTab = 'Other Activities';
searchHint = 'Search for an article';
logoutText = 'Logout';

}

    });
  }

  // Fetch Women Health Data (sectionId from userType)
  Future<void> _fetchactivitiesl() async {
    if (userType == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final api = ApiNews();
      final articles = await api.activities(sectionId: userType.toString(), lang: lang);

      setState(() {
        womenHealthImages = articles
            .map((article) => article['file_path'] as String)
            .toList();
        womenHealthTitles = articles
            .map((article) => article['title'] as String)
            .toList();
        womenHealthDescriptions = articles
            .map((article) => article['content_text'] as String)
            .toList();
        womenHealthDates = articles
            .map((article) => article['created_at'] as String)
            .toList();
        _filteractivities();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching women health articles: $e');
    }
  }


  // Fetch Child Health Data (sectionId from userType)
  Future<void> _fetchother() async {
    if (userType == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final api = ApiNews();
      final events = await api.other(sectionId: userType.toString(), lang: lang);

      setState(() {
        childHealthImages = events
            .map((event) => event['file_path'] as String)
            .toList();
        childHealthTitles = events
            .map((event) => event['title'] as String)
            .toList();
        childHealthDescriptions = events
            .map((event) => event['content_text'] as String)
            .toList();
        childHealthDates = events
            .map((event) => event['created_at'] as String)
            .toList();
        _filterother();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching child health articles: $e');
    }
  }

  // Filter Women Health Data
  void _filteractivities() {
    setState(() {
      if (_searchQuery.isEmpty) {
        filteredWomenHealthImages = womenHealthImages;
        filteredWomenHealthTitles = womenHealthTitles;
        filteredWomenHealthDescriptions = womenHealthDescriptions;
        filteredWomenHealthDates = womenHealthDates;
      } else {
        filteredWomenHealthImages = [];
        filteredWomenHealthTitles = [];
        filteredWomenHealthDescriptions = [];
        filteredWomenHealthDates = [];

        for (int i = 0; i < womenHealthTitles.length; i++) {
          if (womenHealthTitles[i].contains(_searchQuery)) {
            filteredWomenHealthImages.add(womenHealthImages[i]);
            filteredWomenHealthTitles.add(womenHealthTitles[i]);
            filteredWomenHealthDescriptions.add(womenHealthDescriptions[i]);
            filteredWomenHealthDates.add(womenHealthDates[i]);
          }
        }
      }
    });
  }

  // Filter Child Health Data
  void _filterother() {
    setState(() {
      if (_searchQuery.isEmpty) {
        filteredChildHealthImages = childHealthImages;
        filteredChildHealthTitles = childHealthTitles;
        filteredChildHealthDescriptions = childHealthDescriptions;
        filteredChildHealthDates = childHealthDates;
      } else {
        filteredChildHealthImages = [];
        filteredChildHealthTitles = [];
        filteredChildHealthDescriptions = [];
        filteredChildHealthDates = [];

        for (int i = 0; i < childHealthTitles.length; i++) {
          if (childHealthTitles[i].contains(_searchQuery)) {
            filteredChildHealthImages.add(childHealthImages[i]);
            filteredChildHealthTitles.add(childHealthTitles[i]);
            filteredChildHealthDescriptions.add(childHealthDescriptions[i]);
            filteredChildHealthDates.add(childHealthDates[i]);
          }
        }
      }
    });
  }


  
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Handle Tab Switch
  void _onTabTapped(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
    if (_selectedTabIndex == 0) {
      _fetchactivitiesl();
    } else if (_selectedTabIndex == 1) {
      _fetchother();
    }
  }

  // تسجيل الخروج
  Future<void> _logout() async {
    // ضع هنا منطق تسجيل الخروج المناسب
    print("User logged out");
  }

  // Fetch data based on language
  void _fetchDataBasedOnLanguage(String lang) {
    _updateTexts(lang);
    if (_selectedTabIndex == 0) {
      _fetchactivitiesl();
    } else if (_selectedTabIndex == 1) {
      _fetchother();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

//     return DefaultTabController(
//       length: 2,
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         body: Stack(
//
//           children: [
//             // AppBar with gradient and custom content
//             Positioned(
//               top: 0,
//               left: 0,
//               right: 0,
//               child: Container(
//                 height: screenHeight * 0.25,
//                 decoration: const BoxDecoration(
//                   color: AppColors.secondaryColor,
//                   image: DecorationImage(
//
//                     image: AssetImage('assets/images/appbarnew.jpg'),
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//                 child: SafeArea(
//                   child: Padding(
//                     padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         CircleAvatar(
//                           backgroundColor: AppColors.backgroundColor,
//                           radius: screenWidth * 0.06,
//                           child: IconButton(
//                             icon: const Icon(
//                               Icons.arrow_back_ios_rounded,
//                               color: Colors.black,
//                               size: 18,
//                             ),
//                             onPressed: () {
//                               Navigator.of(context).pop();
//                             },
//                           ),
//                         ),
//                     PopupMenuButton<int>(
//   icon: SvgPicture.asset(
//     'assets/images/menu.svg',
//     width: 24,
//     height: 24,
//     color: const Color.fromARGB(255, 255, 255, 255),
//   ),
//   itemBuilder: (context) => [
//     if (userId != null) // Conditionally show the logout option
//       PopupMenuItem(
//         value: 1,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.logout, color: Color.fromARGB(255, 0, 0, 0)),
//             const SizedBox(width: 8),
//             Text(logoutText),
//           ],
//         ),
//       ),
//     const PopupMenuItem(
//       value: 2,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.language, color: Colors.black),
//           SizedBox(width: 8),
//           Text('العربية'),
//         ],
//       ),
//     ),
//     const PopupMenuItem(
//       value: 3,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.language, color: Colors.black),
//           SizedBox(width: 8),
//           Text('English'),
//         ],
//       ),
//     ),
//   ],
//   onSelected: (value) {
//     if (value == 1) {
//       if (userId != null) {
//         _logout(); // Perform logout if user is logged in
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('لا يوجد مستخدم لتسجيل الخروج')),
//         );
//       }
//     } else if (value == 2) {
//       setState(() {
//         lang = 'ar'; // Switch to Arabic
//       });
//       _fetchDataBasedOnLanguage(lang);
//     } else if (value == 3) {
//       setState(() {
//         lang = 'en'; // Switch to English
//       });
//       _fetchDataBasedOnLanguage(lang);
//     }
//   },
// ),
//
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//
//             Positioned(
//               top: 180,
//               left: 0,
//               right: 0,
//               child: Center(
//                 child: Container(
//                   width: 327,
//                   height: 90,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(12),
//                     color: Colors.white,
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.1),
//                         spreadRadius: 2,
//                         blurRadius: 8,
//                       ),
//                     ],
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(12.0),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         Text(
//                           title,
//                           style: GoogleFonts.tajawal(
//                             fontSize: 18,
//                             color: AppColors.headerColor,
//                             fontWeight: FontWeight.w700,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                         Text(
//                           subtitle,
//                           style: GoogleFonts.tajawal(
//                             fontSize: 12,
//                             color: AppColors.textColor,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//
//             // Body content with search box and TabBar
//             Positioned.fill(
//               top: 300,
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                 child: Column(
//                   children: [
//                     // Search Box based on the active tab
//                     Row(
//                       children: [
//                         Expanded(
//                           child: TextField(
//                             decoration: InputDecoration(
//                               hintText: searchHint,
//                               prefixIcon: const Icon(Icons.search),
//                               filled: true,
//                               fillColor: Colors.grey[200],
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                                 borderSide: BorderSide.none,
//                               ),
//                             ),
//                             onChanged: (query) {
//                               setState(() {
//                                 _searchQuery = query;
//                                 if (_selectedTabIndex == 0) {
//                                   _fetchactivitiesl();
//                                 } else if (_selectedTabIndex == 1) {
//                                   _filterother();
//                                 }
//                               });
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 20),
//
//                     // TabBar
//                     TabBar(
//                       controller:_tabController ,
//                       indicator: BoxDecoration(
//                             color: AppColors.primaryColor,
//                         borderRadius: BorderRadius.circular(12),
//
//                       ),
//                       labelColor: Colors.grey,
//                       unselectedLabelColor: Colors.grey,
//                       onTap: _onTabTapped,
//                       tabs: [
//                         Tab(
//                           child: Container(
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(12),
//                               border: Border.all(
//                                color: _selectedTabIndex == 0
//                               ? Colors.grey // No border for selected tab
//                             : const Color(0xFF6B7280), // Border for unselected tabs
//
//                               ),
//                             ),
//                             child: Center(child: Text(womenTab,
//                           style: TextStyle(
//               color: _selectedTabIndex == 0
//                   ? Colors.grey // White text for selected tab
//                   : Colors.grey, // Black text for unselected tabs
//             ),)),
//                           ),
//                         ),
//                         Tab(
//                           child: Container(
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(12),
//                             border: Border.all(
//                                color: _selectedTabIndex == 1
//                               ? Colors.grey // No border for selected tab
//                             : const Color(0xFF6B7280), // Border for unselected tabs
//
//                               ),
//                             ),
//                             child: Center(child: Text(childTab,
//                             style: TextStyle(
//               color: _selectedTabIndex == 0
//                   ? Colors.grey // White text for selected tab
//                   : Colors.grey, // Black text for unselected tabs
//             ),  )),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 20),
//
//                     // TabBarView for women health and child health content
//                     Expanded(
//                       child: TabBarView(
//                         children: [
//                           _isLoading
//                               ? const Center(child: CircularProgressIndicator())
//                               : _buildListView(
//                                   filteredWomenHealthImages,
//                                   filteredWomenHealthTitles,
//                                   filteredWomenHealthDescriptions,
//                                   filteredWomenHealthDates,
//                                 ),
//                           _isLoading
//                               ? const Center(child: CircularProgressIndicator())
//                               : _buildListView(
//                                   filteredChildHealthImages,
//                                   filteredChildHealthTitles,
//                                   filteredChildHealthDescriptions,
//                                   filteredChildHealthDates,
//                                 ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//         bottomNavigationBar: CustomBottomNavigationBar(
//           currentIndex: _selectedIndex,
//           onItemTapped: _onItemTapped,
//           lang: lang,
//
//         ),
//       ),
//     );
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // AppBar with gradient and custom content
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: screenHeight * 0.25,
                decoration: const BoxDecoration(
                  color: AppColors.secondaryColor,
                  image: DecorationImage(
                    image: AssetImage('assets/images/appbarnew.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.backgroundColor,
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

            // Body content with search box and TabBar
            Positioned.fill(
              top: 300,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    // Search Box based on the active tab
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: searchHint,
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
                                if (_selectedTabIndex == 0) {
                                  _fetchactivitiesl();
                                } else if (_selectedTabIndex == 1) {
                                  _filterother();
                                }
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // TabBar
                    TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelColor: Colors.grey,
                      unselectedLabelColor: Colors.grey,
                      onTap: _onTabTapped,
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
                            ),
                            child: Center(
                              child: Text(
                                womenTab,
                                style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.width > 600 ? 16 : 14, // Adjust font size for larger screens
                                  color: _selectedTabIndex == 0 ? Colors.grey : Colors.grey, // Maintain grey color
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
                                color: _selectedTabIndex == 1
                                    ? Colors.grey // No border for selected tab
                                    : const Color(0xFF6B7280), // Border for unselected tabs
                              ),
                            ),
                            child: Center(
                              child: Text(
                                childTab,
                                style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.width > 600 ? 16 : 14, // Adjust font size for larger screens
                                  color: _selectedTabIndex == 1 ? Colors.grey : Colors.grey, // Maintain grey color
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // TabBarView for women health and child health content
                    Expanded(
                      child: TabBarView(
                        children: [
                          _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : _buildListView(
                            filteredWomenHealthImages,
                            filteredWomenHealthTitles,
                            filteredWomenHealthDescriptions,
                            filteredWomenHealthDates,
                          ),
                          _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : _buildListView(
                            filteredChildHealthImages,
                            filteredChildHealthTitles,
                            filteredChildHealthDescriptions,
                            filteredChildHealthDates,
                          ),
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

  // Method to build the list views for women health and child health articles
  Widget _buildListView(
      List<String> images, List<String> titles, List<String> descriptions, List<String> dates) {
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
                builder: (context) => myactivpage(
                  title: titles[index],
                  image: images[index],
                  description: descriptions[index],
                  date: dates[index],
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
                          titles[index],
                          style: GoogleFonts.tajawal(
                            color: AppColors.headerColor,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Html(
                          data: shortDescription,
                          style: {
                            "body": Style(
                              fontSize: FontSize(12.0),
                              color: AppColors.textColor,
                            ),
                          },
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
                              dates[index],
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
                      image: NetworkImage(images[index]),
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
}
