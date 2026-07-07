import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:votechain_mobile/app.dart';
import 'package:votechain_mobile/features/authentication/data/mock/mock_auth_repository.dart';
import 'package:votechain_mobile/features/authentication/presentation/providers/auth_providers.dart';

void main() {
  testWidgets('App loads splash then navigates to login', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(MockAuthRepository()),
        ],
        child: const VoteChainApp(),
      ),
    );
    await tester.pump();

    expect(find.text('VoteChain'), findsOneWidget);
    expect(find.text('ESTABLISHING SECURE LINK'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();

    expect(find.text('Welcome Back'), findsOneWidget);
  });
}
