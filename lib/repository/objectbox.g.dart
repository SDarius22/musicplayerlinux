// GENERATED CODE - DO NOT MODIFY BY HAND
// This code was generated by ObjectBox. To update it run the generator again
// with `dart run build_runner build`.
// See also https://docs.objectbox.io/getting-started#generate-objectbox-code

// ignore_for_file: camel_case_types, depend_on_referenced_packages
// coverage:ignore-file

import 'dart:typed_data';

import 'package:flat_buffers/flat_buffers.dart' as fb;
import 'package:objectbox/internal.dart'
    as obx_int; // generated code can access "internal" functionality
import 'package:objectbox/objectbox.dart' as obx;
import 'package:objectbox_flutter_libs/objectbox_flutter_libs.dart';

import '../domain/album_type.dart';
import '../domain/artist_type.dart';
import '../domain/playlist_type.dart';
import '../domain/settings_type.dart';
import '../domain/song_type.dart';

export 'package:objectbox/objectbox.dart'; // so that callers only have to import this file

final _entities = <obx_int.ModelEntity>[
  obx_int.ModelEntity(
      id: const obx_int.IdUid(1, 1815619076807623967),
      name: 'AlbumType',
      lastPropertyId: const obx_int.IdUid(4, 3700143381519926938),
      flags: 0,
      properties: <obx_int.ModelProperty>[
        obx_int.ModelProperty(
            id: const obx_int.IdUid(1, 8458091153121794614),
            name: 'id',
            type: 6,
            flags: 1),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(2, 1345298650327502809),
            name: 'name',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(3, 8512936839929207505),
            name: 'duration',
            type: 6,
            flags: 0)
      ],
      relations: <obx_int.ModelRelation>[
        obx_int.ModelRelation(
            id: const obx_int.IdUid(1, 2196777118392264311),
            name: 'songs',
            targetId: const obx_int.IdUid(5, 7894316662941293306))
      ],
      backlinks: <obx_int.ModelBacklink>[]),
  obx_int.ModelEntity(
      id: const obx_int.IdUid(2, 3925805979979484823),
      name: 'ArtistType',
      lastPropertyId: const obx_int.IdUid(2, 4033493852260689551),
      flags: 0,
      properties: <obx_int.ModelProperty>[
        obx_int.ModelProperty(
            id: const obx_int.IdUid(1, 455336560021715696),
            name: 'id',
            type: 6,
            flags: 1),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(2, 4033493852260689551),
            name: 'name',
            type: 9,
            flags: 0)
      ],
      relations: <obx_int.ModelRelation>[
        obx_int.ModelRelation(
            id: const obx_int.IdUid(2, 7336186303175286966),
            name: 'songs',
            targetId: const obx_int.IdUid(5, 7894316662941293306))
      ],
      backlinks: <obx_int.ModelBacklink>[]),
  obx_int.ModelEntity(
      id: const obx_int.IdUid(3, 7335752985882107118),
      name: 'PlaylistType',
      lastPropertyId: const obx_int.IdUid(7, 1081497872397675260),
      flags: 0,
      properties: <obx_int.ModelProperty>[
        obx_int.ModelProperty(
            id: const obx_int.IdUid(1, 1494518102450216985),
            name: 'id',
            type: 6,
            flags: 1),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(2, 6153441952504667348),
            name: 'name',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(3, 5415571419012464132),
            name: 'nextAdded',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(4, 4890538008718222274),
            name: 'paths',
            type: 30,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(5, 6851290111821521417),
            name: 'duration',
            type: 6,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(6, 7192996012449545044),
            name: 'artistCount',
            type: 30,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(7, 1081497872397675260),
            name: 'indestructible',
            type: 1,
            flags: 0)
      ],
      relations: <obx_int.ModelRelation>[],
      backlinks: <obx_int.ModelBacklink>[]),
  obx_int.ModelEntity(
      id: const obx_int.IdUid(4, 6804076072802197348),
      name: 'Settings',
      lastPropertyId: const obx_int.IdUid(31, 2620913899500465255),
      flags: 0,
      properties: <obx_int.ModelProperty>[
        obx_int.ModelProperty(
            id: const obx_int.IdUid(1, 5178715081886201470),
            name: 'id',
            type: 6,
            flags: 1),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(2, 8710457297108856265),
            name: 'mongoID',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(3, 46998898595284097),
            name: 'email',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(4, 8041144671428001314),
            name: 'password',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(5, 488819351752261664),
            name: 'deviceList',
            type: 30,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(6, 6047951844641597661),
            name: 'primaryDevice',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(7, 1802142995195547451),
            name: 'directory',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(8, 5365361459618174637),
            name: 'index',
            type: 6,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(10, 2437385579200723056),
            name: 'firstTime',
            type: 1,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(11, 7909410870437474588),
            name: 'systemTray',
            type: 1,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(12, 4177982114420883162),
            name: 'fullClose',
            type: 1,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(13, 4093183126855020448),
            name: 'appNotifications',
            type: 1,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(14, 1480984136849824540),
            name: 'deezerARL',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(15, 5217132346410254782),
            name: 'queueAdd',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(16, 467231863241907326),
            name: 'queuePlay',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(17, 8249822133428953560),
            name: 'queue',
            type: 30,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(18, 1754679951177592721),
            name: 'missingSongs',
            type: 30,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(22, 5747114371564639158),
            name: 'repeat',
            type: 1,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(23, 1668822660070621182),
            name: 'shuffle',
            type: 1,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(24, 8770041269884286611),
            name: 'balance',
            type: 8,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(25, 3216196079984977284),
            name: 'speed',
            type: 8,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(26, 497009210266954405),
            name: 'volume',
            type: 8,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(27, 9066790932122685542),
            name: 'sleepTimer',
            type: 6,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(28, 6447994625540678165),
            name: 'shuffledQueue',
            type: 30,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(29, 3769136345788891218),
            name: 'lightColor',
            type: 6,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(30, 292241644251009252),
            name: 'darkColor',
            type: 6,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(31, 2620913899500465255),
            name: 'slider',
            type: 6,
            flags: 0)
      ],
      relations: <obx_int.ModelRelation>[],
      backlinks: <obx_int.ModelBacklink>[]),
  obx_int.ModelEntity(
      id: const obx_int.IdUid(5, 7894316662941293306),
      name: 'SongType',
      lastPropertyId: const obx_int.IdUid(14, 3238798048305584967),
      flags: 0,
      properties: <obx_int.ModelProperty>[
        obx_int.ModelProperty(
            id: const obx_int.IdUid(1, 4446675160006263163),
            name: 'id',
            type: 6,
            flags: 1),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(2, 8662021158587083310),
            name: 'title',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(3, 2984380281557415328),
            name: 'artists',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(4, 7701854324956318789),
            name: 'album',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(5, 4392167652933872417),
            name: 'albumArtist',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(6, 1256214510630179389),
            name: 'duration',
            type: 6,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(7, 9216794188712503719),
            name: 'path',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(8, 6768347857469160534),
            name: 'lyricsPath',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(9, 7563905291323881955),
            name: 'trackNumber',
            type: 6,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(10, 3811047316129861105),
            name: 'discNumber',
            type: 6,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(12, 5871174133202682144),
            name: 'liked',
            type: 1,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(13, 1713442380679213921),
            name: 'lastPlayed',
            type: 10,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(14, 3238798048305584967),
            name: 'playCount',
            type: 6,
            flags: 0)
      ],
      relations: <obx_int.ModelRelation>[],
      backlinks: <obx_int.ModelBacklink>[])
];

