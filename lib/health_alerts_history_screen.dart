// FILE: lib/health_alerts_history_screen.dart
// Puthusa create panna vendiya file

import 'package:flutter/material.dart';

class HealthAlertsHistoryScreen extends StatelessWidget {
  const HealthAlertsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Health Follow Up'),
        backgroundColor: const Color(0xFF0d47a1),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sample alert items
            _buildAlertItem(
              imagePath: 'assets/girl.png',
              title: 'Student Health Alerts',
              location: 'South Street, Chennai',
              time: 'Today, 11.00 AM',
            ),
            _buildAlertItem(
              imagePath: 'assets/library2.png',
              title: 'Parents Health Alert',
              location: 'West Street, Chennai',
              time: 'Today, 9.00 AM',
            ),
            _buildAlertItem(
              imagePath: 'assets/staff2.png',
              title: 'Staff Health Alert',
              location: 'South Street, Chennai',
              time: 'Yesterday, 10.00 AM',
            ),
            const SizedBox(height: 30),
            // Diet Sheet Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'Diet Sheet',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[100],
                ),
                child: IconButton(
                  onPressed: () {
                    // Diet sheet upload panra logic inga varum
                  },
                  icon: Icon(
                    Icons.upload_file,
                    size: 80,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Ovvoru alert item-ayum create panra helper widget
  Widget _buildAlertItem({required String imagePath, required String title, required String location, required String time}) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: AssetImage(imagePath),
              onBackgroundImageError: (e, s) => const Icon(Icons.person, size: 28),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(location, style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ],
              ),
            ),
            Text(time, style: TextStyle(color: Colors.grey[700], fontSize: 12)),
          ],
        ),
      ),
    );
  }
}


// ======================================================================

