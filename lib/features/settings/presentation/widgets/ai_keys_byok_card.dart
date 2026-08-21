import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/security/auth_service.dart';
import '../../../../core/theme/velvet_colors.dart';
import '../../../../shared_widgets/clay_card.dart';
import '../../../../shared_widgets/glass_snackbar.dart';

// ── Model catalogue (accurate IDs as of 2026-08) ──────────────────────────────
class _AiModel {
  final String id;
  final String label;
  final bool isFree;
  final bool isHeader; // visual group separator — not selectable
  const _AiModel(this.id, this.label, {this.isFree = false, this.isHeader = false});
}

// ─── OpenRouter — grouped by provider ─────────────────────────────────────────
const _openRouterModels = [
  // ── 1. Google ──────────────────────────────────────────────────────────────
  _AiModel('__header_google', '── 🌐 Google ──', isHeader: true),
  _AiModel('google/gemini-3.6-flash',                'Gemini 3.6 Flash'),
  _AiModel('google/gemini-3.5-flash',                'Gemini 3.5 Flash'),
  _AiModel('google/gemini-3.1-flash',                'Gemini 3.1 Flash'),
  _AiModel('google/gemini-2.5-flash:free',           'Gemini 2.5 Flash (Free)',           isFree: true),
  _AiModel('google/gemini-2.5-flash-exp:free',       'Gemini 2.5 Flash Exp (Free)',       isFree: true),
  _AiModel('google/gemini-2.0-flash-exp:free',       'Gemini 2.0 Flash Exp (Free)',       isFree: true),
  _AiModel('google/gemini-flash-1.5:free',           'Gemini Flash 1.5 (Free)',           isFree: true),
  _AiModel('google/gemma-3-27b-it:free',             'Gemma 3 27B IT (Free)',             isFree: true),
  _AiModel('google/gemma-3-12b-it:free',             'Gemma 3 12B IT (Free)',             isFree: true),
  _AiModel('google/gemma-3-4b-it:free',              'Gemma 3 4B IT (Free)',              isFree: true),
  _AiModel('google/gemma-3n-e4b-it:free',            'Gemma 3n E4B IT (Free)',            isFree: true),
  _AiModel('google/gemini-2.5-pro',                  'Gemini 2.5 Pro (Paid)'),
  _AiModel('google/gemini-2.5-flash',                'Gemini 2.5 Flash (Paid)'),
  _AiModel('google/gemini-2.0-flash',                'Gemini 2.0 Flash (Paid)'),

  // ── 2. Nvidia ──────────────────────────────────────────────────────────────
  _AiModel('__header_nvidia', '── 🟢 Nvidia ──', isHeader: true),
  _AiModel('nvidia/nemotron-3-nano-30b-a3b:free',    'Nemotron Nano 30B (Free)',          isFree: true),
  _AiModel('nvidia/llama-3.1-nemotron-ultra-253b-v1:free', 'Nemotron Ultra 253B (Free)', isFree: true),
  _AiModel('nvidia/llama-3.3-nemotron-super-49b-v1:free', 'Nemotron Super 49B (Free)',   isFree: true),
  _AiModel('nvidia/llama-3.1-nemotron-70b-instruct', 'Nemotron 70B Instruct (Paid)'),
  _AiModel('nvidia/mistral-nemo-12b-instruct',       'Mistral Nemo 12B (Paid)'),
  // ── 3. DeepSeek ────────────────────────────────────────────────────────────
  _AiModel('__header_deepseek', '── 🔵 DeepSeek ──', isHeader: true),
  _AiModel('deepseek/deepseek-r1:free',              'DeepSeek R1 (Free)',                isFree: true),
  _AiModel('deepseek/deepseek-r1-0528:free',         'DeepSeek R1 0528 (Free)',           isFree: true),
  _AiModel('deepseek/deepseek-v3:free',              'DeepSeek V3 (Free)',                isFree: true),
  _AiModel('deepseek/deepseek-r2:free',              'DeepSeek R2 (Free)',                isFree: true),
  _AiModel('deepseek/deepseek-chat',                 'DeepSeek Chat V3 (Paid)'),
  _AiModel('deepseek/deepseek-r1-0528',              'DeepSeek R1 0528 (Paid)'),
  _AiModel('deepseek/deepseek-r1-distill-qwen-32b', 'DeepSeek R1 Distill Qwen 32B'),
  // ── 4. Meta / Llama ────────────────────────────────────────────────────────
  _AiModel('__header_llama', '── 🦙 Llama (Meta) ──', isHeader: true),
  _AiModel('meta-llama/llama-3.1-8b-instruct:free',         'Llama 3.1 8B (Free)',          isFree: true),
  _AiModel('meta-llama/llama-3.2-11b-vision-instruct:free', 'Llama 3.2 11B Vision (Free)',  isFree: true),
  _AiModel('meta-llama/llama-3.3-70b-instruct:free',        'Llama 3.3 70B (Free)',         isFree: true),
  _AiModel('meta-llama/llama-4-scout:free',                 'Llama 4 Scout (Free)',         isFree: true),
  _AiModel('meta-llama/llama-4-maverick:free',              'Llama 4 Maverick (Free)',      isFree: true),
  _AiModel('meta-llama/llama-3.3-70b-instruct',             'Llama 3.3 70B (Paid)'),
  _AiModel('meta-llama/llama-4-maverick',                   'Llama 4 Maverick (Paid)'),
  // ── 5. Qwen ────────────────────────────────────────────────────────────────
  _AiModel('__header_qwen', '── 🌊 Qwen ──', isHeader: true),
  _AiModel('qwen/qwen3-8b:free',                     'Qwen3 8B (Free)',                   isFree: true),
  _AiModel('qwen/qwen3-14b:free',                    'Qwen3 14B (Free)',                  isFree: true),
  _AiModel('qwen/qwen3-32b:free',                    'Qwen3 32B (Free)',                  isFree: true),
  _AiModel('qwen/qwen3-30b-a3b:free',                'Qwen3 30B A3B MoE (Free)',          isFree: true),
  _AiModel('qwen/qwen3-235b-a22b:free',              'Qwen3 235B A22B MoE (Free)',        isFree: true),
  _AiModel('qwen/qwen-2.5-72b-instruct',             'Qwen2.5 72B (Paid)'),
  _AiModel('qwen/qwen3-235b-a22b',                   'Qwen3 235B A22B MoE (Paid)'),
  // ── 6. Mistral ─────────────────────────────────────────────────────────────
  _AiModel('__header_mistral', '── ✨ Mistral ──', isHeader: true),
  _AiModel('mistralai/mistral-7b-instruct:free',     'Mistral 7B (Free)',                 isFree: true),
  _AiModel('mistralai/mistral-small:free',           'Mistral Small 3.2 (Free)',          isFree: true),
  _AiModel('mistralai/mistral-nemo:free',            'Mistral Nemo 12B (Free)',           isFree: true),
  _AiModel('mistralai/devstral-small:free',          'Devstral Small (Coding, Free)',     isFree: true),
  _AiModel('mistralai/mistral-large-2411',           'Mistral Large 2411 (Paid)'),
  _AiModel('mistralai/mistral-small-3.2-24b-instruct', 'Mistral Small 3.2 24B (Paid)'),
  _AiModel('mistralai/magistral-medium',             'Magistral Medium (Reasoning, Paid)'),
  // ── 7. Kimi ────────────────────────────────────────────────────────────────
  _AiModel('__header_kimi', '── 🌙 Kimi ──', isHeader: true),
  _AiModel('moonshotai/kimi-k2:free',                'Kimi K2 (Free)',                    isFree: true),
  _AiModel('moonshotai/kimi-vl-a3b-thinking:free',  'Kimi VL A3B Thinking (Free)',       isFree: true),
  _AiModel('moonshotai/kimi-k2',                     'Kimi K2 (Paid)'),
  // ── 8. GLM ─────────────────────────────────────────────────────────────────
  _AiModel('__header_glm', '── 🔷 GLM ──', isHeader: true),
  _AiModel('thudm/glm-4-32b:free',                   'GLM-4 32B (Free)',                  isFree: true),
  _AiModel('thudm/glm-z1-32b:free',                  'GLM-Z1 32B Reasoning (Free)',       isFree: true),
  _AiModel('thudm/glm-4-9b:free',                    'GLM-4 9B (Free)',                   isFree: true),
  _AiModel('thudm/glm-z1-9b:free',                   'GLM-Z1 9B (Free)',                  isFree: true),
  // ── 9. OpenAI via OpenRouter ────────────────────────────────────────────────
  _AiModel('__header_openai_or', '── 🔳 OpenAI via OpenRouter ──', isHeader: true),
  _AiModel('openai/gpt-4.1',                         'GPT-4.1'),
  _AiModel('openai/gpt-4.1-mini',                    'GPT-4.1 Mini'),
  _AiModel('openai/gpt-4.1-nano',                    'GPT-4.1 Nano'),
  _AiModel('openai/gpt-4o',                          'GPT-4o'),
  _AiModel('openai/gpt-4o-mini',                     'GPT-4o Mini'),
  _AiModel('openai/o4-mini',                         'o4 Mini (Reasoning)'),
  _AiModel('openai/o3-mini',                         'o3 Mini (Reasoning)'),
  _AiModel('openai/o3',                              'o3 (Deep Reasoning)'),
  _AiModel('openai/o1',                              'o1 (Full Reasoning)'),
  // ── 10. Others ─────────────────────────────────────────────────────────────
  _AiModel('__header_others', '── 🔠 Others ──', isHeader: true),
  _AiModel('microsoft/phi-4-reasoning-plus:free',    'Phi-4 Reasoning Plus (Free)',       isFree: true),
  _AiModel('microsoft/phi-4-mini-reasoning:free',    'Phi-4 Mini Reasoning (Free)',       isFree: true),
  _AiModel('nousresearch/hermes-3-llama-3.1-405b:free', 'Hermes 3 Llama 405B (Free)',    isFree: true),
  _AiModel('openchat/openchat-7b:free',              'OpenChat 3.5 7B (Free)',            isFree: true),
  _AiModel('tiiuae/falcon3-7b-instruct:free',        'Falcon3 7B (Free)',                 isFree: true),
  _AiModel('cohere/aya-expanse-32b',                 'Cohere Aya Expanse 32B'),
  _AiModel('anthropic/claude-opus-4',                'Claude Opus 4 via OR'),
  _AiModel('anthropic/claude-sonnet-4-5',            'Claude Sonnet 4.5 via OR'),
  _AiModel('x-ai/grok-3-mini',                      'Grok 3 Mini'),
  _AiModel('x-ai/grok-3',                           'Grok 3'),
  _AiModel('cohere/command-r-plus-08-2024',          'Command R+ (Cohere)'),
];

