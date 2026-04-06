// ============================================================
// MAIN MENU - Geometry Fight 3
// ============================================================
// Schermata principale con titolo animato e pulsanti.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../main.dart';
import 'game_screen.dart';
import 'shop_screen.dart';
import 'settings_screen.dart';

/// Schermata menu principale
class MainMenuScreen extends ConsumerStatefulWidget {
  const MainMenuScreen({super.key});

  @override
  ConsumerState<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends ConsumerState<MainMenuScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _titleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _titleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final saveData = ref.watch(saveDataProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF000011), Color(0xFF000000)],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Titolo animato
              AnimatedBuilder(
                animation: _titleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _titleAnimation.value,
                    child: child,
                  );
                },
                child: const _GameTitle(),
              ),

              const SizedBox(height: 20),

              // Gold Geoms counter
              Text(
                '💎 ${saveData.goldGeoms} Gold Geoms',
                style: const TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 18,
                  fontFamily: 'monospace',
                ),
              ),

              const Spacer(),

              // Pulsanti principali
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    _NeonButton(
                      text: '▶ GIOCA',
                      color: const Color(0xFF00FFFF),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GameScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _NeonButton(
                      text: '🛒 SHOP',
                      color: const Color(0xFFFF00AA),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ShopScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _NeonButton(
                      text: '⚙ IMPOSTAZIONI',
                      color: const Color(0xFF00FF88),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Versione
              const Text(
                'v1.0.0',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

/// Titolo del gioco con effetto neon
class _GameTitle extends StatelessWidget {
  const _GameTitle();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF00FFFF), Color(0xFFFF00AA), Color(0xFF00FF88)],
          ).createShader(bounds),
          child: const Text(
            'GEOMETRY FIGHT 3',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'monospace',
              letterSpacing: 4,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Retro Evolved',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFFFF00AA),
            fontFamily: 'monospace',
            letterSpacing: 8,
          ),
        ),
      ],
    );
  }
}

/// Bottone neon personalizzato
class _NeonButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onPressed;

  const _NeonButton({
    required this.text,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
