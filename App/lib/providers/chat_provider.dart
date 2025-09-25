import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/destination.dart';

class ChatProvider with ChangeNotifier {
  final List<ChatMessage> _messages = [];
  final List<String> _currentSuggestions = [];
  bool _isTyping = false;
  bool _isAiPowered = true;

  // Your Flask API endpoint - UPDATE THIS TO YOUR FLASK SERVER
  static const String _apiBaseUrl = 'https://atithiverse.qzz.io';

  List<ChatMessage> get messages => _messages;
  List<String> get currentSuggestions => _currentSuggestions;
  bool get isTyping => _isTyping;
  bool get isAiPowered => _isAiPowered;

  void initializeChat() {
    if (_messages.isEmpty) {
      _addBotMessage(
        "👋 **Namaste! Welcome to AtithiVerse!**\n\nI'm your personal AI travel guide for **Incredible India**! 🇮🇳\n\nI can instantly help you with:\n• **Popular destinations** & hidden gems\n• **Trip planning** & custom itineraries  \n• **Budget advice** & money-saving tips\n• **Best travel times** & weather info\n• **Cultural experiences** & local insights\n\nWhat adventure can I help you plan today? 🗺️",
        [
          "Show me popular destinations",
          "Plan a 7-day trip",
          "Best time to visit India",
          "Budget travel tips"
        ],
      );
    }
  }

