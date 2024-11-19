import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:merge_voice_coplain/EditPage.dart';
import 'package:merge_voice_coplain/theme/appcolors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_complain_legul_sugges_success_form.dart';
import '../buttomnav.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;




class LegalListView extends StatefulWidget {
  final int userType;

  const LegalListView({super.key, required this.userType});

  @override
  _LegalListViewState createState() => _LegalListViewState();
}

class _LegalListViewState extends State<LegalListView> {
  int _selectedIndex = 1;
  int? userType;
  String? userId;
  List<Map<String, dynamic>> titles = []; 
  List<Map<String, dynamic>> filteredTitles = []; 
  TextEditingController searchController = TextEditingController(); 
  bool isLoading = true; 
  String lang = 'ar';

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      _filterTitles(searchController.text);
    });
  }

  void _filterTitles(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredTitles = List.from(titles); // نعيد ضبط العناوين المفلترة لتكون هي نفسها العناوين الأصلية
      });
    } else {
      setState(() {
        filteredTitles = titles
            .where((title) =>
                title['name'] != null &&
                title['name'].toString().toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (arguments != null) {
      setState(() {
        userType = arguments['userType'] as int? ?? widget.userType;
      });
    } else {
      userType = widget.userType;
    }

    _loadUserId().then((_) {
      _fetchFormSubmissions(); // Fetch submissions after loading userId
    });
  }

final String baseUrl = "http://eyn.ur.gov.iq/"; // ضع رابط الخادم الأساسي هنا
Future<void> _fetchFormSubmissions() async {
  if (userId != null) {
    try {
      final api = Apicomplain();
      List<dynamic> submissions = await api.formSubmissions(userType.toString(), int.parse(userId!));
      setState(() {
        titles = submissions.map((submission) {
          return {
            'name': submission['Form_name'] ?? 'عنوان غير متوفر',
            'details': submission['submission_data'] ?? {},
            'status': submission['status'] ?? 'غير متاح',
            'created_at': submission['created_at'] ?? '',
            'attachments': (submission['attachments'] as List<dynamic>).map((attachment) {
              final attachmentId = attachment['attachment_id'];
              final filePath = attachment['file_path'];
              
              // إنشاء المسار الكامل باستخدام baseUrl
              final fullPath = "$baseUrl/$filePath".replaceAll('./', '');

              // طباعة المسار الكامل للتحقق
              print("Full file path: $fullPath");

              final fileName = filePath?.split('/').last;
              return {
                'attachment_id': attachmentId,
                'file_path': fullPath, // استخدام المسار الكامل هنا
                'file_name': fileName,
              };
            }).toList(),
            'form_id': submission['form_id'],
          };
        }).toList();
        filteredTitles = List.from(titles);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        titles = [];
        filteredTitles = [];
        isLoading = false;
      });
      print('Error fetching submissions: $e');
    }
  }
}

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('user_id')?.toString();
    });
  }

  void _showSubmissionDialog(int index) {
    final title = filteredTitles[index];
    final formName = title['name'] ?? 'لايوجد عنوان';
    final details = title['details'] as Map<String, dynamic>?;
    final status = title['status'] ?? 'غير متاح';
    final createdAt = DateTime.parse(title['created_at']);
    bool canEdit = DateTime.now().difference(createdAt).inMinutes < 15;


    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            formName,
            style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 16),
            textAlign: TextAlign.right,
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text(
                  'حالة الشكوى الحالية: $status',
                  style: GoogleFonts.tajawal(fontSize: 14, color: Colors.black),
                  textAlign: TextAlign.right,
                ),
                ...?details?.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      '${entry.key}: ${entry.value}',
                      style: GoogleFonts.tajawal(fontSize: 14, color: Colors.black),
                      textAlign: TextAlign.right,
                    ),
                  );
                }),
              ],
            ),
          ),
          actions: <Widget>[
            if (canEdit)
      TextButton(
  onPressed: () {
    // جلب جميع attachment_id من قائمة attachments
    final attachments = title['attachments'] as List<dynamic>;
    if (attachments.isNotEmpty) {
      final List<int> attachmentIds = attachments
          .map((attachment) => attachment['attachment_id'] as int)
          .toList();
      print("Selected attachment_ids: $attachmentIds"); // طباعة جميع attachment_ids للتحقق
      _navigateToEditPage(index, attachmentIds); // تمرير القائمة بدلًا من عنصر واحد
    } else {
      print("No attachments to edit");
    }
  },
  child: Text('تعديل', style: GoogleFonts.tajawal()),
),



            TextButton(
              child: Text('إغلاق', style: GoogleFonts.tajawal(fontSize: 14), textAlign: TextAlign.right),
              onPressed: () {
                Navigator.of(context).pop();
                _filterTitles(searchController.text);
              },
            ),
          ],
        );
      },
    );
  }




