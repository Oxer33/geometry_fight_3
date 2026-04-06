// ============================================================
// GAME SCREEN - Geometry Fight 3
// ============================================================
// Schermata di gioco con GameWidget Flame e HUD overlay.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart' show Vector2;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_joystick/flutter_joystick.dart';

import '../../game/geometry_fight_game.dart';
import '../../main.dart';

/// Schermata di gioco
class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  late GeometryFightGame _game;
  // Variabili per l'HUD - verranno aggiornate dal gioco
  int _score = 0;
  int _geoms = 0;
  double _multiplier = 1.0;
  int _lives = 3;
  int _bombs = 1;
  int _wave = 0;

  @override
  void initState() {
    super.initState();
    final saveData = ref.read(saveDataProvider);
    _game = GeometryFightGame(
      saveData: saveData,
      onGameOver: (score, geoms) {
        _handleGameOver(score, geoms);
      },
    );
  }

  void _handleGameOver(int score, int geoms) {
    // Salva punteggio e geomi
    final saveData = ref.read(saveDataProvider);
    saveData.updateHighscore('classic', score);
    saveData.addGoldGeoms(geoms);
    ref.read(saveDataProvider.notifier).save();

    // Mostra game over
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.black87,
          title: const Text(
            'GAME OVER',
            style: TextStyle(color: Color(0xFFFF00AA), fontFamily: 'monospace'),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Punteggio: $score', style: const TextStyle(color: Colors.white)),
              Text('Geomi: $geoms', style: const TextStyle(color: Color(0xFF00FF88))),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Menu', style: TextStyle(color: Color(0xFF00FFFF))),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Game Widget
          GameWidget(game: _game),

          // HUD Overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildHUD(),
          ),

          // Joystick movimento (sinistra)
          Positioned(
            bottom: 40,
            left: 40,
            child: Joystick(
              listener: (details) {
                // Collega il joystick sinistro al movimento del player
                final moveDir = Vector2(details.x, -details.y);
                _game.player?.move(moveDir);
              },
            ),
          ),

          // Joystick mira (destra) - mira e spara
          Positioned(
            bottom: 40,
            right: 40,
            child: Joystick(
              listener: (details) {
                // Collega il joystick destro alla mira e allo sparo
                final aimDir = Vector2(details.x, -details.y);
                if (aimDir.length2 > 0) {
                  _game.player?.aim(aimDir);
                  _game.player?.shoot();
                }
              },
            ),
          ),

          // Pulsante bomba
          Positioned(
            bottom: 40,
            right: 160,
            child: GestureDetector(
              onTap: () {
                _game.player?.useBomb();
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFF0000), width: 3),
                  color: const Color(0xFFFF0000).withValues(alpha: 0.3),
                ),
                child: const Center(
                  child: Text('💣', style: TextStyle(fontSize: 24)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Costruisce l'HUD
  Widget _buildHUD() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Score
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$_score',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'x${_multiplier.toStringAsFixed(1)}',
                style: TextStyle(
                  color: _multiplier >= 10
                      ? const Color(0xFFFFD700)
                      : _multiplier >= 5
                          ? const Color(0xFFFF00AA)
                          : Colors.white,
                  fontSize: 16,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),

          // Wave
          Text(
            'WAVE $_wave',
            style: const TextStyle(
              color: Color(0xFF00FFFF),
              fontSize: 18,
              fontFamily: 'monospace',
            ),
          ),

          // Vite e Bombe
          Row(
            children: [
              // Geoms
              Text(
                '💎 $_geoms',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 16),
              // Vite
              Row(
                children: List.generate(
                  _lives,
                  (i) => const Text('🚀', style: TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(width: 8),
              // Bombe
              Row(
                children: List.generate(
                  _bombs,
                  (i) => const Text('💣', style: TextStyle(fontSize: 20)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
