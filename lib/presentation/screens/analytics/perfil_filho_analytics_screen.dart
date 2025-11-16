import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:bluflix/core/theme/app_theme.dart';
import 'package:bluflix/presentation/widgets/theme_toggle_button.dart';
import 'package:bluflix/data/services/analytics_service.dart';
import 'package:bluflix/data/models/video_visualizacao_model.dart';

class PerfilFilhoAnalyticsScreen extends StatefulWidget {
  final String perfilFilhoApelido;

  const PerfilFilhoAnalyticsScreen({
    super.key,
    required this.perfilFilhoApelido,
  });

  @override
  State<PerfilFilhoAnalyticsScreen> createState() =>
      _PerfilFilhoAnalyticsScreenState();
}

class _PerfilFilhoAnalyticsScreenState
    extends State<PerfilFilhoAnalyticsScreen> {
  final AnalyticsService _analyticsService = AnalyticsService();

  bool _isLoading = true;
  int _tempoTotalTela = 0;
  Map<String, int> _generosMaisAssistidos = {};
  List<VideoVisualizacao> _videosMaisAssistidos = [];
  double _taxaReassistencia = 0;
  int _duracaoMediaSessao = 0;
  Map<String, int> _frequenciaPorDia = {};

  int _periodoSelecionado = 7;

  @override
  void initState() {
    super.initState();
    _carregarAnalytics();
  }

  Future<void> _carregarAnalytics() async {
    setState(() => _isLoading = true);

    try {
      final tempoTotal = await _analyticsService.calcularTempoTotalTela(
        widget.perfilFilhoApelido,
        limiteDias: _periodoSelecionado == -1 ? null : _periodoSelecionado,
      );
      print('📊 Tempo Total: $tempoTotal segundos');

      final generos = await _analyticsService.calcularGenerosMaisAssistidos(
        widget.perfilFilhoApelido,
        limiteDias: _periodoSelecionado == -1 ? null : _periodoSelecionado,
      );
      print('📊 Gêneros: $generos');

      final videos = await _analyticsService.buscarVideosMaisAssistidos(
        widget.perfilFilhoApelido,
        limite: 5,
      );
      print('📊 Vídeos: ${videos.length}');

      final duracaoMedia = await _analyticsService.calcularDuracaoMediaSessao(
        widget.perfilFilhoApelido,
        limiteDias: _periodoSelecionado == -1 ? null : _periodoSelecionado,
      );
      print('📊 Duração Média Sessão: $duracaoMedia segundos');

      final frequencia = await _analyticsService.calcularFrequenciaPorDia(
        widget.perfilFilhoApelido,
        limiteDias: _periodoSelecionado == -1 ? null : _periodoSelecionado,
      );
      print('📊 Frequência por Dia: $frequencia');

      // ✅ CORRIGIDO: Calcular taxa de reassistência de TODOS os vídeos
      final todasVisualizacoes = await _analyticsService
          .buscarVisualizacoesPerfil(
            widget.perfilFilhoApelido,
            limiteDias: _periodoSelecionado == -1 ? null : _periodoSelecionado,
          );

      // Agrupar por videoId para contar visualizações únicas
      final Set<String> videosUnicos = {};
      int totalReassistencias = 0;

      for (var vis in todasVisualizacoes) {
        videosUnicos.add(vis.videoId);
        totalReassistencias += vis.vezesReassistido;
      }

      final totalVisualizacoes = videosUnicos.length + totalReassistencias;
      final taxaReassistencia = totalVisualizacoes > 0
          ? (totalReassistencias / totalVisualizacoes * 100)
          : 0.0;

      print('📊 Taxa Reassistência:');
      print('   Vídeos únicos: ${videosUnicos.length}');
      print('   Total reassistências: $totalReassistencias');
      print('   Total visualizações: $totalVisualizacoes');
      print('   Taxa: $taxaReassistencia%');

      setState(() {
        _tempoTotalTela = tempoTotal;
        _generosMaisAssistidos = generos;
        _videosMaisAssistidos = videos;
        _taxaReassistencia = taxaReassistencia;
        _duracaoMediaSessao = duracaoMedia;
        _frequenciaPorDia = frequencia;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Erro ao carregar analytics: $e');
      setState(() => _isLoading = false);
    }
  }

  String _formatarTempo(int segundos) {
    final horas = segundos ~/ 3600;
    final minutos = (segundos % 3600) ~/ 60;
    final segs = segundos % 60;

    if (horas > 0) {
      return '${horas}h ${minutos}min';
    } else if (minutos > 0) {
      return '${minutos}min ${segs}s';
    } else {
      return '${segs}s';
    }
  }

  @override
  Widget build(BuildContext context) {
    final appTema = Provider.of<AppTema>(context);

    return Scaffold(
      backgroundColor: appTema.backgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFFA9DBF4),
        foregroundColor: Colors.black,
        title: Text(
          'Analytics - ${widget.perfilFilhoApelido}',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 28),
          onPressed: () => context.pop(),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: ThemeToggleButton(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFA9DBF4)),
            )
          : RefreshIndicator(
              onRefresh: _carregarAnalytics,
              color: const Color(0xFFA9DBF4),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFiltroPeriodo(appTema),
                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.access_time,
                            titulo: 'Tempo Total',
                            valor: _formatarTempo(_tempoTotalTela),
                            cor: Colors.blue,
                            appTema: appTema,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.timer,
                            titulo: 'Sessão Média',
                            valor: _formatarTempo(_duracaoMediaSessao),
                            cor: Colors.orange,
                            appTema: appTema,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.replay,
                            titulo: 'Reassistidos',
                            valor: '${_taxaReassistencia.toStringAsFixed(0)}%',
                            cor: Colors.green,
                            appTema: appTema,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.play_circle,
                            titulo: 'Vídeos',
                            valor: '${_videosMaisAssistidos.length}',
                            cor: Colors.purple,
                            appTema: appTema,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    _buildSecaoTitulo('📊 Gêneros Assistidos', appTema),
                    const SizedBox(height: 16),
                    _buildGenerosList(appTema),

                    const SizedBox(height: 32),

                    _buildSecaoTitulo('🎬 Vídeos Assistidos', appTema),
                    const SizedBox(height: 16),
                    _buildVideosList(appTema),

                    const SizedBox(height: 32),

                    _buildSecaoTitulo('📅 Dias Mais Ativos', appTema),
                    const SizedBox(height: 16),
                    _buildFrequenciaChart(appTema),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildFiltroPeriodo(AppTema appTema) {
    return Row(
      children: [
        Text(
          'Período:',
          style: TextStyle(
            color: appTema.textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildPeriodoChip('7 dias', 7, appTema),
                const SizedBox(width: 8),
                _buildPeriodoChip('15 dias', 15, appTema),
                const SizedBox(width: 8),
                _buildPeriodoChip('30 dias', 30, appTema),
                const SizedBox(width: 8),
                _buildPeriodoChip('Tudo', -1, appTema),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodoChip(String label, int dias, AppTema appTema) {
    final isSelected = _periodoSelecionado == dias;

    return GestureDetector(
      onTap: () {
        setState(() => _periodoSelecionado = dias);
        _carregarAnalytics();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFA9DBF4)
              : (appTema.isDarkMode ? Colors.grey[800] : Colors.grey[200]),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFA9DBF4)
                : (appTema.isDarkMode ? Colors.white24 : Colors.black12),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : appTema.textColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String titulo,
    required String valor,
    required Color cor,
    required AppTema appTema,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: appTema.isDarkMode
              ? [
                  Colors.white.withValues(alpha: 0.15),
                  Colors.white.withValues(alpha: 0.08),
                ]
              : [
                  Colors.black.withValues(alpha: 0.08),
                  Colors.black.withValues(alpha: 0.05),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cor.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        children: [
          Icon(icon, color: cor, size: 32),
          const SizedBox(height: 8),
          Text(
            valor,
            style: TextStyle(
              color: appTema.textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            titulo,
            style: TextStyle(color: appTema.textSecondaryColor, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSecaoTitulo(String titulo, AppTema appTema) {
    return Text(
      titulo,
      style: TextStyle(
        color: appTema.textColor,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildGenerosList(AppTema appTema) {
    if (_generosMaisAssistidos.isEmpty) {
      return _buildEstadoVazio('Nenhum gênero assistido ainda', appTema);
    }

    final totalSegundos = _generosMaisAssistidos.values.fold(
      0,
      (a, b) => a + b,
    );

    if (totalSegundos == 0) {
      return _buildEstadoVazio('Nenhum tempo registrado', appTema);
    }

    return Column(
      children: _generosMaisAssistidos.entries.take(5).map((entry) {
        final percentual = (entry.value / totalSegundos * 100);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key,
                    style: TextStyle(
                      color: appTema.textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${percentual.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: appTema.textSecondaryColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: percentual / 100,
                backgroundColor: appTema.isDarkMode
                    ? Colors.grey[800]
                    : Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFFA9DBF4),
                ),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildVideosList(AppTema appTema) {
    if (_videosMaisAssistidos.isEmpty) {
      return _buildEstadoVazio('Nenhum vídeo assistido ainda', appTema);
    }

    return Column(
      children: _videosMaisAssistidos.map((video) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: appTema.isDarkMode
                ? Colors.grey[800]?.withValues(alpha: 0.5)
                : Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  video.videoThumbnail,
                  width: 80,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80,
                      height: 60,
                      color: Colors.grey[700],
                      child: const Icon(Icons.video_library, size: 30),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.videoTitulo,
                      style: TextStyle(
                        color: appTema.textColor,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Assistido ${video.vezesReassistido + 1}x',
                      style: TextStyle(
                        color: appTema.textSecondaryColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFrequenciaChart(AppTema appTema) {
    if (_frequenciaPorDia.isEmpty) {
      return _buildEstadoVazio('Nenhuma sessão registrada', appTema);
    }

    final maxSessoes = _frequenciaPorDia.values.fold(
      0,
      (max, valor) => valor > max ? valor : max,
    );

    return Column(
      children: _frequenciaPorDia.entries.map((entry) {
        final percentual = maxSessoes > 0 ? (entry.value / maxSessoes) : 0.0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  entry.key,
                  style: TextStyle(
                    color: appTema.textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: LinearProgressIndicator(
                  value: percentual,
                  backgroundColor: appTema.isDarkMode
                      ? Colors.grey[800]
                      : Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFA9DBF4),
                  ),
                  minHeight: 24,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${entry.value}',
                style: TextStyle(
                  color: appTema.textSecondaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEstadoVazio(String mensagem, AppTema appTema) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Text(
          mensagem,
          style: TextStyle(color: appTema.textSecondaryColor, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
