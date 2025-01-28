import 'package:flutter/material.dart';
import 'package:merge_voice_coplain/option.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/appcolors.dart';
import 'profile/profile_page.dart';
import 'package:merge_voice_coplain/api/api_NotificationsPage.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onItemTapped;
  final String lang;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onItemTapped,
    required this.lang,
  });

  @override
  _CustomBottomNavigationBarState createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  bool hasUnreadNotifications = false;
  final NotificationsService notificationsService = NotificationsService();

  @override
  void initState() {
    super.initState();
    _checkUnreadNotifications();
  }

  Future<void> _checkUnreadNotifications() async {
    bool hasUnread = await notificationsService.checkUnreadNotifications();
    setState(() {
      hasUnreadNotifications = hasUnread;
    });
  }

  Future<int?> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int?>(
      future: _getUserId(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 60,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final int? userId = snapshot.data;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            BottomNavigationBar(
              backgroundColor: Colors.white,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home),
                  label: widget.lang == 'ar' ? 'الرئيسية' : 'Home',
                ),
                const BottomNavigationBarItem(
                  icon: SizedBox(
                    height: 0,
                  ),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Stack(
                    children: [
                      Icon(userId != null ? Icons.person : Icons.settings),
                      if (hasUnreadNotifications) // عرض الدائرة الحمراء إذا كانت هناك إشعارات غير مقروءة
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 12,
                              minHeight: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  label: widget.lang == 'ar'
                      ? (userId != null ? 'الملف الشخصي' : 'الخيارات')
                      : (userId != null ? 'Profile' : 'Options'),
                ),
              ],
              currentIndex: widget.currentIndex,
              selectedItemColor: AppColors.buttonColor,
              unselectedItemColor: Colors.grey,
              onTap: (index) async {
                widget.onItemTapped(index);
                if (index == 2) {
                  if (userId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfilePage(),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OptionPage(),
                      ),
                    );
                  }
                } else if (index == 0) {
                  Navigator.pushNamed(context, '/cards');
                }
              },
              type: BottomNavigationBarType.fixed,
              selectedLabelStyle: const TextStyle(fontSize: 12),
              unselectedLabelStyle: const TextStyle(fontSize: 10),
            ),
            Positioned(
              top: -50,
              left: MediaQuery.of(context).size.width / 2 - 75,
              child: GestureDetector(
                onTap: () {
                  widget.onItemTapped(1);
                },
                child: Image.asset(
                  'assets/images/wlogo2.png',
                  height: 150,
                  width: 150,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
