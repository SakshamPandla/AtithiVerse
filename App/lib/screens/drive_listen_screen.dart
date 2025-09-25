import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/app_theme.dart';

class DriveListenScreen extends StatefulWidget {
  final String? selectedCity;

  const DriveListenScreen({
    super.key,
    this.selectedCity,
  });

  @override
  State<DriveListenScreen> createState() => _DriveListenScreenState();
}

class _DriveListenScreenState extends State<DriveListenScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  // Indian cities available on Drive & Listen
  final List<Map<String, String>> _indianCities = [
    {'name': '🌆 Mumbai, India', 'url': 'mumbai-india'},
    {'name': '🏛️ Delhi, India', 'url': 'delhi-india'},
    {'name': '🌟 Bangalore, India', 'url': 'bangalore-india'},
    {'name': '🏖️ Chennai, India', 'url': 'chennai-india'},
    {'name': '💎 Hyderabad, India', 'url': 'hyderabad-india'},
    {'name': '🎭 Kolkata, India', 'url': 'kolkata-india'},
    {'name': '🌿 Pune, India', 'url': 'pune-india'},
    {'name': '🕌 Ahmedabad, India', 'url': 'ahmedabad-india'},
    {'name': '👑 Jaipur, India', 'url': 'jaipur-india'},
    {'name': '🏖️ Goa, India', 'url': 'goa-india'},
    {'name': '🌸 Shimla, India', 'url': 'shimla-himachal-pradesh-india'},
    {'name': '🙏 Amritsar, India', 'url': 'amritsar-punjab-india'},
  ];

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (progress == 100) {
              setState(() => _isLoading = false);
            }
          },
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse('https://drivenlisten.com/city/'));
  }

  void _loadCity(String cityUrl) {
    final fullUrl = 'https://drivenlisten.com/city/$cityUrl/';
    _controller.loadRequest(Uri.parse(fullUrl));
  }

  void _showCitySelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildCitySelector(),
    );
  }

  Widget _buildCitySelector() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.location_on, color: AppTheme.primaryColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Choose Indian City to Explore',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // City List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _indianCities.length,
              itemBuilder: (context, index) {
                final city = _indianCities[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: AppGradients.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.drive_eta, color: Colors.white, size: 24),
                    ),
                    title: Text(
                      city['name']!,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      'Virtual driving experience with local radio',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.pop(context);
                      _loadCity(city['url']!);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.drive_eta, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Drive & Listen',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Virtual City Exploration',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.location_city, color: Colors.white),
            onPressed: _showCitySelector,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => _controller.reload(),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryColor,
        onPressed: _showCitySelector,
        child: const Icon(Icons.location_city, color: Colors.white),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: AppGradients.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.drive_eta, size: 40, color: Colors.white),
            ).animate(onPlay: (controller) => controller.repeat()).rotate(duration: 2000.ms),

            const SizedBox(height: 24),

            Text(
              'Loading Virtual Drive...',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Get ready for an immersive city experience',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),

            const SizedBox(height: 24),

            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
