import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/responsive_content.dart';
import '../../domain/entities/lead.dart';
import '../../domain/leads_exception.dart';
import '../providers/leads_providers.dart';
import '../widgets/lead_status_chip.dart';

/// Uma única tela pra criar (`editLeadId == null`) e editar
/// (`editLeadId != null`, busca o lead via [leadDetailProvider] e
/// pré-popula os campos) — a API de edição já atualiza tudo de uma vez via
/// `PATCH`, então não precisa de telas separadas.
class LeadFormScreen extends ConsumerStatefulWidget {
  const LeadFormScreen({super.key, this.editLeadId});

  final String? editLeadId;

  @override
  ConsumerState<LeadFormScreen> createState() => _LeadFormScreenState();
}

class _LeadFormScreenState extends ConsumerState<LeadFormScreen> {
  final _contactName = TextEditingController();
  final _companyName = TextEditingController();
  final _cnpj = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _source = TextEditingController();
  final _notes = TextEditingController();

  LeadStatus _status = LeadStatus.new_;
  bool _isSaving = false;
  bool _prefilled = false;

  bool get _isEditing => widget.editLeadId != null;

  @override
  void dispose() {
    _contactName.dispose();
    _companyName.dispose();
    _cnpj.dispose();
    _phone.dispose();
    _email.dispose();
    _source.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _prefill(Lead lead) {
    if (_prefilled) return;
    _prefilled = true;
    _contactName.text = lead.contactName;
    _companyName.text = lead.companyName;
    _cnpj.text = lead.cnpj ?? '';
    _phone.text = lead.phone;
    _email.text = lead.email ?? '';
    _source.text = lead.source ?? '';
    _notes.text = lead.notes ?? '';
    _status = lead.status;
  }

  bool get _canSave =>
      _contactName.text.trim().isNotEmpty &&
      _companyName.text.trim().isNotEmpty &&
      _phone.text.trim().isNotEmpty &&
      !_isSaving;

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      if (_isEditing) {
        await ref.read(leadsRepositoryProvider).updateLead(
          id: widget.editLeadId!,
          contactName: _contactName.text.trim(),
          companyName: _companyName.text.trim(),
          cnpj: _cnpj.text.trim().isEmpty ? null : _cnpj.text.trim(),
          phone: _phone.text.trim(),
          email: _email.text.trim().isEmpty ? null : _email.text.trim(),
          status: _status,
          source: _source.text.trim().isEmpty ? null : _source.text.trim(),
          notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
          lastContactAtUtc: DateTime.now().toUtc(),
        );
      } else {
        await ref.read(leadsRepositoryProvider).createLead(
          contactName: _contactName.text.trim(),
          companyName: _companyName.text.trim(),
          cnpj: _cnpj.text.trim().isEmpty ? null : _cnpj.text.trim(),
          phone: _phone.text.trim(),
          email: _email.text.trim().isEmpty ? null : _email.text.trim(),
          source: _source.text.trim().isEmpty ? null : _source.text.trim(),
          notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        );
      }
      ref.invalidate(leadsListProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Lead atualizado.' : 'Lead cadastrado.'),
        ),
      );
      Navigator.of(context).pop();
    } on LeadsException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(hintText: label),
      ),
    );
  }

  Widget _buildForm() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [
        Text(
          'DADOS DO LEAD',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: context.colors.textMuted,
          ),
        ),
        const SizedBox(height: 6),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _field('Nome do Contato', _contactName),
                _field('Empresa', _companyName),
                _field('CNPJ (opcional)', _cnpj),
                _field('Telefone', _phone, keyboardType: TextInputType.phone),
                _field(
                  'E-mail (opcional)',
                  _email,
                  keyboardType: TextInputType.emailAddress,
                ),
                _field(
                  'Origem (opcional)',
                  _source,
                  isLast: !_isEditing,
                ),
                if (_isEditing) ...[
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final status in LeadStatus.values)
                          ChoiceChip(
                            label: Text(LeadStatusChip.label(status)),
                            selected: _status == status,
                            onSelected: (_) => setState(() => _status = status),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
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
          controller: _notes,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Observações sobre o lead (opcional)...',
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_isEditing) {
      final leadAsync = ref.watch(leadDetailProvider(widget.editLeadId!));
      body = leadAsync.when(
        loading: () => Center(
          child: CircularProgressIndicator(color: context.colors.primary),
        ),
        error: (error, _) =>
            Center(child: Text('Não foi possível carregar o lead.\n$error')),
        data: (lead) {
          _prefill(lead);
          return _buildForm();
        },
      );
    } else {
      body = _buildForm();
    }

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Editar Lead' : 'Novo Lead')),
      body: ResponsiveContent(child: body),
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
                    onPressed: _canSave ? _save : null,
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
