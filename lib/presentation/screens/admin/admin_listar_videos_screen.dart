import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:bluflix/core/theme/app_theme.dart';
import 'package:bluflix/presentation/widgets/theme_toggle_button.dart';
import 'package:bluflix/data/services/video_service_youtube.dart';
import 'package:bluflix/data/models/video_model_youtube.dart';
import 'package:bluflix/utils/guards/admin_guard.dart'; // ✅ Corrigido

class AdminListarVideosScreen extends StatefulWidget {
  const AdminListarVideosScreen({super.key});

  @override
  State<AdminListarVideosScreen> createState() =>
      _AdminListarVideosScreenState();
}

class _AdminListarVideosScreenState extends State<AdminListarVideosScreen> {
  final VideoServiceYoutube _videoService = VideoServiceYoutube();
  List<VideoModelYoutube> _todosVideos = [];
  List<VideoModelYoutube> _videosFiltrados = [];
  bool _isLoading = true;
  String _filtroAtual = 'Todos'; // Todos, Ativos, Inativos
  final TextEditingController _buscaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    AdminGuard.checkAdminAccess(context); // ✅ Adicionado
    _carregarVideos();
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  Future<void> _carregarVideos() async {
    setState(() => _isLoading = true);

    try {
      final videos = await _videoService.buscarTodosVideos();

      setState(() {
        _todosVideos = videos;
        _aplicarFiltros();
        _isLoading = false;
      });

      print('📹 ${videos.length} vídeos carregados');
    } catch (e) {
      print('❌ Erro ao carregar vídeos: $e');
      setState(() => _isLoading = false);
    }
  }

  void _aplicarFiltros() {
    List<VideoModelYoutube> resultado = List.from(_todosVideos);

    if (_filtroAtual == 'Ativos') {
      resultado = resultado.where((v) => v.ativo).toList();
    } else if (_filtroAtual == 'Inativos') {
      resultado = resultado.where((v) => !v.ativo).toList();
    }

    final busca = _buscaController.text.toLowerCase();
    if (busca.isNotEmpty) {
      resultado = resultado.where((v) {
        return v.titulo.toLowerCase().contains(busca) ||
            v.descricao.toLowerCase().contains(busca) ||
            v.generos.any((g) => g.toLowerCase().contains(busca));
      }).toList();
    }

    setState(() {
      _videosFiltrados = resultado;
    });
  }

  Future<void> _toggleStatusVideo(VideoModelYoutube video) async {
    final novoStatus = !video.ativo;

    try {
      final sucesso = await _videoService.atualizarVideo(
        videoId: video.id,
        ativo: novoStatus,
      );

      if (sucesso) {
        _mostrarMensagem(
          novoStatus ? 'Vídeo ativado!' : 'Vídeo desativado!',
          sucesso: true,
        );
        _carregarVideos();
      } else {
        _mostrarMensagem('Erro ao alterar status', sucesso: false);
      }
    } catch (e) {
      _mostrarMensagem('Erro: $e', sucesso: false);
    }
  }

