import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:miro_hybrid/main.dart';
import 'package:miro_hybrid/features/energy/widgets/quest_bar.dart';
import 'package:miro_hybrid/features/energy/widgets/claim_button.dart';
import 'package:miro_hybrid/core/services/device_id_service.dart';

/// Quest Bar Integration Tests
/// 
/// Tests ทั้งหมดสำหรับ Quest Bar functionality:
/// - Offer display with countdown
/// - Swipe to dismiss
/// - Claim button interaction
/// - Multiple offers priority
/// - Streak mode display

void main() {
  group('Quest Bar Integration Tests', () {
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
      // Mock DeviceIdService
      DeviceIdService.deviceId = 'test-device-id';
    });

    tearDown(() {
      mockClient.close();
    });

    /// Helper: Mock user with active offer
    Future<void> mockUserWithOffer(
      String offerType, {
      Duration expiry = const Duration(hours: 4),
    }) async {
      final expiryTimestamp = DateTime.now().add(expiry).millisecondsSinceEpoch ~/ 1000;
      
      when(mockClient.post(
        Uri.parse('https://us-central1-miro-d6856.cloudfunctions.net/getActiveOffersEndpoint'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(
        jsonEncode({
          'success': true,
          'offers': [
            {
              'id': offerType,
              'type': offerType,
              'title': '🔥 200E แค่ \$1!',
              'subtitle': 'First purchase special',
              'priority': 1,
              'expiry': {
                '_seconds': expiryTimestamp,
              },
              'remainingSeconds': expiry.inSeconds,
            }
          ],
        }),
        200,
      ));
    }

    /// Helper: Mock user can claim daily energy
    Future<void> mockUserCanClaim({int energy = 1}) async {
      when(mockClient.post(
        Uri.parse('https://us-central1-miro-d6856.cloudfunctions.net/syncBalance'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(
        jsonEncode({
          'success': true,
          'canClaimToday': true,
          'tier': energy == 1 ? 'starter' : energy == 2 ? 'silver' : 'gold',
          'balance': 100,
        }),
        200,
      ));
    }

    testWidgets('Quest Bar displays active offer when available', (WidgetTester tester) async {
      // Arrange
      await mockUserWithOffer('first_purchase', expiry: const Duration(hours: 4));
      
      // Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: QuestBar()),
        ),
      );
      await tester.pumpAndSettle();
      
      // Assert
      expect(find.text('🔥 200E แค่ \$1!'), findsOneWidget);
      expect(find.textContaining('⏰'), findsOneWidget);
    });

    testWidgets('Countdown timer updates correctly', (WidgetTester tester) async {
      // Arrange
      await mockUserWithOffer('first_purchase', expiry: const Duration(seconds: 10));
      
      // Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: QuestBar()),
        ),
      );
      await tester.pumpAndSettle();
      
      // Initial state
      expect(find.textContaining('00:00:10'), findsOneWidget);
      
      // Wait 1 second
      await tester.pump(const Duration(seconds: 1));
      
      // Assert: Time should decrease
      expect(find.textContaining('00:00:09'), findsOneWidget);
      
      // Wait until expiry
      await tester.pump(const Duration(seconds: 9));
      await tester.pumpAndSettle();
      
      // Assert: Offer should disappear, Streak mode should show
      expect(find.text('🔥 200E แค่ \$1!'), findsNothing);
      expect(find.textContaining('Streak'), findsOneWidget);
    });

    testWidgets('Swipe left dismisses offer and shows Snackbar', (WidgetTester tester) async {
      // Arrange
      await mockUserWithOffer('first_purchase');
      
      // Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: QuestBar())),
        ),
      );
      await tester.pumpAndSettle();
      
      // Find offer text
      final offerFinder = find.text('🔥 200E แค่ \$1!');
      expect(offerFinder, findsOneWidget);
      
      // Swipe left
      await tester.drag(offerFinder, const Offset(-300, 0));
      await tester.pumpAndSettle();
      
      // Assert: offer hidden + Snackbar shown
      expect(find.text('🔥 200E แค่ \$1!'), findsNothing);
      expect(find.text('Offer ถูกซ่อน'), findsOneWidget);
      expect(find.text('ดู Offer'), findsOneWidget);
    });

    testWidgets('Undo button restores dismissed offer', (WidgetTester tester) async {
      // Arrange
      await mockUserWithOffer('first_purchase');
      
      // Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: QuestBar())),
        ),
      );
      await tester.pumpAndSettle();
      
      // Swipe to dismiss
      await tester.drag(find.text('🔥 200E แค่ \$1!'), const Offset(-300, 0));
      await tester.pumpAndSettle();
      
      // Tap "Undo" button
      await tester.tap(find.text('ดู Offer'));
      await tester.pumpAndSettle();
      
      // Assert: offer should reappear
      expect(find.text('🔥 200E แค่ \$1!'), findsOneWidget);
    });

    testWidgets('Claim button calls API and shows confetti', (WidgetTester tester) async {
      // Arrange
      await mockUserCanClaim(energy: 2);
      
      when(mockClient.post(
        Uri.parse('https://us-central1-miro-d6856.cloudfunctions.net/claimDailyEnergy'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(
        jsonEncode({
          'success': true,
          'energy': 2,
          'newBalance': 102,
          'tier': 'silver',
        }),
        200,
      ));
      
      // Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: QuestBar())),
        ),
      );
      await tester.pumpAndSettle();
      
      // Find and tap claim button
      final claimButton = find.text('+2E');
      expect(claimButton, findsOneWidget);
      
      await tester.tap(claimButton);
      await tester.pump();
      
      // Assert: loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      await tester.pumpAndSettle();
      
      // Assert: confetti + success message
      expect(find.byType(ConfettiWidget), findsOneWidget);
      expect(find.textContaining('ได้รับ +2E'), findsOneWidget);
    });

    testWidgets('Quest Bar shows highest priority offer first', (WidgetTester tester) async {
      // Arrange: Mock multiple offers
      when(mockClient.post(
        Uri.parse('https://us-central1-miro-d6856.cloudfunctions.net/getActiveOffersEndpoint'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(
        jsonEncode({
          'success': true,
          'offers': [
            {
              'id': 'tier_promo',
              'type': 'tier_promo',
              'title': '🎁 Tier Promo',
              'priority': 3,
            },
            {
              'id': 'first_purchase',
              'type': 'first_purchase',
              'title': '🔥 200E แค่ \$1!',
              'priority': 1,
            },
            {
              'id': 'bonus_40',
              'type': 'bonus_40',
              'title': '💰 40% Bonus',
              'priority': 2,
            },
          ],
        }),
        200,
      ));
      
      // Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: QuestBar())),
        ),
      );
      await tester.pumpAndSettle();
      
      // Assert: first_purchase (priority 1) should be shown
      expect(find.text('🔥 200E แค่ \$1!'), findsOneWidget);
      expect(find.text('💰 40% Bonus'), findsNothing);
      
      // Swipe to dismiss first offer
      await tester.drag(find.text('🔥 200E แค่ \$1!'), const Offset(-300, 0));
      await tester.pumpAndSettle();
      
      // Assert: bonus_40 (priority 2) should now be shown
      expect(find.text('💰 40% Bonus'), findsOneWidget);
    });

    testWidgets('Quest Bar shows Streak mode when no offers', (WidgetTester tester) async {
      // Arrange: Mock no offers
      when(mockClient.post(
        Uri.parse('https://us-central1-miro-d6856.cloudfunctions.net/getActiveOffersEndpoint'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(
        jsonEncode({
          'success': true,
          'offers': [],
        }),
        200,
      ));
      
      await mockUserCanClaim(energy: 1);
      
      // Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: QuestBar()),
        ),
      );
      await tester.pumpAndSettle();
      
      // Assert: Streak mode should be shown
      expect(find.textContaining('Streak'), findsOneWidget);
      expect(find.byType(ClaimButton), findsOneWidget);
    });

    testWidgets('Quest Bar handles API errors gracefully', (WidgetTester tester) async {
      // Arrange: Mock API error
      when(mockClient.post(
        Uri.parse('https://us-central1-miro-d6856.cloudfunctions.net/getActiveOffersEndpoint'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(
        jsonEncode({'success': false, 'error': 'Server error'}),
        500,
      ));
      
      // Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: QuestBar()),
        ),
      );
      await tester.pumpAndSettle();
      
      // Assert: Should show Streak mode as fallback (not crash)
      expect(find.textContaining('Streak'), findsOneWidget);
    });

    testWidgets('Quest Bar handles offline mode', (WidgetTester tester) async {
      // Arrange: Mock network error
      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenThrow(const SocketException('No internet'));
      
      // Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: QuestBar()),
        ),
      );
      await tester.pumpAndSettle();
      
      // Assert: Should show Streak mode as fallback
      expect(find.textContaining('Streak'), findsOneWidget);
    });

    testWidgets('Claim button is disabled after claim', (WidgetTester tester) async {
      // Arrange
      await mockUserCanClaim(energy: 1);
      
      when(mockClient.post(
        Uri.parse('https://us-central1-miro-d6856.cloudfunctions.net/claimDailyEnergy'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(
        jsonEncode({
          'success': true,
          'energy': 1,
          'newBalance': 101,
        }),
        200,
      ));
      
      // Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: QuestBar())),
        ),
      );
      await tester.pumpAndSettle();
      
      // Tap claim button
      await tester.tap(find.text('+1E'));
      await tester.pumpAndSettle();
      
      // Assert: button should be disabled (opacity reduced)
      final claimButton = find.byType(ClaimButton);
      final opacity = tester.widget<Opacity>(find.ancestor(
        of: claimButton,
        matching: find.byType(Opacity),
      ));
      expect(opacity.opacity, lessThan(1.0));
    });

    testWidgets('Quest Bar displays correct tier progress', (WidgetTester tester) async {
      // Arrange
      await mockUserCanClaim(energy: 2); // Silver tier (2E)
      
      when(mockClient.post(
        Uri.parse('https://us-central1-miro-d6856.cloudfunctions.net/syncBalance'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(
        jsonEncode({
          'success': true,
          'tier': 'silver',
          'currentStreak': 10,
          'daysToNextTier': 4, // 14 - 10 = 4 days to Gold
        }),
        200,
      ));
      
      // Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: QuestBar()),
        ),
      );
      await tester.pumpAndSettle();
      
      // Assert: Should show tier progress
      expect(find.textContaining('4 วัน → Gold'), findsOneWidget);
    });
  });
}

/// Mock HTTP Client for testing
class MockClient extends Mock implements http.Client {}

/// Mock ConfettiWidget
class ConfettiWidget extends StatelessWidget {
  const ConfettiWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

/// Mock SocketException
class SocketException implements Exception {
  final String message;
  const SocketException(this.message);
}
