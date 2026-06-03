import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../../../../core/error/failures.dart';
import '../entities/diary_entry_entity.dart';

@injectable
class GeneratePdfUseCase {
  Future<Either<Failure, File>> call({
    required String projectName,
    required List<DiaryEntryEntity> entries,
    String? phaseFilter,
  }) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Diário de Obra - $projectName',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            if (phaseFilter != null)
              pw.Text(
                'Fase: $phaseFilter',
                style: const pw.TextStyle(fontSize: 14),
              ),
            pw.SizedBox(height: 20),
            ...entries.map((entry) => _buildEntryWidget(entry)),
          ],
        ),
      );

      final output = await getTemporaryDirectory();
      final file = File(
        '${output.path}/diario_obra_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      await file.writeAsBytes(await pdf.save());

      return Right(file);
    } catch (e) {
      return Left(ServerFailure('Erro ao gerar PDF: $e'));
    }
  }

  pw.Widget _buildEntryWidget(DiaryEntryEntity entry) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 20),
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                entry.type.displayName,
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                '${entry.date.day}/${entry.date.month}/${entry.date.year}',
                style: const pw.TextStyle(fontSize: 12),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            entry.title,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(entry.description, style: const pw.TextStyle(fontSize: 12)),
          if (entry.photoUrls.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            pw.Text(
              'Fotos: ${entry.photoUrls.length}',
              style: const pw.TextStyle(fontSize: 10),
            ),
          ],
          if (entry.problemSeverity != null) ...[
            pw.SizedBox(height: 4),
            pw.Text(
              'Gravidade: ${entry.problemSeverity!.displayName}',
              style: const pw.TextStyle(fontSize: 10),
            ),
          ],
        ],
      ),
    );
  }
}

// Made with Bob
