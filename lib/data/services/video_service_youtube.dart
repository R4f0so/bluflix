import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bluflix/data/models/video_model_youtube.dart';

/// Serviço para gerenciar vídeos do YouTube no Firestore
class VideoServiceYoutube {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ═══════════════════════════════════════════════════════════════
  // BUSCAR VÍDEOS
  // ═══════════════════════════════════════════════════════════════

  /// Busca todos os vídeos ativos
  Future<List<VideoModelYoutube>> buscarTodosVideos() async {
    try {
      final query = await _firestore
          .collection('videos_youtube')
          .where('ativo', isEqualTo: true)
          .orderBy('dataUpload', descending: true)
          .get();

      return query.docs
          .map((doc) => VideoModelYoutube.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('❌ Erro ao buscar vídeos: $e');
      return [];
    }
  }

  /// Busca vídeos por gênero específico
  Future<List<VideoModelYoutube>> buscarVideosPorGenero(String genero) async {
    try {
      final query = await _firestore
          .collection('videos_youtube')
          .where('ativo', isEqualTo: true)
          .where('generos', arrayContains: genero)
          .orderBy('dataUpload', descending: true)
          .get();

      return query.docs
          .map((doc) => VideoModelYoutube.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('❌ Erro ao buscar vídeos por gênero: $e');
      return [];
    }
  }

  /// Busca vídeos por múltiplos gêneros
  Future<List<VideoModelYoutube>> buscarVideosPorGeneros(
    List<String> generos,
  ) async {
    try {
      // Busca vídeos que contenham pelo menos um dos gêneros
      final query = await _firestore
          .collection('videos_youtube')
          .where('ativo', isEqualTo: true)
          .orderBy('dataUpload', descending: true)
          .get();

      // Filtra manualmente para incluir vídeos que tenham qualquer um dos gêneros
      final videos = query.docs
          .map((doc) => VideoModelYoutube.fromFirestore(doc))
          .where(
            (video) => video.generos.any((genero) => generos.contains(genero)),
          )
          .toList();

      return videos;
    } catch (e) {
      print('❌ Erro ao buscar vídeos por múltiplos gêneros: $e');
      return [];
    }
  }

  /// Busca um vídeo específico por ID
  Future<VideoModelYoutube?> buscarVideoPorId(String videoId) async {
    try {
      final doc = await _firestore
          .collection('videos_youtube')
          .doc(videoId)
          .get();

      if (doc.exists) {
        return VideoModelYoutube.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('❌ Erro ao buscar vídeo por ID: $e');
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // ADICIONAR VÍDEO (APENAS ADMIN)
  // ═══════════════════════════════════════════════════════════════

  /// Adiciona um novo vídeo do YouTube ao Firestore
  /// Retorna o ID do documento criado ou null se houver erro
  Future<String?> adicionarVideo({
    required String titulo,
    required String descricao,
    required String youtubeUrl,
    required List<String> generos,
  }) async {
    try {
      // Extrai o ID do YouTube da URL
      final youtubeId = VideoModelYoutube.extractYoutubeId(youtubeUrl);

      if (youtubeId == null) {
        print('❌ URL do YouTube inválida: $youtubeUrl');
        return null;
      }

      // Cria o mapa de dados
      final videoData = {
        'titulo': titulo,
        'descricao': descricao,
        'youtubeId': youtubeId,
        'youtubeUrl': youtubeUrl,
        'generos': generos,
        'dataUpload': FieldValue.serverTimestamp(),
        'ativo': true,
      };

      // Adiciona ao Firestore
      final docRef = await _firestore
          .collection('videos_youtube')
          .add(videoData);

      print('✅ Vídeo adicionado com sucesso! ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Erro ao adicionar vídeo: $e');
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // ATUALIZAR VÍDEO (APENAS ADMIN)
  // ═══════════════════════════════════════════════════════════════

  /// Atualiza um vídeo existente
  Future<bool> atualizarVideo({
    required String videoId,
    String? titulo,
    String? descricao,
    String? youtubeUrl,
    List<String>? generos,
    bool? ativo,
  }) async {
    try {
      final Map<String, dynamic> updates = {};

      if (titulo != null) updates['titulo'] = titulo;
      if (descricao != null) updates['descricao'] = descricao;
      if (generos != null) updates['generos'] = generos;
      if (ativo != null) updates['ativo'] = ativo;

      if (youtubeUrl != null) {
        final youtubeId = VideoModelYoutube.extractYoutubeId(youtubeUrl);
        if (youtubeId != null) {
          updates['youtubeUrl'] = youtubeUrl;
          updates['youtubeId'] = youtubeId;
        }
      }

      if (updates.isEmpty) {
        print('⚠️ Nenhuma atualização fornecida');
        return false;
      }

      await _firestore
          .collection('videos_youtube')
          .doc(videoId)
          .update(updates);

      print('✅ Vídeo atualizado com sucesso!');
      return true;
    } catch (e) {
      print('❌ Erro ao atualizar vídeo: $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // EXCLUIR VÍDEO (APENAS ADMIN)
  // ═══════════════════════════════════════════════════════════════

  /// Exclui um vídeo do Firestore
  Future<bool> excluirVideo(String videoId) async {
    try {
      await _firestore.collection('videos_youtube').doc(videoId).delete();

      print('✅ Vídeo excluído com sucesso!');
      return true;
    } catch (e) {
      print('❌ Erro ao excluir vídeo: $e');
      return false;
    }
  }

  /// Desativa um vídeo (soft delete)
  Future<bool> desativarVideo(String videoId) async {
    try {
      await _firestore.collection('videos_youtube').doc(videoId).update({
        'ativo': false,
      });

      print('✅ Vídeo desativado com sucesso!');
      return true;
    } catch (e) {
      print('❌ Erro ao desativar vídeo: $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // ANALYTICS (VISUALIZAÇÕES)
  // ═══════════════════════════════════════════════════════════════

  /// Registra uma visualização do vídeo
  Future<void> registrarVisualizacao(String videoId, String userId) async {
    try {
      await _firestore
          .collection('videos_youtube')
          .doc(videoId)
          .collection('visualizacoes')
          .add({'userId': userId, 'timestamp': FieldValue.serverTimestamp()});

      print('✅ Visualização registrada');
    } catch (e) {
      print('❌ Erro ao registrar visualização: $e');
    }
  }

  /// Busca o total de visualizações de um vídeo
  Future<int> buscarTotalVisualizacoes(String videoId) async {
    try {
      final query = await _firestore
          .collection('videos_youtube')
          .doc(videoId)
          .collection('visualizacoes')
          .get();

      return query.docs.length;
    } catch (e) {
      print('❌ Erro ao buscar visualizações: $e');
      return 0;
    }
  }
}
