// FILE: lib/homescreen.dart
// Intha file-la, automatic keyboard prachanai-ah sari panniruken.

import 'package:ammu_app/addallcontactsscreen.dart';
import 'package:ammu_app/subscription_screen.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'heatwaveindicatorscreen.dart';
import 'gps_tracking_screen.dart';
import 'reports_screen.dart';
import 'signup.dart'; 
import 'deviceservice.dart';

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
      const ReportsScreen(),
    ];
  }

  String _getTitleForIndex(int index) {
    switch (index) {
      case 0:
        return 'Home';
      case 1:
        return 'GPS Tracking';
      case 2:
        return 'Reports';
      default:
        return 'AMMU';
    }
  }

  // **** ITHA THAAN MAATHIRUKEN ****
  @override
  Widget build(BuildContext context) {
    // Unga build method-ah ippo oru GestureDetector kulla potturuken.
    return GestureDetector(
      onTap: () {
        // Intha line thaan keyboard-ah close pannum.
        // Screen-la enga tap pannalum, keyboard focus-ah eduthu vittudum.
        // Adhunaala, vera icon-ah click pannalum, keyboard close aagidum.
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_getTitleForIndex(_currentIndex)),
          actions: [
             ValueListenableBuilder<bool>(
              valueListenable: DeviceService.instance.isConnectedNotifier,
              builder: (context, isConnected, child) {
                return IconButton(
                  icon: Icon(
                    isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                    color: isConnected ? Colors.white : Colors.grey[400],
                  ),
                  onPressed: () {
                    final message = isConnected
                        ? 'Smartwatch connected.'
                        : 'No smartwatch connected. Please pair a device.';
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
                    );
                  },
                  tooltip: isConnected ? 'Connected' : 'Disconnected',
                );
              },
            ),
            IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SubscriptionScreen()),
                  );
                },
                icon: const Icon(Icons.card_membership))
          ],
        ),
        drawer: const AppDrawer(),
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
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
            BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart), label: 'Reports'),
          ],
        ),
      ),
    );
  }
}

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
    )..repeat();
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
                      'Once you tap the button, an alert message will be sent to emergency contacts.',
                ),
              ],
            ),
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 30),
          Center(
            child: GestureDetector(
              onTap: () {
              },
              child: SizedBox(
                width: 220,
                height: 220,
                child: AnimatedBuilder(
                  animation: _sosController,
                  builder: (context, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        _buildRipple(
                            controllerValue:
                                (_sosController.value + 0.0) % 1.0),
                        _buildRipple(
                            controllerValue:
                                (_sosController.value + 0.25) % 1.0),
                        _buildRipple(
                            controllerValue:
                                (_sosController.value + 0.5) % 1.0),
                        _buildRipple(
                            controllerValue:
                                (_sosController.value + 0.75) % 1.0),
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
                    child: const CircleAvatar(
                      radius: 70,
                      backgroundColor: Color(0xFFFF4747),
                      child: Text(
                        'SOS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
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
                        builder: (context) => const AddAllContactsScreen()));
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
             onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const HeatwaveIndicatorScreen()),
                  );
                  setState(() {});
                },
            child: _buildIndicatorCard(
                title: 'Heatwave', icon: Icons.wb_sunny),
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
        color: const Color(0xFFFF4744).withOpacity(opacity.clamp(0.0, 1.0)),
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

  Widget _buildIndicatorCard({required String title, required IconData icon}) {
    return Container(
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(width: 10),
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    void showComingSoon(String featureName) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$featureName module coming soon...')),
      );
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFF0d47a1),
            ),
            child: Text(
              'AMMU Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),

          // 👩‍🍼 Mother & Baby Care Section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text("Mother & Baby Care", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.watch),
            title: const Text('Smartwatch Pairing'),
            onTap: () => Navigator.pushNamed(context, '/bluetooth_pairing'),
          ),
          ListTile(
            leading: const Icon(Icons.health_and_safety),
            title: const Text('Health Monitoring'),
            onTap: () => Navigator.pushNamed(context, '/health_follow_up'),
          ),

          const Divider(),

          // 🎓 Student Management Section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text("Student Monitoring", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.assignment),
            title: const Text('Assignments'),
            onTap: () => Navigator.pushNamed(context, '/academic_follow_up'),
          ),
          ListTile(
            leading: const Icon(Icons.grade),
            title: const Text('Marks & Reports'),
            onTap: () => Navigator.pushNamed(context, '/student_marks'),
          ),

          const Divider(),

          // 🛡️ Safety & Emergency
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text("Safety & Emergency", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.gps_fixed),
            title: const Text('Live GPS Tracking'),
            onTap: () => Navigator.pushNamed(context, '/gps_tracking'),
          ),
          ListTile(
            leading: const Icon(Icons.warning),
            title: const Text('SOS Reports'),
            onTap: () => Navigator.pushNamed(context, '/reports'),
          ),

          const Divider(),

          // 📊 Government & Extras
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text("Information & Support", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.account_balance),
            title: const Text('Government Schemes'),
            onTap: () => Navigator.pushNamed(context, '/government_schemes'),
          ),
          ListTile(
            leading: const Icon(Icons.feedback),
            title: const Text('Send Feedback'),
            onTap: () => Navigator.pushNamed(context, '/feedback'),
          ),

          const Divider(),

          // 🔒 Logout
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              Navigator.pop(context);
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const SignUpScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
