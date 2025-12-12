class AppConfig {
  // ⚠️ PENTING: Ubah sesuai environment Anda
  // Android Emulator: http://10.0.2.2:8000/api
  // iOS Simulator: http://localhost:8000/api
  // Physical Device: http://YOUR_LOCAL_IP:8000/api (misal: http://192.168.1.100:8000/api)
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // URL untuk storage gambar
  static const String storageUrl = 'http://10.0.2.2:8000/storage';

  // Endpoints
  static const String register = '/register';
  static const String login = '/login';
  static const String logout = '/logout';
  static const String getUser = '/get-user';
  static const String berita = '/berita';
  static const String komentar = '/komentar';

  // Kategori Berita
  static const List<String> kategoriBerita = [
    'Politik',
    'Ekonomi',
    'Olahraga',
    'Teknologi',
    'Hiburan',
    'Kesehatan',
    'Pendidikan',
    'Lainnya',
  ];

  // Helper untuk mendapatkan full URL gambar
  static String getImageUrl(String? path) {
    if (path == null || path.isEmpty) {
      return '';
    }
    // Jika sudah URL lengkap, return as is
    if (path.startsWith('http')) {
      return path;
    }
    // Jika path relatif, gabungkan dengan storage URL
    return '$storageUrl/$path';
  }
}