/// Shortcut for [obx.Store.new] that passes [getObjectBoxModel] and for Flutter
/// apps by default a [directory] using `defaultStoreDirectory()` from the
/// ObjectBox Flutter library.
///
/// Note: for desktop apps it is recommended to specify a unique [directory].
///
/// See [obx.Store.new] for an explanation of all parameters.
///
/// For Flutter apps, also calls `loadObjectBoxLibraryAndroidCompat()` from
/// the ObjectBox Flutter library to fix loading the native ObjectBox library
/// on Android 6 and older.
Future<obx.Store> openStore(
    {String? directory,
    int? maxDBSizeInKB,
    int? maxDataSizeInKB,
    int? fileMode,
    int? maxReaders,
    bool queriesCaseSensitiveDefault = true,
    String? macosApplicationGroup}) async {
  await loadObjectBoxLibraryAndroidCompat();
  return obx.Store(getObjectBoxModel(),
      directory: directory ?? (await defaultStoreDirectory()).path,
      maxDBSizeInKB: maxDBSizeInKB,
      maxDataSizeInKB: maxDataSizeInKB,
      fileMode: fileMode,
      maxReaders: maxReaders,
      queriesCaseSensitiveDefault: queriesCaseSensitiveDefault,
      macosApplicationGroup: macosApplicationGroup);
}

