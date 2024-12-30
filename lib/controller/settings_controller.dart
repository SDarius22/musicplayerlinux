import 'package:flutter/cupertino.dart';

import '../domain/settings_type.dart';
import '../repository/objectBox.dart';


class SettingsController {
  static final SettingsController _instance = SettingsController._internal();

  factory SettingsController() => _instance;

  SettingsController._internal();

  void _updateSettings(void Function(Settings) updateFn) {
    final updatedSettings = settings;
    updateFn(updatedSettings);
    ObjectBox.store.box<Settings>().put(updatedSettings);
  }

  static String get currentSongPath => queue.isNotEmpty? shuffle ? shuffledQueue[index] : queue[index] : '';
  static List<String> get currentQueue => shuffle ? shuffledQueue : queue;

  static Settings get settings => ObjectBox.store.box<Settings>().getAll().last;

  static ValueNotifier<String> mongoIDNotifier = ValueNotifier<String>(settings.mongoID);

  static String get mongoID => mongoIDNotifier.value;

  static set mongoID(String mongoID) {
    mongoIDNotifier.value = mongoID;
    _instance._updateSettings((settings) => settings.mongoID = mongoID);
  }

  static ValueNotifier<String> emailNotifier = ValueNotifier<String>(settings.email);

  static String get email => emailNotifier.value;

  static set email(String email) {
    emailNotifier.value = email;
    _instance._updateSettings((settings) => settings.email = email);
  }

  static ValueNotifier<String> passwordNotifier = ValueNotifier<String>(settings.password);

  static String get password => settings.password;

  static set password(String password) {
    passwordNotifier.value = password;
    _instance._updateSettings((settings) => settings.password = password);
  }

  static List<String> get deviceList => settings.deviceList;

  static set deviceList(List<String> deviceList) =>
      _instance._updateSettings((settings) => settings.deviceList = deviceList);

  static String get primaryDevice => settings.primaryDevice;

  static set primaryDevice(String primaryDevice) =>
      _instance._updateSettings((settings) => settings.primaryDevice = primaryDevice);

  static List<String> get missingSongs => settings.missingSongs;

  static set missingSongs(List<String> missingSongs) =>
      _instance._updateSettings((settings) => settings.missingSongs = missingSongs);

  static ValueNotifier<String> directoryNotifier = ValueNotifier<String>(settings.directory);

  static String get directory => settings.directory;

  static set directory(String directory) {
    directoryNotifier.value = directory;
    _instance._updateSettings((settings) => settings.directory = directory);
  }

  static ValueNotifier<bool> firstTimeNotifier = ValueNotifier<bool>(settings.firstTime);

  static bool get firstTime => settings.firstTime;

  static set firstTime(bool firstTime) {
    firstTimeNotifier.value = firstTime;
    _instance._updateSettings((settings) => settings.firstTime = firstTime);
  }

  static ValueNotifier<bool> systemTrayNotifier = ValueNotifier<bool>(settings.systemTray);

  static bool get systemTray => settings.systemTray;

  static set systemTray(bool systemTray) {
    systemTrayNotifier.value = systemTray;
    _instance._updateSettings((settings) => settings.systemTray = systemTray);
  }

  static ValueNotifier<bool> fullCloseNotifier = ValueNotifier<bool>(settings.fullClose);

  static bool get fullClose => settings.fullClose;

  static set fullClose(bool fullClose) {
    fullCloseNotifier.value = fullClose;
    _instance._updateSettings((settings) => settings.fullClose = fullClose);
  }

  static ValueNotifier<bool> appNotificationsNotifier = ValueNotifier<bool>(settings.appNotifications);

  static bool get appNotifications => settings.appNotifications;

  static set appNotifications(bool appNotifications) {
    appNotificationsNotifier.value = appNotifications;
    _instance._updateSettings((settings) => settings.appNotifications = appNotifications);
  }


  static String get deezerARL => settings.deezerARL;

  static ValueNotifier<String> deezerARLNotifier = ValueNotifier<String>(settings.deezerARL);

  static set deezerARL(String deezerARL) {
    deezerARLNotifier.value = deezerARL;
    _instance._updateSettings((settings) => settings.deezerARL = deezerARL);
  }

  static ValueNotifier<String> queueAddNotifier = ValueNotifier<String>(settings.queueAdd);

  static String get queueAdd => settings.queueAdd;

  static set queueAdd(String queueAdd) {
    queueAddNotifier.value = queueAdd;
    _instance._updateSettings((settings) => settings.queueAdd = queueAdd);
  }

  static ValueNotifier<String> queuePlayNotifier = ValueNotifier<String>(settings.queuePlay);

