import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

// Intha class, ella Bluetooth logic-aiyum handle pannum.
class BluetoothManager {
  final ValueNotifier<List<ScanResult>> scanResults = ValueNotifier([]);
  final ValueNotifier<bool> isScanning = ValueNotifier(false);
  final ValueNotifier<String> statusText = ValueNotifier("");

  StreamSubscription<List<ScanResult>>? _scanResultsSubscription;
  StreamSubscription<bool>? _isScanningSubscription;
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;

  BluetoothManager() {
    _isScanningSubscription = FlutterBluePlus.isScanning.listen((scanning) {
      isScanning.value = scanning;
      if (!scanning && scanResults.value.isEmpty) {
        statusText.value = "No BLE devices found. Make sure the device is discoverable.";
      }
    });
  }

  // App-ku thevaiyaana permissions-ah check pannum.
  Future<bool> _checkPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();
    return statuses.values.every((status) => status.isGranted);
  }

  // Devices-ah scan panna aarambikkum.
  Future<void> startScan() async {
    if (!await _checkPermissions()) {
      statusText.value = "Bluetooth & Location permissions are required.";
      return;
    }

    // adapterState stream-ah listen panni, Bluetooth on aana odane scan panrom.
    _adapterStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      if (state == BluetoothAdapterState.on) {
        _performScan();
      } else {
        FlutterBluePlus.stopScan();
        scanResults.value = [];
        statusText.value = "Please turn on Bluetooth.";
      }
    });
  }
  
  // Ithu thaan ippo unmaiyaana scan panna pora function.
  Future<void> _performScan() async {
    if (isScanning.value) return;

    try {
      scanResults.value = [];
      statusText.value = "Scanning for BLE devices...";
      
      _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
          // Ovvoru device-um list-la oru thadava mattum kaatura maari logic.
          var uniqueResults = <DeviceIdentifier, ScanResult>{};
          for (var r in scanResults.value) {
             uniqueResults[r.device.remoteId] = r;
          }
          for (var r in results) {
            uniqueResults[r.device.remoteId] = r;
          }
          scanResults.value = uniqueResults.values.toList();
      });

      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));

    } catch (e) {
      debugPrint("Error starting scan: $e");
      statusText.value = "Could not start scan.";
    }
  }


  // FIXED: Connection-ah stable aakkurathukkaaga, MTU request-ah disable panni,
  // 'discoverServices' function-ah call panrom.
  Future<BluetoothDevice?> connectToDevice(BluetoothDevice device) async {
    if (isScanning.value) {
      await FlutterBluePlus.stopScan();
    }
    statusText.value = "Connecting to ${device.platformName.isNotEmpty ? device.platformName : device.remoteId}...";
    
    try {
      // `mtu: null` enru sethathunaala, app ippo antha MTU request-ah anuppaathu.
      await device.connect(timeout: const Duration(seconds: 15), autoConnect: false, mtu: null);
      
      // Ithu romba mukkiyamaana step. Ithu connection-ah alive-a vechukkum.
      await device.discoverServices();
      
      statusText.value = "Connection Successful!";
      return device;
    } catch (e) {
      debugPrint("Connection Error: $e");
      statusText.value = "Failed to connect. Please try again.";
      await device.disconnect();
      return null;
    }
  }
 
  // Intha manager-ah use panni mudichathum, ella streams-ayum close pannum.
  void dispose() {
    FlutterBluePlus.stopScan();
    _scanResultsSubscription?.cancel();
    _isScanningSubscription?.cancel();
    _adapterStateSubscription?.cancel();
  }
}
