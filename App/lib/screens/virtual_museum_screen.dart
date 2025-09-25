import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/app_theme.dart';

class VirtualMuseumScreen extends StatefulWidget {
  const VirtualMuseumScreen({super.key});

  @override
  State<VirtualMuseumScreen> createState() => _VirtualMuseumScreenState();
}

class _VirtualMuseumScreenState extends State<VirtualMuseumScreen> {
  int _currentArtifactIndex = 0;
  bool _isVirtualTourActive = false;

  final List<Map<String, dynamic>> _museums = [
    {
      'name': 'National Museum',
      'location': 'New Delhi',
      'established': '1949',
      'artifacts': 200000,
      'highlights': ['Harappan Civilization', 'Mauryan Sculptures', 'Medieval Art'],
      'virtual_tours': 5,
      'rating': 4.8,
      'image': 'https://images.unsplash.com/photo-1554907984-15263bfd63bd',
    },
    {
      'name': 'Indian Museum',
      'location': 'Kolkata',
      'established': '1814',
      'artifacts': 100000,
      'highlights': ['Egyptian Mummy', 'Buddhist Art', 'Geological Specimens'],
      'virtual_tours': 3,
      'rating': 4.6,
      'image': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96',
    },
    {
      'name': 'Chhatrapati Shivaji Museum',
      'location': 'Mumbai',
      'established': '1922',
      'artifacts': 50000,
      'highlights': ['Miniature Paintings', 'Arms & Armour', 'Natural History'],
      'virtual_tours': 4,
      'rating': 4.7,
      'image': 'https://images.unsplash.com/photo-1571115764595-644a1f56a55c',
    },
  ];

  final List<Map<String, dynamic>> _featuredArtifacts = [
    {
      'name': 'Dancing Girl of Harappa',
      'period': '2500-1500 BCE',
      'material': 'Bronze',
      'description': 'One of the finest examples of Harappan bronze casting, this 4,000-year-old bronze figurine depicts a young woman in a confident pose.',
      'significance': 'Represents the artistic sophistication of the Indus Valley Civilization',
      'museum': 'National Museum, Delhi',
      'image': 'https://images.unsplash.com/photo-1594736797933-d0401ba2fe65',
      'audio_guide': true,
      '3d_model': true,
    },
    {
      'name': 'Mauryan Lion Capital',
      'period': '250 BCE',
      'material': 'Sandstone',
      'description': 'The national emblem of India, this sculpture was originally placed atop Emperor Ashoka\'s pillar at Sarnath.',
      'significance': 'Symbol of Indian sovereignty and Buddhist philosophy',
      'museum': 'Sarnath Museum',
      'image': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96',
      'audio_guide': true,
      '3d_model': true,
    },
    {
      'name': 'Gandhara Buddha',
      'period': '2nd-5th Century CE',
      'material': 'Schist Stone',
      'description': 'Greco-Buddhist art fusion showing Hellenistic influence on Indian Buddhist sculpture.',
      'significance': 'Represents cultural synthesis along the Silk Road',
      'museum': 'National Museum, Delhi',
      'image': 'https://images.unsplash.com/photo-1605948042683-41a8d6e45d56',
      'audio_guide': true,
      '3d_model': false,
    },
  ];

  final List<Map<String, String>> _historicalPeriods = [
    {
      'period': 'Indus Valley Civilization',
      'timeline': '3300-1300 BCE',
      'key_features': 'Urban planning, Drainage systems, Bronze working',
      'major_sites': 'Harappa, Mohenjodaro, Dholavira',
    },
    {
      'period': 'Mauryan Empire',
      'timeline': '322-185 BCE',
      'key_features': 'First unified Indian empire, Buddhism patronage',
      'major_sites': 'Pataliputra, Sarnath, Sanchi',
    },
    {
      'period': 'Gupta Period',
      'timeline': '320-550 CE',
      'key_features': 'Golden Age of arts and sciences',
      'major_sites': 'Ajanta, Ellora, Mathura',
    },
    {
      'period': 'Mughal Empire',
      'timeline': '1526-1857 CE',
      'key_features': 'Indo-Islamic architecture, Miniature paintings',
      'major_sites': 'Agra, Delhi, Fatehpur Sikri',
    },
  ];

