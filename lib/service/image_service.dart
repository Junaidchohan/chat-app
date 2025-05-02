import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ImageService {
  final picker = ImagePicker();

  Future<File?> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  Future<String?> uploadToCloudinary(File imageFile) async {
    final cloudName = 'YOUR_CLOUD_NAME';
    final uploadPreset = 'YOUR_UPLOAD_PRESET'; // from Cloudinary dashboard

    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final resStr = await response.stream.bytesToString();
      final url = RegExp(r'"secure_url":"(.*?)"').firstMatch(resStr)?.group(1);
      return url?.replaceAll(r'\/', '/');
    } else {
      return null;
    }
  }
}
