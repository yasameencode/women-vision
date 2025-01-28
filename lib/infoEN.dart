import 'package:flutter/material.dart';
import 'theme/appcolors.dart';

class infoPageEN extends StatelessWidget {
  const infoPageEN({super.key});

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
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const SizedBox(height: 100), // To add some space from the top for the image
                      // Small Image Icon in the top center
                      Center(
                        child: Image.asset(
                          'assets/images/information.png',
                          width: 60, // Resize image to a smaller size
                          height: 60,
                        ),
                      ),
                      const SizedBox(height: 20), // Space after the image

                      const Text(
                        'About the App',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondaryColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'The Women\'s Eye app is an initiative by the Supreme Council for Women to support women through a variety of interactive and non-interactive services.',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.secondaryColor,
                        ),
                        textAlign: TextAlign.end,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'App Sections',
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
                                  text: 'Complaints: ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold, // Make this part bold
                                    color: AppColors.secondaryColor,
                                  ),

                                ),
                                TextSpan(
                                  text: 'The app provides a platform for women to submit complaints in various areas such as extortion, violence, or any other issues related to women\'s rights. These complaints are processed in collaboration with relevant authorities with full confidentiality and transparency to provide effective and swift solutions. Users can submit, view, and modify their complaints by pressing the complaints icon on the homepage. Modifications can be made within the first 15 minutes of submitting the complaint.',
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
                                  text: 'Legal Consultations: ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold, // Make this part bold
                                    color: AppColors.secondaryColor,
                                  ),
                                ),
                                TextSpan(
                                  text: 'This section allows users to inquire about various legal matters, with a specialized legal team available to communicate with users and provide appropriate consultations.',
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
                                  text: 'Success Stories: ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold, // Make this part bold
                                    color: AppColors.secondaryColor,
                                  ),
                                ),
                                TextSpan(
                                  text: 'An interactive section that allows women to share their success stories and inspire others.',
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
                                  text: 'My Suggestions: ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold, // Make this part bold
                                    color: AppColors.secondaryColor,
                                  ),
                                ),
                                TextSpan(
                                  text: 'An interactive section that allows women to submit their suggestions to improve the app or any proposals regarding the improvement of the council\'s work.',
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
                                  text: 'The app also offers other sections that can be explored to discover new news, articles on health, job opportunities, outstanding talents, and many other important topics.',
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
