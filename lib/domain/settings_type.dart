import 'package:objectbox/objectbox.dart';

@Entity()
class Settings{
  @Id()
  int id = 0;

  String mongoID = '';
  String email = '';
  String password = '';
  List<String> deviceList = [];
  String primaryDevice = '';
  List<String> missingSongs = []; // this is the list of songs that are missing from the library

  String directory = '/'; // not in the database, only in the settings local db

  bool firstTime = true;
  bool systemTray = true;
  bool fullClose = false;
  bool appNotifications = true;
  String deezerARL = '';
  String queueAdd = 'last';
  String queuePlay = 'all';

  int index = 0; // this is the index of the song in the unshuffled queue
  int slider = 0; // this is the time in milliseconds
  // bool playing = false;
  bool repeat = false;
  bool shuffle = false;
  double balance = 0;
  double speed = 1;
  double volume = 0.5;
  int sleepTimer = 0; // this is the time to sleep in milliseconds
  List<String> queue = []; // this is the queue of songs, unshuffled
  List<String> shuffledQueue = []; // this is the queue of songs, shuffled

  // Colors
  int lightColor = 0xFFFFFFFF;
  int darkColor = 0xFF000000;

  Map<String, dynamic> toMap() {
    return {
      'index': index,
      'email': email,
      'password': password,
      'deviceList': deviceList,
      'primaryDevice': primaryDevice,
      'firstTime': firstTime,
      'systemTray': systemTray,
      'fullClose': fullClose,
      'appNotifications': appNotifications,
      'deezerARL': deezerARL,
      'queueAdd': queueAdd,
      'queuePlay': queuePlay,
      'queue': queue,
      'missingSongs': missingSongs,
    };
  }

  void fromMap(Map<String, dynamic> map) {
    mongoID = map['id'];
    deviceList = List<String>.from(map['deviceList']);
    primaryDevice = map['primaryDevice'];
    index = map['index'];
    firstTime = map['firstTime'];
    systemTray = map['systemTray'];
    fullClose = map['fullClose'];
    appNotifications = map['appNotifications'];
    deezerARL = map['deezerARL'];
    queueAdd = map['queueAdd'];
    queuePlay = map['queuePlay'];
    queue = List<String>.from(map['queue']);
    missingSongs = List<String>.from(map['missingSongs']);
  }
}