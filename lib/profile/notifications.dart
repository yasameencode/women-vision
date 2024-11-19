import 'package:flutter/material.dart';
import '../api/api_NotificationsPage.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late Future<List<dynamic>> _notifications;
  final NotificationsService _notificationsService = NotificationsService(); // إنشاء كائن من كلاس جلب الإشعارات

  @override
  void initState() {
    super.initState();
    _markAllNotificationsAsRead(); // تحديث حالة جميع الإشعارات عند فتح الصفحة
    _notifications = _notificationsService.fetchNotifications(); // استدعاء دالة جلب الإشعارات
  }

  // دالة لتحديث حالة جميع الإشعارات إلى "read"
  void _markAllNotificationsAsRead() {
    _notificationsService.markAllAsRead().then((_) {
      print('All notifications marked as read');
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to mark notifications as read')),
      );
    });
  }

  // عند سحب الإشعار إلى اليمين، يتم حذف الإشعار
  void _deleteNotification(int notificationId) {
    _notificationsService.deleteNotification(notificationId).then((_) {
      setState(() {
        _notifications = _notificationsService.fetchNotifications(); // إعادة تحميل الإشعارات بعد الحذف
      });
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete notification')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الاشعارات'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _notifications,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return const Center(child: Text('لا توجد اشعارات'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final notification = snapshot.data![index];
                return Dismissible(
                  key: Key(notification['notification_id'].toString()), // مفتاح مميز لكل إشعار
                  direction: DismissDirection.endToStart, // السحب من اليمين إلى اليسار
                  onDismissed: (direction) {
                    _deleteNotification(notification['notification_id']);
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   const SnackBar(content: Text('تم حذف الإشعار')),
                    // );
                  },
                  background: Container(
                    alignment: Alignment.centerRight, // أيقونة الحذف تظهر في الجهة اليمنى
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    color: Colors.red, // اللون الأحمر الذي يظهر عند السحب
                    child: const Icon(Icons.delete, color: Colors.white, size: 30), // أيقونة سلة النفايات
                  ),
                  child: InkWell(
                    onTap: () {
                      // تم إزالة التنقل إلى DetailsPage، يمكنك هنا وضع أي عملية أخرى أو تركها فارغة
                      // على سبيل المثال:
                      print('Notification tapped: ${notification['notification_id']}');
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10), // حواف ناعمة
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1), // ظل خفيف
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification['content'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            notification['created_at'],
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
