import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/responsive_content.dart';
import 'create_password_screen.dart';

/// Primeiro passo do fluxo de "Primeiro Acesso": identifica o representante
/// pela matrícula antes de deixá-lo criar uma senha (ver
/// [CreatePasswordScreen]). Protótipo: não valida contra nenhum cadastro
/// real, apenas exige um valor não vazio, no mesmo espírito do login mock.
class FirstAccessScreen extends StatefulWidget {
  const FirstAccessScreen({super.key});

  @override
  State<FirstAccessScreen> createState() => _FirstAccessScreenState();
}

class _FirstAccessScreenState extends State<FirstAccessScreen> {
  final _idController = TextEditingController();

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Primeiro Acesso')),
      body: ResponsiveContent(
        maxWidth: 480,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          children: [
            Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.textPrimary,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.verified_user_outlined,
                  color: Colors.white,
                  size: 34,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Bem-vindo à Josapar',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Para começar seu primeiro acesso, precisamos identificar sua '
              'conta no sistema.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Matrícula ou Identificador Único',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _idController,
                    textInputAction: TextInputAction.done,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'Ex: 00123456',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Utilize o número impresso no seu crachá ou fornecido '
                    'pelo seu gestor.',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _idController.text.trim().isEmpty
                  ? null
                  : () => context.push(AppRoutes.createPassword),
              icon: const Icon(Icons.arrow_forward, size: 18),
              label: const Text('Continuar'),
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () => context.pop(),
                child: const Text('Voltar ao Login'),
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: TextButton.icon(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Suporte TI: (51) 3000-0000.')),
                ),
                icon: const Icon(
                  Icons.help_outline,
                  size: 14,
                  color: AppColors.textMuted,
                ),
                label: const Text(
                  'PRECISA DE AJUDA? CONTATE O SUPORTE TI',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                    color: AppColors.textMuted,
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
