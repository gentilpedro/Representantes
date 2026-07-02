import 'package:flutter/material.dart';

/// Chip de status reutilizável (ex: Pendente, Enviado, Erro, Rascunho,
/// Sincronizado, Urgente...) usado em Pedidos, Clientes, Sincronização e
/// Notificações.
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    required this.foreground,
    required this.background,
    this.icon,
    this.filled = false,
  });

  final String label;
  final Color foreground;
  final Color background;
  final IconData? icon;

  /// Quando true, usa preenchimento sólido (ex: badges "URGENTE"/"ERRO").
  /// Quando false, usa fundo suave com texto colorido (padrão dos status
  /// de pedido no protótipo).
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: filled ? foreground : background,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: filled ? Colors.white : foreground),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: filled ? Colors.white : foreground,
            ),
          ),
        ],
      ),
    );
  }
}
