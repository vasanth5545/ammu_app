// FILE: lib/admin_dashboard_screen.dart
// Intha file-la, GPS map-ah dynamic-ah maathiruken.

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart'; // Location-ah edukka indha package theva
import 'contact_storage_service.dart'; // Unga contacts-ah edukka idhu theva

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // Map-ah control panradhukku
  GoogleMapController? _mapController;
  // Location-ah edukka Future use panrom
  late Future<Position> _positionFuture;

  @override
  void initState() {
    super.initState();
    // Page open aana odane, location-ah edukka aarambikkurom
    _positionFuture = _determinePosition();
  }

  // User-oda current location-ah edukka pora function
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }

  // **** ITHA THAAN MAATHIRUKEN ****
  // Unga contacts-ah vechi, dynamic-ah markers create panra function
  Set<Marker> _createMarkers(Position adminPosition) {
    final contacts = ContactStorageService.instance.getContacts();
    final Set<Marker> markers = {};

    // **** ITHA THAAN PUTHUSA ADD PANIRUKEN ****
    // Admin-oda current position-ku oru marker add panrom
    markers.add(
      Marker(
        markerId: const MarkerId('admin_location'),
        position: LatLng(adminPosition.latitude, adminPosition.longitude),
        infoWindow: const InfoWindow(title: 'My Location (Admin)'),
        // Admin marker-ku oru aazhaana neela niram (deep blue color) kudukalam
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    );

    // Ovvoru contact-kum oru marker create panrom
    for (int i = 0; i < contacts.length; i++) {
      final contact = contacts[i];
      // Sample location-ah, admin location-ah suthi create panrom
      final lat = adminPosition.latitude + (i + 1) * 0.0030 * (i.isEven ? 1 : -1);
      final lng = adminPosition.longitude + (i + 1) * 0.0030 * (i.isEven ? -1 : 1);
      
      markers.add(
        Marker(
          markerId: MarkerId(contact['name']!),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(title: contact['name']),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        ),
      );
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final contacts = ContactStorageService.instance.getContacts();

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
              // FutureBuilder use panni, location kedaicha aprom map-ah kaatrom
              child: FutureBuilder<Position>(
                future: _positionFuture,
                builder: (context, snapshot) {
                  // Location load aagum bodhu, loading indicator kaatrom
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  // Edhavadhu error vandha, adha kaatrom
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  // Location correct-ah kedacha, map-ah create panrom
                  if (snapshot.hasData) {
                    final adminPosition = snapshot.data!;
                    return GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(adminPosition.latitude, adminPosition.longitude),
                        zoom: 13.0,
                      ),
                      onMapCreated: (controller) {
                        _mapController = controller;
                      },
                      markers: _createMarkers(adminPosition),
                    );
                  }
                  // Default-ah, loading text kaatrom
                  return const Center(child: Text('Loading Map...'));
                },
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Membership Revenue Section (Idhula endha maathamum illa)
          _buildMembershipCard(),
          const SizedBox(height: 24),

          // Incident Record Section
          _buildIncidentRecordCard(contacts),
        ],
      ),
      bottomNavigationBar: _buildCustomBottomNav(),
    );
  }

  // Inga irundhu keezha, vera endha maathamum illa. Ellam appadiye thaan irukku.
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
  
  Widget _buildRevenueRow(String title, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
        Text(amount, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildIncidentRecordCard(List<Map<String, String>> contacts) {
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
            if (contacts.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Text('No contacts added yet.'),
              )
            else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                return _buildIncidentRow(
                  'assets/police.png',
                  contact['name']!, 
                  '${index + 7}th Jan 2022',
                  '9:0${index}PM'
                );
              },
              separatorBuilder: (context, index) => const Divider(height: 16),
            ),
          ],
        ),
      ),
    );
  }

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
            const SizedBox(width: 40),
            _buildNavItem(Icons.history, 'History', false),
            _buildNavItem(Icons.person_outline, 'Profile', false),
          ],
        ),
      ),
    );
  }

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
