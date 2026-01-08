import 'package:flutter/material.dart';
import 'package:gohana_migrated/theme/colors.dart';
import 'package:hive/hive.dart';
import '../models/recipe.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();
    _startInitialization();
  }

  Future<void> _startInitialization() async {
    // 1. Init Hive
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() => _progress = 0.2);
    await Hive.openBox<Recipe>('recipes');
    setState(() => _progress = 0.4);
    // 2. Load theme (simulácia)
    await Future.delayed(const Duration(milliseconds: 300));
    await SharedPreferences.getInstance();
    setState(() => _progress = 0.6);
    // 3. Simuluj ďalšie kroky (napr. seedovanie, migrácie...)
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() => _progress = 0.8);
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() => _progress = 1.0);
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/Gohana.png', width: 350),
              const SizedBox(height: 20),
              const SizedBox(height: 40),
              SizedBox(
                width: 200,
                child: LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: AppColors.panel,
                  color: AppColors.accent,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
