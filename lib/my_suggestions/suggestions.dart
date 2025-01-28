import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:merge_voice_coplain/theme/appcolors.dart';
import 'dart:io';
import '../api/api_complain_legul_sugges_success_form.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

class suggestions extends StatefulWidget {
  const suggestions({super.key});

  @override
  State<suggestions> createState() => _suggestionsState();
}

class _suggestionsState extends State<suggestions> {
  FlutterSoundRecorder? _audioRecorder;
  FlutterSoundPlayer? _audioPlayer;
  bool _isRecording = false;
  bool _isPlaying = false;
  String? _audioPath;
  String _statusMessage = "لا يوجد تسجيل";
  int _timeLeft = 60; // مدة العداد (60 ثانية)
  Timer? _timer;
  int recordDuration = 0;
  Timer? timer;
  String? selectedTitleId;
  String? selectedLocation;
  int? userType;
  String? userId;
  List<Map<String, dynamic>> titles = [];
  List<File>? _files;
  final TextEditingController complaintContentController =
      TextEditingController();
  final TextEditingController whatsappController = TextEditingController();
  
  List<String> locations = [
    'بغداد', 'البصرة', 'الانبار', 'بابل', 'الديوانية', 'ديالى',
    'كربلاء', 'كركوك', 'المثنى', 'ميسان', 'النجف', 'نينوى',
    'صلاح الدين', 'ذي قار', 'واسط'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _audioRecorder = FlutterSoundRecorder();
    _audioPlayer = FlutterSoundPlayer();
    initRecorderAndPlayer();
  }

 

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (arguments != null) {
      setState(() {
        userType = arguments['userType'] as int?;
      });
      if (userType != null) {
        _loadTitles(userType!.toString());
      }
    }
  }

 Future<void> initRecorderAndPlayer() async {
    await Permission.microphone.request();
    await _audioRecorder!.openRecorder();
    await _audioPlayer!.openPlayer();
  }

Future<void> startRecording() async {
  // الحصول على المسار المناسب لحفظ الملفات
  final directory = await getApplicationDocumentsDirectory();
  _audioPath = '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.aac';

  // بدء التسجيل
  await _audioRecorder!.startRecorder(
    toFile: _audioPath,
  );
  setState(() {
    _isRecording = true;
    _statusMessage = "جاري التسجيل...";
    _timeLeft = 60; // إعادة ضبط العداد
  });

  // بدء العداد
  _startTimer();
}

  Future<void> stopRecording() async {
    await _audioRecorder!.stopRecorder();
    setState(() {
      _isRecording = false;
      _statusMessage = "تم إيقاف التسجيل.";
      _timer?.cancel();
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _timer?.cancel();
          stopRecording(); // إيقاف التسجيل تلقائيًا بعد انتهاء الدقيقة
        }
      });
    });
  }

Future<void> playAudio() async {
  if (_audioPath != null) {
    await _audioPlayer!.startPlayer(
      fromURI: _audioPath, // تشغيل الملف من المسار الكامل
      whenFinished: () {
        setState(() {
          _isPlaying = false;
          _statusMessage = "انتهى التشغيل.";
        });
      },
    );
    setState(() {
      _isPlaying = true;
      _statusMessage = "جاري التشغيل...";
    });
  } else {
    setState(() {
      _statusMessage = "لا يوجد تسجيل لتشغيله.";
    });
  }
}

  Future<void> stopAudio() async {
    await _audioPlayer!.stopPlayer();
    setState(() {
      _isPlaying = false;
      _statusMessage = "تم إيقاف التشغيل.";
    });
  }

Future<void> deleteAudio() async {
  if (_audioPath != null) {
    final file = File(_audioPath!);
    if (await file.exists()) {
      await file.delete(); // حذف الملف من الجهاز
    }
    _audioPath = null; // إعادة تعيين المسار إلى null
    setState(() {
      _statusMessage = "تم حذف التسجيل.";
    });
  }
}

