import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../widgets/image_input.dart';
import '../../controllers/artikel_controller.dart';

class ArticleFormScreen extends StatefulWidget {
  final bool isEdit;
  final String? artikelId;
  const ArticleFormScreen({super.key, required this.isEdit, this.artikelId});

  @override
  State<ArticleFormScreen> createState() => _ArticleFormScreenState();
}

class _ArticleFormScreenState extends State<ArticleFormScreen> {
  final TextEditingController judulController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String? imagePath;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imagePath = pickedFile.path;
      });
    }
  }

  Future<void> _create(String title, String description) async {
    if (imagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih gambar terlebih dahulu')),
      );
      return;
    }

    final imageFile = File(imagePath!);

    final message = await ArtikelController.createArtikel(
      imageFile,
      title,
      description,
      context,
    );

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _update(String title, String description) async {
    File? imageFile;
    if (imagePath != null) {
      imageFile = File(imagePath!);
    }

    final message = await ArtikelController.updateArtikel(
      id: widget.artikelId!,
      title: title.isNotEmpty ? title : null,
      description: description.isNotEmpty ? description : null,
      image: imageFile,
      context: context,
    );

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isEdit ? 'Edit Artikel' : 'Tambah Artikel'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UploadGambarBox(onTap: _pickImage, imagePath: imagePath),
                const SizedBox(height: 20),

                // form judul artikel
                const Text(
                  'Judul Artikel',
                  style: TextStyle(
                    color: Color(0xFFD1A824),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: judulController,
                  decoration: InputDecoration(
                    hintText: 'Masukkan Nama Lokasi',
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color(0xFFD1A824),
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color(0xFFD1A824),
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 20,
                    ),
                  ),
                ),
                // end form judul artikel

                // form deskripsi
                const SizedBox(height: 10),
                const Text(
                  'Deskripsi',
                  style: TextStyle(
                    color: Color(0xFFD1A824),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: descriptionController,
                  maxLines: 5,
                  minLines: 5,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    hintText: 'Masukkan Deskripsi Lokasi',
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color(0xFFD1A824),
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color(0xFFD1A824),
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 20,
                    ),
                  ),
                ),
                // end form deskripsi
              ],
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            onPressed: () {
              final title = judulController.text;
              final description = descriptionController.text;

              if (widget.isEdit == false) {
                _create(title, description);
              } else if (widget.isEdit == true && widget.artikelId != null) {
                _update(title, description);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD1A824),
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              widget.isEdit ? 'Edit' : 'Tambah',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
