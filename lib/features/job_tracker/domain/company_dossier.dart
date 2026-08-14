import 'package:flutter/foundation.dart';

// ---------- helpers -----------------------------------------------------------

String _asString(dynamic value, String fallback) {
  if (value == null) return fallback;
  if (value is String) return value;
  if (value is List) return value.map((e) => e.toString()).join(', ');
  return value.toString();
}

List<String> _asList(dynamic value, List<String> fallback) {
  if (value == null) return fallback;
  if (value is List) return value.map((e) => e.toString()).toList();
  if (value is String && value.isNotEmpty) {
    return value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }
  return fallback;
}

// ---------- models ------------------------------------------------------------

@immutable
class InterviewPrepData {
  final String whyUsScript;
  final List<String> keyJdBuzzwords;
  final List<String> questionsToAskInterviewer;
  final String potentialRedFlags;
  final List<String> typicalInterviewRounds;
  final List<String> topLeetCodeTopics; // DSA & System Design topics
  final List<String> atsKeywordsToInject; // ATS Resume Optimization keywords

  const InterviewPrepData({
    required this.whyUsScript,
    required this.keyJdBuzzwords,
    required this.questionsToAskInterviewer,
    required this.potentialRedFlags,
    this.typicalInterviewRounds = const [],
    this.topLeetCodeTopics = const [],
    this.atsKeywordsToInject = const [],
  });

  Map<String, dynamic> toJson() => {
        'whyUsScript': whyUsScript,
        'keyJdBuzzwords': keyJdBuzzwords,
        'questionsToAskInterviewer': questionsToAskInterviewer,
        'potentialRedFlags': potentialRedFlags,
        'typicalInterviewRounds': typicalInterviewRounds,
        'topLeetCodeTopics': topLeetCodeTopics,
        'atsKeywordsToInject': atsKeywordsToInject,
      };

  factory InterviewPrepData.fromJson(Map<String, dynamic> json) {
    final whyUs = json['whyUsScript'] ?? json['why_us_script'] ?? json['whyUs'] ?? json['why_us'];
    final buzzwords = json['keyJdBuzzwords'] ?? json['key_jd_buzzwords'] ?? json['buzzwords'] ?? json['keywords'];
    final questions = json['questionsToAskInterviewer'] ?? json['questions_to_ask_interviewer'] ?? json['questions_to_ask'] ?? json['questions'];
    final redFlags = json['potentialRedFlags'] ?? json['potential_red_flags'] ?? json['redFlags'] ?? json['red_flags'];
    final rounds = json['typicalInterviewRounds'] ?? json['typical_interview_rounds'] ?? json['rounds'];
    final leetcode = json['topLeetCodeTopics'] ?? json['top_leetcode_topics'] ?? json['leetcode_topics'] ?? json['topics'];
    final ats = json['atsKeywordsToInject'] ?? json['ats_keywords_to_inject'] ?? json['ats_keywords'] ?? json['atsKeywords'];

    return InterviewPrepData(
      whyUsScript: _asString(whyUs, ''),
      keyJdBuzzwords: _asList(buzzwords, []),
      questionsToAskInterviewer: _asList(questions, []),
      potentialRedFlags: _asString(redFlags, ''),
      typicalInterviewRounds: _asList(rounds, []),
      topLeetCodeTopics: _asList(leetcode, []),
      atsKeywordsToInject: _asList(ats, []),
    );
  }
}

@immutable
class CompanyDossier {
  final String companyName;
  final String foundingYear;
  final String headquartersLocation;
  final String internationalPresence;
  final String companySize;
  final String fundingStatus;
  final String companyStage;
  final List<String> investorsOrBoard;
  final String founderBackground;
  final String salaryBenchmark;
  final String workMode;
  final List<String> techStack;
  final List<String> openSourceProjects;
  final String layoffRiskStatus;
  final String layoffRiskReason;
  final String applyVerdict;                  // Feature 1: Should I Apply? Verdict
  final String applyVerdictReason;            // Feature 1: 1-sentence Rationale
  final int matchScorePercentage;            // Candidate tech stack % match (0-100)
  final List<String> matchingSkills;          // Candidate matching skills
  final List<String> missingSkillGaps;        // Candidate missing skill gaps
  final String esopVestingProjection;        // Feature 2: Indian Startup ESOP Valuation Note
  final String salaryNegotiationScript;      // Tailored counter-offer negotiation email
  final String followUpThankYouEmail;        // Feature 5: Post-Interview Thank You email
  final String followUpStatusCheckEmail;     // Feature 5: 5-Day Status Check-in email
  final String followUpCompetingOfferEmail;  // Feature 5: Competing Offer Leverage email
  final List<String> mockInterviewQuestions;  // 5 specific practice questions
  final List<String> recentHighlights;
  final List<String> partnershipsAndClients;
  final List<String> coreServicesAndProducts;
  final String careerAndTeamCulture;
  final String shiftTypeAndHours;
  final InterviewPrepData interviewPrep;
  final List<String> rawSourceUrls;
  final DateTime extractedAt;

