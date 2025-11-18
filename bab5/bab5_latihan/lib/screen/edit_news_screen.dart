import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class EditNewsScreen extends StatefulWidget {
  final int newsId;
  final String title;
  final String description;
  final String imageUrl;
  final String author;
  final String token;

  const EditNewsScreen({
    super.key,
    required this.newsId,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.author,
    required this.token,
  });

  @override
  _EditNewsScreenState createState() => _EditNewsScreenState();
}

class _EditNewsScreenState extends State<EditNewsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _authorController;
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
    _descriptionController = TextEditingController(text: widget.description);
    _authorController = TextEditingController(text: widget.author);
  }

  Future<void> _submitNews() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // ✅ Menggunakan endpoint yang benar
      var uri = Uri.parse(
        'https://hmti-news.hppms-sabala.my.id/api/posts/${widget.newsId}',
      );
      var request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer ${widget.token}'
        ..headers['Accept'] = 'application/json'
        ..fields['_method'] =
            'PUT' // Tetap gunakan ini untuk Laravel
        ..fields['title'] = _titleController.text
        // ✅ Menggunakan field 'content' yang benar
        ..fields['content'] = _descriptionController.text
        ..fields['author'] = _authorController.text;

      if (_image != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', _image!.path),
        );
      }

      try {
        final response = await request.send();
        final responseBody = await response.stream.bytesToString();

        if (response.statusCode == 200 || response.statusCode == 201) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('News updated successfully!')),
          );
          Navigator.pop(context, true); // Go back and signal a refresh
        } else {
          if (!mounted) return;
          String errorMessage;
          try {
            final errorData = json.decode(responseBody);
            if (errorData['message'] != null) {
              errorMessage = 'Failed to update news: ${errorData['message']}';
            } else {
              errorMessage = 'An unknown error occurred.';
            }
          } catch (e) {
            errorMessage =
                'Failed to update news. Invalid response from server.';
            debugPrint('Server response body: $responseBody');
          }
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(errorMessage)));
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('An error occurred: $e')));
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit News')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
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
                          return 'Please enter content';
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
                          return 'Please enter an author';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submitNews,
                      child: const Text('Update News'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
