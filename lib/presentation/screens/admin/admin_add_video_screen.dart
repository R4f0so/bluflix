import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:bluflix/core/theme/app_theme.dart';
import 'package:bluflix/presentation/widgets/theme_toggle_button.dart';
import 'package:bluflix/data/services/video_service_youtube.dart';
import 'package:bluflix/data/models/video_model_youtube.dart';
import 'package:bluflix/utils/guards/admin_guard.dart'; // ✅ Adicionado

class AdminAddVideoScreen extends StatefulWidget {
  const AdminAddVideoScreen({super.key});

  @override
  State<AdminAddVideoScreen> createState() => _AdminAddVideoScreenState();
}

class _AdminAddVideoScreenState extends State<AdminAddVideoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _videoService = VideoServiceYoutube();

  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _youtubeUrlController = TextEditingController();

  final List<String> _todosGeneros = [
    'Ação',
    'Comédia',
    'Drama',
    'Terror',
    'Ficção Científica',
    'Romance',
    'Animação',
    'Documentário',
  ];

  final List<String> _generosSelecionados = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    AdminGuard.checkAdminAccess(context); // ✅ Verificação adicionada
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _youtubeUrlController.dispose();
    super.dispose();
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
          'Adicionar Vídeo do YouTube',
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
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFA9DBF4).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFA9DBF4),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.info_outline,
                                  color: Color(0xFFA9DBF4), size: 24),
                              const SizedBox(width: 8),
                              Text(
                                'Como adicionar vídeos:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: appTema.textColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '1. Faça upload do vídeo no YouTube\n'
                            '2. Configure como "Não listado"\n'
                            '3. Copie o link do vídeo\n'
                            '4. Cole abaixo e preencha os dados',
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: appTema.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildLabel('Link do YouTube', appTema),
                    TextFormField(
                      controller: _youtubeUrlController,
                      decoration: InputDecoration(
                        hintText: 'https://www.youtube.com/watch?v=...',
                        hintStyle: TextStyle(color: appTema.textSecondaryColor),
                        filled: true,
                        fillColor: appTema.isDarkMode
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.link),
                      ),
                      style: TextStyle(color: appTema.textColor),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Cole o link do vídeo do YouTube';
                        }
                        if (VideoModelYoutube.extractYoutubeId(value) == null) {
                          return 'Link do YouTube inválido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildLabel('Título', appTema),
                    TextFormField(
                      controller: _tituloController,
                      decoration: InputDecoration(
                        hintText: 'Digite o título do vídeo',
                        hintStyle: TextStyle(color: appTema.textSecondaryColor),
                        filled: true,
                        fillColor: appTema.isDarkMode
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: TextStyle(color: appTema.textColor),
                      maxLength: 100,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Digite o título do vídeo';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildLabel('Descrição', appTema),
                    TextFormField(
                      controller: _descricaoController,
                      decoration: InputDecoration(
                        hintText: 'Descreva o conteúdo do vídeo',
                        hintStyle: TextStyle(color: appTema.textSecondaryColor),
                        filled: true,
                        fillColor: appTema.isDarkMode
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: TextStyle(color: appTema.textColor),
                      maxLines: 4,
                      maxLength: 500,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Digite uma descrição';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildLabel('Gêneros', appTema),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _todosGeneros.map((genero) {
                        final isSelected =
                            _generosSelecionados.contains(genero);
                        return FilterChip(
                          label: Text(genero),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _generosSelecionados.add(genero);
                              } else {
                                _generosSelecionados.remove(genero);
                              }
                            });
                          },
                          selectedColor: const Color(0xFFA9DBF4),
                          checkmarkColor: Colors.black,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.black
                                : appTema.textColor,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        );
                      }).toList(),
                    ),
                    if (_generosSelecionados.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Selecione pelo menos um gênero',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red.shade300,
                          ),
                        ),
                      ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _adicionarVideo,
                        icon: const Icon(Icons.add, size: 24),
                        label: const Text(
                          'Adicionar Vídeo',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFA9DBF4),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildLabel(String texto, AppTema appTema) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: appTema.textColor,
        ),
      ),
    );
  }

  Future<void> _adicionarVideo() async {
    if (!_formKey.currentState!.validate()) return;
    if (_generosSelecionados.isEmpty) {
      _mostrarMensagem('Selecione pelo menos um gênero', erro: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final videoId = await _videoService.adicionarVideo(
        titulo: _tituloController.text.trim(),
        descricao: _descricaoController.text.trim(),
        youtubeUrl: _youtubeUrlController.text.trim(),
        generos: _generosSelecionados,
      );

      if (videoId != null) {
        if (!mounted) return;
        _mostrarMensagem('Vídeo adicionado com sucesso!');
        await Future.delayed(const Duration(seconds: 1));
        if (!mounted) return;
        context.pop();
      } else {
        _mostrarMensagem('Erro ao adicionar vídeo', erro: true);
      }
    } catch (e) {
      _mostrarMensagem('Erro: $e', erro: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _mostrarMensagem(String mensagem, {bool erro = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: erro ? Colors.red.shade400 : Colors.green.shade400,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
