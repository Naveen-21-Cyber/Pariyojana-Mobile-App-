import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FeatureTogglesState {
  final bool isCmdCentreEnabled;
  final bool isMitnickAiEnabled;

  const FeatureTogglesState({
    this.isCmdCentreEnabled = false,
    this.isMitnickAiEnabled = false,
  });

  FeatureTogglesState copyWith({
    bool? isCmdCentreEnabled,
    bool? isMitnickAiEnabled,
  }) {
    return FeatureTogglesState(
      isCmdCentreEnabled: isCmdCentreEnabled ?? this.isCmdCentreEnabled,
      isMitnickAiEnabled: isMitnickAiEnabled ?? this.isMitnickAiEnabled,
    );
  }
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize sharedPreferencesProvider in ProviderScope overrides');
});

final featureTogglesProvider = StateNotifierProvider<FeatureTogglesNotifier, FeatureTogglesState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return FeatureTogglesNotifier(prefs);
});

class FeatureTogglesNotifier extends StateNotifier<FeatureTogglesState> {
  final SharedPreferences _prefs;

  FeatureTogglesNotifier(this._prefs)
      : super(FeatureTogglesState(
          isCmdCentreEnabled: _prefs.getBool('feature_cmd_centre') ?? false,
          isMitnickAiEnabled: _prefs.getBool('feature_mitnick_ai') ?? false,
        ));

  Future<void> setCmdCentreEnabled(bool enabled) async {
    state = state.copyWith(isCmdCentreEnabled: enabled);
    await _prefs.setBool('feature_cmd_centre', enabled);
  }

  Future<void> setMitnickAiEnabled(bool enabled) async {
    state = state.copyWith(isMitnickAiEnabled: enabled);
    await _prefs.setBool('feature_mitnick_ai', enabled);
  }
}
