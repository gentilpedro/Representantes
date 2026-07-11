import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/lead.dart';
import '../../domain/leads_exception.dart';
import '../../domain/repositories/leads_repository.dart';

/// Implementação real de [LeadsRepository], contra `GET/POST /api/leads` e
/// `GET/PATCH /api/leads/{id}` da Web API .NET 10. Leitura (lista e
/// detalhe) cacheia no [AppDatabase]; criar/atualizar lead ainda exige
/// conexão.
class ApiLeadsRepository implements LeadsRepository {
  ApiLeadsRepository(this._apiClient, this._db);

  static const _listCacheKey = 'leads';

  final ApiClient _apiClient;
  final AppDatabase _db;

  String _detailCacheKey(String id) => 'lead:$id';

  @override
  Future<List<Lead>> fetchLeads() async {
    try {
      final response = await _apiClient.dio.get<List<dynamic>>('/api/leads');
      await _db.upsertJsonCache(_listCacheKey, jsonEncode(response.data));
      return response.data!
          .map((json) => _leadFromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final cached = await _db.fetchJsonCache(_listCacheKey);
      if (cached != null) {
        return (jsonDecode(cached) as List<dynamic>)
            .map((json) => _leadFromJson(json as Map<String, dynamic>))
            .toList();
      }
      throw LeadsException(_errorMessage(e));
    }
  }

  @override
  Future<Lead> fetchLead(String id) async {
    final cacheKey = _detailCacheKey(id);
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/api/leads/$id',
      );
      await _db.upsertJsonCache(cacheKey, jsonEncode(response.data));
      return _leadFromJson(response.data!);
    } on DioException catch (e) {
      final cached = await _db.fetchJsonCache(cacheKey);
      if (cached != null) {
        return _leadFromJson(jsonDecode(cached) as Map<String, dynamic>);
      }
      throw LeadsException(_errorMessage(e));
    }
  }

  @override
  Future<Lead> createLead({
    required String contactName,
    required String companyName,
    String? cnpj,
    required String phone,
    String? email,
    String? source,
    String? notes,
  }) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/api/leads',
        data: {
          'contactName': contactName,
          'companyName': companyName,
          'cnpj': cnpj,
          'phone': phone,
          'email': email,
          'source': source,
          'notes': notes,
        },
      );
      return _leadFromJson(response.data!);
    } on DioException catch (e) {
      throw LeadsException(_errorMessage(e));
    }
  }

  @override
  Future<Lead> updateLead({
    required String id,
    required String contactName,
    required String companyName,
    String? cnpj,
    required String phone,
    String? email,
    required LeadStatus status,
    String? source,
    String? notes,
    DateTime? lastContactAtUtc,
  }) async {
    try {
      final response = await _apiClient.dio.patch<Map<String, dynamic>>(
        '/api/leads/$id',
        data: {
          'contactName': contactName,
          'companyName': companyName,
          'cnpj': cnpj,
          'phone': phone,
          'email': email,
          'status': _statusToJson(status),
          'source': source,
          'notes': notes,
          'lastContactAtUtc': lastContactAtUtc?.toUtc().toIso8601String(),
        },
      );
      return _leadFromJson(response.data!);
    } on DioException catch (e) {
      throw LeadsException(_errorMessage(e));
    }
  }

  String _errorMessage(DioException e) {
    if (e.response?.statusCode == 404) return 'Lead não encontrado.';
    return 'Não foi possível carregar os leads. Tente novamente.';
  }

  Lead _leadFromJson(Map<String, dynamic> json) {
    final lastContactAtUtc = json['lastContactAtUtc'] as String?;
    return Lead(
      id: json['id'] as String,
      contactName: json['contactName'] as String,
      companyName: json['companyName'] as String,
      cnpj: json['cnpj'] as String?,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      status: _statusFromJson(json['status'] as String),
      source: json['source'] as String?,
      notes: json['notes'] as String?,
      createdAtUtc: DateTime.parse(json['createdAtUtc'] as String),
      lastContactAtUtc: lastContactAtUtc == null
          ? null
          : DateTime.parse(lastContactAtUtc),
    );
  }

  // `new` é palavra reservada em Dart — o enum usa `new_`, então o
  // mapeamento pro JSON da API ("new") precisa ser manual nos dois
  // sentidos (não dá pra usar `.name`/`.byName` direto).
  LeadStatus _statusFromJson(String value) {
    switch (value) {
      case 'new':
        return LeadStatus.new_;
      case 'contacted':
        return LeadStatus.contacted;
      case 'qualified':
        return LeadStatus.qualified;
      case 'converted':
        return LeadStatus.converted;
      case 'lost':
        return LeadStatus.lost;
      default:
        throw LeadsException('Status de lead desconhecido: $value');
    }
  }

  String _statusToJson(LeadStatus status) {
    switch (status) {
      case LeadStatus.new_:
        return 'new';
      case LeadStatus.contacted:
        return 'contacted';
      case LeadStatus.qualified:
        return 'qualified';
      case LeadStatus.converted:
        return 'converted';
      case LeadStatus.lost:
        return 'lost';
    }
  }
}
