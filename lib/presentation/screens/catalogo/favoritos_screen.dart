import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bluflix/core/theme/app_theme.dart';
import 'package:bluflix/presentation/widgets/theme_toggle_button.dart';
import 'package:bluflix/presentation/providers/perfil_provider.dart';
import 'package:bluflix/data/models/video_model_youtube.dart';

class FavoritosScreen extends StatefulWidget {
  const FavoritosScreen({super.key});

  @override
  State<FavoritosScreen> createState() => _FavoritosScreenState();
}

class _FavoritosScreenState extends State<FavoritosScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _favoritos = [];

  @override
  void initState() {
    super.initState();
    _carregarFavoritos();
  }

  // ═══════════════════════════════════════════════════════════════
  // CARREGAR FAVORITOS DO PERFIL ATIVO
  // ═══════════════════════════════════════════════════════════════
  Future<void> _carregarFavoritos() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        return;
      }

      final perfilProvider = Provider.of<PerfilProvider>(
        context,
        listen: false,
      );
      final perfilAtivo = perfilProvider.perfilAtivoApelido ?? 'Usuário';

      print('📱 Carregando favoritos do perfil: $perfilAtivo');

      final favoritosSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('perfis')
          .doc(perfilAtivo)
          .collection('favoritos')
          .orderBy('adicionadoEm', descending: true)
          .get();

      if (!mounted) return;
      setState(() {
        _favoritos = favoritosSnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'docId': doc.id,
            'videoId': data['videoId'] ?? '',
            'titulo': data['titulo'] ?? 'Sem título',
            'genero': data['genero'] ?? '',
            'thumbnailUrl': data['thumbnailUrl'] ?? '',
            'youtubeUrl': data['youtubeUrl'] ?? '',
          };
        }).toList();
        _isLoading = false;
      });

      print('✅ Favoritos carregados: ${_favoritos.length}');
    } catch (e) {
      print('❌ Erro ao carregar favoritos: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // REMOVER FAVORITO
  // ═══════════════════════════════════════════════════════════════
  Future<void> _removerFavorito(String docId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final perfilProvider = Provider.of<PerfilProvider>(
        context,
        listen: false,
      );
      final perfilAtivo = perfilProvider.perfilAtivoApelido ?? 'Usuário';

      final confirmar = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Remover dos favoritos?'),
          content: const Text(
            'Tem certeza que deseja remover este vídeo dos favoritos?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Remover', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirmar != true) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('perfis')
          .doc(perfilAtivo)
          .collection('favoritos')
          .doc(docId)
          .delete();

      await _carregarFavoritos();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Removido dos favoritos!'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      print('❌ Erro ao remover favorito: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao remover: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // ABRIR VÍDEO NO PLAYER
  // ═══════════════════════════════════════════════════════════════
  Future<void> _abrirVideo(String videoId) async {
    try {
      final videoSnapshot = await FirebaseFirestore.instance
          .collection('videos_youtube')
          .where('youtubeId', isEqualTo: videoId)
          .limit(1)
          .get();

      if (videoSnapshot.docs.isEmpty) {
        throw 'Vídeo não encontrado';
      }

      final videoDoc = videoSnapshot.docs.first;
      final videoData = videoDoc.data();

      // ✅ CORRIGIDO: Sem thumbnail no construtor (é um getter!)
      final video = VideoModelYoutube(
        id: videoDoc.id,
        titulo: videoData['titulo'] ?? 'Sem título',
        descricao: videoData['descricao'] ?? '',
        youtubeId: videoId,
        youtubeUrl:
            videoData['youtubeUrl'] ??
            'https://www.youtube.com/watch?v=$videoId',
        generos: List<String>.from(videoData['generos'] ?? []),
        dataUpload: (videoData['dataUpload'] as Timestamp).toDate(),
        ativo: videoData['ativo'] ?? true,
      );

      if (!mounted) return;
      context.push('/player', extra: video);
    } catch (e) {
      print('❌ Erro ao abrir vídeo: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao abrir vídeo: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final appTema = Provider.of<AppTema>(context);

    return Scaffold(
      backgroundColor: appTema.backgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFFA9DBF4),
        foregroundColor: Colors.black,
        title: const Text(
          'Meus Favoritos',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
          : _favoritos.isEmpty
          ? _buildEmptyState(appTema)
          : _buildListaFavoritos(appTema),
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
            Icons.favorite_border,
            size: 80,
            color: appTema.textSecondaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum favorito ainda',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: appTema.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Adicione vídeos aos favoritos para vê-los aqui',
            style: TextStyle(fontSize: 16, color: appTema.textSecondaryColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // WIDGET: LISTA DE FAVORITOS
  // ═══════════════════════════════════════════════════════════════
  Widget _buildListaFavoritos(AppTema appTema) {
    return RefreshIndicator(
      onRefresh: _carregarFavoritos,
      color: const Color(0xFFA9DBF4),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _favoritos.length,
        itemBuilder: (context, index) {
          final favorito = _favoritos[index];
          return _buildFavoritoCard(favorito, appTema);
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // WIDGET: CARD DE FAVORITO
  // ═══════════════════════════════════════════════════════════════
  Widget _buildFavoritoCard(Map<String, dynamic> favorito, AppTema appTema) {
    return GestureDetector(
      onTap: () => _abrirVideo(favorito['videoId']),
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
            // ═══════════════════════════════════════════════════════
            // THUMBNAIL
            // ═══════════════════════════════════════════════════════
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Stack(
                children: [
                  // Imagem
                  Image.network(
                    favorito['thumbnailUrl'],
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

                  // Overlay de play
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

                  // Botão de remover
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      onPressed: () => _removerFavorito(favorito['docId']),
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 28,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.red.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ═══════════════════════════════════════════════════════
            // INFORMAÇÕES
            // ═══════════════════════════════════════════════════════
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    favorito['titulo'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: appTema.textColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Gênero
                  if (favorito['genero'].isNotEmpty)
                    Chip(
                      label: Text(
                        favorito['genero'],
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor: const Color(0xFFA9DBF4),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
