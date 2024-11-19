import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:http_parser/http_parser.dart';

class Apicomplain {
  final String baseUrl = "https://eyn.ur.gov.iq/complain_legul_sugges_success_form.php";


  // جلب العناوين بناءً على نوع المستخدم
  Future<List<Map<String, dynamic>>> fetchTitles(String userType) async {
    print('UserType: $userType');

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'action': 'title',
        'userType': userType,
      }),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => {
        'id': item['Form_title_id'].toString(),
        'name': item['Form_name'].toString(),
      }).toList();
    } else {
      throw Exception('Failed to load titles');
    }
  }





Future<Map<String, dynamic>> updateFormText({
  required int formId,
  required String location,
  required String content,
  required String whatsapp,
}) async {
  final response = await http.post(
    Uri.parse(baseUrl),
    headers: {'Content-Type': 'application/json; charset=UTF-8'},
    body: jsonEncode({
      'action': 'updateFormText',
      'form_id': formId,
      'location': location,
      'content': content,
      'whatsapp': whatsapp,
    }),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to update form text');
  }
}





Future<Map<String, dynamic>> updateImageAttachment({
  required int attachmentId,
  required File imageFile,
  required String fileName,
  required String filePath,
  required String oldFilePath, // إضافة المعامل هنا
}) async {
  var request = http.MultipartRequest(
    'POST',
    Uri.parse(baseUrl),
  );

  request.fields['action'] = 'updateImageAttachment';
  request.fields['attachment_id'] = attachmentId.toString();
  request.fields['file_name'] = fileName;
  request.fields['file_path'] = filePath;
  request.fields['old_file_path'] = oldFilePath; // إرسال المسار القديم هنا

  request.files.add(
    http.MultipartFile.fromBytes(
      'image_file',
      await imageFile.readAsBytes(),
      filename: fileName,
      contentType: MediaType('image', 'jpeg'),
    ),
  );

  var response = await request.send();
  if (response.statusCode == 200) {
    var responseData = await response.stream.bytesToString();
    print("Response Data: $responseData"); // طباعة الاستجابة للتحقق
    return jsonDecode(responseData);
  } else {
    throw Exception('Failed to update image attachment');
  }
}





Future<Map<String, dynamic>> deleteAttachment(int attachmentId) async {
  final response = await http.post(
    Uri.parse(baseUrl),
    headers: {'Content-Type': 'application/json; charset=UTF-8'},
    body: jsonEncode({
      'action': 'deleteAttachment',
      'attachment_id': attachmentId,
    }),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to delete attachment');
  }
}



Future<Map<String, dynamic>> updateAudioAttachment({
  required int attachmentId,
  required File audioFile,
}) async {
  var request = http.MultipartRequest(
    'POST',
    Uri.parse(baseUrl),
  );

  request.fields['action'] = 'updateAudioAttachment';
  request.fields['attachment_id'] = attachmentId.toString();

  request.files.add(
    http.MultipartFile.fromBytes(
      'audio_file',
      await audioFile.readAsBytes(),
      filename: audioFile.path.split('/').last,
      contentType: MediaType('audio', 'wav'),
    ),
  );

  var response = await request.send();
  if (response.statusCode == 200) {
    var responseData = await response.stream.bytesToString();
    return jsonDecode(responseData);
  } else {
    throw Exception('Failed to update audio attachment');
  }
}