  Future<void> sendMessage(String message) async {
    // Add user message immediately
    _addUserMessage(message);

    // Clear current suggestions
    _currentSuggestions.clear();
    notifyListeners();

    // Start typing indicator
    _setTyping(true);

    try {
      print('🌐 Sending request to: $_apiBaseUrl/api/chat');
      print('📤 Message: $message');

      // Call your Flask API with proper structure
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/api/chat'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'user_input': message,
          // Add conversation history if needed
          'conversation_history': _messages
              .where((m) => m.message.isNotEmpty)
              .map((m) => {
            'message': m.message,
            'is_user': m.isUser,
            'timestamp': m.timestamp.toIso8601String(),
          })
              .toList(),
        }),
      ).timeout(const Duration(seconds: 15));

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('📊 Parsed data: $data');

        if (data['success'] == true) {
          // Extract response and suggestions from your Flask API
          String botResponse = data['response'] ?? 'I apologize, but I couldn\'t process that request.';
          List<String> suggestions = [];

          // Handle suggestions - your API returns them as a list
          if (data['suggestions'] != null) {
            if (data['suggestions'] is List) {
              suggestions = List<String>.from(data['suggestions']);
            }
          }

          // Check if AI powered
          _isAiPowered = data['ai_powered'] ?? false;

          _addBotMessage(botResponse, suggestions);
          print('✅ Bot response added successfully');
        } else {
          throw Exception('API returned success=false: ${data['error'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }

    } catch (e) {
      print('❌ Chat API Error: $e');

      // Use enhanced fallback with the same quality as your Flask API
      _isAiPowered = false;
      _addBotMessage(
        _getEnhancedFallbackResponse(message),
        _getEnhancedFallbackSuggestions(message),
      );
    } finally {
      _setTyping(false);
    }
  }

  void _addUserMessage(String message) {
    _messages.add(ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: message,
      isUser: true,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  void _addBotMessage(String message, List<String> suggestions) {
    _messages.add(ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: message,
      isUser: false,
      timestamp: DateTime.now(),
      suggestions: suggestions,
    ));

    _currentSuggestions.clear();
    _currentSuggestions.addAll(suggestions.take(4));
    notifyListeners();
  }

  void _setTyping(bool typing) {
    _isTyping = typing;
    notifyListeners();
  }

  void clearChat() {
    _messages.clear();
    _currentSuggestions.clear();
    _isTyping = false;
    notifyListeners();
    initializeChat();
  }

  // Enhanced fallback responses matching your Flask API quality
  String _getEnhancedFallbackResponse(String message) {
    final input = message.toLowerCase();

    // Popular destinations
    if (input.contains('popular') && input.contains('destination')) {
      return """🏛️ **India's Most Popular Destinations:**

✨ **Golden Triangle Circuit**:
• **Delhi**: Red Fort, India Gate, Qutub Minar (₹30-500)
• **Agra**: Taj Mahal (₹500), Agra Fort (₹500)  
• **Jaipur**: City Palace (₹400), Amber Fort (₹500)

🏖️ **Beach Paradise**:
• **Goa**: North (party) vs South (peaceful) - ₹2,000-5,000/day
• **Kerala**: Backwaters, houseboats (₹4,000-12,000/night)
• **Andaman**: Crystal waters, diving, pristine beaches

🏔️ **Mountain Escapes**:
• **Himachal Pradesh**: Shimla, Manali, adventure sports
• **Uttarakhand**: Rishikesh (yoga), Nainital (lakes)
• **Kashmir**: Srinagar, Dal Lake, breathtaking valleys

Which type of destination excites you most? 🗺️""";
    }

    // Trip planning
    if (input.contains('plan') || input.contains('trip') || input.contains('itinerary')) {
      return """✈️ **Let's Plan Your Perfect Indian Adventure!**

🎯 **Tell me your preferences**:

📅 **Duration**: How many days do you have?
• 3-5 days: Single region focus
• 7-10 days: Golden Triangle or regional circuit  
• 2-3 weeks: Multi-region grand tour

🎨 **What excites you most?**
• **🏛️ History & Culture**: Delhi, Agra, Rajasthan palaces
• **🏖️ Beaches & Relaxation**: Goa, Kerala backwaters  
• **🏔️ Mountains & Adventure**: Himalayas, hill stations
• **🕉️ Spiritual Journey**: Varanasi, Rishikesh

💰 **Budget Range**:
• **Budget Explorer**: ₹2,000-4,000/day
• **Comfort Traveler**: ₹5,000-10,000/day  

Share these details and I'll create your personalized itinerary! 🗺️""";
    }

    // Budget queries
    if (input.contains('budget') || input.contains('cost') || input.contains('money')) {
      return """💰 **India Budget Guide - Incredible Value!**

**📊 Daily Costs (per person)**:

🛏️ **Accommodation**:
• **Hostels/Dorms**: ₹500-1,500
• **Budget Hotels**: ₹1,500-3,000  
• **Mid-Range**: ₹3,000-8,000

🍽️ **Food**:
• **Street Food**: ₹50-200/meal (authentic & safe)
• **Local Restaurants**: ₹200-500/meal
• **Tourist Areas**: ₹500-1,000/meal

🚌 **Transportation**:
• **Local Buses**: ₹10-50 (city travel)
• **Trains**: ₹200-2,000 (depends on distance)
• **Taxis/Autos**: ₹100-500/day

📊 **Total Daily Budgets**:
• **Backpacker**: ₹1,200-2,500
• **Mid-Range Comfort**: ₹3,000-6,000
• **Luxury Travel**: ₹8,000-20,000+

What's your preferred budget range? 💭""";
    }

    // Best time queries
    if (input.contains('best time') || input.contains('weather') || input.contains('season')) {
      return """🌤️ **India Travel Seasons Guide:**

🌟 **Peak Season (October - March)**:
• **Weather**: Cool & pleasant (15-25°C)
• **Perfect for**: North India, Rajasthan, Goa
• **Pros**: Best weather, clear skies, festivals
• **Cons**: Higher prices, crowds

☀️ **Summer Season (April - June)**:
• **Perfect for**: Hill stations, Kashmir, Ladakh
• **Great deals** and fewer crowds in mountains

🌧️ **Monsoon Season (July - September)**:
• **Perfect for**: Kerala backwaters, Western Ghats
• **Pros**: Lush landscapes, lowest prices

📍 **Region-Specific Best Times**:
• **North India**: Oct-Mar
• **South India**: Nov-Feb  
• **Beaches (Goa)**: Nov-Mar
• **Mountains**: Apr-Jun & Sep-Nov

Which region interests you most? 🗺️""";
    }

    // Taj Mahal
    if (input.contains('taj mahal') || input.contains('agra')) {
      return """🏛️ **Taj Mahal - The Crown Jewel of India!**

💰 **Entry Costs**:
• Indians: ₹500 • Foreigners: ₹1,100
• Online booking saves queue time!

⏰ **Best Visiting Times**:
• **Sunrise** (6:00 AM): Golden glow, fewer crowds ⭐
• **Sunset** (5:30 PM): Romantic pink hues

📅 **Important Info**:
• **Closed**: Every Friday
• **Duration**: 3-4 hours recommended

🎯 **Perfect 2-Day Agra Itinerary**:
**Day 1**: Taj Mahal (sunrise) → Agra Fort → Local lunch
**Day 2**: Fatehpur Sikri → Mehtab Bagh (sunset view)

Need hotel recommendations? 🏨""";
    }

    // Goa
    if (input.contains('goa') || input.contains('beach')) {
      return """🏖️ **Goa - Beach Paradise Guide!**

🎉 **North Goa** (Party & Adventure):
• **Baga Beach**: Water sports, shacks, nightlife
• **Calangute**: Crowded but happening
• **Anjuna**: Flea markets, trance parties

🌅 **South Goa** (Peaceful & Pristine):
• **Palolem**: Perfect crescent, beach huts
• **Agonda**: Pristine, fewer crowds
• **Butterfly Beach**: Hidden gem

💡 **Essential Goa Info**:
• **Best Time**: November-March
• **Daily Budget**: ₹2,000-5,000
• **Rent Scooter**: ₹300-500/day

🎭 **Choose Your Vibe**: Party scene or peaceful relaxation? 🤔""";
    }

    // Kerala
    if (input.contains('kerala') || input.contains('backwater')) {
      return """🌴 **Kerala - God's Own Country!**

🛥️ **Backwater Experience**:
• **Alleppey**: Most popular, ₹4,000-8,000/night
• **Kumarakom**: Luxury options, ₹6,000-15,000/night
• **Kollam**: Budget-friendly, ₹3,000-6,000/night

✨ **Unmissable Experiences**:
• **Traditional Houseboat Stay**
• **Ayurvedic Full-Body Massage**
• **Village Walks** through paddy fields
• **Authentic Kerala Cuisine**

🏔️ **Hill Station Extensions**:
• **Munnar**: Tea plantations
• **Wayanad**: Wildlife sanctuary
• **Thekkady**: Spice gardens

📅 **Perfect Time**: October-March
Planning a romantic getaway? 💕""";
    }

    // Default comprehensive response
    return """🇮🇳 **Welcome to Incredible India!**

I'm your **instant travel expert** ready to help you discover the magic of India! ✨

🎯 **I can help you with**:

🏛️ **Iconic Destinations**: Taj Mahal, Golden Temple, Red Fort
🏖️ **Beach Paradise**: Goa's coastline, Kerala backwaters  
🏔️ **Mountain Adventures**: Himalayan treks, hill stations
🏰 **Royal Heritage**: Rajasthan palaces, desert safaris
💰 **Smart Planning**: Budget tips, best deals
📅 **Perfect Timing**: Seasonal guides, weather insights

**✨ Try asking me**:
• "Show me popular destinations"
• "Plan a 10-day trip with ₹80,000 budget"  
• "What's the best time to visit Kerala?"
• "Budget backpacking tips for North India"

What aspect of **Incredible India** excites you most? 🗺️🎉""";
  }

  List<String> _getEnhancedFallbackSuggestions(String message) {
    final input = message.toLowerCase();

    if (input.contains('popular')) {
      return ["Golden Triangle Tour", "Goa Beach Guide", "Kerala Backwaters", "Rajasthan Palaces"];
    }
    if (input.contains('plan') || input.contains('trip')) {
      return ["7-day Golden Triangle", "Kerala 5-day tour", "Rajasthan circuit", "Budget Planning"];
    }
    if (input.contains('budget')) {
      return ["Budget Destinations", "Money-saving Tips", "Cheap Stays", "Local Transport"];
    }
    if (input.contains('taj mahal')) {
      return ["2-day Agra itinerary", "Best photo spots", "Nearby attractions", "Agra hotels"];
    }
    if (input.contains('goa')) {
      return ["North vs South Goa", "Best beaches", "Water sports", "Nightlife guide"];
    }
    if (input.contains('kerala')) {
      return ["Houseboat booking", "Hill stations", "Ayurvedic spas", "Kerala cuisine"];
    }
    if (input.contains('best time')) {
      return ["Regional weather", "Festival calendar", "Peak vs off-season", "Packing tips"];
    }

    return ["Popular destinations", "Trip planning", "Best travel time", "Budget advice"];
  }
}
