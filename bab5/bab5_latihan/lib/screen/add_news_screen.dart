import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class AddNewsScreen extends StatefulWidget {
  final String token;
  const AddNewsScreen({super.key, required this.token});

  @override
  _AddNewsScreenState createState() => _AddNewsScreenState();
}

class _AddNewsScreenState extends State<AddNewsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _authorController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitNews() async {
    if (_formKey.currentState!.validate()) {
      if (_imageFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silakan pilih gambar berita')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        var request = http.MultipartRequest(
          'POST',
          // ✅ Menggunakan endpoint yang benar
          Uri.parse('https://hmti-news.hppms-sabala.my.id/api/posts'),
        );

        // ❗ Tetap menggunakan token karena ini adalah operasi POST
        request.headers['Authorization'] = 'Bearer ${widget.token}';
        request.headers['Accept'] = 'application/json';

        request.fields['title'] = _titleController.text;
        // ✅ Menggunakan field 'content' yang benar
        request.fields['content'] = _descriptionController.text;
        request.fields['author'] = _authorController.text;
        request.files.add(
          await http.MultipartFile.fromPath('image', _imageFile!.path),
        );

        var response = await request.send();
        final responseBody = await response.stream.bytesToString();

        if (mounted) {
          // ✅ Menggunakan status code 200 atau 201 untuk sukses
          if (response.statusCode == 201 || response.statusCode == 200) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('News created successfully')),
            );
            Navigator.pop(context, true); // Kirim sinyal sukses
          } else if (response.statusCode == 401) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Unauthorized')));
          } else if (response.statusCode == 422) {
            final errors = json.decode(responseBody)['errors'];
            String errorMessage = 'Validation error:';
            errors.forEach((key, value) {
              errorMessage += '\n- ${value[0]}';
            });
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(errorMessage)));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Gagal menambahkan berita. Status: ${response.statusCode}, Body: $responseBody',
                ),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Berita Baru')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Judul tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  // ✅ Mengubah label agar konsisten
                  labelText: 'Content',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    // ✅ Mengubah pesan error
                    return 'Konten tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(
                  labelText: 'Author',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Penulis tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _imageFile == null
                  ? const Text('Tidak ada gambar yang dipilih.')
                  : Image.file(_imageFile!, height: 200, fit: BoxFit.cover),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Pilih Gambar'),
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _submitNews,
                      icon: const Icon(Icons.send),
                      label: const Text('Kirim Berita'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
