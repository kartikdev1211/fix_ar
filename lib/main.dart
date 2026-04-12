import 'package:fix_ar/constants/constant.dart';
import 'package:fix_ar/screens/auth_screen.dart';
import 'package:fix_ar/screens/camera_screen.dart';
import 'package:fix_ar/screens/home_screen.dart';
import 'package:fix_ar/screens/onboarding_screen.dart';
import 'package:fix_ar/screens/parts_screen.dart';
import 'package:fix_ar/screens/repair_screen.dart';
import 'package:fix_ar/screens/tutorial_screen.dart';
import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const FixARApp());
}

class FixARApp extends StatelessWidget {
  const FixARApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FixAR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/auth':(cintext)=>const AuthScreen(),
        '/home': (context) => const HomeScreen(),
        "/tutorials":(context)=>const TutorialScreen(),
        '/ar-camera': (context) => const ARCameraScreen(),
        '/repair-steps':(context)=>const RepairStepsScreen(),
        '/parts': (context) => const PartsScreen(),
      },
    );
  }
}