// تقديم الشكوى
Future<Map<String, dynamic>> submitComplaint({
  required String titleId,
  required String location,
  required String content,
  required int userType,
  required String whatsapp,
  required List<File>? files,
  required File? audioFile, // ملف الصوت
  required String userId,
}) async {
  try {
    print('Starting complaint submission...');
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(baseUrl),
    );

    // إضافة البيانات النصية
    request.fields['action'] = 'comp_insert';
    request.fields['title_id'] = titleId;
    request.fields['location'] = location;
    request.fields['userType'] = userType.toString();
    request.fields['content'] = content;
    request.fields['whatsapp'] = whatsapp;
    request.fields['userId'] = userId;

    print('Form fields:');
    print('title_id: $titleId, location: $location, userType: $userType, content: $content, whatsapp: $whatsapp, userId: $userId');

    // إرفاق الملفات الأخرى
    if (files != null && files.isNotEmpty) {
      for (var file in files) {
        if (file.existsSync()) {
          print('Attaching file: ${file.path}');
          request.files.add(
            http.MultipartFile.fromBytes(
              'files[]',
              await file.readAsBytes(),
              filename: file.path.split('/').last,
            ),
          );
        } else {
          print('File does not exist: ${file.path}');
        }
      }
    } else {
      print('No additional files to attach.');
    }

    // إرفاق ملف الصوت إذا كان موجوداً
    if (audioFile != null && audioFile.existsSync()) {
      print('Attaching audio file: ${audioFile.path}');
      String extension = p.extension(audioFile.path);
      request.files.add(
        await http.MultipartFile.fromPath(
          'audio_file', 
          audioFile.path,
          contentType: MediaType('audio', extension == '.wav' ? 'wav' : 'mpeg'), // تأكد أن "mpeg" تستخدم للصوت MP3
        ),
      );
    } else {
      print('No audio file to attach or file does not exist.');
    }

    // إرسال الطلب
    var response = await request.send();

    print('Response status code: ${response.statusCode}');
    if (response.statusCode == 200) {
      // Successful response
      var responseData = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseData);
      print('Response data: $jsonResponse');
      return {
        'success_complaint_count': jsonResponse['success_complaint_count'] ?? true,
        'error_complaint_count': jsonResponse['error_complaint_count'],
        'message': jsonResponse['message'] ?? 'Complaint submitted successfully',
      };
    } else {
      var errorData = await response.stream.bytesToString();
      print('Error response: $errorData');
      return {
        'success_complaint_count': false,
        'error_complaint_count': 'Failed to submit complaint, status code: ${response.statusCode}',
        'message': errorData,
      };
    }
  } catch (e) {
    print('Error during complaint submission: $e');
    throw Exception('خطأ أثناء تقديم الشكوى: $e');
  }
}




Future<List<dynamic>> formSubmissions(String userType, int userId) async {
  try {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'action': 'getSubmissions',
        'role': 'user',
        'userType': userType,
        'user_id': userId.toString(),
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);

      if (responseData is List) {
        final decodedData = responseData.map((item) {
          final Map<String, dynamic> map = item as Map<String, dynamic>;
          final String submissionData = map['submission_data'];
          final decodedSubmissionData = json.decode(submissionData);

          // تقسيم المرفقات إلى قائمة من الخرائط
          final List<String> attachmentIds = (map['attachment_ids'] as String?)?.split(',') ?? [];
          final List<String> filePaths = (map['file_paths'] as String?)?.split(',') ?? [];

          // إنشاء قائمة من المرفقات، كل مرفق يتضمن attachment_id و file_path
          final attachments = List.generate(attachmentIds.length, (index) {
            return {
              'attachment_id': int.tryParse(attachmentIds[index]) ?? 0,
              'file_path': filePaths[index],
            };
          });

          return {
            'section_id': map['section_id'],
            'form_tittle_id': map['form_tittle_id'],
            'Form_name': map['Form_name'],
            'submission_data': decodedSubmissionData,
            'status': map['status'],
            'created_at': map['created_at'],
            'attachments': attachments,  // تمرير قائمة المرفقات هنا
            'form_id': map['form_id'],
          };
        }).toList();

        return decodedData;
      } else {
        throw Exception('Unexpected response format.');
      }
    } else {
      print('Failed to load submissions. Status code: ${response.statusCode}');
      throw Exception('Failed to load submissions');
    }
  } catch (e) {
    print('Error fetching submissions: $e');
    throw Exception('Error fetching submissions');
  }
}


}