/// Returns the ObjectBox model definition for this project for use with
/// [obx.Store.new].
obx_int.ModelDefinition getObjectBoxModel() {
  final model = obx_int.ModelInfo(
      entities: _entities,
      lastEntityId: const obx_int.IdUid(5, 7894316662941293306),
      lastIndexId: const obx_int.IdUid(0, 0),
      lastRelationId: const obx_int.IdUid(3, 3440552932794375637),
      lastSequenceId: const obx_int.IdUid(0, 0),
      retiredEntityUids: const [],
      retiredIndexUids: const [],
      retiredPropertyUids: const [
        8117591938523893765,
        3605978690295634239,
        149915083280863291,
        1171492870719301957,
        3807358697915249101,
        3700143381519926938
      ],
      retiredRelationUids: const [3440552932794375637],
      modelVersion: 5,
      modelVersionParserMinimum: 5,
      version: 1);

  final bindings = <Type, obx_int.EntityDefinition>{
    AlbumType: obx_int.EntityDefinition<AlbumType>(
        model: _entities[0],
        toOneRelations: (AlbumType object) => [],
        toManyRelations: (AlbumType object) =>
            {obx_int.RelInfo<AlbumType>.toMany(1, object.id): object.songs},
        getId: (AlbumType object) => object.id,
        setId: (AlbumType object, int id) {
          object.id = id;
        },
        objectToFB: (AlbumType object, fb.Builder fbb) {
          final nameOffset = fbb.writeString(object.name);
          fbb.startTable(5);
          fbb.addInt64(0, object.id);
          fbb.addOffset(1, nameOffset);
          fbb.addInt64(2, object.duration);
          fbb.finish(fbb.endTable());
          return object.id;
        },
        objectFromFB: (obx.Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);

          final object = AlbumType()
            ..id = const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0)
            ..name = const fb.StringReader(asciiOptimization: true)
                .vTableGet(buffer, rootOffset, 6, '')
            ..duration =
                const fb.Int64Reader().vTableGet(buffer, rootOffset, 8, 0);
          obx_int.InternalToManyAccess.setRelInfo<AlbumType>(object.songs,
              store, obx_int.RelInfo<AlbumType>.toMany(1, object.id));
          return object;
        }),
    ArtistType: obx_int.EntityDefinition<ArtistType>(
        model: _entities[1],
        toOneRelations: (ArtistType object) => [],
        toManyRelations: (ArtistType object) =>
            {obx_int.RelInfo<ArtistType>.toMany(2, object.id): object.songs},
        getId: (ArtistType object) => object.id,
        setId: (ArtistType object, int id) {
          object.id = id;
        },
        objectToFB: (ArtistType object, fb.Builder fbb) {
          final nameOffset = fbb.writeString(object.name);
          fbb.startTable(3);
          fbb.addInt64(0, object.id);
          fbb.addOffset(1, nameOffset);
          fbb.finish(fbb.endTable());
          return object.id;
        },
        objectFromFB: (obx.Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);

          final object = ArtistType()
            ..id = const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0)
            ..name = const fb.StringReader(asciiOptimization: true)
                .vTableGet(buffer, rootOffset, 6, '');
          obx_int.InternalToManyAccess.setRelInfo<ArtistType>(object.songs,
              store, obx_int.RelInfo<ArtistType>.toMany(2, object.id));
          return object;
        }),
    PlaylistType: obx_int.EntityDefinition<PlaylistType>(
        model: _entities[2],
        toOneRelations: (PlaylistType object) => [],
        toManyRelations: (PlaylistType object) => {},
        getId: (PlaylistType object) => object.id,
        setId: (PlaylistType object, int id) {
          object.id = id;
        },
        objectToFB: (PlaylistType object, fb.Builder fbb) {
          final nameOffset = fbb.writeString(object.name);
          final nextAddedOffset = fbb.writeString(object.nextAdded);
          final pathsOffset = fbb.writeList(
              object.paths.map(fbb.writeString).toList(growable: false));
          final artistCountOffset = fbb.writeList(
              object.artistCount.map(fbb.writeString).toList(growable: false));
          fbb.startTable(8);
          fbb.addInt64(0, object.id);
          fbb.addOffset(1, nameOffset);
          fbb.addOffset(2, nextAddedOffset);
          fbb.addOffset(3, pathsOffset);
          fbb.addInt64(4, object.duration);
          fbb.addOffset(5, artistCountOffset);
          fbb.addBool(6, object.indestructible);
          fbb.finish(fbb.endTable());
          return object.id;
        },
        objectFromFB: (obx.Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);

          final object = PlaylistType()
            ..id = const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0)
            ..name = const fb.StringReader(asciiOptimization: true)
                .vTableGet(buffer, rootOffset, 6, '')
            ..nextAdded = const fb.StringReader(asciiOptimization: true)
                .vTableGet(buffer, rootOffset, 8, '')
            ..paths = const fb.ListReader<String>(
                    fb.StringReader(asciiOptimization: true),
                    lazy: false)
                .vTableGet(buffer, rootOffset, 10, [])
            ..duration =
                const fb.Int64Reader().vTableGet(buffer, rootOffset, 12, 0)
            ..artistCount = const fb.ListReader<String>(
                    fb.StringReader(asciiOptimization: true),
                    lazy: false)
                .vTableGet(buffer, rootOffset, 14, [])
            ..indestructible =
                const fb.BoolReader().vTableGet(buffer, rootOffset, 16, false);

          return object;
        }),
    Settings: obx_int.EntityDefinition<Settings>(
        model: _entities[3],
        toOneRelations: (Settings object) => [],
        toManyRelations: (Settings object) => {},
        getId: (Settings object) => object.id,
        setId: (Settings object, int id) {
          object.id = id;
        },
        objectToFB: (Settings object, fb.Builder fbb) {
          final mongoIDOffset = fbb.writeString(object.mongoID);
          final emailOffset = fbb.writeString(object.email);
          final passwordOffset = fbb.writeString(object.password);
          final deviceListOffset = fbb.writeList(
              object.deviceList.map(fbb.writeString).toList(growable: false));
          final primaryDeviceOffset = fbb.writeString(object.primaryDevice);
          final directoryOffset = fbb.writeString(object.directory);
          final deezerARLOffset = fbb.writeString(object.deezerARL);
          final queueAddOffset = fbb.writeString(object.queueAdd);
          final queuePlayOffset = fbb.writeString(object.queuePlay);
          final queueOffset = fbb.writeList(
              object.queue.map(fbb.writeString).toList(growable: false));
          final missingSongsOffset = fbb.writeList(
              object.missingSongs.map(fbb.writeString).toList(growable: false));
          final shuffledQueueOffset = fbb.writeList(object.shuffledQueue
              .map(fbb.writeString)
              .toList(growable: false));
          fbb.startTable(32);
          fbb.addInt64(0, object.id);
          fbb.addOffset(1, mongoIDOffset);
          fbb.addOffset(2, emailOffset);
          fbb.addOffset(3, passwordOffset);
          fbb.addOffset(4, deviceListOffset);
          fbb.addOffset(5, primaryDeviceOffset);
          fbb.addOffset(6, directoryOffset);
          fbb.addInt64(7, object.index);
          fbb.addBool(9, object.firstTime);
          fbb.addBool(10, object.systemTray);
          fbb.addBool(11, object.fullClose);
          fbb.addBool(12, object.appNotifications);
          fbb.addOffset(13, deezerARLOffset);
          fbb.addOffset(14, queueAddOffset);
          fbb.addOffset(15, queuePlayOffset);
          fbb.addOffset(16, queueOffset);
          fbb.addOffset(17, missingSongsOffset);
          fbb.addBool(21, object.repeat);
          fbb.addBool(22, object.shuffle);
          fbb.addFloat64(23, object.balance);
          fbb.addFloat64(24, object.speed);
          fbb.addFloat64(25, object.volume);
          fbb.addInt64(26, object.sleepTimer);
          fbb.addOffset(27, shuffledQueueOffset);
          fbb.addInt64(28, object.lightColor);
          fbb.addInt64(29, object.darkColor);
          fbb.addInt64(30, object.slider);
          fbb.finish(fbb.endTable());
          return object.id;
        },
        objectFromFB: (obx.Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);

          final object = Settings()
            ..id = const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0)
            ..mongoID = const fb.StringReader(asciiOptimization: true)
                .vTableGet(buffer, rootOffset, 6, '')
            ..email = const fb.StringReader(asciiOptimization: true)
                .vTableGet(buffer, rootOffset, 8, '')
            ..password = const fb.StringReader(asciiOptimization: true)
                .vTableGet(buffer, rootOffset, 10, '')
            ..deviceList = const fb.ListReader<String>(
                    fb.StringReader(asciiOptimization: true),
                    lazy: false)
                .vTableGet(buffer, rootOffset, 12, [])
            ..primaryDevice = const fb.StringReader(asciiOptimization: true)
                .vTableGet(buffer, rootOffset, 14, '')
            ..directory = const fb.StringReader(asciiOptimization: true)
                .vTableGet(buffer, rootOffset, 16, '')
            ..index =
                const fb.Int64Reader().vTableGet(buffer, rootOffset, 18, 0)
            ..firstTime =
                const fb.BoolReader().vTableGet(buffer, rootOffset, 22, false)
            ..systemTray =
                const fb.BoolReader().vTableGet(buffer, rootOffset, 24, false)
            ..fullClose =
                const fb.BoolReader().vTableGet(buffer, rootOffset, 26, false)
            ..appNotifications =
                const fb.BoolReader().vTableGet(buffer, rootOffset, 28, false)
            ..deezerARL = const fb.StringReader(asciiOptimization: true)
                .vTableGet(buffer, rootOffset, 30, '')
            ..queueAdd = const fb.StringReader(asciiOptimization: true)
                .vTableGet(buffer, rootOffset, 32, '')
            ..queuePlay = const fb.StringReader(asciiOptimization: true)
                .vTableGet(buffer, rootOffset, 34, '')
            ..queue = const fb.ListReader<String>(
                    fb.StringReader(asciiOptimization: true),
                    lazy: false)
                .vTableGet(buffer, rootOffset, 36, [])
            ..missingSongs = const fb.ListReader<String>(
                    fb.StringReader(asciiOptimization: true),
                    lazy: false)
                .vTableGet(buffer, rootOffset, 38, [])
            ..repeat =
                const fb.BoolReader().vTableGet(buffer, rootOffset, 46, false)
            ..shuffle =
                const fb.BoolReader().vTableGet(buffer, rootOffset, 48, false)
            ..balance =
                const fb.Float64Reader().vTableGet(buffer, rootOffset, 50, 0)
            ..speed =
                const fb.Float64Reader().vTableGet(buffer, rootOffset, 52, 0)
            ..volume =
                const fb.Float64Reader().vTableGet(buffer, rootOffset, 54, 0)
            ..sleepTimer =
                const fb.Int64Reader().vTableGet(buffer, rootOffset, 56, 0)
            ..shuffledQueue = const fb.ListReader<String>(
                    fb.StringReader(asciiOptimization: true),
                    lazy: false)
                .vTableGet(buffer, rootOffset, 58, [])
            ..lightColor =
                const fb.Int64Reader().vTableGet(buffer, rootOffset, 60, 0)
            ..darkColor =
                const fb.Int64Reader().vTableGet(buffer, rootOffset, 62, 0)
            ..slider =
                const fb.Int64Reader().vTableGet(buffer, rootOffset, 64, 0);

          return object;
        }),
    SongType: obx_int.EntityDefinition<SongType>(
        model: _entities[4],
        toOneRelations: (SongType object) => [],
        toManyRelations: (SongType object) => {},
        getId: (SongType object) => object.id,
        setId: (SongType object, int id) {
          object.id = id;
        },
        objectToFB: (SongType object, fb.Builder fbb) {
          final titleOffset = fbb.writeString(object.title);
          final artistsOffset = fbb.writeString(object.artists);
          final albumOffset = fbb.writeString(object.album);
          final albumArtistOffset = fbb.writeString(object.albumArtist);
          final pathOffset = fbb.writeString(object.path);
          final lyricsPathOffset = fbb.writeString(object.lyricsPath);
          fbb.startTable(15);
          fbb.addInt64(0, object.id);
          fbb.addOffset(1, titleOffset);
          fbb.addOffset(2, artistsOffset);
          fbb.addOffset(3, albumOffset);
          fbb.addOffset(4, albumArtistOffset);
          fbb.addInt64(5, object.duration);
          fbb.addOffset(6, pathOffset);
          fbb.addOffset(7, lyricsPathOffset);
          fbb.addInt64(8, object.trackNumber);
          fbb.addInt64(9, object.discNumber);
          fbb.addBool(11, object.liked);
          fbb.addInt64(12, object.lastPlayed?.millisecondsSinceEpoch);
          fbb.addInt64(13, object.playCount);
          fbb.finish(fbb.endTable());
          return object.id;
        },
        objectFromFB: (obx.Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);
          final lastPlayedValue =
              const fb.Int64Reader().vTableGetNullable(buffer, rootOffset, 28);
          final object = SongType()
            ..id = const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0)
            ..title = const fb.StringReader(asciiOptimization: true)
                .vTableGet(buffer, rootOffset, 6, '')
            ..artists = const fb.StringReader(asciiOptimization: true)
                .vTableGet(buffer, rootOffset, 8, '')
            ..album = const fb.StringReader(asciiOptimization: true)
                .vTableGet(buffer, rootOffset, 10, '')
            ..albumArtist = const fb.StringReader(asciiOptimization: true)
                .vTableGet(buffer, rootOffset, 12, '')
            ..duration =
                const fb.Int64Reader().vTableGet(buffer, rootOffset, 14, 0)
            ..path = const fb.StringReader(asciiOptimization: true)
                .vTableGet(buffer, rootOffset, 16, '')
            ..lyricsPath = const fb.StringReader(asciiOptimization: true)
                .vTableGet(buffer, rootOffset, 18, '')
            ..trackNumber =
                const fb.Int64Reader().vTableGet(buffer, rootOffset, 20, 0)
            ..discNumber =
                const fb.Int64Reader().vTableGet(buffer, rootOffset, 22, 0)
            ..liked =
                const fb.BoolReader().vTableGet(buffer, rootOffset, 26, false)
            ..lastPlayed = lastPlayedValue == null
                ? null
                : DateTime.fromMillisecondsSinceEpoch(lastPlayedValue)
            ..playCount =
                const fb.Int64Reader().vTableGet(buffer, rootOffset, 30, 0);

          return object;
        })
  };

  return obx_int.ModelDefinition(model, bindings);
}

