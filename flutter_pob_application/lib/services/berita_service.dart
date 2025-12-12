import 'dart:io';
import 'dart:convert'; // ✅ Tambahkan import ini
import '../config/app_config.dart';
import '../models/berita_model.dart';
import 'api_service.dart';

class BeritaService {
  final ApiService _apiService = ApiService();

  // Get All Berita
  Future<Map<String, dynamic>> getAllBerita() async {
    try {
      final response = await _apiService.get(
        AppConfig.berita,
        needsAuth: true,
      );

      print('🔍 Response Status: ${response.statusCode}');
      print('🔍 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // ✅ FIX: Parse langsung dari response body, bypass parseResponse
        final dynamic parsedData = json.decode(response.body);

        print('🔍 Parsed Data Type: ${parsedData.runtimeType}');
        print('🔍 Parsed Data: $parsedData');

        List<dynamic> dataList;

        // Handle berbagai format response
        if (parsedData is List) {
          // Case 1: Response langsung array
          // [ { "id": 1, ... }, { "id": 2, ... } ]
          dataList = parsedData;
          print('✅ Response format: Direct Array');
        } else if (parsedData is Map) {
          // Case 2: Response wrapped dalam object
          // { "data": [...] } atau { "berita": [...] }
          if (parsedData.containsKey('data')) {
            dataList = parsedData['data'] as List;
            print('✅ Response format: Wrapped in "data"');
          } else if (parsedData.containsKey('berita')) {
            dataList = parsedData['berita'] as List;
            print('✅ Response format: Wrapped in "berita"');
          } else {
            // Coba ambil value pertama yang berupa List
            final listValue = parsedData.values.firstWhere(
              (v) => v is List,
              orElse: () => [],
            );
            dataList = listValue as List;
            print('✅ Response format: Found list in map values');
          }
        } else {
          throw Exception(
              'Unexpected response format: ${parsedData.runtimeType}');
        }

        print('🔍 Data List Length: ${dataList.length}');

        final List<BeritaModel> beritaList = dataList.map((json) {
          print('🔍 Parsing item: $json');
          return BeritaModel.fromJson(json as Map<String, dynamic>);
        }).toList();

        print('✅ Successfully parsed ${beritaList.length} berita');

        return {
          'success': true,
          'data': beritaList,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to load berita (Status: ${response.statusCode})',
        };
      }
    } catch (e, stackTrace) {
      print('❌ Error in getAllBerita: $e');
      print('Stack trace: $stackTrace');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // Get Berita by ID
  Future<Map<String, dynamic>> getBeritaById(int id) async {
    try {
      final response = await _apiService.get(
        '${AppConfig.berita}/$id',
        needsAuth: true,
      );

      if (response.statusCode == 200) {
        final dynamic parsedData = _apiService.parseResponse(response);

        Map<String, dynamic> beritaJson;

        // Handle berbagai format response
        if (parsedData is Map<String, dynamic>) {
          if (parsedData.containsKey('berita')) {
            beritaJson = parsedData['berita'] as Map<String, dynamic>;
          } else if (parsedData.containsKey('data')) {
            beritaJson = parsedData['data'] as Map<String, dynamic>;
          } else {
            beritaJson = parsedData;
          }
        } else {
          throw Exception('Unexpected response format');
        }

        final berita = BeritaModel.fromJson(beritaJson);

        return {
          'success': true,
          'data': berita,
        };
      } else {
        final data = _apiService.parseResponse(response);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to load berita',
        };
      }
    } catch (e, stackTrace) {
      print('❌ Error in getBeritaById: $e');
      print('Stack trace: $stackTrace');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // Create Berita
  Future<Map<String, dynamic>> createBerita({
    required String judul,
    required String konten,
    required String kategori,
    File? gambar,
  }) async {
    try {
      final fields = {
        'judul': judul,
        'konten': konten,
        'kategori': kategori,
      };

      final response = await _apiService.postMultipart(
        AppConfig.berita,
        fields: fields,
        file: gambar,
        fileFieldName: 'gambar',
        needsAuth: true,
      );

      final data = await _apiService.parseStreamedResponse(response);

      if (response.statusCode == 201) {
        final berita = BeritaModel.fromJson(data['berita']);

        return {
          'success': true,
          'message': data['message'] ?? 'Berita berhasil ditambahkan',
          'data': berita,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to create berita',
          'errors': data['errors'],
        };
      }
    } catch (e, stackTrace) {
      print('❌ Error in createBerita: $e');
      print('Stack trace: $stackTrace');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // Update Berita
  Future<Map<String, dynamic>> updateBerita({
    required int id,
    required String judul,
    required String konten,
    required String kategori,
    File? gambar,
  }) async {
    try {
      final fields = {
        'judul': judul,
        'konten': konten,
        'kategori': kategori,
      };

      final response = await _apiService.putMultipart(
        '${AppConfig.berita}/$id',
        fields: fields,
        file: gambar,
        fileFieldName: 'gambar',
        needsAuth: true,
      );

      final data = await _apiService.parseStreamedResponse(response);

      if (response.statusCode == 200) {
        final berita = BeritaModel.fromJson(data['berita']);

        return {
          'success': true,
          'message': data['message'] ?? 'Berita berhasil diupdate',
          'data': berita,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update berita',
          'errors': data['errors'],
        };
      }
    } catch (e, stackTrace) {
      print('❌ Error in updateBerita: $e');
      print('Stack trace: $stackTrace');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // Delete Berita
  Future<Map<String, dynamic>> deleteBerita(int id) async {
    try {
      final response = await _apiService.delete(
        '${AppConfig.berita}/$id',
        needsAuth: true,
      );

      final data = _apiService.parseResponse(response);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Berita berhasil dihapus',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to delete berita',
        };
      }
    } catch (e, stackTrace) {
      print('❌ Error in deleteBerita: $e');
      print('Stack trace: $stackTrace');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }
}
