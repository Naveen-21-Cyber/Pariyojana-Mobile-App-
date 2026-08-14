import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/velvet_colors.dart';

class ModularTechStackPicker extends StatefulWidget {
  final List<String> selectedTechStack;
  final ValueChanged<List<String>> onChanged;
  final Map<String, List<String>>? aiSuggestions;

  const ModularTechStackPicker({
    super.key,
    required this.selectedTechStack,
    required this.onChanged,
    this.aiSuggestions,
  });

  @override
  State<ModularTechStackPicker> createState() => _ModularTechStackPickerState();
}

class _ModularTechStackPickerState extends State<ModularTechStackPicker> {
  final TextEditingController _customController = TextEditingController();

  static const Map<String, Map<String, dynamic>> _categories = {
    'languages': {
      'title': 'Core Languages & Runtimes',
      'icon': Icons.code_rounded,
      'items': [
        'Python', 'Dart', 'TypeScript', 'JavaScript', 'Rust', 'Go', 'Java',
        'C++', 'C#', 'Swift', 'Kotlin', 'PHP', 'Mojo', 'Zig', 'Solidity',
        'SQL', 'Bash / Shell', 'R', 'Scala', 'Elixir'
      ],
    },
    'frontend': {
      'title': 'Frontend & Mobile Frameworks',
      'icon': Icons.devices_rounded,
      'items': [
        'Flutter', 'React', 'Next.js', 'React Native', 'Svelte', 'Vue.js',
        'Angular', 'TailwindCSS', 'Shadcn/UI', 'Vite', 'Nuxt.js', 'Astro',
        'Remix', 'Expo', 'HTML5/CSS3', 'Bootstrap 5', 'Three.js', 'Electron', 'Tauri'
      ],
    },
    'backend': {
      'title': 'Backend & Microservices APIs',
      'icon': Icons.dns_rounded,
      'items': [
        'FastAPI', 'Node.js', 'Express', 'Spring Boot', 'Django', 'Flask',
        'Bun', 'Gin (Go)', 'Fiber (Go)', 'Actix Web (Rust)', 'Axum (Rust)',
        'ASP.NET Core', 'Laravel (PHP)', 'GraphQL', 'gRPC', 'WebSockets',
        'tRPC', 'NestJS', 'Celery', 'Kafka'
      ],
    },
    'database': {
      'title': 'Databases, Vector DBs & Storage',
      'icon': Icons.storage_rounded,
      'items': [
        'Supabase', 'PostgreSQL', 'pgvector', 'Vector DB', 'Pinecone', 'Qdrant',
        'ChromaDB', 'Weaviate', 'Milvus', 'Redis', 'MongoDB', 'SQLCipher',
        'SQLite', 'Drift DB', 'ClickHouse', 'Neo4j', 'Neon PG', 'Turso (LibSQL)',
        'Firebase Firestore', 'PlanetScale', 'MySQL', 'Elasticsearch'
      ],
    },
    'cloud': {
      'title': 'Cloud, DevOps & Infrastructure',
      'icon': Icons.cloud_done_rounded,
      'items': [
        'Docker', 'Kubernetes', 'AWS', 'Google Cloud (GCP)', 'Azure',
        'Cloudflare Workers', 'Vercel', 'Supabase Cloud', 'Terraform',
        'GitHub Actions', 'Linux Server', 'Nginx', 'Railway', 'Render',
        'DigitalOcean', 'Fly.io', 'Datadog', 'Prometheus'
      ],
    },
    'ai': {
      'title': 'AI, Machine Learning & Agent Systems',
      'icon': Icons.psychology_rounded,
      'items': [
        'ML Regression', 'PyTorch', 'TensorFlow', 'Scikit-learn', 'XGBoost',
        'LangChain', 'LlamaIndex', 'Ollama', 'DeepSeek R1', 'DeepSeek V3',
        'Gemini 2.0 Flash', 'OpenAI o3-mini', 'GPT-4o', 'Claude 3.5 Sonnet',
        'Llama 4 Scout', 'vLLM', 'Hugging Face', 'CrewAI', 'RAG Architecture',
        'Computer Vision (OpenCV)', 'NLP Transformers', 'Whisper AI', 'Mistral AI', 'Qwen 3'
      ],
    },
    'security': {
      'title': 'Security & Cryptography',
      'icon': Icons.security_rounded,
      'items': [
        'SQLCipher', 'JWT / OAuth2', 'OpenSSL', 'Biometric Auth', 'AES-256',
        'RSA Encryption', 'Zero Trust', 'OWASP', 'Pen Testing', 'Burp Suite',
        'Snyk', 'SonarQube', 'Vault (HashiCorp)', 'mTLS', 'SAST / DAST',
        'PKI / Certificate Mgmt', 'Keycloak', 'Passkeys / FIDO2'
      ],
    },
    'data_eng': {
      'title': 'Data Engineering & Analytics',
      'icon': Icons.bar_chart_rounded,
      'items': [
        'Apache Spark', 'Apache Kafka', 'Apache Airflow', 'dbt', 'Great Expectations',
        'Pandas', 'Polars', 'DuckDB', 'BigQuery', 'Snowflake', 'Redshift',
        'Databricks', 'MLflow', 'Metabase', 'Apache Flink', 'dlt (data load tool)',
        'Airbyte', 'Fivetran', 'Apache Iceberg'
      ],
    },
    'testing': {
      'title': 'Testing & Quality Assurance',
      'icon': Icons.verified_rounded,
      'items': [
        'Jest', 'Pytest', 'Playwright', 'Cypress', 'Selenium', 'k6 Load Testing',
        'JMeter', 'Postman', 'Swagger / OpenAPI', 'Flutter Test', 'Patrol',
        'Mockito', 'Detox (RN)', 'Vitest', 'TestContainers', 'Storybook',
        'Appium', 'Artillery', 'Allure Reports'
      ],
    },
    'mobile_native': {
      'title': 'Mobile Native & Cross-Platform',
      'icon': Icons.phone_android_rounded,
      'items': [
        'Jetpack Compose', 'SwiftUI', 'Capacitor', 'ARCore / ARKit',
        'BLE / Bluetooth', 'NFC', 'Push Notifications (FCM/APNs)', 'In-App Purchase',
        'Biometrics (local_auth)', 'Wear OS', 'watchOS', 'Android NDK',
        'Background Services', 'Deep Links / App Links', 'Kotlin Multiplatform',
        'Compose Multiplatform'
      ],
    },
    'emerging': {
      'title': 'Emerging Tech & Web3',
      'icon': Icons.rocket_launch_rounded,
      'items': [
        'Solidity', 'Ethereum', 'Solana', 'IPFS', 'Web3.js', 'Ethers.js',
        'WebAssembly (WASM)', 'Edge Computing', 'Quantum Computing (Qiskit)',
        'Digital Twins', 'IoT (MQTT)', 'ROS 2 (Robotics)', 'Unity (XR)',
        'Unreal Engine', 'OpenXR / WebXR', 'LiDAR / Point Cloud', 'Federated Learning'
      ],
    },
  };

