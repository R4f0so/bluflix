// ═══════════════════════════════════════════════════════════════
// MODELO DE DADOS - ANALYTICS DE VISUALIZAÇÃO
// ═══════════════════════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart';

class VideoVisualizacao {
  final String id; // ID único da visualização
  final String videoId;
  final String videoTitulo;
  final String videoThumbnail;
  final String genero;
  final String perfilFilhoApelido; // Nome do perfil que assistiu
  final DateTime inicioVisualizacao;
  final DateTime? fimVisualizacao; // Pode ser null se ainda está assistindo
  final int duracaoAssistidaSegundos; // Quanto tempo assistiu
  final int duracaoTotalSegundos; // Duração total do vídeo
  final double percentualAssistido; // % que assistiu
  final bool concluido; // Se assistiu até o final (>90%)
  final int vezesReassistido; // Quantas vezes voltou para este vídeo

  VideoVisualizacao({
    required this.id,
    required this.videoId,
    required this.videoTitulo,
    required this.videoThumbnail,
    required this.genero,
    required this.perfilFilhoApelido,
    required this.inicioVisualizacao,
    this.fimVisualizacao,
    required this.duracaoAssistidaSegundos,
    required this.duracaoTotalSegundos,
    required this.percentualAssistido,
    required this.concluido,
    this.vezesReassistido = 0,
  });

  // Converter para Map (para salvar no Firestore)
  Map<String, dynamic> toMap() {
    return {
      'videoId': videoId,
      'videoTitulo': videoTitulo,
      'videoThumbnail': videoThumbnail,
      'genero': genero,
      'perfilFilhoApelido': perfilFilhoApelido,
      'inicioVisualizacao': Timestamp.fromDate(inicioVisualizacao),
      'fimVisualizacao': fimVisualizacao != null
          ? Timestamp.fromDate(fimVisualizacao!)
          : null,
      'duracaoAssistidaSegundos': duracaoAssistidaSegundos,
      'duracaoTotalSegundos': duracaoTotalSegundos,
      'percentualAssistido': percentualAssistido,
      'concluido': concluido,
      'vezesReassistido': vezesReassistido,
    };
  }

  // Converter de Map (para ler do Firestore)
  factory VideoVisualizacao.fromMap(String id, Map<String, dynamic> map) {
    return VideoVisualizacao(
      id: id,
      videoId: map['videoId'] ?? '',
      videoTitulo: map['videoTitulo'] ?? '',
      videoThumbnail: map['videoThumbnail'] ?? '',
      genero: map['genero'] ?? '',
      perfilFilhoApelido: map['perfilFilhoApelido'] ?? '',
      inicioVisualizacao: (map['inicioVisualizacao'] as Timestamp).toDate(),
      fimVisualizacao: map['fimVisualizacao'] != null
          ? (map['fimVisualizacao'] as Timestamp).toDate()
          : null,
      duracaoAssistidaSegundos: map['duracaoAssistidaSegundos'] ?? 0,
      duracaoTotalSegundos: map['duracaoTotalSegundos'] ?? 0,
      percentualAssistido: (map['percentualAssistido'] ?? 0.0).toDouble(),
      concluido: map['concluido'] ?? false,
      vezesReassistido: map['vezesReassistido'] ?? 0,
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// MODELO DE SESSÃO (para calcular tempo no app)
// ═══════════════════════════════════════════════════════════════

class SessaoApp {
  final String id;
  final String perfilFilhoApelido;
  final DateTime inicioSessao;
  final DateTime? fimSessao;
  final int duracaoSegundos; // Tempo total na sessão

  SessaoApp({
    required this.id,
    required this.perfilFilhoApelido,
    required this.inicioSessao,
    this.fimSessao,
    required this.duracaoSegundos,
  });

  Map<String, dynamic> toMap() {
    return {
      'perfilFilhoApelido': perfilFilhoApelido,
      'inicioSessao': Timestamp.fromDate(inicioSessao),
      'fimSessao': fimSessao != null ? Timestamp.fromDate(fimSessao!) : null,
      'duracaoSegundos': duracaoSegundos,
    };
  }

  factory SessaoApp.fromMap(String id, Map<String, dynamic> map) {
    return SessaoApp(
      id: id,
      perfilFilhoApelido: map['perfilFilhoApelido'] ?? '',
      inicioSessao: (map['inicioSessao'] as Timestamp).toDate(),
      fimSessao: map['fimSessao'] != null
          ? (map['fimSessao'] as Timestamp).toDate()
          : null,
      duracaoSegundos: map['duracaoSegundos'] ?? 0,
    );
  }
}
