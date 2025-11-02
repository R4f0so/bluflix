import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'app_tema.dart';
import 'services/pin_service.dart';

class VerificarPinDialog {
  static Future<bool> verificar(BuildContext context) async {
    final pinController = TextEditingController();

    final resultado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) =>
          _PinDialogContent(pinController: pinController),
    );

    return resultado ?? false;
  }
}

class _PinDialogContent extends StatefulWidget {
  final TextEditingController pinController;

  const _PinDialogContent({required this.pinController});

  @override
  State<_PinDialogContent> createState() => _PinDialogContentState();
}

class _PinDialogContentState extends State<_PinDialogContent> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _verificarPin() async {
    final pin = widget.pinController.text.trim();

    if (pin.isEmpty) {
      setState(() {
        _errorMessage = 'Digite o PIN';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // ✅ NOVO: Usa o PinService para verificação segura
      final pinService = PinService();
      final pinCorreto = await pinService.verificarPinPerfilPai(pin);

      if (!mounted) return;

      if (pinCorreto) {
        // PIN correto
        Navigator.of(context).pop(true);
      } else {
        // PIN incorreto
        setState(() {
          _errorMessage = 'PIN incorreto';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Erro ao verificar PIN';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appTema = Provider.of<AppTema>(context);

    return AlertDialog(
      backgroundColor: appTema.isDarkMode ? Colors.grey[900] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: appTema.isDarkMode ? Colors.white24 : Colors.black12,
          width: 1,
        ),
      ),
      title: Row(
        children: [
          Icon(Icons.lock_outline, color: const Color(0xFFA9DBF4), size: 28),
          const SizedBox(width: 12),
          Text(
            'Digite o PIN',
            style: TextStyle(
              color: appTema.textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: widget.pinController,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 4,
            autofocus: true,
            style: TextStyle(
              color: appTema.textColor,
              fontSize: 18,
              letterSpacing: 8,
            ),
            decoration: InputDecoration(
              hintText: '••••',
              hintStyle: TextStyle(
                color: appTema.textSecondaryColor,
                letterSpacing: 8,
              ),
              errorText: _errorMessage,
              errorStyle: const TextStyle(color: Colors.red, fontSize: 14),
              counterText: '',
              filled: true,
              fillColor: appTema.isDarkMode
                  ? Colors.grey[800]
                  : Colors.grey[100],
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
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
            ),
            onSubmitted: (_) => _verificarPin(),
          ),
          if (_isLoading) ...[
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: Color(0xFFA9DBF4)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading
              ? null
              : () {
                  Navigator.of(context).pop(false);
                },
          style: TextButton.styleFrom(
            foregroundColor: appTema.isDarkMode
                ? Colors.white70
                : Colors.black54,
          ),
          child: const Text('Cancelar', style: TextStyle(fontSize: 16)),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _verificarPin,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFA9DBF4),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Verificar',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    widget.pinController.dispose();
    super.dispose();
  }
}
