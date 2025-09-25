import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/app_theme.dart';
import '../widgets/hero_section.dart';
import '../widgets/destination_card.dart';
import '../widgets/category_filter.dart';
import '../widgets/floating_chat_button.dart';
import '../models/destination.dart';
import 'drive_listen_screen.dart';
import 'ai_recognition_screen.dart';
import 'safety_dashboard_screen.dart';
import 'eco_tourism_screen.dart';
import 'virtual_museum_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = 'all';
  final ScrollController _scrollController = ScrollController();
  bool _showAppBarTitle = false;

  // Sample destinations data
  final List<Destination> destinations = [
    Destination(
      id: 1,
      name: 'Taj Mahal, Agra',
      category: 'mustsees',
      rating: 4.9,
      reviews: 12450,
      price: 500,
      originalPrice: 650,
      image: 'https://images.unsplash.com/photo-1564507592333-c60657eea523',
      description: 'UNESCO World Heritage site and symbol of eternal love',
      location: 'Agra, Uttar Pradesh',
      features: ['UNESCO World Heritage', 'Guided Tours', 'Photography'],
    ),
    Destination(
      id: 2,
      name: 'Goa Beach Paradise',
      category: 'mustsees',
      rating: 4.7,
      reviews: 8320,
      price: 350,
      originalPrice: 450,
      image: 'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2',
      description: 'Pristine beaches with vibrant nightlife and water sports',
      location: 'Goa',
      features: ['Beach Activities', 'Water Sports', 'Nightlife'],
    ),
    Destination(
      id: 3,
      name: 'Kerala Backwaters',
      category: 'tours',
      rating: 4.9,
      reviews: 5670,
      price: 1200,
      originalPrice: 1500,
      image: 'https://images.unsplash.com/photo-1602216056096-3b40cc0c9944',
      description: 'Serene houseboat experience in God\'s Own Country',
      location: 'Alleppey, Kerala',
      features: ['Houseboat Stay', 'Ayurvedic Spa', 'Local Cuisine'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.offset > 200 && !_showAppBarTitle) {
      setState(() => _showAppBarTitle = true);
    } else if (_scrollController.offset <= 200 && _showAppBarTitle) {
      setState(() => _showAppBarTitle = false);
    }
  }

  List<Destination> get filteredDestinations {
    if (selectedCategory == 'all') return destinations;
    return destinations.where((d) => d.category == selectedCategory).toList();
  }

  // 🚀 NAVIGATION METHODS FOR WINNING FEATURES
  void _navigateToAIRecognition() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AIRecognitionScreen()),
    );
  }

  void _navigateToSafety() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SafetyDashboardScreen()),
    );
  }

  void _navigateToEcoTourism() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EcoTourismScreen()),
    );
  }

  void _navigateToVirtualMuseum() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const VirtualMuseumScreen()),
    );
  }

  void _navigateToDriveListen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DriveListenScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 0,
                floating: true,
                pinned: true,
                backgroundColor: Colors.white,
                elevation: _showAppBarTitle ? 1 : 0,
                title: AnimatedOpacity(
                  opacity: _showAppBarTitle ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    'AtithiVerse',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.account_circle_outlined),
                    onPressed: () {},
                  ),
                ],
              ),

              // Hero Section
              const SliverToBoxAdapter(
                child: HeroSection(),
              ),

              // 🏆 SMART INDIA HACKATHON WINNING FEATURES
              SliverToBoxAdapter(
                child: _buildSmartIndiaFeatures(),
              ),

              // 🚗 DRIVE & LISTEN FEATURE CARD
              SliverToBoxAdapter(
                child: _buildDriveListenCard(),
              ),

              // Category Filters
              SliverToBoxAdapter(
                child: CategoryFilter(
                  selectedCategory: selectedCategory,
                  onCategoryChanged: (category) {
                    setState(() => selectedCategory = category);
                  },
                ),
              ),

              // Section Title
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Popular Destinations',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ),

              // Destinations Grid
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 375),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: DestinationCard(
                                destination: filteredDestinations[index],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: filteredDestinations.length,
                  ),
                ),
              ),

              // 🇮🇳 GOVERNMENT INTEGRATION SECTION
              SliverToBoxAdapter(
                child: _buildGovernmentServicesSection(),
              ),

              // Bottom spacing
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),

          // Floating Chat Button
          const FloatingChatButton(),
        ],
      ),
    );
  }

  // 🏆 SMART INDIA HACKATHON WINNING FEATURES SECTION
  Widget _buildSmartIndiaFeatures() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppGradients.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.emoji_events, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Smart India Features',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      'AI-powered travel innovations',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: [
              _buildSmartFeatureCard(
                '🤖 AI Recognition',
                'Point camera at monuments\nfor instant information',
                Colors.blue,
                Icons.camera_alt,
                _navigateToAIRecognition,
              ),
              _buildSmartFeatureCard(
                '🚺 Women Safety',
                'Emergency SOS & real-time\nlocation sharing',
                Colors.pink,
                Icons.security,
                _navigateToSafety,
              ),
              _buildSmartFeatureCard(
                '🌱 Eco Tourism',
                'Carbon footprint tracker\n& sustainable travel',
                Colors.green,
                Icons.eco,
                _navigateToEcoTourism,
              ),
              _buildSmartFeatureCard(
                '🏛️ Virtual Museums',
                '360° heritage tours with\n3D artifacts',
                Colors.purple,
                Icons.museum,
                _navigateToVirtualMuseum,
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms, delay: 400.ms);
  }

  Widget _buildSmartFeatureCard(
      String title,
      String subtitle,
      Color color,
      IconData icon,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.8), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.white.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  // 🚗 DRIVE & LISTEN FEATURE CARD
  Widget _buildDriveListenCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _navigateToDriveListen,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.drive_eta, color: Colors.white, size: 28),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '🆕 NEW',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Text(
                  'Virtual City Drive 🚗',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Experience Indian cities virtually with immersive driving and local radio stations',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    _buildFeatureChip('🚗 12+ Cities', Colors.white.withOpacity(0.2)),
                    const SizedBox(width: 8),
                    _buildFeatureChip('📻 Local Radio', Colors.white.withOpacity(0.2)),
                    const SizedBox(width: 8),
                    _buildFeatureChip('🎮 Interactive', Colors.white.withOpacity(0.2)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().slideX(delay: 600.ms, duration: 800.ms);
  }

  Widget _buildFeatureChip(String text, Color backgroundColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }

  // 🇮🇳 GOVERNMENT INTEGRATION SECTION
  Widget _buildGovernmentServicesSection() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.shade50,
            Colors.green.shade50,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.account_balance, color: Colors.orange.shade700),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Government Services Integration',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      'Digital India • Incredible India Initiative',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.verified, color: Colors.white, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.2,
            children: [
              _buildGovServiceCard(
                '🚂 IRCTC',
                'Railway\nBooking',
                Colors.blue,
                    () => _showComingSoon('Railway Integration'),
              ),
              _buildGovServiceCard(
                '📄 e-Visa',
                'Tourist\nVisa',
                Colors.green,
                    () => _showComingSoon('e-Visa Services'),
              ),
              _buildGovServiceCard(
                '📱 UPI',
                'Digital\nPayments',
                Colors.purple,
                    () => _showComingSoon('UPI Integration'),
              ),
              _buildGovServiceCard(
                '🆔 DigiLocker',
                'Document\nStorage',
                Colors.orange,
                    () => _showComingSoon('DigiLocker'),
              ),
              _buildGovServiceCard(
                '🏥 Ayushman',
                'Health\nInsurance',
                Colors.red,
                    () => _showComingSoon('Healthcare'),
              ),
              _buildGovServiceCard(
                '📞 1363',
                'Tourist\nHelpline',
                Colors.teal,
                    () => _showComingSoon('Emergency Services'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade300),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange.shade700, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Seamless integration with official Government of India services',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 1000.ms);
  }

  Widget _buildGovServiceCard(String title, String subtitle, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(String service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.rocket_launch, color: Colors.orange),
            const SizedBox(width: 8),
            const Text('Coming Soon!'),
          ],
        ),
        content: Text('$service integration will be available in the next update. Stay tuned! 🚀'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
