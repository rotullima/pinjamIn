import 'package:flutter/material.dart';
import 'loginscreen.dart';
import 'package:pinjamln/screen/dashboard_screen.dart';
import 'package:pinjamln/services/auth/user_session.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    // Add a small delay for better UX
    await Future.delayed(const Duration(milliseconds: 1500));
    
    // Try to restore existing session
    final hasSession = await UserSession.restoreSession();
    
    if (!mounted) return;
    
    if (hasSession) {
      // User is already logged in, go to dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } else {
      // No valid session, go to login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              width: 250,
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(
              color: Color(0xFF2D3748),
            ),
            const SizedBox(height: 20),
            const Text(
              'Memuat...',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF4A5568),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