// ─── Claude (Anthropic direct) ─────────────────────────────────────────────────
const _claudeModels = [
  _AiModel('claude-opus-4-5-20250514',   'Claude Opus 4.5 (Best)'),
  _AiModel('claude-sonnet-4-5-20250514', 'Claude Sonnet 4.5 (Balanced)'),
  _AiModel('claude-opus-4-20250514',     'Claude Opus 4'),
  _AiModel('claude-sonnet-4-20250514',   'Claude Sonnet 4'),
  _AiModel('claude-3-5-sonnet-20241022', 'Claude 3.5 Sonnet'),
  _AiModel('claude-3-5-haiku-20241022',  'Claude 3.5 Haiku (Fast)'),
  _AiModel('claude-3-opus-20240229',     'Claude 3 Opus'),
];

// ─── OpenAI direct ─────────────────────────────────────────────────────────────
const _openAiModels = [
  _AiModel('gpt-4.1',      'GPT-4.1 (Latest)'),
  _AiModel('gpt-4.1-mini', 'GPT-4.1 Mini (Fast)'),
  _AiModel('gpt-4.1-nano', 'GPT-4.1 Nano (Fastest)'),
  _AiModel('o4-mini',      'o4 Mini (Reasoning)'),
  _AiModel('o3-mini',      'o3 Mini (Reasoning)'),
  _AiModel('o3',           'o3 (Deep Reasoning)'),
  _AiModel('o1',           'o1 (Full Reasoning)'),
  _AiModel('gpt-4o',       'GPT-4o'),
  _AiModel('gpt-4o-mini',  'GPT-4o Mini'),
  _AiModel('gpt-4o-2024-11-20', 'GPT-4o Nov 2024'),
];

