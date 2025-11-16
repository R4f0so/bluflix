// ═══════════════════════════════════════════════════════════════
// ANALYTICS SERVICE - Gerencia dados de visualização
// ✅ ATUALIZADO: Usa subcoleções por perfil
// ═══════════════════════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bluflix/data/models/video_visualizacao_model.dart';

class AnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ═══════════════════════════════════════════════════════════════
  // ✅ NOVO: Helper para obter referência da subcoleção analytics
  // ═══════════════════════════════════════════════════════════════
  CollectionReference _getAnalyticsRef(String userId, String perfilApelido) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('perfis')
        .doc(perfilApelido)
        .collection('analytics');
  }

  // ═══════════════════════════════════════════════════════════════
  // ✅ NOVO: Helper para obter referência da subcoleção sessoes
  // ═══════════════════════════════════════════════════════════════
  CollectionReference _getSessoesRef(String userId, String perfilApelido) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('perfis')
        .doc(perfilApelido)
        .collection('sessoes');
  }

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

      final perfilApelido = perfilFilhoApelido.isNotEmpty
          ? perfilFilhoApelido
          : 'Usuário';

      final visualizacaoExistente = await _buscarVisualizacaoRecente(
        user.uid,
        perfilApelido,
        videoId,
      );

      final analyticsRef = _getAnalyticsRef(user.uid, perfilApelido);

      if (visualizacaoExistente != null) {
        await analyticsRef.doc(visualizacaoExistente).update({
          'vezesReassistido': FieldValue.increment(1),
          'inicioVisualizacao': Timestamp.now(),
        });

        print('🔄 Vídeo reassistido! ID: $visualizacaoExistente');
        return visualizacaoExistente;
      }

      final visualizacao = VideoVisualizacao(
        id: '',
        videoId: videoId,
        videoTitulo: videoTitulo,
        videoThumbnail: videoThumbnail,
        genero: genero,
        perfilFilhoApelido: perfilApelido,
        inicioVisualizacao: DateTime.now(),
        duracaoAssistidaSegundos: 0,
        duracaoTotalSegundos: duracaoTotalSegundos,
        percentualAssistido: 0,
        concluido: false,
        vezesReassistido: 0,
      );

      final docRef = await analyticsRef.add(visualizacao.toMap());

      print(
        '✅ Visualização iniciada! Perfil: $perfilApelido, ID: ${docRef.id}',
      );
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
    String? perfilFilhoApelido,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      if (perfilFilhoApelido == null || perfilFilhoApelido.isEmpty) {
        print('⚠️ Perfil não informado ao finalizar visualização');
        return;
      }

      final analyticsRef = _getAnalyticsRef(user.uid, perfilFilhoApelido);
      final docRef = analyticsRef.doc(visualizacaoId);

      final doc = await docRef.get();
      if (!doc.exists) return;

      final data = doc.data() as Map<String, dynamic>;
      final duracaoTotal = data['duracaoTotalSegundos'] as int;
      final percentual = (duracaoAssistidaSegundos / duracaoTotal * 100);
      final concluido = percentual >= 90;

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
    String perfilApelido,
    String videoId,
  ) async {
    try {
      final ontem = DateTime.now().subtract(const Duration(hours: 24));
      final analyticsRef = _getAnalyticsRef(userId, perfilApelido);

      final query = await analyticsRef
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

      final perfilApelido = perfilFilhoApelido.isNotEmpty
          ? perfilFilhoApelido
          : 'Usuário';

      final sessao = SessaoApp(
        id: '',
        perfilFilhoApelido: perfilApelido,
        inicioSessao: DateTime.now(),
        duracaoSegundos: 0,
      );

      final sessoesRef = _getSessoesRef(user.uid, perfilApelido);
      final docRef = await sessoesRef.add(sessao.toMap());

      print('✅ Sessão iniciada! Perfil: $perfilApelido, ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Erro ao iniciar sessão: $e');
      return null;
    }
  }

  /// Finaliza sessão (quando sai do app)
  Future<void> finalizarSessao(
    String sessaoId,
    String perfilFilhoApelido,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final perfilApelido = perfilFilhoApelido.isNotEmpty
          ? perfilFilhoApelido
          : 'Usuário';

      final sessoesRef = _getSessoesRef(user.uid, perfilApelido);
      final docRef = sessoesRef.doc(sessaoId);

      final doc = await docRef.get();
      if (!doc.exists) return;

      final data = doc.data() as Map<String, dynamic>;
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

      final perfilApelido = perfilFilhoApelido.isNotEmpty
          ? perfilFilhoApelido
          : 'Usuário';

      final analyticsRef = _getAnalyticsRef(user.uid, perfilApelido);
      var query = analyticsRef.orderBy('inicioVisualizacao', descending: true);

      if (limiteDias != null && limiteDias > 0) {
        final dataLimite = DateTime.now().subtract(Duration(days: limiteDias));
        query = query.where(
          'inicioVisualizacao',
          isGreaterThan: Timestamp.fromDate(dataLimite),
        );
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map(
            (doc) => VideoVisualizacao.fromMap(
              doc.id,
              doc.data() as Map<String, dynamic>,
            ),
          )
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

    final sorted = Map.fromEntries(
      generos.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );

    return sorted;
  }

  /// Retorna vídeos mais assistidos (AGRUPADOS por videoId)
  Future<List<VideoVisualizacao>> buscarVideosMaisAssistidos(
    String perfilFilhoApelido, {
    int limite = 10,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final perfilApelido = perfilFilhoApelido.isNotEmpty
          ? perfilFilhoApelido
          : 'Usuário';

      final analyticsRef = _getAnalyticsRef(user.uid, perfilApelido);

      // ✅ CORRIGIDO: Buscar TODAS as visualizações
      final snapshot = await analyticsRef
          .orderBy('inicioVisualizacao', descending: true)
          .get();

      // ✅ NOVO: Agrupar por videoId e somar vezesReassistido
      final Map<String, VideoVisualizacao> videosAgrupados = {};

      for (var doc in snapshot.docs) {
        final visualizacao = VideoVisualizacao.fromMap(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );

        final videoId = visualizacao.videoId;

        if (videosAgrupados.containsKey(videoId)) {
          // ✅ Vídeo já existe: somar vezesReassistido
          final existente = videosAgrupados[videoId]!;
          videosAgrupados[videoId] = VideoVisualizacao(
            id: existente.id,
            videoId: existente.videoId,
            videoTitulo: existente.videoTitulo,
            videoThumbnail: existente.videoThumbnail,
            genero: existente.genero,
            perfilFilhoApelido: existente.perfilFilhoApelido,
            inicioVisualizacao: existente.inicioVisualizacao,
            duracaoAssistidaSegundos: existente.duracaoAssistidaSegundos,
            duracaoTotalSegundos: existente.duracaoTotalSegundos,
            percentualAssistido: existente.percentualAssistido,
            concluido: existente.concluido,
            // ✅ Somar todas as visualizações
            vezesReassistido:
                existente.vezesReassistido + visualizacao.vezesReassistido + 1,
          );
        } else {
          // ✅ Primeira vez: adicionar ao mapa
          videosAgrupados[videoId] = visualizacao;
        }
      }

      // ✅ Ordenar por vezesReassistido e limitar
      final videosOrdenados = videosAgrupados.values.toList()
        ..sort((a, b) => b.vezesReassistido.compareTo(a.vezesReassistido));

      return videosOrdenados.take(limite).toList();
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

      final perfilApelido = perfilFilhoApelido.isNotEmpty
          ? perfilFilhoApelido
          : 'Usuário';

      final sessoesRef = _getSessoesRef(user.uid, perfilApelido);
      var query = sessoesRef.orderBy('inicioSessao', descending: true);

      if (limiteDias != null && limiteDias > 0) {
        final dataLimite = DateTime.now().subtract(Duration(days: limiteDias));
        query = query.where(
          'inicioSessao',
          isGreaterThan: Timestamp.fromDate(dataLimite),
        );
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map(
            (doc) =>
                SessaoApp.fromMap(doc.id, doc.data() as Map<String, dynamic>),
          )
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

    final sessoesValidas = sessoes.where((s) => s.duracaoSegundos > 0).toList();

    if (sessoesValidas.isEmpty) return 0;

    final totalDuracao = sessoesValidas.fold<int>(
      0,
      (total, s) => total + s.duracaoSegundos,
    );

    return totalDuracao ~/ sessoesValidas.length;
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
      'Domingo',
    ];

    for (var sessao in sessoes) {
      final diaSemana = sessao.inicioSessao.weekday;
      final index = diaSemana == 7 ? 6 : diaSemana - 1;
      final nomeDia = diasDaSemana[index];

      frequencia[nomeDia] = (frequencia[nomeDia] ?? 0) + 1;
    }

    print('📅 Frequência calculada: $frequencia');

    return frequencia;
  }
}
