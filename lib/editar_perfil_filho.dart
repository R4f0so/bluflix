import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'app_tema.dart';
import 'perfil_provider.dart';
import 'widgets/theme_toggle_button.dart';

class EditarPerfilFilhoScreen extends StatefulWidget {
  final int perfilIndex; // Índice do perfil no array
  final Map<String, dynamic> perfilAtual; // Dados atuais do perfil

  const EditarPerfilFilhoScreen({
    super.key,
    required this.perfilIndex,
    required this.perfilAtual,
  });

  @override
  State<EditarPerfilFilhoScreen> createState() =>
      _EditarPerfilFilhoScreenState();
}

class _EditarPerfilFilhoScreenState extends State<EditarPerfilFilhoScreen> {
  final TextEditingController _apelidoController = TextEditingController();
  bool _isLoading = false;
  final Map<String, bool> _interessesSelecionados = {};

  // Lista de interesses disponíveis
  final Map<String, Map<String, dynamic>> _todosInteresses = {
    'Ação': {'emoji': '💥', 'cor': Colors.red},
    'Comédia': {'emoji': '😂', 'cor': Colors.orange},
    'Drama': {'emoji': '🎭', 'cor': Colors.purple},
    'Terror': {'emoji': '👻', 'cor': Colors.grey},
    'Ficção Científica': {'emoji': '🚀', 'cor': Colors.blue},
    'Romance': {'emoji': '💕', 'cor': Colors.pink},
    'Animação': {'emoji': '🎨', 'cor': Colors.green},
    'Documentário': {'emoji': '📚', 'cor': Colors.brown},
  };

  @override
  void initState() {
    super.initState();

    // Inicializa com dados atuais
    _apelidoController.text = widget.perfilAtual['apelido'] ?? '';

    // Inicializa interesses
    final interessesAtuais =
        widget.perfilAtual['interesses'] as List<dynamic>? ?? [];
    for (var interesse in _todosInteresses.keys) {
      _interessesSelecionados[interesse] = interessesAtuais.contains(interesse);
    }
  }

  @override
  void dispose() {
    _apelidoController.dispose();
    super.dispose();
  }

