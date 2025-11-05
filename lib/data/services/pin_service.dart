import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Serviço para gerenciamento seguro de PINs
///
/// Este serviço usa SHA-256 para hash de PINs, garantindo que
/// os PINs nunca sejam armazenados em texto plano no Firestore.
///
/// ✅ ATUALIZADO: Apenas gerencia PIN do perfil PAI (array não tem PIN próprio)
class PinService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ═══════════════════════════════════════════════════════════════
  // HASH DE PIN
  // ═══════════════════════════════════════════════════════════════

  /// Gera um hash SHA-256 do PIN
  ///
  /// Exemplo: "1234" → "03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4"
  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  // ═══════════════════════════════════════════════════════════════
  // CRIAR PIN (APENAS PERFIL PAI)
  // ═══════════════════════════════════════════════════════════════

  /// Cria um novo PIN para o usuário atual (perfil pai)
  ///
  /// Retorna:
  /// - `true` se o PIN foi criado com sucesso
  /// - `false` em caso de erro
  Future<bool> criarPinPerfilPai(String pin) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('❌ Usuário não autenticado');
        return false;
      }

      // Validação básica
      if (!_validarPin(pin)) {
        print('❌ PIN inválido');
        return false;
      }

      // Hash do PIN
      final pinHash = _hashPin(pin);

      // Salva no Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'pinHash': pinHash,
        'pinCriadoEm': FieldValue.serverTimestamp(),
      });

      print('✅ PIN criado com sucesso para ${user.uid}');
      return true;
    } catch (e) {
      print('❌ Erro ao criar PIN: $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // VERIFICAR PIN (APENAS PERFIL PAI)
  // ═══════════════════════════════════════════════════════════════

  /// Verifica se o PIN fornecido corresponde ao PIN do perfil pai
  ///
  /// Retorna:
  /// - `true` se o PIN está correto
  /// - `false` se o PIN está incorreto ou ocorreu erro
  Future<bool> verificarPinPerfilPai(String pin) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('❌ Usuário não autenticado');
        return false;
      }

      // Busca o hash do Firestore
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        print('❌ Documento do usuário não encontrado');
        return false;
      }

      final pinHashSalvo = userDoc.data()?['pinHash'] as String?;

      if (pinHashSalvo == null) {
        print('⚠️ Usuário não tem PIN configurado');
        return false;
      }

      // Compara o hash do PIN fornecido com o hash salvo
      final pinHashFornecido = _hashPin(pin);
      final pinCorreto = pinHashFornecido == pinHashSalvo;

      if (pinCorreto) {
        print('✅ PIN correto');
      } else {
        print('❌ PIN incorreto');
      }

      return pinCorreto;
    } catch (e) {
      print('❌ Erro ao verificar PIN: $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // ALTERAR PIN
  // ═══════════════════════════════════════════════════════════════

  /// Altera o PIN do perfil pai
  ///
  /// Requer o PIN antigo para autorização
  Future<bool> alterarPinPerfilPai(String pinAntigo, String pinNovo) async {
    try {
      // Primeiro verifica o PIN antigo
      final pinAntigoCorreto = await verificarPinPerfilPai(pinAntigo);

      if (!pinAntigoCorreto) {
        print('❌ PIN antigo incorreto');
        return false;
      }

      // Valida o novo PIN
      if (!_validarPin(pinNovo)) {
        print('❌ Novo PIN inválido');
        return false;
      }

      // Cria o novo hash
      final user = _auth.currentUser;
      if (user == null) return false;

      final pinHashNovo = _hashPin(pinNovo);

      // Atualiza no Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'pinHash': pinHashNovo,
        'pinAlteradoEm': FieldValue.serverTimestamp(),
      });

      print('✅ PIN alterado com sucesso');
      return true;
    } catch (e) {
      print('❌ Erro ao alterar PIN: $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // REMOVER PIN
  // ═══════════════════════════════════════════════════════════════

  /// Remove o PIN do perfil pai (requer PIN para autorização)
  Future<bool> removerPinPerfilPai(String pin) async {
    try {
      // Primeiro verifica o PIN
      final pinCorreto = await verificarPinPerfilPai(pin);

      if (!pinCorreto) {
        print('❌ PIN incorreto');
        return false;
      }

      final user = _auth.currentUser;
      if (user == null) return false;

      // Remove o hash do Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'pinHash': FieldValue.delete(),
        'pinCriadoEm': FieldValue.delete(),
        'pinAlteradoEm': FieldValue.delete(),
      });

      print('✅ PIN removido com sucesso');
      return true;
    } catch (e) {
      print('❌ Erro ao remover PIN: $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // VERIFICAR SE TEM PIN
  // ═══════════════════════════════════════════════════════════════

  /// Verifica se o usuário tem PIN configurado
  Future<bool> temPinConfigurado() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) return false;

      final pinHash = userDoc.data()?['pinHash'];
      return pinHash != null && pinHash is String && pinHash.isNotEmpty;
    } catch (e) {
      print('❌ Erro ao verificar PIN: $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // VALIDAÇÃO
  // ═══════════════════════════════════════════════════════════════

  /// Valida se o PIN é válido
  ///
  /// Regras:
  /// - Deve ter exatamente 4 dígitos
  /// - Deve conter apenas números
  bool _validarPin(String pin) {
    if (pin.length != 4) {
      print('⚠️ PIN deve ter 4 dígitos');
      return false;
    }

    if (!RegExp(r'^\d{4}$').hasMatch(pin)) {
      print('⚠️ PIN deve conter apenas números');
      return false;
    }

    return true;
  }
}
