import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/velvet_colors.dart';
import '../../../shared_widgets/glass_container.dart';
import '../../../shared_widgets/clay_card.dart';
import '../../../shared_widgets/skeuo_folder_tab.dart';
import '../../../shared_widgets/liquid_fab.dart';

class StyleGuideScreen extends StatefulWidget {
  const StyleGuideScreen({super.key});

  @override
  State<StyleGuideScreen> createState() => _StyleGuideScreenState();
}

class _StyleGuideScreenState extends State<StyleGuideScreen> {
  int _activeSkeuoTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Design System Style Guide',
          style: TextStyle(
            fontFamily: GoogleFonts.fraunces().fontFamily,
            fontWeight: FontWeight.bold,
            color: VelvetColors.cocoa,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: VelvetColors.cocoa),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Typography'),
              const SizedBox(height: 12),
              ClayCard(
                color: VelvetColors.cream,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Display (Fraunces)',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Headline (Fraunces)',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 22),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'UI & Body Text (Plus Jakarta Sans)',
                      style: TextStyle(
                        fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
                        fontSize: 14,
                        color: VelvetColors.cocoa,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'data_path: /usr/local/bin/velvet (JetBrains Mono)',
                      style: TextStyle(
                        fontFamily: GoogleFonts.jetBrainsMono().fontFamily,
                        fontSize: 13,
                        color: VelvetColors.cocoa,
                        backgroundColor: const Color(0x0D6B4F4F),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              _buildSectionTitle('Color Palette'),
              const SizedBox(height: 12),
              ClayCard(
                color: VelvetColors.cream,
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildColorBox(VelvetColors.cream, 'Cream', '#FDF6F0'),
                        _buildColorBox(VelvetColors.coralPeach, 'Coral', '#FFB4A2'),
                        _buildColorBox(VelvetColors.periwinkle, 'Periwinkle', '#B8C0FF'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildColorBox(VelvetColors.cocoa, 'Cocoa', '#6B4F4F', textColor: Colors.white),
                        _buildColorBox(VelvetColors.clayTan, 'Clay Tan', '#E8D5C4'),
                        _buildColorBox(VelvetColors.mint, 'Mint', '#7FE7C4'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              _buildSectionTitle('Glassmorphism'),
              const SizedBox(height: 8),
              const Text(
                'Uses a frosted, translucent backdrop filter blur (25px) and a 1px border. Ideal for navigation and modal overlays.',
                style: TextStyle(fontSize: 12, color: VelvetColors.cocoa),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                    colors: [VelvetColors.periwinkle, VelvetColors.coralPeach],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: GlassContainer(
                  padding: const EdgeInsets.all(24),
                  borderRadius: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.blur_on, color: VelvetColors.cocoa),
                          SizedBox(width: 8),
                          Text(
                            'Frosted Overlay',
                            style: TextStyle(fontWeight: FontWeight.bold, color: VelvetColors.cocoa),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'See how the background gradient is blurred behind this glass card.',
                        style: TextStyle(fontSize: 12, color: VelvetColors.cocoa.withValues(alpha: 0.85)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              _buildSectionTitle('Claymorphism'),
              const SizedBox(height: 8),
              const Text(
                'Features matte pastel fills with soft dual shadows (raised depth and top-left light highlight) giving a squishy, friendly, 3D look.',
                style: TextStyle(fontSize: 12, color: VelvetColors.cocoa),
              ),
              const SizedBox(height: 12),
              const Row(
                children: [
                  Expanded(
                    child: ClayCard(
                      color: VelvetColors.clayTan,
                      child: Column(
                        children: [
                          Icon(Icons.layers, color: VelvetColors.cocoa),
                          SizedBox(height: 8),
                          Text('Clay Tan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ClayCard(
                      color: VelvetColors.periwinkle,
                      child: Column(
                        children: [
                          Icon(Icons.water_drop, color: VelvetColors.cocoa),
                          SizedBox(height: 8),
                          Text('Periwinkle', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              _buildSectionTitle('Skeuomorphism'),
              const SizedBox(height: 8),
              const Text(
                'Used selectively for index folders and drive structure. Interactive tabs press down/sink on tap.',
                style: TextStyle(fontSize: 12, color: VelvetColors.cocoa),
              ),
              const SizedBox(height: 16),
              ClayCard(
                color: VelvetColors.cream,
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, top: 16.0),
                      child: Row(
                        children: [
                          SkeuoFolderTab(
                            label: 'Drive C:',
                            isSelected: _activeSkeuoTab == 0,
                            icon: Icons.storage,
                            onTap: () => setState(() => _activeSkeuoTab = 0),
                          ),
                          const SizedBox(width: 4),
                          SkeuoFolderTab(
                            label: 'Drive D:',
                            isSelected: _activeSkeuoTab == 1,
                            icon: Icons.storage,
                            onTap: () => setState(() => _activeSkeuoTab = 1),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: VelvetColors.clayTan,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(28),
                          bottomRight: Radius.circular(28),
                          topRight: Radius.circular(28),
                        ),
                      ),
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        _activeSkeuoTab == 0
                            ? 'Displaying filesystem tree for local OS Drive C:\\\n├── Projects/\n│   └── Velvet/\n└── System/'
                            : 'Displaying filesystem tree for secondary Storage Drive D:\\\n├── Backups/\n└── Datasets/',
                        style: TextStyle(
                          fontFamily: GoogleFonts.jetBrainsMono().fontFamily,
                          fontSize: 12,
                          color: VelvetColors.cocoa,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              _buildSectionTitle('Signature Liquid Morphing'),
              const SizedBox(height: 8),
              const Text(
                'A single custom fluid-morphing FAB representing a morphing liquid orb.',
                style: TextStyle(fontSize: 12, color: VelvetColors.cocoa),
              ),
              const SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    LiquidFab(
                      onPressed: () {},
                      icon: const Icon(Icons.add),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Observe the continuous organic liquid morph animation.',
                      style: TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: VelvetColors.cocoa,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: GoogleFonts.fraunces().fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: VelvetColors.cocoa,
      ),
    );
  }

  Widget _buildColorBox(Color color, String name, String hex, {Color textColor = VelvetColors.cocoa}) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: VelvetColors.cocoa.withValues(alpha: 0.1)),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: VelvetColors.cocoa),
          ),
          Text(
            hex,
            style: TextStyle(
              fontFamily: GoogleFonts.jetBrainsMono().fontFamily,
              fontSize: 10,
              color: VelvetColors.cocoa.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
