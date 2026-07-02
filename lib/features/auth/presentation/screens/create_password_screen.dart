import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/responsive_content.dart';

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

/// Último passo do fluxo de "Primeiro Acesso": define a senha da conta.
/// Protótipo — não persiste nada de verdade, apenas simula o cadastro e
/// devolve o representante para o Login (que aceita qualquer credencial).
class CreatePasswordScreen extends StatefulWidget {
  const CreatePasswordScreen({super.key});

  @override
  State<CreatePasswordScreen> createState() => _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends State<CreatePasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isSaving = false;

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

  bool get _canSave => _allRequirementsMet && _passwordsMatch && !_isSaving;

  Future<void> _save() async {
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Senha criada! Faça login para continuar.')),
    );
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Senha')),
      body: ResponsiveContent(
        maxWidth: 480,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          children: [
            const Text(
              'Para garantir a segurança dos seus dados, crie uma senha '
              'forte seguindo os critérios abaixo.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
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
                color: AppColors.neutralSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'REQUISITOS DE SEGURANÇA',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                      color: AppColors.textMuted,
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
              onPressed: _canSave ? _save : null,
              child: _isSaving
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
          color: isMet ? AppColors.success : AppColors.textMuted,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isMet ? AppColors.textPrimary : AppColors.textMuted,
              fontWeight: isMet ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