  const CompanyDossier({
    required this.companyName,
    required this.foundingYear,
    required this.headquartersLocation,
    required this.internationalPresence,
    this.companySize = 'Not publicly disclosed',
    this.fundingStatus = 'Not publicly disclosed',
    this.companyStage = 'Not specified',
    this.investorsOrBoard = const [],
    this.founderBackground = 'Not publicly disclosed',
    this.salaryBenchmark = 'Not publicly disclosed',
    this.workMode = 'Not specified',
    this.techStack = const [],
    this.openSourceProjects = const [],
    this.layoffRiskStatus = 'Low Risk (Active Hiring)',
    this.layoffRiskReason = 'No negative layoff signals found in public sources.',
    this.applyVerdict = 'Strong Apply',
    this.applyVerdictReason = 'Positive company signals and active engineering team growth.',
    this.matchScorePercentage = 0,
    this.matchingSkills = const [],
    this.missingSkillGaps = const [],
    this.esopVestingProjection = '',
    this.salaryNegotiationScript = '',
    this.followUpThankYouEmail = '',
    this.followUpStatusCheckEmail = '',
    this.followUpCompetingOfferEmail = '',
    this.mockInterviewQuestions = const [],
    this.recentHighlights = const [],
    this.partnershipsAndClients = const [],
    this.coreServicesAndProducts = const [],
    this.careerAndTeamCulture = 'Not specified in public sources',
    this.shiftTypeAndHours = 'Not specified in public sources',
    required this.interviewPrep,
    required this.rawSourceUrls,
    required this.extractedAt,
  });

  Map<String, dynamic> toJson() => {
        'companyName': companyName,
        'foundingYear': foundingYear,
        'headquartersLocation': headquartersLocation,
        'internationalPresence': internationalPresence,
        'companySize': companySize,
        'fundingStatus': fundingStatus,
        'companyStage': companyStage,
        'investorsOrBoard': investorsOrBoard,
        'founderBackground': founderBackground,
        'salaryBenchmark': salaryBenchmark,
        'workMode': workMode,
        'techStack': techStack,
        'openSourceProjects': openSourceProjects,
        'layoffRiskStatus': layoffRiskStatus,
        'layoffRiskReason': layoffRiskReason,
        'applyVerdict': applyVerdict,
        'applyVerdictReason': applyVerdictReason,
        'matchScorePercentage': matchScorePercentage,
        'matchingSkills': matchingSkills,
        'missingSkillGaps': missingSkillGaps,
        'esopVestingProjection': esopVestingProjection,
        'salaryNegotiationScript': salaryNegotiationScript,
        'followUpThankYouEmail': followUpThankYouEmail,
        'followUpStatusCheckEmail': followUpStatusCheckEmail,
        'followUpCompetingOfferEmail': followUpCompetingOfferEmail,
        'mockInterviewQuestions': mockInterviewQuestions,
        'recentHighlights': recentHighlights,
        'partnershipsAndClients': partnershipsAndClients,
        'coreServicesAndProducts': coreServicesAndProducts,
        'careerAndTeamCulture': careerAndTeamCulture,
        'shiftTypeAndHours': shiftTypeAndHours,
        'interviewPrep': interviewPrep.toJson(),
        'rawSourceUrls': rawSourceUrls,
        'extractedAt': extractedAt.toIso8601String(),
      };

