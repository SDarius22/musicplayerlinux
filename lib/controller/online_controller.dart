import 'dart:convert';

import 'package:deezer/deezer.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:musicplayer/controller/settings_controller.dart';

class OnlineController{
  static final OnlineController _instance = OnlineController._internal();

  factory OnlineController() => _instance;

  OnlineController._internal();


  final secretKey = encrypt.Key.fromUtf8("eP9CLbcaUxKfvhhFLWcusXWo3ZS2nR1P");
  final iv = encrypt.IV.fromUtf8("1234567890123456");
  static late Deezer instance;
  ValueNotifier<bool> loggedInNotifier = ValueNotifier<bool>(false);
  ValueNotifier<bool> downloadNotifier = ValueNotifier<bool>(false);

  static void init(){
    initDeezer();
    SettingsController.deezerARLNotifier.addListener(() async {
      instance.close();
      await initDeezer();
    });
  }


  Future<String> encryptData(String data) async {
    final encrypter =
    encrypt.Encrypter(encrypt.AES(secretKey, mode: encrypt.AESMode.cbc, padding: 'PKCS7'));
    final encrypted = encrypter.encrypt(data, iv: iv);
    return encrypted.base64;
  }

  static Future<dynamic> initDeezer() async {
    debugPrint("Initialising Deezer");
    debugPrint(SettingsController.deezerARL);
    try {
      instance = await Deezer.create(arl: SettingsController.deezerARL);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> loginUser() async {
    debugPrint("Log in");
    var data = "{'email': '${SettingsController.email}', 'password': '${SettingsController.password}'}";
    var encryptedData = await encryptData(data);
    debugPrint(encryptedData);
    var uri = Uri.parse('http://localhost:8000/api/get-user');
    var request = http.Request('GET', uri)
      ..headers.addAll({
        'Content-Type': 'application/json',
      })
      ..body = jsonEncode({
        'data': encryptedData,
      });
    var response = await request.send();
    if (response.statusCode == 200) {
      debugPrint("Success");
      String body = await response.stream.bytesToString();
      Map<String, dynamic> data = jsonDecode(body);
      if (data['message'] == "Not premium user") {
        SettingsController.mongoID = data['id'];
      } else {
        // SettingsController.fromMap(data);
      }
      // loggedInNotifier.value = true;
      // settingsBox.put(settings);
    } else {
      debugPrint("Failed");
      debugPrint(response.statusCode.toString());
      debugPrint(response.stream.bytesToString().toString());
    }
  }

  Future<void> registerUser() async {
    debugPrint("Register user");
    var data = "{'email': '${SettingsController.email}',"
        "'password': '${SettingsController.password}',"
        "'index': ${SettingsController.index},"
        "'deviceList': ${SettingsController.deviceList},"
        "'primaryDevice': ${SettingsController.primaryDevice},"
        "'firstTime': ${SettingsController.firstTime},"
        "'systemTray': ${SettingsController.systemTray},"
        "'fullClose': ${SettingsController.fullClose},"
        "'appNotifications': ${SettingsController.appNotifications},"
        "'deezerARL': ${SettingsController.deezerARL},"
        "'queueAdd': ${SettingsController.queueAdd},"
        "'queuePlay': ${SettingsController.queuePlay},"
        "'queue': ${SettingsController.queue},"
        "'missingSongs': ${SettingsController.missingSongs}}";

    var encryptedData = await encryptData(data);
    debugPrint(encryptedData);
    var uri = Uri.parse('http://localhost:8000/api/upload-user');
    var request = http.Request('POST', uri)
      ..headers.addAll({
        'Content-Type': 'application/json',
      })
      ..body = jsonEncode({
        'data': encryptedData,
      });
    var response = await request.send();
    if (response.statusCode == 201) {
      debugPrint("Success");
      String body = await response.stream.bytesToString();
      Map<String, dynamic> data = jsonDecode(body);
      SettingsController.mongoID = data['id'];
      // loggedInNotifier.value = true;
      // settingsBox.put(settings);
    } else {
      debugPrint("Failed");
      debugPrint(response.statusCode.toString());
      debugPrint(await response.stream.bytesToString()..toString());
    }
  }

  static Future<dynamic> searchDeezer(String searchValue) async {
    if (searchValue.isEmpty) {
      return [];
    }
    // final Map<String, String> cookies = {'arl': SettingsController.deezerARL};
    String searchUrl = 'https://api.deezer.com/search?q=$searchValue&limit=56&index=0&output=json';
    debugPrint(searchUrl);

    // final http.Response getResponse = await http.get(Uri.parse(searchUrl), headers: {
    //   'Cookie': 'arl=${cookies['arl']}',
    // });

    final http.Response getResponse = await http.get(Uri.parse(searchUrl));

    final Map<String, dynamic> getResponseJson = jsonDecode(getResponse.body);
    return (getResponseJson['data']);
  }

  Future<List<String>> searchLyrics(String title, String artist) async {
    //plainLyricNotifier.value = 'Searching for lyrics...';
    final Map<String, String> cookies = {'arl': SettingsController.deezerARL};
    final Map<String, String> params = {'jo': 'p', 'rto': 'c', 'i': 'c'};
    const String loginUrl = 'https://auth.deezer.com/login/arl';
    const String deezerApiUrl = 'https://pipe.deezer.com/api';
    String searchUrl = 'https://api.deezer.com/search?q=$title-$artist&limit=1&index=0&output=json';
    debugPrint(searchUrl);

    final Uri uri = Uri.parse(loginUrl).replace(queryParameters: params);
    final http.Request postRequest = http.Request('POST', uri);
    postRequest.headers
        .addAll({'Content-Type': 'application/json', 'Cookie': 'arl=${cookies['arl']}'});
    final http.StreamedResponse streamedResponse = await postRequest.send();
    final String postResponseString = await streamedResponse.stream.bytesToString();
    final Map<String, dynamic> postResponseJson = jsonDecode(postResponseString);

    //debugPrint(postResponseJson);
    final String jwt = postResponseJson['jwt'];
    //debugPrint(jwt);

    final http.Response getResponse = await http.get(Uri.parse(searchUrl), headers: {
      'Cookie': 'arl=${cookies['arl']}',
    });

    final Map<String, dynamic> getResponseJson = jsonDecode(getResponse.body);
    //debugPrint(getResponseJson['data'][0]['id']);

    final String trackId = getResponseJson['data'][0]['id'].toString();

    final Map<String, dynamic> jsonData = {
      'operationName': 'SynchronizedTrackLyrics',
      'variables': {
        'trackId': trackId,
      },
      'query': '''query SynchronizedTrackLyrics(\$trackId: String!) {
                            track(trackId: \$trackId) {
                              ...SynchronizedTrackLyrics
                              __typename
                            }
                          }
                      
                          fragment SynchronizedTrackLyrics on Track {
                            id
                            lyrics {
                              ...Lyrics
                              __typename
                            }
                            album {
                              cover {
                                small: urls(pictureRequest: {width: 100, height: 100})
                                medium: urls(pictureRequest: {width: 264, height: 264})
                                large: urls(pictureRequest: {width: 800, height: 800})
                              explicitStatus
                              __typename
                            }
                            __typename
                          }
                          __typename
                          }
                      
                          fragment Lyrics on Lyrics {
                            id
                            copyright
                            text
                            writers
                            synchronizedLines {
                              ...LyricsSynchronizedLines
                              __typename
                            }
                            __typename
                          }
                      
                          fragment LyricsSynchronizedLines on LyricsSynchronizedLine {
                            lrcTimestamp
                            line
                            lineTranslated
                            milliseconds
                            duration
                            __typename
                          }'''
    };

    final http.Response lyricResponse = await http.post(
      Uri.parse(deezerApiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwt',
      },
      body: jsonEncode(jsonData),
    );

    final Map<String, dynamic> lyricResponseJson = jsonDecode(lyricResponse.body);
    //debugPrint(lyricResponseJson);

    String plainLyric = '';
    String syncedLyric = '';
    try {
      plainLyric += lyricResponseJson['data']['track']['lyrics']['text'] + "\n";
      plainLyric += "\nWriters: ${lyricResponseJson['data']['track']['lyrics']['writers']}\nCopyright: ${lyricResponseJson['data']['track']['lyrics']['copyright']}";
    } catch (e) {
      debugPrint(e.toString());
      plainLyric = 'No lyrics found';
    }

    try {
      for (var line in lyricResponseJson['data']['track']['lyrics']['synchronizedLines']) {
        syncedLyric += "${line['lrcTimestamp']} ${line['line']}\n";
      }
      syncedLyric += "\nWriters: ${lyricResponseJson['data']['track']['lyrics']['writers']}\nCopyright: ${lyricResponseJson['data']['track']['lyrics']['copyright']}";
    } catch (e) {
      debugPrint(e.toString());
      syncedLyric = 'No lyrics found';
    }
    //debugPrint(plainLyric);

    // lyricModelNotifier.value = LyricsModelBuilder.create().bindLyricToMain(syncedLyric).getModel();
    // plainLyricNotifier.value = plainLyric;
    //
    // if (syncedLyric != 'No lyrics found') {
    //   var lyrPath = path
    //       .replaceAll(".mp3", ".lrc")
    //       .replaceAll(".flac", ".lrc")
    //       .replaceAll(".wav", ".lrc")
    //       .replaceAll(".m4a", ".lrc");
    //   File lyrFile = File(lyrPath);
    //   lyrFile.writeAsStringSync(syncedLyric);
    //   song.lyricsPath = lyrFile.path;
    // } else if (plainLyric != 'No lyrics found') {
    //   var lyrPath = path
    //       .replaceAll(".mp3", ".lrc")
    //       .replaceAll(".flac", ".lrc")
    //       .replaceAll(".wav", ".lrc")
    //       .replaceAll(".m4a", ".lrc");
    //   File lyrFile = File(lyrPath);
    //   lyrFile.writeAsStringSync(plainLyric);
    //   song.lyricsPath = lyrFile.path;
    // }
    // songBox.put(song);
    return [plainLyric, syncedLyric];
  }

  Future<void> updateUser() async {
    // debugPrint("Update user");
    // var data = SettingsController.toMap().toString();
    // var encryptedData = await encryptData(data);
    // debugPrint(encryptedData);
    // var uri = Uri.parse('http://localhost:8000/api/update-user');
    // var request = http.Request('POST', uri)
    //   ..headers.addAll({
    //     'Content-Type': 'application/json',
    //   })
    //   ..body = jsonEncode({
    //     'data': encryptedData,
    //   });
    // var response = await request.send();
    // debugPrint(response.statusCode);
    // debugPrint(await response.stream.bytesToString());
  }
}