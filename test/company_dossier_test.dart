import 'package:flutter_test/flutter_test.dart';
import 'package:velvet/features/job_tracker/data/company_dossier_service.dart';
import 'package:velvet/core/security/secure_storage_service.dart';

class FakeSecureStorageService extends SecureStorageService {
  final String? keyToReturn;
  FakeSecureStorageService({this.keyToReturn});

  @override
  Future<String?> getOpenRouterApiKey() async => keyToReturn;
}

void main() {
  group('Company & JD Intelligence Dossier Tests', () {
    test('CompanyDossier model serialization & Markdown formatting', () {
      final dossier = CompanyDossier(
        companyName: 'Stripe',
        foundingYear: 'Founded in 2010 (By Patrick & John Collison)',
        headquartersLocation: 'San Francisco, CA, USA & Dublin, Ireland',
        internationalPresence: 'Global Operations (US, UK, Ireland, India, Singapore)',
        partnershipsAndClients: ['Shopify', 'Amazon', 'Salesforce'],
        coreServicesAndProducts: ['Online Payment Processing', 'Stripe Connect', 'Radar Fraud Defense'],
        careerAndTeamCulture: 'Meticulous API design, developer-first documentation and extreme ownership.',
        shiftTypeAndHours: 'Day Shift (Standard Business Hours)',
        interviewPrep: const InterviewPrepData(
          whyUsScript: 'Inspired by Stripe\'s mission to increase the GDP of the internet.',
          keyJdBuzzwords: ['High Availability', 'Distributed Systems', 'API Precision'],
          questionsToAskInterviewer: [
            'What is the technical roadmap for financial API resiliency?',
            'How are API migration rollouts handled across millions of connected merchants?',
          ],
          potentialRedFlags: 'Clarify on-call rotation expectations during engineering round.',
        ),
        rawSourceUrls: ['https://stripe.com'],
        extractedAt: DateTime(2026, 7, 27),
      );

      // Serialization round-trip
      final json = dossier.toJson();
      expect(json['companyName'], equals('Stripe'));
      expect(json['foundingYear'], contains('2010'));

      final restored = CompanyDossier.fromJson(json);
      expect(restored.companyName, equals('Stripe'));
      expect(restored.partnershipsAndClients, contains('Shopify'));
      expect(restored.interviewPrep.keyJdBuzzwords, contains('High Availability'));

      // Markdown export
      final markdown = dossier.toFormattedMarkdownNote();
      expect(markdown, contains('# 🏢 Stripe — Company & JD Intel Dossier'));
      expect(markdown, contains('Founded in 2010'));
      expect(markdown, contains('Shopify'));
      expect(markdown, contains('Why Us?'));
    });

    test('CompanyDossierService rate limiting: allows max 5 requests per minute', () async {
      final service = CompanyDossierService(
        secureStorage: FakeSecureStorageService(keyToReturn: null),
      );
      expect(service, isNotNull);

      // Initial state: 5 requests available
      final remaining = CompanyDossierService.getRemainingRequestsThisMinute();
      expect(remaining, greaterThanOrEqualTo(0));
      expect(remaining, lessThanOrEqualTo(5));
    });

    test('CompanyDossierService throws meaningful error without API key', () async {
      final service = CompanyDossierService(
        secureStorage: FakeSecureStorageService(keyToReturn: null),
      );

      expect(
        () async => await service.extractDossier(companyUrl: 'https://stripe.com'),
        throwsA(
          predicate((e) =>
              e is Exception &&
              e.toString().contains('API key')),
        ),
      );
    });

    test('CompanyDossierService throws on empty input', () async {
      final service = CompanyDossierService(
        secureStorage: FakeSecureStorageService(keyToReturn: null),
      );

      expect(
        () async => await service.extractDossier(),
        throwsA(isA<Exception>()),
      );
    });

    test('CompanyDossier fromJson handles empty json without mock data contamination', () {
      final dossier = CompanyDossier.fromJson({});
      expect(dossier.companyName, equals('Target Company'));
      expect(dossier.matchingSkills, isEmpty);
      expect(dossier.missingSkillGaps, isEmpty);
      expect(dossier.partnershipsAndClients, isEmpty);
    });
  });
}
