import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../clients/domain/entities/client_summary.dart';
import 'agenda_providers.dart';

class NewVisitFormState {
  const NewVisitFormState({
    required this.client,
    required this.scheduledAt,
    this.notes = '',
  });

  final ClientSummary? client;
  final DateTime scheduledAt;
  final String notes;

  NewVisitFormState copyWith({
    ClientSummary? client,
    DateTime? scheduledAt,
    String? notes,
  }) {
    return NewVisitFormState(
      client: client ?? this.client,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      notes: notes ?? this.notes,
    );
  }
}

/// Mantém a "visita em construção" enquanto a tela de Nova Visita está
/// aberta — mesmo papel do `NewOrderController` para o fluxo de Pedidos.
class NewVisitController extends Notifier<NewVisitFormState> {
  @override
  NewVisitFormState build() {
    final selectedDate = ref.read(selectedAgendaDateProvider);
    return NewVisitFormState(
      client: null,
      scheduledAt: DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        9,
      ),
    );
  }

  void selectClient(ClientSummary client) {
    state = state.copyWith(client: client);
  }

  void updateScheduledAt(DateTime scheduledAt) {
    state = state.copyWith(scheduledAt: scheduledAt);
  }

  void updateNotes(String notes) {
    state = state.copyWith(notes: notes);
  }

  void clear() {
    state = NewVisitFormState(client: null, scheduledAt: state.scheduledAt);
  }
}

final newVisitControllerProvider =
    NotifierProvider<NewVisitController, NewVisitFormState>(
      NewVisitController.new,
    );
