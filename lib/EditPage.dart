import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:merge_voice_coplain/theme/appcolors.dart';
import 'dart:async';
import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:record/record.dart';
import 'package:image_picker/image_picker.dart';
import '../api/api_complain_legul_sugges_success_form.dart';

class EditPage extends StatefulWidget {
  final int submissionIndex;
  final Map<String, dynamic> submissionData;
  final List<String> filePaths;

  const EditPage({
    super.key,
    required this.submissionIndex,
    required this.submissionData,
    required this.filePaths,
  });

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  late List<int> attachmentIds;
  final AudioRecorder audioRecorder = AudioRecorder();
  final AudioPlayer audioPlayer = AudioPlayer();
  String? recordingPath;
  bool isRecording = false;
  bool isPlaying = false;
  bool _isImagePickerActive = false;
  int recordDuration = 0;
  Timer? timer;

  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _locationController.text = widget.submissionData['location'] ?? '';
    _contentController.text = widget.submissionData['content'] ?? '';
    _whatsappController.text = widget.submissionData['whatsapp'] ?? '';
    attachmentIds = widget.submissionData['attachment_ids'] ?? [];
    print("Received attachment_ids in EditPage: $attachmentIds");
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    timer?.cancel();
    super.dispose();
  }

  Future<File?> _pickImage() async {
    if (_isImagePickerActive) return null;
    _isImagePickerActive = true;

    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        print("Image selected: ${pickedFile.path}");
        return File(pickedFile.path);
      } else {
        print("No image selected.");
      }
      return null;
    } finally {
      _isImagePickerActive = false;
    }
  }

void _submitEdits() async {
  final formId = widget.submissionData['form_id'];
  if (formId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("معرف النموذج غير متوفر")),
    );
    return;
  }

  final location = _locationController.text;
  final content = _contentController.text;
  final whatsapp = _whatsappController.text;

  try {
    final response = await Apicomplain().updateFormText(
      formId: formId,
      location: location,
      content: content,
      whatsapp: whatsapp,
    );

    if (response['success'] != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تم تحديث البيانات بنجاح")),
      );
      
      // الرجوع إلى الصفحة السابقة
      Navigator.pop(context, 'تم التحديث بنجاح');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("فشل في تحديث البيانات: ${response['error']}")),
      );
    }
  } catch (e) {
    print('Error updating form text: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("خطأ أثناء تحديث البيانات")),
    );
  }
}




void _updateImageAttachment(int attachmentId, List<String> filePaths, String oldFileName) async {
  print("Updating image with attachmentId: $attachmentId");

  final imageFile = await _pickImage();
  if (imageFile != null) {
    final String newFileName = imageFile.path.split('/').last;

    // استبعاد اسم الصورة القديم في نهاية المسار
    final String pathToFolder = filePaths.isNotEmpty 
        ? filePaths[0].substring(0, filePaths[0].lastIndexOf('/')) 
        : "default_path";
        
    final String newFilePath = "$pathToFolder/$newFileName";
    final String oldFilePath = "$pathToFolder/$oldFileName"; // إنشاء مسار الصورة القديمة

    print("New file name: $newFileName");
    print("New file path: $newFilePath");
    print("Old file path: $oldFilePath");

    try {
      final response = await Apicomplain().updateImageAttachment(
        attachmentId: attachmentId,
        imageFile: imageFile,
        fileName: newFileName,
        filePath: newFilePath,
        oldFilePath: oldFilePath, // تمرير المسار الكامل للصورة القديمة
      );

      if (response['success'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم تحديث الصورة بنجاح")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("فشل في تحديث الصورة: ${response['error']}")),
        );
      }
    } catch (e) {
      print("Error updating image attachment: $e");
    }
  }
}