  Future<void> _confirmarExclusao(VideoModelYoutube video) async {
    final appTema = Provider.of<AppTema>(context, listen: false);

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: appTema.isDarkMode ? Colors.grey[900] : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.red.withValues(alpha: 0.5), width: 2),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.red,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Excluir Vídeo',
                style: TextStyle(color: appTema.textColor),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tem certeza que deseja excluir:',
              style: TextStyle(color: appTema.textSecondaryColor),
            ),
            const SizedBox(height: 12),
            Text(
              '"${video.titulo}"',
              style: TextStyle(
                color: appTema.textColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Esta ação não pode ser desfeita!',
              style: TextStyle(
                color: Colors.red[300],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar', style: TextStyle(color: appTema.textColor)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
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
      final sucesso = await _videoService.excluirVideo(video.id);

      if (sucesso) {
        _mostrarMensagem('Vídeo excluído com sucesso!', sucesso: true);
        _carregarVideos();
      } else {
        _mostrarMensagem('Erro ao excluir vídeo', sucesso: false);
      }
    } catch (e) {
      _mostrarMensagem('Erro: $e', sucesso: false);
    }
  }

  void _mostrarMensagem(String mensagem, {required bool sucesso}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: sucesso ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appTema = Provider.of<AppTema>(context);

    return Scaffold(
      backgroundColor: appTema.backgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFFA9DBF4),
        foregroundColor: Colors.black,
        title: const Text(
          'Gerenciar Vídeos',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: appTema.isDarkMode
                        ? Colors.grey[900]
                        : Colors.grey[100],
                    border: Border(
                      bottom: BorderSide(
                        color: appTema.isDarkMode
                            ? Colors.white24
                            : Colors.black12,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _buscaController,
                        onChanged: (_) => _aplicarFiltros(),
                        style: TextStyle(color: appTema.textColor),
                        decoration: InputDecoration(
                          hintText: 'Buscar por título, descrição ou gênero...',
                          hintStyle: TextStyle(
                            color: appTema.textSecondaryColor,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: appTema.textSecondaryColor,
                          ),
                          suffixIcon: _buscaController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: appTema.textSecondaryColor,
                                  ),
                                  onPressed: () {
                                    _buscaController.clear();
                                    _aplicarFiltros();
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: appTema.isDarkMode
                              ? Colors.grey[800]
                              : Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildFiltroChip('Todos', appTema)),
                          const SizedBox(width: 8),
                          Expanded(child: _buildFiltroChip('Ativos', appTema)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildFiltroChip('Inativos', appTema),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_videosFiltrados.length} vídeo(s)',
                            style: TextStyle(
                              color: appTema.textSecondaryColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await context.push('/admin-add-video');
                              _carregarVideos();
                            },
                            icon: const Icon(Icons.add, size: 20),
                            label: const Text('Novo Vídeo'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFA9DBF4),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _videosFiltrados.isEmpty
                      ? _buildEstadoVazio(appTema)
                      : RefreshIndicator(
                          onRefresh: _carregarVideos,
                          color: const Color(0xFFA9DBF4),
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _videosFiltrados.length,
                            itemBuilder: (context, index) {
                              final video = _videosFiltrados[index];
                              return _buildVideoCard(video, appTema);
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildFiltroChip(String filtro, AppTema appTema) {
    final isSelected = _filtroAtual == filtro;

    return GestureDetector(
      onTap: () {
        setState(() {
          _filtroAtual = filtro;
          _aplicarFiltros();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFA9DBF4)
              : (appTema.isDarkMode ? Colors.grey[800] : Colors.white),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFA9DBF4)
                : (appTema.isDarkMode ? Colors.white24 : Colors.black12),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          filtro,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.black : appTema.textColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildEstadoVazio(AppTema appTema) {
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
            _buscaController.text.isNotEmpty
                ? 'Tente uma busca diferente'
                : 'Adicione vídeos para começar',
            style: TextStyle(fontSize: 16, color: appTema.textSecondaryColor),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              await context.push('/admin-add-video');
              _carregarVideos();
            },
            icon: const Icon(Icons.add),
            label: const Text('Adicionar Primeiro Vídeo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFA9DBF4),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCard(VideoModelYoutube video, AppTema appTema) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: appTema.isDarkMode
            ? Colors.grey[900]?.withValues(alpha: 0.5)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: video.ativo
              ? (appTema.isDarkMode ? Colors.white24 : Colors.black12)
              : Colors.orange.withValues(alpha: 0.5),
          width: video.ativo ? 1 : 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Stack(
              children: [
                Image.network(
                  video.thumbnailUrl,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 180,
                      color: Colors.grey.shade800,
                      child: const Icon(
                        Icons.video_library,
                        size: 60,
                        color: Colors.white54,
                      ),
                    );
                  },
                ),
                if (!video.ativo)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'INATIVO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: video.generos.map((genero) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFA9DBF4).withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFA9DBF4),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        genero,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: appTema.textColor,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _toggleStatusVideo(video),
                        icon: Icon(
                          video.ativo ? Icons.visibility_off : Icons.visibility,
                          size: 18,
                        ),
                        label: Text(
                          video.ativo ? 'Desativar' : 'Ativar',
                          style: const TextStyle(fontSize: 14),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: video.ativo
                              ? Colors.orange
                              : Colors.green,
                          side: BorderSide(
                            color: video.ativo ? Colors.orange : Colors.green,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _confirmarExclusao(video),
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text(
                          'Excluir',
                          style: TextStyle(fontSize: 14),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
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
}
