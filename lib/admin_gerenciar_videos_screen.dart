import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'app_tema.dart';
import 'video_model_youtube.dart';
import 'admin_editar_video_screen.dart';

class AdminGerenciarVideosScreen extends StatefulWidget {
  const AdminGerenciarVideosScreen({super.key});

  @override
  State<AdminGerenciarVideosScreen> createState() =>
      _AdminGerenciarVideosScreenState();
}

class _AdminGerenciarVideosScreenState
    extends State<AdminGerenciarVideosScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _generoFiltro;
  bool _mostrarApenasInativos = false;

  final List<String> _generos = [
    'Todos',
    'Ação',
    'Comédia',
    'Drama',
    'Terror',
    'Ficção Científica',
    'Romance',
    'Animação',
    'Documentário',
  ];

  @override
  void initState() {
    super.initState();
    _verificarPermissaoAdmin();
  }

  Future<void> _verificarPermissaoAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        context.go('/login');
        return;
      }
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      final tipoUsuario = userDoc.data()?['tipoUsuario'] ?? 'usuario';

      if (tipoUsuario != 'admin') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Acesso negado! Apenas admins podem acessar.'),
              backgroundColor: Colors.red,
            ),
          );
          context.go('/catalogo');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao verificar permissões: $e'),
            backgroundColor: Colors.red,
          ),
        );
        context.go('/catalogo');
      }
    }
  }

  Stream<QuerySnapshot> _getVideosStream() {
    Query query = FirebaseFirestore.instance.collection('videos_youtube');

    // Filtro por gênero
    if (_generoFiltro != null && _generoFiltro != 'Todos') {
      query = query.where('generos', arrayContains: _generoFiltro);
    }

    // Filtro por status (ativo/inativo)
    if (_mostrarApenasInativos) {
      query = query.where('ativo', isEqualTo: false);
    }

    // Ordenar por data de upload
    query = query.orderBy('dataUpload', descending: true);

    return query.snapshots();
  }

  List<VideoModelYoutube> _filtrarPorBusca(List<VideoModelYoutube> videos) {
    if (_searchQuery.isEmpty) return videos;

    return videos.where((video) {
      final tituloMatch = video.titulo.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      final descricaoMatch = video.descricao.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      return tituloMatch || descricaoMatch;
    }).toList();
  }

  Future<void> _toggleStatusVideo(VideoModelYoutube video) async {
    try {
      await FirebaseFirestore.instance
          .collection('videos_youtube')
          .doc(video.id)
          .update({'ativo': !video.ativo});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              video.ativo
                  ? '✅ Vídeo desativado com sucesso!'
                  : '✅ Vídeo ativado com sucesso!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro ao alterar status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _confirmarExclusao(VideoModelYoutube video) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Confirmar Exclusão'),
        content: Text(
          'Tem certeza que deseja excluir o vídeo "${video.titulo}"?\n\n'
          'Esta ação é irreversível!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await _excluirVideo(video);
    }
  }

  Future<void> _excluirVideo(VideoModelYoutube video) async {
    try {
      await FirebaseFirestore.instance
          .collection('videos_youtube')
          .doc(video.id)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Vídeo excluído com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro ao excluir vídeo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navegarParaEdicao(VideoModelYoutube video) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AdminEditarVideoScreen(video: video),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appTema = Provider.of<AppTema>(context);

    return Scaffold(
      backgroundColor: appTema.backgroundColor,
      appBar: AppBar(
        title: const Text(
          '🎬 Gerenciar Vídeos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: appTema.corSecundaria,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle),
            tooltip: 'Adicionar Vídeo',
            onPressed: () => context.push('/admin/adicionar-video'),
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔍 BARRA DE BUSCA
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: appTema.textColor),
              decoration: InputDecoration(
                hintText: 'Buscar por título ou descrição...',
                hintStyle: TextStyle(
                  color: appTema.textColor.withValues(alpha: 0.6),
                ),
                prefixIcon: Icon(Icons.search, color: appTema.corSecundaria),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: appTema.isDarkMode
                    ? Colors.grey[800]
                    : Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),

          // 🎯 FILTROS
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                // Filtro de Gênero
                DropdownButton<String>(
                  value: _generoFiltro ?? 'Todos',
                  dropdownColor: appTema.isDarkMode
                      ? Colors.grey[800]
                      : Colors.grey[200],
                  style: TextStyle(color: appTema.textColor),
                  items: _generos.map((genero) {
                    return DropdownMenuItem(value: genero, child: Text(genero));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _generoFiltro = value == 'Todos' ? null : value;
                    });
                  },
                ),

                const SizedBox(width: 16),

                // Filtro de Status (Inativos)
                FilterChip(
                  label: Text(
                    'Apenas Inativos',
                    style: TextStyle(color: appTema.textColor),
                  ),
                  selected: _mostrarApenasInativos,
                  onSelected: (selected) {
                    setState(() => _mostrarApenasInativos = selected);
                  },
                  backgroundColor: appTema.isDarkMode
                      ? Colors.grey[800]
                      : Colors.grey[200],
                  selectedColor: Colors.orange.withValues(alpha: 0.3),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 📋 LISTA DE VÍDEOS
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getVideosStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      '❌ Erro ao carregar vídeos:\n${snapshot.error}',
                      style: TextStyle(color: appTema.textColor),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.video_library_outlined,
                          size: 100,
                          color: appTema.textColor.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhum vídeo encontrado',
                          style: TextStyle(
                            fontSize: 18,
                            color: appTema.textColor.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Converter documentos em VideoModelYoutube
                List<VideoModelYoutube> videos = snapshot.data!.docs
                    .map((doc) => VideoModelYoutube.fromFirestore(doc))
                    .toList();

                // Aplicar filtro de busca
                videos = _filtrarPorBusca(videos);

                if (videos.isEmpty) {
                  return Center(
                    child: Text(
                      '🔍 Nenhum resultado encontrado para "$_searchQuery"',
                      style: TextStyle(
                        fontSize: 16,
                        color: appTema.textColor.withValues(alpha: 0.6),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: videos.length,
                  itemBuilder: (context, index) {
                    final video = videos[index];
                    return _buildVideoCard(video, appTema);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCard(VideoModelYoutube video, AppTema appTema) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: appTema.isDarkMode ? Colors.grey[850] : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // THUMBNAIL
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.network(
                  video.thumbnailUrl,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.grey[700],
                      child: const Icon(
                        Icons.broken_image,
                        size: 50,
                        color: Colors.white54,
                      ),
                    );
                  },
                ),
              ),

              // Badge de Status
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: video.ativo ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    video.ativo ? '✓ ATIVO' : '✗ INATIVO',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // INFORMAÇÕES
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
                Text(
                  video.descricao,
                  style: TextStyle(
                    fontSize: 14,
                    color: appTema.textColor.withValues(alpha: 0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 12),

                // Gêneros
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: video.generos.map((genero) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: appTema.corSecundaria.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: appTema.corSecundaria,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        genero,
                        style: TextStyle(
                          color: appTema.corSecundaria,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                // BOTÕES DE AÇÃO
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Ativar/Desativar
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _toggleStatusVideo(video),
                        icon: Icon(
                          video.ativo ? Icons.visibility_off : Icons.visibility,
                          size: 18,
                        ),
                        label: Text(
                          video.ativo ? 'Desativar' : 'Ativar',
                          style: const TextStyle(fontSize: 12),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: video.ativo
                              ? Colors.orange
                              : Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Editar
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _navegarParaEdicao(video),
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text(
                          'Editar',
                          style: TextStyle(fontSize: 12),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Excluir
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _confirmarExclusao(video),
                        icon: const Icon(Icons.delete, size: 18),
                        label: const Text(
                          'Excluir',
                          style: TextStyle(fontSize: 12),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
