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
  }

  static Future<String> login(
    BuildContext context,
    String username,
    String password,
  ) async {
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
  }

  // Fungsi getProfile - BARU
  static Future<User> getProfile() async {
    final result = await AuthServices.getProfile();
    final responseData = jsonDecode(result.body);

    if (result.statusCode == 200) {
      final userData = responseData['data'];
      return User.fromJson(userData);
    } else {
      throw Exception(responseData['message'] ?? 'Gagal memuat profil');
    }
  }

  // Fungsi logout - BARU
  static Future<String> logout(BuildContext context) async {
    final result = await AuthServices.logout();
    final responseData = jsonDecode(result.body);

    if (result.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );

      return responseData['message'] ?? "Logout berhasil";
    } else {
      return responseData['message'] ?? "Logout gagal";
    }
  }
}
