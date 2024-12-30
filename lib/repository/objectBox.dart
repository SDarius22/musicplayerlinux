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
    final dbPath = kDebugMode ? '${docsDir.path}/musicplayer-debug ${Platform.operatingSystem}' : '${docsDir.path}/musicplayer ${Platform.operatingSystem}';
    if (Store.isOpen(dbPath)) {
      store = Store.attach(getObjectBoxModel(),dbPath);
    }
    else{
      store = await openStore(directory: dbPath);
    }
  }
}