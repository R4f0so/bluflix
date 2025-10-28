import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'app_tema.dart';
import 'perfil_provider.dart';
import 'widgets/theme_toggle_button.dart';

class GerenciamentoPaisScreen extends StatefulWidget {
  const GerenciamentoPaisScreen({super.key});

  @override
  State<GerenciamentoPaisScreen> createState() =>
      _GerenciamentoPaisScreenState();
}

class _GerenciamentoPaisScreenState extends State<GerenciamentoPaisScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _perfisFilhos = [];
  Map<String, dynamic>? _perfilPai;

  @override
  void initState() {
    super.initState();
    _carregarPerfis();
  }

  // ✅ SOLUÇÃO 1: Recarrega dados toda vez que a tela ganha foco
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _carregarPerfis();
  }

  Future<void> _carregarPerfis() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final data = userDoc.data();

          if (mounted) {
            setState(() {
              _perfilPai = {
                'apelido': data?['apelido'] ?? 'Usuário',
                'avatar': data?['avatar'] ?? 'assets/avatar1.png',
              };

              final perfis = data?['perfisFilhos'] as List<dynamic>? ?? [];
              _perfisFilhos = perfis
                  .map((p) => Map<String, dynamic>.from(p))
                  .toList();
              _isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      print('Erro ao carregar perfis: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _trocarParaPerfilFilho(Map<String, dynamic> perfil) async {
    final perfilProvider = Provider.of<PerfilProvider>(context, listen: false);

    await perfilProvider.setPerfilAtivo(
      apelido: perfil['apelido'],
      avatar: perfil['avatar'],
      isPai: false,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Trocado para perfil ${perfil['apelido']}'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );

    // Redireciona para o catálogo
    context.go('/catalogo');
  }

  @override
  Widget build(BuildContext context) {
    final appTema = Provider.of<AppTema>(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: appTema.backgroundColor,
        body: Center(
          child: CircularProgressIndicator(color: const Color(0xFFA9DBF4)),
        ),
      );
    }

    final bool limiteAtingido = _perfisFilhos.length >= 4;

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
                    // Botão de Configurações
                    IconButton(
                      onPressed: () async {
                        // Navega e espera retornar
                        await context.push('/perfil-configs');
                        // Recarrega dados ao voltar
                        if (mounted) {
                          _carregarPerfis();
                        }
                      },
                      icon: Icon(
                        Icons.settings,
                        color: appTema.textColor,
                        size: 28,
                      ),
                      tooltip: 'Configurações',
                    ),
                  ],
                ),
              ),

              // Informações do Perfil Pai
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage(
                        _perfilPai?['avatar'] ?? 'assets/avatar1.png',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _perfilPai?['apelido'] ?? 'Usuário',
                      style: TextStyle(
                        color: appTema.textColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Perfil Pai',
                      style: TextStyle(
                        color: appTema.textColor.withValues(alpha: 0.7),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Título da seção de perfis filhos
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Text(
                      'Perfis Filhos',
                      style: TextStyle(
                        color: appTema.textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${_perfisFilhos.length}/4)',
                      style: TextStyle(
                        color: appTema.textColor.withValues(alpha: 0.6),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Lista de perfis filhos
              Expanded(
                child: _perfisFilhos.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 80,
                              color: appTema.textColor.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhum perfil filho criado',
                              style: TextStyle(
                                color: appTema.textColor.withValues(alpha: 0.6),
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Toque no + para adicionar',
                              style: TextStyle(
                                color: appTema.textColor.withValues(alpha: 0.4),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            // Cards dos perfis filhos
                            ..._perfisFilhos.map(
                              (perfil) => _buildPerfilCard(perfil, appTema),
                            ),
                            // Botão adicionar (se não atingiu o limite)
                            if (!limiteAtingido)
                              GestureDetector(
                                onTap: () async {
                                  await context.push('/adicionar-perfis');
                                  // Recarrega dados ao voltar
                                  if (mounted) {
                                    _carregarPerfis();
                                  }
                                },
                                child: _buildAdicionarCard(appTema),
                              ),
                          ],
                        ),
                      ),
              ),

              // Botão adicionar (quando não há perfis)
              if (_perfisFilhos.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SizedBox(
                    width: 200,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await context.push('/adicionar-perfis');
                        // Recarrega dados ao voltar
                        if (mounted) {
                          _carregarPerfis();
                        }
                      },
                      icon: const Icon(Icons.add, size: 24),
                      label: const Text(
                        'Adicionar Perfil',
                        style: TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA9DBF4),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPerfilCard(Map<String, dynamic> perfil, AppTema appTema) {
    return GestureDetector(
      onTap: () => _trocarParaPerfilFilho(perfil),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: appTema.isDarkMode
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: appTema.isDarkMode ? Colors.white24 : Colors.black12,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage(
                perfil['avatar'] ?? 'assets/avatar_crianca1.png',
              ),
            ),
            const SizedBox(height: 12),
            Text(
              perfil['apelido'] ?? 'Perfil',
              style: TextStyle(
                color: appTema.textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {
                // TODO: Implementar edição de perfil filho
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Editar perfil em desenvolvimento'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: appTema.textColor,
                side: BorderSide(
                  color: appTema.textColor.withValues(alpha: 0.5),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Editar', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdicionarCard(AppTema appTema) {
    return Container(
      width: 160,
      height: 200,
      decoration: BoxDecoration(
        color: appTema.isDarkMode
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFA9DBF4),
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_circle_outline,
            size: 60,
            color: const Color(0xFFA9DBF4),
          ),
          const SizedBox(height: 12),
          Text(
            'Adicionar\nPerfil',
            style: TextStyle(
              color: appTema.textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
