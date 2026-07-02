import 'package:intl/intl.dart';

class AppFormatters {
  AppFormatters._();

  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  static String currency(num value) => _currency.format(value);

  /// Formata como dd/MM/yyyy sem depender de `initializeDateFormatting`
  /// (que carrega dados de locale de forma assíncrona e não deve ser
  /// aguardado no boot do app — ver [weekdayAbbreviation] e [monthYear]).
  static String shortDate(DateTime date) {
    String pad(int n) => n.toString().padLeft(2, '0');
    return '${pad(date.day)}/${pad(date.month)}/${date.year}';
  }

  static const _weekdayAbbreviations = [
    'SEG',
    'TER',
    'QUA',
    'QUI',
    'SEX',
    'SÁB',
    'DOM',
  ];

  /// `date.weekday` é 1 (segunda) .. 7 (domingo).
  static String weekdayAbbreviation(DateTime date) =>
      _weekdayAbbreviations[date.weekday - 1];

  static const _monthNames = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];

  static String monthYear(DateTime date) =>
      '${_monthNames[date.month - 1]} ${date.year}';

  static String timeOfDay(DateTime date) {
    String pad(int n) => n.toString().padLeft(2, '0');
    return '${pad(date.hour)}:${pad(date.minute)}';
  }
}
