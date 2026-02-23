import 'package:flutter/material.dart';
import 'login.dart';
import 'welcome.dart'; // 1. ADD THIS IMPORT

void main() {
  runApp(const SahyogApp());
}

// GLOBAL STATE: This allows the Parent's "Approve" click to update the Student's screen
class AppState {
  static String leaveStatus = "No Pending Requests";
}

class SahyogApp extends StatefulWidget {
  const SahyogApp({super.key});

  @override
  State<SahyogApp> createState() => _SahyogAppState();
}

class _SahyogAppState extends State<SahyogApp> {
  String currentRole = 'Boy';

  // Dynamic Theme: Changes the app color based on who logs in
  ThemeData _buildTheme(String role) {
    Color primaryColor;
    switch (role) {
      case 'Girl': primaryColor = Colors.pink; break;
      case 'Parent': primaryColor = Colors.green; break;
      case 'Warden': primaryColor = Colors.deepPurple; break;
      default: primaryColor = const Color(0xFF0D47A1); // Dark Blue for Boys
    }
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
      useMaterial3: true,
      appBarTheme: AppBarTheme(backgroundColor: primaryColor, foregroundColor: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sahyog HMS',
      theme: _buildTheme(currentRole),
      // 2. CHANGE home to WelcomePage
      home: const WelcomePage(), 
    );
  }
}

// Global Animation Function: Links all pages with a smooth slide transition
Route createAnimatedRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}