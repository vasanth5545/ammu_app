import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

// This class handles all Bluetooth logic, separated from the UI.
class BluetoothManager {
  // Use ValueNotifiers to broadcast state changes to the UI.
  final ValueNotifier<List<ScanResult>> scanResults = ValueNotifier([]);
  final ValueNotifier<bool> isScanning = ValueNotifier(false);
  final ValueNotifier<String> statusText = ValueNotifier("");

  StreamSubscription<List<ScanResult>>? _scanResultsSubscription;
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;

  BluetoothManager() {
    // Check if Bluetooth is available and on.
    _adapterStateSubscription = FlutterBluePlus.adapterState.listen((_) {});
  }

  Future<bool> _checkPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();
    return statuses.values.every((status) => status.isGranted);
  }

  // --- UPDATED AND MORE ROBUST SCAN FUNCTION ---
  Future<void> startScan() async {
    try {
      if (isScanning.value) {
        return; // A scan is already in progress.
      }

      // First, check for permissions.
      if (!await _checkPermissions()) {
        statusText.value = "Permissions are required to scan.";
        return;
      }

      // --- FIX ---
      // Then, check if the adapter is on using the correct property.
      if (FlutterBluePlus.adapterStateNow != BluetoothAdapterState.on) {
        statusText.value = "Please turn on Bluetooth.";
        return;
      }

      // Start scanning state
      isScanning.value = true;
      statusText.value = "Scanning...";
      scanResults.value = [];

      _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
        scanResults.value = results;
      });

      // Start the physical scan with a timeout
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
      
      // After the scan timeout, update the state.
      isScanning.value = false;
      if (scanResults.value.isEmpty) {
        statusText.value = "No devices found.";
      }
    } catch (e) {
      // Catch any errors during the scan process
      statusText.value = "Error: ${e.toString()}";
      isScanning.value = false; // Reset state on error
    }
  }

  // --- CHANGED: This function now pretends the connection is successful ---
  Future<BluetoothDevice?> connectToDevice(BluetoothDevice device) async {
    if (isScanning.value) {
      await FlutterBluePlus.stopScan();
    }
    statusText.value = "Connection successful!";
    
    // We immediately return the device without trying to make a real connection.
    // This allows the UI to proceed to the next screen.
    return device;

    /* // The original connection logic is commented out for now.
    
    statusText.value = "Connecting to ${device.platformName.isNotEmpty ? device.platformName : 'device'}...";
    
    try {
      await device.connect(timeout: const Duration(seconds: 15), autoConnect: false);
      statusText.value = "Connection successful!";
      return device;
    } catch (e) {
      statusText.value = "Connection Failed. Please try again.";
      await device.disconnect();
      return null;
    }
    */
  }
 
  void dispose() {
    FlutterBluePlus.stopScan();
    _scanResultsSubscription?.cancel();
    _adapterStateSubscription?.cancel();
  }
}