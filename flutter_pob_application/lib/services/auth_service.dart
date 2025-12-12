import '../config/app_config.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  // Register
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        AppConfig.register,
        body: {
          'name': name,
          'email': email,
          'password': password,
        },
        needsAuth: false,
      );

      final data = _apiService.parseResponse(response);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'] ?? 'Registration successful',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // Login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        AppConfig.login,
        body: {
          'email': email,
          'password': password,
        },
        needsAuth: false,
      );

      final data = _apiService.parseResponse(response);

      if (response.statusCode == 200 && data['status'] == 'success') {
        // Save token
        final token = data['token'];
        await _apiService.saveToken(token);

        // Parse user info
        final user = UserModel.fromJson(data['user_info']);

        return {
          'success': true,
          'message': data['message'] ?? 'Login successful',
          'user': user,
          'token': token,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // Get User Info
  Future<Map<String, dynamic>> getUserInfo() async {
    try {
      final response = await _apiService.get(
        AppConfig.getUser,
        needsAuth: true,
      );

      final data = _apiService.parseResponse(response);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get user info',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // Logout
  Future<Map<String, dynamic>> logout() async {
    try {
      final response = await _apiService.post(
        AppConfig.logout,
        body: {},
        needsAuth: true,
      );

      final data = _apiService.parseResponse(response);

      if (response.statusCode == 200) {
        // Remove token
        await _apiService.removeToken();

        return {
          'success': true,
          'message': data['message'] ?? 'Logout successful',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Logout failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await _apiService.getToken();
    return token != null && token.isNotEmpty;
  }
}
