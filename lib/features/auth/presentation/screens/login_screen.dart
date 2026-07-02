import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/responsive_content.dart';
import '../providers/auth_providers.dart';
import '../widgets/auth_brand_panel.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _keepConnected = true;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    await ref
        .read(authControllerProvider.notifier)
        .login(
          identifier: _identifierController.text,
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
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;
    final isDesktop = AppBreakpoints.isDesktop(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const _BackButton(),
            Expanded(
              child: isDesktop
                  ? AuthDesktopLayout(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Acessar Sistema',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Entre com seu código de representante para continuar.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 28),
                          ..._buildCoreForm(isLoading),
                          const SizedBox(height: 32),
                          const Center(child: _SystemStatusFooter()),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 8),
                          const _BrandMark(),
                          const SizedBox(height: 32),
                          ..._buildCoreForm(isLoading),
                          const SizedBox(height: 40),
                          const _SystemStatusFooter(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCoreForm(bool isLoading) {
    return [
      _FieldLabel('Representante'),
      const SizedBox(height: 6),
      TextField(
        controller: _identifierController,
        textInputAction: TextInputAction.next,
        decoration: const InputDecoration(
          hintText: 'Digite seu código ou e-mail',
          prefixIcon: Icon(Icons.person_outline),
        ),
      ),
      const SizedBox(height: 18),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _FieldLabel('Senha'),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
            ),
            child: const Text('Esqueceu a senha?'),
          ),
        ],
      ),
      const SizedBox(height: 6),
      TextField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => isLoading ? null : _submit(),
        decoration: InputDecoration(
          hintText: '••••••••',
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
      const SizedBox(height: 14),
      Row(
        children: [
          Checkbox(
            value: _keepConnected,
            onChanged: (value) =>
                setState(() => _keepConnected = value ?? true),
          ),
          const Expanded(child: Text('Manter conectado neste dispositivo')),
        ],
      ),
      const SizedBox(height: 8),
      ElevatedButton(
        onPressed: isLoading ? null : _submit,
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Acessar Sistema'),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 18),
                ],
              ),
      ),
    ];
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.canPop()
                ? context.pop()
                : context.go(AppRoutes.welcome),
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Voltar',
          ),
        ],
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.textPrimary,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(Icons.bolt, color: Colors.white, size: 36),
        ),
        const SizedBox(height: 20),
        const Text(
          'SOLUÇÕES EM VENDAS CORPORATIVAS',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            letterSpacing: 0.3,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shield_outlined, size: 13, color: AppColors.textMuted),
            SizedBox(width: 4),
            Text(
              'CONEXÃO SEGURA JWT ATIVA',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SystemStatusFooter extends StatelessWidget {
  const _SystemStatusFooter();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi, size: 15, color: AppColors.textSecondary),
              SizedBox(width: 6),
              Text(
                'SISTEMA ONLINE (SINCRO AUTOMÁTICA)',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'VERSÃO 2.4.0-BUILD-88',
          style: TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
        const SizedBox(height: 4),
        const Text(
          '© 2024 Josapar S.A. Todos os direitos reservados.',
          style: TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
    );
  }
}