Widget _buildImageAttachments() {
  if (widget.filePaths.isEmpty || widget.submissionData['attachments'] == null) {
    return const Text('لا توجد صور مرفقة');
  }

  final attachments = widget.submissionData['attachments'] as List<dynamic>;

  return Column(
    children: attachments.asMap().entries.map((entry) {
      final index = entry.key;
      final attachment = entry.value;
      final filePath = widget.filePaths[index];
      final attachmentId = attachment['attachment_id'];

      // استخدم filePath كما هو دون تعديل
      final String fullPath = filePath;

      final String oldFileName = filePath.split('/').last;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: [
            Image.network(fullPath),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    if (attachmentId != null && widget.filePaths.isNotEmpty) {
                      print("Attachment ID: $attachmentId");
                      print("Old file name: $oldFileName"); // طباعة اسم الصورة القديمة للتحقق
                      _updateImageAttachment(
                        attachmentId,
                        widget.filePaths,
                        oldFileName, // تمرير اسم الصورة القديمة
                      );
                    } else {
                      print("Attachment ID or file paths are null");
                    }
                  },
                  child: Text('تعديل الصورة', style: GoogleFonts.tajawal()),
                ),
                TextButton(
                  onPressed: () {
                    // Call the delete function here if needed
                  },
                  child: Text('حذف الصورة', style: GoogleFonts.tajawal()),
                ),
              ],
            ),
          ],
        ),
      );
    }).toList(),
  );
}



  // Widget _buildAudioAttachment() {
  //   String? audioFilePath = widget.filePaths.firstWhere(
  //     (filePath) => filePath.endsWith('.wav'),
  //     orElse: () => '',
  //   );

  //   if (audioFilePath.isEmpty) {
  //     return const Text('لا يوجد ملف صوتي مرفق');
  //   }

  //   const String baseUrl = 'http://172.16.30.130/women_project';
  //   final String fullAudioPath = audioFilePath.startsWith('http')
  //       ? audioFilePath
  //       : '$baseUrl/$audioFilePath';

  //   return Column(
  //     children: [
  //       ListTile(
  //         leading: const Icon(Icons.audiotrack),
  //         title: const Text('الملف الصوتي المرفق'),
  //         subtitle: Text(fullAudioPath),
  //       ),
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           FloatingActionButton(
  //             onPressed: isPlaying
  //                 ? () async {
  //                     await audioPlayer.stop();
  //                     setState(() {
  //                       isPlaying = false;
  //                     });
  //                   }
  //                 : () async {
  //                     await audioPlayer.setUrl(fullAudioPath);
  //                     audioPlayer.play();
  //                     setState(() {
  //                       isPlaying = true;
  //                     });
  //                     audioPlayer.playerStateStream.listen((state) {
  //                       if (!state.playing) {
  //                         setState(() {
  //                           isPlaying = false;
  //                         });
  //                       }
  //                     });
  //                   },
  //             backgroundColor: Colors.green,
  //             child: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
  //           ),
  //           FloatingActionButton(
  //             onPressed: isRecording
  //                 ? () async {
  //                     String? filepath = await audioRecorder.stop();
  //                     if (filepath != null) {
  //                       setState(() {
  //                         isRecording = false;
  //                         recordingPath = filepath;
  //                       });
  //                     }
  //                   }
  //                 : () async {
  //                     if (await audioRecorder.hasPermission()) {
  //                       final Directory directory = await getApplicationDocumentsDirectory();
  //                       final String filepath = p.join(directory.path, "recording.wav");
  //                       await audioRecorder.start(const RecordConfig(), path: filepath);

  //                       setState(() {
  //                         isRecording = true;
  //                         recordingPath = null;
  //                       });
  //                     } else {
  //                       ScaffoldMessenger.of(context).showSnackBar(
  //                         const SnackBar(content: Text("تحتاج إلى منح إذن التسجيل")),
  //                       );
  //                     }
  //                   },
  //             backgroundColor: Colors.blue,
  //             child: Icon(isRecording ? Icons.stop : Icons.mic),
  //           ),
  //           FloatingActionButton(
  //             onPressed: () async {
  //               final file = File(fullAudioPath);
  //               if (await file.exists()) {
  //                 await file.delete();
  //               }
  //               setState(() {
  //                 recordingPath = null;
  //               });
  //             },
  //             backgroundColor: Colors.red,
  //             child: const Icon(Icons.delete),
  //           ),
  //         ],
  //       ),
  //     ],
  //   );
  // }




  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text(
  //         'تعديل الشكوى',
  //         style: GoogleFonts.tajawal(color: Colors.white),
  //       ),
  //       backgroundColor: AppColors.topBarColor,
  //       iconTheme: const IconThemeData(color: Colors.white),
  //     ),
  //     body: Padding(
  //       padding: const EdgeInsets.all(16.0),
  //       child: SingleChildScrollView(
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text('الموقع', style: GoogleFonts.tajawal(fontSize: 16, color: AppColors.textColor)),
  //             TextFormField(
  //               controller: _locationController,
  //               decoration: const InputDecoration(
  //                 border: OutlineInputBorder(),
  //                 hintText: 'أدخل الموقع',
  //               ),
  //             ),
  //             const SizedBox(height: 16),
  //             Text('المحتوى', style: GoogleFonts.tajawal(fontSize: 16, color: AppColors.textColor)),
  //             TextFormField(
  //               controller: _contentController,
  //               decoration: const InputDecoration(
  //                 border: OutlineInputBorder(),
  //                 hintText: 'أدخل المحتوى',
  //               ),
  //               maxLines: 5,
  //             ),
  //             const SizedBox(height: 16),
  //             Text('رقم الواتساب', style: GoogleFonts.tajawal(fontSize: 16, color: AppColors.textColor)),
  //             TextFormField(
  //               controller: _whatsappController,
  //               decoration: const InputDecoration(
  //                 border: OutlineInputBorder(),
  //                 hintText: 'أدخل رقم الواتساب',
  //               ),
  //               keyboardType: TextInputType.phone,
  //             ),
  //             const SizedBox(height: 24),
  //             // _buildImageAttachments(),
  //             const SizedBox(height: 24),
  //             // _buildAudioAttachment(),
  //             const SizedBox(height: 24),
  //             Center(
  //               child: ElevatedButton(
  //                 onPressed: _submitEdits,
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: AppColors.buttonColor,
  //                 ),
  //                 child: Text('حفظ التعديلات', style: GoogleFonts.tajawal(color: Colors.white)),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
  @override
Widget build(BuildContext context) {
  // final screenHeight = MediaQuery.of(context).size.height;
return Scaffold(
  body: CustomScrollView(
    slivers: [
      SliverAppBar(
        expandedHeight: 150.0, // Height of the AppBar
        floating: false,
        pinned: true, // AppBar remains pinned at the top when scrolling
        backgroundColor: AppColors.topBarColor,
        flexibleSpace: FlexibleSpaceBar(
          title: Text(
            'تعديل الشكوى',
            style: GoogleFonts.tajawal(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('الموقع', style: GoogleFonts.tajawal(fontSize: 16, color: AppColors.textColor)),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: AppColors.topBarColor), // Highlight color
                  ),
                  hintText: 'أدخل الموقع',
                ),
              ),
              const SizedBox(height: 16),
              Text('المحتوى', style: GoogleFonts.tajawal(fontSize: 16, color: AppColors.textColor)),
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: AppColors.topBarColor),
                  ),
                  hintText: 'أدخل المحتوى',
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              Text('رقم الواتساب', style: GoogleFonts.tajawal(fontSize: 16, color: AppColors.textColor)),
              TextFormField(
                controller: _whatsappController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: AppColors.topBarColor),
                  ),
                  hintText: 'أدخل رقم الواتساب',
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _submitEdits,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonColor,
                  ),
                  child: Text('حفظ التعديلات', style: GoogleFonts.tajawal(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  ),
);

}

}