// ─── Google Gemini direct (AI Studio) ──────────────────────────────────────────
const _geminiModels = [
  // Gemini 3.x (2026 series)
  _AiModel('gemini-3.6-flash',                    'Gemini 3.6 Flash (Latest)'),
  _AiModel('gemini-3.5-flash',                    'Gemini 3.5 Flash'),
  _AiModel('gemini-3.1-flash',                    'Gemini 3.1 Flash'),
  _AiModel('gemini-3.6-flash-lite',               'Gemini 3.6 Flash Lite (Fast)'),
  // Gemini 2.5 family
  _AiModel('gemini-2.5-pro-preview-06-05',        'Gemini 2.5 Pro (Preview)'),
  _AiModel('gemini-2.5-flash-preview-05-20',      'Gemini 2.5 Flash (Preview)'),
  _AiModel('gemini-2.5-flash-lite-preview-06-17', 'Gemini 2.5 Flash Lite (Preview)'),
  // Gemini 2.0
  _AiModel('gemini-2.0-flash',                    'Gemini 2.0 Flash'),
  _AiModel('gemini-2.0-flash-exp',                'Gemini 2.0 Flash Exp'),
  _AiModel('gemini-2.0-flash-thinking-exp',       'Gemini 2.0 Flash Thinking'),
  // Gemini 1.5 (stable)
  _AiModel('gemini-1.5-pro',                      'Gemini 1.5 Pro'),
  _AiModel('gemini-1.5-flash',                    'Gemini 1.5 Flash'),
  _AiModel('gemini-1.5-flash-8b',                 'Gemini 1.5 Flash 8B (Fastest)'),
];

