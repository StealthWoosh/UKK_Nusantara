import 'dart:convert';
import 'package:flutter/material.dart';
import '../../services/artikel_service.dart';
import '../../widgets/grid_my_artikel.dart';
import '../../controllers/artikel_controller.dart';
import '../../models/artikel_model.dart';
import '../../screens/articles/form_screen.dart';
import '../../controllers/auth_controller.dart'; // IMPORT BARU
import '../../models/user_model.dart'; // IMPORT BARU

class MyArticlesScreen extends StatefulWidget {
  const MyArticlesScreen({super.key});

  @override
  State<MyArticlesScreen> createState() => _MyArticlesScreenState();
}

class _MyArticlesScreenState extends State<MyArticlesScreen> {
  List<Artikel> artikelAll = [];
  int page = 1;
  final int limit = 3;
  bool isLoading = false;
  bool hasMore = true;
  late Future<User> _futureUserProfile; // VARIABLE BARU

  @override
  void initState() {
    super.initState();
    loadArtikel();
    _futureUserProfile = AuthController.getProfile(); // INISIALISASI BARU
  }

  Future<void> loadArtikel() async {
    if (isLoading || !hasMore) return;

    setState(() => isLoading = true);

    try {
      final getArtikel = await ArtikelService.getMyArtikel(page, limit);
      final totalData = jsonDecode(getArtikel.body)["totalData"];

      final data = await ArtikelController.getMyArtikel(page, limit);

      setState(() {
        artikelAll.addAll(data);
        if (artikelAll.length >= totalData) {
          hasMore = false;
        } else {
          page++;
        }
      });
    } catch (e) {
      debugPrint("Gagal memuat artikel: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header dengan data dinamis
                Row(
                  children: [
                    FutureBuilder<User>(
                      future: _futureUserProfile,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircleAvatar(
                            backgroundImage: const AssetImage(
                              'assets/images/profile.png',
                            ),
                            radius: 25,
                          );
                        } else if (snapshot.hasError) {
                          return CircleAvatar(
                            backgroundImage: const AssetImage(
                              'assets/images/profile.png',
                            ),
                            radius: 25,
                            child: const Icon(Icons.error, size: 15),
                          );
                        } else {
                          final user = snapshot.data!;
                          return CircleAvatar(
                            backgroundImage: const AssetImage(
                              'assets/images/profile.png',
                            ),
                            radius: 25,
                          );
                        }
                      },
                    ),
                    const SizedBox(width: 10),
                    FutureBuilder<User>(
                      future: _futureUserProfile,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Hello",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text("Loading...",
                                  style: TextStyle(fontSize: 15)),
                            ],
                          );
                        } else if (snapshot.hasError) {
                          return const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Hello",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text("User", style: TextStyle(fontSize: 15)),
                            ],
                          );
                        } else {
                          final user = snapshot.data!;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Hello",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                user.name, // ✅ MENGGUNAKAN NAMA ASLI
                                style: const TextStyle(fontSize: 15),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.notifications,
                      color: Color(0xFFD1A824),
                      size: 30,
                    ),
                  ],
                ),
                // End Header

                // Search bar
                const SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(
                    hintText: "Cari Artikel Kamu",
                    hintStyle: const TextStyle(fontSize: 14),
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: const Color(0xFFD1A824).withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                // search bar end

                // Header list artikel saya
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "List Artikel Kamu",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const ArticleFormScreen(isEdit: false),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: Color(0xFFD1A824),
                        size: 20,
                      ),
                      label: const Text(
                        "Buat Artikel",
                        style: TextStyle(
                          color: Color(0xFFD1A824),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                // end header list artikel saya

                // Gridview
                const SizedBox(height: 10),
                GridMyArtikel(artikelList: artikelAll),
                // end gridview

                // Tombol Load More
                const SizedBox(height: 10),
                if (hasMore)
                  Center(
                    child: ElevatedButton(
                      onPressed: isLoading ? null : loadArtikel,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD1A824),
                      ),
                      child: isLoading
                          ? const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : const Text("Load More"),
                    ),
                  )
                else
                  const Center(
                    child: Text("Semua artikel sudah dimuat"),
                  ),
                // End Tombol Load More
              ],
            ),
          ),
        ),
      ),
    );
  }
}
