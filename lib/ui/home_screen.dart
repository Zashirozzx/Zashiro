
import 'package:flutter/material.dart';
import 'package:usage_stats/usage_stats.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isUsageStatsPermissionGranted = false;
  bool _isOverlayPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    bool? usageStatsGranted = await UsageStats.checkUsagePermission();
    bool? overlayGranted = await FlutterOverlayWindow.isPermissionGranted();
    setState(() {
      _isUsageStatsPermissionGranted = usageStatsGranted ?? false;
      _isOverlayPermissionGranted = overlayGranted ?? false;
    });
  }

  void _requestUsageStatsPermission() {
    UsageStats.grantUsagePermission();
    // User is sent to system settings. We will need to re-check when they return.
    // A more robust solution could use WidgetsBindingObserver to detect app lifecycle changes.
  }

  void _requestOverlayPermission() {
    FlutterOverlayWindow.requestPermission();
    // User is sent to system settings. 
  }

  Widget _buildPermissionRequestUI(String message, String buttonText, VoidCallback onPressed) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: onPressed,
          child: Text(buttonText),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ziru FPS Counter - Setup'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: !_isUsageStatsPermissionGranted
              ? _buildPermissionRequestUI(
                  'For the app to identify which game is running, it needs access to your usage data.',
                  'Grant Usage Stats Permission',
                  _requestUsageStatsPermission,
                )
              : !_isOverlayPermissionGranted
                  ? _buildPermissionRequestUI(
                      'To display the FPS counter over your games, the overlay permission is required.',
                      'Grant Overlay Permission',
                      _requestOverlayPermission,
                    )
                  : const Text(
                      'All permissions granted! Ready to start the service.',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
        ),
      ),
    );
  }
}