void _navigateToEditPage(int index, List<int> attachmentIds) {
  print("Attachment IDs in _navigateToEditPage: $attachmentIds");

  final submission = filteredTitles[index];
  final List<String> filePaths = (submission['attachments'] as List<dynamic>)
      .map((attachment) => attachment['file_path'].toString())
      .where((path) => path.isNotEmpty)
      .toList();

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => EditPage(
        submissionIndex: index,
        submissionData: {
          ...submission['details'],
          'form_id': submission['form_id'],
          'attachment_ids': attachmentIds,
          'attachments': submission['attachments'],
        },
        filePaths: filePaths, // تمرير المسارات هنا
      ),
    ),
  );
}



  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
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







  @override
  Widget build(BuildContext context) {
      final double screenHeight = MediaQuery.of(context).size.height;
    // final double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(
        children: [
          // AppBar with gradient and custom content
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: PreferredSize(
              preferredSize: const Size.fromHeight(180), // Adjust AppBar height
              child: Container(
                  height: screenHeight * 0.20,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF1C1C1C),
                      Color(0xFF1C1C1C),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: AppBar(
                  automaticallyImplyLeading: false,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 18.5,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_rounded,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: PopupMenuButton<int>(
                icon: SvgPicture.asset(
                  'assets/images/menu.svg',
                  width: 24,
                  height: 24,
                  color: const Color.fromARGB(255, 255, 255, 255),
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
                ],
                onSelected: (value) {
                  if (value == 1) {
                    _logout();
                  }
                },
              ),
            ),
                    ],
                  ),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
              ),
            ),
          ),
          // Positioned container above the AppBar
          Positioned(
            top: 110,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 327,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'الاستشارات القانونية',
                      style: GoogleFonts.tajawal(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppColors.headerColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'الاطلاع على الاستشارات السابقة وتقديم استشارة جديدة ',
                      style: GoogleFonts.tajawal(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: AppColors.textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Middle content
          Positioned.fill(
            top: 240,
            child: Column(
              children: [
                Container(
                  width: 351,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD3D3D3), // Gray color
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.search, color: Colors.grey[600]), // زر البحث الأيقوني
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          decoration: const InputDecoration(
                            hintText: 'بحث',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16),
                          ),
                          style: GoogleFonts.tajawal(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  'الاستشارات السابقة',
                  style: GoogleFonts.tajawal(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: const Color(0xec000000),
                  ),
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(), // عرض دائرة التحميل أثناء جلب البيانات
                        )
                      : filteredTitles.isEmpty
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
  'assets/images/File searching-rafiki 1.svg', // المسار الصحيح لملف SVG
  width: 100,
  height: 100,
),
                                const SizedBox(height: 20), // إضافة مسافة بين الصورة والنص
                                Text(
                                  'لا توجد استشارات لعرضها حاليًا',
                                  style: GoogleFonts.tajawal(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: const Color(0xec000000),
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              itemCount: filteredTitles.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                  title: Row(
                                    children: [
                                      SvgPicture.asset(
                                        'assets/images/agenda.svg',
                                        width: 24,
                                        height: 24,
                                        color: AppColors.buttonColor,
                                      ),
                                      const SizedBox(width: 16), // مسافة بين الأيقونة والنص
                                      Expanded(
                                        child: Text(
                                          filteredTitles[index]['name'] ?? 'لايوجد عنوان',
                                          style: GoogleFonts.tajawal(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            color: const Color(0xec000000),
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    _showSubmissionDialog(index);
                                  },
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/legal_consul',
                  arguments: {'userType': widget.userType},
                );
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.buttonColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
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
}
