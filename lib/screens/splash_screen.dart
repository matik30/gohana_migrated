import 'package:flutter/material.dart';
import 'package:gohana_migrated/theme/colors.dart';
import 'package:hive/hive.dart';
import '../models/recipe.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Importy potrebných balíkov a súborov

// Úvodná obrazovka (SplashScreen), ktorá sa zobrazí pri štarte aplikácie
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// Stavová trieda pre SplashScreen
class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Premenná pre stav priebehu načítavania (0.0 - 1.0)
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    // Spustenie inicializačných krokov aplikácie
    _startInitialization();
  }

  // Asynchrónna inicializácia aplikácie (databáza, téma, simulované kroky)
  Future<void> _startInitialization() async {
    // 1. Inicializácia Hive (databáza)
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() => _progress = 0.2);
    await Hive.openBox<Recipe>('recipes');
    setState(() => _progress = 0.4);
    // 2. Načítanie témy (simulácia)
    await Future.delayed(const Duration(milliseconds: 300));
    await SharedPreferences.getInstance();
    setState(() => _progress = 0.6);
    // 3. Simulácia ďalších krokov (napr. seedovanie, migrácie...)
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() => _progress = 0.8);
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() => _progress = 1.0);
    await Future.delayed(const Duration(milliseconds: 200));
    // Po dokončení presmeruj na hlavnú obrazovku
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  void dispose() {
    // Už nie je potrebné uvoľňovať AnimationController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: FadeTransition(
          // Fade loga je teraz priamo viazaný na hodnotu _progress (0.0 - 1.0)
          opacity: AlwaysStoppedAnimation(_progress),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo aplikácie
              Image.asset('assets/images/Gohana.png', width: 350),
              const SizedBox(height: 20),
              const SizedBox(height: 40),
              // Indikátor priebehu načítavania
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
