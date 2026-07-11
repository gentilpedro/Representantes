import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/reports_summary.dart';
import '../../domain/repositories/reports_repository.dart';
import '../../domain/reports_exception.dart';

/// Implementação real de [ReportsRepository], contra
/// `GET /api/reports/summary` da Web API .NET 10. Cada período tem seu
/// próprio cache (ver [AppDatabase]), já que os dados mudam de forma
/// completamente diferente entre "hoje" e "trimestre".
class ApiReportsRepository implements ReportsRepository {
  ApiReportsRepository(this._apiClient, this._db);

  final ApiClient _apiClient;
  final AppDatabase _db;

  String _cacheKey(ReportPeriod period) => 'reports:${period.name}';

  @override
  Future<ReportsSummary> fetchSummary(ReportPeriod period) async {
    final cacheKey = _cacheKey(period);
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/api/reports/summary',
        queryParameters: {'period': period.name},
      );
      await _db.upsertJsonCache(cacheKey, jsonEncode(response.data));
      return _parseSummary(response.data!);
    } on DioException catch (_) {
      final cached = await _db.fetchJsonCache(cacheKey);
      if (cached != null) {
        return _parseSummary(jsonDecode(cached) as Map<String, dynamic>);
      }
      throw ReportsException(
        'Não foi possível carregar os relatórios. Tente novamente.',
      );
    }
  }

  ReportsSummary _parseSummary(Map<String, dynamic> json) {
    return ReportsSummary(
      totalSales: _parseKpi(
        json['totalSales'] as Map<String, dynamic>,
        AppFormatters.currency,
      ),
      activeClients: _parseKpi(
        json['activeClients'] as Map<String, dynamic>,
        (v) => v.toStringAsFixed(0),
      ),
      averageTicket: _parseKpi(
        json['averageTicket'] as Map<String, dynamic>,
        AppFormatters.currency,
      ),
      goalAchievement: _parseKpi(
        json['goalAchievement'] as Map<String, dynamic>,
        // `value` é fração 0-1 (mesma convenção do Dashboard) — formata como %.
        (v) => '${(v * 100).toStringAsFixed(1)}%',
      ),
      salesTrend: (json['salesTrend'] as List<dynamic>)
          .map((v) => _parseSalesTrendPoint(v as Map<String, dynamic>))
          .toList(),
      topProducts: (json['topProducts'] as List<dynamic>)
          .map((v) => _parseTopProduct(v as Map<String, dynamic>))
          .toList(),
      regionMix: (json['regionMix'] as List<dynamic>)
          .map((v) => _parseRegionMix(v as Map<String, dynamic>))
          .toList(),
      topClients: (json['topClients'] as List<dynamic>)
          .map((v) => _parseTopClient(v as Map<String, dynamic>))
          .toList(),
      insight: json['insight'] == null
          ? null
          : SalesInsight(
              message:
                  (json['insight'] as Map<String, dynamic>)['message']
                      as String,
            ),
    );
  }

  ReportKpi _parseKpi(
    Map<String, dynamic> json,
    String Function(double) formatValue,
  ) {
    return ReportKpi(
      label: json['label'] as String,
      value: formatValue((json['value'] as num).toDouble()),
      growthPercent: (json['growthPercent'] as num).toDouble(),
    );
  }

  SalesTrendPoint _parseSalesTrendPoint(Map<String, dynamic> json) {
    return SalesTrendPoint(
      monthLabel: json['monthLabel'] as String,
      sales: (json['sales'] as num).toDouble(),
      target: (json['target'] as num).toDouble(),
    );
  }

  TopProduct _parseTopProduct(Map<String, dynamic> json) {
    return TopProduct(
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
    );
  }

  RegionMix _parseRegionMix(Map<String, dynamic> json) {
    return RegionMix(
      label: json['label'] as String,
      percent: (json['percent'] as num).toDouble(),
    );
  }

  TopClient _parseTopClient(Map<String, dynamic> json) {
    return TopClient(
      name: json['name'] as String,
      volume: (json['volume'] as num).toDouble(),
      trend: TrendDirection.values.byName(json['trend'] as String),
    );
  }
}
