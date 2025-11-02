import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_tema.dart';
import 'widgets/theme_toggle_button.dart';
import 'video_model_youtube.dart';
import 'video_service_youtube.dart';

class ListaVideosYoutubeScreen extends StatefulWidget {
  final String genero;

  const ListaVideosYoutubeScreen({super.key, required this.genero});

  @override
  State<ListaVideosYoutubeScreen> createState() =>
      _ListaVideosYoutubeScreenState();
}

class _ListaVideosYoutubeScreenState extends State<ListaVideosYoutubeScreen> {
  final VideoServiceYoutube _videoService = VideoServiceYoutube();
  List<VideoModelYoutube> _videos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarVideos();
  }

  Future<void> _carregarVideos() async {
    setState(() => _isLoading = true);

    try {
      final videos = await _videoService.buscarVideosPorGenero(widget.genero);

      setState(() {
        _videos = videos;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Erro ao carregar vídeos: $e');
      setState(() => _isLoading = false);
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
          widget.genero,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
          : _videos.isEmpty
          ? _buildEmptyState(appTema)
          : _buildListaVideos(appTema),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // WIDGET: ESTADO VAZIO
  // ═══════════════════════════════════════════════════════════════
  Widget _buildEmptyState(AppTema appTema) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_library_outlined,
            size: 80,
            color: appTema.textSecondaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum vídeo encontrado',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: appTema.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ainda não há vídeos neste gênero',
            style: TextStyle(fontSize: 16, color: appTema.textSecondaryColor),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // WIDGET: LISTA DE VÍDEOS
  // ═══════════════════════════════════════════════════════════════
  Widget _buildListaVideos(AppTema appTema) {
    return RefreshIndicator(
      onRefresh: _carregarVideos,
      color: const Color(0xFFA9DBF4),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _videos.length,
        itemBuilder: (context, index) {
          final video = _videos[index];
          return _buildVideoCard(video, appTema);
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // WIDGET: CARD DE VÍDEO
  // ═══════════════════════════════════════════════════════════════
  Widget _buildVideoCard(VideoModelYoutube video, AppTema appTema) {
    return GestureDetector(
      onTap: () => _abrirPlayer(video),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: appTema.isDarkMode
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: appTema.isDarkMode
                ? Colors.white.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail do YouTube
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Stack(
                children: [
                  // Imagem da thumbnail
                  Image.network(
                    video.thumbnailUrl,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 200,
                        color: Colors.grey.shade800,
                        child: const Icon(
                          Icons.video_library,
                          size: 60,
                          color: Colors.white54,
                        ),
                      );
                    },
                  ),
                  // Ícone de play
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.3),
                      child: const Icon(
                        Icons.play_circle_outline,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Informações do vídeo
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    video.titulo,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: appTema.textColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Descrição
                  if (video.descricao.isNotEmpty)
                    Text(
                      video.descricao,
                      style: TextStyle(
                        fontSize: 14,
                        color: appTema.textSecondaryColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                  const SizedBox(height: 12),

                  // Gêneros
                  Wrap(
                    spacing: 8,
                    children: video.generos.map((genero) {
                      return Chip(
                        label: Text(
                          genero,
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: const Color(0xFFA9DBF4),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // AÇÃO: ABRIR PLAYER
  // ═══════════════════════════════════════════════════════════════
  void _abrirPlayer(VideoModelYoutube video) {
    // Registra visualização
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _videoService.registrarVisualizacao(video.id, user.uid);
    }

    // Navega para o player
    context.push('/player', extra: video);
  }
}
