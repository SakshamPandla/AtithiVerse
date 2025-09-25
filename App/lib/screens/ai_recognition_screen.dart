import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/app_theme.dart';

class AIRecognitionScreen extends StatefulWidget {
  const AIRecognitionScreen({super.key});

  @override
  State<AIRecognitionScreen> createState() => _AIRecognitionScreenState();
}

class _AIRecognitionScreenState extends State<AIRecognitionScreen> {
  CameraController? _cameraController;
  bool _isDetecting = false;
  String _monumentInfo = '';
  bool _showInfo = false;
  bool _cameraInitialized = false;

  // Monument database
  final Map<String, Map<String, String>> _monumentDatabase = {
    'taj mahal': {
      'name': 'Taj Mahal',
      'location': 'Agra, Uttar Pradesh',
      'history': 'Built by Shah Jahan in memory of Mumtaz Mahal (1632-1653)',
      'timings': '6:00 AM - 6:30 PM (Closed on Fridays)',
      'entry_fee': 'Indians: ₹500, Foreigners: ₹1,100',
      'best_time': 'October to March',
      'significance': 'UNESCO World Heritage Site, Wonder of the World',
    },
    'red fort': {
      'name': 'Red Fort (Lal Qila)',
      'location': 'Delhi',
      'history': 'Mughal fortress built by Emperor Shah Jahan (1639-1648)',
      'timings': '9:30 AM - 4:30 PM (Closed on Mondays)',
      'entry_fee': 'Indians: ₹35, Foreigners: ₹500',
      'best_time': 'October to March',
      'significance': 'UNESCO World Heritage Site, Independence Day celebrations',
    },
    'gateway of india': {
      'name': 'Gateway of India',
      'location': 'Mumbai, Maharashtra',
      'history': 'Built to commemorate visit of King George V (1924)',
      'timings': 'Open 24 hours',
      'entry_fee': 'Free (Boat rides extra)',
      'best_time': 'November to February',
      'significance': 'Iconic monument, British departure point (1948)',
    },
    'qutub minar': {
      'name': 'Qutub Minar',
      'location': 'Delhi',
      'history': 'Victory tower built by Qutb-ud-din Aibak (1199)',
      'timings': '7:00 AM - 5:00 PM',
      'entry_fee': 'Indians: ₹30, Foreigners: ₹500',
      'best_time': 'October to March',
      'significance': 'UNESCO World Heritage Site, Tallest brick minaret',
    },
  };

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _cameraController = CameraController(
          cameras.first,
          ResolutionPreset.medium,
        );
        await _cameraController!.initialize();
        setState(() {
          _cameraInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing camera: $e');
      // Camera not available - show demo mode
      setState(() {
        _cameraInitialized = false;
      });
    }
  }

  Future<void> _captureAndAnalyze() async {
    if (_isDetecting) return;

    setState(() {
      _isDetecting = true;
      _showInfo = false;
    });

    // Simulate AI processing for 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    // Simulate monument recognition (demo for hackathon)
    final monuments = _monumentDatabase.keys.toList();
    final randomMonument = monuments[DateTime.now().millisecond % monuments.length];

    setState(() {
      _monumentInfo = randomMonument;
      _showInfo = true;
      _isDetecting = false;
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Monument recognized: ${_monumentDatabase[randomMonument]!['name']}!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: Text(
          'AI Monument Recognition',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () => _showDemoInfo(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera Preview or Demo View
          Positioned.fill(
            child: _cameraInitialized && _cameraController != null
                ? CameraPreview(_cameraController!)
                : _buildDemoView(),
          ),

          // Overlay UI
          _buildOverlayUI(),

          // Monument Information Panel
          if (_showInfo) _buildMonumentInfoPanel(),
        ],
      ),
      floatingActionButton: _buildCaptureButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildDemoView() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade900, Colors.purple.shade900],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 80,
                color: Colors.white,
              ),
            ).animate().scale(duration: 1000.ms).fadeIn(duration: 800.ms),

            const SizedBox(height: 30),

            Text(
              'AI Camera Simulation',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'Tap the capture button to simulate\nmonument recognition',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlayUI() {
    return Positioned(
      top: 20,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              Icons.smart_toy,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'AI Monument Recognition',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              _cameraInitialized
                  ? 'Point camera at monument & tap capture'
                  : 'Demo mode - Tap capture to simulate recognition',
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3),
    );
  }

  Widget _buildCaptureButton() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isDetecting ? null : _captureAndAnalyze,
          borderRadius: BorderRadius.circular(40),
          child: _isDetecting
              ? const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
          )
              : const Icon(
            Icons.camera_alt,
            color: Colors.white,
            size: 32,
          ),
        ),
      ),
    );
  }

  Widget _buildMonumentInfoPanel() {
    final monument = _monumentDatabase[_monumentInfo];
    if (monument == null) return const SizedBox.shrink();

    return Positioned(
      bottom: 100,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '✅ ${monument['name']!}',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _showInfo = false),
                ),
              ],
            ),

            const SizedBox(height: 12),

            _buildInfoRow(Icons.location_on, 'Location', monument['location']!),
            _buildInfoRow(Icons.history, 'History', monument['history']!),
            _buildInfoRow(Icons.access_time, 'Timings', monument['timings']!),
            _buildInfoRow(Icons.currency_rupee, 'Entry Fee', monument['entry_fee']!),
            _buildInfoRow(Icons.star, 'Significance', monument['significance']!),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showDirections(monument['location']!),
                    icon: const Icon(Icons.directions, size: 18),
                    label: Text('Get Directions'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _bookTickets(monument['name']!),
                    icon: const Icon(Icons.confirmation_number, size: 18),
                    label: Text('Book Tickets'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTheme.primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ).animate().slideY(begin: 0.5, duration: 600.ms).fadeIn(duration: 400.ms),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryColor),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDirections(String location) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🗺️ Opening directions to $location...'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _bookTickets(String monumentName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎫 Booking tickets for $monumentName...'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showDemoInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            const Text('Demo Mode'),
          ],
        ),
        content: const Text(
            'This is a demo simulation of AI monument recognition for the Smart India Hackathon.\n\n'
                'In the full version, this would use real AI/ML to recognize monuments from camera input.\n\n'
                'Tap the capture button to see how monument information would be displayed!'
        ),
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
    _cameraController?.dispose();
    super.dispose();
  }
}
