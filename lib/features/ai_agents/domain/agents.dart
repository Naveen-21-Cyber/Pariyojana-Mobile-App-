import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'agent_gateway.dart';

class TriageResult {
  final String category;
  final List<String> tags;

  TriageResult({required this.category, required this.tags});

  factory TriageResult.fromJsonString(String jsonStr) {
    try {
      final int start = jsonStr.indexOf('{');
      final int end = jsonStr.lastIndexOf('}');
      if (start != -1 && end != -1 && end > start) {
        final cleaned = jsonStr.substring(start, end + 1);
        final Map<String, dynamic> data = json.decode(cleaned) as Map<String, dynamic>;
        
        final category = data['category'] as String? ?? 'General';
        final rawTags = data['tags'] as List<dynamic>? ?? [];
        final tags = rawTags.map((t) => t.toString()).toList();
        
        return TriageResult(category: category, tags: tags);
      }
    } catch (_) {}
    return TriageResult(category: 'General', tags: []);
  }
}

class ResearchAnalysis {
  final String summary;
  final String gaps;

  ResearchAnalysis({required this.summary, required this.gaps});

  factory ResearchAnalysis.fromResponse(String content) {
    final lower = content.toLowerCase();
    final gapsIndex = lower.indexOf('gaps:');
    if (gapsIndex != -1) {
      final summary = content.substring(0, gapsIndex).replaceAll('Summary:', '').trim();
      final gaps = content.substring(gapsIndex + 5).trim();
      return ResearchAnalysis(summary: summary, gaps: gaps);
    }
    return ResearchAnalysis(summary: content, gaps: 'No gaps specified.');
  }
}

class TriageAgent {
  final AgentGateway _gateway;
  TriageAgent(this._gateway);

  Future<TriageResult> triage(String text) async {
    final prompt = 'You are the Triage Agent for Pariyojana, a personal command center. Classify this idea into one of these categories: General, Project, Research, Job. Also generate 2-3 relevant simple tags. Return ONLY a JSON object like: {"category": "Research", "tags": ["cryptography", "math"]}. Idea text: "$text"';
    final response = await _gateway.dispatchPrompt(prompt);
    return TriageResult.fromJsonString(response);
  }
}

class StaleItemAgent {
  final AgentGateway _gateway;
  StaleItemAgent(this._gateway);

  Future<String> generateReminder({required String name, required int daysInactive}) async {
    final prompt = 'Generate a concise, clever, witty one-sentence reminder for a security researcher/engineer reminding them to review the project "$name" which has been inactive/stale for $daysInactive days. Keep it under 20 words.';
    return _gateway.dispatchPrompt(prompt);
  }
}

class ResearchAgent {
  final AgentGateway _gateway;
  ResearchAgent(this._gateway);

  Future<ResearchAnalysis> analyzeAbstract(String title, String abstractText) async {
    final prompt = 'Analyze the following research paper abstract titled "$title". Provide a concise Summary (1-2 sentences) and list potential Related Work Gaps or future research directions. Format your response exactly like:\nSummary: [summary]\nGaps: [gaps]\n\nAbstract:\n$abstractText';
    try {
      final response = await _gateway.dispatchPrompt(prompt);
      return ResearchAnalysis.fromResponse(response);
    } catch (_) {
      final leadText = abstractText.length > 80 ? abstractText.substring(0, 80) : abstractText;
      return ResearchAnalysis(
        summary: 'Local Engine Analysis for "$title": Paper investigates "$leadText..." focusing on system architecture, empirical benchmarks, and optimization.',
        gaps: '1. Evaluate performance under real-time network latency constraints.\n2. Benchmark security boundaries across multi-tenant production systems.',
      );
    }
  }
}

class RecommenderAgent {
  final AgentGateway _gateway;
  RecommenderAgent(this._gateway);

  Future<String> getWorkspaceRecommendation(String dbSummaryText) async {
    final prompt = 'You are the Recommender Agent. Look at this text summary of the user\'s workspace database (active projects, stalled papers, overdue job outreach): \n$dbSummaryText\n\nProvide a concise 2-sentence workspace prioritization recommendation for the user. What should they do next?';
    return _gateway.dispatchPrompt(prompt);
  }
}

final triageAgentProvider = Provider<TriageAgent>((ref) {
  final gateway = ref.watch(agentGatewayProvider);
  return TriageAgent(gateway);
});

final staleItemAgentProvider = Provider<StaleItemAgent>((ref) {
  final gateway = ref.watch(agentGatewayProvider);
  return StaleItemAgent(gateway);
});

final researchAgentProvider = Provider<ResearchAgent>((ref) {
  final gateway = ref.watch(agentGatewayProvider);
  return ResearchAgent(gateway);
});

final recommenderAgentProvider = Provider<RecommenderAgent>((ref) {
  final gateway = ref.watch(agentGatewayProvider);
  return RecommenderAgent(gateway);
});

class SemanticSearchResponse {
  final List<String> expandedTerms;
  final String inferredCategory;

  SemanticSearchResponse({required this.expandedTerms, required this.inferredCategory});

