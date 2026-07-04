import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/responsive_content.dart';
import '../providers/auth_providers.dart';

class _PasswordRequirement {
  const _PasswordRequirement(this.label, this.isMet);

  final String label;
  final bool Function(String password) isMet;
}

final _passwordRequirements = <_PasswordRequirement>[
  _PasswordRequirement('Mínimo 8 caracteres', (p) => p.length >= 8),
  _PasswordRequirement(
    'Pelo menos uma letra maiúscula',
    (p) => RegExp(r'[A-Z]').hasMatch(p),
  ),
  _PasswordRequirement(
    'Pelo menos uma letra minúscula',
    (p) => RegExp(r'[a-z]').hasMatch(p),
  ),
  _PasswordRequirement(
    'Pelo menos um número',
    (p) => RegExp(r'[0-9]').hasMatch(p),
  ),
  _PasswordRequirement(
    'Um caractere especial (@, #, \$, etc.)',
    (p) => RegExp(r'''[!@#$%^&*(),.?":{}|<>_\-+=\[\]/~`]''').hasMatch(p),
  ),
];

/// Último passo do fluxo de "Primeiro Acesso": define a senha da conta via
/// `POST /api/auth/first-access/activate`, que já devolve uma sessão
/// autenticada — o redirect do [GoRouter] leva direto ao dashboard.
class CreatePasswordScreen extends ConsumerStatefulWidget {
  const CreatePasswordScreen({super.key, required this.identifier});

  final String identifier;

  @override
  ConsumerState<CreatePasswordScreen> createState() =>
      _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends ConsumerState<CreatePasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool get _allRequirementsMet =>
      _passwordRequirements.every((r) => r.isMet(_passwordController.text));

  bool get _passwordsMatch =>
      _confirmController.text.isNotEmpty &&
      _confirmController.text == _passwordController.text;

  bool _canSave(bool isLoading) =>
      _allRequirementsMet && _passwordsMatch && !isLoading;

  Future<void> _save() async {
    await ref
        .read(authControllerProvider.notifier)
        .activateAccount(
          identifier: widget.identifier,
          password: _passwordController.text,
        );

    final state = ref.read(authControllerProvider);
    if (state.hasError && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Criar Senha')),
      body: ResponsiveContent(
        maxWidth: 480,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          children: [
            Text(
              'Para garantir a segurança dos seus dados, crie uma senha '
              'forte seguindo os critérios abaixo.',
              style: TextStyle(
                fontSize: 13,
                color: context.colors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Nova senha',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Digite sua nova senha',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Confirmar senha',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _confirmController,
              obscureText: _obscureConfirm,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Repita a senha digitada',
                prefixIcon: const Icon(Icons.shield_outlined),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
                errorText:
                    _confirmController.text.isNotEmpty && !_passwordsMatch
                    ? 'As senhas não coincidem.'
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.colors.neutralSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'REQUISITOS DE SEGURANÇA',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                      color: context.colors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (final requirement in _passwordRequirements)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: _RequirementRow(
                        label: requirement.label,
                        isMet: requirement.isMet(_passwordController.text),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: _canSave(isLoading) ? _save : null,
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Salvar Senha'),
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () => context.go(AppRoutes.welcome),
                child: const Text('Voltar ao início'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RequirementRow extends StatelessWidget {
  const _RequirementRow({required this.label, required this.isMet});

  final String label;
  final bool isMet;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.circle_outlined,
          size: 15,
          color: isMet ? context.colors.success : context.colors.textMuted,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isMet
                  ? context.colors.textPrimary
                  : context.colors.textMuted,
              fontWeight: isMet ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
