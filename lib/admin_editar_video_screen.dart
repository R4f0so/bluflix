import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'app_tema.dart';
import 'video_model_youtube.dart';

class AdminEditarVideoScreen extends StatefulWidget {
  final VideoModelYoutube video;

  const AdminEditarVideoScreen({super.key, required this.video});

  @override
  State<AdminEditarVideoScreen> createState() => _AdminEditarVideoScreenState();
}

class _AdminEditarVideoScreenState extends State<AdminEditarVideoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tituloController;
  late TextEditingController _descricaoController;
  late List<String> _generosSelecionados;
  bool _isLoading = false;

  final List<String> _generosDisponiveis = [
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
    _tituloController = TextEditingController(text: widget.video.titulo);
    _descricaoController = TextEditingController(text: widget.video.descricao);
    _generosSelecionados = List.from(widget.video.generos);
  }

  Future<void> _salvarAlteracoes() async {
    if (!_formKey.currentState!.validate()) return;

    if (_generosSelecionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Selecione pelo menos um gênero!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('videos_youtube')
          .doc(widget.video.id)
          .update({
            'titulo': _tituloController.text.trim(),
            'descricao': _descricaoController.text.trim(),
            'generos': _generosSelecionados,
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Vídeo atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro ao salvar alterações: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appTema = Provider.of<AppTema>(context);

    return Scaffold(
      backgroundColor: appTema.backgroundColor,
      appBar: AppBar(
        title: const Text(
          '✏️ Editar Vídeo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: appTema.corSecundaria,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // PREVIEW DO VÍDEO
              Card(
                color: appTema.isDarkMode ? Colors.grey[850] : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: Image.network(
                        widget.video.thumbnailUrl,
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
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          const Icon(Icons.link, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'ID: ${widget.video.youtubeId}',
                              style: TextStyle(
                                fontSize: 12,
                                color: appTema.textColor.withValues(alpha: 0.6),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // CAMPO TÍTULO
              Text(
                'Título',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: appTema.textColor,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _tituloController,
                style: TextStyle(color: appTema.textColor),
                maxLength: 100,
                decoration: InputDecoration(
                  hintText: 'Digite o título do vídeo',
                  hintStyle: TextStyle(
                    color: appTema.textColor.withValues(alpha: 0.5),
                  ),
                  filled: true,
                  fillColor: appTema.isDarkMode
                      ? Colors.grey[800]
                      : Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  counterStyle: TextStyle(
                    color: appTema.textColor.withValues(alpha: 0.6),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'O título é obrigatório';
                  }
                  if (value.trim().length < 3) {
                    return 'O título deve ter pelo menos 3 caracteres';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // CAMPO DESCRIÇÃO
              Text(
                'Descrição',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: appTema.textColor,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descricaoController,
                style: TextStyle(color: appTema.textColor),
                maxLines: 4,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText: 'Digite uma descrição clara e acessível',
                  hintStyle: TextStyle(
                    color: appTema.textColor.withValues(alpha: 0.5),
                  ),
                  filled: true,
                  fillColor: appTema.isDarkMode
                      ? Colors.grey[800]
                      : Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  counterStyle: TextStyle(
                    color: appTema.textColor.withValues(alpha: 0.6),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'A descrição é obrigatória';
                  }
                  if (value.trim().length < 10) {
                    return 'A descrição deve ter pelo menos 10 caracteres';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // SELEÇÃO DE GÊNEROS
              Text(
                'Gêneros',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: appTema.textColor,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _generosDisponiveis.map((genero) {
                  final isSelected = _generosSelecionados.contains(genero);
                  return FilterChip(
                    label: Text(
                      genero,
                      style: TextStyle(
                        color: isSelected ? Colors.white : appTema.textColor,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
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
                    backgroundColor: appTema.isDarkMode
                        ? Colors.grey[800]
                        : Colors.grey[200],
                    selectedColor: appTema.corSecundaria,
                    checkmarkColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? appTema.corSecundaria
                            : appTema.textColor.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),

              // BOTÃO SALVAR
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _salvarAlteracoes,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appTema.corSecundaria,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        )
                      : const Text(
                          '💾 Salvar Alterações',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // BOTÃO CANCELAR
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: _isLoading
                      ? null
                      : () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: appTema.corSecundaria,
                    side: BorderSide(color: appTema.corSecundaria, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }
}
