import 'widgets/theme_toggle_button.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'app_tema.dart';

class AdicionarPerfisScreen extends StatefulWidget {
  const AdicionarPerfisScreen({super.key});

  @override
  State<AdicionarPerfisScreen> createState() => _AdicionarPerfisScreenState();
}

class _AdicionarPerfisScreenState extends State<AdicionarPerfisScreen> {
  bool _isLoading = true;
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
          final perfis = data?['perfisFilhos'] as List<dynamic>? ?? [];

          setState(() {
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
                  'Adicionar Perfis',
                  style: TextStyle(
                    color: appTema.textColor,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Conteúdo condicional
              Expanded(
                child: limiteAtingido
                    ? _buildLimiteAtingido(appTema)
                    : _buildGridPerfis(appTema),
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

  Widget _buildLimiteAtingido(AppTema appTema) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.group_off,
              size: 80,
              color: appTema.textColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Número de perfis excedido',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: appTema.textColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Remova um perfil para poder criar um novo',
              textAlign: TextAlign.center,
              style: TextStyle(color: appTema.textSecondaryColor, fontSize: 16),
            ),
            const SizedBox(height: 40),
            // Mostra os 4 perfis existentes (somente leitura)
            ..._perfisFilhos.map(
              (perfil) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: appTema.isDarkMode
                        ? Colors.grey[800]?.withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundImage: AssetImage(
                          perfil['avatar'] ?? 'assets/avatar1.png',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        perfil['apelido'] ?? 'Sem nome',
                        style: TextStyle(
                          color: appTema.textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridPerfis(AppTema appTema) {
    final int espacosVazios = 4 - _perfisFilhos.length;

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 0.9,
      ),
      itemCount: _perfisFilhos.length + espacosVazios,
      itemBuilder: (context, index) {
        if (index < _perfisFilhos.length) {
          return _buildPerfilExistente(_perfisFilhos[index], appTema);
        } else {
          return _buildAdicionarPerfil(appTema);
        }
      },
    );
  }

  Widget _buildAdicionarPerfil(AppTema appTema) {
    return GestureDetector(
      onTap: () async {
        await context.push('/avatar-filho');
        _carregarPerfis();
      },
      child: Container(
        decoration: BoxDecoration(
          color: appTema.isDarkMode
              ? Colors.grey[800]?.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: appTema.isDarkMode ? Colors.white24 : Colors.black12,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: appTema.textColor.withValues(alpha: 0.3),
                  width: 3,
                  style: BorderStyle.solid,
                ),
              ),
              child: Icon(
                Icons.add,
                size: 50,
                color: appTema.textColor.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Adicionar\nFamiliar',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: appTema.textColor.withValues(alpha: 0.7),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerfilExistente(Map<String, dynamic> perfil, AppTema appTema) {
    return Container(
      decoration: BoxDecoration(
        color: appTema.isDarkMode
            ? Colors.grey[800]?.withValues(alpha: 0.5)
            : Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage(
              perfil['avatar'] ?? 'assets/avatar1.png',
            ),
          ),
          const SizedBox(height: 12),
          Text(
            perfil['apelido'] ?? 'Sem nome',
            style: TextStyle(
              color: appTema.textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            'Perfil Filho',
            style: TextStyle(
              color: appTema.textColor.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
