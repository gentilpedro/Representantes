import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/responsive_content.dart';
import '../widgets/auth_brand_panel.dart';

/// Primeira tela pública do app: ponto de entrada tanto para quem já tem
/// conta ("Entrar") quanto para quem está acessando pela primeira vez
/// ("Primeiro Acesso").
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = AppBreakpoints.isDesktop(context);

    return Scaffold(
      body: SafeArea(
        child: isDesktop
            ? AuthDesktopLayout(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: _buildCoreContent(context),
                ),
              )
            : Column(
                children: [
                  const _StatusBar(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 24),
                          ..._buildCoreContent(context),
                          const SizedBox(height: 32),
                          const _SecurityFooter(),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  List<Widget> _buildCoreContent(BuildContext context) {
    return [
      Center(
        child: Container(
          width: 88,
          height: 88,
          padding: const EdgeInsets.all(18),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Image.asset('assets/branding/app_icon.png'),
        ),
      ),
      const SizedBox(height: 24),
      Text(
        'Bem-vindo à Josapar',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: context.colors.textPrimary,
        ),
      ),
      const SizedBox(height: 10),
      Text(
        'Acesse sua conta para gerenciar seus pedidos e acompanhar nossas '
        'novidades com agilidade.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          color: context.colors.textSecondary,
          height: 1.4,
        ),
      ),
      const SizedBox(height: 32),
      ElevatedButton.icon(
        onPressed: () => context.push(AppRoutes.login),
        icon: const Icon(Icons.login, size: 18),
        label: const Text('Entrar'),
      ),
      const SizedBox(height: 12),
      OutlinedButton.icon(
        onPressed: () => context.push(AppRoutes.firstAccess),
        style: OutlinedButton.styleFrom(
          backgroundColor: context.colors.neutralSoft,
          side: BorderSide.none,
        ),
        icon: const Icon(Icons.person_add_alt_1_outlined, size: 18),
        label: const Text('Primeiro Acesso'),
      ),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.colors.infoSoft,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, size: 18, color: context.colors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Novo por aqui?',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: context.colors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Você precisará do seu CPF ou CNPJ e do código de '
                    'cliente fornecido em sua última nota fiscal.',
                    style: TextStyle(
                      fontSize: 12,
                      color: context.colors.primaryDark,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      Center(
        child: TextButton(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Recuperação de senha ainda não implementada.'),
            ),
          ),
          child: const Text('Esqueceu sua senha? Recuperar agora'),
        ),
      ),
    ];
  }
}

class _StatusBar extends ConsumerWidget {
  const _StatusBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(connectivityStatusProvider).valueOrNull ?? true;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: context.colors.neutralSoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isOnline ? Icons.wifi : Icons.wifi_off,
                  size: 13,
                  color: context.colors.textSecondary,
                ),
                const SizedBox(width: 5),
                Text(
                  isOnline ? 'ONLINE' : 'OFFLINE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Central de ajuda em breve.')),
                ),
                icon: Icon(
                  Icons.help_outline,
                  size: 20,
                  color: context.colors.textSecondary,
                ),
              ),
              IconButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Modo escuro ainda não disponível.'),
                  ),
                ),
                icon: Icon(
                  Icons.dark_mode_outlined,
                  size: 20,
                  color: context.colors.textSecondary,
                ),
              ),
              TextButton.icon(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Apenas Português (Brasil) disponível.'),
                  ),
                ),
                icon: Icon(
                  Icons.public,
                  size: 16,
                  color: context.colors.textSecondary,
                ),
                label: const Text('PT-BR'),
                style: TextButton.styleFrom(
                  foregroundColor: context.colors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SecurityFooter extends StatelessWidget {
  const _SecurityFooter();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'DESDE 1922',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: context.colors.textMuted,
                ),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: context.colors.border)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        size: 14,
                        color: context.colors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Josapar Segura',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'v2.4.0-stable',
                    style: TextStyle(
                      fontSize: 11,
                      color: context.colors.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                    ),
                    child: const Text(
                      'Termos de Uso',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '•',
                      style: TextStyle(color: context.colors.border),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                    ),
                    child: const Text(
                      'Privacidade',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
