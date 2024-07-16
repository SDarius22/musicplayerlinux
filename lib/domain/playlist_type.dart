import 'featured_artist_type.dart';
import 'metadata_type.dart';

class PlaylistType{
  String name = "Unknown playlist";
  List<String> paths = [];
  List<MetadataType> songs = [];
  String duration = "Unknown duration";
  List<FeaturedArtistType> featuredArtists = [];

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'paths': paths,
      'duration': duration,
      'featuredArtists': featuredArtists,
    };
  }
}