import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' show Platform;
import 'objectbox.g.dart'; // created by `flutter pub run build_runner build`

class ObjectBox {
  /// The Store of this app.
  static late final Store store;

  /// Create an instance of ObjectBox to use throughout the app.
  static Future initialize() async {
    final docsDir = await getApplicationDocumentsDirectory();
    String platform = Platform.isWindows ? 'Windows' : Platform.isLinux ? 'Linux' : Platform.isMacOS ? 'macOS' : 'Other';
    final dbPath = kDebugMode ? '${docsDir.path}/MusicPlayer$platform-Debug' : '${docsDir.path}/MusicPlayer$platform';
    if (Store.isOpen(dbPath)) {
      store = Store.attach(getObjectBoxModel(),dbPath);
    }
    else{
      store = await openStore(directory: dbPath);
    }
  }
}