@override
void dispose() {
  _audioRecorder?.closeRecorder();
  _audioPlayer?.closePlayer();
  _timer?.cancel();
  super.dispose();
}






  // Load user ID from SharedPreferences
  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('user_id')?.toString();
    });
  }

  // Load titles based on user type
  Future<void> _loadTitles(String userType) async {
    try {
      final api = Apicomplain();
      final fetchedTitles = await api.fetchTitles(userType);
      setState(() {
        titles = fetchedTitles;
      });
    } catch (e) {
      print('Failed to load titles: $e');
    }
  }

  // Submit complaint function
Future<void> _submitComplaint() async {
  // تحقق من صحة الإدخال
  if (selectedTitleId == null ||
      selectedLocation == null ||
      complaintContentController.text.isEmpty ||
      whatsappController.text.isEmpty ||
      userType == null ||
      userId == null ||
      !RegExp(r'^[0-9]{11}$').hasMatch(whatsappController.text)) {
    print('الحقل غير مكتمل أو الرقم غير صحيح'); // طباعة للتحقق من المدخلات
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('يرجى ملء جميع الحقول بشكل صحيح')),
    );
    return;
  }

  try {
    print('بدأ إرسال الشكوى'); // طباعة لفحص بداية عملية الإرسال

    // معلومات الشكوى التي يتم إرسالها
    print('تفاصيل الشكوى:');
    print('titleId: $selectedTitleId');
    print('location: $selectedLocation');
    print('content: ${complaintContentController.text}');
    print('whatsapp: ${whatsappController.text}');
    print('userType: $userType');
    print('userId: $userId');

    // if (_audioPath != null) {
    //   print('مسار ملف الصوت: $_audioPath');
    // } else {
    //   print('لا يوجد ملف صوتي');
    // }

    // استدعاء API لتقديم الشكوى
    final api = Apicomplain();
    final response = await api.submitComplaint(
      titleId: selectedTitleId!,
      location: selectedLocation!,
      content: complaintContentController.text,
      whatsapp: whatsappController.text,
      files: _files,
      audioFile: _audioPath != null ? File(_audioPath!) : null,
      userType: userType!,
      userId: userId!,
    );

    // التحقق من حالة النجاح
    if (response['success_complaint_count'] == true) {
      print('تم إرسال المقترح بنجاح'); // طباعة في حالة النجاح
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تقديم المقترح بنجاح')),
      );
      Navigator.of(context).pop();
    } else {
      print('فشل في إرسال المقترح'); // طباعة في حالة الفشل
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'فشل تقديم المقترح: ${response['error_complaint_count'] ?? 'غير محدد'}')),
      );
    }
  } catch (e) {
    print('حدث خطأ أثناء تقديم الشكوى: $e'); // طباعة عند حدوث استثناء
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('حدث خطأ أثناء تقديم المقترح: ${e.toString()}')),
    );
  }
}


  // Logout function
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
  // Build main UI
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
              height: screenHeight * 0.2,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1C1C1C), Color(0xFF1C1C1C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,

                ),
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
                      // Adding Hero for CircleAvatar to enable smooth transition
                      Hero(
                        tag: 'avatar-hero',  // Unique tag for Hero animation
                        child: CircleAvatar(
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
                      ),
                      Text(
                        'مشاركة مقترح جديدة',
                        style: GoogleFonts.tajawal(
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.05,
                          color: AppColors.backgroundColor,
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
                ),
              ),
            ),
          ),
          Positioned.fill(
            top: screenHeight * 0.18,
            child: SingleChildScrollView(
              child: Center(
                child: Container(
                  width: screenWidth * 0.9,
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.03,
                    vertical: screenHeight * 0.02,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),

                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.secondaryColor,
                        offset: Offset(0, 4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildDropdownField(
                        label: 'عنوان المحتوى',
                        items: titles.map((item) => item['name'] as String).toList(),
                        selectedValue: selectedTitleId,
                        onChanged: (value) {
                          setState(() {
                            selectedTitleId = titles.firstWhere(
                                (item) => item['name'] == value)['id'];
                          });
                        },
                        leadingIcon: 'assets/images/complain.svg',
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      _buildDropdownField(
                        label: 'مكان السكن',
                        items: locations,
                        selectedValue: selectedLocation,
                        onChanged: (value) {
                          setState(() {
                            selectedLocation = value;
                          });
                        },
                        leadingIcon: 'assets/images/location.svg',
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      _buildTextArea(
                        label: 'محتوى المقترح',
                        height: screenHeight * 0.3,
                        controller: complaintContentController,
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      _buildInputField(
                        label: 'رقم واتساب للتواصل',
                        leadingIcon: 'assets/images/chat.svg',
                        controller: whatsappController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'يرجى إدخال رقم';
                          }
                          final regex = RegExp(r'^[0-9]{1,11}$');
                          if (!regex.hasMatch(value)) {
                            return 'الرقم يجب أن يتكون من 11 رقم كحد أقصى';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      _buildFileAttachmentField(),
                      SizedBox(height: screenHeight * 0.02),
                      _buildAudioRecorderUI(),
                      SizedBox(height: screenHeight * 0.02),
                      _buildSubmitButton(context),
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

  Widget _buildFileAttachmentField() {
    return FileAttachmentWidget(
      onFilesSelected: (files) {
        setState(() {
          _files = files;
        });
      },
    );
  }

  Widget _buildDropdownField({
    required String label,
    required List<String> items,
    required String? selectedValue,
    required ValueChanged<String?> onChanged,
    String? leadingIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.tajawal(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: const Color(0xFFB2B2B2),
          ),
          textAlign: TextAlign.right,
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFA1A1A1)),
            borderRadius: BorderRadius.circular(9),
            color: Colors.white,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              if (leadingIcon != null)
                SvgPicture.asset(leadingIcon, width: 13, height: 13),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: items.contains(selectedValue) ? selectedValue : null,
                  onChanged: onChanged,
                  items: items.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                  dropdownColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

//ملف الصوت
 
Widget _buildAudioRecorderUI() {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      // الحالة النصية
      Text(
        _statusMessage,
        style: const TextStyle(
          color: Color(0xFF36623F), // اللون الأخضر
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 20),
      // الوقت المتبقي أثناء التسجيل
      Text(
        _isRecording ? "الوقت المتبقي: $_timeLeft ثانية" : "",
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
        ),
      ),
      const SizedBox(height: 20),
      // الأزرار
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // زر الحذف (يسار)
          _buildButton(
            icon: Icons.delete,
            onPressed: (_audioPath != null) ? deleteAudio : null, // تفعيل فقط عند وجود تسجيل
            color: (_audioPath != null) ? const Color(0xFF36623F) : Colors.grey,
          ),
          const SizedBox(width: 40), // مساحة بين الحذف والميكروفون
          // زر التسجيل (في المنتصف)
          _buildButton(
            icon: _isRecording ? Icons.stop : Icons.mic,
            onPressed: _isRecording ? stopRecording : startRecording,
            color: const Color(0xFF36623F),
          ),
          const SizedBox(width: 40), // مساحة بين الميكروفون والتشغيل
          // زر التشغيل (يمين)
          _buildButton(
            icon: (_isPlaying) ? Icons.stop : Icons.play_arrow,
            onPressed: (_audioPath != null)
                ? (_isPlaying ? stopAudio : playAudio) // تفعيل فقط عند وجود تسجيل
                : null,
            color: (_audioPath != null) ? const Color(0xFF36623F) : Colors.grey,
          ),
        ],
      ),
    ],
  );
}

 Widget _buildButton({
  required IconData icon,
  required VoidCallback? onPressed, // اجعل `onPressed` قابلًا لأن يكون فارغًا
  required Color color,
}) {
  return GestureDetector(
    onTap: onPressed, // لا تفعل شيء إذا كان `onPressed` null
    child: Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: onPressed != null ? Colors.grey.shade300 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(
        icon,
        color: onPressed != null ? color : Colors.grey, // تغيير اللون عند التعطيل
        size: 30,
      ),
    ),
  );
}

// ملف الصوت

  Widget _buildTextArea({
    required String label,
    required double height,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.tajawal(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: const Color(0xFFB2B2B2),
          ),
          textAlign: TextAlign.right,
        ),
        const SizedBox(height: 8),
        Container(
          height: height,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFA1A1A1)),
            borderRadius: BorderRadius.circular(9),
            color: Colors.white,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: TextFormField(
            controller: controller,
            maxLines: null,
            decoration: const InputDecoration(
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    // required String placeholder,
    required String leadingIcon,
    required TextEditingController controller,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.tajawal(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: const Color(0xFFB2B2B2),
          ),
          textAlign: TextAlign.right,
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFA1A1A1)),
            borderRadius: BorderRadius.circular(9),
            color: Colors.white,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              SvgPicture.asset(leadingIcon, width: 13, height: 13),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    // hintText: placeholder,
                  ),
                  keyboardType: TextInputType.phone,
                  validator: validator,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تأكيد الإرسال'),
          content: const Text('هل أنت متأكد من تقديم المقترح'),
          actions: <Widget>[
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Centers the buttons horizontally
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('إلغاء'),
                ),
                const SizedBox(
                    width:
                        30), // Adds fixed horizontal space between the buttons
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await _submitComplaint();
                  },
                  child: const Text('تأكيد'),
                ),
              ],
            )
          ],
        );
      },
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth * 0.8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: AppColors.buttonColor,
      ),
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: ElevatedButton(
        onPressed: () => _showConfirmationDialog(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
        child: Text(
          ' ارسال',
          style: GoogleFonts.tajawal(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.backgroundColor,
          ),
        ),
      ),
    );
  }
}

