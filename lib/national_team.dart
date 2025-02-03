
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:merge_voice_coplain/buttomnav.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/appcolors.dart';
import '../api/national_team.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_html/flutter_html.dart';

import 'nationaldetails.dart';

class national_team extends StatefulWidget {
  const national_team({super.key});

  @override
  _national_teamState createState() => _national_teamState();
}

class _national_teamState extends State<national_team> {
  int _selectedIndex = 1;
  int? userType;
  bool _isLoading = false;
  String lang = 'ar';
  String _searchQuery = '';
  int? userId;

  String title = 'الفريق الوطني';
  String subtitle = 'اطلع على اخبار الفريق الوطني';
  String searchHint = 'ابحث عن الخبر';
  String logoutText = 'تسجيل خروج';

  // Women Health data
  List<String> womenHealthImages = [];
  List<String> womenHealthTitles = [];
  List<String> womenHealthDescriptions = [];
  List<String> womenHealthDates = [];

  // Filtered Data
  List<String> filteredWomenHealthImages = [];
  List<String> filteredWomenHealthTitles = [];
  List<String> filteredWomenHealthDescriptions = [];
  List<String> filteredWomenHealthDates = [];

  @override
  void initState() {
    super.initState();
    _loadUserId();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (userType != null) {
        _fetchefficiency();
      }
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

    if (userType != null) {
      _fetchefficiency();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('user_id');
    });
  }

  void _updateTexts(String selectedLang) {
    setState(() {
      if (selectedLang == 'ar') {
        title = 'الفريق الوطني';
        subtitle = 'اطلع على اخبار الفريق الوطني';
        searchHint = 'ابحث عن الخبر';
        logoutText = 'تسجيل خروج';
      } else {
        title = 'national team';
        subtitle = 'Check out the national team news';
        searchHint = 'Search for news';
        logoutText = 'Logout';
      }
    });
  }

  Future<void> _fetchefficiency() async {
    if (userType == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final api = ApiNews();
      final articles =
      await api.efficiency(sectionId: userType.toString(), lang: lang);

      setState(() {
        womenHealthImages =
            articles.map((article) => article['file_path'] as String).toList();
        womenHealthTitles =
            articles.map((article) => article['title'] as String).toList();
        womenHealthDescriptions = articles
            .map((article) => article['content_text'] as String)
            .toList();
        womenHealthDates =
            articles.map((article) => article['created_at'] as String).toList();
        _filterefficiency();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching women health articles: $e');
    }
  }

  void _filterefficiency() {
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

  void _fetchDataBasedOnLanguage(String lang) {
    _updateTexts(lang);
    _fetchefficiency();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? accessToken = prefs.getString('accessToken');

      if (accessToken != null) {
        final url = Uri.parse('https://ur.gov.iq/api/client/user/logout');
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          print('Logout successful: $responseData');
        } else {
          print('Logout failed. Status: ${response.statusCode}, Response: ${response.body}');
        }
      } else {
        print('No Access Token found.');
      }

      await prefs.remove('accessToken');
      await prefs.remove('user_id');
      Navigator.pushReplacementNamed(context, '/logafterlogout');
    } catch (e) {
      print('Error occurred during logout: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: screenHeight * 0.28,
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
                          if (userId != null)
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
                              _logout();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('لا يوجد مستخدم لتسجيل الخروج')),
                              );
                            }
                          } else if (value == 2) {
                            setState(() {
                              lang = 'ar';
                            });
                            _fetchDataBasedOnLanguage(lang);
                          } else if (value == 3) {
                            setState(() {
                              lang = 'en';
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
                              _fetchefficiency();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Replaced TabBarView with ListView.builder
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _buildListView(
                      filteredWomenHealthImages,
                      filteredWomenHealthTitles,
                      filteredWomenHealthDescriptions,
                      filteredWomenHealthDates,
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
    );
  }

  // _buildListView function to display the list
  Widget _buildListView(
      List<String> images,
      List<String> titles,
      List<String> descriptions,
      List<String> dates,
      ) {
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
                builder: (context) => nationaldetails(
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
