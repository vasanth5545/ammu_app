import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'gauge_painter.dart';

class HeatwaveIndicatorScreen extends StatefulWidget {
  const HeatwaveIndicatorScreen({super.key});

  @override
  State<HeatwaveIndicatorScreen> createState() =>
      _HeatwaveIndicatorScreenState();
}

class _HeatwaveIndicatorScreenState extends State<HeatwaveIndicatorScreen> {
  final String _apiKey = 'cc606abad3f4fe0fdf8ab6e4b3ab88a1';

  String _location = 'Loading...';
  String _appBarTitle = 'Heatwaves Indicator';
  bool _isLoading = true;
  double _heatRatio = 137; // Default value for display
  String _heatCondition = 'NOT GOOD'; // Default value for display
  List<FlSpot> _hourlyData = [];
  List<Map<String, dynamic>> _weeklyData = [];
  String _lastUpdated = '';

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  // --- Backend Logic (Weather and Location) ---
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _updateError('Location services are disabled.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _updateError('Location permissions are denied.');
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      _updateError('Location permissions are permanently denied.');
      return;
    } 

    try {
      Position position = await Geolocator.getCurrentPosition();
      _getWeatherForCoordinates(position.latitude, position.longitude);
    } catch (e) {
      _updateError('Failed to get location.');
    }
  }

  Future<void> _getWeatherForLocation(String locationName) async {
    setState(() { _isLoading = true; _location = "Searching..."; });
    try {
      List<Location> locations = await locationFromAddress(locationName);
      if (locations.isNotEmpty) {
        _getWeatherForCoordinates(locations.first.latitude, locations.first.longitude);
      } else {
        _updateError('Location not found.');
      }
    } catch (e) {
      _updateError('Failed to find location.');
    }
  }

  Future<void> _getWeatherForCoordinates(double lat, double lon) async {
    try {
      final weatherResponse = await http.get(Uri.parse('https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric'));
      final forecastResponse = await http.get(Uri.parse('https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$_apiKey&units=metric'));
      
      if (weatherResponse.statusCode == 200 && forecastResponse.statusCode == 200) {
        final weatherData = json.decode(weatherResponse.body);
        final forecastData = json.decode(forecastResponse.body);
        _processWeatherData(weatherData, forecastData);
      } else {
        _updateError('Failed to load weather data.');
      }
    } catch (e) {
      _updateError('An error occurred. Please check your connection.');
    }
  }

  void _processWeatherData(dynamic weatherData, dynamic forecastData) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(weatherData['coord']['lat'], weatherData['coord']['lon']);
      if (mounted) {
        setState(() {
          _appBarTitle = placemarks.isNotEmpty ? '${placemarks.first.locality}, ${placemarks.first.country}' : 'Unknown Location';
          
          double temp = weatherData['main']['temp'].toDouble();
          _heatRatio = temp * 4.5; // Example calculation for Heat Ratio

          if (_heatRatio < 100) { _heatCondition = 'GOOD'; } 
          else if (_heatRatio < 175) { _heatCondition = 'NOT GOOD'; }
          else { _heatCondition = 'DANGEROUS'; }

          _hourlyData = (forecastData['list'] as List).take(8).map((item) {
             final int index = (forecastData['list'] as List).indexOf(item);
             return FlSpot(index.toDouble(), item['main']['temp'].toDouble());
          }).toList();

          Map<int, Map<String, dynamic>> dailyData = {};
          for (var item in forecastData['list']) {
            final date = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
            if (!dailyData.containsKey(date.day)) {
              dailyData[date.day] = {
                'day': DateFormat('EEE').format(date),
                'temp': item['main']['temp'].toDouble(),
                'icon': _getWeatherIcon(item['weather'][0]['main'])
              };
            }
          }
          var sortedDays = dailyData.values.toList();
          _weeklyData = sortedDays.take(6).toList();

          _lastUpdated = 'Updated ${DateFormat.jm().format(DateTime.now())}';
          _isLoading = false;
        });
      }
    } catch (e) {
      _updateError("Error processing location data.");
    }
  }

  void _updateError(String message) {
    if (mounted) {
      setState(() {
        _appBarTitle = "Error";
        _location = message;
        _isLoading = false;
      });
    }
  }

  IconData _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear': return Icons.wb_sunny;
      case 'clouds': return Icons.cloud;
      case 'rain': return Icons.grain;
      default: return Icons.cloud_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: Text(_appBarTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0d47a1),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : RefreshIndicator(
            onRefresh: _determinePosition,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildSearchBar(),
                const SizedBox(height: 40),
                _buildHeatRatioDisplay(),
                const SizedBox(height: 60),
                _buildHourlyForecastCard(),
                const SizedBox(height: 20),
                _buildWeeklyForecastCard(),
              ],
            ),
          ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      onSubmitted: (value) {
        if (value.isNotEmpty) {
          _getWeatherForLocation(value);
        }
      },
      decoration: InputDecoration(
        hintText: 'Search for a location',
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
         focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0d47a1)),
        ),
      ),
    );
  }

  Widget _buildHeatRatioDisplay() {
  return Column(
    children: [
      SizedBox(
        height: 200,
        width: 180,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: _heatRatio),
          duration: const Duration(seconds: 2),
          builder: (context, animatedValue, _) {
            return CustomPaint(
              painter: GaugePainter(value: animatedValue),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 60),
                    Text(
                      animatedValue.toStringAsFixed(0),
                      style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _heatCondition,
                      style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: Colors.black54),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Heat Ratio',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    ],
  );
}

Widget _buildHourlyForecastCard() {

  return Card(
    color: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 55),
              const Text('Next hours',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(_lastUpdated, style: const TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 100,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 50,
                minY: 0,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  leftTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final now = DateTime.now();
                        final hour = now.add(Duration(hours: value.toInt() * 3));
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            DateFormat('ha').format(hour),
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12),
                          ),
                        );
                      },
                      interval: 1,
                    ),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: _hourlyData.asMap().entries.map((e) {
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value.y,
                        color: const Color(0xFF6EBE71),
                        width: 12,
                        borderRadius: const BorderRadius.all(Radius.circular(4)),
                      )
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildWeeklyForecastCard() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Weather', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('This week', style: TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _weeklyData.map((dayData) {
                  return Column(
                    children: [
                      Text(dayData['day'], style: const TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 84, 83, 83))),
                      const SizedBox(height: 8),
                      Icon(dayData['icon'], color: Colors.orangeAccent, size: 32,),
                      const SizedBox(height: 8),
                      Text('${dayData['temp'].toStringAsFixed(0)}°', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  );
              }).toList(),
            )
          ],
        ),
      ),
    );
  }
}