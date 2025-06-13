import 'package:musicplayer/database/objectBox.dart';
import 'package:musicplayer/database/objectbox.g.dart';
import 'package:musicplayer/entities/app_settings.dart';
import 'package:musicplayer/entities/audio_settings.dart';

class SettingsRepo {
  get audioSettingsBox => ObjectBox.store.box<AudioSettings>();
  get appSettingsBox => ObjectBox.store.box<AppSettings>();

  void addAudioSettings(AudioSettings settings)  {
     audioSettingsBox.put(settings);
  }

  AudioSettings? getAudioSettings() {
    return audioSettingsBox.query(AudioSettings_.id.equals(1)).build().findUnique();
  }

  void updateAudioSettings(AudioSettings settings)  {
     audioSettingsBox.put(settings);
  }

  void deleteAudioSettings(AudioSettings settings)  {
     audioSettingsBox.remove(settings.id);
  }

  void resetAudioSettings()  {
     audioSettingsBox.removeAll();
     addAudioSettings(AudioSettings());
  }

  void initAudioSettings()  {
    if ( getAudioSettings() == null) {
       addAudioSettings(AudioSettings());
    }
  }

  void addAppSettings(AppSettings settings)  {
     appSettingsBox.put(settings);
  }

  AppSettings? getAppSettings()  {
    return appSettingsBox.query(AppSettings_.id.equals(1)).build().findUnique();
  }

  void updateAppSettings(AppSettings settings)  {
     appSettingsBox.put(settings);
  }

  void deleteAppSettings(AppSettings settings)  {
     appSettingsBox.remove(settings.id);
  }

  void resetAppSettings()  {
     appSettingsBox.removeAll();
     addAppSettings(AppSettings());
  }

  void initAppSettings()  {
    if ( getAppSettings() == null) {
       addAppSettings(AppSettings());
    }
  }
}