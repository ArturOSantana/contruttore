import 'package:flutter/material.dart';
import 'shimmer_loading.dart';
import '../../app/theme/app_spacing.dart';

/// Widget de loading com diferentes tipos de apresentação
class LoadingWidget extends StatelessWidget {
  final LoadingType type;

  const LoadingWidget({super.key, this.type = LoadingType.list});

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case LoadingType.list:
        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: 5,
          itemBuilder: (context, index) => const ShimmerListCard(),
        );

      case LoadingType.grid:
        return GridView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: 0.8,
          ),
          itemCount: 6,
          itemBuilder: (context, index) => const ShimmerGridCard(),
        );

      case LoadingType.center:
        return const Center(child: CircularProgressIndicator());
    }
  }
}

/// Tipos de loading disponíveis
enum LoadingType {
  /// Lista vertical com shimmer cards
  list,

  /// Grid com shimmer cards
  grid,

  /// Circular progress indicator centralizado
  center,
}

// Made with Bob
