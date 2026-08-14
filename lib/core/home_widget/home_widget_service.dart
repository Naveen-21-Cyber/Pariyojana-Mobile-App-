import 'package:home_widget/home_widget.dart';
import 'package:logger/logger.dart';

/// Service that pushes data to the Android home screen widget.
/// Call [updateWidget] whenever idea or project counts change.
///
/// Data flow:
///   Flutter → HomeWidget.saveWidgetData → SharedPreferences →
///   PariyojanaWidget.kt reads on next update cycle.
class HomeWidgetService {
  static final _log = Logger();
  static const _appGroupId = 'com.navii.pariyojana';

  static Future<void> init() async {
    await HomeWidget.setAppGroupId(_appGroupId);
  }

  /// Push current counts to the Android home screen widget.
  /// [ideaCount]    — total ideas in vault
  /// [projectCount] — active (non-completed) projects
  static Future<void> updateWidget({
    required int ideaCount,
    required int projectCount,
  }) async {
    try {
      await Future.wait([
        HomeWidget.saveWidgetData<int>(
            'pariyojana_idea_count', ideaCount),
        HomeWidget.saveWidgetData<int>(
            'pariyojana_project_count', projectCount),
      ]);
      await HomeWidget.updateWidget(
        androidName: 'PariyojanaWidget',
      );
    } catch (e) {
      // Widget update failure is non-fatal — app works fine without it.
      _log.w('[HomeWidgetService] Widget update failed: $e');
    }
  }
}
