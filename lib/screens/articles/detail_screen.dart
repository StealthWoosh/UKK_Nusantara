import 'package:flutter/material.dart';
import '../../models/artikel_model.dart';

class DetailScreen extends StatelessWidget {
  final Artikel detailArtikel;
  const DetailScreen({super.key, required this.detailArtikel});

  @override
  Widget build(BuildContext context) {
    const baseUrl = 'https://api-pariwisata.rakryan.id';

    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Artikel
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        "$baseUrl/${detailArtikel.image}",
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                        ),
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Color(0xFFD1A824),
                            size: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // End Image Artikel

                // Judul Artikel
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      detailArtikel.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Lihat Di Maps',
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFFD1A824),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      color: Color(0xFFD1A824),
                      size: 15,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '4.5 (355 Reviews)',
                      style: TextStyle(
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                // End Judul Artikel

                // Deskripsi Artikel
                const SizedBox(height: 10),
                Text(
                  detailArtikel.description,
                  textAlign: TextAlign.justify,
                  style: const TextStyle(fontSize: 14),
                ),
                // End Deskripsi Artikel

                // Informasi Artikel
                const SizedBox(height: 10),
                const Text(
                  'Informasi Artikel',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 15,
                      backgroundColor: const Color(0xFFD1A824),
                      child: const Icon(
                        Icons.location_on_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(detailArtikel.title,
                        style: const TextStyle(fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 15,
                      backgroundColor: const Color(0xFFD1A824),
                      child: const Icon(
                        Icons.person_2_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(detailArtikel.name,
                        style: const TextStyle(fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 15,
                      backgroundColor: const Color(0xFFD1A824),
                      child: const Icon(
                        Icons.calendar_month_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(detailArtikel.date,
                        style: const TextStyle(fontSize: 14)),
                  ],
                ),
                // End Informasi Artikel
              ],
            ),
          ),
        ),
      ),
    );
  }
}