// ─── Groq (Ultra-fast LPU inference) ───────────────────────────────────────────
const _groqModels = [
  _AiModel('llama-3.3-70b-versatile',            'Llama 3.3 70B Versatile'),
  _AiModel('llama-3.1-8b-instant',               'Llama 3.1 8B Instant (Fast)'),
  _AiModel('llama-3.1-70b-versatile',            'Llama 3.1 70B Versatile'),
  _AiModel('llama-4-scout-17b-16e-instruct',     'Llama 4 Scout 17B'),
  _AiModel('llama-4-maverick-17b-128e-instruct', 'Llama 4 Maverick 17B'),
  _AiModel('mixtral-8x7b-32768',                 'Mixtral 8x7B MoE'),
  _AiModel('gemma2-9b-it',                       'Gemma 2 9B IT'),
  _AiModel('deepseek-r1-distill-llama-70b',      'DeepSeek R1 Distill 70B'),
  _AiModel('qwen-qwq-32b',                       'QwQ 32B (Reasoning)'),
  _AiModel('compound-beta',                      'Compound Beta (Search+LLM)'),
  _AiModel('llama-3.3-70b-specdec',              'Llama 3.3 70B SpecDec'),
  _AiModel('llama-3.2-3b-preview',               'Llama 3.2 3B Preview'),
  _AiModel('llama-3.2-1b-preview',               'Llama 3.2 1B Preview (Fastest)'),
];

// ─── Hugging Face Inference API (free & serverless) ────────────────────────────
const _huggingFaceModels = [
  _AiModel('meta-llama/Llama-3.3-70B-Instruct',          'Llama 3.3 70B (Free)',           isFree: true),
  _AiModel('meta-llama/Llama-3.1-8B-Instruct',           'Llama 3.1 8B (Free)',            isFree: true),
  _AiModel('meta-llama/Llama-4-Scout-17B-16E-Instruct',  'Llama 4 Scout 17B (Free)',       isFree: true),
  _AiModel('mistralai/Mistral-7B-Instruct-v0.3',         'Mistral 7B v0.3 (Free)',         isFree: true),
  _AiModel('mistralai/Mixtral-8x7B-Instruct-v0.1',       'Mixtral 8x7B (Free)',            isFree: true),
  _AiModel('Qwen/Qwen2.5-72B-Instruct',                  'Qwen2.5 72B (Free)',             isFree: true),
  _AiModel('Qwen/Qwen3-30B-A3B',                         'Qwen3 30B MoE (Free)',           isFree: true),
  _AiModel('deepseek-ai/DeepSeek-R1',                    'DeepSeek R1 (Free)',             isFree: true),
  _AiModel('google/gemma-3-27b-it',                      'Gemma 3 27B (Free)',             isFree: true),
  _AiModel('nvidia/Llama-3.1-Nemotron-70B-Instruct-HF',  'Nemotron 70B (Free)',            isFree: true),
  _AiModel('microsoft/Phi-4',                            'Phi-4 (Free)',                   isFree: true),
  _AiModel('microsoft/phi-4-mini-instruct',              'Phi-4 Mini (Free)',              isFree: true),
];

/// Community Edition BYOK Key Manager with per-provider model dropdown.
class AiKeysByokCard extends ConsumerStatefulWidget {
  const AiKeysByokCard({super.key});

  @override
  ConsumerState<AiKeysByokCard> createState() => _AiKeysByokCardState();
}

class _AiKeysByokCardState extends ConsumerState<AiKeysByokCard> {
  // ── AI Key Controllers ──────────────────────────────────────────────────────
  final _claudeController = TextEditingController();
  final _gptController = TextEditingController();
  final _geminiController = TextEditingController();
  final _openRouterController = TextEditingController();
  final _groqController = TextEditingController();
  final _huggingFaceController = TextEditingController();

  // ── Integration Key Controllers ─────────────────────────────────────────────
  final _githubPatController = TextEditingController();
  final _openRouteController = TextEditingController();

  // ── Selected model IDs ──────────────────────────────────────────────────────
  String _selectedClaude = _claudeModels.first.id;
  String _selectedOpenAi = _openAiModels.first.id;
  String _selectedGemini = _geminiModels.first.id;
  String _selectedOpenRouter = _openRouterModels.firstWhere((m) => !m.isHeader).id;
  String _selectedGroq = _groqModels.first.id;
  String _selectedHuggingFace = _huggingFaceModels.first.id;

