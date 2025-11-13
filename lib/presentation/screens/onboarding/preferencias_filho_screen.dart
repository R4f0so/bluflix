import 'package:bluflix/presentation/providers/perfil_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:bluflix/core/theme/app_theme.dart';
import 'package:bluflix/presentation/widgets/theme_toggle_button.dart';

class PreferenciasFilhoScreen extends StatefulWidget {
  final String apelido;
  final String avatar;

  const PreferenciasFilhoScreen({
    super.key,
    required this.apelido,
    required this.avatar,
  });

  @override
  State<PreferenciasFilhoScreen> createState() =>
      _PreferenciasFilhoScreenState();
}

class _PreferenciasFilhoScreenState extends State<PreferenciasFilhoScreen> {
  bool _isLoading = false;

  // Lista de gêneros disponíveis (mesmos do catálogo)
  final Map<String, Map<String, dynamic>> _generos = {
    'Relaxamento': {'emoji': '😴', 'cor': Colors.blue},
    'Animação': {'emoji': '🎨', 'cor': Colors.purple},
    'Música': {'emoji': '🎵', 'cor': Colors.pink},
    'Natureza': {'emoji': '🌿', 'cor': Colors.green},
    'Ciências': {'emoji': '🔬', 'cor': Colors.cyan},
    'Arte': {'emoji': '🖌️', 'cor': Colors.orange},
    'Histórias': {'emoji': '📖', 'cor': Colors.brown},
    'Jogos': {'emoji': '🎮', 'cor': Colors.red},
  };

  // Map para controlar os checkboxes
  final Map<String, bool> _preferencias = {};

  @override
  void initState() {
    super.initState();
    // Inicializa todas as preferências como false
    for (var genero in _generos.keys) {
      _preferencias[genero] = false;
    }
  }

  bool get _algumaSelecionada => _preferencias.values.any((v) => v == true);

  Future<void> _salvarPreferencias() async {
    if (!_algumaSelecionada) {
      _mostrarErro('Selecione pelo menos um gênero de interesse');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      // Pega apenas os gêneros selecionados
      final List<String> generosSelecionados = _preferencias.entries
          .where((entry) => entry.value == true)
          .map((entry) => entry.key)
          .toList();

      print("════════════════════════════════");
      print("💾 SALVANDO PREFERÊNCIAS DO PERFIL FILHO");
      print("   Apelido: ${widget.apelido}");
      print("   Avatar: ${widget.avatar}");
      print("   Preferências: $generosSelecionados");
      print("════════════════════════════════");

      // Busca o documento do usuário
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception('Documento do usuário não encontrado');
      }

      // Pega a lista atual de perfis filhos
      List<dynamic> perfisFilhos = userDoc.data()?['perfisFilhos'] ?? [];

      // Verifica se já tem 4 perfis
      if (perfisFilhos.length >= 4) {
        if (!mounted) return;
        _mostrarErro('Limite de 4 perfis atingido!');
        setState(() => _isLoading = false);
        return;
      }

      // Cria o novo perfil filho com preferências
      final novoPerfilFilho = {
        'apelido': widget.apelido,
        'avatar': widget.avatar,
        'interesses': generosSelecionados, // ✅ Padronizado como 'interesses'
        'criadoEm': Timestamp.now(),
      };

      // Adiciona o novo perfil à lista
      perfisFilhos.add(novoPerfilFilho);

      // Atualiza o Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'perfisFilhos': perfisFilhos},
      );

      print("   ✅ Perfil filho salvo com preferências!");
      print("════════════════════════════════");

      if (!mounted) return;

      // Mostra mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Perfil "${widget.apelido}" criado com sucesso!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      if (!mounted) return;

      // Define o perfil filho como ativo
      final perfilProvider = Provider.of<PerfilProvider>(
        context,
        listen: false,
      );
      await perfilProvider.setPerfilAtivo(
        apelido: widget.apelido,
        avatar: widget.avatar,
        isPai: false,
      );
      // Navega para o catálogo
      context.go('/catalogo');
    } catch (e) {
      print("❌ ERRO ao salvar preferências: $e");
      if (!mounted) return;

      _mostrarErro('Erro ao salvar: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _toggleSelecaoTodas() {
    setState(() {
      final bool novoValor = !_algumaSelecionada;
      for (var genero in _generos.keys) {
        _preferencias[genero] = novoValor;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appTema = Provider.of<AppTema>(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(appTema.backgroundImage),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Image.asset("assets/logo.png", height: 40),
                    const Spacer(),
                    const ThemeToggleButton(showLogo: false),
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: Icon(
                        Icons.close,
                        color: appTema.textColor,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),

              // Título e subtítulo
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Avatar escolhido
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage(widget.avatar),
                    ),
                    const SizedBox(height: 12),

                    Text(
                      widget.apelido,
                      style: TextStyle(
                        color: appTema.textColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Text(
                      'Quais gêneros você gosta?',
                      style: TextStyle(
                        color: appTema.textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    Text(
                      'Selecione seus gêneros favoritos para\npersonalizar sua experiência',
                      style: TextStyle(
                        color: appTema.textSecondaryColor,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Botão "Selecionar Todas"
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _toggleSelecaoTodas,
                    icon: Icon(
                      _algumaSelecionada ? Icons.deselect : Icons.select_all,
                      color: const Color(0xFFA9DBF4),
                    ),
                    label: Text(
                      _algumaSelecionada
                          ? 'Desmarcar Todas'
                          : 'Selecionar Todas',
                      style: const TextStyle(
                        color: Color(0xFFA9DBF4),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFFA9DBF4),
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Lista de gêneros com checkboxes
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: _generos.entries.map((entry) {
                    final genero = entry.key;
                    final dados = entry.value;
                    final isSelected = _preferencias[genero] ?? false;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: _buildGeneroCheckbox(
                        genero: genero,
                        emoji: dados['emoji'],
                        cor: dados['cor'],
                        isSelected: isSelected,
                        appTema: appTema,
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Botões
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 140,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () => context.pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Voltar"),
                      ),
                    ),
                    const SizedBox(width: 20),
                    SizedBox(
                      width: 140,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _salvarPreferencias,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFA9DBF4),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text("Salvar"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGeneroCheckbox({
    required String genero,
    required String emoji,
    required Color cor,
    required bool isSelected,
    required AppTema appTema,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _preferencias[genero] = !isSelected;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? (appTema.isDarkMode
                    ? const Color(0xFFA9DBF4).withValues(alpha: 0.2)
                    : const Color(0xFFA9DBF4).withValues(alpha: 0.3))
              : (appTema.isDarkMode
                    ? Colors.grey[800]?.withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.7)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFA9DBF4)
                : (appTema.isDarkMode ? Colors.white24 : Colors.black12),
            width: isSelected ? 3 : 1,
          ),
        ),
        child: Row(
          children: [
            // Emoji e nome do gênero
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: cor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 32)),
              ),
            ),
            const SizedBox(width: 16),

            Expanded(
              child: Text(
                genero,
                style: TextStyle(
                  color: appTema.textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Checkbox
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFA9DBF4)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFA9DBF4)
                      : appTema.textSecondaryColor,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.black, size: 20)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
