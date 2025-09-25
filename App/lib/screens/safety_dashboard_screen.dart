import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';  // ✅ For phone calls
import '../utils/app_theme.dart';

class SafetyDashboardScreen extends StatefulWidget {
  const SafetyDashboardScreen({super.key});

  @override
  State<SafetyDashboardScreen> createState() => _SafetyDashboardScreenState();
}

class _SafetyDashboardScreenState extends State<SafetyDashboardScreen> {
  Position? _currentPosition;
  bool _isEmergencyActive = false;

  List<Map<String, String>> _emergencyContacts = [
    {'name': 'Police', 'number': '100'},
    {'name': 'Women Helpline', 'number': '1091'},
    {'name': 'Tourist Helpline', 'number': '1363'},
    {'name': 'Medical Emergency', 'number': '108'},
  ];

  List<Map<String, String>> _safetyTips = [
    {
      'title': 'Share Your Location',
      'tip': 'Always share your live location with trusted contacts',
      'icon': 'location_on'
    },
    {
      'title': 'Stay Connected',
      'tip': 'Keep your phone charged and carry a power bank',
      'icon': 'battery_charging_full'
    },
    {
      'title': 'Trust Your Instincts',
      'tip': 'If something feels wrong, remove yourself from the situation',
      'icon': 'psychology'
    },
    {
      'title': 'Use Verified Transport',
      'tip': 'Use official taxis, verified ride-sharing apps',
      'icon': 'verified'
    },
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition();
        setState(() {
          _currentPosition = position;
        });
      }
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<void> _triggerEmergency() async {
    setState(() {
      _isEmergencyActive = true;
    });

    // Send emergency alert (without SMS - using share instead)
    if (_currentPosition != null) {
      String locationUrl = 'https://maps.google.com/?q=${_currentPosition!.latitude},${_currentPosition!.longitude}';

      // Show emergency dialog with options
      _showEmergencyOptions(locationUrl);
    }
  }

  void _showEmergencyOptions(String locationUrl) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.red.shade50,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Emergency Mode Active',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your location: ${_currentPosition?.latitude.toStringAsFixed(4)}, ${_currentPosition?.longitude.toStringAsFixed(4)}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            const Text('Choose emergency action:'),
            const SizedBox(height: 12),

            // Emergency action buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _callEmergencyNumber('100'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                icon: const Icon(Icons.phone, color: Colors.white),
                label: const Text('Call Police (100)', style: TextStyle(color: Colors.white)),
              ),
            ),

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _shareEmergencyLocation(locationUrl),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                icon: const Icon(Icons.share, color: Colors.white),
                label: const Text('Share Location', style: TextStyle(color: Colors.white)),
              ),
            ),

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openLocationInMaps(locationUrl),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                icon: const Icon(Icons.map, color: Colors.white),
                label: const Text('Open in Maps', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _isEmergencyActive = false);
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _callEmergencyNumber(String number) async {
    Navigator.pop(context); // Close dialog first

    final Uri phoneUri = Uri(scheme: 'tel', path: number);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        _showErrorMessage('Cannot make call to $number');
      }
    } catch (e) {
      _showErrorMessage('Error calling $number');
    }
  }

  Future<void> _shareEmergencyLocation(String locationUrl) async {
    Navigator.pop(context); // Close dialog first

    final Uri shareUri = Uri(
      scheme: 'mailto',
      query: 'subject=Emergency Alert&body=EMERGENCY! I need help. My location: $locationUrl',
    );

    try {
      if (await canLaunchUrl(shareUri)) {
        await launchUrl(shareUri);
      } else {
        _showErrorMessage('Cannot open email app');
      }
    } catch (e) {
      _showErrorMessage('Error sharing location');
    }
  }

  Future<void> _openLocationInMaps(String locationUrl) async {
    Navigator.pop(context); // Close dialog first

    final Uri mapsUri = Uri.parse(locationUrl);
    try {
      if (await canLaunchUrl(mapsUri)) {
        await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorMessage('Cannot open maps');
      }
    } catch (e) {
      _showErrorMessage('Error opening maps');
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: Text(
          'Women Safety Dashboard',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEmergencyButton(),
            const SizedBox(height: 24),
            _buildLocationStatus(),
            const SizedBox(height: 24),
            _buildEmergencyContacts(),
            const SizedBox(height: 24),
            _buildSafetyTips(),
            const SizedBox(height: 24),
            _buildSafetyFeatures(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyButton() {
    return Container(
      width: double.infinity,
      height: 120,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isEmergencyActive ? null : _triggerEmergency,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isEmergencyActive
                    ? [Colors.red.shade400, Colors.red.shade600]
                    : [Colors.pink.shade400, Colors.red.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isEmergencyActive ? Icons.warning : Icons.sos,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isEmergencyActive ? 'EMERGENCY ACTIVE' : 'SOS EMERGENCY',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _isEmergencyActive
                      ? 'Help is on the way'
                      : 'Tap to activate emergency mode',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 800.ms).scale(delay: 200.ms); // ✅ FIXED animation
  }

  // ✅ FIXED: Add the missing methods that were causing errors
  Widget _buildLocationStatus() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        border: Border.all(color: Colors.green.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.my_location, color: Colors.green.shade700),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Location Tracking Active',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
                ),
                Text(
                  _currentPosition != null
                      ? 'Lat: ${_currentPosition!.latitude.toStringAsFixed(4)}, Lng: ${_currentPosition!.longitude.toStringAsFixed(4)}'
                      : 'Getting your location...',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.green.shade600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _currentPosition != null,
            onChanged: (value) => _getCurrentLocation(),
            activeColor: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContacts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Emergency Contacts',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(_emergencyContacts.length, (index) {
          final contact = _emergencyContacts[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.phone, color: Colors.red.shade700, size: 20),
              ),
              title: Text(
                contact['name']!,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(contact['number']!),
              trailing: IconButton(
                icon: const Icon(Icons.call, color: Colors.green),
                onPressed: () => _callEmergencyNumber(contact['number']!),
              ),
              tileColor: Colors.grey.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSafetyTips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Safety Tips',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(_safetyTips.length, (index) {
          final tip = _safetyTips[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getIconFromString(tip['icon']!),
                    color: Colors.blue.shade700,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tip['title']!,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      Text(
                        tip['tip']!,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.blue.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().slideX(
            delay: Duration(milliseconds: index * 100),
            duration: const Duration(milliseconds: 400),
          );
        }),
      ],
    );
  }

  Widget _buildSafetyFeatures() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Safety Features',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildFeatureCard(
              'Safe Routes',
              'Find well-lit, populated routes',
              Icons.route,
              Colors.green,
            ),
            _buildFeatureCard(
              'Verified Stays',
              'Women-friendly accommodations',
              Icons.hotel,
              Colors.purple,
            ),
            _buildFeatureCard(
              'Travel Buddy',
              'Connect with fellow travelers',
              Icons.people,
              Colors.orange,
            ),
            _buildFeatureCard(
              'Live Tracking',
              'Share location with contacts',
              Icons.track_changes,
              Colors.blue,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureCard(String title, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: color.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'location_on':
        return Icons.location_on;
      case 'battery_charging_full':
        return Icons.battery_charging_full;
      case 'psychology':
        return Icons.psychology;
      case 'verified':
        return Icons.verified;
      default:
        return Icons.info;
    }
  }
}
