import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/artikel_model.dart';
import '../../widgets/grid_artikel_populer.dart';
import '../../controllers/artikel_controller.dart';
import '../../widgets/grid_artikel_all.dart';
import '../../services/artikel_service.dart';
import '../../controllers/auth_controller.dart';
import '../../models/user_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Artikel> artikelAll = [];
  List<Artikel> filteredArtikelAll = [];
  int page = 1;
  final int limit = 5;
  bool isLoading = false;
  bool hasMore = true;
  bool isSearching = false;
  String searchQuery = "";
  late Future<List<Artikel>> _futureArtikelPopuler;
  late Future<User> _futureUserProfile;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadArtikel();
    _futureArtikelPopuler = ArtikelController.getArtikel(1, 4);
    _futureUserProfile = AuthController.getProfile();
  }

  Future<void> loadArtikel() async {
    if (isLoading || !hasMore) return;

    setState(() => isLoading = true);

    try {
      final getArtikel = await ArtikelService.getArtikel(page, limit);
      final totalData = jsonDecode(getArtikel.body)["totalData"];

      final data = await ArtikelController.getArtikel(page, limit);

      setState(() {
        artikelAll.addAll(data);
        filteredArtikelAll = List.from(artikelAll);
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

  // FUNGSI UNTUK MENCARI ARTIKEL - SUDAH DIPERBAIKI
  void _searchArtikel(String query) {
    setState(() {
      searchQuery = query;
      isSearching = query.isNotEmpty;

      if (query.isEmpty) {
        filteredArtikelAll = List.from(artikelAll);
      } else {
        filteredArtikelAll = artikelAll.where((artikel) {
          final titleLower = artikel.title.toLowerCase();
          final descriptionLower = artikel.description.toLowerCase();
          final queryLower = query.toLowerCase();

          // CARI DI JUDUL ATAU DESKRIPSI
          return titleLower.contains(queryLower) ||
              descriptionLower.contains(queryLower);
        }).toList();
      }
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      searchQuery = "";
      isSearching = false;
      filteredArtikelAll = List.from(artikelAll);
    });
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
                                user.name,
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

                // Search Bar
                const SizedBox(height: 20),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Cari artikel...",
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: isSearching
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: _clearSearch,
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFFD1A824).withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: _searchArtikel,
                ),
                // End Search Bar

                // TAMPILKAN HASIL PENCARIAN ATAU SEMUA ARTIKEL
                if (isSearching) ...[
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Hasil Pencarian: \"$searchQuery\"",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (filteredArtikelAll.isNotEmpty)
                        Text(
                          "${filteredArtikelAll.length} hasil",
                          style: TextStyle(
                            fontSize: 12,
                            color: const Color(0xFFD1A824),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // TAMPILKAN HASIL PENCARIAN
                  if (filteredArtikelAll.isEmpty)
                    const Column(
                      children: [
                        SizedBox(height: 50),
                        Icon(
                          Icons.search_off,
                          size: 60,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Tidak ada artikel yang ditemukan",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          "Coba dengan kata kunci lain",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    )
                  else
                    GridArtikelAll(artikelList: filteredArtikelAll),
                ] else ...[
                  // TAMPILKAN CONTENT NORMAL JIKA TIDAK SEDANG MENCARI

                  // Grid Artikel Popular
                  const SizedBox(height: 20),
                  const Text(
                    "Populer",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  FutureBuilder(
                    future: _futureArtikelPopuler,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        final artikelList = snapshot.data ?? [];
                        return Column(
                          children: [
                            GridArtikelPopuler(artikelList: artikelList),
                            const SizedBox(height: 20),

                            // Destination Container
                            Container(
                              width: double.infinity,
                              height: 90,
                              decoration: BoxDecoration(
                                color: const Color(0xFFD1A824),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      'assets/icons/news-paper.png',
                                      width: 40,
                                      height: 40,
                                    ),
                                    const SizedBox(width: 15),
                                    const Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Lihat Artikel Kamu",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "Yuk, Mulai Buat Artikel Kamu Sendiri",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    CircleAvatar(
                                      backgroundColor: Colors.white,
                                      child: IconButton(
                                        onPressed: () {
                                          // Navigasi ke My Articles
                                        },
                                        icon: const Icon(
                                          Icons.arrow_forward,
                                          color: Color(0xFFD1A824),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // End Destination Container
                          ],
                        );
                      }
                    },
                  ),
                  // End Grid Artikel Popular

                  const SizedBox(height: 20),

                  // Artikel Lainnya
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Artikel Lainnya",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "See all",
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFFD1A824),
                        ),
                      ),
                    ],
                  ),
                  // End Artikel Lainnya

                  const SizedBox(height: 10),
                  GridArtikelAll(artikelList: artikelAll),
                  // End Grid Artikel All

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
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