class FileAttachmentWidget extends StatefulWidget {
  final ValueChanged<List<File>> onFilesSelected;

  const FileAttachmentWidget({super.key, required this.onFilesSelected});

  @override
  _FileAttachmentWidgetState createState() => _FileAttachmentWidgetState();
}

class _FileAttachmentWidgetState extends State<FileAttachmentWidget> {
  List<File>? _files;
  // int _cameraUsageCount = 0;

  void _showOptionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('اختيار صور'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImages();
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_file),
              title: const Text('اختيار ملف PDF'),
              onTap: () {
                Navigator.of(context).pop();
                _pickPdf();
              },
            ),
            // ListTile(
            //   leading: const Icon(Icons.camera_alt),
            //   title: const Text('استخدام الكاميرا'),
            //   onTap: () {
            //     Navigator.of(context).pop();
            //     _pickImagesFromCamera();
            //   },
            // ),
          ],
        );
      },
    );
  }





void _pickImages() async {
  try {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
    );

    if (result != null && result.files.isNotEmpty) {
      if (result.files.length <= 5) {
        final allowedExtensions = ['jpg', 'jpeg', 'png']; // أنواع الصور المسموح بها

        final List<File> files = [];

        for (var file in result.files) {
          final fileSizeKB = file.size / 1024; // تحويل الحجم إلى كيلوبايت
          final extension = file.extension?.toLowerCase(); // الحصول على الامتداد

          // التحقق من نوع الصورة
          if (extension == null || !allowedExtensions.contains(extension)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('يجب أن تكون الصورة من نوع JPG أو PNG')),
            );
            return; // إيقاف العملية إذا كان هناك نوع غير مدعوم
          }

          File processedFile = File(file.path!);

          // ضغط الصورة إذا كان الحجم أكبر من 500 كيلوبايت
          if (fileSizeKB > 500) {
            final imageBytes = processedFile.readAsBytesSync();
            final decodedImage = img.decodeImage(imageBytes);

            if (decodedImage != null) {
  // ضغط الصورة بجودة 85%
  final compressedImage = img.encodeJpg(decodedImage, quality: 85);
  processedFile.writeAsBytesSync(compressedImage); // تعديل الملف مباشرةً
}

            // التحقق من الحجم بعد الضغط
            final newFileSizeKB = processedFile.lengthSync() / 1024;
            if (newFileSizeKB > 500) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('الصورة "${file.name}" حجمها لا يزال أكبر من 500 كيلوبايت بعد الضغط')),
              );
              return; // إيقاف العملية إذا لم تنجح عملية الضغط
            }
          }

          files.add(processedFile);
        }

        // تحديث الحالة فقط إذا كانت جميع الصور مقبولة
        setState(() {
          _files = files;
        });
        widget.onFilesSelected(_files!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يمكنك رفع 5 صور كحد أقصى فقط')),
        );
      }
    }
  } catch (e) {
    print('Error picking files: $e');
  }
}






