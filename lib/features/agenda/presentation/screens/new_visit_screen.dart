import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/responsive_content.dart';
import '../../domain/agenda_exception.dart';
import '../providers/agenda_providers.dart';
import '../providers/new_visit_providers.dart';

class NewVisitScreen extends ConsumerStatefulWidget {
  const NewVisitScreen({super.key});

  @override
  ConsumerState<NewVisitScreen> createState() => _NewVisitScreenState();
}

class _NewVisitScreenState extends ConsumerState<NewVisitScreen> {
  bool _isSaving = false;

  Future<void> _pickDate(DateTime current) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;
    final merged = DateTime(
      picked.year,
      picked.month,
      picked.day,
      current.hour,
      current.minute,
    );
    ref.read(newVisitControllerProvider.notifier).updateScheduledAt(merged);
  }

  Future<void> _pickTime(DateTime current) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (picked == null) return;
    final merged = DateTime(
      current.year,
      current.month,
      current.day,
      picked.hour,
      picked.minute,
    );
    ref.read(newVisitControllerProvider.notifier).updateScheduledAt(merged);
  }

  Future<void> _save() async {
    final formState = ref.read(newVisitControllerProvider);
    final client = formState.client;
    if (client == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um cliente antes de salvar.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ref
          .read(agendaControllerProvider.notifier)
          .createVisit(
            clientId: client.id,
            scheduledAtUtc: formState.scheduledAt.toUtc(),
            notes: formState.notes.trim().isEmpty ? null : formState.notes.trim(),
          );
      ref.read(newVisitControllerProvider.notifier).clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Visita agendada com sucesso.')),
      );
      Navigator.of(context).pop();
    } on AgendaException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(newVisitControllerProvider);
    final client = formState.client;

    return Scaffold(
      appBar: AppBar(title: const Text('Nova Visita')),
      body: ResponsiveContent(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'CLIENTE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: context.colors.textMuted,
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      context.push(AppRoutes.selectClientForVisit),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                  ),
                  child: const Text('Alterar'),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (client != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: context.colors.primarySoft,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.apartment_outlined,
                          color: context.colors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              client.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'CNPJ: ${client.cnpj}',
                              style: TextStyle(
                                fontSize: 11,
                                color: context.colors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    'Nenhum cliente selecionado.',
                    style: TextStyle(color: context.colors.textMuted),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            Text(
              'DATA E HORÁRIO',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: context.colors.textMuted,
              ),
            ),
            const SizedBox(height: 6),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.calendar_today_outlined),
                    title: Text(AppFormatters.shortDate(formState.scheduledAt)),
                    onTap: () => _pickDate(formState.scheduledAt),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: Text(AppFormatters.timeOfDay(formState.scheduledAt)),
                    onTap: () => _pickTime(formState.scheduledAt),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'OBSERVAÇÕES',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: context.colors.textMuted,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              maxLines: 3,
              onChanged: (value) =>
                  ref.read(newVisitControllerProvider.notifier).updateNotes(value),
              decoration: const InputDecoration(
                hintText: 'Ex: Levar tabela de preços atualizada...',
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: ResponsiveContent(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Salvar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
