import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Preference keys ─────────────────────────────────────────────────────────
const _kMasterSoundKey = 'pref_master_sound_enabled';
const _kVadyaMusicKey  = 'pref_vadya_music_enabled';
const _kMusicVolumeKey = 'pref_vadya_music_volume';

// ─── Persisted async notifiers ───────────────────────────────────────────────

class MasterSoundNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kMasterSoundKey) ?? true;
  }
  Future<void> toggle(bool value) async {
    state = AsyncValue.data(value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kMasterSoundKey, value);
  }
}

class VadyaMusicNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kVadyaMusicKey) ?? false;
  }
  Future<void> toggle(bool value) async {
    state = AsyncValue.data(value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kVadyaMusicKey, value);
  }
}

class VadyaVolumeNotifier extends AsyncNotifier<double> {
  @override
  Future<double> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_kMusicVolumeKey) ?? 0.7;
  }
  Future<void> setVolume(double value) async {
    state = AsyncValue.data(value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kMusicVolumeKey, value);
  }
}

// ─── Providers ───────────────────────────────────────────────────────────────

final masterSoundProvider = AsyncNotifierProvider<MasterSoundNotifier, bool>(
  MasterSoundNotifier.new,
);

final vadyaMusicProvider = AsyncNotifierProvider<VadyaMusicNotifier, bool>(
  VadyaMusicNotifier.new,
);

final vadyaVolumeProvider = AsyncNotifierProvider<VadyaVolumeNotifier, double>(
  VadyaVolumeNotifier.new,
);

/// Legacy StateProviders kept for backwards-compat with existing widgets.
final masterSoundEnabledProvider = StateProvider<bool>((ref) => true);
final vadyaMusicEnabledProvider  = StateProvider<bool>((ref) => false);

// ─── Song playlist ───────────────────────────────────────────────────────────

const List<String> kVadyaSongs = [
  'sounds/songs/akash_ki_vistarta.mp3',
  'sounds/songs/calculate_the_outcome.mp3',
  'sounds/songs/ek_lakshya.mp3',
  'sounds/songs/equations_in_the_daylight.mp3',
  'sounds/songs/gagan_prarthana.mp3',
  'sounds/songs/gemini_music.mp3',
  'sounds/songs/lakshya_ki_oar.mp3',
  'sounds/songs/logic_ka_tower.mp3',
  'sounds/songs/mownada_matu.mp3',
  'sounds/songs/packet_lock.mp3',
  'sounds/songs/pariyojana.mp3',
  'sounds/songs/pariyojana_breaking_the_seal.mp3',
  'sounds/songs/pariyojana_ka_shikhar.mp3',
  'sounds/songs/pariyojana_ke_vardaan.mp3',
  'sounds/songs/pariyojana_the_blueprint.mp3',
  'sounds/songs/prakriti_ka_saath.mp3',
  'sounds/songs/raghukul_ki_pukaar.mp3',
  'sounds/songs/sankalpa_ki_jwala.mp3',
  'sounds/songs/sapno_ki_bunai.mp3',
  'sounds/songs/shiva-shakti_ki_lalkar.mp3',
  'sounds/songs/siddhi-sadhana.mp3',
  'sounds/songs/the_grand_pariyojana.mp3',
  'sounds/songs/the_inward_path.mp3',
  'sounds/songs/the_mission_pariyojana.mp3',
  'sounds/songs/vidya_ka_prakash.mp3',
  'sounds/songs/waving_in_the_dusk.mp3',
];

// ─── SoundService ─────────────────────────────────────────────────────────────

final soundServiceProvider = Provider<SoundService>((ref) {
  final service = SoundService();
  service.initialize();

  // Keep service in sync with persisted master sound toggle
  ref.listen<AsyncValue<bool>>(masterSoundProvider, (_, next) {
    next.whenData((enabled) => service.setUIMuted(!enabled));
  });

  // Keep service in sync with persisted Vadya music toggle
  ref.listen<AsyncValue<bool>>(vadyaMusicProvider, (prev, next) {
    next.whenData((enabled) {
      service.setVadyaMuted(!enabled);
      if (enabled) {
        service.playRandomSong();
      } else {
        service.stopMusic();
      }
    });
  });

  // Sync music volume
  ref.listen<AsyncValue<double>>(vadyaVolumeProvider, (_, next) {
    next.whenData((vol) => service.setMusicVolume(vol));
  });

  return service;
});

