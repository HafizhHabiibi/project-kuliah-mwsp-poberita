// lib/screens/berita/berita_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/berita_provider.dart';
import '../../providers/komentar_provider.dart';
import '../../config/app_config.dart';
import 'edit_berita_screen.dart';

class BeritaDetailScreen extends StatefulWidget {
  final int beritaId;

  const BeritaDetailScreen({super.key, required this.beritaId});

  @override
  State<BeritaDetailScreen> createState() => _BeritaDetailScreenState();
}

class _BeritaDetailScreenState extends State<BeritaDetailScreen> {
  final TextEditingController _komentarController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBerita();
    });
  }

  @override
  void dispose() {
    _komentarController.dispose();
    super.dispose();
  }

  Future<void> _loadBerita() async {
    final beritaProvider = Provider.of<BeritaProvider>(context, listen: false);
    await beritaProvider.loadBeritaById(widget.beritaId);
  }

  Future<void> _addKomentar() async {
    if (_komentarController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Komentar tidak boleh kosong')),
      );
      return;
    }

    final komentarProvider =
        Provider.of<KomentarProvider>(context, listen: false);

    final success = await komentarProvider.addKomentar(
      beritaId: widget.beritaId,
      isiKomentar: _komentarController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      _komentarController.clear();
      await _loadBerita();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Komentar berhasil ditambahkan'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              komentarProvider.errorMessage ?? 'Gagal menambahkan komentar'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteKomentar(int komentarId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Komentar'),
        content: const Text('Apakah Anda yakin ingin menghapus komentar ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    final komentarProvider =
        Provider.of<KomentarProvider>(context, listen: false);

    final success = await komentarProvider.deleteKomentar(komentarId);

    if (!mounted) return;

    if (success) {
      await _loadBerita();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Komentar berhasil dihapus'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(komentarProvider.errorMessage ?? 'Gagal menghapus komentar'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteBerita() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Berita'),
        content: const Text('Apakah Anda yakin ingin menghapus berita ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    final beritaProvider = Provider.of<BeritaProvider>(context, listen: false);

    final success = await beritaProvider.deleteBerita(widget.beritaId);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Berita berhasil dihapus'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(beritaProvider.errorMessage ?? 'Gagal menghapus berita'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final beritaProvider = Provider.of<BeritaProvider>(context);
    final berita = beritaProvider.selectedBerita;

    if (beritaProvider.isLoading || berita == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Berita')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final isMyBerita = berita.userId == authProvider.user?.id;
    final dateFormat = DateFormat('dd MMMM yyyy, HH:mm', 'id_ID');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Berita'),
        actions: isMyBerita
            ? [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => EditBeritaScreen(berita: berita),
                      ),
                    );
                    _loadBerita();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _deleteBerita,
                ),
              ]
            : null,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  if (berita.gambar != null)
                    CachedNetworkImage(
                      imageUrl: AppConfig.getImageUrl(berita.gambar),
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 250,
                        color: Colors.grey[300],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 250,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported, size: 50),
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            berita.kategori,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Title
                        Text(
                          berita.judul,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Author & Date
                        Row(
                          children: [
                            const Icon(Icons.person, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              berita.user?.name ?? 'Unknown',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Icon(Icons.calendar_today, size: 18),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                dateFormat.format(berita.createdAt),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 32),

                        // Content
                        Text(
                          berita.konten,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.6,
                          ),
                        ),
                        const Divider(height: 32),

                        // Komentar Section
                        Text(
                          'Komentar (${berita.komentar?.length ?? 0})',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Komentar List
                        if (berita.komentar != null &&
                            berita.komentar!.isNotEmpty)
                          ...berita.komentar!.map((komentar) {
                            final isMyKomentar =
                                komentar.userId == authProvider.user?.id;
                            final komentarDateFormat =
                                DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 16,
                                          child: Text(
                                            komentar.user?.name
                                                    .substring(0, 1)
                                                    .toUpperCase() ??
                                                'U',
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                komentar.user?.name ??
                                                    'Unknown',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                komentarDateFormat
                                                    .format(komentar.createdAt),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (isMyKomentar)
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                size: 20),
                                            color: Colors.red,
                                            onPressed: () =>
                                                _deleteKomentar(komentar.id),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(komentar.isiKomentar),
                                  ],
                                ),
                              ),
                            );
                          })
                        else
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: Text(
                                'Belum ada komentar',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Komentar Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _komentarController,
                    decoration: InputDecoration(
                      hintText: 'Tulis komentar...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                  ),
                ),
                const SizedBox(width: 8),
                Consumer<KomentarProvider>(
                  builder: (context, komentarProvider, child) {
                    return IconButton(
                      icon: komentarProvider.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send),
                      onPressed:
                          komentarProvider.isLoading ? null : _addKomentar,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
