class FeaturedArtistType{
  String name = "Unknown artist";
  int appearances = 0;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'appearances': appearances,
    };
  }
}