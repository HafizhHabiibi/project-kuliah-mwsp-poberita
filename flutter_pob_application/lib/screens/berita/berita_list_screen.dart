// lib/screens/berita/berita_list_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/berita_provider.dart';
import '../../config/app_config.dart';
import '../../widgets/berita_card.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/error_widget.dart';
import 'berita_detail_screen.dart';
import 'add_berita_screen.dart';

class BeritaListScreen extends StatefulWidget {
  const BeritaListScreen({super.key});

  @override
  State<BeritaListScreen> createState() => _BeritaListScreenState();
}

class _BeritaListScreenState extends State<BeritaListScreen> {
  String _selectedKategori = 'Semua';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadBerita();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBerita() async {
    final beritaProvider = Provider.of<BeritaProvider>(context, listen: false);
    await beritaProvider.loadBerita();
  }

  List<dynamic> _getFilteredBerita() {
    final beritaProvider = Provider.of<BeritaProvider>(context, listen: false);
    var beritaList = beritaProvider.beritaList;

    // Filter by kategori
    if (_selectedKategori != 'Semua') {
      beritaList = beritaList
          .where((berita) => berita.kategori == _selectedKategori)
          .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      beritaList = beritaList.where((berita) {
        return berita.judul
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            berita.konten.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return beritaList;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari berita...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),

        // Category Filter Chips
        SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildCategoryChip('Semua'),
              ...AppConfig.kategoriBerita.map(_buildCategoryChip),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Berita List
        Expanded(
          child: Consumer<BeritaProvider>(
            builder: (context, beritaProvider, child) {
              // Loading State
              if (beritaProvider.isLoading) {
                return const LoadingWidget(
                  message: 'Memuat berita...',
                );
              }

              // Error State
              if (beritaProvider.errorMessage != null) {
                return ErrorDisplayWidget(
                  message: beritaProvider.errorMessage!,
                  onRetry: _loadBerita,
                );
              }

              final filteredBerita = _getFilteredBerita();

              // Empty State
              if (filteredBerita.isEmpty) {
                if (_searchQuery.isNotEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.search_off,
                    title: 'Tidak ada hasil',
                    subtitle:
                        'Tidak ditemukan berita dengan kata kunci "$_searchQuery"',
                    action: ElevatedButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                      child: const Text('Hapus Pencarian'),
                    ),
                  );
                } else if (_selectedKategori != 'Semua') {
                  return EmptyStateWidget(
                    icon: Icons.article_outlined,
                    title: 'Belum ada berita',
                    subtitle: 'Belum ada berita di kategori $_selectedKategori',
                    action: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedKategori = 'Semua';
                        });
                      },
                      child: const Text('Lihat Semua Kategori'),
                    ),
                  );
                } else {
                  return EmptyStateWidget(
                    icon: Icons.article_outlined,
                    title: 'Belum ada berita',
                    subtitle: 'Mulai tambahkan berita pertama Anda',
                    action: ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AddBeritaScreen(),
                          ),
                        );
                        _loadBerita();
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Tambah Berita'),
                    ),
                  );
                }
              }

              // Berita List with Pull to Refresh
              return RefreshIndicator(
                onRefresh: _loadBerita,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredBerita.length,
                  itemBuilder: (context, index) {
                    final berita = filteredBerita[index];
                    return BeritaCard(
                      berita: berita,
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BeritaDetailScreen(
                              beritaId: berita.id,
                            ),
                          ),
                        );
                        _loadBerita();
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String kategori) {
    final isSelected = _selectedKategori == kategori;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(kategori),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedKategori = kategori;
          });
        },
        selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        checkmarkColor: Theme.of(context).colorScheme.primary,
        labelStyle: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Theme.of(context).colorScheme.primary : null,
        ),
      ),
    );
  }
}