  Future<void> _salvarAlteracoes() async {
    final apelido = _apelidoController.text.trim();

    // Validações
    if (apelido.isEmpty) {
      _mostrarErro('Por favor, insira um apelido');
      return;
    }

    final interessesSelecionados = _interessesSelecionados.entries
        .where((entry) => entry.value == true)
        .map((entry) => entry.key)
        .toList();

    if (interessesSelecionados.isEmpty) {
      _mostrarErro('Selecione pelo menos um interesse');
      return;
    }

    // ✅ CORREÇÃO: Confirmar se o usuário realmente quer salvar
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        final appTema = Provider.of<AppTema>(context, listen: false);
        return AlertDialog(
          backgroundColor: appTema.isDarkMode ? Colors.grey[900] : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Color(0xFFA9DBF4),
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Salvar Alterações?',
                  style: TextStyle(color: appTema.textColor),
                ),
              ),
            ],
          ),
          content: Text(
            'Deseja realmente salvar as alterações feitas no perfil?',
            style: TextStyle(color: appTema.textSecondaryColor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Cancelar',
                style: TextStyle(color: appTema.textSecondaryColor),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA9DBF4),
                foregroundColor: Colors.black,
              ),
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      print("════════════════════════════════");
      print("💾 ATUALIZANDO PERFIL FILHO");
      print("   Índice: ${widget.perfilIndex}");
      print("   Novo Apelido: $apelido");
      print("   Novos Interesses: $interessesSelecionados");
      print("════════════════════════════════");

      // Busca o documento do usuário
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception('Documento do usuário não encontrado');
      }

      // Pega o array de perfis filhos
      List<dynamic> perfisFilhos = userDoc.data()?['perfisFilhos'] ?? [];

      // ✅ VALIDAÇÃO: Verifica se já existe outro perfil com esse apelido
      final apelidoOriginal = widget.perfilAtual['apelido'];
      if (apelido != apelidoOriginal) {
        final apelidoJaExiste = perfisFilhos.any(
          (p) => p['apelido'] == apelido,
        );

        if (apelidoJaExiste) {
          if (!mounted) return;
          _mostrarErro(
            'Já existe um perfil com o apelido "$apelido". Escolha outro nome.',
          );
          setState(() => _isLoading = false);
          return;
        }
      }

      // ✅ CORREÇÃO: Validação mais robusta do índice
      if (perfisFilhos.isEmpty) {
        throw Exception('Nenhum perfil filho encontrado');
      }

      if (widget.perfilIndex < 0 || widget.perfilIndex >= perfisFilhos.length) {
        throw Exception(
          'Índice do perfil inválido (${widget.perfilIndex}/${perfisFilhos.length})',
        );
      }

      // ✅ CORREÇÃO: Verifica se o apelido original ainda existe no índice correto
      final perfilNoIndice = perfisFilhos[widget.perfilIndex];
      if (perfilNoIndice['apelido'] != widget.perfilAtual['apelido']) {
        // O perfil mudou de posição, tenta encontrar pelo apelido original
        final indexCorreto = perfisFilhos.indexWhere(
          (p) => p['apelido'] == widget.perfilAtual['apelido'],
        );

        if (indexCorreto == -1) {
          throw Exception(
            'Perfil não encontrado. A lista pode ter sido modificada.',
          );
        }

        print(
          "⚠️ Perfil mudou de posição. Usando índice correto: $indexCorreto",
        );

        // Atualiza usando o índice correto (mantém o avatar original)
        perfisFilhos[indexCorreto] = {
          'apelido': apelido,
          'avatar':
              perfisFilhos[indexCorreto]['avatar'], // Mantém o avatar original
          'interesses': interessesSelecionados,
          'criadoEm': perfisFilhos[indexCorreto]['criadoEm'] ?? Timestamp.now(),
          'atualizadoEm': Timestamp.now(),
        };
      } else {
        // Tudo certo, atualiza normalmente (mantém o avatar original)
        perfisFilhos[widget.perfilIndex] = {
          'apelido': apelido,
          'avatar': widget.perfilAtual['avatar'], // Mantém o avatar original
          'interesses': interessesSelecionados,
          'criadoEm':
              perfisFilhos[widget.perfilIndex]['criadoEm'] ?? Timestamp.now(),
          'atualizadoEm': Timestamp.now(),
        };
      }

      // Salva no Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'perfisFilhos': perfisFilhos},
      );

      print("   ✅ Perfil atualizado com sucesso!");
      print("════════════════════════════════");

      if (!mounted) return;

      // ✅ CORREÇÃO: Atualiza provider de forma mais robusta
      final perfilProvider = Provider.of<PerfilProvider>(
        context,
        listen: false,
      );

      final apelidoAntigo = widget.perfilAtual['apelido'];
      final perfilEstaAtivo =
          perfilProvider.perfilAtivoApelido == apelidoAntigo;

      print("🔍 Verificando se precisa atualizar provider:");
      print("   Apelido antigo: $apelidoAntigo");
      print("   Apelido novo: $apelido");
      print("   Perfil ativo: ${perfilProvider.perfilAtivoApelido}");
      print("   Está ativo?: $perfilEstaAtivo");

      if (perfilEstaAtivo) {
        print("🔄 Perfil editado está ativo - Atualizando provider...");

        await perfilProvider.setPerfilAtivo(
          apelido: apelido,
          avatar: widget.perfilAtual['avatar'], // Mantém o avatar original
          isPai: false,
        );

        print("✅ Provider atualizado com sucesso!");

        if (!mounted) return;

        // Mensagem diferenciada para perfil ativo
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Perfil atualizado e ativo! As mudanças já estão visíveis.',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        print(
          "ℹ️ Perfil editado não está ativo - Não precisa atualizar provider",
        );

        if (!mounted) return;

        // Mensagem padrão
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil atualizado com sucesso!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Volta para a tela anterior
      context.pop(true); // true = sucesso
    } catch (e) {
      print("❌ ERRO ao atualizar perfil: $e");
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

              // Conteúdo
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Título
                      Text(
                        'Editar Perfil',
                        style: TextStyle(
                          color: appTema.textColor,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Personalize o perfil do familiar',
                        style: TextStyle(
                          color: appTema.textSecondaryColor,
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // ═══════════════════════════════════════════════
                      // AVATAR FIXO (não editável)
                      // ═══════════════════════════════════════════════
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: AssetImage(
                          widget.perfilAtual['avatar'],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // ═══════════════════════════════════════════════
                      // SEÇÃO: APELIDO
                      // ═══════════════════════════════════════════════
                      _buildSecaoTitulo('Apelido', appTema),

                      const SizedBox(height: 16),

                      TextField(
                        controller: _apelidoController,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: appTema.textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          hintText: "Digite o apelido",
                          hintStyle: TextStyle(
                            color: appTema.textColor.withValues(alpha: 0.5),
                          ),
                          filled: true,
                          fillColor: appTema.isDarkMode
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.white.withValues(alpha: 0.8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFA9DBF4),
                              width: 2,
                            ),
                          ),
                        ),
                        maxLength: 20,
                      ),

                      const SizedBox(height: 40),

                      // ═══════════════════════════════════════════════
                      // SEÇÃO: INTERESSES
                      // ═══════════════════════════════════════════════
                      _buildSecaoTitulo('Interesses', appTema),

                      const SizedBox(height: 16),

                      // Botão Selecionar Todas
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _toggleSelecaoTodas,
                          icon: Icon(
                            _algumInteresseSelecionado
                                ? Icons.deselect
                                : Icons.select_all,
                            color: const Color(0xFFA9DBF4),
                          ),
                          label: Text(
                            _algumInteresseSelecionado
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

                      const SizedBox(height: 16),

                      // Lista de interesses
                      ..._todosInteresses.entries.map((entry) {
                        final interesse = entry.key;
                        final dados = entry.value;
                        final isSelected =
                            _interessesSelecionados[interesse] ?? false;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: _buildInteresseCheckbox(
                            interesse: interesse,
                            emoji: dados['emoji'],
                            cor: dados['cor'],
                            isSelected: isSelected,
                            appTema: appTema,
                          ),
                        );
                      }),
                    ],
                  ),
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
                        child: const Text("Cancelar"),
                      ),
                    ),
                    const SizedBox(width: 20),
                    SizedBox(
                      width: 140,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _salvarAlteracoes,
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

  // ═══════════════════════════════════════════════════════════════
  // WIDGETS AUXILIARES
  // ═══════════════════════════════════════════════════════════════

  Widget _buildSecaoTitulo(String titulo, AppTema appTema) {
    return Text(
      titulo,
      style: TextStyle(
        color: appTema.textColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInteresseCheckbox({
    required String interesse,
    required String emoji,
    required Color cor,
    required bool isSelected,
    required AppTema appTema,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _interessesSelecionados[interesse] = !isSelected;
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
                interesse,
                style: TextStyle(
                  color: appTema.textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
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

  bool get _algumInteresseSelecionado =>
      _interessesSelecionados.values.any((v) => v == true);

  void _toggleSelecaoTodas() {
    setState(() {
      final novoValor = !_algumInteresseSelecionado;
      for (var interesse in _interessesSelecionados.keys) {
        _interessesSelecionados[interesse] = novoValor;
      }
    });
  }
}