  bool _obscureKeys = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadKeys();
  }

  @override
  void dispose() {
    _claudeController.dispose();
    _gptController.dispose();
    _geminiController.dispose();
    _openRouterController.dispose();
    _groqController.dispose();
    _huggingFaceController.dispose();
    _githubPatController.dispose();
    _openRouteController.dispose();
    super.dispose();
  }

  String _validateModel(String? saved, List<_AiModel> catalogue) {
    if (saved == null) return catalogue.firstWhere((m) => !m.isHeader).id;
    return catalogue.any((m) => !m.isHeader && m.id == saved)
        ? saved
        : catalogue.firstWhere((m) => !m.isHeader).id;
  }

  Future<void> _loadKeys() async {
    final storage = ref.read(secureStorageProvider);
    final claude = await storage.getAnthropicApiKey();
    final gpt = await storage.getOpenAiApiKey();
    final gemini = await storage.getGeminiApiKey();
    final openRouter = await storage.getOpenRouterApiKey();
    final groq = await storage.getGroqApiKey();
    final hf = await storage.readSetting('pariyojana_hf_key');
    final githubPat = await storage.readSetting('velvet_github_pat');
    final openRoute = await storage.getOpenRouteServiceApiKey();
    final savedClaude = await storage.getSelectedModel('claude');
    final savedOpenAi = await storage.getSelectedModel('openai');
    final savedGemini = await storage.getSelectedModel('gemini');
    final savedOpenRouter = await storage.getSelectedModel('openrouter');
    final savedGroq = await storage.getSelectedModel('groq');
    final savedHf = await storage.getSelectedModel('huggingface');

    if (mounted) {
      setState(() {
        _claudeController.text = claude ?? '';
        _gptController.text = gpt ?? '';
        _geminiController.text = gemini ?? '';
        _openRouterController.text = openRouter ?? '';
        _groqController.text = groq ?? '';
        _huggingFaceController.text = hf ?? '';
        _githubPatController.text = githubPat ?? '';
        _openRouteController.text = openRoute ?? '';
        _selectedClaude = _validateModel(savedClaude, _claudeModels);
        _selectedOpenAi = _validateModel(savedOpenAi, _openAiModels);
        _selectedGemini = _validateModel(savedGemini, _geminiModels);
        _selectedOpenRouter = _validateModel(savedOpenRouter, _openRouterModels);
        _selectedGroq = _validateModel(savedGroq, _groqModels);
        _selectedHuggingFace = _validateModel(savedHf, _huggingFaceModels);
      });
    }
  }

  Future<void> _saveKeys() async {
    setState(() => _isSaving = true);
    final storage = ref.read(secureStorageProvider);
    await storage.saveAnthropicApiKey(_claudeController.text.trim());
    await storage.saveOpenAiApiKey(_gptController.text.trim());
    await storage.saveGeminiApiKey(_geminiController.text.trim());
    await storage.saveOpenRouterApiKey(_openRouterController.text.trim());
    await storage.saveGroqApiKey(_groqController.text.trim());
    await storage.writeSetting('pariyojana_hf_key', _huggingFaceController.text.trim());
    await storage.writeSetting('velvet_github_pat', _githubPatController.text.trim());
    await storage.saveOpenRouteServiceApiKey(_openRouteController.text.trim());
    await storage.saveSelectedModel('claude', _selectedClaude);
    await storage.saveSelectedModel('openai', _selectedOpenAi);
    await storage.saveSelectedModel('gemini', _selectedGemini);
    await storage.saveSelectedModel('openrouter', _selectedOpenRouter);
    await storage.saveSelectedModel('groq', _selectedGroq);
    await storage.saveSelectedModel('huggingface', _selectedHuggingFace);

    if (mounted) {
      setState(() => _isSaving = false);
      GlassSnackBar.show(context, '🔑 Keys & Model Preferences Saved!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClayCard(
      color: VelvetColors.cardSurface(context),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: VelvetColors.coralPeach.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.vpn_key_rounded,
                    color: VelvetColors.coralPeach, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Keys & Model Selection 🤖🔑',
                      style: TextStyle(
                        fontFamily: GoogleFonts.outfit().fontFamily,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: VelvetColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'BYOK — keys encrypted on-device • choose model per provider',
                      style: TextStyle(
                        fontSize: 11,
                        color: VelvetColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  _obscureKeys
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: VelvetColors.coralPeach,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscureKeys = !_obscureKeys),
                tooltip: _obscureKeys ? 'Show Keys' : 'Hide Keys',
              ),
            ],
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: VelvetColors.coralPeach,
              side: BorderSide(color: VelvetColors.coralPeach.withValues(alpha: 0.5)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            icon: const Icon(Icons.help_outline_rounded, size: 16),
            label: const Text('Step-by-Step Guide: How to Get API Keys & GitHub PAT 📖',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
            onPressed: () => _showApiKeyGuideModal(context),
          ),
          const SizedBox(height: 18),
          _buildSectionLabel(context, '🧠 AI Provider Keys & Models'),
          const SizedBox(height: 10),

          // 1. OpenRouter — RECOMMENDED (shown first)
          _buildField(
            context,
            controller: _openRouterController,
            label: 'OpenRouter — sk-or-v1-... (100+ Models)',
            hint: 'sk-or-v1-xxxxxxxx...',
            icon: Icons.route_rounded,
            badge: '⭐ RECOMMENDED · FREE',
            badgeColor: VelvetColors.coralPeach,
            obscure: _obscureKeys,
          ),
          const SizedBox(height: 6),
          _buildModelDropdown(
            context,
            label: 'OpenRouter Model',
            models: _openRouterModels,
            selected: _selectedOpenRouter,
            onChanged: (v) => setState(() => _selectedOpenRouter = v!),
          ),
          const SizedBox(height: 12),

          // 2. Claude (Anthropic)
          _buildField(
            context,
            controller: _claudeController,
            label: 'Claude (Anthropic) — sk-ant-...',
            hint: 'sk-ant-api03-xxxxxxxx...',
            icon: Icons.auto_awesome_rounded,
            badge: 'HIGH ACCURACY',
            badgeColor: const Color(0xFFD4A017),
            obscure: _obscureKeys,
          ),
          const SizedBox(height: 6),
          _buildModelDropdown(
            context,
            label: 'Claude Model',
            models: _claudeModels,
            selected: _selectedClaude,
            onChanged: (v) => setState(() => _selectedClaude = v!),
          ),
          const SizedBox(height: 12),

          // 3. GPT-4o (OpenAI)
          _buildField(
            context,
            controller: _gptController,
            label: 'GPT-4o (OpenAI) — sk-...',
            hint: 'sk-proj-xxxxxxxxxxxxxxxx...',
            icon: Icons.memory_rounded,
            badge: 'POPULAR',
            badgeColor: const Color(0xFF10A37F),
            obscure: _obscureKeys,
          ),
          const SizedBox(height: 6),
          _buildModelDropdown(
            context,
            label: 'OpenAI Model',
            models: _openAiModels,
            selected: _selectedOpenAi,
            onChanged: (v) => setState(() => _selectedOpenAi = v!),
          ),
          const SizedBox(height: 12),

          // 4. Gemini (Google)
          _buildField(
            context,
            controller: _geminiController,
            label: 'Gemini (Google AI Studio) — AIza...',
            hint: 'AIzaSyxxxxxxxxxxxxxxxxxxxxxxx...',
            icon: Icons.hub_rounded,
            badge: 'FREE TIER',
            badgeColor: const Color(0xFF4285F4),
            obscure: _obscureKeys,
          ),
          const SizedBox(height: 6),
          _buildModelDropdown(
            context,
            label: 'Gemini Model',
            models: _geminiModels,
            selected: _selectedGemini,
            onChanged: (v) => setState(() => _selectedGemini = v!),
          ),

          const SizedBox(height: 12),

          // 5. Groq — ultra-fast inference, free tier
          _buildField(
            context,
            controller: _groqController,
            label: 'Groq — gsk_... (Ultra-Fast Inference)',
            hint: 'gsk_xxxxxxxxxxxxxxxxxxxx...',
            icon: Icons.bolt_rounded,
            badge: 'ULTRA FAST · FREE',
            badgeColor: const Color(0xFF7C3AED),
            obscure: _obscureKeys,
          ),
          const SizedBox(height: 6),
          _buildModelDropdown(
            context,
            label: 'Groq Model',
            models: _groqModels,
            selected: _selectedGroq,
            onChanged: (v) => setState(() => _selectedGroq = v!),
          ),

          const SizedBox(height: 12),

          // 6. Hugging Face — serverless free inference
          _buildField(
            context,
            controller: _huggingFaceController,
            label: 'Hugging Face — hf_... (Serverless Free)',
            hint: 'hf_xxxxxxxxxxxxxxxxxxxx...',
            icon: Icons.face_retouching_natural_rounded,
            badge: 'ALL FREE',
            badgeColor: const Color(0xFFFFC107),
            obscure: _obscureKeys,
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 2),
            child: Text(
              '⚡ Cold-start models may take up to 30s on first call.',
              style: TextStyle(fontSize: 10, color: VelvetColors.textSecondary(context)),
            ),
          ),
          const SizedBox(height: 6),
          _buildModelDropdown(
            context,
            label: 'Hugging Face Model',
            models: _huggingFaceModels,
            selected: _selectedHuggingFace,
            onChanged: (v) => setState(() => _selectedHuggingFace = v!),
          ),

          const SizedBox(height: 18),
          _buildSectionLabel(context, '🔗 Integrations & Map'),
          const SizedBox(height: 10),

          // 5. GitHub PAT
          _buildField(
            context,
            controller: _githubPatController,
            label: 'GitHub Personal Access Token (PAT)',
            hint: 'ghp_xxxxxxxxxxxxxxxxxxxx...',
            icon: Icons.code_rounded,
            obscure: _obscureKeys,
          ),
          const SizedBox(height: 10),

          // 6. OpenRouteService Map Key
          _buildField(
            context,
            controller: _openRouteController,
            label: 'OpenRouteService Key (Interview Route Map)',
            hint: '5b3ce3597851110001cf6548...',
            icon: Icons.map_rounded,
            obscure: _obscureKeys,
          ),

          const SizedBox(height: 18),

          // Priority hint
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: VelvetColors.coralPeach.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: VelvetColors.coralPeach.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 16, color: VelvetColors.coralPeach),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '⭐ OpenRouter recommended — many free models, no credit card. '
                    'Active provider priority: OpenRouter → Claude → GPT-4o → Gemini. '
                    'Select your model above and tap Save.',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: VelvetColors.textSecondary(context),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Save Button
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: VelvetColors.coralPeach,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 2,
              ),
              onPressed: _isSaving ? null : _saveKeys,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.save_rounded, size: 18),
              label: Text(
                _isSaving ? 'Saving...' : 'Save All Keys & Models 🖐',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String label) {
    return Text(
      label,
      style: TextStyle(
        fontFamily: GoogleFonts.outfit().fontFamily,
        fontWeight: FontWeight.w700,
        fontSize: 12.5,
        letterSpacing: 0.3,
        color: VelvetColors.textSecondary(context),
      ),
    );
  }

  Widget _buildModelDropdown(
    BuildContext context, {
    required String label,
    required List<_AiModel> models,
    required String selected,
    required ValueChanged<String?> onChanged,
  }) {
    // Ensure selected is never a header id
    final safeSelected = models.any((m) => !m.isHeader && m.id == selected)
        ? selected
        : models.firstWhere((m) => !m.isHeader).id;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: VelvetColors.surface(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: VelvetColors.border(context)),
        ),
        child: Row(
          children: [
            const Icon(Icons.smart_toy_rounded, size: 16, color: VelvetColors.coralPeach),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButton<String>(
                value: safeSelected,
                isExpanded: true,
                underline: const SizedBox.shrink(),
                dropdownColor: VelvetColors.surface(context),
                borderRadius: BorderRadius.circular(14),
                style: TextStyle(
                  fontSize: 12,
                  color: VelvetColors.textPrimary(context),
                  fontFamily: GoogleFonts.outfit().fontFamily,
                ),
                hint: Text(label,
                    style: TextStyle(
                        fontSize: 12,
                        color: VelvetColors.textSecondary(context))),
                items: models.map((m) {
                  if (m.isHeader) {
                    // Section divider — styled but not selectable
                    return DropdownMenuItem<String>(
                      value: m.id,
                      enabled: false,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 6, bottom: 2),
                        child: Text(
                          m.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                            color: VelvetColors.coralPeach.withValues(alpha: 0.85),
                          ),
                        ),
                      ),
                    );
                  }
                  return DropdownMenuItem<String>(
                    value: m.id,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(m.label,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: VelvetColors.textPrimary(context))),
                        ),
                        if (m.isFree)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('FREE',
                                style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green)),
                          ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (v) {
                  // Never propagate a header selection
                  if (v != null && !models.firstWhere((m) => m.id == v).isHeader) {
                    onChanged(v);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool obscure,
    String? badge,
    Color? badgeColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (badge != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: (badgeColor ?? VelvetColors.coralPeach)
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: badgeColor ?? VelvetColors.coralPeach,
                    ),
                  ),
                ),
              ],
            ),
          ),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: TextStyle(
              fontSize: 12.5, color: VelvetColors.textPrimary(context)),
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            prefixIcon:
                Icon(icon, size: 18, color: VelvetColors.coralPeach),
            filled: true,
            fillColor: VelvetColors.surface(context),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: VelvetColors.border(context)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: VelvetColors.border(context)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: VelvetColors.coralPeach, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  void _showApiKeyGuideModal(BuildContext context) {
    void openPortal(String urlString) async {
      final uri = Uri.parse(urlString);
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        debugPrint('Could not launch $urlString: $e');
      }
    }

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: VelvetColors.surface(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: VelvetColors.coralPeach.withValues(alpha: 0.4), width: 1.5),
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: VelvetColors.border(context),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: VelvetColors.coralPeach,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.vpn_key_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'API Key & GitHub PAT Setup Guide',
                        style: TextStyle(
                          fontFamily: GoogleFonts.outfit().fontFamily,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: VelvetColors.textPrimary(context),
                        ),
                      ),
                      Text(
                        'Hardware-encrypted on-device via Android KeyStore TEE',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: VelvetColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, size: 22, color: VelvetColors.iconColor(context)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildGuideItem(
                      context,
                      stepNumber: '1',
                      title: 'OpenRouter (Recommended)',
                      badge: '⭐ FREE & BEST',
                      portalUrl: 'https://openrouter.ai/keys',
                      keyPrefix: 'sk-or-v1-...',
                      color: VelvetColors.coralPeach,
                      onOpenPortal: () => openPortal('https://openrouter.ai/keys'),
                      steps: [
                        'No credit card required. Free tier models include Llama 3.3, DeepSeek R1 & Gemma.',
                        'Sign in with Google / GitHub → Click "Create Key".',
                        'Set Name to "Pariyojana" → Copy the key starting with "sk-or-v1-...".',
                        'Paste in Pariyojana OpenRouter field → Select from 50+ models.',
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildGuideItem(
                      context,
                      stepNumber: '2',
                      title: 'Google Gemini Studio',
                      badge: 'FREE TIER',
                      portalUrl: 'https://aistudio.google.com/app/apikey',
                      keyPrefix: 'AIzaSy...',
                      color: Colors.blueAccent,
                      onOpenPortal: () => openPortal('https://aistudio.google.com/app/apikey'),
                      steps: [
                        'High token rate limits (15 RPM / 1M TPM free).',
                        'Sign in with your Google account.',
                        'Click "+ Create API Key" in a new or existing Google Cloud project.',
                        'Copy key starting with "AIzaSy..." and paste into Gemini field.',
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildGuideItem(
                      context,
                      stepNumber: '3',
                      title: 'Groq Cloud (Ultra-Fast)',
                      badge: '⚡ 500 T/s SPEED',
                      portalUrl: 'https://console.groq.com/keys',
                      keyPrefix: 'gsk_...',
                      color: Colors.deepOrange,
                      onOpenPortal: () => openPortal('https://console.groq.com/keys'),
                      steps: [
                        'Blazing-fast LPUs with 500+ tokens/sec inference.',
                        'Log in to Groq Console → Navigate to API Keys.',
                        'Click "Create API Key" → Copy key starting with "gsk_...".',
                        'Best for instant resume triage and live mock interview feedback.',
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildGuideItem(
                      context,
                      stepNumber: '4',
                      title: 'OpenAI (GPT-4o & o3-mini)',
                      badge: 'STANDARD',
                      portalUrl: 'https://platform.openai.com/api-keys',
                      keyPrefix: 'sk-proj-...',
                      color: const Color(0xFF10A37F),
                      onOpenPortal: () => openPortal('https://platform.openai.com/api-keys'),
                      steps: [
                        'Log in to OpenAI Platform → Dashboard → API Keys.',
                        'Click "+ Create new secret key" → Name: "Pariyojana".',
                        'Copy key starting with "sk-..." or "sk-proj-...".',
                        'Ensure your OpenAI billing balance is active.',
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildGuideItem(
                      context,
                      stepNumber: '5',
                      title: 'Anthropic Claude 3.5',
                      badge: 'HIGH REASONING',
                      portalUrl: 'https://console.anthropic.com/settings/keys',
                      keyPrefix: 'sk-ant-...',
                      color: const Color(0xFFD4A017),
                      onOpenPortal: () => openPortal('https://console.anthropic.com/settings/keys'),
                      steps: [
                        'Log in to Anthropic Console → Settings → API Keys.',
                        'Click "Create Key" → Copy key starting with "sk-ant-...".',
                        'Ideal for complex research synthesis and architecture evaluation.',
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildGuideItem(
                      context,
                      stepNumber: '6',
                      title: 'GitHub Personal Access Token (PAT)',
                      badge: 'REPO SYNC',
                      portalUrl: 'https://github.com/settings/tokens',
                      keyPrefix: 'ghp_...',
                      color: Colors.purpleAccent,
                      onOpenPortal: () => openPortal('https://github.com/settings/tokens'),
                      steps: [
                        'Go to GitHub → Settings → Developer Settings → Personal Access Tokens (Classic).',
                        'Click "Generate new token (classic)" → Note: "Pariyojana Mobile App".',
                        'Check Scopes: "repo" (Full repo control), "workflow", and "read:user".',
                        'Generate token & copy "ghp_..." key. Used to create & link project repositories.',
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideItem(
    BuildContext context, {
    required String stepNumber,
    required String title,
    required String badge,
    required String portalUrl,
    required String keyPrefix,
    required Color color,
    required VoidCallback onOpenPortal,
    required List<String> steps,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    stepNumber,
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: VelvetColors.textPrimary(context),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withValues(alpha: 0.5)),
                ),
                child: Text(
                  badge,
                  style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...steps.map(
            (step) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
                  Expanded(
                    child: Text(
                      step,
                      style: TextStyle(fontSize: 11, color: VelvetColors.textSecondary(context), height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: VelvetColors.surface(context),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: VelvetColors.border(context)),
                ),
                child: Text(
                  'Prefix: $keyPrefix',
                  style: TextStyle(fontSize: 10, fontFamily: 'monospace', fontWeight: FontWeight.w600, color: VelvetColors.textSecondary(context)),
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: const Icon(Icons.open_in_new_rounded, size: 12),
                label: const Text('Open Portal ↗', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
                onPressed: onOpenPortal,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
