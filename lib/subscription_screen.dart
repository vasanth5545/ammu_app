import 'homescreen.dart';
import 'package:ammu_app/payment_screen.dart'; // Puthusa import pannunga
import 'package:flutter/material.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  String _selectedPlan = 'School Plan';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Subscription Plan'),
        elevation: 0,
                // Maathapattadhu (Corrected Code)
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_outlined),
            onPressed: () {
              // Inga `pushReplacement`-ku badhila `pop` use pannunga
              Navigator.pop(context);
            },
          ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeaderCard(),
            _buildChoosePlanSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15.0),
              topRight: Radius.circular(15.0),
            ),
            child: Image.asset(
              'assets/sub.png',
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (c, o, s) => Container(
                height: 180,
                color: Colors.pink[100],
                child: const Center(child: Icon(Icons.photo, size: 50, color: Colors.grey)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'School Plan',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildFeatureListItem('Limit upto track 1000 students'),
                const SizedBox(height: 8),
                _buildFeatureListItem('Past month location records are shown'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureListItem(String text) {
    return Row(
      children: [
        Icon(Icons.check_circle, color: Colors.grey[400], size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }

  Widget _buildChoosePlanSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose Plan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildPlanOption(
            title: 'Parents Plan',
            price: '₹199 / per month',
            value: 'Parents Plan',
            showBuyNow: true,
          ),
          const SizedBox(height: 12),
          _buildPlanOption(
            title: 'School Plan',
            price: '₹999 / per month',
            value: 'School Plan',
            showBuyNow: true,
          ),
          const SizedBox(height: 12),
          _buildPlanOption(
            title: 'University Plan',
            price: '₹3999 / per month',
            value: 'University Plan',
            showBuyNow: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPlanOption({required String title, required String price, required String value, bool showBuyNow = false}) {
    final bool isSelected = _selectedPlan == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlan = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[50] : Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isSelected ? const Color(0xFF0d47a1) : Colors.grey.shade300,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF0d47a1) : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Color(0xFF0d47a1))
                  : null,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(price, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              ],
            ),
            const Spacer(),
            if (isSelected && showBuyNow)
              ElevatedButton(
                onPressed: () {
                  // Inga thaan navigation logic-ah maathiruken
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PaymentScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0d47a1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Buy Now', style: TextStyle(color: Colors.white)),
              ),
          ],
        ),
      ),
    );
  }
}