/// [AlbumType] entity fields to define ObjectBox queries.
class AlbumType_ {
  /// See [AlbumType.id].
  static final id =
      obx.QueryIntegerProperty<AlbumType>(_entities[0].properties[0]);

  /// See [AlbumType.name].
  static final name =
      obx.QueryStringProperty<AlbumType>(_entities[0].properties[1]);

  /// See [AlbumType.duration].
  static final duration =
      obx.QueryIntegerProperty<AlbumType>(_entities[0].properties[2]);

  /// see [AlbumType.songs]
  static final songs =
      obx.QueryRelationToMany<AlbumType, SongType>(_entities[0].relations[0]);
}

/// [ArtistType] entity fields to define ObjectBox queries.
class ArtistType_ {
  /// See [ArtistType.id].
  static final id =
      obx.QueryIntegerProperty<ArtistType>(_entities[1].properties[0]);

  /// See [ArtistType.name].
  static final name =
      obx.QueryStringProperty<ArtistType>(_entities[1].properties[1]);

  /// see [ArtistType.songs]
  static final songs =
      obx.QueryRelationToMany<ArtistType, SongType>(_entities[1].relations[0]);
}

/// [PlaylistType] entity fields to define ObjectBox queries.
class PlaylistType_ {
  /// See [PlaylistType.id].
  static final id =
      obx.QueryIntegerProperty<PlaylistType>(_entities[2].properties[0]);

