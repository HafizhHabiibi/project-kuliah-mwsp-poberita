import 'user_model.dart';

class KomentarModel {
  final int id;
  final int userId;
  final int beritaId;
  final String isiKomentar;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserModel? user;

  KomentarModel({
    required this.id,
    required this.userId,
    required this.beritaId,
    required this.isiKomentar,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  factory KomentarModel.fromJson(Map<String, dynamic> json) {
    return KomentarModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      beritaId: json['berita_id'] ?? 0,
      isiKomentar: json['isi_komentar'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'berita_id': beritaId,
      'isi_komentar': isiKomentar,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user': user?.toJson(),
    };
  }
}
