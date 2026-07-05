import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/responsive_content.dart';
import '../providers/leads_providers.dart';
import '../widgets/lead_status_chip.dart';

class LeadDetailScreen extends ConsumerWidget {
  const LeadDetailScreen({super.key, required this.leadId});

  final String leadId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leadAsync = ref.watch(leadDetailProvider(leadId));

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhe do Lead')),
      body: ResponsiveContent(
        child: leadAsync.when(
          loading: () => Center(
            child: CircularProgressIndicator(color: context.colors.primary),
          ),
          error: (error, _) =>
              Center(child: Text('Não foi possível carregar o lead.\n$error')),
          data: (lead) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        lead.companyName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    LeadStatusChip(status: lead.status),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  lead.contactName,
                  style: TextStyle(color: context.colors.textSecondary),
                ),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InfoRow(icon: Icons.call_outlined, label: lead.phone),
                        if (lead.email != null)
                          _InfoRow(icon: Icons.email_outlined, label: lead.email!),
                        if (lead.cnpj != null)
                          _InfoRow(icon: Icons.badge_outlined, label: lead.cnpj!),
                        if (lead.source != null)
                          _InfoRow(
                            icon: Icons.campaign_outlined,
                            label: 'Origem: ${lead.source}',
                          ),
                        _InfoRow(
                          icon: Icons.calendar_today_outlined,
                          label:
                              'Criado em ${AppFormatters.shortDate(lead.createdAtUtc.toLocal())}',
                        ),
                        if (lead.lastContactAtUtc != null)
                          _InfoRow(
                            icon: Icons.history,
                            label:
                                'Último contato em ${AppFormatters.shortDate(lead.lastContactAtUtc!.toLocal())}',
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'OBSERVAÇÕES',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: context.colors.textMuted,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  lead.notes?.isNotEmpty == true
                      ? lead.notes!
                      : 'Nenhuma observação registrada.',
                  style: TextStyle(color: context.colors.textSecondary),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await context.push(AppRoutes.editLead(lead.id));
                      ref.invalidate(leadDetailProvider(leadId));
                      ref.invalidate(leadsListProvider);
                    },
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Editar'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 15, color: context.colors.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: context.colors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
