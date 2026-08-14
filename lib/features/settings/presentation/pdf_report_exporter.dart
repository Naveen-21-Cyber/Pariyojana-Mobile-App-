import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vibration/vibration.dart';
import '../../../shared_widgets/glass_snackbar.dart';
import '../../../core/database/database.dart';
import '../../../core/profile/user_profile_provider.dart';

class PdfReportExporter {
  static Future<void> exportExecutiveReport(BuildContext context, WidgetRef ref) async {
    try {
      final hasVib = await Vibration.hasVibrator();
      if (hasVib == true) {
        await Vibration.vibrate(duration: 60, amplitude: 255);
      } else {
        await HapticFeedback.heavyImpact();
      }
    } catch (_) {
      await HapticFeedback.heavyImpact();
    }

    List<Project> projects = [];
    List<ResearchPaper> papers = [];
    List<JobApplication> jobs = [];
    List<Idea> ideas = [];

    try {
      final database = ref.read(databaseProvider);
      projects = await database.select(database.projects).get();
      papers = await database.select(database.researchPapers).get();
      jobs = await database.select(database.jobApplications).get();
      ideas = await database.select(database.ideas).get();
    } catch (_) {}

    final dateStr = DateTime.now().toString().split(' ').first;
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header Banner
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.deepOrange100,
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'PARIYOJANA OS — EXECUTIVE PORTFOLIO AUDIT REPORT',
                    style: pw.TextStyle(
                      fontSize: 15,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.brown900,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'SQLCipher AES-256 Encrypted Local Store | Generated: $dateStr',
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.brown700),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 16),

            // Section 1: Projects
            pw.Text('1. ENGINEERING PROJECTS (${projects.length})', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 6),
            if (projects.isEmpty)
              pw.Text('No projects logged.', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700))
            else
              pw.TableHelper.fromTextArray(
                headers: ['Project Name', 'Status', 'Repository / Path', 'Tech Stack'],
                data: projects.map((p) => [
                  p.name,
                  p.status,
                  p.repoUrl ?? 'Local Repository',
                  p.techStack ?? 'Flutter / Clean Architecture',
                ]).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 9),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.brown600),
                rowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
                cellStyle: const pw.TextStyle(fontSize: 9),
                cellAlignment: pw.Alignment.centerLeft,
                cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            pw.SizedBox(height: 16),

            // Section 2: Research Papers
            pw.Text('2. RESEARCH & ACADEMIC PAPERS (${papers.length})', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 6),
            if (papers.isEmpty)
              pw.Text('No research papers logged.', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700))
            else
              pw.TableHelper.fromTextArray(
                headers: ['Paper Title', 'Status', 'Venue', 'Citations'],
                data: papers.map((p) => [
                  p.title,
                  p.status,
                  p.targetVenue ?? 'Academic Journal',
                  '${p.citationCount}',
                ]).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 9),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey700),
                rowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
                cellStyle: const pw.TextStyle(fontSize: 9),
                cellAlignment: pw.Alignment.centerLeft,
                cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            pw.SizedBox(height: 16),

            // Section 3: Job Applications
            pw.Text('3. CAREER & JOB APPLICATIONS (${jobs.length})', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 6),
            if (jobs.isEmpty)
              pw.Text('No job applications logged.', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700))
            else
              pw.TableHelper.fromTextArray(
                headers: ['Company', 'Role', 'Stage', 'Outreach Channel'],
                data: jobs.map((j) => [
                  j.company,
                  j.role,
                  j.status,
                  j.outreachChannel ?? 'Direct Portal',
                ]).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 9),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.teal700),
                rowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
                cellStyle: const pw.TextStyle(fontSize: 9),
                cellAlignment: pw.Alignment.centerLeft,
                cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            pw.SizedBox(height: 16),

            // Section 4: Idea Vault Summary
            pw.Text('4. IDEA VAULT CAPTURES (${ideas.length})', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 6),
            if (ideas.isEmpty)
              pw.Text('No idea captures logged.', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700))
            else
              ...ideas.take(5).map((i) => pw.Bullet(text: '[${i.category.toUpperCase()}] ${i.content}', style: const pw.TextStyle(fontSize: 9))),

            pw.SizedBox(height: 20),

            // Author Sign-off
            () {
              final profile = ref.read(userProfileProvider);
              final authorName = profile.fullName.isNotEmpty ? profile.fullName : 'Command Center User';
              final authorRole = profile.title.isNotEmpty ? profile.title : 'Pariyojana OS User';
              final portfolio = profile.portfolioUrl;
              final github = profile.githubUrl;

              return pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Report Owner / Author:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                    pw.SizedBox(height: 3),
                    pw.Text('$authorName — $authorRole', style: const pw.TextStyle(fontSize: 9)),
                    if (portfolio.isNotEmpty || github.isNotEmpty)
                      pw.Text(
                        '${portfolio.isNotEmpty ? "Portfolio: $portfolio" : ""}${portfolio.isNotEmpty && github.isNotEmpty ? " | " : ""}${github.isNotEmpty ? "GitHub: $github" : ""}',
                        style: const pw.TextStyle(fontSize: 9, color: PdfColors.blue800),
                      ),
                  ],
                ),
              );
            }(),
          ];
        },
      ),
    );

    final outputDir = await getTemporaryDirectory();
    final pdfFile = File('${outputDir.path}/Pariyojana_Executive_Report_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await pdfFile.writeAsBytes(await pdf.save());

    await Share.shareXFiles(
      [XFile(pdfFile.path, mimeType: 'application/pdf', name: 'Pariyojana_Executive_Report.pdf')],
      subject: 'Pariyojana OS — Executive Portfolio Audit Report (PDF File)',
      text: 'Attached is the official Pariyojana OS Executive Audit Report PDF file.',
    );

    if (context.mounted) {
      GlassSnackBar.show(
        context,
        'Executive PDF Report generated & shared! 📄🛡️',
        icon: Icons.picture_as_pdf_rounded,
      );
    }
  }
}
