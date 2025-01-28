import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class PermissionManager {

  Future<void> requestAllPermissions(BuildContext context) async {
    final statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    bool allGranted = statuses.values.every((status) => status.isGranted);
    if (!allGranted) {
      // التعامل مع حالة الرفض
      statuses.forEach((permission, status) {
        if (status.isDenied) {
          _handlePermissionStatus(status, context, permission.toString().split('.').last);
        }
      });
    }
  }

  // معالجة حالة أذونات الرفض
  void _handlePermissionStatus(PermissionStatus status, BuildContext context, String permissionName) {
    if (status.isGranted) {
      // إذن مُنح
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم منح إذن $permissionName')),
      );
    } else if (status.isDenied) {
      // إذن مُرفوض هذه المرة فقط
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم رفض إذن $permissionName. يرجى منحه في الإعدادات.')),
      );
    } else if (status.isPermanentlyDenied) {
      // إذن مُرفوض بشكل دائم
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم رفض إذن $permissionName بشكل دائم. الرجاء الذهاب إلى الإعدادات لمنحه.'),
          action: SnackBarAction(
            label: 'إعدادات',
            onPressed: () {
              openAppSettings();
            },
          ),
        ),
      );
    }
  }
}
