import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/responsive_content.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/kpi_card.dart';
import '../widgets/monthly_goal_card.dart';
import '../widgets/quick_access_grid.dart';
import '../widgets/recent_orders_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dashboardSummaryProvider);

    return Scaffold(
      body: ResponsiveContent(
        child: SafeArea(
          child: summaryAsync.when(
            loading: () => Center(
              child: CircularProgressIndicator(color: context.colors.primary),
            ),
            error: (error, _) => Center(
              child: Text(
                'Não foi possível carregar o dashboard.\n$error',
                textAlign: TextAlign.center,
              ),
            ),
            data: (summary) => RefreshIndicator(
              onRefresh: () async => ref.invalidate(dashboardSummaryProvider),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  _TopBar(
                    onNotificationsTap: () =>
                        context.push(AppRoutes.notifications),
                  ),
                  const SizedBox(height: 16),
                  _Greeting(summary: summary),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: KpiCard(
                          icon: Icons.trending_up,
                          label: 'Vendas Hoje',
                          value: AppFormatters.currency(summary.salesToday),
                          growthLabel:
                              '+${summary.salesTodayGrowthPercent.toStringAsFixed(0)}%',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: KpiCard(
                          icon: Icons.person_pin_circle_outlined,
                          label: 'Visitas',
                          value:
                              '${summary.visitsCompleted} / ${summary.visitsTotal}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Acesso Rápido',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  QuickAccessGrid(
                    items: [
                      QuickAccessItem(
                        icon: Icons.add_circle_outline,
                        label: 'Novo Pedido',
                        onTap: () => context.push(AppRoutes.newOrder),
                      ),
                      QuickAccessItem(
                        icon: Icons.calendar_today_outlined,
                        label: 'Minha Agenda',
                        onTap: () => context.go(AppRoutes.agenda),
                      ),
                      QuickAccessItem(
                        icon: Icons.people_outline,
                        label: 'Clientes',
                        onTap: () => context.go(AppRoutes.clients),
                      ),
                      QuickAccessItem(
                        icon: Icons.inventory_2_outlined,
                        label: 'Catálogo',
                        onTap: () => context.push(AppRoutes.catalog),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  MonthlyGoalCard(
                    achieved: summary.monthlyGoalAchieved,
                    target: summary.monthlyGoalTarget,
                    percent: summary.monthlyGoalPercent,
                    series: summary.monthlySeries,
                  ),
                  const SizedBox(height: 22),
                  RecentOrdersCard(
                    orders: summary.recentOrders,
                    onSeeAll: () => context.go(AppRoutes.orders),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onNotificationsTap});

  final VoidCallback onNotificationsTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 36,
          height: 36,
          padding: const EdgeInsets.all(6),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Image.asset('assets/branding/app_icon.png'),
        ),
        Row(
          children: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.refresh)),
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  onPressed: onNotificationsTap,
                  icon: const Icon(Icons.notifications_outlined),
                ),
                Positioned(
                  right: 4,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: context.colors.error,
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      '2',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Olá, ${summary.greetingName}!',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Você tem ${summary.scheduledVisitsToday} visitas agendadas hoje.',
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: context.colors.primary,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.adjust, color: Colors.white, size: 20),
        ),
      ],
    );
  }
}
