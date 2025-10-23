import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'app_tema.dart';
import 'perfil_provider.dart';
import 'widgets/theme_toggle_button.dart';

class MudarPerfilScreen extends StatefulWidget {
  const MudarPerfilScreen({super.key});

  @override
  State<MudarPerfilScreen> createState() => _MudarPerfilScreenState();
}

class _MudarPerfilScreenState extends State<MudarPerfilScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _perfilPai;
  List<Map<String, dynamic>> _perfisFilhos = [];

  @override
  void initState() {
    super.initState();
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

          setState(() {
            _perfilPai = {
              'apelido': data?['apelido'] ?? 'Usuário',
              'avatar': data?['avatar'] ?? 'assets/avatar1.png',
              'tipo': 'pai',
            };

            final perfis = data?['perfisFilhos'] as List<dynamic>? ?? [];
            _perfisFilhos = perfis
                .map((p) => Map<String, dynamic>.from(p))
                .toList();
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Erro ao carregar perfis: $e');
      setState(() => _isLoading = false);
    }
  }

  void _selecionarPerfil(Map<String, dynamic> perfil) async {
    print("🔵 _selecionarPerfil chamado");
    print("   Perfil selecionado: ${perfil['apelido']}");

    final perfilProvider = Provider.of<PerfilProvider>(context, listen: false);

    final apelido = perfil['apelido'] ?? 'Usuário';
    final avatar = perfil['avatar'] ?? 'assets/avatar1.png';
    final isPai = perfil['tipo'] == 'pai';

    print("   Apelido: $apelido");
    print("   Avatar: $avatar");
    print("   IsPai: $isPai");

    // Salva o perfil ativo
    await perfilProvider.setPerfilAtivo(
      apelido: apelido,
      avatar: avatar,
      isPai: isPai,
    );

    print("✅ Perfil salvo, voltando para catálogo");

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Perfil "$apelido" selecionado!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );

    // Volta para o catálogo
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
              // AppBar customizada
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Image.asset("assets/logo.png", height: 40),
                    const Spacer(),
                    const ThemeToggleButton(),
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

              // Título
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Quem está assistindo?',
                  style: TextStyle(
                    color: appTema.textColor,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Lista de perfis
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Perfil Pai
                      if (_perfilPai != null) ...[
                        _buildPerfilCard(_perfilPai!, appTema, isPai: true),
                        const SizedBox(height: 20),
                      ],

                      // Perfis Filhos
                      if (_perfisFilhos.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40.0),
                          child: Text(
                            'Perfis Familiares',
                            style: TextStyle(
                              color: appTema.textSecondaryColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...(_perfisFilhos.map(
                          (perfil) => Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: _buildPerfilCard(perfil, appTema),
                          ),
                        )),
                      ],

                      // Mensagem se não houver perfis filhos
                      if (_perfisFilhos.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.family_restroom,
                                size: 80,
                                color: appTema.textColor.withValues(alpha: 0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Nenhum perfil familiar criado',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: appTema.textSecondaryColor,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () {
                                  context.push('/adicionar-perfis');
                                },
                                icon: const Icon(
                                  Icons.add,
                                  color: Colors.black,
                                ),
                                label: const Text(
                                  'Adicionar Familiar',
                                  style: TextStyle(color: Colors.black),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFA9DBF4),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Botão Voltar
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => context.pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA9DBF4),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Voltar', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPerfilCard(
    Map<String, dynamic> perfil,
    AppTema appTema, {
    bool isPai = false,
  }) {
    return GestureDetector(
      onTap: () => _selecionarPerfil(perfil),
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: appTema.isDarkMode
              ? Colors.grey[800]?.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: appTema.isDarkMode ? Colors.white24 : Colors.black12,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage(
                    perfil['avatar'] ?? 'assets/avatar1.png',
                  ),
                ),
                if (isPai)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFA9DBF4),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 20),
            // Nome e tipo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    perfil['apelido'] ?? 'Sem nome',
                    style: TextStyle(
                      color: appTema.textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isPai ? 'Perfil Principal' : 'Perfil Filho',
                    style: TextStyle(
                      color: appTema.textSecondaryColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            // Ícone de seta
            Icon(
              Icons.arrow_forward_ios,
              color: appTema.textSecondaryColor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
