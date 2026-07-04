import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_palette.dart';
import '../../domain/entities/daily_route.dart';

class RouteSummaryCard extends StatelessWidget {
  const RouteSummaryCard({super.key, required this.route});

  final DailyRoute route;

  Future<void> _openInMaps() async {
    final uri = Uri.parse('geo:0,0?q=rota+de+visitas');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
            child: Row(
              children: [
                Icon(
                  Icons.map_outlined,
                  size: 16,
                  color: context.colors.primary,
                ),
                const SizedBox(width: 6),
                const Text(
                  'Planejamento de Rota',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ],
            ),
          ),
          Stack(
            children: [
              Container(
                height: 140,
                width: double.infinity,
                color: context.colors.neutralSoft,
                child: Icon(
                  Icons.map,
                  size: 48,
                  color: context.colors.border,
                ),
              ),
              Positioned(
                right: 10,
                bottom: 10,
                child: ElevatedButton.icon(
                  onPressed: _openInMaps,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 34),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    backgroundColor: Colors.white,
                    foregroundColor: context.colors.textPrimary,
                  ),
                  icon: const Icon(Icons.navigation_outlined, size: 15),
                  label: const Text(
                    'Abrir no GPS',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL DA ROTA',
                      style: TextStyle(
                        fontSize: 10,
                        color: context.colors.textMuted,
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${route.totalKm.toStringAsFixed(1)} km',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            '(${route.estimatedDuration})',
                            style: TextStyle(
                              fontSize: 11,
                              color: context.colors.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'PROGRESSO',
                      style: TextStyle(
                        fontSize: 10,
                        color: context.colors.textMuted,
                      ),
                    ),
                    Text(
                      '${route.completedOrInProgressCount}/${route.visitsPlanned} Visitas',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: context.colors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
