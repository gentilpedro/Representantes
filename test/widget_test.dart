import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:josapar_representantes/features/auth/domain/entities/app_user.dart';
import 'package:josapar_representantes/features/auth/domain/repositories/auth_repository.dart';
import 'package:josapar_representantes/features/auth/presentation/providers/auth_providers.dart';
import 'package:josapar_representantes/features/auth/presentation/screens/login_screen.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<AppUser?> restoreSession() async => null;

  @override
  Future<AppUser> login({
    required String identifier,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> logout() async {}
}

void main() {
  testWidgets('Login screen shows the main call to action', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
        ],
        child: const MaterialApp(home: LoginScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Acessar Sistema'), findsOneWidget);
    expect(find.text('Representante'), findsOneWidget);
  });
}