  void _startVirtualTour(String museumName) {
    setState(() {
      _isVirtualTourActive = true;
    });

    showDialog(
      context: context,
      builder: (context) => Dialog.fullscreen(
        child: _buildVirtualTourInterface(museumName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Text(
          'Virtual Museums',
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
            icon: const Icon(Icons.view_in_ar, color: Colors.white),
            onPressed: () => _showARFeatures(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(),
            const SizedBox(height: 24),
            _buildFeaturedMuseums(),
            const SizedBox(height: 24),
            _buildFeaturedArtifacts(),
            const SizedBox(height: 24),
            _buildHistoricalTimeline(),
            const SizedBox(height: 24),
            _buildInteractiveFeatures(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade400, Colors.purple.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
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
                child: const Icon(
                  Icons.museum,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Explore India\'s Heritage',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Virtual museum tours with 3D artifacts',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('15+', 'Museums'),
              _buildStatItem('5000+', 'Artifacts'),
              _buildStatItem('20+', 'Virtual Tours'),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3);
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedMuseums() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Featured Museums',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(_museums.length, (index) {
          final museum = _museums[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade100,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.account_balance,
                      size: 80,
                      color: Colors.indigo.shade300,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              museum['name'],
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star, size: 16, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(
                                  museum['rating'].toString(),
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            museum['location'],
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            'Est. ${museum['established']}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Highlights:',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: (museum['highlights'] as List<String>)
                            .map((highlight) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.indigo.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.indigo.shade200,
                            ),
                          ),
                          child: Text(
                            highlight,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.indigo.shade700,
                            ),
                          ),
                        ))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _startVirtualTour(museum['name']),
                              icon: const Icon(Icons.view_in_ar, size: 18),
                              label: const Text('Virtual Tour'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
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
                              onPressed: () => _showMuseumDetails(museum),
                              icon: const Icon(Icons.info_outline, size: 18),
                              label: const Text('Details'),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.indigo),
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
                ),
              ],
            ),
          ).animate().slideX(
            delay: Duration(milliseconds: index * 200),
            duration: const Duration(milliseconds: 600),
          );
        }),
      ],
    );
  }

  Widget _buildFeaturedArtifacts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Featured Artifacts',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 400,
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.85),
            onPageChanged: (index) {
              setState(() {
                _currentArtifactIndex = index;
              });
            },
            itemCount: _featuredArtifacts.length,
            itemBuilder: (context, index) {
              final artifact = _featuredArtifacts[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _buildArtifactCard(artifact),
              );
            },
          ),
        ),

      ],
    );
  }

  Widget _buildArtifactCard(Map<String, dynamic> artifact) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Center(
              child: Icon(
                Icons.extension,
                size: 100,
                color: Colors.amber.shade300,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    artifact['name'],
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${artifact['period']} • ${artifact['material']}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Text(
                      artifact['description'],
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                        height: 1.4,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (artifact['audio_guide'])
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.headphones, size: 12, color: Colors.green.shade700),
                              const SizedBox(width: 4),
                              Text(
                                'Audio',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(width: 8),
                      if (artifact['3d_model'])
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.view_in_ar, size: 12, color: Colors.blue.shade700),
                              const SizedBox(width: 4),
                              Text(
                                '3D',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _showArtifactDetails(artifact),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Explore'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoricalTimeline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Historical Timeline',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(_historicalPeriods.length, (index) {
          final period = _historicalPeriods[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  child: Column(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.indigo,
                          shape: BoxShape.circle,
                        ),
                      ),
                      if (index < _historicalPeriods.length - 1)
                        Container(
                          width: 2,
                          height: 80,
                          color: Colors.indigo.shade200,
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.indigo.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          period['period']!,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo.shade700,
                          ),
                        ),
                        Text(
                          period['timeline']!,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.indigo.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Key Features: ${period['key_features']!}',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        Text(
                          'Major Sites: ${period['major_sites']!}',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ).animate().slideX(
            delay: Duration(milliseconds: index * 200),
            duration: const Duration(milliseconds: 500),
          );
        }),
      ],
    );
  }

  Widget _buildInteractiveFeatures() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade50, Colors.pink.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Interactive Features',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildInteractiveFeature(
                'AR Experience',
                'View artifacts in augmented reality',
                Icons.view_in_ar,
                Colors.blue,
                    () => _showARFeatures(),
              ),
              _buildInteractiveFeature(
                'Audio Guides',
                'Listen to expert narrations',
                Icons.headphones,
                Colors.green,
                    () => _playAudioGuide(),
              ),
              _buildInteractiveFeature(
                'Virtual Reality',
                'Immersive museum walkthrough',
                Icons.vrpano,
                Colors.purple,
                    () => _startVRExperience(),
              ),
              _buildInteractiveFeature(
                'Quiz Challenge',
                'Test your historical knowledge',
                Icons.quiz,
                Colors.orange,
                    () => _startQuizChallenge(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveFeature(
      String title,
      String description,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVirtualTourInterface(String museumName) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Virtual Tour - $museumName',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            setState(() {
              _isVirtualTourActive = false;
            });
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          // 360° Tour Simulation
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Colors.indigo.shade900,
                  Colors.black,
                ],
                center: Alignment.center,
                radius: 1.0,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.threed_rotation,
                      size: 100,
                      color: Colors.white,
                    ),
                  )
                      .animate(onPlay: (controller) => controller.repeat())
                      .rotate(duration: 4000.ms),

                  const SizedBox(height: 30),

                  Text(
                    '360° Virtual Tour',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'Use your device to look around',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tour Controls
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTourControl(Icons.threed_rotation, 'Rotate'),
                  _buildTourControl(Icons.zoom_in, 'Zoom'),
                  _buildTourControl(Icons.info, 'Info'),
                  _buildTourControl(Icons.headphones, 'Audio'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTourControl(IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$label feature activated'),
            duration: const Duration(milliseconds: 1000),
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.indigo,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _showMuseumDetails(Map<String, dynamic> museum) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
                margin: const EdgeInsets.only(bottom: 20),
                alignment: Alignment.center,
              ),
              Text(
                museum['name'],
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(museum['location']),
                  const SizedBox(width: 16),
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text('Est. ${museum['established']}'),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Museum Information',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text('Total Artifacts: ${museum['artifacts']}'),
              Text('Virtual Tours Available: ${museum['virtual_tours']}'),
              Text('Visitor Rating: ${museum['rating']}/5.0'),
              const SizedBox(height: 16),
              Text(
                'Featured Collections:',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...((museum['highlights'] as List<String>).map((highlight) =>
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_right, size: 16),
                        const SizedBox(width: 4),
                        Text(highlight),
                      ],
                    ),
                  ),
              )).toList(),
            ],
          ),
        ),
      ),
    );
  }

  void _showArtifactDetails(Map<String, dynamic> artifact) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(artifact['name']),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Period: ${artifact['period']}'),
              Text('Material: ${artifact['material']}'),
              Text('Museum: ${artifact['museum']}'),
              const SizedBox(height: 16),
              Text(
                'Description:',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              Text(artifact['description']),
              const SizedBox(height: 12),
              Text(
                'Historical Significance:',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              Text(artifact['significance']),
            ],
          ),
        ),
        actions: [
          if (artifact['audio_guide'])
            TextButton.icon(
              onPressed: () => _playAudioGuide(),
              icon: const Icon(Icons.headphones),
              label: const Text('Audio Guide'),
            ),
          if (artifact['3d_model'])
            TextButton.icon(
              onPressed: () => _show3DModel(),
              icon: const Icon(Icons.view_in_ar),
              label: const Text('3D Model'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showARFeatures() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('AR features will be available soon! Point your camera at artifacts for immersive experience.'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _playAudioGuide() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎧 Audio guide is now playing... Learn about the history and significance of this artifact.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _show3DModel() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎮 3D model loaded! Rotate and zoom to explore the artifact in detail.'),
        backgroundColor: Colors.purple,
      ),
    );
  }

  void _startVRExperience() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🥽 VR mode activated! Experience immersive museum walkthrough.'),
        backgroundColor: Colors.purple,
      ),
    );
  }

  void _startQuizChallenge() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('History Quiz Challenge'),
        content: const Text('Test your knowledge about Indian heritage and artifacts!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Maybe Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🧠 Quiz started! Answer questions about Indian history and culture.'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Start Quiz'),
          ),
        ],
      ),
    );
  }
}
