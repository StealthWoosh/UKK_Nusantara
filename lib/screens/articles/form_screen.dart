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
  bool _isLoading = false;

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
    if (_isLoading) return;

    // Validasi input
    if (imagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih gambar terlebih dahulu')),
      );
      return;
    }

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul artikel harus diisi')),
      );
      return;
    }

    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deskripsi artikel harus diisi')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final imageFile = File(imagePath!);

      print('Creating article:');
      print('Image path: $imagePath');
      print('Title: $title');
      print('Description: $description');

      final message = await ArtikelController.createArtikel(
        imageFile,
        title,
        description,
        context,
      );

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _update(String title, String description) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      File? imageFile;
      if (imagePath != null) {
        imageFile = File(imagePath!);
      }

      print('Updating article:');
      print('Article ID: ${widget.artikelId}');
      print('Image path: $imagePath');
      print('Title: $title');
      print('Description: $description');

      final message = await ArtikelController.updateArtikel(
        id: widget.artikelId!,
        title: title.isNotEmpty ? title : null,
        description: description.isNotEmpty ? description : null,
        image: imageFile,
        context: context,
      );

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
                    hintText: 'Masukkan Judul Artikel',
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
                    hintText: 'Masukkan Deskripsi Artikel',
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
              ],
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            onPressed: _isLoading
                ? null
                : () {
                    final title = judulController.text.trim();
                    final description = descriptionController.text.trim();

                    if (widget.isEdit) {
                      if (widget.artikelId != null) {
                        _update(title, description);
                      }
                    } else {
                      _create(title, description);
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD1A824),
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
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
