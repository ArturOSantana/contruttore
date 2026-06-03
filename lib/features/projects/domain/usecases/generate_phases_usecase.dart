import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';

@injectable
class GeneratePhasesUseCase {
  final FirebaseFirestore _firestore;

  GeneratePhasesUseCase(this._firestore);

  Future<Either<Failure, void>> call({
    required String projectId,
    required String currentSituation,
  }) async {
    try {
      // Definir as 12 fases
      final phases = _getPhases();

      // Definir status inicial baseado na situação
      for (int i = 0; i < phases.length; i++) {
        final phase = phases[i];
        String status;

        if (currentSituation == 'just_signed') {
          // Fases 1-4 ativas, restantes locked
          status = i < 4 ? 'active' : 'locked';
        } else if (currentSituation == 'construction') {
          // Todas as fases de comprador ativas
          status = i < 5 ? 'active' : 'locked';
        } else if (currentSituation == 'keys_received') {
          // Fases 1-4 done_no_record, 5-12 active
          status = i < 4 ? 'done_no_record' : (i == 4 ? 'active' : 'locked');
        } else {
          // renovation - perguntar em qual fase está (implementar depois)
          status = i < 5 ? 'done_no_record' : 'active';
        }

        await _firestore
            .collection('projects')
            .doc(projectId)
            .collection('phases')
            .doc('phase_${i + 1}')
            .set({
              'number': i + 1,
              'name': phase['name'],
              'description': phase['description'],
              'status': status,
              'startDate': null,
              'endDate': null,
              'estimatedDurationDays': phase['estimatedDurationDays'],
              'subtasks': phase['subtasks'],
              'notes': null,
            });
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao gerar fases: $e'));
    }
  }

  List<Map<String, dynamic>> _getPhases() {
    return [
      {
        'name': 'Assinatura e documentação',
        'description':
            'Guardar contrato, entender cláusulas, cadastrar parcelas',
        'estimatedDurationDays': 7,
        'subtasks': [
          {
            'id': '1',
            'name': 'Salvar contrato assinado',
            'isRequired': true,
            'isDone': false,
          },
          {
            'id': '2',
            'name': 'Registrar data de entrega prevista',
            'isRequired': true,
            'isDone': false,
          },
          {
            'id': '3',
            'name': 'Verificar Registro de Incorporação',
            'isRequired': true,
            'isDone': false,
          },
          {
            'id': '4',
            'name': 'Cadastrar cronograma de parcelas',
            'isRequired': true,
            'isDone': false,
          },
        ],
      },
      {
        'name': 'Financiamento e ITBI',
        'description':
            'Organizar documentos, solicitar financiamento, pagar ITBI',
        'estimatedDurationDays': 30,
        'subtasks': [
          {
            'id': '1',
            'name': 'Reunir documentos para financiamento',
            'isRequired': true,
            'isDone': false,
          },
          {
            'id': '2',
            'name': 'Solicitar financiamento no banco',
            'isRequired': true,
            'isDone': false,
          },
          {
            'id': '3',
            'name': 'Calcular e pagar ITBI',
            'isRequired': true,
            'isDone': false,
          },
          {
            'id': '4',
            'name': 'Agendar escritura',
            'isRequired': false,
            'isDone': false,
          },
        ],
      },
      {
        'name': 'Acompanhamento da obra',
        'description': 'Visitas periódicas, fotos, verificação de qualidade',
        'estimatedDurationDays': 365,
        'subtasks': [
          {
            'id': '1',
            'name': 'Agendar primeira visita à obra',
            'isRequired': true,
            'isDone': false,
          },
          {
            'id': '2',
            'name': 'Tirar fotos do andamento',
            'isRequired': false,
            'isDone': false,
          },
          {
            'id': '3',
            'name': 'Verificar acabamentos',
            'isRequired': true,
            'isDone': false,
          },
          {
            'id': '4',
            'name': 'Anotar pendências',
            'isRequired': false,
            'isDone': false,
          },
        ],
      },
      {
        'name': 'Vistoria pré-entrega',
        'description': 'Checklist completo antes de receber as chaves',
        'estimatedDurationDays': 7,
        'subtasks': [
          {
            'id': '1',
            'name': 'Agendar vistoria com construtora',
            'isRequired': true,
            'isDone': false,
          },
          {
            'id': '2',
            'name': 'Verificar todos os pontos elétricos',
            'isRequired': true,
            'isDone': false,
          },
          {
            'id': '3',
            'name': 'Testar torneiras e registros',
            'isRequired': true,
            'isDone': false,
          },
          {
            'id': '4',
            'name': 'Listar defeitos encontrados',
            'isRequired': true,
            'isDone': false,
          },
        ],
      },
      {
        'name': 'Recebimento das chaves',
        'description': 'Assinar termo de entrega, receber chaves e documentos',
        'estimatedDurationDays': 1,
        'subtasks': [
          {
            'id': '1',
            'name': 'Assinar termo de entrega',
            'isRequired': true,
            'isDone': false,
          },
          {
            'id': '2',
            'name': 'Receber todas as chaves',
            'isRequired': true,
            'isDone': false,
          },
          {
            'id': '3',
            'name': 'Receber manual do proprietário',
            'isRequired': true,
            'isDone': false,
          },
          {
            'id': '4',
            'name': 'Tirar fotos do imóvel vazio',
            'isRequired': false,
            'isDone': false,
          },
        ],
      },
      {
        'name': 'Planejamento da reforma',
        'description': 'Definir escopo, orçamentos, cronograma',
        'estimatedDurationDays': 30,
        'subtasks': [
          {
            'id': '1',
            'name': 'Definir ambientes a reformar',
            'isRequired': true,
            'isDone': false,
          },
          {
            'id': '2',
            'name': 'Contratar arquiteto/designer',
            'isRequired': false,
            'isDone': false,
          },
          {
            'id': '3',
            'name': 'Solicitar 3 orçamentos',
            'isRequired': true,
            'isDone': false,
          },
          {
            'id': '4',
            'name': 'Definir cronograma de obra',
            'isRequired': true,
            'isDone': false,
          },
        ],
      },
      {
        'name': 'Demolição e preparação',
        'description': 'Quebra de paredes, remoção de entulho, preparação',
        'estimatedDurationDays': 14,
        'subtasks': [
          {
            'id': '1',
            'name': 'Proteger áreas que não serão reformadas',
            'isRequired': true,
            'isDone': false,
          },
          {
            'id': '2',
            'name': 'Realizar demolições necessárias',
            'isRequired': true,
            'isDone': false,
          },
          {
            'id': '3',
            'name': 'Remover entulho',
            'isRequired': true,
            'isDone': false,
          },
          {
            'id': '4',
            'name': 'Preparar superfícies',
            'isRequired': true,
            'isDone': false,
          },
        ],
      },
      {
        'name': 'Instalações hidráulicas e elétricas',
        'description': 'Novos pontos, tubulações, fiação',
        'estimatedDurationDays': 21,
        'subtasks': [
          {
            'id': '1',
            'name': 'Instalar novos pontos elétricos',
            'isRequired': true,
            'isDone': false,
          },
          {
            'id': '2',
            'name': 'Instalar novos pontos hidráulicos',
            'isRequired': true,
            'isDone': false,
          },
          {
            'id': '3',
            'name': 'Testar instalações',
            'isRequired': true,
            'isDone': false,
          },
          {
            'id': '4',
            'name': 'Fechar rasgos',
            'isRequired': true,
            'isDone': false,
          },
        ],
      },
      {
        'name': 'Revestimentos e acabamentos',
        'description': 'Pisos, azulejos, pintura, gesso',
        'estimatedDurationDays': 30,
        'subtasks': [
          {
            'id': '1',
            'name': 'Instalar pisos',
            'isRequired': true,
            'isDone': false,
          },
          {
            'id': '2',
            'name': 'Instalar azulejos',
            'isRequired': true,
            'isDone': false,
          },
          {
            'id': '3',
            'name': 'Aplicar gesso/sanca',
            'isRequired': false,
            'isDone': false,
          },
          {
            'id': '4',
            'name': 'Pintar paredes e teto',
            'isRequired': true,
            'isDone': false,
          },
        ],
      },
      {
        'name': 'Marcenaria e esquadrias',
        'description': 'Armários, portas, janelas, bancadas',
        'estimatedDurationDays': 21,
        'subtasks': [
          {
            'id': '1',
            'name': 'Instalar armários planejados',
            'isRequired': false,
            'isDone': false,
          },
          {
            'id': '2',
            'name': 'Instalar portas',
            'isRequired': true,
            'isDone': false,
          },
          {
            'id': '3',
            'name': 'Instalar bancadas',
            'isRequired': true,
            'isDone': false,
          },
          {
            'id': '4',
            'name': 'Instalar rodapés',
            'isRequired': true,
            'isDone': false,
          },
        ],
      },
      {
        'name': 'Louças, metais e iluminação',
        'description': 'Instalação final de acabamentos',
        'estimatedDurationDays': 7,
        'subtasks': [
          {
            'id': '1',
            'name': 'Instalar louças sanitárias',
            'isRequired': true,
            'isDone': false,
          },
          {
            'id': '2',
            'name': 'Instalar metais (torneiras, chuveiros)',
            'isRequired': true,
            'isDone': false,
          },
          {
            'id': '3',
            'name': 'Instalar luminárias',
            'isRequired': true,
            'isDone': false,
          },
          {
            'id': '4',
            'name': 'Instalar espelhos',
            'isRequired': false,
            'isDone': false,
          },
        ],
      },
      {
        'name': 'Limpeza e entrega',
        'description': 'Limpeza final, vistoria, correções',
        'estimatedDurationDays': 3,
        'subtasks': [
          {
            'id': '1',
            'name': 'Realizar limpeza pesada',
            'isRequired': true,
            'isDone': false,
          },
          {
            'id': '2',
            'name': 'Fazer vistoria final',
            'isRequired': true,
            'isDone': false,
          },
          {
            'id': '3',
            'name': 'Corrigir pendências',
            'isRequired': true,
            'isDone': false,
          },
          {
            'id': '4',
            'name': 'Tirar fotos finais',
            'isRequired': false,
            'isDone': false,
          },
        ],
      },
    ];
  }
}

// Made with Bob
