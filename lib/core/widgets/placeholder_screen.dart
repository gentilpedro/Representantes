import 'package:flutter/material.dart';

import '../theme/app_palette.dart';

/// Placeholder temporário para telas ainda não implementadas nesta etapa.
/// Cada uma será substituída pelo conteúdo real na etapa correspondente do
/// plano (ver lista de tarefas), mantendo a navegação e a estrutura já
/// funcionando de ponta a ponta.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: context.colors.textMuted),
            const SizedBox(height: 12),
            Text(
              '$title — em construção',
              style: TextStyle(color: context.colors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
