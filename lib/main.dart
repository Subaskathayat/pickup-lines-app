import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'services/line_of_day_service.dart';
import 'services/theme_service.dart';
import 'services/premium_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize services
    await LineOfDayService.instance.initialize();
    await ThemeService().initialize();
    await PremiumService().initialize();
  } catch (e) {
    // Continue even if service initialization fails
    debugPrint('Service initialization failed: $e');
  }

  runApp(const FlirtyTextApp());
}

class FlirtyTextApp extends StatefulWidget {
  const FlirtyTextApp({super.key});

  @override
  State<FlirtyTextApp> createState() => _FlirtyTextAppState();
}

class _FlirtyTextAppState extends State<FlirtyTextApp> {
  final ThemeService _themeService = ThemeService();

  @override
  void initState() {
    super.initState();
    _themeService.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    _themeService.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {
      // Rebuild the app with the new theme
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pickup Lines',
      theme: _themeService.currentThemeData.themeData,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
