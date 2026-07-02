import 'package:flutter/material.dart';

/// Breakpoints usados para decidir quando a navegação vira uma barra
/// lateral (`NavigationRail`) e quando o conteúdo ganha um pouco mais de
/// espaço para respirar em telas largas de desktop web.
class AppBreakpoints {
  AppBreakpoints._();

  static const double desktop = 900;
  static const double wideDesktop = 1150;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= desktop;

  static bool isWideDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= wideDesktop;
}

/// Centraliza o conteúdo de uma tela com uma largura máxima confortável de
/// leitura. Em mobile, a largura da tela já é menor que [maxWidth] então o
/// comportamento fica idêntico ao original; em desktop web, evita que
/// listas e formulários fiquem esticados de ponta a ponta da janela.
class ResponsiveContent extends StatelessWidget {
  const ResponsiveContent({
    super.key,
    required this.child,
    this.maxWidth = 760,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    // Não usa `Center`/`Align`: por padrão eles se esticam para preencher
    // toda a altura disponível, o que é ótimo para o `body` (que já deve
    // preencher a tela), mas quebra usos compactos como
    // `bottomNavigationBar` — nesses slots o Scaffold mede a altura que o
    // conteúdo pede, e um `Center` guloso "rouba" toda a altura restante da
    // tela, deixando outros slots (como o `body`) com zero de altura. Um
    // `Row` centralizado no eixo principal encolhe no eixo cruzado (altura)
    // para caber no conteúdo, então funciona nos dois casos.
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: child,
          ),
        ),
      ],
    );
  }
}
