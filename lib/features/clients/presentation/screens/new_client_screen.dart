import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/responsive_content.dart';
import '../../domain/clients_exception.dart';
import '../../domain/entities/client_detail.dart';
import '../providers/clients_providers.dart';

class NewClientScreen extends ConsumerStatefulWidget {
  const NewClientScreen({super.key});

  @override
  ConsumerState<NewClientScreen> createState() => _NewClientScreenState();
}

class _NewClientScreenState extends ConsumerState<NewClientScreen> {
  final _name = TextEditingController();
  final _cnpj = TextEditingController();
  final _phone = TextEditingController();
  final _mobile = TextEditingController();
  final _email = TextEditingController();
  final _creditLimit = TextEditingController();
  final _street = TextEditingController();
  final _district = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _notes = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _name.dispose();
    _cnpj.dispose();
    _phone.dispose();
    _mobile.dispose();
    _email.dispose();
    _creditLimit.dispose();
    _street.dispose();
    _district.dispose();
    _city.dispose();
    _state.dispose();
    _notes.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _name.text.trim().isNotEmpty &&
      _cnpj.text.trim().isNotEmpty &&
      _phone.text.trim().isNotEmpty &&
      _mobile.text.trim().isNotEmpty &&
      _email.text.trim().isNotEmpty &&
      _street.text.trim().isNotEmpty &&
      _city.text.trim().isNotEmpty &&
      _state.text.trim().isNotEmpty &&
      !_isSaving;

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      await ref.read(clientsRepositoryProvider).createClient(
        name: _name.text.trim(),
        cnpj: _cnpj.text.trim(),
        phone: _phone.text.trim(),
        mobile: _mobile.text.trim(),
        email: _email.text.trim(),
        creditLimit:
            double.tryParse(_creditLimit.text.trim().replaceAll(',', '.')) ??
                0,
        deliveryAddress: DeliveryAddress(
          street: _street.text.trim(),
          district: _district.text.trim(),
          city: _city.text.trim(),
          state: _state.text.trim(),
        ),
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      );
      ref.invalidate(clientsListProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cliente cadastrado com sucesso.')),
      );
      Navigator.of(context).pop();
    } on ClientsException catch (e) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Cliente')),
      body: ResponsiveContent(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          children: [
            _SectionLabel('DADOS DO CLIENTE'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    _field('Nome / Razão Social', _name),
                    _field('CNPJ', _cnpj),
                    _field('Telefone', _phone, keyboardType: TextInputType.phone),
                    _field('Celular', _mobile, keyboardType: TextInputType.phone),
                    _field(
                      'E-mail',
                      _email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    _field(
                      'Limite de Crédito (R\$)',
                      _creditLimit,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _SectionLabel('ENDEREÇO DE ENTREGA'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    _field('Rua / Número', _street),
                    _field('Bairro', _district),
                    _field('Cidade', _city),
                    _field('UF', _state, isLast: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _SectionLabel('OBSERVAÇÕES'),
            const SizedBox(height: 6),
            TextField(
              controller: _notes,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Observações sobre o cliente (opcional)...',
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: context.colors.textMuted,
      ),
    );
  }
}
