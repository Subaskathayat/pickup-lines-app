import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'services/line_of_day_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the Line of Day service
  await LineOfDayService.instance.initialize();

  runApp(const FlirtyTextApp());
}

class FlirtyTextApp extends StatelessWidget {
  const FlirtyTextApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pickup Lines',
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFFFABAB), // Coral Pink
          secondary: Color(0xFFB0E0E6), // Powder Blue
          surface: Color(0xFFFFF0F5), // Blush White
          onPrimary: Color(0xFF4A4A4A), // Dark Gray
          onSecondary: Color(0xFF4A4A4A), // Dark Gray
          onSurface: Color(0xFF4A4A4A), // Dark Gray
        ),
        scaffoldBackgroundColor: const Color(0xFFFFF0F5), // Blush White
        useMaterial3: true,
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF4A4A4A),
          elevation: 0,
        ),
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFABAB), // Coral Pink
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
