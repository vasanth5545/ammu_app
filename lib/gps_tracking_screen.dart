import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'contact_storage_service.dart';
import 'addallcontactsscreen.dart';

class GpsTrackingScreen extends StatefulWidget {
  const GpsTrackingScreen({super.key});

  @override
  State<GpsTrackingScreen> createState() => _GpsTrackingScreenState();
}

class _GpsTrackingScreenState extends State<GpsTrackingScreen> {
  GoogleMapController? _mapController;
  late Future<Position> _positionFuture;
  String? selectedContactName;
  final Map<String, LatLng> contactLocations = {};

  @override
  void initState() {
    super.initState();
    _positionFuture = _determinePosition();
  }

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

  Set<Marker> _createMarkers(Position currentPosition) {
    final contacts = ContactStorageService.instance.getContacts();
    final Set<Marker> markers = {};

    markers.add(
      Marker(
        markerId: const MarkerId('current_user'),
        position: LatLng(currentPosition.latitude, currentPosition.longitude),
        infoWindow: const InfoWindow(title: 'My Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    );

    contactLocations.clear();
    for (int i = 0; i < contacts.length; i++) {
      final lat = currentPosition.latitude + (i + 1) * 0.0015;
      final lng = currentPosition.longitude + (i + 1) * 0.0015;
      final contactName = contacts[i]['name']!;
      contactLocations[contactName] = LatLng(lat, lng);

      markers.add(
        Marker(
          markerId: MarkerId(contactName),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(title: contactName),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
        ),
      );
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final contacts = ContactStorageService.instance.getContacts();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: contacts.map((contact) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FilterChip(
                          label: Text(contact['name']!),
                          selected: selectedContactName == contact['name'],
                          onSelected: (_) {
                            final name = contact['name']!;
                            final LatLng? location = contactLocations[name];
                            if (location != null && _mapController != null) {
                              _mapController!.animateCamera(
                                CameraUpdate.newCameraPosition(
                                  CameraPosition(target: location, zoom: 16),
                                ),
                              );
                            }
                            setState(() {
                              selectedContactName = name;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddAllContactsScreen()),
                  );
                  setState(() {});
                },
                icon: const Icon(Icons.add),
                label: const Text('Add'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
        // --- Map ippo FutureBuilder'kulla irukku ---
        Expanded(
          flex: 2, // Map'ku konjam adhigama edam kudukrom
          child: FutureBuilder<Position>(
            future: _positionFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Error: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              if (snapshot.hasData) {
                final currentPosition = snapshot.data!;
                return GoogleMap(
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                        currentPosition.latitude, currentPosition.longitude),
                    zoom: 14,
                  ),
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  markers: _createMarkers(currentPosition),
                );
              }
              return const Center(child: Text('Getting location...'));
            },
          ),
        ),
        // --- Intha "Recent Activity" list ippo thirumba vanthuruchu ---
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Recent Activity',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'See All',
                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1, // List'ku konjam kammiya edam kudukrom
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            children: [
              ListTile(
                leading: const CircleAvatar(backgroundColor: Colors.purple),
                title: const Text('Tuition Center'),
                subtitle: const Text('20 minutes ago'),
                trailing: Text(contacts.isNotEmpty ? contacts[0]['name']! : ''),
              ),
              ListTile(
                leading: const CircleAvatar(backgroundColor: Colors.brown),
                title: const Text('Library'),
                subtitle: const Text('3 Hours ago'),
                trailing: Text(contacts.length > 1 ? contacts[1]['name']! : ''),
              ),
              ListTile(
                leading: const CircleAvatar(backgroundColor: Colors.grey),
                title: const Text('Home'),
                subtitle: const Text('6 Hours ago'),
                trailing: Text(contacts.length > 2 ? contacts[2]['name']! : ''),
              ),
            ],
          ),
        )
      ],
    );
  }
}
