
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:merge_voice_coplain/permission/permissions.dart';
import 'package:merge_voice_coplain/theme/appcolors.dart';
import 'dart:io';
import '../api/api_complain_legul_sugges_success_form.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:path/path.dart' as p;
import 'dart:convert';
import 'package:http/http.dart' as http;

// import 'package:dotted_border/dotted_border.dart';

class LegalConsulPage extends StatefulWidget {
  const LegalConsulPage({super.key});

  @override
  State<LegalConsulPage> createState() => _LegalConsulPageState();
}

class _LegalConsulPageState extends State<LegalConsulPage> {
  final AudioRecorder audioRecorder = AudioRecorder();
  final AudioPlayer audioPlayer = AudioPlayer();
  // final _formKey = GlobalKey<FormState>();
  String? recordingPath;
  bool isRecording = false;
  bool isPlaying = false;
  int recordDuration = 0; 
  Timer? timer;
  String? selectedTitle;
  String? selectedLocation;
  int? userType;
  String? userId; 
  List<Map<String, dynamic>> titles = [];
  String? selectedTitleId;
  List<String> locations = [
    'بغداد',
    'البصرة',
    'الانبار',
    'بابل',
    'الديوانية',
    'ديالى',
    'كربلاء',
    'كركوك',
    'المثنى',
    'ميسان',
    'النجف',
    'نينوى',
    'صلاح الدين',
    'ذي قار',
    'واسط'
  ];
  List<File>? _files;
  final TextEditingController complaintContentController =
      TextEditingController();
  final TextEditingController whatsappController = TextEditingController();

@override
void initState() {
  super.initState();
  _loadUserId(); 
}

@override
void didChangeDependencies() {
  super.didChangeDependencies();

  // Get userType from arguments
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


void _checkPermissions() async {
  PermissionManager permissionManager = PermissionManager();
  await permissionManager.requestAllPermissions(context);
}


Future<void> _loadUserId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  setState(() {
    userId = prefs.getInt('user_id')?.toString(); 
  });
}

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
Future<void> _submitComplaint() async {
  // تحقق من صحة البيانات
  if (selectedTitleId == null ||
      selectedLocation == null ||
      complaintContentController.text.isEmpty ||
      whatsappController.text.isEmpty ||
      userType == null ||
      userId == null ||
      !RegExp(r'^[0-9]{1,11}$').hasMatch(whatsappController.text)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('يرجى ملء جميع الحقول بشكل صحيح')),
    );
    return;
  }

  print('UserType: $userType');
  try {
    final api = Apicomplain();

    // إرسال الشكوى
    final response = await api.submitComplaint(
      titleId: selectedTitleId!,
      location: selectedLocation!,
      content: complaintContentController.text,
      whatsapp: whatsappController.text,
      files: _files,
      audioFile: recordingPath != null ? File(recordingPath!) : null,
      userType: userType!,
      userId: userId!,
    );

    // التحقق من حالة النجاح في الاستجابة
    if (response['success_complaint_count'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تقديم الاستشارة بنجاح')),
      );
      Navigator.of(context).pop();
    } else   if (response['success_complaint_count'] == false) {
      // عرض رسالة الخطأ المحددة في الاستجابة
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل تقديم الاستشارة: ${response['error_complaint_count'] ?? 'غير محدد'}')),
      );
    }
  } catch (e) {
    // عرض رسالة خطأ عامة في حالة حدوث استثناء
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('حدث خطأ أثناء تقديم الاستشارة: ${e.toString()}')),
    );
  }
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
    final double screenWidth = MediaQuery.of(context).size.width;
