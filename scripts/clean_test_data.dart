import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

/// Script para limpar dados de teste/fantasmas do Firestore
///
/// Execute com: dart run scripts/clean_test_data.dart
///
/// ATENÇÃO: Este script irá deletar dados! Use com cuidado!

Future<void> main() async {
  print('🧹 Iniciando limpeza de dados de teste...\n');

  // Inicializar Firebase
  await Firebase.initializeApp();
  final firestore = FirebaseFirestore.instance;

  // Contador de itens deletados
  int deletedCount = 0;

  try {
    // 1. Limpar despesas com descrições suspeitas
    print('📊 Verificando despesas...');
    final expensesSnapshot = await firestore.collectionGroup('expenses').get();

    for (var doc in expensesSnapshot.docs) {
      final data = doc.data();
      final description = (data['description'] ?? '').toString().toLowerCase();

      // Padrões suspeitos
      final suspiciousPatterns = [
        'test',
        'teste',
        'dasda',
        'asdasd',
        'aaa',
        'bbb',
        'xxx',
        'zzz',
        'qwerty',
        'asdf',
      ];

      if (suspiciousPatterns.any((pattern) => description.contains(pattern))) {
        print('  ❌ Deletando despesa: ${data['description']} (${doc.id})');
        await doc.reference.delete();
        deletedCount++;
      }

      // Verificar datas futuras (mais de 1 ano no futuro)
      if (data['date'] != null) {
        final date = (data['date'] as Timestamp).toDate();
        final oneYearFromNow = DateTime.now().add(Duration(days: 365));

        if (date.isAfter(oneYearFromNow)) {
          print(
              '  ❌ Deletando despesa com data futura: ${data['description']} (${date.toString()})');
          await doc.reference.delete();
          deletedCount++;
        }
      }
    }

    // 2. Limpar itens de compras com nomes suspeitos
    print('\n🛒 Verificando itens de compras...');
    final shoppingSnapshot = await firestore.collectionGroup('shopping').get();

    for (var doc in shoppingSnapshot.docs) {
      final data = doc.data();
      final name = (data['name'] ?? '').toString().toLowerCase();

      final suspiciousPatterns = [
        'test',
        'teste',
        'dasda',
        'asdasd',
        'aaa',
        'bbb',
      ];

      if (suspiciousPatterns.any((pattern) => name.contains(pattern))) {
        print('  ❌ Deletando item de compra: ${data['name']} (${doc.id})');
        await doc.reference.delete();
        deletedCount++;
      }
    }

    // 3. Limpar fornecedores com nomes suspeitos
    print('\n👷 Verificando fornecedores...');
    final suppliersSnapshot =
        await firestore.collectionGroup('suppliers').get();

    for (var doc in suppliersSnapshot.docs) {
      final data = doc.data();
      final name = (data['name'] ?? '').toString().toLowerCase();

      final suspiciousPatterns = [
        'test',
        'teste',
        'dasda',
        'asdasd',
      ];

      if (suspiciousPatterns.any((pattern) => name.contains(pattern))) {
        print('  ❌ Deletando fornecedor: ${data['name']} (${doc.id})');
        await doc.reference.delete();
        deletedCount++;
      }
    }

    // 4. Limpar documentos com títulos suspeitos
    print('\n📄 Verificando documentos...');
    final documentsSnapshot =
        await firestore.collectionGroup('documents').get();

    for (var doc in documentsSnapshot.docs) {
      final data = doc.data();
      final title = (data['title'] ?? '').toString().toLowerCase();

      final suspiciousPatterns = [
        'test',
        'teste',
        'dasda',
      ];

      if (suspiciousPatterns.any((pattern) => title.contains(pattern))) {
        print('  ❌ Deletando documento: ${data['title']} (${doc.id})');
        await doc.reference.delete();
        deletedCount++;
      }
    }

    // 5. Limpar entradas do diário com descrições suspeitas
    print('\n📔 Verificando entradas do diário...');
    final diarySnapshot = await firestore.collectionGroup('diary').get();

    for (var doc in diarySnapshot.docs) {
      final data = doc.data();
      final description = (data['description'] ?? '').toString().toLowerCase();

      final suspiciousPatterns = [
        'test',
        'teste',
        'dasda',
      ];

      if (suspiciousPatterns.any((pattern) => description.contains(pattern))) {
        print(
            '  ❌ Deletando entrada do diário: ${data['description']} (${doc.id})');
        await doc.reference.delete();
        deletedCount++;
      }
    }

    print('\n✅ Limpeza concluída!');
    print('📊 Total de itens deletados: $deletedCount');
  } catch (e) {
    print('\n❌ Erro durante a limpeza: $e');
  }
}

// Made with Bob