  void _toggleTech(String item) {
    final updated = List<String>.from(widget.selectedTechStack);
    if (updated.contains(item)) {
      updated.remove(item);
    } else {
      updated.add(item);
    }
    widget.onChanged(updated);
  }

  void _addCustomTag() {
    final text = _customController.text.trim();
    if (text.isEmpty) return;
    final updated = List<String>.from(widget.selectedTechStack);
    if (!updated.contains(text)) {
      updated.add(text);
      widget.onChanged(updated);
    }
    _customController.clear();
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E1B18) : Colors.white;
    final textColor = isDark ? VelvetColors.darkText : VelvetColors.cocoa;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'MODULAR TECH STACK REGISTRY 🧩',
              style: TextStyle(
                fontFamily: GoogleFonts.outfit().fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
                color: VelvetColors.coralPeach,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: VelvetColors.coralPeach.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${widget.selectedTechStack.length} Selected',
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: VelvetColors.coralPeach,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Selected Chips Showcase
        if (widget.selectedTechStack.isNotEmpty) ...[
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: widget.selectedTechStack.map((tech) {
              return Chip(
                backgroundColor: VelvetColors.coralPeach,
                deleteIconColor: Colors.white,
                onDeleted: () => _toggleTech(tech),
                label: Text(
                  tech,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
        ],

        // AI Intelligent Picks & Config Recommendations Quick-Add Bar
        Builder(
          builder: (ctx) {
            final allAiPicks = <String>{};
            if (widget.aiSuggestions != null) {
              for (final list in widget.aiSuggestions!.values) {
                for (final item in list) {
                  if (item.trim().isNotEmpty) allAiPicks.add(item.trim());
                }
              }
            }
            if (allAiPicks.isEmpty) {
              // Smart fallback heuristic picks for modern cloud/mobile architectures
              allAiPicks.addAll(['Flutter', 'FastAPI', 'PostgreSQL', 'Docker', 'Gemini 2.0']);
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: VelvetColors.coralPeach.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: VelvetColors.coralPeach.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.auto_awesome_rounded, size: 14, color: VelvetColors.coralPeach),
                      SizedBox(width: 6),
                      Text(
                        'AI & CONFIG SMART PICKS (1-TAP TO ADD)',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          color: VelvetColors.coralPeach,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: allAiPicks.map((pick) {
                      final isSelected = widget.selectedTechStack.contains(pick);
                      return FilterChip(
                        selected: isSelected,
                        showCheckmark: false,
                        selectedColor: VelvetColors.coralPeach,
                        backgroundColor: isDark ? const Color(0xFF2A2420) : Colors.white,
                        side: BorderSide(
                          color: isSelected ? VelvetColors.coralPeach : VelvetColors.coralPeach.withValues(alpha: 0.5),
                        ),
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isSelected ? '✓ $pick' : '+ $pick',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : (isDark ? VelvetColors.darkText : VelvetColors.cocoa),
                              ),
                            ),
                          ],
                        ),
                        onSelected: (_) => _toggleTech(pick),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          },
        ),

        // Custom Modular Tag Add Input
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _customController,
                style: TextStyle(fontSize: 12, color: textColor),
                decoration: InputDecoration(
                  hintText: 'Add custom module / tech (e.g. WebAssembly)...',
                  hintStyle: TextStyle(fontSize: 11, color: VelvetColors.textSecondary(context)),
                  isDense: true,
                  filled: true,
                  fillColor: cardBg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: VelvetColors.border(context)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: VelvetColors.coralPeach, width: 2),
                  ),
                ),
                onSubmitted: (_) => _addCustomTag(),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _addCustomTag,
              style: ElevatedButton.styleFrom(
                backgroundColor: VelvetColors.coralPeach,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('+ Add', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // 6 Categorized Modular Expansion Sections
        ..._categories.entries.map((entry) {
          final catKey = entry.key;
          final title = entry.value['title'] as String;
          final icon = entry.value['icon'] as IconData;
          final items = entry.value['items'] as List<String>;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: VelvetColors.border(context)),
            ),
            child: ExpansionTile(
              leading: Icon(icon, size: 18, color: VelvetColors.coralPeach),
              title: Text(
                title,
                style: TextStyle(
                  fontFamily: GoogleFonts.outfit().fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: items.map((item) {
                    final isSelected = widget.selectedTechStack.contains(item);
                    final isAiSuggested = widget.aiSuggestions != null &&
                        (widget.aiSuggestions![catKey]?.any((s) => s.toLowerCase().contains(item.toLowerCase()) || item.toLowerCase().contains(s.toLowerCase())) ?? false);

                    return FilterChip(
                      selected: isSelected,
                      showCheckmark: false,
                      selectedColor: VelvetColors.coralPeach,
                      backgroundColor: isDark ? const Color(0xFF2A2420) : VelvetColors.cream,
                      side: BorderSide(
                        color: isSelected
                            ? VelvetColors.coralPeach
                            : (isAiSuggested ? VelvetColors.coralPeach : VelvetColors.clayTan),
                      ),
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected || isAiSuggested ? FontWeight.bold : FontWeight.normal,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? VelvetColors.darkText : VelvetColors.cocoa),
                            ),
                          ),
                          if (isAiSuggested && !isSelected) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: VelvetColors.coralPeach.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                '★ AI',
                                style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: VelvetColors.coralPeach),
                              ),
                            ),
                          ],
                        ],
                      ),
                      onSelected: (_) => _toggleTech(item),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
