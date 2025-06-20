import 'package:ammu_app/homescreen.dart';

import 'smsservicesscreen.dart';
import 'package:flutter/material.dart';

class BluetoothScreen extends StatelessWidget {
  const BluetoothScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Hide the debug banner
      home: Scaffold(
        backgroundColor: Colors.white, // The primary white background of the screen
        body: Column(
          children: [
            // Top section with blue background and wave
            Expanded(
              flex: 2, // Gives this section more vertical space
              child: Stack(
                children: [
                  // Blue background with clipped wave
                  Positioned.fill(
                    child: ClipPath(
                      clipper: BottomWaveClipper(),
                      child: Container(
                        color: const Color(0xFF00224C), // The dark blue color
                      ),
                    ),
                  ),
                  // Content (Back arrow, title, Bluetooth icon)
                  Column(
                    children: [
                      // Top spacing to push content down
                      const SizedBox(height: 50),
                      // Header row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: const Icon(
                                Icons.arrow_back_ios,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const Expanded(
                              child: Text(
                                'Add your device',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            // SizedBox to balance the row if needed, or remove if not necessary
                            const SizedBox(width: 20),
                          ],
                        ),
                      ),
                      // Spacing below the title
                      const SizedBox(height: 100),
                      // Bluetooth icon
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.5),
                              blurRadius:
                                  15, // Increased blur for a softer glow
                              spreadRadius:
                                  5, // Increased spread for more prominence
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.bluetooth,
                          color: Color(0xFF00224C), // Icon color
                          size: 60,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Bottom section with text and button
            Expanded(
              flex: 1, // Gives this section less vertical space than the top
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Center content vertically
                children: [
                  const Text(
                    'Turn on Bluetooth connection settings\n'
                    'in your smart watch and make sure your\n'
                    'Device is close to your phone',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                  const SizedBox(
                    height: 40,
                  ), // Spacing between text and button
                  ElevatedButton(
                    onPressed: () {

                     Navigator.push(context,MaterialPageRoute(builder: (context) => SmsServicesScreen()),);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                        0xFF00224C,
                      ), // Button background color
                      minimumSize: const Size(
                        double.infinity,
                        50,
                      ), // Full width button
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          10,
                        ), // Rounded corners
                      ),
                    ),
                    child: const Text(
                      'Pair Device',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20), // Spacing below the button
                  // The very bottom dark blue bar
                  const SizedBox(height: 20), // Spacing below the button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00224C),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Go to Home',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
           ),
          ],
        ),
        bottomNavigationBar: Container(
          color:  Colors.white, // The dark blue color for the bottom bar
          height: 50,
        ),
      ),
    );
  }
}

class BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    // Start from the top-left corner
    path.lineTo(0, 0);
    // Line to the top-right corner
    path.lineTo(size.width, 0);

    // Start of the wave from the top-right going down
    // This defines the starting height of the wave on the right side
    path.lineTo(
      size.width,
      size.height * 0.7,
    ); // Adjusted to make the wave start higher

    // First curve: dips towards the center (like the right hump of the wave)
    path.quadraticBezierTo(
      size.width * 0.8, // Control point X
      size.height * 0.85, // Control point Y (pulls curve down)
      size.width * 0.5, // End point X
      size.height * 0.75, // End point Y (center dip height)
    );

    // Second curve: rises up to the left side (like the left hump of the wave)
    path.quadraticBezierTo(
      size.width * 0.2, // Control point X
      size.height * 0.65, // Control point Y (pulls curve up)
      0, // End point X (left edge)
      size.height *
          0.75, // End point Y (matches right side height for a flat top of the wave)
    );

    // Close the path to form the complete shape
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper)=>false;
}