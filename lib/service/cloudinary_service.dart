// cloudinary_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CloudinaryService {
  final String cloudName = 'your_cloud_name';
  final String uploadPreset = 'your_upload_preset';

  Future<String?> uploadImage(File imageFile) async {
    final url = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();
    final resBody = await http.Response.fromStream(response);

    if (response.statusCode == 200) {
      final data = jsonDecode(resBody.body);
      return data['secure_url'];
    } else {
      print('Upload failed: ${resBody.body}');
      return null;
    }
  }
}
