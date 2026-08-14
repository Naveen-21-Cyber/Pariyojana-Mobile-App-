import 'package:flutter_test/flutter_test.dart';
import 'package:velvet/features/ai_agents/domain/agent_gateway.dart';
import 'package:velvet/features/ai_agents/domain/agents.dart';
import 'package:velvet/core/security/secure_storage_service.dart';
import 'package:flutter/services.dart';
import 'package:velvet/features/ai_agents/presentation/screens/mitnick_chat_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    AgentGateway.resetThrottle();
    const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (methodCall) async {
        return null;
      },
    );
  });

  group('Phase 6 - AI Agent System Tests', () {
    test('AgentGateway handles rapid queries smoothly and uses cache', () async {
      final secureStorage = SecureStorageService();
      final gateway = AgentGateway(secureStorage: secureStorage);

      final res1 = await gateway.dispatchPrompt('Test triage question');
      expect(res1.isNotEmpty, true);

      final res2 = await gateway.dispatchPrompt('Test triage question');
      expect(res2, res1);
    });

    test('TriageAgent correctly parses category and tags', () async {
      AgentGateway.resetThrottle();
      final secureStorage = SecureStorageService();
      final gateway = AgentGateway(secureStorage: secureStorage);
      final agent = TriageAgent(gateway);

      final result = await agent.triage('Read security paper on elliptic curve signatures');
      expect(result.category, 'Research');
      expect(result.tags.contains('cryptography'), true);
    });

    test('ResearchAgent separates summary and gaps correctly', () async {
      AgentGateway.resetThrottle();
      final secureStorage = SecureStorageService();
      final gateway = AgentGateway(secureStorage: secureStorage);
      final agent = ResearchAgent(gateway);

      final result = await agent.analyzeAbstract('Title', 'This paper explores advanced asymmetric cryptographic primitives in constrained hardware environments.');
      expect(result.summary.toLowerCase().contains('explores advanced asymmetric'), true);
      expect(result.gaps.isNotEmpty, true);
    });

    test('StaleItemAgent and RecommenderAgent generate advice', () async {
      AgentGateway.resetThrottle();
      final secureStorage = SecureStorageService();
      final gateway = AgentGateway(secureStorage: secureStorage);
      
      final staleAgent = StaleItemAgent(gateway);
      final reminder = await staleAgent.generateReminder(name: 'Project A', daysInactive: 9);
      expect(reminder.isNotEmpty, true);

      AgentGateway.resetThrottle();
      final recommenderAgent = RecommenderAgent(gateway);
      final recommendation = await recommenderAgent.getWorkspaceRecommendation('Workspace state');
      expect(recommendation.isNotEmpty, true);
    });

    test('MitnickChatNotifier initializes and handles conversation flow', () async {
      final secureStorage = SecureStorageService();
      final gateway = AgentGateway(secureStorage: secureStorage);
      final notifier = MitnickChatNotifier(gateway);

      // Verify initial system prompt is loaded
      expect(notifier.state.length, 1);
      expect(notifier.state.first.isUser, false);
      expect(notifier.state.first.text.contains('Kevin Mitnick'), true);

      // Send a user message
      await notifier.sendMessage('Hello Kevin, can you check my firewall?');
      
      // Should have user message + AI response (mock response under tests)
      expect(notifier.state.length, 3);
      expect(notifier.state[1].isUser, true);
      expect(notifier.state[2].isUser, false);
      expect(notifier.state[2].text.isNotEmpty, true);
    });
  });
}
