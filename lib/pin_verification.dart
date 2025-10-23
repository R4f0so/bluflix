import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart'; // ✅ Import aqui no topo
import 'app_tema.dart';

class VerificarPinDialog {
  static Future<bool> verificar(BuildContext context) async {
    final appTema = Provider.of<AppTema>(context, listen: false);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final pinCadastrado = userDoc.data()?['pin'];

    // Se não tem PIN cadastrado, pede para configurar primeiro
    if (pinCadastrado == null) {
      if (!context.mounted) return false;

      await showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            backgroundColor: appTema.isDarkMode
                ? Colors.grey[900]
                : Colors.white,
            title: Row(
              children: [
                const Icon(Icons.lock_outline, color: Colors.orange),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'PIN não configurado',
                    style: TextStyle(color: appTema.textColor),
                  ),
                ),
              ],
            ),
            content: Text(
              'Para excluir perfis, é necessário configurar um PIN de segurança primeiro.\n\nDeseja configurar agora?',
              style: TextStyle(color: appTema.textSecondaryColor),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(
                  'Agora não',
                  style: TextStyle(color: appTema.textSecondaryColor),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  if (context.mounted) {
                    context.push('/seguranca-config'); // ✅ Agora funciona
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA9DBF4),
                  foregroundColor: Colors.black,
                ),
                child: const Text('Configurar'),
              ),
            ],
          );
        },
      );
      return false;
    }

    // Verifica se o context ainda está montado antes de usar
    if (!context.mounted) return false;

    // Se tem PIN, pede verificação
    final pinController = TextEditingController();
    bool? resultado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: appTema.isDarkMode ? Colors.grey[900] : Colors.white,
          title: Row(
            children: [
              const Icon(Icons.lock, color: Color(0xFFA9DBF4)),
              const SizedBox(width: 12),
              Text('Digite o PIN', style: TextStyle(color: appTema.textColor)),
            ],
          ),
          content: TextField(
            controller: pinController,
            keyboardType: TextInputType.number,
            maxLength: 4,
            obscureText: true,
            autofocus: true,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: appTema.textColor,
              fontSize: 24,
              letterSpacing: 12,
              fontWeight: FontWeight.bold,
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: '••••',
              hintStyle: TextStyle(color: appTema.textSecondaryColor),
              filled: true,
              fillColor: appTema.isDarkMode
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              counterText: '',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                'Cancelar',
                style: TextStyle(color: appTema.textSecondaryColor),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (pinController.text == pinCadastrado) {
                  Navigator.pop(dialogContext, true);
                } else {
                  if (dialogContext.mounted) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(
                        content: Text('PIN incorreto!'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                  pinController.clear();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA9DBF4),
                foregroundColor: Colors.black,
              ),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );

    pinController.dispose();
    return resultado ?? false;
  }
}
