import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/artikel_model.dart';
import '../services/artikel_service.dart';
import '../widgets/bottom_navbar.dart';

class ArtikelController {
  static Future<List<Artikel>> getArtikel(int page, int limit) async {
    try {
      final result = await ArtikelService.getArtikel(page, limit);
      print('GET Artikel Status: ${result.statusCode}');
      print('GET Artikel Body: ${result.body}');

      // Cek jika response HTML
      if (_isHtmlResponse(result.body)) {
        throw Exception(
            'Server mengembalikan halaman HTML. Periksa endpoint API.');
      }

      if (result.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(result.body);
        final data = responseData['data'] as List<dynamic>?;
        return data?.map((item) => Artikel.fromJson(item)).toList() ?? [];
      } else {
        throw Exception(
            'Gagal memuat data artikel: Status ${result.statusCode}');
      }
    } catch (e) {
      print('Error in getArtikel: $e');
      throw Exception('Gagal memuat data artikel: $e');
    }
  }

  static Future<List<Artikel>> getMyArtikel(int page, int limit) async {
    try {
      final result = await ArtikelService.getMyArtikel(page, limit);
      print('GET MyArtikel Status: ${result.statusCode}');
      print('GET MyArtikel Body: ${result.body}');

      // Cek jika response HTML
      if (_isHtmlResponse(result.body)) {
        throw Exception(
            'Server mengembalikan halaman HTML. Periksa endpoint API.');
      }

      if (result.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(result.body);
        final data = responseData['data'] as List<dynamic>?;
        return data?.map((item) => Artikel.fromJson(item)).toList() ?? [];
      } else if (result.statusCode == 404) {
        throw Exception('Kamu belum mempunyai artikel');
      } else {
        throw Exception(
            'Gagal memuat data artikel: Status ${result.statusCode}');
      }
    } catch (e) {
      print('Error in getMyArtikel: $e');
      throw Exception('Gagal memuat data artikel: $e');
    }
  }

  // Fungsi deleteArtikel - BARU
  static Future<String> deleteArtikel(String id, BuildContext context) async {
    try {
      final result = await ArtikelService.deleteArtikel(id);
      print('DELETE Status: ${result.statusCode}');
      print('DELETE Body: ${result.body}');

      // Cek jika response HTML
      if (_isHtmlResponse(result.body)) {
        return 'Server mengembalikan halaman error. Periksa endpoint API.';
      }

      final responseData = jsonDecode(result.body);

      if (result.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BottomNavbar()),
        );
        return responseData["message"] ?? "Artikel berhasil dihapus";
      } else {
        return responseData["message"] ??
            "Gagal menghapus artikel (Status: ${result.statusCode})";
      }
    } catch (e) {
      print('Error in deleteArtikel: $e');
      return "Error: $e";
    }
  }

  static Future<String> createArtikel(
    dynamic image, // Changed to dynamic untuk support web & mobile
    String title,
    String description,
    BuildContext context,
  ) async {
    try {
      final result = await ArtikelService.createArtikel(
        image,
        title,
        description,
      );

      final response = await http.Response.fromStream(result);
      print('CREATE Status: ${response.statusCode}');
      print('CREATE Body: ${response.body}');

      // Cek jika response HTML sebelum parsing JSON
      if (_isHtmlResponse(response.body)) {
        return 'Server mengembalikan halaman error. Periksa endpoint API. Response: ${response.body.length > 100 ? response.body.substring(0, 100) + "..." : response.body}';
      }

      final objectResponse = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // Delay sedikit agar user bisa baca pesan sukses
        Future.delayed(const Duration(milliseconds: 1500), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const BottomNavbar()),
          );
        });
        return objectResponse["message"] ?? "Tambah data berhasil";
      } else if (response.statusCode == 400) {
        final errors = objectResponse['errors'];
        if (errors != null && errors is List && errors.isNotEmpty) {
          final firstError = errors[0];
          return firstError['message'] ?? "Terjadi kesalahan validasi";
        }
        return objectResponse["message"] ?? "Terjadi kesalahan validasi";
      } else {
        return objectResponse["message"] ??
            "Terjadi kesalahan (Status: ${response.statusCode})";
      }
    } catch (e) {
      print('Error in createArtikel: $e');
      return "Error: $e";
    }
  }

  static Future<String> updateArtikel({
    required String id,
    dynamic image, // Changed to dynamic untuk support web & mobile
    String? title,
    String? description,
    required BuildContext context,
  }) async {
    try {
      final result = await ArtikelService.updateArtikel(
        id: id,
        image: image,
        title: title,
        description: description,
      );

      final response = await http.Response.fromStream(result);
      print('UPDATE Status: ${response.statusCode}');
      print('UPDATE Body: ${response.body}');

      // Cek jika response HTML sebelum parsing JSON
      if (_isHtmlResponse(response.body)) {
        return 'Server mengembalikan halaman error. Periksa endpoint API. Response: ${response.body.length > 100 ? response.body.substring(0, 100) + "..." : response.body}';
      }

      final objectResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Delay sedikit agar user bisa baca pesan sukses
        Future.delayed(const Duration(milliseconds: 1500), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const BottomNavbar()),
          );
        });
        return objectResponse["message"] ?? "Update data berhasil";
      } else if (response.statusCode == 400) {
        final errors = objectResponse["errors"];
        if (errors != null && errors is List && errors.isNotEmpty) {
          final firstError = errors[0];
          return firstError['message'] ?? "Terjadi kesalahan validasi";
        }
        return objectResponse["message"] ?? "Terjadi kesalahan validasi";
      } else {
        return objectResponse["message"] ??
            "Terjadi kesalahan (Status: ${response.statusCode})";
      }
    } catch (e) {
      print('Error in updateArtikel: $e');
      return "Error: $e";
    }
  }

  // Helper function untuk cek jika response adalah HTML
  static bool _isHtmlResponse(String body) {
    final trimmedBody = body.trim();
    return trimmedBody.startsWith('<!DOCTYPE html>') ||
        trimmedBody.startsWith('<html>') ||
        trimmedBody.contains('</html>') ||
        trimmedBody.contains('<head>') ||
        trimmedBody.contains('<body>');
  }
}