  factory CompanyDossier.fromJson(Map<String, dynamic> json) {
    final compName = _asString(json['companyName'] ?? json['company_name'], 'Target Company');

    InterviewPrepData prep;
    final prepRaw = json['interviewPrep'] ?? json['interview_prep'];
    if (prepRaw is Map<String, dynamic>) {
      prep = InterviewPrepData.fromJson(prepRaw);
    } else {
      prep = const InterviewPrepData(
        whyUsScript: '',
        keyJdBuzzwords: [],
        questionsToAskInterviewer: [],
        potentialRedFlags: '',
        typicalInterviewRounds: [],
        topLeetCodeTopics: [],
        atsKeywordsToInject: [],
      );
    }

    DateTime parsedDate;
    try {
      final dateVal = json['extractedAt'] ?? json['extracted_at'];
      parsedDate = dateVal != null ? DateTime.parse(dateVal.toString()) : DateTime.now();
    } catch (_) {
      parsedDate = DateTime.now();
    }

    final matchingSkillsList = _asList(json['matchingSkills'] ?? json['matching_skills'], []);
    final missingSkillsList = _asList(json['missingSkillGaps'] ?? json['missing_skill_gaps'], []);

    int matchPct = 0;
    if (matchingSkillsList.isNotEmpty || missingSkillsList.isNotEmpty) {
      final matchVal = json['matchScorePercentage'] ?? json['match_score_percentage'] ?? json['matchScore'];
      if (matchVal != null) {
        matchPct = int.tryParse(matchVal.toString()) ?? 0;
      }
    }

    final rawMockQs = json['mockInterviewQuestions'] ?? json['mock_interview_questions'] ?? json['interview_questions'];
    final mockQs = _asList(rawMockQs, []);

    final rawScript = json['salaryNegotiationScript'] ?? json['salary_negotiation_script'] ?? json['negotiation_script'];
    final negotiationScript = _asString(rawScript, '');

    final thankYou = json['followUpThankYouEmail'] ?? json['follow_up_thank_you_email'] ?? json['thank_you_email'];
    final statusCheck = json['followUpStatusCheckEmail'] ?? json['follow_up_status_check_email'] ?? json['status_check_email'];
    final competingOffer = json['followUpCompetingOfferEmail'] ?? json['follow_up_competing_offer_email'] ?? json['competing_offer_email'];

    return CompanyDossier(
      companyName: compName,
      foundingYear: _asString(json['foundingYear'] ?? json['founding_year'], 'Not publicly disclosed'),
      headquartersLocation: _asString(json['headquartersLocation'] ?? json['headquarters_location'] ?? json['headquarters'], 'Not publicly disclosed'),
      internationalPresence: _asString(json['internationalPresence'] ?? json['international_presence'], 'Not publicly disclosed'),
      companySize: _asString(json['companySize'] ?? json['company_size'], 'Not publicly disclosed'),
      fundingStatus: _asString(json['fundingStatus'] ?? json['funding_status'], 'Not publicly disclosed'),
      companyStage: _asString(json['companyStage'] ?? json['company_stage'], 'Not specified'),
      investorsOrBoard: _asList(json['investorsOrBoard'] ?? json['investors_or_board'] ?? json['investors'], []),
      founderBackground: _asString(json['founderBackground'] ?? json['founder_background'], 'Not publicly disclosed'),
      salaryBenchmark: _asString(json['salaryBenchmark'] ?? json['salary_benchmark'], 'Not publicly disclosed'),
      workMode: _asString(json['workMode'] ?? json['work_mode'], 'Not specified'),
      techStack: _asList(json['techStack'] ?? json['tech_stack'], []),
      openSourceProjects: _asList(json['openSourceProjects'] ?? json['open_source_projects'], []),
      layoffRiskStatus: _asString(json['layoffRiskStatus'] ?? json['layoff_risk_status'], 'Low Risk (Active Hiring)'),
      layoffRiskReason: _asString(json['layoffRiskReason'] ?? json['layoff_risk_reason'], 'No negative layoff signals found in public sources.'),
      applyVerdict: _asString(json['applyVerdict'] ?? json['apply_verdict'], 'Strong Apply'),
      applyVerdictReason: _asString(json['applyVerdictReason'] ?? json['apply_verdict_reason'], 'Positive headcount signals and engineering growth.'),
      matchScorePercentage: matchPct,
      matchingSkills: matchingSkillsList,
      missingSkillGaps: missingSkillsList,
      esopVestingProjection: _asString(json['esopVestingProjection'] ?? json['esop_vesting_projection'], ''),
      salaryNegotiationScript: negotiationScript,
      followUpThankYouEmail: _asString(thankYou, ''),
      followUpStatusCheckEmail: _asString(statusCheck, ''),
      followUpCompetingOfferEmail: _asString(competingOffer, ''),
      mockInterviewQuestions: mockQs,
      recentHighlights: _asList(json['recentHighlights'] ?? json['recent_highlights'], []),
      partnershipsAndClients: _asList(json['partnershipsAndClients'] ?? json['partnerships_and_clients'], []),
      coreServicesAndProducts: _asList(json['coreServicesAndProducts'] ?? json['core_services_and_products'], []),
      careerAndTeamCulture: _asString(json['careerAndTeamCulture'] ?? json['career_and_team_culture'] ?? json['culture'], 'Not specified in public sources'),
      shiftTypeAndHours: _asString(json['shiftTypeAndHours'] ?? json['shift_type_and_hours'] ?? json['shift'], 'Not specified in public sources'),
      interviewPrep: prep,
      rawSourceUrls: _asList(json['rawSourceUrls'] ?? json['raw_source_urls'], []),
      extractedAt: parsedDate,
    );
  }

