import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bluflix/core/theme/app_theme.dart';
import 'package:bluflix/presentation/widgets/theme_toggle_button.dart';
import 'package:bluflix/data/models/video_model_youtube.dart';
import 'package:bluflix/data/services/video_service_youtube.dart';
import 'package:bluflix/presentation/providers/perfil_provider.dart';

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

  // ✅ NOVO: Controle de favoritos
  int _favoritosCount = 0;
  Set<String> _videosFavoritados = {};

  @override
  void initState() {
    super.initState();
    _carregarVideos();
    _carregarFavoritos(); // ✅ NOVO
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

  // ═══════════════════════════════════════════════════════════════
  // CARREGAR FAVORITOS DO PERFIL ATIVO
  // ═══════════════════════════════════════════════════════════════
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

      print('📱 Carregando favoritos do perfil: $perfilAtivo');

      // ✅ NOVO CAMINHO: users/{uid}/perfis/{perfil}/favoritos
      final favoritosSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('perfis') // ← Nova coleção
          .doc(perfilAtivo) // ← Nome do perfil
          .collection('favoritos') // ← Favoritos deste perfil
          .get();

      setState(() {
        _favoritosCount = favoritosSnapshot.docs.length;
        _videosFavoritados = favoritosSnapshot.docs
            .map((doc) => doc.data()['videoId'] as String)
            .toSet();
      });

      print('✅ Favoritos carregados: $_favoritosCount');
    } catch (e) {
      print('❌ Erro ao carregar favoritos: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // ADICIONAR/REMOVER FAVORITO
  // ═══════════════════════════════════════════════════════════════
  Future<void> _toggleFavorito(VideoModelYoutube video) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // ✅ Pegar o perfil ativo
      final perfilProvider = Provider.of<PerfilProvider>(
        context,
        listen: false,
      );
      final perfilAtivo = perfilProvider.perfilAtivoApelido ?? 'Usuário';

      final videoId = video.youtubeId;

      // ✅ NOVO CAMINHO: users/{uid}/perfis/{perfil}/favoritos
      final favoritosRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('perfis') // ← Nova coleção
          .doc(perfilAtivo) // ← Nome do perfil
          .collection('favoritos'); // ← Favoritos deste perfil

      final isFavorito = _videosFavoritados.contains(videoId);

      if (isFavorito) {
        // ═══════════════════════════════════════════════════════════
        // REMOVER DOS FAVORITOS
        // ═══════════════════════════════════════════════════════════
        final querySnapshot = await favoritosRef
            .where('videoId', isEqualTo: videoId)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          await querySnapshot.docs.first.reference.delete();
        }

        setState(() {
          _videosFavoritados.remove(videoId);
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
        // ═══════════════════════════════════════════════════════════
        // ADICIONAR AOS FAVORITOS
        // ═══════════════════════════════════════════════════════════
        await favoritosRef.add({
          'videoId': videoId,
          'titulo': video.titulo,
          'genero': video.generos.isNotEmpty
              ? video.generos.first
              : widget.genero,
          'thumbnailUrl': video.thumbnailUrl,
          'youtubeUrl': 'https://www.youtube.com/watch?v=${video.youtubeId}',
          'adicionadoEm': FieldValue.serverTimestamp(),
        });

        setState(() {
          _videosFavoritados.add(videoId);
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
      print('❌ Erro ao alternar favorito: $e');
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
      // ✅ NOVO: FAB de Favoritos
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/favoritos');
          if (!mounted) return;
          _carregarFavoritos(); // Recarrega ao voltar
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
      onRefresh: () async {
        await _carregarVideos();
        await _carregarFavoritos();
      },
      color: const Color(0xFFA9DBF4),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _videos.length,
        itemBuilder: (context, index) {
          final video = _videos[index];
          final isFavorito = _videosFavoritados.contains(video.youtubeId);
          return _buildVideoCard(video, appTema, isFavorito);
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // WIDGET: CARD DE VÍDEO
  // ═══════════════════════════════════════════════════════════════
  Widget _buildVideoCard(
    VideoModelYoutube video,
    AppTema appTema,
    bool isFavorito,
  ) {
    return GestureDetector(
      onTap: () async {
        final result = await _abrirPlayer(video);
        // Se retornou true, recarrega favoritos
        if (result == true && mounted) {
          _carregarFavoritos();
        }
      },
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
                  // ✅ NOVO: Botão de favorito na thumbnail
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      onPressed: () => _toggleFavorito(video),
                      icon: Icon(
                        isFavorito ? Icons.favorite : Icons.favorite_border,
                        color: isFavorito ? Colors.red : Colors.white,
                        size: 32,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withValues(alpha: 0.6),
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
  Future<dynamic> _abrirPlayer(VideoModelYoutube video) async {
    // Registra visualização
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _videoService.registrarVisualizacao(video.id, user.uid);
    }

    // Navega para o player e espera resultado
    return await context.push('/player', extra: video);
  }
}
