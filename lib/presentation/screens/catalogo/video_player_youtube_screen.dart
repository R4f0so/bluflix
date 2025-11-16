import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bluflix/core/theme/app_theme.dart';
import 'package:bluflix/data/models/video_model_youtube.dart';
import 'package:bluflix/data/services/analytics_service.dart';
import 'package:bluflix/presentation/providers/perfil_provider.dart';

class VideoPlayerYoutubeScreen extends StatefulWidget {
  final VideoModelYoutube video;

  const VideoPlayerYoutubeScreen({super.key, required this.video});

  @override
  State<VideoPlayerYoutubeScreen> createState() =>
      _VideoPlayerYoutubeScreenState();
}

class _VideoPlayerYoutubeScreenState extends State<VideoPlayerYoutubeScreen> {
  late YoutubePlayerController _controller;
  bool _isPlayerReady = false;

  // Analytics
  final AnalyticsService _analyticsService = AnalyticsService();
  String? _visualizacaoId;
  int _ultimaPosicao = 0;
  int _tempoTotalAssistido = 0;

  // Controle de favoritos
  int _favoritosCount = 0;
  bool _isFavorito = false;

  @override
  void initState() {
    super.initState();
    _inicializarPlayer();
    _iniciarRegistroVisualizacao();
    _carregarFavoritos();
  }

  void _inicializarPlayer() {
    _controller =
        YoutubePlayerController(
          initialVideoId: widget.video.youtubeId,
          flags: const YoutubePlayerFlags(
            autoPlay: true,
            mute: false,
            enableCaption: true,
            controlsVisibleAtStart: true,
            hideControls: false,
          ),
        )..addListener(() {
          if (_controller.value.isReady && !_isPlayerReady) {
            if (!mounted) return;
            setState(() {
              _isPlayerReady = true;
            });
          }

          // Rastrear tempo assistido
          if (_controller.value.isPlaying) {
            final posicaoAtual = _controller.value.position.inSeconds;

            if (posicaoAtual > _ultimaPosicao &&
                posicaoAtual - _ultimaPosicao <= 2) {
              _tempoTotalAssistido += (posicaoAtual - _ultimaPosicao);
            }

            _ultimaPosicao = posicaoAtual;
          }
        });
  }

  Future<void> _iniciarRegistroVisualizacao() async {
    final perfilProvider = Provider.of<PerfilProvider>(context, listen: false);

    if (!perfilProvider.isPerfilPai) {
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      final duracaoTotal = _controller.metadata.duration.inSeconds;

      _visualizacaoId = await _analyticsService.iniciarVisualizacao(
        videoId: widget.video.youtubeId,
        videoTitulo: widget.video.titulo,
        videoThumbnail: widget.video.thumbnailUrl,
        genero: widget.video.generos.isNotEmpty
            ? widget.video.generos.first
            : 'Desconhecido',
        perfilFilhoApelido: perfilProvider.perfilAtivoApelido ?? '',
        duracaoTotalSegundos: duracaoTotal,
      );

      print('📊 Analytics: Visualização iniciada');
      print('   ID: $_visualizacaoId');
      print('   Vídeo: ${widget.video.titulo}');
      print('   Perfil: ${perfilProvider.perfilAtivoApelido}');
    } else {
      print('📊 Analytics: Perfil pai - visualização não registrada');
    }
  }

  Future<void> _finalizarRegistroVisualizacao() async {
    if (_visualizacaoId != null) {
      // ✅ ATUALIZADO: Passa o perfil ao finalizar
      final perfilProvider = Provider.of<PerfilProvider>(
        context,
        listen: false,
      );

      await _analyticsService.finalizarVisualizacao(
        visualizacaoId: _visualizacaoId!,
        duracaoAssistidaSegundos: _tempoTotalAssistido,
        perfilFilhoApelido: perfilProvider.perfilAtivoApelido, // ✅ NOVO
      );

      final duracaoTotal = _controller.metadata.duration.inSeconds;
      final percentual = duracaoTotal > 0
          ? (_tempoTotalAssistido / duracaoTotal * 100)
          : 0;

      print('📊 Analytics: Visualização finalizada');
      print('   Tempo assistido: $_tempoTotalAssistido segundos');
      print('   Percentual: ${percentual.toStringAsFixed(1)}%');
    }
  }

  // ✅ ATUALIZADO: Carregar favoritos da subcoleção do perfil
  Future<void> _carregarFavoritos() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // ✅ Pegar o perfil ativo
      final perfilProvider = Provider.of<PerfilProvider>(
        context,
        listen: false,
      );
      final perfilAtivo = perfilProvider.perfilAtivoApelido ?? 'Usuário';

      // ✅ NOVO CAMINHO: users/{uid}/perfis/{perfil}/favoritos
      final favoritosSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('perfis')
          .doc(perfilAtivo)
          .collection('favoritos')
          .get();

