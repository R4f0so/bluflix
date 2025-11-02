import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de dados para vídeos do YouTube no BluFlix
class VideoModelYoutube {
  final String id;
  final String titulo;
  final String descricao;
  final String youtubeId; // ID do vídeo no YouTube (ex: "dQw4w9WgXcQ")
  final String youtubeUrl; // URL completa (ex: "https://www.youtube.com/watch?v=...")
  final List<String> generos;
  final DateTime dataUpload;
  final bool ativo;

  VideoModelYoutube({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.youtubeId,
    required this.youtubeUrl,
    required this.generos,
    required this.dataUpload,
    this.ativo = true,
  });

  // ═══════════════════════════════════════════════════════════════
  // CONVERSÃO FIRESTORE → MODELO
  // ═══════════════════════════════════════════════════════════════

  /// Cria um VideoModelYoutube a partir de um documento do Firestore
  factory VideoModelYoutube.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return VideoModelYoutube(
      id: doc.id,
      titulo: data['titulo'] ?? '',
      descricao: data['descricao'] ?? '',
      youtubeId: data['youtubeId'] ?? '',
      youtubeUrl: data['youtubeUrl'] ?? '',
      generos: List<String>.from(data['generos'] ?? []),
      dataUpload: (data['dataUpload'] as Timestamp).toDate(),
      ativo: data['ativo'] ?? true,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // CONVERSÃO MODELO → FIRESTORE
  // ═══════════════════════════════════════════════════════════════

  /// Converte o modelo para Map (para salvar no Firestore)
  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'descricao': descricao,
      'youtubeId': youtubeId,
      'youtubeUrl': youtubeUrl,
      'generos': generos,
      'dataUpload': Timestamp.fromDate(dataUpload),
      'ativo': ativo,
    };
  }

  // ═══════════════════════════════════════════════════════════════
  // UTILITÁRIOS
  // ═══════════════════════════════════════════════════════════════

  /// Retorna a URL da thumbnail do YouTube
  /// Formato: https://img.youtube.com/vi/{youtubeId}/hqdefault.jpg
  String get thumbnailUrl =>
      'https://img.youtube.com/vi/$youtubeId/hqdefault.jpg';

  /// Extrai o ID do YouTube de uma URL
  /// Suporta formatos:
  /// - https://www.youtube.com/watch?v=VIDEO_ID
  /// - https://youtu.be/VIDEO_ID
  /// - https://m.youtube.com/watch?v=VIDEO_ID
  static String? extractYoutubeId(String url) {
    final regExp = RegExp(
      r'(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/)([a-zA-Z0-9_-]{11})',
      caseSensitive: false,
    );

    final match = regExp.firstMatch(url);
    return match?.group(1);
  }

  /// Copia o modelo com alterações opcionais
  VideoModelYoutube copyWith({
    String? id,
    String? titulo,
    String? descricao,
    String? youtubeId,
    String? youtubeUrl,
    List<String>? generos,
    DateTime? dataUpload,
    bool? ativo,
  }) {
    return VideoModelYoutube(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      youtubeId: youtubeId ?? this.youtubeId,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      generos: generos ?? this.generos,
      dataUpload: dataUpload ?? this.dataUpload,
      ativo: ativo ?? this.ativo,
    );
  }

  @override
  String toString() {
    return 'VideoModelYoutube(id: $id, titulo: $titulo, youtubeId: $youtubeId)';
  }
}