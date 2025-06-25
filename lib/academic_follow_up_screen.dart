// FILE: lib/academic_follow_up_screen.dart
// Intha file-la, performance indicator widget-ah unga photo-la irukka maari maathiruken.

import 'package:flutter/material.dart';

class AcademicFollowUpScreen extends StatelessWidget {
  const AcademicFollowUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic Follow Up'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Alerts',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildGridItem(context, 'Marks', 'assets/marks.png'),
                _buildGridItem(context, 'Assignments', 'assets/assignments.png'),
                _buildGridItem(context, 'Events', 'assets/events.png'),
                _buildGridItem(context, 'Others', 'assets/others.png'),
              ],
            ),
            const SizedBox(height: 32),
            _buildPerformanceIndicator(),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0d47a1),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('View Overall Student Performance',style: TextStyle(color: Colors.white),),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, String title, String imagePath) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imagePath, height: 80, errorBuilder: (c, o, s) => const Icon(Icons.school, size: 80, color: Colors.grey)),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // **** ITHA THAAN MAATHIRUKEN ****
  Widget _buildPerformanceIndicator() {
    return Center(
      child: SizedBox(
        width: 200, 
        height: 200,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: const CircularProgressIndicator(
                value: 0.6, // Example value 60%
                strokeWidth: 15,
                backgroundColor: Color(0xFFE0E0E0), // Light grey background
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0d47a1)), // Dark blue progress
              ),
            ),
            // Center-la irukka image
            Image.asset(
              'assets/computer.png', 
              height: 130, // Unga photo-la irukka maari, image size-ah konjam perusaakiruken
              errorBuilder: (c,o,s) => const SizedBox()
            ), 
            // Positioned use panni, text-ah correct-ah vechiruken
            Positioned(
              top: 20,
              right: 15,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                ),
                child: const Text(
                  '60/100',
                  style: TextStyle(
                    fontSize: 14, 
                    fontWeight: FontWeight.bold,
                    color: Colors.black87
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