  /// See [PlaylistType.name].
  static final name =
      obx.QueryStringProperty<PlaylistType>(_entities[2].properties[1]);

  /// See [PlaylistType.nextAdded].
  static final nextAdded =
      obx.QueryStringProperty<PlaylistType>(_entities[2].properties[2]);

  /// See [PlaylistType.paths].
  static final paths =
      obx.QueryStringVectorProperty<PlaylistType>(_entities[2].properties[3]);

  /// See [PlaylistType.duration].
  static final duration =
      obx.QueryIntegerProperty<PlaylistType>(_entities[2].properties[4]);

  /// See [PlaylistType.artistCount].
  static final artistCount =
      obx.QueryStringVectorProperty<PlaylistType>(_entities[2].properties[5]);

  /// See [PlaylistType.indestructible].
  static final indestructible =
      obx.QueryBooleanProperty<PlaylistType>(_entities[2].properties[6]);
}

/// [Settings] entity fields to define ObjectBox queries.
class Settings_ {
  /// See [Settings.id].
  static final id =
      obx.QueryIntegerProperty<Settings>(_entities[3].properties[0]);

  /// See [Settings.mongoID].
  static final mongoID =
      obx.QueryStringProperty<Settings>(_entities[3].properties[1]);

  /// See [Settings.email].
  static final email =
      obx.QueryStringProperty<Settings>(_entities[3].properties[2]);

