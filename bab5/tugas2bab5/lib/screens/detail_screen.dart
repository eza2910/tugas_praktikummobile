import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api_client.dart';

enum DetailResult { none, updated, deleted }

class DetailScreen extends StatefulWidget {
  final int id;
  final String title;
  final String description;
  final String imageUrl;

  const DetailScreen({
    super.key,
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isBusy = false;

  late String _title;
  late String _description;
  late String _imageUrl;

  @override
  void initState() {
    super.initState();
    _title = widget.title;
    _description = widget.description;
    _imageUrl = widget.imageUrl;
  }

  // ---------------------------
  // DELETE
  // ---------------------------
  Future<void> _confirmAndDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Berita'),
        content: const Text('Apakah kamu yakin ingin menghapus berita ini? Tindakan ini tidak bisa dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteNews();
    }
  }

  Future<void> _deleteNews() async {
    setState(() => _isBusy = true);
    try {
      final http.Response res = await ApiClient.request(
        method: 'DELETE',
        path: '/news/${widget.id}',
        auth: true,
      );

      if (res.statusCode == 200 || res.statusCode == 204) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berita berhasil dihapus')),
        );
        Navigator.pop(context, DetailResult.deleted);
        return;
      }

      if (res.statusCode == 401) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unauthorized (401). Pastikan sudah login dan token masih berlaku.')),
        );
        return;
      }

      if (!mounted) return;
      final body = res.body.isNotEmpty ? res.body : 'No response body';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus (${res.statusCode}): $body')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  // ---------------------------
  // UPDATE
  // ---------------------------
  Future<void> _openEditSheet() async {
    final titleCtl = TextEditingController(text: _title);
    final descCtl = TextEditingController(text: _description);
    final imageCtl = TextEditingController(text: _imageUrl);

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Edit Berita', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                TextField(
                  controller: titleCtl,
                  decoration: const InputDecoration(labelText: 'Judul'),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descCtl,
                  decoration: const InputDecoration(labelText: 'Deskripsi'),
                  maxLines: 4,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: imageCtl,
                  decoration: const InputDecoration(labelText: 'URL Gambar'),
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () async {
                          FocusScope.of(ctx).unfocus();
                          final ok = await _updateNews(
                            title: titleCtl.text.trim(),
                            description: descCtl.text.trim(),
                            imageUrl: imageCtl.text.trim(),
                          );
                          if (ok && mounted) Navigator.pop(ctx, true);
                        },
                        icon: const Icon(Icons.save),
                        label: const Text('Simpan'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );

    if (result == true && mounted) {
      setState(() {
        _title = titleCtl.text.trim();
        _description = descCtl.text.trim();
        _imageUrl = imageCtl.text.trim();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berita berhasil diperbarui')),
      );
      Navigator.pop(context, DetailResult.updated);
    }
  }

  Future<bool> _updateNews({
    required String title,
    required String description,
    required String imageUrl,
  }) async {
    setState(() => _isBusy = true);
    try {
      final payload = {
        'title': title,
        'description': description,
        'image_url': imageUrl,
      };

      final res = await ApiClient.request(
        method: 'PUT',
        path: '/news/${widget.id}',
        jsonBody: payload,
        auth: true,
      );

      if (res.statusCode == 200) return true;

      if (res.statusCode == 401) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unauthorized (401). Pastikan sudah login dan token masih berlaku.')),
          );
        }
        return false;
      }

      if (mounted) {
        final body = res.body.isNotEmpty ? res.body : 'No response body';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal update (${res.statusCode}): $body')),
        );
      }
      return false;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
      return false;
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  // ---------------------------
  // UI
  // ---------------------------
  @override
  Widget build(BuildContext context) {
    final busy = _isBusy;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail News'),
        actions: [
          IconButton(
            tooltip: 'Edit',
            icon: const Icon(Icons.edit),
            onPressed: busy ? null : _openEditSheet,
          ),
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete),
            onPressed: busy ? null : _confirmAndDelete,
          ),
        ],
      ),
      body: AbsorbPointer(
        absorbing: busy,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        _imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) => const SizedBox(
                          height: 120,
                          child: Center(child: Icon(Icons.broken_image, size: 48)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _description,
                      style: const TextStyle(fontSize: 16, height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
            if (busy)
              const Positioned.fill(
                child: ColoredBox(
                  color: Colors.black26,
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
