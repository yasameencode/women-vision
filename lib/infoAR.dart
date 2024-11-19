import 'package:flutter/material.dart';
import 'theme/appcolors.dart';

class Infoar extends StatelessWidget {
  const Infoar({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12), // Border radius of 12
                  color: Colors.white, // You can change the background color
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0), // Inner padding for content
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 100), // To add some space from the top for the image
                      // Small Image Icon in the top center
                      Center(
                        child: Image.asset(
                                'assets/images/info.jpg',
                                width: 99.3,
                                height: 42,
                              ),
                      ),
                      const SizedBox(height: 20), // Space after the image

                      const Text(
                        'عن التطبيق',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondaryColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'تطبيق عين المرأة هو تطبيق مقدم من المجلس الاعلى لشؤون المرأة لدعم النساء من خلال مجموعة من الخدمات المتنوعة التفاعلية والغير تفاعلية.',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.secondaryColor,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'اقسام التطبيق',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondaryColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Column(
                        children: [
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'الشكاوى: ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold, // Make this part bold
                                    color: AppColors.secondaryColor,
                                  ),
                                ),
                                TextSpan(
                                  text: 'يوفر التطبيق للنساء منصة لتقديم الشكاوى في مختلف المجالات مثل الابتزاز، العنف، أو أي قضايا أخرى تتعلق بحقوق المرأة. يتم معالجة هذه الشكاوى بالشراكة مع السلطات المعنية وبكل سرية وشفافية لتقديم حلول فعالة وسريعة يمكن للمستخدمات تقديم الشكوى وارسالها وامكانية عرضها وتعديلها من خلال الضغط على أيقونة الشكاوى في الصفحة الرئيسية يمكن التعديل خلال أول ربع ساعة من إرسال الشكوى فقط.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.secondaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10), // Add space between sections if needed
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'الاستشارات القانونية: ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold, // Make this part bold
                                    color: AppColors.secondaryColor,
                                  ),
                                ),
                                TextSpan(
                                  text: 'يتيح القسم الاستفسار عن مختلف القضايا القانونية حيث يوجد فريق قانوني مختص للتواصل مع المستخدمات وتقديم الاستشارة المناسبة.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.secondaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10), // Add space between sections if needed
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'قصص النجاح: ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold, // Make this part bold
                                    color: AppColors.secondaryColor,
                                  ),
                                ),
                                TextSpan(
                                  text: 'قسم تفاعلي يتيح للنساء مشاركة قصص نجاحهن والإلهام لبعضهن.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.secondaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10), // Add space between sections if needed
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'مقترحاتي: ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold, // Make this part bold
                                    color: AppColors.secondaryColor,
                                  ),
                                ),
                                TextSpan(
                                  text: 'قسم تفاعلي يمكن النساء من ارسال مقترحاتهن لتحسين التطبيق او اي مقترح يخص تحسين عمل المجلس.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.secondaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10), // Add space between sections if needed
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'يوفر التطبيق اقسام اخرى يمكن تصفحها لأستكشاف اخبار جديدة مقالات عن الصحة فرص عمل كفاءات متميزة ,والعديد من المواضيع المهمة  ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold, // Make this part bold
                                    color: AppColors.secondaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
