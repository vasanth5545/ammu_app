// FILE: lib/payment_screen.dart
// Puthusa intha file-ah create pannunga

import 'package:flutter/material.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  // User entha payment method-ah select panraanga-nu track panra variable
  String _selectedPaymentMethod = 'Apple Pay';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Unga image-la irundha light blue background color
      backgroundColor: Colors.white, 
      appBar: AppBar(
        title: const Text('Payment'),
        // Dark blue color from your app's theme
        backgroundColor: const Color(0xFF0d47a1),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select the payment method you want to use.',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 20),
            
            // Ovvoru payment option-um inga irukku
            _buildPaymentOption(
              title: 'Paytm',
              imagePath: 'assets/paytm.png', // Intha image-ah assets folder-la add pannunga
              value: 'Paytm',
            ),
            const SizedBox(height: 15),
            _buildPaymentOption(
              title: 'Stripe',
              imagePath: 'assets/stripe.png', // Intha image-ah assets folder-la add pannunga
              value: 'Stripe',
            ),
            const SizedBox(height: 15),
            _buildPaymentOption(
              title: 'UPI',
              imagePath: 'assets/upi.png', // Intha image-ah assets folder-la add pannunga
              value: 'UPI',
            ),
            const SizedBox(height: 15),
            _buildPaymentOption(
              title: 'Apple Pay',
              imagePath: 'assets/applepay.png', // Intha image-ah assets folder-la add pannunga
              value: 'Apple Pay',
            ),
            const SizedBox(height: 15),
            _buildAddCardOption(
              title: 'Add New Card',
              value: 'Add New Card',
            ),
            const Spacer(), // Idhu "Proceed" button-ah keezha thallidum
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Inga payment process panra actual logic varum
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Proceeding with $_selectedPaymentMethod')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0d47a1),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text(
                  'Proceed',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Payment option-ah kaatura widget
  Widget _buildPaymentOption({required String title, required String imagePath, required String value}) {
    bool isSelected = _selectedPaymentMethod == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 5,
            )
          ],
        ),
        child: Row(
          children: [
            Image.asset(imagePath, height: 24, width: 24, errorBuilder: (c, o, s) => const Icon(Icons.payment, size: 24, color: Colors.grey)),
            const SizedBox(width: 15),
            Expanded(
              child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ),
            Radio<String>(
              value: value,
              groupValue: _selectedPaymentMethod,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedPaymentMethod = newValue!;
                });
              },
              activeColor: const Color(0xFF0d47a1),
            ),
          ],
        ),
      ),
    );
  }
  
  // "Add New Card" option-kaana widget
  Widget _buildAddCardOption({required String title, required String value}) {
     bool isSelected = _selectedPaymentMethod == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.grey[200],
           // Intha color-a maathalaa, light blue color use pannalaam
           // color: const Color(0xFF0d47a1),
          borderRadius: BorderRadius.circular(50),
           boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 5,
            )
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.add, size: 24, color: Colors.grey),
            const SizedBox(width: 15),
            Expanded(
              child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ),
            Radio<String>(
              value: value,
              groupValue: _selectedPaymentMethod,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedPaymentMethod = newValue!;
                });
              },
              activeColor: const Color(0xFF0d47a1),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================================

// FILE: lib/subscription_screen.dart
// Intha file-la irukka code-ah ippadi maathunga