      final videosFavoritados = favoritosSnapshot.docs
          .map((doc) => doc.data()['videoId'] as String)
          .toSet();

      if (!mounted) return;
      setState(() {
        _favoritosCount = favoritosSnapshot.docs.length;
        _isFavorito = videosFavoritados.contains(widget.video.youtubeId);
      });
    } catch (e) {
      print('Erro ao carregar favoritos: $e');
    }
  }

  // ✅ ATUALIZADO: Toggle favorito na subcoleção do perfil
  Future<void> _toggleFavorito() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // ✅ Pegar o perfil ativo
      final perfilProvider = Provider.of<PerfilProvider>(
        context,
        listen: false,
      );
      final perfilAtivo = perfilProvider.perfilAtivoApelido ?? 'Usuário';

      final videoId = widget.video.youtubeId;

      // ✅ NOVO CAMINHO: users/{uid}/perfis/{perfil}/favoritos
      final favoritosRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('perfis')
          .doc(perfilAtivo)
          .collection('favoritos');

      if (_isFavorito) {
        // ═══════════════════════════════════════════════════════
        // REMOVER DOS FAVORITOS
        // ═══════════════════════════════════════════════════════
        final querySnapshot = await favoritosRef
            .where('videoId', isEqualTo: videoId)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          await querySnapshot.docs.first.reference.delete();
        }

        if (!mounted) return;
        setState(() {
          _isFavorito = false;
          _favoritosCount--;
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removido dos favoritos'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        // ═══════════════════════════════════════════════════════
        // ADICIONAR AOS FAVORITOS
        // ═══════════════════════════════════════════════════════
        await favoritosRef.add({
          'videoId': videoId,
          'titulo': widget.video.titulo,
          'genero': widget.video.generos.isNotEmpty
              ? widget.video.generos.first
              : 'Desconhecido',
          'thumbnailUrl': widget.video.thumbnailUrl,
          'youtubeUrl':
              'https://www.youtube.com/watch?v=${widget.video.youtubeId}',
          'adicionadoEm': FieldValue.serverTimestamp(),
        });

        if (!mounted) return;
        setState(() {
          _isFavorito = true;
          _favoritosCount++;
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Adicionado aos favoritos!'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Erro ao alternar favorito: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _finalizarRegistroVisualizacao();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appTema = Provider.of<AppTema>(context);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          // Retorna true para indicar mudança nos favoritos
          context.pop(true);
        }
      },
      child: YoutubePlayerBuilder(
        player: YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: true,
          progressIndicatorColor: const Color(0xFFA9DBF4),
          progressColors: const ProgressBarColors(
            playedColor: Color(0xFFA9DBF4),
            handleColor: Color(0xFFA9DBF4),
          ),
        ),
        builder: (context, player) {
          return Scaffold(
            backgroundColor: appTema.backgroundColor,
            appBar: AppBar(
              backgroundColor: const Color(0xFFA9DBF4),
              foregroundColor: Colors.black,
              title: Text(
                widget.video.titulo,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, size: 28),
                onPressed: () async {
                  await _finalizarRegistroVisualizacao();
                  if (!mounted) return;
                  if (context.mounted) context.pop(true);
                },
              ),
              actions: [
                // Botão de favorito no AppBar
                IconButton(
                  onPressed: _toggleFavorito,
                  icon: Icon(
                    _isFavorito ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorito ? Colors.red : Colors.black,
                    size: 28,
                  ),
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Player
                  player,

                  // Informações do vídeo
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.video.titulo,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: appTema.textColor,
                          ),
                        ),

                        const SizedBox(height: 16),

                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: widget.video.generos.map((genero) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFA9DBF4),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                genero,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 20),

                        Divider(
                          color: appTema.isDarkMode
                              ? Colors.white.withValues(alpha: 0.2)
                              : Colors.black.withValues(alpha: 0.1),
                        ),

                        const SizedBox(height: 20),

                        if (widget.video.descricao.isNotEmpty) ...[
                          Text(
                            'Descrição',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: appTema.textColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.video.descricao,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              color: appTema.textSecondaryColor,
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: appTema.textSecondaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Adicionado em ${_formatarData(widget.video.dataUpload)}',
                              style: TextStyle(
                                fontSize: 14,
                                color: appTema.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // FAB de Favoritos
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () async {
                await _finalizarRegistroVisualizacao();
                if (!mounted) return;
                if (!context.mounted) return;
                context.pop(true);
                context.push('/favoritos');
              },
              backgroundColor: const Color(0xFFA9DBF4),
              icon: const Icon(Icons.favorite, color: Colors.red),
              label: Text(
                '$_favoritosCount',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatarData(DateTime data) {
    final meses = [
      'janeiro',
      'fevereiro',
      'março',
      'abril',
      'maio',
      'junho',
      'julho',
      'agosto',
      'setembro',
      'outubro',
      'novembro',
      'dezembro',
    ];

    return '${data.day} de ${meses[data.month - 1]} de ${data.year}';
  }
}
