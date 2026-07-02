import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../domain/entities/scheduled_visit.dart';
import '../providers/agenda_providers.dart';

class VisitCard extends ConsumerStatefulWidget {
  const VisitCard({super.key, required this.visit});

  final ScheduledVisit visit;

  @override
  ConsumerState<VisitCard> createState() => _VisitCardState();
}

class _VisitCardState extends ConsumerState<VisitCard> {
  bool _isLocating = false;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.visit.notes);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleCheckIn() async {
    setState(() => _isLocating = true);
    final result = await ref.read(locationServiceProvider).getCurrentPosition();
    if (!mounted) return;
    setState(() => _isLocating = false);

    ref
        .read(agendaControllerProvider.notifier)
        .checkIn(widget.visit.id, geoValidated: result.isSuccess);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.isSuccess
              ? 'Check-in realizado com localização validada via GPS.'
              : 'Check-in realizado, mas a localização não pôde ser validada (${result.errorMessage}).',
        ),
      ),
    );
  }

  Future<void> _handleCheckOut() async {
    ref
        .read(agendaControllerProvider.notifier)
        .checkOut(widget.visit.id, _notesController.text);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Check-out registrado. Visita concluída.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visit = widget.visit;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.neutralSoft,
                  child: Text(
                    visit.clientName.substring(0, 1),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              visit.clientName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          if (visit.status == VisitStatus.inProgress) ...[
                            const SizedBox(width: 8),
                            const StatusChip(
                              label: 'Em Andamento',
                              foreground: Colors.white,
                              background: AppColors.primary,
                              filled: true,
                            ),
                          ],
                          if (visit.isProspect) ...[
                            const SizedBox(width: 8),
                            const StatusChip(
                              label: 'Cliente em Potencial',
                              icon: Icons.person_search_outlined,
                              foreground: AppColors.warning,
                              background: AppColors.warningSoft,
                            ),
                          ],
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 12,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Agendado: ${visit.scheduledTimeLabel}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    visit.address,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            if (visit.status == VisitStatus.inProgress) ...[
              const SizedBox(height: 10),
              if (visit.isGeoValidated)
                const Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 14,
                      color: AppColors.success,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Localização validada via GPS',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 8),
              const Text(
                'NOTAS DA VISITA',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _notesController,
                maxLines: 2,
                style: const TextStyle(fontSize: 12),
                decoration: const InputDecoration(
                  hintText: 'Descreva o resultado da abordagem...',
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildActionButton(context)),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.navigation_outlined, size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                ),
                icon: const Icon(Icons.history, size: 14),
                label: const Text(
                  'Histórico Recente',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    switch (widget.visit.status) {
      case VisitStatus.completed:
        return OutlinedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.check, size: 16),
          label: const Text('Concluída'),
        );
      case VisitStatus.inProgress:
        return ElevatedButton.icon(
          onPressed: _handleCheckOut,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          icon: const Icon(Icons.stop_circle_outlined, size: 16),
          label: const Text('Check-out'),
        );
      case VisitStatus.pending:
        return ElevatedButton.icon(
          onPressed: _isLocating ? null : _handleCheckIn,
          icon: _isLocating
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.play_circle_outline, size: 16),
          label: const Text('Check-in'),
        );
    }
  }
}
