import 'user_model.dart';
import 'komentar_model.dart';

class BeritaModel {
  final int id;
  final int userId;
  final String judul;
  final String konten;
  final String kategori;
  final String? gambar;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserModel? user;
  final List<KomentarModel>? komentar;

  BeritaModel({
    required this.id,
    required this.userId,
    required this.judul,
    required this.konten,
    required this.kategori,
    this.gambar,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.komentar,
  });

  factory BeritaModel.fromJson(Map<String, dynamic> json) {
    return BeritaModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      judul: json['judul'] ?? '',
      konten: json['konten'] ?? '',
      kategori: json['kategori'] ?? '',
      gambar: json['gambar'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      komentar: json['komentar'] != null
          ? (json['komentar'] as List)
              .map((k) => KomentarModel.fromJson(k))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'judul': judul,
      'konten': konten,
      'kategori': kategori,
      'gambar': gambar,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user': user?.toJson(),
      'komentar': komentar?.map((k) => k.toJson()).toList(),
    };
  }
}