  static String get queuePlay => settings.queuePlay;

  static set queuePlay(String queuePlay) {
    queuePlayNotifier.value = queuePlay;
    _instance._updateSettings((settings) => settings.queuePlay = queuePlay);
  }

  static ValueNotifier<int> indexNotifier = ValueNotifier<int>(settings.index);

  static int get index => settings.index;

  static set index(int newIndex) {
    print("Index set to $newIndex");
    slider = 0;
    playing = false;
    _instance._updateSettings((settings) => settings.index = newIndex);
    indexNotifier.value = -1;
    indexNotifier.value = newIndex;
  }

  static ValueNotifier<int> sliderNotifier = ValueNotifier<int>(settings.slider);

  static int get slider => settings.slider;

  static set slider(int slider) {
    sliderNotifier.value = slider;
    _instance._updateSettings((settings) => settings.slider = slider);
  }

  static ValueNotifier<bool> playingNotifier = ValueNotifier<bool>(false);

  static bool get playing => playingNotifier.value;

  static set playing(bool playing) {
    playingNotifier.value = playing;
  }

  static ValueNotifier<bool> repeatNotifier = ValueNotifier<bool>(settings.repeat);

  static bool get repeat => settings.repeat;

  static set repeat(bool repeat) {
    repeatNotifier.value = repeat;
    _instance._updateSettings((settings) => settings.repeat = repeat);
  }

  static ValueNotifier<bool> shuffleNotifier = ValueNotifier<bool>(settings.shuffle);

  static bool get shuffle => settings.shuffle;

  static set shuffle(bool shuffle) {
    shuffleNotifier.value = shuffle;
    _instance._updateSettings((settings) => settings.shuffle = shuffle);
  }

  static ValueNotifier<double> balanceNotifier = ValueNotifier<double>(settings.balance);

  static double get balance => settings.balance;

  static set balance(double balance) {
    balanceNotifier.value = balance;
    _instance._updateSettings((settings) => settings.balance = balance);
  }

  static ValueNotifier<double> speedNotifier = ValueNotifier<double>(settings.speed);

  static double get speed => settings.speed;

  static set speed(double speed) {
    speedNotifier.value = speed;
    _instance._updateSettings((settings) => settings.speed = speed);
  }

  static ValueNotifier<double> volumeNotifier = ValueNotifier<double>(settings.volume);

  static double get volume => settings.volume;

  static set volume(double volume) {
    volumeNotifier.value = volume;
    _instance._updateSettings((settings) => settings.volume = volume);
  }

  static ValueNotifier<int> sleepTimerNotifier = ValueNotifier<int>(settings.sleepTimer);

  static int get sleepTimer => settings.sleepTimer;

  static set sleepTimer(int sleepTimer) {
    sleepTimerNotifier.value = sleepTimer;
    _instance._updateSettings((settings) => settings.sleepTimer = sleepTimer);
  }

  static List<String> get queue => settings.queue;

  static set queue(List<String> queue) {
    shuffledQueue = List<String>.from(queue)..shuffle();
    _instance._updateSettings((settings) => settings.queue = queue);
  }

  static List<String> get shuffledQueue => settings.shuffledQueue;

  static set shuffledQueue(List<String> shuffledQueue) =>
      _instance._updateSettings((settings) => settings.shuffledQueue = shuffledQueue);

  static ValueNotifier<Color> lightColorNotifier = ValueNotifier<Color>(Color(settings.lightColor));

  static int get lightColor => settings.lightColor;

  static set lightColor(int lightColor) {
    lightColorNotifier.value = Color(lightColor);
    _instance._updateSettings((settings) => settings.lightColor = lightColor);
  }

  static ValueNotifier<Color> darkColorNotifier = ValueNotifier<Color>(Color(settings.darkColor));

  static int get darkColor => settings.darkColor;

  static set darkColor(int darkColor) {
    darkColorNotifier.value = Color(darkColor);
    _instance._updateSettings((settings) => settings.darkColor = darkColor);
  }

  static void save() {
    ObjectBox.store.box<Settings>().put(settings);
  }

  static void delete() {
    ObjectBox.store.box<Settings>().remove(settings.id);
  }

  static void clear() {
    ObjectBox.store.box<Settings>().removeAll();
  }

  static void init() {
    if (ObjectBox.store.box<Settings>().isEmpty()) {
      ObjectBox.store.box<Settings>().put(Settings());
    }
    // Stream<Query> query = ObjectBox.store.box<Settings>().query().watch(triggerImmediately: true);
    // query.listen((event) {
    //   print("Settings updated");
    //   var newSettings = event.find().last;
    //   indexNotifier.value = newSettings.index;
    // });
  }
}
