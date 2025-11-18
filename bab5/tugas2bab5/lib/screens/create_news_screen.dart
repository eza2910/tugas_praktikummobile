import 'package:flutter/material.dart';
import '../services/api_client.dart';

class CreateNewsScreen extends StatefulWidget {
  const CreateNewsScreen({super.key});

  @override
  State<CreateNewsScreen> createState() => _CreateNewsScreenState();
}

class _CreateNewsScreenState extends State<CreateNewsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtl = TextEditingController();
  final _descCtl = TextEditingController();
  final _authorCtl = TextEditingController();
  final _imageCtl = TextEditingController();

  bool _submitting = false;

  @override
  void dispose() {
    _titleCtl.dispose();
    _descCtl.dispose();
    _authorCtl.dispose();
    _imageCtl.dispose();
    super.dispose();
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _onSubmit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    setState(() => _submitting = true);
    try {
      final payload = {
        'title': _titleCtl.text.trim(),
        'description': _descCtl.text.trim(),
        'author': _authorCtl.text.trim(),
        'image_url': _imageCtl.text.trim(),
      };

      final decoded = await ApiClient.requestJson(
        method: 'POST',
        path: '/news',
        jsonBody: payload,
        auth: true, // kirim Authorization jika token ada
      );

      if (decoded is Map && decoded['success'] == true) {
        _showSnack('Berhasil menambahkan berita');
        final data = decoded['data'];
        Navigator.pop(context, data is Map ? data : decoded);
      } else {
        _showSnack('Tambah berita berhasil (tanpa bendera success).');
        Navigator.pop(context, decoded);
      }
    } catch (e) {
      _showSnack('Gagal menambahkan: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = _submitting;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Berita'),
      ),
      body: AbsorbPointer(
        absorbing: busy,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleCtl,
                      decoration: const InputDecoration(
                        labelText: 'Judul',
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Judul wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descCtl,
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 5,
                      validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Deskripsi wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _authorCtl,
                      decoration: const InputDecoration(
                        labelText: 'Author',
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Author wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _imageCtl,
                      decoration: const InputDecoration(
                        labelText: 'URL Gambar',
                        border: OutlineInputBorder(),
                        hintText: 'https://example.com/img.jpg',
                      ),
                      validator: (v) {
                        final s = (v ?? '').trim();
                        if (s.isEmpty) return 'URL gambar wajib diisi';
                        if (!s.startsWith('http')) return 'URL gambar tidak valid';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _onSubmit,
                        icon: const Icon(Icons.cloud_upload),
                        label: const Text('Simpan'),
                      ),
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
