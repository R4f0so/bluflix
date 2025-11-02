import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'app_tema.dart';
import 'widgets/theme_toggle_button.dart';
import 'services/pin_service.dart';

class SegurancaConfigScreen extends StatefulWidget {
  const SegurancaConfigScreen({super.key});

  @override
  State<SegurancaConfigScreen> createState() => _SegurancaConfigScreenState();
}

class _SegurancaConfigScreenState extends State<SegurancaConfigScreen> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  bool _isLoading = false;
  String? _pinAtual;

  @override
  void initState() {
    super.initState();
    _carregarPinAtual();
  }

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _carregarPinAtual() async {
    try {
      final pinService = PinService();
      final temPin = await pinService.temPinConfigurado();

      if (mounted) {
        setState(() {
          _pinAtual = temPin ? 'CONFIGURADO' : null;
        });
      }
    } catch (e) {
      print('Erro ao carregar PIN: $e');
    }
  }

  Future<void> _salvarPin() async {
    final pin = _pinController.text.trim();
    final confirmPin = _confirmPinController.text.trim();

    if (pin.isEmpty || confirmPin.isEmpty) {
      _mostrarErro('Por favor, preencha todos os campos');
      return;
    }

    if (pin.length != 4) {
      _mostrarErro('O PIN deve ter exatamente 4 dígitos');
      return;
    }

    if (pin != confirmPin) {
      _mostrarErro('Os PINs não coincidem');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final pinService = PinService();

      // Se já tem PIN, precisa alterar (não implementado aqui)
      // Se não tem PIN, cria novo
      final sucesso = await pinService.criarPinPerfilPai(pin);

      if (!mounted) return;

      if (sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PIN configurado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        context.pop();
      } else {
        _mostrarErro('Erro ao salvar PIN');
      }
    } catch (e) {
      _mostrarErro('Erro ao salvar PIN: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _removerPin() async {
    // Mostra diálogo de confirmação
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover PIN?'),
        content: const Text(
          'Tem certeza que deseja remover o PIN de segurança? '
          'Você precisará digitar o PIN atual para confirmar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remover', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    // ✅ Verifica se o widget ainda está montado
    if (!mounted) return;

    if (confirmar == true) {
      setState(() => _isLoading = true);

      try {
        // Solicita PIN para confirmar
        final pinController = TextEditingController();

        final pin = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Digite seu PIN'),
            content: TextField(
              controller: pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                letterSpacing: 8,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, pinController.text),
                child: const Text('OK'),
              ),
            ],
          ),
        );

        // ✅ Verifica mounted novamente
        if (!mounted) return;

        if (pin == null || pin.isEmpty) {
          setState(() => _isLoading = false);
          return;
        }

        final pinService = PinService();
        final sucesso = await pinService.removerPinPerfilPai(pin);

        if (!mounted) return;

        if (sucesso) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PIN removido com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        } else {
          _mostrarErro('PIN incorreto ou erro ao remover');
        }
      } catch (e) {
        if (!mounted) return; // ✅ Verifica antes de mostrar erro
        _mostrarErro('Erro ao remover PIN: ${e.toString()}');
      } finally {
        if (mounted) {
          // ✅ Verifica antes de setState
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), backgroundColor: Colors.red),
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
                    const ThemeToggleButton(showLogo: false), // ✅ SEM logo
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

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.lock_outline,
                        size: 80,
                        color: const Color(0xFFA9DBF4),
                      ),
                      const SizedBox(height: 24),

                      Text(
                        _pinAtual == null
                            ? 'Configurar PIN de Segurança'
                            : 'Alterar PIN de Segurança',
                        style: TextStyle(
                          color: appTema.textColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 12),

                      Text(
                        'Use um PIN de 4 dígitos para proteger ações sensíveis',
                        style: TextStyle(
                          color: appTema.textSecondaryColor,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 40),

                      // Campo PIN
                      _buildPinField(
                        controller: _pinController,
                        label: 'Digite o PIN',
                        appTema: appTema,
                      ),

                      const SizedBox(height: 20),

                      // Campo Confirmar PIN
                      _buildPinField(
                        controller: _confirmPinController,
                        label: 'Confirme o PIN',
                        appTema: appTema,
                      ),

                      const SizedBox(height: 40),

                      // Botão Salvar
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _salvarPin,
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
                              : Text(
                                  _pinAtual == null
                                      ? 'Configurar PIN'
                                      : 'Alterar PIN',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      // Botão Remover (só aparece se já tiver PIN)
                      if (_pinAtual != null) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton(
                            onPressed: _isLoading ? null : _removerPin,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Remover PIN',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinField({
    required TextEditingController controller,
    required String label,
    required AppTema appTema,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      maxLength: 4,
      obscureText: true,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: appTema.textColor,
        fontSize: 24,
        letterSpacing: 12,
        fontWeight: FontWeight.bold,
      ),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: appTema.textSecondaryColor),
        filled: true,
        fillColor: appTema.isDarkMode
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.white.withValues(alpha: 0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        counterText: '',
      ),
    );
  }
}
