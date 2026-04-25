import 'package:fix_ar/screens/auth/auth_screen.dart';
import 'package:fix_ar/screens/auth/bloc/auth_bloc.dart';
import 'package:fix_ar/screens/camera/bloc/camera_bloc.dart';
import 'package:fix_ar/screens/camera/camera_screen.dart';
import 'package:fix_ar/screens/home/home_screen.dart';
import 'package:fix_ar/screens/onboarding/bloc/onboarding_bloc.dart';
import 'package:fix_ar/screens/onboarding/onboarding_screen.dart';
import 'package:fix_ar/screens/parts_screen.dart';
import 'package:fix_ar/screens/repair_screen.dart';
import 'package:fix_ar/screens/tutorial_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      theme: ThemeData(scaffoldBackgroundColor: const Color(0xFF080810)),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) {
          return BlocProvider(
            create: (_) => OnboardingBloc(),
            child: const OnboardingScreen(),
          );
        },
        '/auth': (context) {
          return BlocProvider(
            create: (_) => AuthBloc(),
            child: const AuthScreen(),
          );
        },
        '/home': (context) {
          return BlocProvider(
            create: (_) => AuthBloc(),
            child: const HomeScreen(),
          );
        },
        "/tutorials": (context) => const TutorialScreen(),
        '/ar-camera': (context) => BlocProvider(
          create: (_) => CameraBloc(),
          child: const ARCameraScreen(),
        ),
        '/repair-steps': (context) => const RepairStepsScreen(),
        '/parts': (context) => const PartsScreen(),
      },
    );
  }
}
