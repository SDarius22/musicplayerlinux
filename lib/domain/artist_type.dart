import 'metadata_type.dart';

class ArtistType{
  String name = "Unknown artist";
  List<MetadataType> songs = [];

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'songs': songs,
    };
  }
}