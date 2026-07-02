import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../domain/entities/client_list_item.dart';
import 'client_tier_chip.dart';

class ClientCard extends StatelessWidget {
  const ClientCard({
    super.key,
    required this.client,
    required this.onTap,
    required this.onToggleFavorite,
  });

  final ClientListItem client;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      client.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: onToggleFavorite,
                    icon: Icon(
                      client.isFavorite ? Icons.star : Icons.star_border,
                      color: client.isFavorite
                          ? AppColors.warning
                          : AppColors.textMuted,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              Text(
                '# ${client.code}',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 6),
              if (client.isOffline) ...[
                const StatusChip(
                  label: 'Offline',
                  icon: Icons.cloud_off_outlined,
                  foreground: AppColors.textSecondary,
                  background: AppColors.neutralSoft,
                ),
                const SizedBox(height: 6),
              ],
              Row(
                children: [
                  const Icon(
                    Icons.badge_outlined,
                    size: 14,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    client.cnpj,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${client.city}, ${client.state}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ClientTierChip(tier: client.tier),
                  Row(
                    children: [
                      const Icon(
                        Icons.history,
                        size: 13,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Últ. Pedido: ${client.lastOrderDateLabel}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
