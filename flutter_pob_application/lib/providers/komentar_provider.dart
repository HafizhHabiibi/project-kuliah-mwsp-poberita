import 'package:flutter/material.dart';
import '../services/komentar_service.dart';

class KomentarProvider with ChangeNotifier {
  final KomentarService _komentarService = KomentarService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Add komentar
  Future<bool> addKomentar({
    required int beritaId,
    required String isiKomentar,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _komentarService.addKomentar(
      beritaId: beritaId,
      isiKomentar: isiKomentar,
    );

    _isLoading = false;

    if (result['success']) {
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  // Delete komentar
  Future<bool> deleteKomentar(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _komentarService.deleteKomentar(id);

    _isLoading = false;

    if (result['success']) {
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
