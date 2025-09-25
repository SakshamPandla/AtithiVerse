class Destination {
  final int id;
  final String name;
  final String category;
  final double rating;
  final int reviews;
  final double price;
  final double originalPrice;
  final String image;
  final String description;
  final String location;
  final List<String> features;
  final bool inWishlist;

  Destination({
    required this.id,
    required this.name,
    required this.category,
    required this.rating,
    required this.reviews,
    required this.price,
    required this.originalPrice,
    required this.image,
    required this.description,
    required this.location,
    required this.features,
    this.inWishlist = false,
  });

  factory Destination.fromJson(Map<String, dynamic> json) {
    return Destination(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      rating: json['rating']?.toDouble() ?? 0.0,
      reviews: json['reviews'] ?? 0,
      price: json['price']?.toDouble() ?? 0.0,
      originalPrice: json['original_price']?.toDouble() ?? 0.0,
      image: json['image'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      features: List<String>.from(json['features'] ?? []),
      inWishlist: json['in_wishlist'] ?? false,
    );
  }
}

class ChatMessage {
  final String id;
  final String message;
  final bool isUser;
  final DateTime timestamp;
  final List<String>? suggestions;

  ChatMessage({
    required this.id,
    required this.message,
    required this.isUser,
    required this.timestamp,
    this.suggestions,
  });
}
