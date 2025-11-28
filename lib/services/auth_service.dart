import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthServices {
  static String baseUrl = 'https://api-pariwisata.rakryan.id/auth';

  static Future<http.Response> register(
    String name,
    String username,
    String password,
  ) async {
    final url = Uri.parse("$baseUrl/register");
    return await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "username": username,
        "password": password,
      }),
    );
  }

  static Future<http.Response> login(String username, String password) async {
    final url = Uri.parse("$baseUrl/login");
    return await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username, "password": password}),
    );
  }

  static Future<http.Response> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final url = Uri.parse("$baseUrl/profile");
    return await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );
  }

  static Future<http.Response> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final url = Uri.parse("$baseUrl/logout");
    return await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );
  }

  // UPDATE PROFILE - Mencoba beberapa endpoint yang mungkin
  static Future<http.Response> updateProfile({
    required String name,
    required String username,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    // Coba endpoint-endpoint yang mungkin berdasarkan pattern
    final possibleEndpoints = [
      "$baseUrl/update-profile", // Paling mungkin
      "$baseUrl/profile/update",
      "$baseUrl/user/update",
      "$baseUrl/profile", // Fallback ke endpoint profile dengan POST
    ];

    for (final endpoint in possibleEndpoints) {
      try {
        final url = Uri.parse(endpoint);

        // Gunakan POST method (konsisten dengan register/login)
        final response = await http.post(
          url,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: jsonEncode({
            "name": name,
            "username": username,
          }),
        );

        // Jika dapat response JSON (bukan HTML error), anggap berhasil
        if (response.statusCode != 404 && !_isHtmlResponse(response.body)) {
          return response;
        }
      } catch (e) {
        // Continue ke endpoint berikutnya
        continue;
      }
    }

    // Jika semua endpoint gagal, throw exception
    throw Exception('Tidak dapat menemukan endpoint update profile yang valid');
  }

  // Helper untuk cek HTML response
  static bool _isHtmlResponse(String body) {
    if (body.isEmpty) return false;
    final trimmedBody = body.trim();
    return trimmedBody.startsWith('<!DOCTYPE html>') ||
        trimmedBody.startsWith('<html>');
  }
}
