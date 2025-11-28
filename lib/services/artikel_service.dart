import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ArtikelService {
  static final String baseUrl = 'https://api-pariwisata.rakryan.id/blog';

  static Future<http.Response> getArtikel(int page, int limit) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    var url = Uri.parse('$baseUrl?page=$page&limit=$limit');
    return await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  static Future<http.Response> getMyArtikel(int page, int limit) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    var url = Uri.parse("$baseUrl/user?page=$page&limit=$limit");
    return await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  // Fungsi deleteArtikel - BARU
  static Future<http.Response> deleteArtikel(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    var url = Uri.parse("$baseUrl/delete/$id");
    return await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  static Future<http.StreamedResponse> createArtikel(
    File image,
    String title,
    String description,
  ) async {
    final url = Uri.parse('$baseUrl/create');

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    var request = http.MultipartRequest('POST', url);

    request.headers['Authorization'] = 'Bearer $token';

    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['date'] = DateTime.now().toString();

    request.files.add(await http.MultipartFile.fromPath('image', image.path));

    return await request.send();
  }

  static Future<http.StreamedResponse> updateArtikel({
    required String id,
    File? image,
    String? title,
    String? description,
  }) async {
    final url = Uri.parse('$baseUrl/update/$id');

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    var request = http.MultipartRequest('PUT', url);

    request.headers['Authorization'] = 'Bearer $token';

    if (title != null && title.isNotEmpty) {
      request.fields['title'] = title;
    }
    if (description != null && description.isNotEmpty) {
      request.fields['description'] = description;
    }
    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
    }

    request.fields['date'] = DateTime.now().toString();

    return await request.send();
  }
}
