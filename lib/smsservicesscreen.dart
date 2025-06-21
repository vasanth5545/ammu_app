import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'bluetooth_manager.dart'; // Import the new manager
import 'deviceservice.dart';
import 'homescreen.dart';

class SmsServicesScreen extends StatefulWidget {
  const SmsServicesScreen({super.key});

  @override
  State<SmsServicesScreen> createState() => _SmsServicesScreenState();
}

class _SmsServicesScreenState extends State<SmsServicesScreen> with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final BluetoothManager _bluetoothManager;
  bool _isActionInProgress = false;

  @override
  void initState() {
    super.initState();
    _bluetoothManager = BluetoothManager();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _bluetoothManager.dispose(); // Clean up the manager
    super.dispose();
  }

  Future<void> _handlePairingProcess() async {
    if (_isActionInProgress) return;

    setState(() {
      _isActionInProgress = true;
      _animationController.stop();
    });

    // The dialog now takes the manager as a parameter
    final BluetoothDevice? connectedDevice = await showDialog<BluetoothDevice>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ScanAndConnectDialog(bluetoothManager: _bluetoothManager),
    );

    if (connectedDevice != null && mounted) {
      DeviceService.instance.saveDevice(connectedDevice);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (Route<dynamic> route) => false,
      );
    } else {
      // Reset UI if the dialog is closed without connecting
      if (mounted) {
        setState(() {
          _isActionInProgress = false;
          _animationController.repeat();
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('SMS Add on Services'),
        backgroundColor: const Color(0xFF0d47a1),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            const Text(
              'Tap on pair Button to pair\nGPS Smart Watch / Chip',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, height: 1.5, color: Colors.black54),
            ),
            const Spacer(flex: 1),
            GestureDetector(
              onTap: _handlePairingProcess,
              child: SizedBox(
                width: 200,
                height: 200,
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        if (!_isActionInProgress) ...[
                          _buildRipple(1, 0.2),
                          _buildRipple(0.75, 0.4),
                          _buildRipple(0.5, 0.7),
                          _buildRipple(0.25, 1.0),
                        ],
                        child!,
                      ],
                    );
                  },
                  child: CircleAvatar(
                    radius: 65,
                    backgroundColor: const Color(0xFF0d47a1),
                    child: _isActionInProgress
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const Text(
                            'Pair',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ),
            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildRipple(double initialRadius, double opacity) {
    final double animationValue = (_animationController.value + initialRadius) % 1.0;
    final double radius = 70 + (100 * animationValue);
    final double finalOpacity = (1.0 - animationValue) * opacity;
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.blueGrey.withOpacity(finalOpacity * 0.15),
    );
  }
}

// The dialog is now much simpler and only handles UI
class ScanAndConnectDialog extends StatefulWidget {
  final BluetoothManager bluetoothManager;
  const ScanAndConnectDialog({required this.bluetoothManager, super.key});

  @override
  State<ScanAndConnectDialog> createState() => _ScanAndConnectDialogState();
}

class _ScanAndConnectDialogState extends State<ScanAndConnectDialog> {

  @override
  void initState() {
    super.initState();
    // Tell the manager to start scanning when the dialog opens
    widget.bluetoothManager.startScan();
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    final connectedDevice = await widget.bluetoothManager.connectToDevice(device);
    if (connectedDevice != null && mounted) {
      Navigator.of(context).pop(connectedDevice);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to the manager's state to rebuild the UI
    return ValueListenableBuilder<List<ScanResult>>(
      valueListenable: widget.bluetoothManager.scanResults,
      builder: (context, results, child) {
        return ValueListenableBuilder<bool>(
          valueListenable: widget.bluetoothManager.isScanning,
          builder: (context, isScanning, child) {
            return ValueListenableBuilder<String>(
              valueListenable: widget.bluetoothManager.statusText,
              builder: (context, statusText, child) {
                return AlertDialog(
                  title: const Text("Select a Device"),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: (isScanning && results.isEmpty) || statusText.contains("Connecting")
                        ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const CircularProgressIndicator(), const SizedBox(height: 16), Text(statusText)]))
                        : results.isEmpty
                            ? Center(child: Text(statusText))
                            : ListView.builder(
                                shrinkWrap: true,
                                itemCount: results.length,
                                itemBuilder: (context, index) {
                                  final result = results[index];
                                  return ListTile(
                                    title: Text(result.device.platformName.isNotEmpty ? result.device.platformName : 'Unknown Device'),
                                    subtitle: Text(result.device.remoteId.toString()),
                                    onTap: () => _connectToDevice(result.device),
                                  );
                                },
                              ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Close'),
                      onPressed: () => Navigator.of(context).pop(null),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}