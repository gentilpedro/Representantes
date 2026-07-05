import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:josapar_representantes/core/theme/app_theme.dart';
import 'package:josapar_representantes/features/auth/presentation/providers/auth_providers.dart';
import 'package:josapar_representantes/features/auth/presentation/screens/login_screen.dart';

import 'fakes/fake_auth_repository.dart';

void main() {
  testWidgets('Login screen shows the main call to action', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(
            FakeAuthRepository.loggedOut(),
          ),
        ],
        child: MaterialApp(theme: AppTheme.light(), home: const LoginScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Acessar Sistema'), findsOneWidget);
    expect(find.text('Representante'), findsOneWidget);
  });
}
