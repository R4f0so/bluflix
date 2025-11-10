// ═══════════════════════════════════════════════════════════════
// ANALYTICS SERVICE - Gerencia dados de visualização
// ═══════════════════════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bluflix/data/models/video_visualizacao_model.dart';

class AnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ═══════════════════════════════════════════════════════════════
  // REGISTRAR VISUALIZAÇÃO
  // ═══════════════════════════════════════════════════════════════

  /// Registra o início de uma visualização
  Future<String?> iniciarVisualizacao({
    required String videoId,
    required String videoTitulo,
    required String videoThumbnail,
    required String genero,
    required String perfilFilhoApelido,
    required int duracaoTotalSegundos,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      // Verificar se já existe visualização deste vídeo nas últimas 24h
      final visualizacaoExistente = await _buscarVisualizacaoRecente(
        user.uid,
        perfilFilhoApelido,
        videoId,
      );

      if (visualizacaoExistente != null) {
        // Incrementa vezesReassistido
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('analytics')
            .doc(visualizacaoExistente)
            .update({
          'vezesReassistido': FieldValue.increment(1),
          'inicioVisualizacao': Timestamp.now(),
        });

        print('🔄 Vídeo reassistido! ID: $visualizacaoExistente');
        return visualizacaoExistente;
      }

      // Criar nova visualização
      final visualizacao = VideoVisualizacao(
        id: '', // Será gerado pelo Firestore
        videoId: videoId,
        videoTitulo: videoTitulo,
        videoThumbnail: videoThumbnail,
        genero: genero,
        perfilFilhoApelido: perfilFilhoApelido,
        inicioVisualizacao: DateTime.now(),
        duracaoAssistidaSegundos: 0,
        duracaoTotalSegundos: duracaoTotalSegundos,
        percentualAssistido: 0,
        concluido: false,
        vezesReassistido: 0,
      );

      final docRef = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('analytics')
          .add(visualizacao.toMap());

      print('✅ Visualização iniciada! ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Erro ao iniciar visualização: $e');
      return null;
    }
  }

  /// Atualiza a visualização quando o vídeo termina ou é pausado
  Future<void> finalizarVisualizacao({
    required String visualizacaoId,
    required int duracaoAssistidaSegundos,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final docRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('analytics')
          .doc(visualizacaoId);

      final doc = await docRef.get();
      if (!doc.exists) return;

      final data = doc.data()!;
      final duracaoTotal = data['duracaoTotalSegundos'] as int;
      final percentual = (duracaoAssistidaSegundos / duracaoTotal * 100);
      final concluido = percentual >= 90; // Considera concluído se assistiu 90%+

      await docRef.update({
        'fimVisualizacao': Timestamp.now(),
        'duracaoAssistidaSegundos': duracaoAssistidaSegundos,
        'percentualAssistido': percentual,
        'concluido': concluido,
      });

      print('✅ Visualização finalizada! $percentual% assistido');
    } catch (e) {
      print('❌ Erro ao finalizar visualização: $e');
    }
  }

  /// Busca visualização recente (últimas 24h) do mesmo vídeo
  Future<String?> _buscarVisualizacaoRecente(
    String userId,
    String perfilFilhoApelido,
    String videoId,
  ) async {
    try {
      final ontem = DateTime.now().subtract(const Duration(hours: 24));

      final query = await _firestore
          .collection('users')
          .doc(userId)
          .collection('analytics')
          .where('perfilFilhoApelido', isEqualTo: perfilFilhoApelido)
          .where('videoId', isEqualTo: videoId)
          .where('inicioVisualizacao', isGreaterThan: Timestamp.fromDate(ontem))
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return query.docs.first.id;
      }
      return null;
    } catch (e) {
      print('❌ Erro ao buscar visualização recente: $e');
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // SESSÕES
  // ═══════════════════════════════════════════════════════════════

  /// Registra início de sessão (quando entra no app)
  Future<String?> iniciarSessao(String perfilFilhoApelido) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final sessao = SessaoApp(
        id: '',
        perfilFilhoApelido: perfilFilhoApelido,
        inicioSessao: DateTime.now(),
        duracaoSegundos: 0,
      );

      final docRef = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('sessoes')
          .add(sessao.toMap());

      print('✅ Sessão iniciada! ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Erro ao iniciar sessão: $e');
      return null;
    }
  }

  /// Finaliza sessão (quando sai do app)
  Future<void> finalizarSessao(String sessaoId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final docRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('sessoes')
          .doc(sessaoId);

      final doc = await docRef.get();
      if (!doc.exists) return;

      final data = doc.data()!;
      final inicioSessao = (data['inicioSessao'] as Timestamp).toDate();
      final duracao = DateTime.now().difference(inicioSessao).inSeconds;

      await docRef.update({
        'fimSessao': Timestamp.now(),
        'duracaoSegundos': duracao,
      });

      print('✅ Sessão finalizada! Duração: ${duracao}s');
    } catch (e) {
      print('❌ Erro ao finalizar sessão: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // CONSULTAS - ESTATÍSTICAS
  // ═══════════════════════════════════════════════════════════════

  /// Busca todas as visualizações de um perfil filho
  Future<List<VideoVisualizacao>> buscarVisualizacoesPerfil(
    String perfilFilhoApelido, {
    int? limiteDias,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      var query = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('analytics')
          .where('perfilFilhoApelido', isEqualTo: perfilFilhoApelido)
          .orderBy('inicioVisualizacao', descending: true);

      // Filtrar por período se especificado
      if (limiteDias != null) {
        final dataLimite =
            DateTime.now().subtract(Duration(days: limiteDias));
        query = query.where(
          'inicioVisualizacao',
          isGreaterThan: Timestamp.fromDate(dataLimite),
        );
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => VideoVisualizacao.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print('❌ Erro ao buscar visualizações: $e');
      return [];
    }
  }

  /// Calcula tempo total de tela (em segundos)
  Future<int> calcularTempoTotalTela(
    String perfilFilhoApelido, {
    int? limiteDias,
  }) async {
    final visualizacoes = await buscarVisualizacoesPerfil(
      perfilFilhoApelido,
      limiteDias: limiteDias,
    );

    return visualizacoes.fold<int>(
      0,
      (total, v) => total + v.duracaoAssistidaSegundos,
    );
  }

  /// Retorna gêneros mais assistidos (mapa: gênero -> tempo em segundos)
  Future<Map<String, int>> calcularGenerosMaisAssistidos(
    String perfilFilhoApelido, {
    int? limiteDias,
  }) async {
    final visualizacoes = await buscarVisualizacoesPerfil(
      perfilFilhoApelido,
      limiteDias: limiteDias,
    );

    final Map<String, int> generos = {};

    for (var v in visualizacoes) {
      generos[v.genero] = (generos[v.genero] ?? 0) + v.duracaoAssistidaSegundos;
    }

    // Ordenar por tempo (maior para menor)
    final sorted = Map.fromEntries(
      generos.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );

    return sorted;
  }

  /// Retorna vídeos mais assistidos (com reexibições)
  Future<List<VideoVisualizacao>> buscarVideosMaisAssistidos(
    String perfilFilhoApelido, {
    int limite = 10,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('analytics')
          .where('perfilFilhoApelido', isEqualTo: perfilFilhoApelido)
          .orderBy('vezesReassistido', descending: true)
          .limit(limite)
          .get();

      return snapshot.docs
          .map((doc) => VideoVisualizacao.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print('❌ Erro ao buscar vídeos mais assistidos: $e');
      return [];
    }
  }

  /// Calcula taxa de conclusão média (%)
  Future<double> calcularTaxaConclusao(
    String perfilFilhoApelido, {
    int? limiteDias,
  }) async {
    final visualizacoes = await buscarVisualizacoesPerfil(
      perfilFilhoApelido,
      limiteDias: limiteDias,
    );

    if (visualizacoes.isEmpty) return 0;

    final totalPercentual = visualizacoes.fold<double>(
      0,
      (total, v) => total + v.percentualAssistido,
    );

    return totalPercentual / visualizacoes.length;
  }

  /// Busca sessões de um perfil
  Future<List<SessaoApp>> buscarSessoesPerfil(
    String perfilFilhoApelido, {
    int? limiteDias,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      var query = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('sessoes')
          .where('perfilFilhoApelido', isEqualTo: perfilFilhoApelido)
          .orderBy('inicioSessao', descending: true);

      if (limiteDias != null) {
        final dataLimite =
            DateTime.now().subtract(Duration(days: limiteDias));
        query = query.where(
          'inicioSessao',
          isGreaterThan: Timestamp.fromDate(dataLimite),
        );
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => SessaoApp.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print('❌ Erro ao buscar sessões: $e');
      return [];
    }
  }

  /// Calcula duração média das sessões (em segundos)
  Future<int> calcularDuracaoMediaSessao(
    String perfilFilhoApelido, {
    int? limiteDias,
  }) async {
    final sessoes = await buscarSessoesPerfil(
      perfilFilhoApelido,
      limiteDias: limiteDias,
    );

    if (sessoes.isEmpty) return 0;

    final totalDuracao = sessoes.fold<int>(
      0,
      (total, s) => total + s.duracaoSegundos,
    );

    return totalDuracao ~/ sessoes.length;
  }

  /// Calcula frequência de uso (dias da semana)
  Future<Map<String, int>> calcularFrequenciaPorDia(
    String perfilFilhoApelido, {
    int? limiteDias,
  }) async {
    final sessoes = await buscarSessoesPerfil(
      perfilFilhoApelido,
      limiteDias: limiteDias,
    );

    final Map<String, int> frequencia = {
      'Segunda': 0,
      'Terça': 0,
      'Quarta': 0,
      'Quinta': 0,
      'Sexta': 0,
      'Sábado': 0,
      'Domingo': 0,
    };

    final diasDaSemana = [
      'Segunda',
      'Terça',
      'Quarta',
      'Quinta',
      'Sexta',
      'Sábado',
      'Domingo'
    ];

    for (var sessao in sessoes) {
      final diaSemana = sessao.inicioSessao.weekday; // 1 = Monday, 7 = Sunday
      final nomeDia = diasDaSemana[diaSemana - 1];
      frequencia[nomeDia] = (frequencia[nomeDia] ?? 0) + 1;
    }

    return frequencia;
  }
}