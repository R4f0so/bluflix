import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

/// Script para configurar usuário como Admin
/// RODE APENAS UMA VEZ e depois delete este arquivo
void main() async {
  print('🚀 Iniciando configuração de Admin...\n');

  // Inicializar Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final firestore = FirebaseFirestore.instance;

  // UID do usuário que será Admin (ratf705@gmail.com)
  const String adminUid = '78pXjYjaVFVl0bK6mlbjEnf20yy1';

  try {
    // 1. Atualizar o usuário existente para Admin
    print('📝 Atualizando usuário para Admin...');
    await firestore.collection('users').doc(adminUid).update({
      'isAdmin': true,
      'atualizadoEm': FieldValue.serverTimestamp(),
    });
    print('✅ Usuário atualizado com sucesso!\n');

    // 2. Verificar se funcionou
    print('🔍 Verificando atualização...');
    final userDoc = await firestore.collection('users').doc(adminUid).get();
    final userData = userDoc.data();

    print('📋 Dados do usuário:');
    print('   - Email: ${userData?['email']}');
    print('   - Apelido: ${userData?['apelido']}');
    print('   - Tipo: ${userData?['tipoUsuario']}');
    print('');

    if (userData?['tipoUsuario'] == 'admin') {
      print('🎉 SUCESSO! Usuário é agora ADMIN!');
      print('');
      print('⚠️  IMPORTANTE:');
      print('   1. Delete este arquivo (setup_admin.dart) agora');
      print('   2. Atualize as regras do Firestore (próximo passo)');
      print('   3. Faça logout e login novamente no app');
    } else {
      print('❌ Algo deu errado. Verifique o Firestore manualmente.');
    }
  } catch (e) {
    print('❌ ERRO: $e');
    print('');
    print('💡 Possíveis soluções:');
    print('   - Verifique se o UID está correto');
    print('   - Verifique sua conexão com o Firebase');
    print('   - Verifique as regras de segurança do Firestore');
  }

  print('\n🏁 Script finalizado!');
}
