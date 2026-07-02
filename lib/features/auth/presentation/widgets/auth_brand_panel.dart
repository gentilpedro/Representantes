import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Painel de identidade visual reaproveitado por todas as telas públicas
/// (Boas-vindas, Login) no layout de desktop — preenche o espaço que, em
/// mobile, ficaria vazio ao lado de um formulário estreito.
class AuthBrandPanel extends StatelessWidget {
  const AuthBrandPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primary],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(48),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.bolt,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Josapar Representantes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Soluções em vendas corporativas — pedidos, clientes e '
                  'agenda de visitas em um só lugar, online ou offline.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: 15,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'CONEXÃO SEGURA JWT ATIVA',
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 0.3,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Em telas largas de desktop, divide a tela em [AuthBrandPanel] (esquerda)
/// e [child] centrado num cartão de largura confortável (direita) — em vez
/// de um formulário mobile esticado até as bordas da janela.
class AuthDesktopLayout extends StatelessWidget {
  const AuthDesktopLayout({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(flex: 5, child: AuthBrandPanel()),
        Expanded(
          flex: 4,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: child,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
