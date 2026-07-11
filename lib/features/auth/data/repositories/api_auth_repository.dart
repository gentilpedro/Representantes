import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/storage/session_storage.dart';
import '../../domain/auth_exception.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Implementação real de [AuthRepository], contra `POST /api/auth/*` da Web
/// API .NET 10.
class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this._apiClient, this._sessionStorage);

  final ApiClient _apiClient;
  final SessionStorage _sessionStorage;

  @override
  Future<AppUser> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/api/auth/login',
        data: {'identifier': identifier, 'password': password},
      );
      return _persistAuthResponse(response.data!);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Código/e-mail ou senha inválidos.');
      }
      throw AuthException('Não foi possível entrar. Tente novamente.');
    }
  }

  @override
  Future<void> logout() => _sessionStorage.clear();

  @override
  Future<AppUser?> restoreSession() async {
    final token = await _sessionStorage.readToken();
    if (token == null) return null;

    final profile = await _sessionStorage.readUserProfile();
    if (profile == null) return null;
    return AppUser.fromJson(profile);
  }

  @override
  Future<String> checkFirstAccess(String identifier) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/api/auth/first-access/check',
        data: {'identifier': identifier},
      );
      return response.data!['name'] as String;
    } on DioException catch (e) {
      throw AuthException(_firstAccessErrorMessage(e));
    }
  }

  @override
  Future<AppUser> activateAccount({
    required String identifier,
    required String password,
  }) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/api/auth/first-access/activate',
        data: {'identifier': identifier, 'password': password},
      );
      return _persistAuthResponse(response.data!);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final requirements =
            (e.response?.data as Map<String, dynamic>?)?['unmetRequirements']
                as List<dynamic>?;
        if (requirements != null && requirements.isNotEmpty) {
          throw AuthException(
            'Senha não atende aos requisitos: ${requirements.join(', ')}.',
          );
        }
      }
      throw AuthException(_firstAccessErrorMessage(e));
    }
  }

  String _firstAccessErrorMessage(DioException e) {
    switch (e.response?.statusCode) {
      case 404:
        return 'Matrícula não encontrada.';
      case 409:
        return 'Esta conta já foi ativada. Faça login.';
      default:
        return 'Não foi possível continuar. Tente novamente.';
    }
  }

  Future<AppUser> _persistAuthResponse(Map<String, dynamic> data) async {
    final token = data['token'] as String;
    final representative = data['representative'] as Map<String, dynamic>;
    final packageInfo = await PackageInfo.fromPlatform();

    final user = AppUser(
      id: representative['id'] as String,
      name: representative['name'] as String,
      role: representative['role'] as String,
      region: representative['region'] as String,
      appVersion: formatAppVersion(packageInfo),
      avatarUrl: representative['avatarUrl'] as String?,
      lastSyncAt: representative['lastSyncAtUtc'] == null
          ? null
          : DateTime.parse(representative['lastSyncAtUtc'] as String),
    );

    await _sessionStorage.saveToken(token);
    await _sessionStorage.saveRepresentativeCode(user.id);
    await _sessionStorage.saveUserProfile(user.toJson());
    return user;
  }
}
