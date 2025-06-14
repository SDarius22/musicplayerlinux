import 'dart:async';
import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/providers/albums_provider.dart';
import 'package:musicplayer/providers/app_state_provider.dart';
import 'package:musicplayer/providers/artist_provider.dart';
import 'package:musicplayer/providers/audio_provider.dart';
import 'package:musicplayer/providers/playlist_provider.dart';
import 'package:musicplayer/providers/slider_provider.dart';
import 'package:musicplayer/providers/song_provider.dart';
import 'package:musicplayer/repository/album_repo.dart';
import 'package:musicplayer/repository/artist_repo.dart';
import 'package:musicplayer/repository/playlist_repo.dart';
import 'package:musicplayer/repository/settings_repo.dart';
import 'package:musicplayer/repository/song_repo.dart';
import 'package:musicplayer/screens/loading_screen.dart';
import 'package:musicplayer/services/album_service.dart';
import 'package:musicplayer/services/app_audio_service.dart';
import 'package:musicplayer/services/artist_service.dart';
import 'package:musicplayer/services/playlist_service.dart';
import 'package:musicplayer/services/settings_service.dart';
import 'package:musicplayer/services/song_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_single_instance/flutter_single_instance.dart';
import 'package:provider/provider.dart';
import 'database/objectBox.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  windowMain();
  onError();
  await ObjectBox.initialize();

  if(await FlutterSingleInstance().isFirstInstance()){
    runApp(const MyApp());
  } else {
    updateSettings(args);
    exit(0);
  }
}

void windowMain() {
  doWhenWindowReady(() {
    final win = appWindow;
    win.minSize = const Size(800, 600);
    win.alignment = Alignment.center;
    win.title = 'Music Player${kDebugMode ? ' (Debug)' : ''}';
    win.maximize();
    win.show();
  });
}

Future<void> onError() async {
  final docsDir = await getApplicationDocumentsDirectory();
  String platform = Platform.isWindows ? 'Windows' : Platform.isLinux ? 'Linux' : Platform.isMacOS ? 'macOS' : 'Other';
  File logFile = File(kDebugMode ? '${docsDir.path}/MusicPlayer$platform-Debug/log.txt' : '${docsDir.path}/MusicPlayer$platform/log.txt');
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details, forceReport: true);
    try{
      logFile.writeAsStringSync('${DateTime.now()}: ${details.toString()}\n', mode: FileMode.append);
    } catch (e) {
      logFile.createSync(recursive: true);
      logFile.writeAsStringSync('${DateTime.now()}: ${details.toString()}\n', mode: FileMode.append);
    }
  };
}

void updateSettings(List<String> args) {
  if (args.isNotEmpty) {
    debugPrint("App is already running, should add to queue!");
    // Settings newSettings = SettingsController.settings;
    // newSettings.queue = args;
    // newSettings.index = -100;
    // SettingsController.settings = newSettings;
  }
  else{
    debugPrint("App is already running");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AlbumRepository>(
          create: (_) => AlbumRepository(),
        ),
        Provider<ArtistRepository>(
          create: (_) => ArtistRepository(),
        ),
        Provider<PlaylistRepository>(
          create: (_) => PlaylistRepository(),
        ),
        Provider<SettingsRepo>(
          create: (_) => SettingsRepo(),
        ),
        Provider<SongsRepository>(
          create: (_) => SongsRepository(),
        ),
        Provider<AlbumService>(
          create: (context) => AlbumService(context.read<AlbumRepository>()),
        ),
        Provider<ArtistService>(
          create: (context) => ArtistService(context.read<ArtistRepository>()),
        ),
        Provider<SettingsService>(
          create: (context) => SettingsService(context.read<SettingsRepo>()),
        ),
        Provider<SongService>(
          create: (context) => SongService(
              context.read<SongsRepository>(),
              context.read<SettingsService>(),
              context.read<AlbumService>(),
              context.read<ArtistService>()
          ),
        ),
        Provider<PlaylistService>(
          create: (context) => PlaylistService(context.read<PlaylistRepository>(), context.read<SongService>()),
        ),
        ChangeNotifierProvider<AlbumProvider> (
          create: (context) => AlbumProvider(context.read<AlbumService>()),
        ),
        ChangeNotifierProvider<ArtistProvider> (
          create: (context) => ArtistProvider(context.read<ArtistService>()),
        ),
        ChangeNotifierProvider<AudioProvider>(
          create: (context) => AudioProvider()// ..init(context.read<SettingsService>()),
        ),
        ChangeNotifierProvider<PlaylistProvider> (
          create: (context) => PlaylistProvider(context.read<PlaylistService>()),
        ),
        ChangeNotifierProvider<SongProvider> (
          create: (context) => SongProvider(context.read<SongService>()),
        ),
        ChangeNotifierProvider<SliderProvider>(
          create: (context) => SliderProvider(context.read<AudioProvider>()),
        ),
        ChangeNotifierProvider<AppStateProvider>(
          create: (context) => AppStateProvider(context.read<AudioProvider>(), context.read<SettingsService>()),
        ),
        
      ],
      child: MaterialApp(
        builder: BotToastInit(),
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0E0E0E),
        ),
        home: LoadingScreen(),
      ),
    );
  }
}



