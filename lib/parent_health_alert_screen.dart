import 'package:flutter/material.dart';

class ParentHealthAlertScreen extends StatelessWidget {
  const ParentHealthAlertScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parent Health Alerts'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter the Valid Medication Details:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
            TextFormField(decoration: const InputDecoration(labelText: 'Student name', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextFormField(decoration: const InputDecoration(labelText: 'Roll No', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextFormField(decoration: const InputDecoration(labelText: 'Class', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextFormField(decoration: const InputDecoration(labelText: 'Parent name', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextFormField(decoration: const InputDecoration(labelText: 'Staff Name', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Medication details',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0d47a1),
                  padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('Submit'),
              ),
            )
          ],
        ),
      ),
    );
  }
}

