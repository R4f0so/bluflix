import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:bluflix/core/theme/app_theme.dart';
import 'package:bluflix/data/models/video_model_youtube.dart';

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

  @override
  void initState() {
    super.initState();
    _inicializarPlayer();
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
            setState(() {
              _isPlayerReady = true;
            });
          }
        });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appTema = Provider.of<AppTema>(context);

    return YoutubePlayerBuilder(
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
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, size: 28),
              onPressed: () => context.pop(),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ═══════════════════════════════════════════════════════
                // PLAYER DO YOUTUBE
                // ═══════════════════════════════════════════════════════
                player,

                // ═══════════════════════════════════════════════════════
                // INFORMAÇÕES DO VÍDEO
                // ═══════════════════════════════════════════════════════
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título
                      Text(
                        widget.video.titulo,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: appTema.textColor,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Gêneros
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

                      // Divisor
                      Divider(
                        color: appTema.isDarkMode
                            ? Colors.white.withValues(alpha: 0.2)
                            : Colors.black.withValues(alpha: 0.1),
                      ),

                      const SizedBox(height: 20),

                      // Descrição
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

                      // Data de upload
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
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // UTILITÁRIOS
  // ═══════════════════════════════════════════════════════════════

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