return Scaffold(
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
              colors: [
                Color(0xFF1C1C1C),
                 Color(0xFF1C1C1C),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                    CircleAvatar(
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
                      Text(
                    'مشاركة استشارة جديدة',
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
                borderRadius: BorderRadius.circular(20),
                color: AppColors.backgroundColor,
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
                    items: titles
                        .map((item) => item['name'] as String)
                        .toList(),
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
                    label: 'محتوى الاستشارة',
                    height: screenHeight * 0.3,
                    controller: complaintContentController,
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  _buildInputField(
                    label: 'رقم واتساب للتواصل',
                    // placeholder: 'الرقم',
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
                  _buildSubmitButton(context), // Add submit button
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
      children: [
        if (recordingPath != null)
          const Text(
            "التسجيل جاهز للتشغيل",
            style: TextStyle(fontSize: 18, color: Colors.green),
          ),
        if (recordingPath == null)
          const Text(
            "لايوجد تسجيل",
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _recordingButton(),
            const SizedBox(width: 20),
            _playbackButton(),
            const SizedBox(width: 20),
            _deleteRecordingButton(),
          ],
        ),
        const SizedBox(height: 20),
        if (isRecording) _buildRecordingDuration(),
      ],
    );
  }

  Widget _buildRecordingDuration() {
    final minutes = (recordDuration / 60).floor().toString().padLeft(2, '0');
    final seconds = (recordDuration % 60).toString().padLeft(2, '0');
    return Text(
      "$minutes:$seconds",
      style: const TextStyle(fontSize: 30, color: Colors.blue),
    );
  }

  Widget _recordingButton() {
    return FloatingActionButton(
      onPressed: () async {
        if (isRecording) {
          String? filepath = await audioRecorder.stop();
          timer?.cancel();
          if (filepath != null) {
            setState(() {
              isRecording = false;
              recordingPath = filepath;
            });
          }
        } else {
          if (await audioRecorder.hasPermission()) {
            final Directory directory = await getApplicationDocumentsDirectory();
            final String filepath = p.join(directory.path, "recording.wav");
            await audioRecorder.start(const RecordConfig(), path: filepath);

            setState(() {
              isRecording = true;
              recordingPath = null;
              recordDuration = 0;
            });

            timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
              setState(() {
                recordDuration++;
              });
              if (recordDuration >= 60) {
                timer?.cancel();
                _stopRecording();
              }
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("تحتاج إلى منح إذن التسجيل")),
            );
          }
        }
      },
      child: Icon(
        isRecording ? Icons.stop : Icons.mic,
      ),
    );
  }

  Widget _playbackButton() {
    return FloatingActionButton(
      onPressed: recordingPath == null
          ? null
          : () async {
              if (isPlaying) {
                await audioPlayer.stop();
                setState(() {
                  isPlaying = false;
                });
              } else {
                await audioPlayer.setFilePath(recordingPath!);
                audioPlayer.play();
                setState(() {
                  isPlaying = true;
                });
                audioPlayer.playerStateStream.listen((state) {
                  if (state.playing == false) {
                    setState(() {
                      isPlaying = false;
                    });
                  }
                });
              }
            },
      backgroundColor: recordingPath == null ? Colors.grey : Colors.blue,
      child: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
    );
  }

  Widget _deleteRecordingButton() {
    return FloatingActionButton(
      onPressed: recordingPath == null
          ? null
          : () {
              setState(() {
                recordingPath = null;
              });
            },
      backgroundColor: recordingPath == null ? Colors.grey : Colors.red,
      child: const Icon(Icons.delete),
    );
  }

  void _stopRecording() async {
    if (isRecording) {
      String? filepath = await audioRecorder.stop();
      timer?.cancel();
      if (filepath != null) {
        setState(() {
          isRecording = false;
          recordingPath = filepath;
        });
      }
    }
  }


  @override
  void dispose() {
    audioPlayer.dispose();
    timer?.cancel();
    super.dispose();
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
        content: const Text('هل أنت متأكد من تقديم الشكوى؟'),
        actions: <Widget>[
          Row(
  mainAxisAlignment: MainAxisAlignment.center, // Centers the buttons horizontally
  children: [
    TextButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      child: const Text('إلغاء'),
    ),
    const SizedBox(width: 30), // Adds fixed horizontal space between the buttons
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

        final files = result.files.map((file) {
          final fileSizeKB = file.size / 1024; // تحويل الحجم إلى كيلوبايت
          final extension = file.extension?.toLowerCase(); // الحصول على الامتداد

          // التحقق من نوع الصورة
          if (extension == null || !allowedExtensions.contains(extension)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('يجب أن تكون الصورة من نوع JPG أو PNG')),
            );
            return null; // تجاهل الملفات التي لا تتطابق مع النوع المسموح به
          }

          // التحقق من حجم الصورة الواحدة
          if (fileSizeKB > 150) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('كل صورة يجب أن تكون أقل من 150 كيلوبايت')),
            );
            return null; // تجاهل الملفات التي تتجاوز الحد
          }

          return File(file.path!);
        }).whereType<File>().toList(); // التأكد من أن الصور المقبولة فقط هي التي سيتم معالجتها

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

      // Check the size of the selected file
      final fileSizeMB =
          await file.length() / (1024 * 1024); // Convert bytes to MB
      if (fileSizeMB > 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('الملف يجب أن يكون أقل من 2 ميجابايت')),
        );
        return; 
      }

      setState(() {
        _files = [file];
      });
      widget.onFilesSelected(_files!);
    }
  } catch (e) {
    print('Error picking file: $e');
  }
}

  // void _pickImagesFromCamera() async {
  //   final ImagePicker picker = ImagePicker();

  //   if (_cameraUsageCount < 5) {
  //     try {
  //       final pickedFile = await picker.pickImage(source: ImageSource.camera);

  //       if (pickedFile != null) {
  //         final file = File(pickedFile.path);
  //         setState(() {
  //           _files = _files != null ? [..._files!, file] : [file];
  //           _cameraUsageCount++;
  //         });
  //         widget.onFilesSelected(_files!);
  //       }
  //     } catch (e) {
  //       print('Error picking image from camera: $e');
  //     }
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('يمكنك استخدام الكاميرا 5 مرات فقط')),
  //     );
  //   }
  // }

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
                    'إضافة مرفقات',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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
                    ? const Center(child: Icon(Icons.picture_as_pdf, color: Colors.red))
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


