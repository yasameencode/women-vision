import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

class JoboppPage extends StatelessWidget {
  final String title;
  final String image;
  final String description;
  final String date;

  const JoboppPage({
    super.key,
    required this.title,
    required this.image,
    required this.description,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Top Container for Image and Forward Arrow Button
          Stack(
            children: [
              // Image Container (350x200)
              Container(
                width: double.infinity,
                // height: 375, // Fixed height
                height: MediaQuery.of(context).size.height * 0.4,
                decoration: BoxDecoration(
                  color: Colors.white, // Placeholder color
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ), // Rounded corners at the bottom
                  image: DecorationImage(
                    image: NetworkImage(
                        image), // استخدم NetworkImage لتحميل الصورة من الإنترنت
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // Positioned Arrow Forward Button
              Positioned(
                top: 40,
                right: 16,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white, // لون الخلفية الأبيض
                    shape: BoxShape.circle, // تحويل الـ Container إلى دائرة
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.black, // لون الأيقونة الأسود
                      size: 28,
                    ),
                    onPressed: () {
                      // العودة إلى الصفحة السابقة
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16), // Spacing between image and content

          // Second Container for Calendar Button and Text
          Align(
            alignment:
                Alignment.centerRight, // Aligns the container to the right
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white, // Background color
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 3,
                    blurRadius: 5,
                    offset: const Offset(0, 3), // Shadow position
                  ),
                ],
              ),
              // Wrapping with SizedBox to control size
              child: Container(
  margin: const EdgeInsets.only(right: 16), // إضافة هامش من اليمين
  child: SizedBox(
    width: 130,
    height: 40,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            date, // استبدال النص الثابت بـ date
            style: const TextStyle(
              fontSize: 12, // Adjusted size to fit within 26px height
              fontWeight: FontWeight.bold,
            ),
            // overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          icon: SvgPicture.asset(
            'assets/images/agenda.svg',
            width: 24,
            height: 24,
          ),
          onPressed: () {
            // Handle button press
          },
        ),
      ],
    ),
  ),
),
            ),
          ),
          const SizedBox(height: 16),

          // New Container for Additional Text

          const SizedBox(height: 3), // Add spacing before the description

          // Scrollable Container for the Description
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Html(
                  data: description,
                  onAnchorTap: (String? url, _, __) {
                    if (url != null) {
                      _launchUrl(url);
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $url');
    }
  }
}
