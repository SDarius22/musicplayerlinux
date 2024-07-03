import 'featured_artist_type.dart';
import 'metadata_type.dart';

class AlbumType{
  String name = "Unknown album";
  List<FeaturedArtistType> featuredartists = [];
  List<MetadataType> songs = [];
  String duration = "Unknown duration";

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'featuredArtists': featuredartists,
      'songs': songs,
      'duration': duration,
    };
  }
}