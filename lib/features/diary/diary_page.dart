import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/router/route_names.dart';

class DiaryPage extends StatelessWidget {
  final String projectId;
  final String projectName;

  const DiaryPage({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Diário - $projectName')),
      body: Center(child: Text('Diary Page - Project: $projectId')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await context.push(
            '${RouteNames.diaryCreate}?projectId=$projectId',
          );
          // TODO: Reload diary entries when cubit is properly integrated
        },
        icon: const Icon(Icons.add),
        label: const Text('Nova Entrada'),
      ),
    );
  }
}
