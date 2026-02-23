import 'dart:async';
import 'package:flutter/material.dart';
import 'login.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  // Set to true so Pink/Girls Hostel appears FIRST
  bool isPink = true; 
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // Toggles the theme every 3 seconds
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          isPink = !isPink;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Elegant Gradients
    final List<Color> blueGradient = [const Color(0xFF0D47A1), const Color(0xFF1976D2), const Color(0xFF42A5F5)];
    final List<Color> pinkGradient = [const Color(0xFF880E4F), const Color(0xFFC2185B), const Color(0xFFF06292)];
    
    final Color themeColor = isPink ? const Color(0xFFC2185B) : const Color(0xFF0D47A1);
    final String hostelTitle = isPink ? "GIRLS HOSTEL" : "BOYS HOSTEL";
    final String logoAsset = isPink ? 'assets/images/g_logo.png' : 'assets/images/b_logo.png';

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isPink ? pinkGradient : blueGradient,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: -50,
                right: -50,
                child: CircleAvatar(radius: 100, backgroundColor: Colors.white.withOpacity(0.1)),
              ),
              
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // BIG LOGO SECTION
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 800),
                      switchInCurve: Curves.elasticOut,
                      switchOutCurve: Curves.elasticIn,
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return ScaleTransition(
                          scale: animation, 
                          child: FadeTransition(opacity: animation, child: child)
                        );
                      },
                      child: Container(
                        key: ValueKey<String>(logoAsset),
                        height: 200, // Slightly reduced to save space
                        width: 200,  
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 30,
                              spreadRadius: 5,
                              offset: const Offset(0, 15),
                            )
                          ],
                          border: Border.all(color: Colors.white, width: 8),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            logoAsset,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.home_work_rounded,
                              size: 100,
                              color: themeColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 40), // Reduced spacing
                    
                    // APP NAME
                    const Text(
                      "SAHYOG",
                      style: TextStyle(
                        fontSize: 54, // Slightly smaller font
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 8,
                        shadows: [
                          Shadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))
                        ]
                      ),
                    ),
                    
                    // HOSTEL TYPE TEXT
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: Text(
                        hostelTitle,
                        key: ValueKey<String>(hostelTitle),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.9),
                          letterSpacing: 6,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20), // Reduced spacing

                    // TAGLINE
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      child: Opacity(
                        opacity: 0.8,
                        child: Text(
                          "Safety, Comfort and Community like home.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white.withOpacity(0.8),
                            fontStyle: FontStyle.italic,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // REPOSITIONED & LOWER HEIGHT BUTTON
              Positioned(
                bottom: 30, // Lowered closer to bottom
                left: 50,
                right: 50,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        _createRoute(
                          LoginPage(
                            onRoleChange: (role) => debugPrint("Selected: $role"),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: themeColor,
                      padding: const EdgeInsets.symmetric(vertical: 15), // Reduced height
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "GET STARTED",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 1200),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var curve = Curves.easeInOutQuart;
        var tween = Tween(begin: const Offset(0.0, 1.0), end: Offset.zero)
            .chain(CurveTween(curve: curve));
        
        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }
}