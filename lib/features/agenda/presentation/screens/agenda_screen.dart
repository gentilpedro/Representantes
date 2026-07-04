import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/responsive_content.dart';
import '../providers/agenda_providers.dart';
import '../widgets/day_selector.dart';
import '../widgets/route_summary_card.dart';
import '../widgets/visit_card.dart';

class AgendaScreen extends ConsumerWidget {
  const AgendaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedAgendaDateProvider);
    final routeAsync = ref.watch(agendaControllerProvider);
    final monthLabel = AppFormatters.monthYear(selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda de Visitas'),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(agendaControllerProvider),
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () => context.push(AppRoutes.notifications),
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),
      body: ResponsiveContent(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(agendaControllerProvider),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: context.colors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        monthLabel,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () =>
                        ref
                            .read(selectedAgendaDateProvider.notifier)
                            .state = DateTime(
                          DateTime.now().year,
                          DateTime.now().month,
                          DateTime.now().day,
                        ),
                    child: const Text('Hoje'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              DaySelector(
                selectedDate: selectedDate,
                onSelected: (date) =>
                    ref.read(selectedAgendaDateProvider.notifier).state = date,
              ),
              const SizedBox(height: 20),
              routeAsync.when(
                loading: () => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: context.colors.primary,
                    ),
                  ),
                ),
                error: (error, _) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text('Não foi possível carregar a agenda.\n$error'),
                ),
                data: (route) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RouteSummaryCard(route: route),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Cronograma Diário',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: context.colors.neutralSoft,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${route.visitsPlanned} Visitas',
                            style: TextStyle(
                              fontSize: 10,
                              color: context.colors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    for (var i = 0; i < route.visits.length; i++) ...[
                      VisitCard(visit: route.visits[i]),
                      if (route.routeTip != null && i == 1) ...[
                        const SizedBox(height: 4),
                        _RouteTip(message: route.routeTip!),
                        const SizedBox(height: 4),
                      ] else
                        const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RouteTip extends StatelessWidget {
  const _RouteTip({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
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
                  'Dica de Rota',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: context.colors.primaryDark,
                  ),
                ),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colors.primaryDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
