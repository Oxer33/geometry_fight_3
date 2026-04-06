// ============================================================
// GEOMETRY FIGHT GAME - Geometry Fight 3
// ============================================================
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../data/constants.dart';
import '../data/models/save_data.dart';
import 'entities/player.dart';
import 'entities/projectile.dart';
import 'entities/enemy.dart';
import 'effects/grid_distortion.dart';
import 'systems/wave_system.dart';
import 'systems/score_system.dart';
import 'systems/particle_system.dart';
import 'systems/powerup_system.dart';
import 'collision_manager.dart';

class GeometryFightGame extends FlameGame {
  final SaveData saveData;
  final Function(int score, int geoms) onGameOver;

  Player? player;
  late GridDistortion gridDistortion;
  late WaveSystem waveSystem;
  late ScoreSystem scoreSystem;
  late ParticleSystem particleSystem;
  late PowerUpSystem powerUpSystem;
  late CollisionManager collisionManager;

  double gameTime = 0.0;
  bool isPaused = false;
  double _timeScale = 1.0;

  GeometryFightGame({required this.saveData, required this.onGameOver});

  @override
  Color backgroundColor() => const Color(0xFF000000);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    camera.viewfinder.anchor = Anchor.center;

    // Aggiungi tutti i sistemi
    gridDistortion = GridDistortion(size: size);
    await add(gridDistortion);

    collisionManager = CollisionManager();
    await add(collisionManager);

    scoreSystem = ScoreSystem();
    await add(scoreSystem);

    particleSystem = ParticleSystem();
    await add(particleSystem);

    powerUpSystem = PowerUpSystem();
    await add(powerUpSystem);

    waveSystem = WaveSystem(
      scoreSystem: scoreSystem,
      particleSystem: particleSystem,
      powerUpSystem: powerUpSystem,
    );
    await add(waveSystem);

    // Crea il player al centro dell'arena
    player = Player(
      position: Vector2(ArenaConstants.arenaWidth / 2, ArenaConstants.arenaHeight / 2),
      saveData: saveData,
    );

    // Collega il player ai sistemi
    player!.onShoot = _onPlayerShoot;
    player!.onHit = _onPlayerHit;
    player!.onDeath = _onPlayerDeath;

    await add(player!);

    // Collega il wave system allo spawn dei nemici
    waveSystem.onEnemySpawn = _onEnemySpawn;
    waveSystem.onWaveStart = _onWaveStart;
    waveSystem.onWaveComplete = _onWaveComplete;

    // Collega il collision manager ai sistemi
    collisionManager.scoreSystem = scoreSystem;
    collisionManager.particleSystem = particleSystem;
    collisionManager.waveSystem = waveSystem;
    collisionManager.player = player;

    // Avvia la prima wave
    waveSystem.startFirstWave();
  }

  // ============================================================
  // CALLBACK DEL PLAYER
  // ============================================================

  /// Quando il player spara, crea un proiettile
  void _onPlayerShoot(Vector2 position, Vector2 direction) {
    final projectile = PlayerProjectile(
      position: position.clone(),
      direction: direction.clone(),
    );
    add(projectile);
  }

  /// Quando il player viene colpito
  void _onPlayerHit() {
    // Effetto visivo e sonoro
    particleSystem.explosion(
      position: player!.position,
      color: const Color(0xFFFF0000),
      count: 10,
    );
    gridDistortion.applyExplosionForce(player!.position, 50.0);
  }

  /// Quando il player muore
  void _onPlayerDeath() {
    // Effetto esplosione grande
    particleSystem.explosion(
      position: player!.position,
      color: PlayerConstants.playerColor,
      count: 50,
    );
    gridDistortion.applyExplosionForce(player!.position, 200.0);

    // Game over dopo un breve delay
    Future.delayed(const Duration(seconds: 2), () {
      triggerGameOver();
    });
  }

  // ============================================================
  // CALLBACK DEL WAVE SYSTEM
  // ============================================================

  /// Quando un nemico viene spawnato
  void _onEnemySpawn(Enemy enemy) {
    // Il nemico viene aggiunto dal wave system stesso
  }

  /// Quando inizia una nuova wave
  void _onWaveStart(int waveNumber) {
    debugPrint('🌊 Wave $waveNumber iniziata!');
  }

  /// Quando una wave viene completata
  void _onWaveComplete(int waveNumber) {
    debugPrint('✅ Wave $waveNumber completata!');
  }

  // ============================================================
  // GAME LOOP
  // ============================================================

  @override
  void update(double dt) {
    if (isPaused) return;
    final scaledDt = dt * _timeScale;
    gameTime += scaledDt;
    super.update(scaledDt);

    // Camera segue il player
    if (player != null && player!.isAlive) {
      camera.viewfinder.position.lerp(player!.position, PlayerConstants.cameraLerp);
    }

    // Aggiorna la griglia deformabile
    gridDistortion.updateGrid(dt);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    gridDistortion.onResize(size);
  }

  void pause() { isPaused = true; }
  void resume() { isPaused = false; }
  void activateSlowMo() { _timeScale = EffectConstants.slowMoTimeScale; }
  void deactivateSlowMo() { _timeScale = 1.0; }
  void triggerGameOver() {
    onGameOver(scoreSystem.currentScore, scoreSystem.currentGeoms);
  }
}
