import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Intha class, oru unmaiyaana smartwatch-oda location-ah simulate panni,
/// antha data-va Firebase-la save pannum. Ithu thaan unga diagram-la irukkura "Transmitter".
class SmartwatchTransmitter {
  final String userId;
  final String deviceId;
  final LatLng initialPosition;

  Timer? _timer;
  bool _isTransmitting = false;

  SmartwatchTransmitter({
    required this.userId,
    required this.deviceId,
    required this.initialPosition,
  });

  /// Simulation-ah start pannum.
  void start() {
    if (_isTransmitting) return; // Already running
    _isTransmitting = true;
    
    LatLng currentPosition = initialPosition;
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      // Ovvoru 5 second-kum, location-ah konjam random-a maathi, Firebase-la update panrom.
      final random = Random();
      currentPosition = LatLng(
        currentPosition.latitude + (random.nextDouble() - 0.5) * 0.0008,
        currentPosition.longitude + (random.nextDouble() - 0.5) * 0.0008,
      );
      
      // Location-ah Firebase Firestore-la save panrom.
      FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('tracked_devices')
          .doc(deviceId)
          .set({
            'name': 'Paired Smartwatch', // Device name-ah yum save panrom.
            'last_location': GeoPoint(currentPosition.latitude, currentPosition.longitude),
            'last_updated': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true)); // `merge:true` vecha, palaya data azhiyathu.
    });
  }

  /// Simulation-ah stop pannum.
  void stop() {
    _timer?.cancel();
    _isTransmitting = false;
  }
}

/// Intha service, app full-ah tracking logic-ah handle pannum.
class LocationService {
  LocationService._privateConstructor();
  static final LocationService _instance = LocationService._privateConstructor();
  static LocationService get instance => _instance;

  SmartwatchTransmitter? _transmitter;

  /// Oru puthu device-kaana tracking-ah start pannum.
  void startTracking({
    required String userId, 
    required String deviceId, 
    required LatLng userInitialLocation
  }) {
    // Palaya tracking iruntha, atha stop panrom.
    stopTracking();
    
    final watchInitialPosition = LatLng(
      userInitialLocation.latitude + 0.005,
      userInitialLocation.longitude + 0.005,
    );

    _transmitter = SmartwatchTransmitter(
      userId: userId, 
      deviceId: deviceId, 
      initialPosition: watchInitialPosition
    );
    
    _transmitter!.start();
  }

  /// Tracking-ah stop pannum.
  void stopTracking() {
    _transmitter?.stop();
    _transmitter = null;
  }
  
  /// Intha stream, Firebase-la irunthu smartwatch-oda location-ah live-ah eduthu kodukkum.
  /// Ithu thaan unga diagram-la irukkura "Receiver".
  Stream<DocumentSnapshot> getSmartwatchLocationStream({
    required String userId,
    required String deviceId,
  }) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('tracked_devices')
        .doc(deviceId)
        .snapshots();
  }
}
