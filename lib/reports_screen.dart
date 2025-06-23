import 'package:ammu_app/addallcontactsscreen.dart';
import 'package:flutter/foundation.dart'; // 'compute' function-kaaga import panrom
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'dart:math';

// Import the local contact storage service to ensure data consistency
import 'contact_storage_service.dart';

// --- Data Model for a Report Entry ---
// This enum helps categorize different types of reports.
enum ReportType { school, library, park, home }

// This class defines the structure for a single report item.
class ReportEntry {
  final String studentName;
  final String title;
  final String location;
  final DateTime timestamp; // Using DateTime for better sorting and formatting
  final String imagePath;
  final ReportType type;
  final Map<String, dynamic> details;

  ReportEntry({
    required this.studentName,
    required this.title,
    required this.location,
    required this.timestamp,
    required this.imagePath,
    required this.type,
    required this.details,
  });

  // Helper to format the date part (e.g., 'Today', 'Yesterday', 'Dec 30, 2022')
  String get displayDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final checkDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (checkDate == today) {
      return 'Today';
    } else if (checkDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM d, yyyy').format(timestamp);
    }
  }

  // Helper to format the time part (e.g., '11:00 AM')
  String get displayTime {
    return DateFormat('h:mm a').format(timestamp);
  }
}

/// FIXED: Intha function-ah thaniya top-level-la vechurukkom.
/// 'compute' function use panrathukku, ithu oru top-level function-ah irukkanum.
/// Ithu reports-ah background-la generate pannum, so app hang aagathu.
List<ReportEntry> _generateReportsForContactsInBackground(
  List<Map<String, String>> contacts,
) {
  List<ReportEntry> reports = [];
  final now = DateTime.now();
  final random = Random();

  if (contacts.isEmpty) {
    return reports;
  }

  final activities = [
    {
      'title': 'VM School',
      'location': 'South Street, Chennai',
      'imagePath': 'assets/VMschool.png',
      'type': ReportType.school,
    },
    {
      'title': 'Library',
      'location': 'West Street, Chennai',
      'imagePath': 'assets/library2.png',
      'type': ReportType.library,
    },
    {
      'title': 'Park',
      'location': 'North Street, Chennai',
      'imagePath': 'assets/park.png',
      'type': ReportType.park,
    },
    {
      'title': 'Home',
      'location': 'East Street, Chennai',
      'imagePath': 'assets/home2.png',
      'type': ReportType.home,
    },
  ];

  for (var contact in contacts) {
    final studentName = contact['name'] ?? 'Contact';
    for (int i = 0; i < (random.nextInt(2) + 2); i++) {
      final activity = activities[random.nextInt(activities.length)];
      final timestamp = now.subtract(
        Duration(days: random.nextInt(5), hours: random.nextInt(24)),
      );

      reports.add(
        ReportEntry(
          studentName: studentName,
          title: activity['title'] as String,
          location: activity['location'] as String,
          timestamp: timestamp,
          imagePath: activity['imagePath'] as String,
          type: activity['type'] as ReportType,
          details: {
            'note': 'Details for ${activity['title']} for $studentName',
          },
        ),
      );
    }
  }

  reports.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  return reports;
}

// --- Main Reports Page Widget ---
// This is the main stateful widget for the reports screen.
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ReportEntry> _allReports = [];
  List<ReportEntry> _filteredReports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReportsFromLocalService();
    _searchController.addListener(_filterReports);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterReports);
    _searchController.dispose();
    super.dispose();
  }

  /// FIXED: Loads reports using 'compute' to prevent blocking the main UI thread.
  Future<void> _loadReportsFromLocalService() async {
    setState(() => _isLoading = true);

    final contacts = ContactStorageService.instance.getContacts();

    // 'compute' function reports generation-ah background thread-ku maathidum.
    final newReports = await compute(
      _generateReportsForContactsInBackground,
      contacts,
    );

    if (mounted) {
      setState(() {
        _allReports = newReports;
        _filteredReports = newReports;
        _isLoading = false; // Stop loading indicator
      });
    }
  }

  /// Filters the reports based on the text in the search bar.
  void _filterReports() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredReports = _allReports;
      } else {
        _filteredReports = _allReports
            .where((report) => report.studentName.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  /// Shows a dialog with detailed information about the selected report.
  void _showReportDetails(BuildContext context, ReportEntry report) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(report.title),
          content: _buildDetailContent(report),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  /// Builds the content for the details dialog based on the report type.
  Widget _buildDetailContent(ReportEntry report) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Student: ${report.studentName}'),
          const Divider(),
          Text('Location: ${report.location}'),
          Text('Time: ${report.displayDate}, ${report.displayTime}'),
          const SizedBox(height: 8),
          Text(
            'Details: ${report.details['note'] ?? 'No additional details.'}',
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Background color from the screenshot
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name...', // Updated hint text
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 20,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: const BorderSide(color: Color(0xFF0d47a1)),
                ),
              ),
            ),
          ),
          // Conditional content based on loading state and data availability
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _allReports.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'No reports found.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Please add contacts from the Home screen to see their reports.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const AddAllContactsScreen(),
                                ),
                              );
                              setState(() {});
                            },
                            icon: const Icon(Icons.person_add),
                            label: const Text('Add Contacts'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : _filteredReports.isEmpty && _searchController.text.isNotEmpty
                ? Center(
                    child: Text(
                      'No reports found for "${_searchController.text}".',
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadReportsFromLocalService,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: _filteredReports.length,
                      itemBuilder: (context, index) {
                        final report = _filteredReports[index];
                        // The main card widget for each report item
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12.0),
                          elevation: 2,
                          shadowColor: Colors.grey.withOpacity(0.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12.0),
                            onTap: () => _showReportDetails(context, report),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  // Image on the left
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.asset(
                                      report.imagePath,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      // Error builder in case the asset is not found
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(
                                                Icons.image_not_supported,
                                                size: 60,
                                                color: Colors.grey,
                                              ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Title and Location in the middle
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Show student name on top of the title
                                        Text(
                                          report.studentName,
                                          style: TextStyle(
                                            color: Colors.blue[800],
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          report.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.location_on,
                                              size: 14,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(width: 4),
                                            // Use Flexible to prevent text overflow
                                            Flexible(
                                              child: Text(
                                                report.location,
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Date and Time on the right
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        report.displayDate,
                                        style: TextStyle(
                                          color: Colors.grey[800],
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        report.displayTime,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}