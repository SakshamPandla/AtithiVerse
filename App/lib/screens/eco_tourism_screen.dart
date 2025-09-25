import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/app_theme.dart';

class EcoTourismScreen extends StatefulWidget {
  const EcoTourismScreen({super.key});

  @override
  State<EcoTourismScreen> createState() => _EcoTourismScreenState();
}

class _EcoTourismScreenState extends State<EcoTourismScreen> {
  double _totalCarbonFootprint = 0.0;
  int _treesPlanted = 0;
  double _moneyDonated = 0.0;

  final List<Map<String, dynamic>> _transportOptions = [
    {
      'name': 'Train',
      'co2_per_km': 0.04, // kg CO2 per km
      'icon': Icons.train,
      'color': Colors.green,
      'eco_score': 95,
    },
    {
      'name': 'Bus',
      'co2_per_km': 0.08,
      'icon': Icons.directions_bus,
      'color': Colors.lightGreen,
      'eco_score': 85,
    },
    {
      'name': 'Car (Shared)',
      'co2_per_km': 0.12,
      'icon': Icons.car_rental,
      'color': Colors.orange,
      'eco_score': 65,
    },
    {
      'name': 'Flight (Domestic)',
      'co2_per_km': 0.25,
      'icon': Icons.flight,
      'color': Colors.red,
      'eco_score': 30,
    },
  ];

  final List<Map<String, dynamic>> _ecoFriendlyStays = [
    {
      'name': 'Green Valley Resort, Kerala',
      'location': 'Munnar, Kerala',
      'rating': 4.8,
      'eco_score': 95,
      'features': ['Solar Power', 'Rainwater Harvesting', 'Organic Garden'],
      'price': 3500,
      'image': 'assets/images/eco_resort1.jpg',
    },
    {
      'name': 'Himalayan Eco Lodge',
      'location': 'Dharamshala, HP',
      'rating': 4.6,
      'eco_score': 90,
      'features': ['Zero Waste', 'Local Materials', 'Community Support'],
      'price': 2800,
      'image': 'assets/images/eco_resort2.jpg',
    },
    {
      'name': 'Desert Sustainable Camp',
      'location': 'Jaisalmer, Rajasthan',
      'rating': 4.7,
      'eco_score': 88,
      'features': ['Wind Power', 'Water Conservation', 'Local Crafts'],
      'price': 4200,
      'image': 'assets/images/eco_resort3.jpg',
    },
  ];

  void _calculateCarbonFootprint(String transport, double distance) {
    final option = _transportOptions.firstWhere((t) => t['name'] == transport);
    final footprint = distance * option['co2_per_km'];

    setState(() {
      _totalCarbonFootprint += footprint;
    });

    _showCarbonFootprintDialog(footprint, transport, distance);
  }

