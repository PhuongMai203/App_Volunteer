import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';


Future<double?> verifyFaceBackend(File idCard, File selfie) async {
  try {
    final url = Uri.parse('http://192.168.213.1:3000/verify-face');
    final request = http.MultipartRequest('POST', url)
      ..files.add(await http.MultipartFile.fromPath(
        'id_card',
        idCard.path,
        contentType: MediaType('image', 'jpeg'),
      ))
      ..files.add(await http.MultipartFile.fromPath(
        'selfie',
        selfie.path,
        contentType: MediaType('image', 'jpeg'),
      ));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final jsonResp = jsonDecode(response.body);
      final similarity = (jsonResp['similarity'] as num).toDouble();
      final match = jsonResp['match'] == true;
      if (!match) return null;
      return similarity;
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}