  String toFormattedMarkdownNote() {
    final buffer = StringBuffer();
    buffer.writeln('# 🏢 $companyName — Company & JD Intel Dossier');
    buffer.writeln('*Extracted: ${extractedAt.year}-${extractedAt.month.toString().padLeft(2, '0')}-${extractedAt.day.toString().padLeft(2, '0')}*');
    buffer.writeln();
    buffer.writeln('## 📌 Company Overview');
    buffer.writeln('- **Founded**: $foundingYear');
    buffer.writeln('- **Headquarters**: $headquartersLocation');
    buffer.writeln('- **Global Presence**: $internationalPresence');
    buffer.writeln('- **Company Size**: $companySize');
    buffer.writeln('- **Funding / Status**: $fundingStatus');
    buffer.writeln('- **Work Mode**: $workMode');
    buffer.writeln();
    if (recentHighlights.isNotEmpty) {
      buffer.writeln('## 📰 Recent Highlights');
      for (final h in recentHighlights) {
        buffer.writeln('- $h');
      }
      buffer.writeln();
    }
    buffer.writeln('## 🛠️ Core Services & Products');
    for (final service in coreServicesAndProducts) {
      buffer.writeln('- $service');
    }
    buffer.writeln();
    if (techStack.isNotEmpty) {
      buffer.writeln('## ⚙️ Tech Stack');
      for (final t in techStack) {
        buffer.writeln('- $t');
      }
      buffer.writeln();
    }
    buffer.writeln('## 🤝 Partnerships & Key Clients');
    for (final partner in partnershipsAndClients) {
      buffer.writeln('- $partner');
    }
    buffer.writeln();
    buffer.writeln('## ⏰ Shift & Work Culture');
    buffer.writeln('- **Shift Schedule**: $shiftTypeAndHours');
    buffer.writeln('- **Team Culture**: $careerAndTeamCulture');
    buffer.writeln();
    buffer.writeln('## 🎯 Interview Cheat Sheet');
    buffer.writeln('### "Why Us?" Script');
    buffer.writeln('> ${interviewPrep.whyUsScript}');
    buffer.writeln();
    buffer.writeln('### Key JD Buzzwords');
    for (final word in interviewPrep.keyJdBuzzwords) {
      buffer.writeln('- `$word`');
    }
    buffer.writeln();
    if (interviewPrep.typicalInterviewRounds.isNotEmpty) {
      buffer.writeln('### Interview Rounds');
      for (final r in interviewPrep.typicalInterviewRounds) {
        buffer.writeln('- $r');
      }
      buffer.writeln();
    }
    buffer.writeln('### Smart Questions to Ask');
    for (final q in interviewPrep.questionsToAskInterviewer) {
      buffer.writeln('1. $q');
    }
    if (interviewPrep.potentialRedFlags.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('### ⚠️ Watchouts');
      buffer.writeln('- ${interviewPrep.potentialRedFlags}');
    }
    buffer.writeln();
    buffer.writeln('---');
    buffer.writeln('*⚖️ **Legal & Public Data Disclaimer**: Information in this dossier is automatically synthesized from publicly accessible web sources and AI models for interview preparation and research purposes only. Pariyojana does not verify entity authenticity and assumes no liability for recruitment scams, false postings, or third-party offer activities. Always verify employer credentials independently through official corporate channels.*');
    return buffer.toString();
  }
}