  /// See [Settings.password].
  static final password =
      obx.QueryStringProperty<Settings>(_entities[3].properties[3]);

  /// See [Settings.deviceList].
  static final deviceList =
      obx.QueryStringVectorProperty<Settings>(_entities[3].properties[4]);

  /// See [Settings.primaryDevice].
  static final primaryDevice =
      obx.QueryStringProperty<Settings>(_entities[3].properties[5]);

  /// See [Settings.directory].
  static final directory =
      obx.QueryStringProperty<Settings>(_entities[3].properties[6]);

  /// See [Settings.index].
  static final index =
      obx.QueryIntegerProperty<Settings>(_entities[3].properties[7]);

  /// See [Settings.firstTime].
  static final firstTime =
      obx.QueryBooleanProperty<Settings>(_entities[3].properties[8]);

  /// See [Settings.systemTray].
  static final systemTray =
      obx.QueryBooleanProperty<Settings>(_entities[3].properties[9]);

  /// See [Settings.fullClose].
  static final fullClose =
      obx.QueryBooleanProperty<Settings>(_entities[3].properties[10]);

  /// See [Settings.appNotifications].
  static final appNotifications =
      obx.QueryBooleanProperty<Settings>(_entities[3].properties[11]);

  /// See [Settings.deezerARL].
  static final deezerARL =
      obx.QueryStringProperty<Settings>(_entities[3].properties[12]);

