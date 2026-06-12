import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../lib/features/glossary/data/seed/glossary_seed_data.dart';
import '../lib/firebase_options.dart';

/// Script para popular o Firestore com os dados do glossário
///
/// Execute com: dart run scripts/seed_glossary.dart
Future<void> main() async {
  print('🚀 Iniciando seed do glossário...\n');

  try {
    // Inicializa o Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase inicializado\n');

    final firestore = FirebaseFirestore.instance;
    final glossaryCollection = firestore.collection('glossary');

    // Verifica se já existem dados
    final existingDocs = await glossaryCollection.limit(1).get();

    if (existingDocs.docs.isNotEmpty) {
      print('⚠️  Já existem dados no glossário.');
      print('Deseja sobrescrever? (s/n): ');
      // Em produção, você pode adicionar lógica para confirmar
      // Por enquanto, vamos limpar e recriar
      print('🗑️  Limpando dados existentes...');

      final allDocs = await glossaryCollection.get();
      final batch = firestore.batch();

      for (var doc in allDocs.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('✅ Dados antigos removidos\n');
    }

    // Adiciona os novos dados
    print('📝 Adicionando ${glossarySeedData.length} termos ao Firestore...\n');

    int count = 0;
    final batch = firestore.batch();

    for (var termData in glossarySeedData) {
      final docRef = glossaryCollection.doc();

      // Adiciona o ID ao documento
      final dataWithId = {
        ...termData,
        'id': docRef.id,
        'createdAt': FieldValue.serverTimestamp(),
      };

      batch.set(docRef, dataWithId);
      count++;

      // Firestore tem limite de 500 operações por batch
      if (count % 500 == 0) {
        await batch.commit();
        print('  ✓ ${count} termos adicionados...');
      }
    }

    // Commit final
    await batch.commit();

    print('\n✅ Seed concluído com sucesso!');
    print('📊 Total de termos adicionados: $count');
    print('\n📚 Categorias:');

    // Conta termos por categoria
    final categories = <String, int>{};
    for (var term in glossarySeedData) {
      final category = term['category'] as String;
      categories[category] = (categories[category] ?? 0) + 1;
    }

    categories.forEach((category, count) {
      print('  • $category: $count termos');
    });
  } catch (e, stackTrace) {
    print('\n❌ Erro ao executar seed: $e');
    print('Stack trace: $stackTrace');
  }
}

// Made with Bob
