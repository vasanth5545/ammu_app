import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Puthiya location service-ah import panrom.
import 'location_service.dart';

// Intha service, app full-ah connected device-oda data-vaiyum,
// athoda connection status-aiyum handle pannum.
class DeviceService {
  DeviceService._privateConstructor();
  static final DeviceService _instance = DeviceService._privateConstructor();
  static DeviceService get instance => _instance;

  BluetoothDevice? connectedDevice;
  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;
  final ValueNotifier<bool> isConnectedNotifier = ValueNotifier(false);

  // Oru device-ah save pannum pothu, location tracking-ah start panrom.
  Future<void> saveDevice(BluetoothDevice device) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint("Cannot save device. User is not logged in.");
      return;
    }

    connectedDevice = device;
    
    _connectionStateSubscription?.cancel();
    _connectionStateSubscription = device.connectionState.listen((state) {
      final isCurrentlyConnected = (state == BluetoothConnectionState.connected);
      if (isConnectedNotifier.value != isCurrentlyConnected) {
        isConnectedNotifier.value = isCurrentlyConnected;
      }
      
      if (!isCurrentlyConnected) {
        LocationService.instance.stopTracking();
      }
      
      debugPrint('Device (${device.remoteId}) connection state changed: $state.');
    });

    isConnectedNotifier.value = true;
    debugPrint('Device Saved: ${device.platformName}');

    try {
      Position userPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      // Firebase-la location update panna, user ID, device ID, matrum user location-ah anuppurom.
      LocationService.instance.startTracking(
        userId: user.uid,
        deviceId: device.remoteId.toString(),
        userInitialLocation: LatLng(userPosition.latitude, userPosition.longitude)
      );
    } catch (e) {
      debugPrint("Could not get user location to start tracking: $e");
      // Fallback location
      LocationService.instance.startTracking(
        userId: user.uid,
        deviceId: device.remoteId.toString(),
        userInitialLocation: const LatLng(10.6673, 79.4445) // Example: Thanjavur
      );
    }
  }

  BluetoothDevice? getDevice() {
    return connectedDevice;
  }

  // Device-ah clear panum pothu, tracking-ah yum stop panrom.
  void clearDevice() {
    _connectionStateSubscription?.cancel();
    connectedDevice = null;
    isConnectedNotifier.value = false;
    LocationService.instance.stopTracking(); // Tracking-ah stop panrom.
    debugPrint('Saved device cleared and services stopped.');
  }
}
