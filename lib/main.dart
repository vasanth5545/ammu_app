import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:device_preview/device_preview.dart';
import 'dart:async';

// All pages are imported for route registration
import 'signup.dart';
import 'login.dart';
import 'homescreen.dart';
import 'bluetoothscreen.dart';
import 'smsservicesscreen.dart';
import 'addallcontactsscreen.dart';
import 'reports_screen.dart';

// Puthu pages-ah import panrom
import 'academic_follow_up_screen.dart';
import 'health_follow_up_screen.dart';
import 'parent_health_alert_screen.dart';
import 'admin_dashboard_screen.dart'; // ADDED: Admin Dashboard screen-ah import panrom.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(DevicePreview(builder: (context) => const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      title: 'AMMU App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0d47a1),
          foregroundColor: Colors.white,
        )
      ),
      debugShowCheckedModeBanner: false,
      
      // Named routes use panni, navigation-ah organize panrom.
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/bluetooth': (context) => const BluetoothScreen(),
        '/sms_services': (context) => const SmsServicesScreen(),
        '/add_contacts': (context) => const AddAllContactsScreen(),
        '/reports': (context) => const ReportsScreen(), 
        '/academic_follow_up': (context) => const AcademicFollowUpScreen(),
        '/health_follow_up': (context) => const HealthFollowUpScreen(),
        '/parent_health_alert': (context) => const ParentHealthAlertScreen(),
        '/admin_dashboard': (context) => const AdminDashboardScreen(), 
      },
    );
  }
}

// SplashScreen எந்த மாற்றமும் இல்லை (No changes)
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
    );

    _controller.forward();

    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0d47a1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ScaleTransition(
              scale: _scaleAnimation,
              child: CircleAvatar(
                radius: 60.0,
                backgroundColor: Colors.white,
                child: ClipOval(
                  child: Image.asset(
                    'assets/girl.png',
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24.0),
            FadeTransition(
              opacity: _fadeAnimation,
              child: const Column(
                children: [
                  Text(
                    'AMMU',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 48.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Move with Mother Care',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
