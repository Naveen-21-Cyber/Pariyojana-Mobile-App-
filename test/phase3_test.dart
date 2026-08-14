import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' as drift;
import 'package:velvet/core/database/database.dart';
import 'package:velvet/features/project_tracker/data/repositories/project_repository_impl.dart';
import 'package:velvet/features/project_tracker/domain/repositories/project_repository.dart';
import 'package:velvet/features/research_tracker/data/repositories/research_repository_impl.dart';
import 'package:velvet/features/research_tracker/domain/repositories/research_repository.dart';
import 'package:velvet/features/job_tracker/data/repositories/job_repository_impl.dart';
import 'package:velvet/features/job_tracker/domain/repositories/job_repository.dart';

void main() {
  late VelvetDatabase db;
  late ProjectRepository projectRepo;
  late ResearchRepository researchRepo;
  late JobRepository jobRepo;

  setUp(() {
    db = VelvetDatabase(NativeDatabase.memory());
    projectRepo = ProjectRepositoryImpl(db);
    researchRepo = ResearchRepositoryImpl(db);
    jobRepo = JobRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('ResearchRepository CRUD & Revision Tests', () {
    test('Can manage papers and add revision logs', () async {
      // 1. Initial empty
      var papers = await researchRepo.watchPapers().first;
      expect(papers.isEmpty, true);

      // 2. Insert paper
      final id = await researchRepo.insertPaper(
        ResearchPapersCompanion.insert(
          title: 'Asymmetric Cryptography in Mobile Environments',
          status: 'Draft',
        ),
      );
      expect(id > 0, true);

      papers = await researchRepo.watchPapers().first;
      expect(papers.length, 1);
      expect(papers.first.title, 'Asymmetric Cryptography in Mobile Environments');
      expect(papers.first.status, 'Draft');

      // 3. Add revisions
      var revisions = await researchRepo.watchRevisions(id).first;
      expect(revisions.isEmpty, true);

      final revId = await researchRepo.insertRevision(
        ResearchRevisionsCompanion.insert(
          paperId: id,
          note: 'Initial draft containing proof notes',
        ),
      );
      expect(revId > 0, true);

      revisions = await researchRepo.watchRevisions(id).first;
      expect(revisions.length, 1);
      expect(revisions.first.note, 'Initial draft containing proof notes');

      // 4. Update status and citations
      final paper = papers.first;
      final updated = paper.copyWith(
        status: 'Preliminary Upload',
        citationCount: 4,
      );
      final updateSuccess = await researchRepo.updatePaper(updated);
      expect(updateSuccess, true);

      papers = await researchRepo.watchPapers().first;
      expect(papers.first.status, 'Preliminary Upload');
      expect(papers.first.citationCount, 4);

      // 5. Delete paper
      final deleteSuccess = await researchRepo.deletePaper(id);
      expect(deleteSuccess, true);

      papers = await researchRepo.watchPapers().first;
      expect(papers.isEmpty, true);
    });
  });

  group('JobRepository CRUD Tests', () {
    test('Can manage job applications', () async {
      var apps = await jobRepo.watchApplications().first;
      expect(apps.isEmpty, true);

      // Insert job application
      final id = await jobRepo.insertApplication(
        JobApplicationsCompanion.insert(
          company: 'FIS Global',
          role: 'Security Analyst',
          status: 'Applied',
        ),
      );
      expect(id > 0, true);

      apps = await jobRepo.watchApplications().first;
      expect(apps.length, 1);
      expect(apps.first.company, 'FIS Global');
      expect(apps.first.role, 'Security Analyst');

      // Update stage
      final app = apps.first;
      final updated = app.copyWith(status: 'Interview');
      final updateSuccess = await jobRepo.updateApplication(updated);
      expect(updateSuccess, true);

      apps = await jobRepo.watchApplications().first;
      expect(apps.first.status, 'Interview');

      // Delete
      final deleteSuccess = await jobRepo.deleteApplication(id);
      expect(deleteSuccess, true);

      apps = await jobRepo.watchApplications().first;
      expect(apps.isEmpty, true);
    });
  });

  group('Cross-linking & Nudge Alerts Tests', () {
    test('Can link papers/jobs to projects and verify stall/follow-up triggers', () async {
      // 1. Insert Project
      final projectId = await projectRepo.insertProject(
        ProjectsCompanion.insert(
          name: 'Core Cryptography Library',
          status: 'Active',
          priority: 'High',
        ),
      );

      // 2. Link Paper and Job to this Project
      final paperId = await researchRepo.insertPaper(
        ResearchPapersCompanion.insert(
          title: 'Advanced Encryptions',
          status: 'Preliminary Upload',
          projectId: drift.Value(projectId),
          // Set updatedAt to 8 days ago to trigger the stall warning
          updatedAt: drift.Value(DateTime.now().subtract(const Duration(days: 8))),
        ),
      );

      final appId = await jobRepo.insertApplication(
        JobApplicationsCompanion.insert(
          company: 'Google DeepMind',
          role: 'Research Scientist',
          status: 'Outreach Sent',
          projectId: drift.Value(projectId),
          followUpDate: drift.Value(DateTime.now().subtract(const Duration(days: 1))),
        ),
      );

      // 3. Verify cross-link querying
      final linkedPapers = await researchRepo.watchPapersForProject(projectId).first;
      expect(linkedPapers.length, 1);
      expect(linkedPapers.first.id, paperId);

      final linkedJobs = await jobRepo.watchApplicationsForProject(projectId).first;
      expect(linkedJobs.length, 1);
      expect(linkedJobs.first.id, appId);

      // 4. Assert Research stall warning logic
      final paper = linkedPapers.first;
      final isStalled = paper.status == 'Preliminary Upload' &&
          DateTime.now().difference(paper.updatedAt).inDays >= 7;
      expect(isStalled, true);

      // 5. Assert Job follow-up warning logic
      final app = linkedJobs.first;
      final isFollowUpDue = app.status == 'Outreach Sent' &&
          (app.followUpDate != null && DateTime.now().isAfter(app.followUpDate!));
      expect(isFollowUpDue, true);
    });
  });
}
