import 'package:musicplayer/entities/app_settings.dart';
import 'package:musicplayer/entities/audio_settings.dart';
import 'package:musicplayer/repository/settings_repo.dart';

class SettingsService {
  final SettingsRepo settingsRepo;

  SettingsService(this.settingsRepo);

  AudioSettings? getAudioSettings() {
    AudioSettings? settings = settingsRepo.getAudioSettings();
    if (settings == null) {
      settingsRepo.initAudioSettings();
      settings = settingsRepo.getAudioSettings();
    }
    return settings;
  }

  Future<void> updateAudioSettings(AudioSettings settings) async {
     settingsRepo.updateAudioSettings(settings);
  }

  Future<void> resetAudioSettings() async {
     settingsRepo.resetAudioSettings();
  }

  AppSettings? getAppSettings() {
    AppSettings? settings =  settingsRepo.getAppSettings();
    if (settings == null) {
       settingsRepo.initAppSettings();
      settings =  settingsRepo.getAppSettings();
    }
    return settings;
  }

  Future<void> updateAppSettings(AppSettings settings) async {
     settingsRepo.updateAppSettings(settings);
  }

  Future<void> resetAppSettings() async {
     settingsRepo.resetAppSettings();
  }
}