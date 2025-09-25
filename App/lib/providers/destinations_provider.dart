import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/destination.dart';

class DestinationsProvider with ChangeNotifier {
  List<Destination> _destinations = [];
  List<Destination> _filteredDestinations = [];
  bool _isLoading = false;
  String _selectedCategory = 'all';
  String _searchQuery = '';
  String? _error;

  // Your Flask API endpoint
  static const String _apiBaseUrl = 'http://127.0.0.1:5000';

  // Getters
  List<Destination> get destinations => _filteredDestinations;
  List<Destination> get allDestinations => _destinations;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  String? get error => _error;

  // Sample destinations for fallback
  final List<Map<String, dynamic>> _sampleDestinations = [
    {
      'id': 1,
      'name': 'Taj Mahal, Agra',
      'category': 'mustsees',
      'rating': 4.9,
      'reviews': 12450,
      'price': 500.0,
      'original_price': 650.0,
      'image': 'https://images.unsplash.com/photo-1564507592333-c60657eea523?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80',
      'description': 'UNESCO World Heritage site and symbol of eternal love',
      'location': 'Agra, Uttar Pradesh',
      'features': ['UNESCO World Heritage', 'Guided Tours', 'Photography Allowed'],
      'in_wishlist': false,
    },
    {
      'id': 2,
      'name': 'Goa Beach Paradise',
      'category': 'mustsees',
      'rating': 4.7,
      'reviews': 8320,
      'price': 350.0,
      'original_price': 450.0,
      'image': 'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80',
      'description': 'Pristine beaches with vibrant nightlife and water sports',
      'location': 'Goa',
      'features': ['Beach Activities', 'Water Sports', 'Nightlife'],
      'in_wishlist': false,
    },
    {
      'id': 3,
      'name': 'Jaipur City Palace',
      'category': 'cityviews',
      'rating': 4.8,
      'reviews': 6890,
      'price': 400.0,
      'original_price': 500.0,
      'image': 'https://images.unsplash.com/photo-1477587458883-47145ed94245?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80',
      'description': 'Royal heritage in the magnificent Pink City of Rajasthan',
      'location': 'Jaipur, Rajasthan',
      'features': ['Royal Architecture', 'Museum', 'Cultural Shows'],
      'in_wishlist': false,
    },
    {
      'id': 4,
      'name': 'Kerala Backwaters',
      'category': 'tours',
      'rating': 4.9,
      'reviews': 5670,
      'price': 1200.0,
      'original_price': 1500.0,
      'image': 'https://images.unsplash.com/photo-1602216056096-3b40cc0c9944?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80',
      'description': 'Serene houseboat experience in God\'s Own Country',
      'location': 'Alleppey, Kerala',
      'features': ['Houseboat Stay', 'Ayurvedic Spa', 'Local Cuisine'],
      'in_wishlist': false,
    },
    {
      'id': 5,
      'name': 'Himalayan Adventure',
      'category': 'tours',
      'rating': 4.8,
      'reviews': 4230,
      'price': 2500.0,
      'original_price': 3000.0,
      'image': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80',
      'description': 'Breathtaking mountain views and trekking experiences',
      'location': 'Himachal Pradesh',
      'features': ['Trekking', 'Mountain Views', 'Adventure Sports'],
      'in_wishlist': false,
    },
    {
      'id': 6,
      'name': 'Udaipur Lake Palace',
      'category': 'hotels',
      'rating': 4.9,
      'reviews': 2340,
      'price': 15000.0,
      'original_price': 18000.0,
      'image': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80',
      'description': 'Luxury palace hotel floating on Lake Pichola',
      'location': 'Udaipur, Rajasthan',
      'features': ['Luxury Stay', 'Lake Views', 'Royal Dining'],
      'in_wishlist': false,
    },
  ];

  Future<void> loadDestinations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Try to load from Flask API
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/api/destinations'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] && data['destinations'] != null) {
          _destinations = (data['destinations'] as List)
              .map((json) => Destination.fromJson(json))
              .toList();
        } else {
          throw Exception('Invalid API response format');
        }
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading destinations: $e');
      // Use sample data as fallback
      _destinations = _sampleDestinations
          .map((json) => Destination.fromJson(json))
          .toList();
    }

    _filterDestinations();
    _isLoading = false;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    _filterDestinations();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _filterDestinations();
    notifyListeners();
  }

  void _filterDestinations() {
    _filteredDestinations = _destinations.where((destination) {
      // Filter by category
      bool categoryMatch = _selectedCategory == 'all' ||
          destination.category == _selectedCategory;

      // Filter by search query
      bool searchMatch = _searchQuery.isEmpty ||
          destination.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          destination.location.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          destination.description.toLowerCase().contains(_searchQuery.toLowerCase());

      return categoryMatch && searchMatch;
    }).toList();
  }

  Future<void> toggleWishlist(int destinationId) async {
    try {
      // Find destination in both lists
      final destinationIndex = _destinations.indexWhere((d) => d.id == destinationId);
      final filteredIndex = _filteredDestinations.indexWhere((d) => d.id == destinationId);

      if (destinationIndex != -1) {
        // Toggle wishlist status locally first for immediate UI feedback
        final currentStatus = _destinations[destinationIndex].inWishlist;
        _destinations[destinationIndex] = Destination(
          id: _destinations[destinationIndex].id,
          name: _destinations[destinationIndex].name,
          category: _destinations[destinationIndex].category,
          rating: _destinations[destinationIndex].rating,
          reviews: _destinations[destinationIndex].reviews,
          price: _destinations[destinationIndex].price,
          originalPrice: _destinations[destinationIndex].originalPrice,
          image: _destinations[destinationIndex].image,
          description: _destinations[destinationIndex].description,
          location: _destinations[destinationIndex].location,
          features: _destinations[destinationIndex].features,
          inWishlist: !currentStatus,
        );

        // Update filtered list if destination exists there
        if (filteredIndex != -1) {
          _filteredDestinations[filteredIndex] = _destinations[destinationIndex];
        }

        notifyListeners();

        // Try to sync with API
        final response = await http.post(
          Uri.parse('$_apiBaseUrl/api/wishlist'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'destination_id': destinationId}),
        ).timeout(const Duration(seconds: 5));

        if (response.statusCode != 200) {
          // If API call fails, revert the change
          _destinations[destinationIndex] = Destination(
            id: _destinations[destinationIndex].id,
            name: _destinations[destinationIndex].name,
            category: _destinations[destinationIndex].category,
            rating: _destinations[destinationIndex].rating,
            reviews: _destinations[destinationIndex].reviews,
            price: _destinations[destinationIndex].price,
            originalPrice: _destinations[destinationIndex].originalPrice,
            image: _destinations[destinationIndex].image,
            description: _destinations[destinationIndex].description,
            location: _destinations[destinationIndex].location,
            features: _destinations[destinationIndex].features,
            inWishlist: currentStatus,
          );

          if (filteredIndex != -1) {
            _filteredDestinations[filteredIndex] = _destinations[destinationIndex];
          }

          notifyListeners();
          throw Exception('Failed to update wishlist on server');
        }
      }
    } catch (e) {
      print('Error toggling wishlist: $e');
      _error = 'Failed to update wishlist';
      notifyListeners();
    }
  }

  Destination? getDestinationById(int id) {
    try {
      return _destinations.firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
