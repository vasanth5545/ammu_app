import 'package:flutter/material.dart';

class HealthFollowUpScreen extends StatelessWidget {
  const HealthFollowUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Follow Up'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_active),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Health Alerts',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // MODIFIED: Unga puthiya images-ah inga use panrom.
                Expanded(child: _buildAlertCard(context, 'Parents Health Alert', 'assets/parents1.jpg')),
                const SizedBox(width: 16),
                Expanded(child: _buildAlertCard(context, 'Staff Health Alert', 'assets/staff0.jpg')),
              ],
            ),
            const SizedBox(height: 32),
            _buildDietSheetForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard(BuildContext context, String title, String imagePath) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
            child: Image.asset(imagePath, height: 120, width: double.infinity, fit: BoxFit.cover, errorBuilder: (c,o,s) => const SizedBox(height: 120, child: Icon(Icons.local_hospital, size: 50, color: Colors.grey))),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildDietSheetForm() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Diet Sheet for Hostellers',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextFormField(decoration: const InputDecoration(labelText: 'Student name', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextFormField(decoration: const InputDecoration(labelText: 'Roll No', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextFormField(decoration: const InputDecoration(labelText: 'Hostel Room No', border: OutlineInputBorder())),
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: const Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text('Select Your Image here'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0d47a1),
                  padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                ),
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