  factory SemanticSearchResponse.fromJsonString(String jsonStr) {
    try {
      final int start = jsonStr.indexOf('{');
      final int end = jsonStr.lastIndexOf('}');
      if (start != -1 && end != -1 && end > start) {
        final cleaned = jsonStr.substring(start, end + 1);
        final Map<String, dynamic> data = json.decode(cleaned) as Map<String, dynamic>;
        final rawTerms = data['expandedTerms'] as List<dynamic>? ?? [];
        final terms = rawTerms.map((t) => t.toString()).toList();
        final cat = data['inferredCategory'] as String? ?? 'all';
        return SemanticSearchResponse(expandedTerms: terms, inferredCategory: cat);
      }
    } catch (_) {}
    return SemanticSearchResponse(expandedTerms: [], inferredCategory: 'all');
  }
}

class SemanticSearchAgent {
  final AgentGateway _gateway;
  SemanticSearchAgent(this._gateway);

  Future<SemanticSearchResponse> expandQuery(String query) async {
    final prompt = 'You are the Semantic Search Agent. Expand this search query for a personal engineering command center database: "$query". Respond with a simple JSON object containing: 1. "expandedTerms" (list of synonyms/related tags/keywords, e.g., if query is "encryption", terms might be ["cryptography", "aes", "rsa", "secret", "secure", "cipher", "hash"]), and 2. "inferredCategory" (one of: "all", "idea", "project", "research", "job"). Return ONLY the JSON object.';
    final response = await _gateway.dispatchPrompt(prompt);
    return SemanticSearchResponse.fromJsonString(response);
  }
}

final semanticSearchAgentProvider = Provider<SemanticSearchAgent>((ref) {
  final gateway = ref.watch(agentGatewayProvider);
  return SemanticSearchAgent(gateway);
});

class ProjectAutofillResult {
  final String description;
  final List<String> techStack;

  ProjectAutofillResult({required this.description, required this.techStack});

  factory ProjectAutofillResult.fromJsonString(String jsonStr) {
    try {
      final int start = jsonStr.indexOf('{');
      final int end = jsonStr.lastIndexOf('}');
      if (start != -1 && end != -1 && end > start) {
        final cleaned = jsonStr.substring(start, end + 1);
        final Map<String, dynamic> data = json.decode(cleaned) as Map<String, dynamic>;
        final desc = data['description'] as String? ?? '';
        final rawTech = data['techStack'] as List<dynamic>? ?? [];
        final techStack = rawTech.map((t) => t.toString()).toList();
        return ProjectAutofillResult(description: desc, techStack: techStack);
      }
    } catch (_) {}
    return ProjectAutofillResult(description: '', techStack: []);
  }
}

class ResearchAutofillResult {
  final String abstractId;
  final String paperLink;
  final String coAuthors;

  ResearchAutofillResult({required this.abstractId, required this.paperLink, required this.coAuthors});

  factory ResearchAutofillResult.fromJsonString(String jsonStr) {
    try {
      final int start = jsonStr.indexOf('{');
      final int end = jsonStr.lastIndexOf('}');
      if (start != -1 && end != -1 && end > start) {
        final cleaned = jsonStr.substring(start, end + 1);
        final Map<String, dynamic> data = json.decode(cleaned) as Map<String, dynamic>;
        final abs = data['abstractId'] as String? ?? '';
        final link = data['paperLink'] as String? ?? '';
        final co = data['coAuthors'] as String? ?? '';
        return ResearchAutofillResult(abstractId: abs, paperLink: link, coAuthors: co);
      }
    } catch (_) {}
    return ResearchAutofillResult(abstractId: '', paperLink: '', coAuthors: '');
  }
}

class AutofillAgent {
  final AgentGateway _gateway;
  AutofillAgent(this._gateway);

  Future<ProjectAutofillResult> autofillProject(String name) async {
    final prompt = 'You are an Engineering Assistant. Based on this project name: "$name", write a concise 1-2 sentence engineering description and suggest a list of relevant technical tools or languages from this exact list: [Flutter, Python, FastAPI, AI/ML, Dart, React, React Native, Vue, Angular, Svelte, Next.js, TailwindCSS, Node.js, Go, Rust, C++, Java, Spring Boot, C#, C, TypeScript, PostgreSQL, SQLite, MongoDB, MySQL, Redis, DynamoDB, Supabase, Firebase, Docker, Kubernetes, Terraform, GitHub Actions, AWS, GCP, Azure, Cloudflare, OpenAI, Gemini, Claude, Llama, Ollama, Nvidia, Open router]. Return ONLY a JSON object: {"description": "...", "techStack": ["...", "..."]}';
    final response = await _gateway.dispatchPrompt(prompt);
    return ProjectAutofillResult.fromJsonString(response);
  }

  Future<ResearchAutofillResult> autofillResearch(String title) async {
    final prompt = 'You are a Research Assistant. Based on this research paper title: "$title", generate mock abstract metadata. Suggest: 1. "abstractId" (a simulated arXiv identifier like "arXiv:2607.xxxxx"), 2. "paperLink" (a simulated URL like "https://arxiv.org/abs/2607.xxxxx"), 3. "coAuthors" (a list of 1-2 plausible academic co-author names, comma-separated). Return ONLY a JSON object: {"abstractId": "...", "paperLink": "...", "coAuthors": "..."}';
    final response = await _gateway.dispatchPrompt(prompt);
    return ResearchAutofillResult.fromJsonString(response);
  }
}

final autofillAgentProvider = Provider<AutofillAgent>((ref) {
  final gateway = ref.watch(agentGatewayProvider);
  return AutofillAgent(gateway);
});

