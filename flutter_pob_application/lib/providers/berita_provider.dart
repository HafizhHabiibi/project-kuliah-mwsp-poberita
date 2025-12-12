import 'dart:io';
import 'package:flutter/material.dart';
import '../models/berita_model.dart';
import '../services/berita_service.dart';

class BeritaProvider with ChangeNotifier {
  final BeritaService _beritaService = BeritaService();

  List<BeritaModel> _beritaList = [];
  BeritaModel? _selectedBerita;
  bool _isLoading = false;
  String? _errorMessage;

  List<BeritaModel> get beritaList => _beritaList;
  BeritaModel? get selectedBerita => _selectedBerita;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load all berita
  Future<void> loadBerita() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _beritaService.getAllBerita();

    _isLoading = false;

    if (result['success']) {
      // ✅ PERBAIKAN: Explicit cast dari dynamic ke List<BeritaModel>
      final data = result['data'];
      if (data is List) {
        _beritaList = List<BeritaModel>.from(data);
      } else {
        _beritaList = [];
        _errorMessage = 'Format data tidak valid';
      }
    } else {
      _errorMessage = result['message'];
    }

    notifyListeners();
  }

  // Load berita by ID
  Future<bool> loadBeritaById(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _beritaService.getBeritaById(id);

    _isLoading = false;

    if (result['success']) {
      _selectedBerita = result['data'] as BeritaModel?;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  // Create berita
  Future<bool> createBerita({
    required String judul,
    required String konten,
    required String kategori,
    File? gambar,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _beritaService.createBerita(
      judul: judul,
      konten: konten,
      kategori: kategori,
      gambar: gambar,
    );

    _isLoading = false;

    if (result['success']) {
      // Reload berita list
      await loadBerita();
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  // Update berita
  Future<bool> updateBerita({
    required int id,
    required String judul,
    required String konten,
    required String kategori,
    File? gambar,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _beritaService.updateBerita(
      id: id,
      judul: judul,
      konten: konten,
      kategori: kategori,
      gambar: gambar,
    );

    _isLoading = false;

    if (result['success']) {
      // Reload berita list and selected berita
      await loadBerita();
      await loadBeritaById(id);
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  // Delete berita
  Future<bool> deleteBerita(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _beritaService.deleteBerita(id);

    _isLoading = false;

    if (result['success']) {
      // Reload berita list
      await loadBerita();
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  // Filter berita by kategori
  List<BeritaModel> filterByKategori(String kategori) {
    if (kategori == 'Semua') {
      return _beritaList;
    }
    return _beritaList.where((berita) => berita.kategori == kategori).toList();
  }

  // Search berita
  List<BeritaModel> searchBerita(String query) {
    if (query.isEmpty) {
      return _beritaList;
    }
    return _beritaList.where((berita) {
      return berita.judul.toLowerCase().contains(query.toLowerCase()) ||
          berita.konten.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // Clear selected berita
  void clearSelectedBerita() {
    _selectedBerita = null;
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
