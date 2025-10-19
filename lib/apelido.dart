import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

class ApelidoScreen extends StatefulWidget {
  final String selectedAvatar;
  const ApelidoScreen({super.key, required this.selectedAvatar});

  @override
  State<ApelidoScreen> createState() => _ApelidoScreenState();
}

class _ApelidoScreenState extends State<ApelidoScreen> {
  final TextEditingController _apelidoController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _apelidoController.dispose();
    super.dispose();
  }

  Future<void> _salvarApelido() async {
    final user = FirebaseAuth.instance.currentUser;
    final apelido = _apelidoController.text.trim();

    if (apelido.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, insira um apelido')),
      );
      return;
    }
    
    if (user == null) {
      if (mounted) context.go('/login');
      return;
    }

    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'apelido': apelido,
        'avatar': widget.selectedAvatar,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      context.go('/splash'); 
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar apelido: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/morning_background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  const SizedBox(height: 40),
                  Image.asset("assets/logo.png", width: 200),
                  const SizedBox(height: 40),
                ],
              ),

              CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage(widget.selectedAvatar),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: 300,
                child: TextField(
                  controller: _apelidoController,
                  style: const TextStyle(color: Colors.black), 
                  decoration: InputDecoration(
                    hintText: "Digite seu apelido",
                    hintStyle: TextStyle(
                      color: Colors.black.withValues(alpha: 0.6),
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 140,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => context.go('/avatar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Voltar", style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 20),
                  
                  SizedBox(
                    width: 140,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _salvarApelido, 
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA9DBF4),
                        foregroundColor: Colors.black,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSaving
                          ? const CircularProgressIndicator(color: Colors.black)
                          : const Text("Prosseguir", style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
