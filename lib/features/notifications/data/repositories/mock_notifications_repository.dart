import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notifications_repository.dart';

/// Dados fixos espelhando a tela "Notificações" do protótipo.
class MockNotificationsRepository implements NotificationsRepository {
  @override
  Future<List<AppNotification>> fetchAll() async {
    await Future.delayed(const Duration(milliseconds: 400));

    return const [
      AppNotification(
        id: 'n1',
        category: NotificationCategory.order,
        title: 'Pedido Aprovado #8829',
        message:
            'O pedido do cliente Supermercado Silva foi faturado e enviado para logística.',
        timeLabel: '10 min atrás',
      ),
      AppNotification(
        id: 'n2',
        category: NotificationCategory.promotion,
        title: 'Mega Campanha Arroz Tio Jorge',
        message:
            'Descontos de até 15% para compras acima de 100 fardos até o final desta semana.',
        timeLabel: '1 hora atrás',
        isUrgent: true,
      ),
      AppNotification(
        id: 'n3',
        category: NotificationCategory.announcement,
        title: 'Atualização de Tabela de Preços',
        message:
            'Nova tabela de preços para a linha de feijões entra em vigor a partir de amanhã.',
        timeLabel: '4 horas atrás',
        isRead: true,
      ),
      AppNotification(
        id: 'n4',
        category: NotificationCategory.launch,
        title: 'Lançamento: Azeite Josapar Premium',
        message:
            'Novo item no catálogo: Azeite de Oliva Extra Virgem 500ml. Confira o material de divulgação.',
        timeLabel: 'Ontem',
        isRead: true,
      ),
      AppNotification(
        id: 'n5',
        category: NotificationCategory.order,
        title: 'Crédito Bloqueado: Cliente #4471',
        message:
            'O pedido de Atacado Central foi bloqueado por limite de crédito excedido. Contate o financeiro.',
        timeLabel: 'Ontem',
        isUrgent: true,
      ),
      AppNotification(
        id: 'n6',
        category: NotificationCategory.announcement,
        title: 'Treinamento de Vendas Concluído',
        message:
            'O material do último treinamento já está disponível na central de ajuda.',
        timeLabel: '3 dias atrás',
        isRead: true,
        isRecent: false,
      ),
    ];
  }
}
