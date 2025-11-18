import 'dart:convert';
import 'package:bab5_latihan/screen/edit_news_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DetailScreen extends StatefulWidget {
  final int newsId;
  final String title;
  final String description;
  final String imageUrl;
  final String author;
  final String token;

  DetailScreen({
    required this.newsId,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.author,
    required this.token,
  });

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isDeleting = false;

  Future<void> _deleteNews() async {
    setState(() {
      _isDeleting = true;
    });

    // ✅ Menggunakan endpoint yang benar
    final uri = Uri.parse(
      'https://hmti-news.hppms-sabala.my.id/api/posts/${widget.newsId}',
    );
    try {
      final response = await http.delete(
        uri,
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Accept': 'application/json',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('News deleted successfully!')),
        );
        Navigator.of(context).pop(); // Close dialog
        Navigator.of(context).pop(true); // Go back to home and signal refresh
      } else {
        final responseBody = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete news: ${responseBody['message']}'),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('An error occurred: $e')));
      Navigator.of(context).pop();
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this news?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            _isDeleting
                ? const CircularProgressIndicator()
                : TextButton(
                    onPressed: _deleteNews,
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detail News')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.imageUrl.isNotEmpty)
                // ✅ Menghapus header otentikasi karena URL gambar bersifat publik
                Image.network(
                  widget.imageUrl,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image, size: 100),
                )
              else
                const Icon(Icons.broken_image, size: 100),
              const SizedBox(height: 16),
              Text(
                widget.title,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'By ${widget.author}',
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 16),
              // ✅ Menggunakan widget.description yang sekarang berisi 'content'
              Text(widget.description, style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'editNews',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditNewsScreen(
                    newsId: widget.newsId,
                    title: widget.title,
                    description: widget.description,
                    imageUrl: widget.imageUrl,
                    author: widget.author,
                    token: widget.token,
                  ),
                ),
              );

              if (result == true) {
                Navigator.pop(context, true);
              }
            },
            child: const Icon(Icons.edit),
          ),
          SizedBox(width: 10),
          FloatingActionButton(
            heroTag: 'deleteNews',
            onPressed: _showDeleteConfirmationDialog,
            child: const Icon(Icons.delete),
            backgroundColor: Colors.red,
          ),
        ],
      ),
    );
  }
}
