// Puthusa intha file-ah create pannunga: lib/staff_health_alert_screen.dart

import 'package:flutter/material.dart';

class StaffHealthAlertScreen extends StatelessWidget {
  const StaffHealthAlertScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Health Alert'),
        backgroundColor: const Color(0xFF0d47a1),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        // Unga parent alert screen-la irundha maariye UI inga create panniruken
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter the Valid Staff Health Details:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
            TextFormField(decoration: const InputDecoration(labelText: 'Staff Name', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextFormField(decoration: const InputDecoration(labelText: 'Staff ID', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextFormField(decoration: const InputDecoration(labelText: 'Department', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Health details / Medication',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Inga data-va save panra logic varum
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0d47a1),
                  padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('Submit', style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
