import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:bluflix/core/theme/app_theme.dart';
import 'package:bluflix/presentation/widgets/theme_toggle_button.dart';

/// Tela para recuperação de senha via e-mail
class EsqueciSenhaScreen extends StatefulWidget {
  const EsqueciSenhaScreen({super.key});

  @override
  State<EsqueciSenhaScreen> createState() => _EsqueciSenhaScreenState();
}

class _EsqueciSenhaScreenState extends State<EsqueciSenhaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  String? _mensagemSucesso;
  String? _mensagemErro;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  /// Valida formato do e-mail
  String? _validarEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira seu e-mail';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Por favor, insira um e-mail válido';
    }

    return null;
  }

  /// Envia e-mail de recuperação de senha
  Future<void> _enviarEmailRecuperacao() async {
    // Limpa mensagens anteriores
    setState(() {
      _mensagemSucesso = null;
      _mensagemErro = null;
    });

    // Valida o formulário
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text.trim());

      if (!mounted) return;

      setState(() {
        _mensagemSucesso =
            'E-mail de recuperação enviado! Verifique sua caixa de entrada.';
        _mensagemErro = null;
      });

      // Limpa o campo de e-mail
      _emailController.clear();

      // Aguarda 3 segundos e volta para a tela de login
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          context.go('/login');
        }
      });
    } on FirebaseAuthException catch (e) {
      String mensagem;

      switch (e.code) {
        case 'user-not-found':
          mensagem = 'Não existe uma conta com este e-mail.';
          break;
        case 'invalid-email':
          mensagem = 'E-mail inválido.';
          break;
        case 'too-many-requests':
          mensagem = 'Muitas tentativas. Tente novamente mais tarde.';
          break;
        default:
          mensagem = 'Erro ao enviar e-mail: ${e.message}';
      }

      if (!mounted) return;

      setState(() {
        _mensagemErro = mensagem;
        _mensagemSucesso = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _mensagemErro = 'Erro inesperado. Tente novamente.';
        _mensagemSucesso = null;
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
                  ],
                ),
              ),

              // Conteúdo
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 40),

                        // Ícone de cadeado
                        Icon(
                          Icons.lock_reset_rounded,
                          size: 80,
                          color: const Color(0xFFA9DBF4),
                        ),
                        const SizedBox(height: 24),

                        // Título
                        Text(
                          'Esqueceu sua senha?',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: appTema.textColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),

                        // Subtítulo
                        Text(
                          'Não se preocupe! Digite seu e-mail e enviaremos as instruções para redefinir sua senha.',
                          style: TextStyle(
                            fontSize: 16,
                            color: appTema.textSecondaryColor,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),

                        // Campo de e-mail
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: _validarEmail,
                          style: TextStyle(
                            color: appTema.textColor,
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            labelText: 'E-mail',
                            labelStyle: TextStyle(
                              color: appTema.textSecondaryColor,
                            ),
                            hintText: 'Digite seu e-mail',
                            hintStyle: TextStyle(
                              color: appTema.textSecondaryColor,
                            ),
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: const Color(0xFFA9DBF4),
                            ),
                            filled: true,
                            fillColor: appTema.isDarkMode
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.white.withValues(alpha: 0.8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: appTema.isDarkMode
                                    ? Colors.white.withValues(alpha: 0.2)
                                    : Colors.black.withValues(alpha: 0.1),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFA9DBF4),
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Mensagem de sucesso
                        if (_mensagemSucesso != null)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.green.withValues(alpha: 0.5),
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _mensagemSucesso!,
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Mensagem de erro
                        if (_mensagemErro != null)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.red.withValues(alpha: 0.5),
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _mensagemErro!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        if (_mensagemSucesso != null || _mensagemErro != null)
                          const SizedBox(height: 24),

                        // Botão Enviar
                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : _enviarEmailRecuperacao,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFA9DBF4),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.black,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Enviar e-mail de recuperação',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () => context.go('/login'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFA9DBF4),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                            child: const Text(
                              'Voltar para o login',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 50),

                        // Informação adicional
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: appTema.isDarkMode
                                ? Colors.blue.withValues(alpha: 0.15)
                                : Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.blue.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.blue[700],
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Dica',
                                    style: TextStyle(
                                      color: Colors.blue[700],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Não recebeu o e-mail? Verifique sua caixa de spam ou lixo eletrônico.',
                                style: TextStyle(
                                  color: appTema.textSecondaryColor,
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                            ],
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
      ),
    );
  }
}
