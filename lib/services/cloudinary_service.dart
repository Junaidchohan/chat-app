import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';


class CloudinaryService {
  final String cloudName = 'darj6azjo'; // 🔁 Replace
  final String uploadPreset = 'flutter_upload'; // 🔁 Replace

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