  void _showCarbonFootprintDialog(double footprint, String transport, double distance) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.eco, color: Colors.green),
            const SizedBox(width: 8),
            const Text('Carbon Footprint'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${footprint.toStringAsFixed(2)} kg CO₂',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            Text('for ${distance.toStringAsFixed(0)} km by $transport'),
            const SizedBox(height: 16),
            const Text('Offset your carbon footprint by:'),
            const SizedBox(height: 8),
            _buildOffsetOption('Plant Trees', Icons.park, () => _plantTrees(footprint)),
            _buildOffsetOption('Donate to Conservation', Icons.favorite, () => _donateForEnvironment(footprint)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildOffsetOption(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  void _plantTrees(double co2Amount) {
    // 1 tree absorbs ~22 kg CO2 per year
    int treesToPlant = (co2Amount / 22).ceil();
    setState(() {
      _treesPlanted += treesToPlant;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Great! You\'ve planted $treesToPlant trees to offset your carbon footprint!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _donateForEnvironment(double co2Amount) {
    // ₹100 per kg CO2 for environmental projects
    double donationAmount = co2Amount * 100;
    setState(() {
      _moneyDonated += donationAmount;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Thank you for donating ₹${donationAmount.toStringAsFixed(0)} for environmental conservation!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          'Eco-Tourism Tracker',
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
            _buildEcoScoreCard(),
            const SizedBox(height: 24),
            _buildCarbonFootprintCalculator(),
            const SizedBox(height: 24),
            _buildTransportComparison(),
            const SizedBox(height: 24),
            _buildEcoFriendlyStays(),
            const SizedBox(height: 24),
            _buildConservationProjects(),
          ],
        ),
      ),
    );
  }

  Widget _buildEcoScoreCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.teal.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Your Eco Impact',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildEcoStat(
                '${_totalCarbonFootprint.toStringAsFixed(1)} kg',
                'CO₂ Footprint',
                Icons.cloud,
              ),
              _buildEcoStat(
                '$_treesPlanted',
                'Trees Planted',
                Icons.park,
              ),
              _buildEcoStat(
                '₹${_moneyDonated.toStringAsFixed(0)}',
                'Donated',
                Icons.favorite,
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3);
  }

  Widget _buildEcoStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildCarbonFootprintCalculator() {
    final TextEditingController distanceController = TextEditingController();
    String selectedTransport = 'Train';

    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Carbon Footprint Calculator',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: selectedTransport,
            decoration: const InputDecoration(
              labelText: 'Select Transport',
              border: OutlineInputBorder(),
            ),
            items: _transportOptions.map((transport) {
              return DropdownMenuItem<String>(
                value: transport['name'],
                child: Row(
                  children: [
                    Icon(transport['icon'], color: transport['color']),
                    const SizedBox(width: 8),
                    Text(transport['name']),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              selectedTransport = value!;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: distanceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Distance (km)',
              border: OutlineInputBorder(),
              suffixText: 'km',
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                final distance = double.tryParse(distanceController.text);
                if (distance != null && distance > 0) {
                  _calculateCarbonFootprint(selectedTransport, distance);
                }
              },
              icon: const Icon(Icons.calculate),
              label: const Text('Calculate Footprint'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransportComparison() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transport Eco-Comparison',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(_transportOptions.length, (index) {
          final transport = _transportOptions[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: transport['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: transport['color'].withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: transport['color'].withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    transport['icon'],
                    color: transport['color'],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transport['name'],
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: transport['color'],
                        ),
                      ),
                      Text(
                        '${transport['co2_per_km']} kg CO₂/km',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: transport['color'],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Eco: ${transport['eco_score']}/100',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
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

  Widget _buildEcoFriendlyStays() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Eco-Friendly Accommodations',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _ecoFriendlyStays.length,
            itemBuilder: (context, index) {
              final stay = _ecoFriendlyStays[index];
              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: 16),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.eco,
                          size: 60,
                          color: Colors.green.shade400,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stay['name'],
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            stay['location'],
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Eco: ${stay['eco_score']}/100',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '₹${stay['price']}/night',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: (stay['features'] as List<String>)
                                .take(2)
                                .map((feature) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.green.shade200,
                                ),
                              ),
                              child: Text(
                                feature,
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildConservationProjects() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.green.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Support Conservation Projects',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildConservationProject(
            'Western Ghats Reforestation',
            'Plant native trees in biodiversity hotspot',
            Icons.forest,
            Colors.green,
            'Goal: ₹50,000 | Raised: ₹32,000',
            0.64,
          ),
          const SizedBox(height: 12),
          _buildConservationProject(
            'Ganga River Cleanup',
            'Clean and restore river ecosystems',
            Icons.water,
            Colors.blue,
            'Goal: ₹75,000 | Raised: ₹41,000',
            0.55,
          ),
          const SizedBox(height: 12),
          _buildConservationProject(
            'Wildlife Corridor Protection',
            'Protect elephant migration routes',
            Icons.pets,
            Colors.orange,
            'Goal: ₹1,00,000 | Raised: ₹78,000',
            0.78,
          ),
        ],
      ),
    );
  }

  Widget _buildConservationProject(
      String title,
      String description,
      IconData icon,
      Color color,
      String progress,
      double progressValue,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      description,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => _donateToProject(title),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text('Donate'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progressValue,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          const SizedBox(height: 4),
          Text(
            progress,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _donateToProject(String projectName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Donate to $projectName'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choose donation amount:'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDonationButton('₹100', 100),
                _buildDonationButton('₹500', 500),
                _buildDonationButton('₹1000', 1000),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationButton(String label, double amount) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _moneyDonated += amount;
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Thank you for donating $label for conservation!'),
            backgroundColor: Colors.green,
          ),
        );
      },
      child: Text(label),
    );
  }
}
