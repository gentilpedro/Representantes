import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/responsive_content.dart';
import '../../domain/entities/lead.dart';
import '../providers/leads_providers.dart';
import '../widgets/lead_card.dart';
import '../widgets/lead_status_chip.dart';

class LeadsScreen extends ConsumerWidget {
  const LeadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leadsAsync = ref.watch(filteredLeadsProvider);
    final statusFilter = ref.watch(leadStatusFilterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Leads')),
      body: ResponsiveContent(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                children: [
                  TextField(
                    onChanged: (value) =>
                        ref.read(leadSearchQueryProvider.notifier).state =
                            value,
                    decoration: const InputDecoration(
                      hintText: 'Contato ou empresa...',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _StatusFilterChip(label: 'Todos', value: null, groupValue: statusFilter),
                        const SizedBox(width: 8),
                        for (final status in LeadStatus.values) ...[
                          _StatusFilterChip(
                            label: LeadStatusChip.label(status),
                            value: status,
                            groupValue: statusFilter,
                          ),
                          const SizedBox(width: 8),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: leadsAsync.when(
                loading: () => Center(
                  child: CircularProgressIndicator(color: context.colors.primary),
                ),
                error: (error, _) => Center(
                  child: Text('Não foi possível carregar os leads.\n$error'),
                ),
                data: (leads) {
                  if (leads.isEmpty) {
                    return const Center(child: Text('Nenhum lead encontrado.'));
                  }
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    children: [
                      for (final lead in leads) ...[
                        LeadCard(
                          lead: lead,
                          onTap: () =>
                              context.push(AppRoutes.leadDetail(lead.id)),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.newLead),
        child: const Icon(Icons.person_add_alt_1_outlined),
      ),
    );
  }
}

class _StatusFilterChip extends ConsumerWidget {
  const _StatusFilterChip({
    required this.label,
    required this.value,
    required this.groupValue,
  });

  final String label;
  final LeadStatus? value;
  final LeadStatus? groupValue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = value == groupValue;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) =>
          ref.read(leadStatusFilterProvider.notifier).state = value,
      selectedColor: context.colors.primary,
      backgroundColor: context.colors.surface,
      side: BorderSide(color: context.colors.border),
      labelStyle: TextStyle(
        color: selected ? Colors.white : context.colors.textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
