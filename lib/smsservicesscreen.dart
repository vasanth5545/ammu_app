import 'dart:async';
import 'homescreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'bluetooth_manager.dart'; 
import 'deviceservice.dart';

class SmsServicesScreen extends StatefulWidget {
  const SmsServicesScreen({super.key});

  @override
  State<SmsServicesScreen> createState() => _SmsServicesScreenState();
}

class _SmsServicesScreenState extends State<SmsServicesScreen>
    with TickerProviderStateMixin {
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
    _bluetoothManager.dispose();
    super.dispose();
  }

  Future<void> _handlePairingProcess() async {
    if (_isActionInProgress) return;

    setState(() {
      _isActionInProgress = true;
      _animationController.stop();
    });

    final BluetoothDevice? connectedDevice = await showDialog<BluetoothDevice>(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          ScanAndConnectDialog(bluetoothManager: _bluetoothManager),
    );

    if (connectedDevice != null && mounted) {
      await DeviceService.instance.saveDevice(connectedDevice);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (Route<dynamic> route) => false,
      );
    } else {
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
        title: const Text('Device Pairing'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            const Text(
              'Tap the button to pair your\nGPS Smartwatch or Chip',
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
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
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
    final double animationValue =
        (_animationController.value + initialRadius) % 1.0;
    final double radius = 70 + (100 * animationValue);
    final double finalOpacity = (1.0 - animationValue) * opacity;
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.blueGrey.withOpacity(finalOpacity * 0.15),
    );
  }
}


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
    widget.bluetoothManager.startScan();
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    final connectedDevice =
        await widget.bluetoothManager.connectToDevice(device);
    
    if (connectedDevice != null && mounted) {
      Navigator.of(context).pop(connectedDevice);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    height: 300,
                    child: isScanning
                        ? Center(
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                const CircularProgressIndicator(),
                                const SizedBox(height: 16),
                                Text(statusText)
                              ]))
                        : results.isEmpty
                            ? Center(child: Text(statusText))
                            : ListView.builder(
                                shrinkWrap: true,
                                itemCount: results.length,
                                itemBuilder: (context, index) {
                                  final result = results[index];
                                  
                                  // Device name illana, 'Unknown Device' nu kaatrom.
                                  final deviceName = result.device.platformName.isNotEmpty
                                    ? result.device.platformName
                                    : (result.advertisementData.localName.isNotEmpty 
                                        ? result.advertisementData.localName 
                                        : 'Unknown Device');

                                  return ListTile(
                                    title: Text(deviceName),
                                    subtitle: Text(result.device.remoteId.toString()),
                                    onTap: () =>
                                        _connectToDevice(result.device),
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
