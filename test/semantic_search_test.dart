import 'package:flutter_test/flutter_test.dart';
import 'package:velvet/features/ai_agents/domain/agents.dart';

void main() {
  group('SemanticSearchResponse Parsing Tests', () {
    test('Correct JSON parsing returns terms and category', () {
      const jsonStr = '{"expandedTerms": ["cryptography", "aes", "security"], "inferredCategory": "project"}';
      final response = SemanticSearchResponse.fromJsonString(jsonStr);

      expect(response.expandedTerms, ['cryptography', 'aes', 'security']);
      expect(response.inferredCategory, 'project');
    });

    test('Malformed JSON falls back gracefully', () {
      const jsonStr = '{malformed: true';
      final response = SemanticSearchResponse.fromJsonString(jsonStr);

      expect(response.expandedTerms, isEmpty);
      expect(response.inferredCategory, 'all');
    });

    test('JSON with extra markdown tags parsed successfully', () {
      const jsonStr = '```json\n{"expandedTerms": ["rust", "wasm"], "inferredCategory": "research"}\n```';
      final response = SemanticSearchResponse.fromJsonString(jsonStr);

      expect(response.expandedTerms, ['rust', 'wasm']);
      expect(response.inferredCategory, 'research');
    });
  });
}
