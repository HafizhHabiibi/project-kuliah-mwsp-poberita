import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class ApiService {
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;

  // Get token dari SharedPreferences
  Future<String?> getToken() async {
    if (_token != null) return _token;

    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    return _token;
  }

  // Save token ke SharedPreferences
  Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // Remove token
  Future<void> removeToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // Get headers dengan atau tanpa token
  Future<Map<String, String>> _getHeaders({bool needsAuth = false}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (needsAuth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // GET Request
  Future<http.Response> get(
    String endpoint, {
    bool needsAuth = true,
  }) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
      final headers = await _getHeaders(needsAuth: needsAuth);

      final response = await http.get(url, headers: headers);
      return response;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // POST Request
  Future<http.Response> post(
    String endpoint, {
    required Map<String, dynamic> body,
    bool needsAuth = false,
  }) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
      final headers = await _getHeaders(needsAuth: needsAuth);

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );
      return response;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // POST Multipart (untuk upload file)
  Future<http.StreamedResponse> postMultipart(
    String endpoint, {
    required Map<String, String> fields,
    File? file,
    String fileFieldName = 'gambar',
    bool needsAuth = true,
  }) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
      final token = await getToken();

      var request = http.MultipartRequest('POST', url);

      // Add headers
      request.headers['Accept'] = 'application/json';
      if (needsAuth && token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add fields
      request.fields.addAll(fields);

      // Add file if exists
      if (file != null) {
        request.files.add(
          await http.MultipartFile.fromPath(fileFieldName, file.path),
        );
      }

      return await request.send();
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // PUT Request dengan Multipart (untuk update dengan file)
  Future<http.StreamedResponse> putMultipart(
    String endpoint, {
    required Map<String, String> fields,
    File? file,
    String fileFieldName = 'gambar',
    bool needsAuth = true,
  }) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
      final token = await getToken();

      var request = http.MultipartRequest('POST', url);

      // Laravel method spoofing untuk PUT
      fields['_method'] = 'PUT';

      // Add headers
      request.headers['Accept'] = 'application/json';
      if (needsAuth && token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add fields
      request.fields.addAll(fields);

      // Add file if exists
      if (file != null) {
        request.files.add(
          await http.MultipartFile.fromPath(fileFieldName, file.path),
        );
      }

      return await request.send();
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // PUT Request (JSON)
  Future<http.Response> put(
    String endpoint, {
    required Map<String, dynamic> body,
    bool needsAuth = true,
  }) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
      final headers = await _getHeaders(needsAuth: needsAuth);

      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(body),
      );
      return response;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // DELETE Request
  Future<http.Response> delete(
    String endpoint, {
    bool needsAuth = true,
  }) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
      final headers = await _getHeaders(needsAuth: needsAuth);

      final response = await http.delete(url, headers: headers);
      return response;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Helper untuk parse response
  Map<String, dynamic> parseResponse(http.Response response) {
    if (response.body.isEmpty) {
      return {};
    }
    return jsonDecode(response.body);
  }

  // Helper untuk parse streamed response
  Future<Map<String, dynamic>> parseStreamedResponse(
    http.StreamedResponse response,
  ) async {
    final responseBody = await response.stream.bytesToString();
    if (responseBody.isEmpty) {
      return {};
    }
    return jsonDecode(responseBody);
  }
}