  /// See [Settings.queueAdd].
  static final queueAdd =
      obx.QueryStringProperty<Settings>(_entities[3].properties[13]);

  /// See [Settings.queuePlay].
  static final queuePlay =
      obx.QueryStringProperty<Settings>(_entities[3].properties[14]);

  /// See [Settings.queue].
  static final queue =
      obx.QueryStringVectorProperty<Settings>(_entities[3].properties[15]);

  /// See [Settings.missingSongs].
  static final missingSongs =
      obx.QueryStringVectorProperty<Settings>(_entities[3].properties[16]);

  /// See [Settings.repeat].
  static final repeat =
      obx.QueryBooleanProperty<Settings>(_entities[3].properties[17]);

  /// See [Settings.shuffle].
  static final shuffle =
      obx.QueryBooleanProperty<Settings>(_entities[3].properties[18]);

  /// See [Settings.balance].
  static final balance =
      obx.QueryDoubleProperty<Settings>(_entities[3].properties[19]);

  /// See [Settings.speed].
  static final speed =
      obx.QueryDoubleProperty<Settings>(_entities[3].properties[20]);

  /// See [Settings.volume].
  static final volume =
      obx.QueryDoubleProperty<Settings>(_entities[3].properties[21]);

  /// See [Settings.sleepTimer].
  static final sleepTimer =
      obx.QueryIntegerProperty<Settings>(_entities[3].properties[22]);

