import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/material.dart';
// This is a simple service to hold the connected device's data in memory.
// It uses a Singleton pattern to ensure there's only one instance of it.
class DeviceService {
  // Private constructor
  DeviceService._privateConstructor();

  // The single instance of the service
  static final DeviceService _instance = DeviceService._privateConstructor();

  // Getter to access the single instance
  static DeviceService get instance => _instance;

  // This will hold the currently connected Bluetooth device
  BluetoothDevice? connectedDevice;

  // Method to save a device
  void saveDevice(BluetoothDevice device) {
    connectedDevice = device;
    print('Device Saved: ${device.name} (${device.id})');
  }

  // Method to get the saved device
  BluetoothDevice? getDevice() {
    return connectedDevice;
  }

  // Method to clear the saved device
  void clearDevice() {
    connectedDevice = null;
    print('Saved device cleared.');
  }
}
