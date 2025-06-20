import 'package:flutter/material.dart';
import 'dart:ui';
import 'addallcontactsscreen.dart';
import 'heatwaveindicatorscreen.dart';
import 'gps_tracking_screen.dart';
import 'reports_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeTabPage(onNavigateToReports: () {
        setState(() {
          _currentIndex = 2;
        });
      }),
      const GpsTrackingScreen(),
      const ReportsApp(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentIndex == 0
            ? 'Home'
            : _currentIndex == 1
                ? 'GPS Tracking'
                : 'Reports'),
        backgroundColor: const Color(0xFF0d47a1),
        elevation: 0,
        actions: [
          if (_currentIndex == 1)
            IconButton(
              icon: const Icon(Icons.handshake_outlined, color: Colors.white),
              tooltip: 'Plan',
              onPressed: () {},
            )
          else
            IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert))
        ],
      ),
      drawer: const Drawer(),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF0d47a1),
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.gps_fixed), label: 'GPS'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Reports'),
        ],
      ),
    );
  }
}

// ✅ MISSING CLASS FIXED
class HomeTabPage extends StatefulWidget {
  final VoidCallback onNavigateToReports;

  const HomeTabPage({
    required this.onNavigateToReports,
    super.key,
  });

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage>
    with TickerProviderStateMixin {
  late final AnimationController _sosController;

  @override
  void initState() {
    super.initState();
    _sosController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // 💡 Ripple start after UI ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sosController.repeat();
    });
  }

  @override
  void dispose() {
    _sosController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text.rich(
            TextSpan(
              children: [
                TextSpan(
                    text: 'Note: ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(
                  text:
                      'Once you tap the button, alert message will send to contacts, police, Staff in charge and camera will turn ON.',
                ),
              ],
            ),
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 30),
          Center(
            child: GestureDetector(
              onTap: () {/* SOS Logic Here */},
              child: SizedBox(
                width: 220,
                height: 220,
                child: AnimatedBuilder(
                  animation: _sosController,
                  builder: (context, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        _buildRipple(controllerValue: (_sosController.value + 0.0) % 1.0),
                        _buildRipple(controllerValue: (_sosController.value + 0.25) % 1.0),
                        _buildRipple(controllerValue: (_sosController.value + 0.5) % 1.0),
                        _buildRipple(controllerValue: (_sosController.value + 0.75) % 1.0),
                        child!,
                      ],
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF4744).withOpacity(0.4),
                          blurRadius: 25,
                          spreadRadius: 15,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 70,
                      backgroundColor: const Color(0xFFFF4747),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ImageFiltered(
                            imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                            child: const Text(
                              'SOS',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Text(
                            'SOS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'Tap the SOS button for Help',
              style: TextStyle(fontSize: 18, color: Colors.black87),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddAllContactsScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0d47a1),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              child: const Text('Add all Contacts',
                  style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Nearby Helpline',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              TextButton(
                  onPressed: () {},
                  child: const Text('Tap to call',
                      style: TextStyle(color: Color(0xFF0d47a1)))),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildHelplineIcon('assets/police.png', 'Police'),
              _buildHelplineIcon('assets/family.png', 'Family'),
              _buildHelplineIcon('assets/108.png', '108'),
              _buildHelplineIcon('assets/staff.png', 'Staff'),
              _buildHelplineIcon('assets/ngo.png', 'NGO'),
            ],
          ),
          const SizedBox(height: 30),
          const Text('Indicators',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const HeatwaveIndicatorScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF9D423), Color(0xFFFF4E50)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ]),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wb_sunny, color: Colors.white, size: 28),
                  SizedBox(width: 10),
                  Text('Heatwave',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: widget.onNavigateToReports,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D47A1), Color(0xFF42A5F5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ]),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart, color: Colors.white, size: 28),
                  SizedBox(width: 10),
                  Text('View All Reports',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRipple({required double controllerValue}) {
    final double radius = 70 + (150 * controllerValue);
    final double opacity = (1.0 - controllerValue) * 0.3;

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFFF4747).withOpacity(opacity.clamp(0.0, 1.0)),
      ),
    );
  }

  Widget _buildHelplineIcon(String imagePath, String label) {
    return Column(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: const Color(0xFFE3F2FD),
          backgroundImage: AssetImage(imagePath),
        ),
        const SizedBox(height: 5),
        Text(label),
      ],
    );
  }
}