class SoundService {
  final AudioPlayer _effectPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer  = AudioPlayer();
  final _random = Random.secure();

  bool    _isUIMuted    = false;
  bool    _isVadyaMuted = true; // OFF by default
  String? _currentSong;

  Future<void> initialize() async {
    await _effectPlayer.setReleaseMode(ReleaseMode.stop);
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _effectPlayer.setVolume(0.5);
    await _musicPlayer.setVolume(0.7);
  }

  void setUIMuted(bool muted)    => _isUIMuted = muted;
  void setVadyaMuted(bool muted) {
    _isVadyaMuted = muted;
    if (muted) stopMusic();
  }

  Future<void> setMusicVolume(double vol) async {
    try { await _musicPlayer.setVolume(vol.clamp(0.0, 1.0)); } catch (_) {}
  }

  bool    get isUIMuted    => _isUIMuted;
  bool    get isVadyaMuted => _isVadyaMuted;
  String? get currentSong  => _currentSong;
  List<String> get songList => kVadyaSongs;

  /// Pick and play a random song.
  Future<void> playRandomSong() async {
    if (_isVadyaMuted) return;
    try {
      final song = kVadyaSongs[_random.nextInt(kVadyaSongs.length)];
      _currentSong = song;
      await _musicPlayer.stop();
      await _musicPlayer.play(AssetSource(song));
    } catch (_) {}
  }

  /// Play a specific song by index.
  Future<void> playSongAt(int index) async {
    if (_isVadyaMuted) return;
    if (index < 0 || index >= kVadyaSongs.length) return;
    try {
      final song = kVadyaSongs[index];
      _currentSong = song;
      await _musicPlayer.stop();
      await _musicPlayer.play(AssetSource(song));
    } catch (_) {}
  }

  Future<void> playTap() async {
    if (_isUIMuted) return;
    try { await _effectPlayer.play(AssetSource('sounds/tap.wav'), volume: 0.3); } catch (_) {}
  }

  Future<void> playSuccess() async {
    if (_isUIMuted) return;
    try { await _effectPlayer.play(AssetSource('sounds/success.wav'), volume: 0.4); } catch (_) {}
  }

  Future<void> playError() async {
    if (_isUIMuted) return;
    try { await _effectPlayer.play(AssetSource('sounds/error.wav'), volume: 0.4); } catch (_) {}
  }

  Future<void> playPresetSound(int index) async {
    if (_isUIMuted) return;
    try {
      await _effectPlayer.stop();
      switch (index) {
        case 0: await _effectPlayer.play(AssetSource('sounds/tone_security_alert.wav'),    volume: 0.95); break;
        case 1: await _effectPlayer.play(AssetSource('sounds/tone_daily_digest.wav'),      volume: 0.85); break;
        case 2: await _effectPlayer.play(AssetSource('sounds/tone_milestone_fanfare.wav'), volume: 0.90); break;
        case 3: await _effectPlayer.play(AssetSource('sounds/tone_gita_om.wav'),           volume: 0.90); break;
        case 4: await _effectPlayer.play(AssetSource('sounds/tone_job_ping.wav'),          volume: 0.85); break;
        case 5: await _effectPlayer.play(AssetSource('sounds/tone_stealth_pulse.wav'),     volume: 0.90); break;
      }
    } catch (_) {}
  }

  Future<void> playPariyojanaBootSound() async {
    if (_isVadyaMuted) return;
    try {
      await _musicPlayer.stop();
      await _musicPlayer.setVolume(0.9);
      await _musicPlayer.play(
        AssetSource('sounds/Pariyojana.mp3'),
      );
    } catch (_) {}
  }

  Future<void> stopMusic() async {
    try {
      _currentSong = null;
      await _musicPlayer.stop();
    } catch (_) {}
  }
}