  /// See [Settings.shuffledQueue].
  static final shuffledQueue =
      obx.QueryStringVectorProperty<Settings>(_entities[3].properties[23]);

  /// See [Settings.lightColor].
  static final lightColor =
      obx.QueryIntegerProperty<Settings>(_entities[3].properties[24]);

  /// See [Settings.darkColor].
  static final darkColor =
      obx.QueryIntegerProperty<Settings>(_entities[3].properties[25]);

  /// See [Settings.slider].
  static final slider =
      obx.QueryIntegerProperty<Settings>(_entities[3].properties[26]);
}

/// [SongType] entity fields to define ObjectBox queries.
class SongType_ {
  /// See [SongType.id].
  static final id =
      obx.QueryIntegerProperty<SongType>(_entities[4].properties[0]);

  /// See [SongType.title].
  static final title =
      obx.QueryStringProperty<SongType>(_entities[4].properties[1]);

  /// See [SongType.artists].
  static final artists =
      obx.QueryStringProperty<SongType>(_entities[4].properties[2]);

  /// See [SongType.album].
  static final album =
      obx.QueryStringProperty<SongType>(_entities[4].properties[3]);

  /// See [SongType.albumArtist].
  static final albumArtist =
      obx.QueryStringProperty<SongType>(_entities[4].properties[4]);

  /// See [SongType.duration].
  static final duration =
      obx.QueryIntegerProperty<SongType>(_entities[4].properties[5]);

  /// See [SongType.path].
  static final path =
      obx.QueryStringProperty<SongType>(_entities[4].properties[6]);

  /// See [SongType.lyricsPath].
  static final lyricsPath =
      obx.QueryStringProperty<SongType>(_entities[4].properties[7]);

  /// See [SongType.trackNumber].
  static final trackNumber =
      obx.QueryIntegerProperty<SongType>(_entities[4].properties[8]);

  /// See [SongType.discNumber].
  static final discNumber =
      obx.QueryIntegerProperty<SongType>(_entities[4].properties[9]);

  /// See [SongType.liked].
  static final liked =
      obx.QueryBooleanProperty<SongType>(_entities[4].properties[10]);

  /// See [SongType.lastPlayed].
  static final lastPlayed =
      obx.QueryDateProperty<SongType>(_entities[4].properties[11]);

  /// See [SongType.playCount].
  static final playCount =
      obx.QueryIntegerProperty<SongType>(_entities[4].properties[12]);
}
