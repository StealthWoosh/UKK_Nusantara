import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/auth/login_screen.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../widgets/bottom_navbar.dart';

class AuthController {
  static Future<String> register(
    BuildContext context,
    String name,
    String username,
    String password,
  ) async {
    try {
      final result = await AuthServices.register(name, username, password);
      final responseData = jsonDecode(result.body);

      if (result.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
        return responseData['message'] ?? "Registrasi berhasil";
      } else {
        if (result.statusCode == 400) {
          final firstError = responseData['errors'][0];
          return (firstError['message'] ?? "Terjadi kesalahan");
        } else {
          return (responseData['message'] ?? "Terjadi kesalahan");
        }
      }
    } catch (e) {
      return "Terjadi kesalahan saat registrasi: $e";
    }
  }

  static Future<String> login(
    BuildContext context,
    String username,
    String password,
  ) async {
    try {
      final result = await AuthServices.login(username, password);
      final responseData = jsonDecode(result.body);

      if (result.statusCode == 200) {
        final token = responseData['token'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BottomNavbar()),
        );

        return responseData['message'] ?? "Login berhasil";
      } else {
        if (result.statusCode == 400) {
          final firstError = responseData['errors'][0];
          return (firstError['message'] ?? "Terjadi kesalahan");
        }
        return (responseData['message'] ?? 'Login gagal');
      }
    } catch (e) {
      return "Terjadi kesalahan saat login: $e";
    }
  }

  static Future<User> getProfile() async {
    try {
      final result = await AuthServices.getProfile();

      if (_isHtmlResponse(result.body)) {
        throw Exception('Server mengembalikan halaman error');
      }

      final responseData = jsonDecode(result.body);

      if (result.statusCode == 200) {
        final userData = responseData['data'];

        // CEK DATA LOKAL - jika ada, override data dari server
        final prefs = await SharedPreferences.getInstance();
        final localName = prefs.getString('local_user_name');
        final localUsername = prefs.getString('local_user_username');

        // Override data dari server dengan data lokal jika ada
        if (localName != null) {
          userData['name'] = localName;
        }
        if (localUsername != null) {
          userData['username'] = localUsername;
        }

        return User.fromJson(userData);
      } else {
        throw Exception(responseData['message'] ?? 'Gagal memuat profil');
      }
    } catch (e) {
      // Jika server error, coba load dari local storage
      final prefs = await SharedPreferences.getInstance();
      final localName = prefs.getString('local_user_name');
      final localUsername = prefs.getString('local_user_username');

      if (localName != null && localUsername != null) {
        // Return user dari data lokal DENGAN ID KOSONG
        return User(
          id: 'local-user', // ID default untuk data lokal
          name: localName,
          username: localUsername,
          email: '', // Kosongkan email karena tidak disimpan
        );
      }

      throw Exception('Gagal memuat profil: $e');
    }
  }

  static Future<String> logout(BuildContext context) async {
    try {
      final result = await AuthServices.logout();
      final responseData = jsonDecode(result.body);

      if (result.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        // Opsional: Hapus juga data lokal jika ingin
        // await prefs.remove('local_user_name');
        // await prefs.remove('local_user_username');

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );

        return responseData['message'] ?? "Logout berhasil";
      } else {
        return responseData['message'] ?? "Logout gagal";
      }
    } catch (e) {
      return "Terjadi kesalahan saat logout: $e";
    }
  }

  // UPDATE PROFILE - DENGAN LOCAL STORAGE FALLBACK
  static Future<String> updateProfile({
    required String name,
    required String username,
  }) async {
    try {
      // PERTAMA, COBA PANGGIL API UPDATE PROFILE
      final result = await AuthServices.updateProfile(
        name: name,
        username: username,
      );

      // Debug info
      print('=== DEBUG UPDATE PROFILE ===');
      print('Status Code: ${result.statusCode}');
      print('Response Body: ${result.body}');
      print('============================');

      // CEK JIKA RESPONSE ADALAH HTML (ENDPOINT TIDAK ADA)
      if (_isHtmlResponse(result.body)) {
        // SIMPAN DI LOCAL STORAGE DAN KIRIM PESAN INFORMATIF
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('local_user_name', name);
        await prefs.setString('local_user_username', username);

        return "Endpoint belum tersedia. Untuk sementara, data profile disimpan di Local Storage.";
      }

      // COBA PARSE RESPONSE JSON JIKA BUKAN HTML
      try {
        final responseData = jsonDecode(result.body);

        if (result.statusCode == 200 || result.statusCode == 201) {
          return responseData['message'] ?? "Profile berhasil diperbarui!";
        } else {
          if (result.statusCode == 400) {
            final errors = responseData['errors'];
            if (errors != null && errors is List && errors.isNotEmpty) {
              final firstError = errors[0];
              return (firstError['message'] ?? "Data tidak valid");
            }
            return (responseData['message'] ?? "Data tidak valid");
          } else if (result.statusCode == 404) {
            // ENDPOINT TIDAK DITEMUKAN - SIMPAN DI LOCAL
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('local_user_name', name);
            await prefs.setString('local_user_username', username);

            return "Endpoint update profile belum tersedia. Data disimpan sementara di Local Storage.";
          } else {
            return (responseData['message'] ?? "Gagal memperbarui profile");
          }
        }
      } catch (e) {
        // JIKA GAGAL PARSE JSON, SIMPAN DI LOCAL
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('local_user_name', name);
        await prefs.setString('local_user_username', username);

        return "Endpoint belum tersedia. Data profile disimpan sementara di Local Storage.";
      }
    } catch (e) {
      // JIKA TERJADI ERROR, SIMPAN DI LOCAL
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('local_user_name', name);
      await prefs.setString('local_user_username', username);

      return "Endpoint belum tersedia. Untuk sementara, data profile disimpan di Local Storage.";
    }
  }

  static bool _isHtmlResponse(String body) {
    if (body.isEmpty) return false;
    final trimmedBody = body.trim();
    return trimmedBody.startsWith('<!DOCTYPE html>') ||
        trimmedBody.startsWith('<html>') ||
        trimmedBody.contains('</html>');
  }
}
