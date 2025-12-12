import '../config/app_config.dart';
import '../models/komentar_model.dart';
import 'api_service.dart';

class KomentarService {
  final ApiService _apiService = ApiService();

  // Add Komentar
  Future<Map<String, dynamic>> addKomentar({
    required int beritaId,
    required String isiKomentar,
  }) async {
    try {
      final response = await _apiService.post(
        AppConfig.komentar,
        body: {
          'berita_id': beritaId,
          'isi_komentar': isiKomentar,
        },
        needsAuth: true,
      );

      final data = _apiService.parseResponse(response);

      if (response.statusCode == 201) {
        final komentar = KomentarModel.fromJson(data['komentar']);

        return {
          'success': true,
          'message': data['message'] ?? 'Komentar berhasil ditambahkan',
          'data': komentar,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to add komentar',
          'errors': data['errors'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // Delete Komentar
  Future<Map<String, dynamic>> deleteKomentar(int id) async {
    try {
      final response = await _apiService.delete(
        '${AppConfig.komentar}/$id',
        needsAuth: true,
      );

      final data = _apiService.parseResponse(response);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Komentar berhasil dihapus',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to delete komentar',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }
}
