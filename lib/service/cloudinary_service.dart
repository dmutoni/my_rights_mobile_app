import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CloudinaryService {
  static const String cloudName = 'dnd4yim8j';
  static const String uploadPreset = 'my_unsigned_preset';

  static Future<String> uploadFile(File file) async {
    final url =
        Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/auto/upload');
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final resStr = await response.stream.bytesToString();
      final resJson = json.decode(resStr);
      return resJson['secure_url'];
    } else {
      throw Exception(
          'Failed to upload to Cloudinary: ${response.request} ${response.statusCode}');
    }
  }
}
