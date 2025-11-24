import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/artikel_model.dart';
import '../services/artikel_service.dart';
import '../widgets/bottom_navbar.dart';

class ArtikelController {
  static Future<List<Artikel>> getArtikel(int page, int limit) async {
    final result = await ArtikelService.getArtikel(page, limit);

    if (result.statusCode == 200) {
      final data = jsonDecode(result.body)['data'] as List<dynamic>;
      return data?.map((item) => Artikel.fromJson(item)).toList() ?? [];
    } else {
      throw Exception('Gagal memuat data artikel');
    }
  }

  static Future<List<Artikel>> getMyArtikel(int page, int limit) async {
    final result = await ArtikelService.getMyArtikel(page, limit);

    if (result.statusCode == 200) {
      final data = jsonDecode(result.body)['data'] as List<dynamic>;
      return data?.map((item) => Artikel.fromJson(item)).toList() ?? [];
    } else if (result.statusCode == 404) {
      throw Exception('Kamu belum mempunyai artikel');
    } else {
      throw Exception('Gagal memuat data artikel');
    }
  }

  // Fungsi deleteArtikel - BARU
  static Future<String> deleteArtikel(String id, BuildContext context) async {
    final result = await ArtikelService.deleteArtikel(id);
    final responseData = jsonDecode(result.body);

    if (result.statusCode == 200) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BottomNavbar()),
      );
      return responseData["message"] ?? "Artikel berhasil dihapus";
    } else {
      return responseData["message"] ?? "Gagal menghapus artikel";
    }
  }

  static Future<String> createArtikel(
    File image,
    String title,
    String description,
    BuildContext context,
  ) async {
    final result = await ArtikelService.createArtikel(
      image,
      title,
      description,
    );

    final response = await http.Response.fromStream(result);
    final objectResponse = jsonDecode(response.body);

    if (response.statusCode == 201) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BottomNavbar()),
      );
      return objectResponse["message"] ?? "Tambah data berhasil";
    } else if (response.statusCode == 400) {
      final firstError = objectResponse['errors'][0];
      return (firstError['message'] ?? "Terjadi kesalahan");
    } else {
      return (objectResponse['message'] ?? "Terjadi kesalahan");
    }
  }

  static Future<String> updateArtikel({
    required String id,
    File? image,
    String? title,
    String? description,
    required BuildContext context,
  }) async {
    final result = await ArtikelService.updateArtikel(
      id: id,
      image: image,
      title: title,
      description: description,
    );

    final response = await http.Response.fromStream(result);
    final objectResponse = jsonDecode(response.body);

    if (response.statusCode == 200) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BottomNavbar()),
      );
      return objectResponse["message"] ?? "Update data berhasil";
    } else if (response.statusCode == 400) {
      final firstError = objectResponse["errors"]?[0];
      return firstError?['message'] ?? "Terjadi kesalahan";
    } else {
      return objectResponse["message"] ?? "Terjadi kesalahan";
    }
  }
}