void _pickPdf() async {
  try {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.isNotEmpty) {
      final file = File(result.files.single.path!);

      // التحقق من حجم الملف
      final fileSizeMB = await file.length() / (1024 * 1024); // تحويل الحجم إلى ميجابايت
      if (fileSizeMB > 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الملف يجب أن يكون أقل من 2 ميجابايت')),
        );
        return; // إيقاف العملية إذا تجاوز الحجم
      }

      // إذا كان الحجم أقل من 2 ميجابايت، تابع العملية
      setState(() {
        _files = [file];
      });
      widget.onFilesSelected(_files!);
    }
  } catch (e) {
    print('Error picking file: $e');
  }
}






  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: _showOptionsBottomSheet,
          child: CustomPaint(
            painter: DashedBorderPainter(),
            child: Container(
              width: screenWidth * 0.9,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              alignment: Alignment.center,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add,
                    color: Color.fromARGB(255, 198, 198, 197),
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    '(يجب اضافةاما صور او ملف ولايمكن الدمج بينهما)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Color.fromARGB(255, 198, 198, 197),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        if (_files != null && _files!.isNotEmpty) ...[
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _files!.map((file) {
              return Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                  image: file.path.endsWith('.pdf')
                      ? null
                      : DecorationImage(
                          image: FileImage(file),
                          fit: BoxFit.cover,
                        ),
                ),
                child: file.path.endsWith('.pdf')
                    ? const Center(
                        child: Icon(Icons.picture_as_pdf, color: Colors.red))
                    : null,
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromARGB(255, 178, 178, 176) // لون الداش
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    const dashWidth = 8.0; // طول الداش
    const dashSpace = 4.0; // المسافة بين الداشات
    double startX = 0;

    // رسم الحدود العلوية
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }

    startX = 0; // إعادة تعيين startX للحدود اليسرى
    // رسم الحدود اليسرى
    while (startX < size.height) {
      canvas.drawLine(
        Offset(0, startX),
        Offset(0, startX + dashWidth),
        paint,
      );
      startX += dashWidth + dashSpace;
    }

    startX = size.width; // إعادة تعيين startX للحدود اليمنى
    // رسم الحدود اليمنى
    while (startX > 0) {
      canvas.drawLine(
        Offset(startX, size.height),
        Offset(startX - dashWidth, size.height),
        paint,
      );
      startX -= dashWidth + dashSpace;
    }

    startX = size.height; // إعادة تعيين startX للحدود السفلية
    // رسم الحدود السفلية
    while (startX > 0) {
      canvas.drawLine(
        Offset(size.width, startX),
        Offset(size.width, startX - dashWidth),
        paint,
      );
      startX -= dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
