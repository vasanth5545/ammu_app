import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  // Map-kaana oru sample initial location
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(10.7905, 78.7047), // Mannargudi-oda center
    zoom: 13.0,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundImage: NetworkImage('https://placehold.co/100x100/EFEFEF/AAAAAA&text=User'),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Map Section
          SizedBox(
            height: 250,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: GoogleMap(
                initialCameraPosition: _initialPosition,
                markers: _createMarkers(),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Membership Revenue Section
          _buildMembershipCard(),
          const SizedBox(height: 24),

          // Incident Record Section
          _buildIncidentRecordCard(),
        ],
      ),
      // Unga design-la irukkura maathiriye oru custom bottom navigation bar
      bottomNavigationBar: _buildCustomBottomNav(),
    );
  }

  // Map-la kaatura sample markers
  Set<Marker> _createMarkers() {
    return {
      const Marker(
        markerId: MarkerId('Jyoti'),
        position: LatLng(10.795, 78.709),
        infoWindow: InfoWindow(title: 'Jyoti'),
        icon: BitmapDescriptor.defaultMarker,
      ),
      Marker(
        markerId: const MarkerId('Sara'),
        position: const LatLng(10.785, 78.712),
        infoWindow: const InfoWindow(title: 'Sara'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
      Marker(
        markerId: const MarkerId('Rose'),
        position: const LatLng(10.788, 78.700),
        infoWindow: const InfoWindow(title: 'Rose'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    };
  }

  // Membership card-kaana widget
  Widget _buildMembershipCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Membership Revenue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: 'Monthly',
                    items: <String>['Monthly', 'Yearly'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: const TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                    onChanged: (_) {},
                    style: const TextStyle(color: Colors.white),
                    selectedItemBuilder: (BuildContext context) {
                      return <String>['Monthly', 'Yearly'].map((String value) {
                        return Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0d47a1),
                              borderRadius: BorderRadius.circular(20)
                            ),
                            child: Text(value, style: const TextStyle(color: Colors.white))
                        );
                      }).toList();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildRevenueRow('Total Earning', '₹90,987'),
            const Divider(height: 24),
            _buildRevenueRow('Total Spent', '₹40,706'),
          ],
        ),
      ),
    );
  }
  
  // Revenue row-kaana helper widget
  Widget _buildRevenueRow(String title, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
        Text(amount, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // Incident Record card-kaana widget
  Widget _buildIncidentRecordCard() {
    return Card(
       elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Incident Record', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(onPressed: (){}, child: Row(children: const [Text('View all'), Icon(Icons.arrow_forward_ios, size: 14,)]))
              ],
            ),
            const SizedBox(height: 8),
            _buildIncidentRow('assets/police.png', 'Khatija Begum', '7th Jan 2022', '9:00PM'),
            const Divider(height: 16),
             _buildIncidentRow('assets/police.png', 'Rose Saran', '17th Feb 2022', '8:00PM'),
          ],
        ),
      ),
    );
  }

  // Incident row-kaana helper widget
  Widget _buildIncidentRow(String imagePath, String name, String date, String time) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(imagePath, width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (c,o,s) => const Icon(Icons.image, size: 50, color: Colors.grey)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(date, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(time, style: TextStyle(color: Colors.grey[700], fontSize: 12)),
            const SizedBox(height: 4),
            OutlinedButton(onPressed: (){}, child: const Text('View'), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24)))
          ],
        ),
      ],
    );
  }

  // Custom bottom navigation bar-kaana widget
  Widget _buildCustomBottomNav() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _buildNavItem(Icons.home, 'Home', true),
            _buildNavItem(Icons.analytics_outlined, 'Stats', false),
            const SizedBox(width: 40), // The notch
            _buildNavItem(Icons.history, 'History', false),
            _buildNavItem(Icons.person_outline, 'Profile', false),
          ],
        ),
      ),
    );
  }

  // Navigation item-kaana helper widget
  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: isActive ? const Color(0xFF0d47a1) : Colors.grey),
        Text(label, style: TextStyle(color: isActive ? const Color(0xFF0d47a1) : Colors.grey, fontSize: 12)),
      ],
    );
  }
}
