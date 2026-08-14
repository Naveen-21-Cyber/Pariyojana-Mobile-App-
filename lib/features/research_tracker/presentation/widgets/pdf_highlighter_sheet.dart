import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/velvet_colors.dart';
import '../../../../shared_widgets/glass_snackbar.dart';
import '../../../../shared_widgets/clay_card.dart';

class PdfHighlighterSheet extends StatefulWidget {
  final String paperTitle;
  final String? abstractText;

  const PdfHighlighterSheet({
    super.key,
    required this.paperTitle,
    this.abstractText,
  });

  static Future<void> show(BuildContext context, String title, [String? abstractText]) async {
    await showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PdfHighlighterSheet(paperTitle: title, abstractText: abstractText),
    );
  }

  @override
  State<PdfHighlighterSheet> createState() => _PdfHighlighterSheetState();
}

class _PdfHighlighterSheetState extends State<PdfHighlighterSheet> {
  final List<String> _highlights = [];
  final TextEditingController _quoteController = TextEditingController();

  @override
  void dispose() {
    _quoteController.dispose();
    super.dispose();
  }

  void _addHighlight(String text) {
    if (text.trim().isNotEmpty) {
      setState(() {
        _highlights.add(text.trim());
      });
      _quoteController.clear();
      GlassSnackBar.show(context, 'Quote highlight added! 📝');
    }
  }

  void _exportHighlightsToClipboard() {
    if (_highlights.isEmpty) return;
    final buffer = StringBuffer();
    buffer.writeln('# Research Highlights: ${widget.paperTitle}\n');
    for (int i = 0; i < _highlights.length; i++) {
      buffer.writeln('> ${i + 1}. "${_highlights[i]}"\n');
    }
    Clipboard.setData(ClipboardData(text: buffer.toString()));
    GlassSnackBar.show(context, 'Markdown highlights copied to clipboard! 📋');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: BoxDecoration(
        color: VelvetColors.surface(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.picture_as_pdf_rounded, color: VelvetColors.coralPeach, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.paperTitle,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close_rounded, color: VelvetColors.iconColor(context)),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Highlight Input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _quoteController,
                  style: TextStyle(fontSize: 12, color: VelvetColors.textPrimary(context)),
                  decoration: InputDecoration(
                    hintText: 'Enter or paste highlighted quote from PDF...',
                    hintStyle: TextStyle(fontSize: 11, color: VelvetColors.textSecondary(context)),
                    filled: true,
                    fillColor: VelvetColors.inputFill(context),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: VelvetColors.coralPeach,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                onPressed: () => _addHighlight(_quoteController.text),
                child: const Icon(Icons.add_rounded, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 16),

          const Text('HIGHLIGHTED ANNOTATIONS & QUOTES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: VelvetColors.periwinkle, letterSpacing: 1.0)),
          const SizedBox(height: 8),

          Expanded(
            child: _highlights.isEmpty
                ? Center(
                    child: Text(
                      'No quotes highlighted yet.\nType a key excerpt above to annotate this paper.',
                      style: TextStyle(fontSize: 12, color: VelvetColors.textSecondary(context)),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    itemCount: _highlights.length,
                    itemBuilder: (ctx, idx) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: ClayCard(
                        color: VelvetColors.cardSurface(context),
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 36,
                              decoration: BoxDecoration(color: VelvetColors.coralPeach, borderRadius: BorderRadius.circular(2)),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '"${_highlights[idx]}"',
                                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: VelvetColors.textPrimary(context)),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Colors.redAccent),
                              onPressed: () {
                                setState(() {
                                  _highlights.removeAt(idx);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: VelvetColors.coralPeach,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.content_copy_rounded, size: 18),
              label: const Text('Export Markdown Highlights to Clipboard 📋', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              onPressed: _exportHighlightsToClipboard,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 24),
        ],
      ),
    );
  }
}
