// ============================================================
// WAVE SYSTEM - Geometry Fight 3
// ============================================================
import 'dart:math';
import 'package:flame/components.dart';
import '../../data/constants.dart';
import '../../game/entities/enemy.dart';
import '../../game/entities/enemies/drone.dart';
import '../../game/entities/enemies/weaver.dart';
import '../../game/entities/enemies/snake.dart';
import '../../game/entities/enemies/mine.dart';
import '../../game/entities/enemies/all_enemies.dart';
import '../../game/entities/bosses/the_grid_boss.dart';
import 'score_system.dart';
import 'particle_system.dart';
import 'powerup_system.dart';

enum WaveState { waiting, spawning, active, bossFight, complete }

class WaveSystem extends Component {
  final ScoreSystem scoreSystem;
  final ParticleSystem particleSystem;
  final PowerUpSystem powerUpSystem;
  final Random _random = Random();
  int currentWave = 0;
  WaveState _state = WaveState.waiting;
  double _waveTimer = 0.0;
  double _spawnTimer = 0.0;
  int _enemiesRemaining = 0;
  int _enemiesTotal = 0;
  int _enemiesSpawned = 0;
  bool _bossSpawned = false;
  Function(int waveNumber)? onWaveStart;
  Function(int waveNumber)? onWaveComplete;
  Function(int waveNumber)? onBossSpawn;
  Function(Enemy enemy)? onEnemySpawn;
  Function(TheGridBoss boss)? onBossSpawned;

  WaveSystem({required this.scoreSystem, required this.particleSystem, required this.powerUpSystem});

  @override
  void update(double dt) {
    if (_state == WaveState.waiting) {
      _waveTimer -= dt;
      if (_waveTimer <= 0) _startNextWave();
    } else if (_state == WaveState.spawning) {
      _spawnTimer -= dt;
      if (_spawnTimer <= 0 && _enemiesSpawned < _enemiesTotal) {
        _spawnEnemy();
        _enemiesSpawned++;
        _spawnTimer = WaveConstants.spawnInterval;
      }
      if (_enemiesSpawned >= _enemiesTotal) _state = WaveState.active;
    } else if (_state == WaveState.active && _enemiesRemaining <= 0) {
      _completeWave();
    } else if (_state == WaveState.bossFight && !_bossSpawned) {
      _spawnBoss();
    }
  }

  void _startNextWave() {
    currentWave++;
    onWaveStart?.call(currentWave);
    if (currentWave % WaveConstants.bossWaveInterval == 0) {
      _state = WaveState.bossFight;
      _bossSpawned = false;
      onBossSpawn?.call(currentWave);
    } else {
      _state = WaveState.spawning;
      _spawnWaveEnemies();
    }
  }

  void _spawnWaveEnemies() {
    _enemiesTotal = (5 + (currentWave * 2)).clamp(5, 50);
    _enemiesRemaining = _enemiesTotal;
    _enemiesSpawned = 0;
    _spawnTimer = 0; // Spawn immediato
  }

  void _spawnEnemy() {
    // Posizione casuale ai bordi dell'arena
    final edge = _random.nextInt(4);
    Vector2 spawnPos;
    switch (edge) {
      case 0: // Top
        spawnPos = Vector2(_random.nextDouble() * ArenaConstants.arenaWidth, 0);
        break;
      case 1: // Right
        spawnPos = Vector2(ArenaConstants.arenaWidth, _random.nextDouble() * ArenaConstants.arenaHeight);
        break;
      case 2: // Bottom
        spawnPos = Vector2(_random.nextDouble() * ArenaConstants.arenaWidth, ArenaConstants.arenaHeight);
        break;
      default: // Left
        spawnPos = Vector2(0, _random.nextDouble() * ArenaConstants.arenaHeight);
    }

    // Scegli tipo di nemico basato sulla wave
    Enemy enemy;
    final waveThreshold = currentWave;
    if (waveThreshold >= 8 && _random.nextDouble() < 0.1) {
      enemy = BlackHole(position: spawnPos);
    } else if (waveThreshold >= 6 && _random.nextDouble() < 0.15) {
      enemy = ShieldEnemy(position: spawnPos);
    } else if (waveThreshold >= 5 && _random.nextDouble() < 0.2) {
      enemy = Kamikaze(position: spawnPos);
    } else if (waveThreshold >= 4 && _random.nextDouble() < 0.15) {
      enemy = Splitter(position: spawnPos);
    } else if (waveThreshold >= 3 && _random.nextDouble() < 0.15) {
      enemy = Bouncer(position: spawnPos);
    } else if (waveThreshold >= 2 && _random.nextDouble() < 0.1) {
      enemy = Spawner(position: spawnPos);
    } else if (_random.nextDouble() < 0.3) {
      enemy = Mine(position: spawnPos);
    } else if (_random.nextDouble() < 0.4) {
      enemy = Snake(position: spawnPos);
    } else if (_random.nextDouble() < 0.5) {
      enemy = Weaver(position: spawnPos);
    } else {
      enemy = Drone(position: spawnPos);
    }

    // Callback quando il nemico muore
    enemy.onDeath = (deadEnemy) {
      onEnemyKilled();
    };

    onEnemySpawn?.call(enemy);
    add(enemy);
  }

  /// Spawn del boss The Grid alla wave 10
  void _spawnBoss() {
    _bossSpawned = true;
    final bossPosition = Vector2(
      ArenaConstants.arenaWidth / 2,
      ArenaConstants.arenaHeight / 2 - 300,
    );
    final boss = TheGridBoss(position: bossPosition);
    _enemiesRemaining = 1; // Il boss conta come un nemico
    onBossSpawned?.call(boss);
    onEnemySpawn?.call(boss);
    add(boss);
  }

  void _completeWave() {
    _state = WaveState.complete;
    onWaveComplete?.call(currentWave);
    scoreSystem.addWaveBonus(currentWave);
    _waveTimer = WaveConstants.wavePauseDuration;
    _state = WaveState.waiting;
  }

  void onEnemyKilled() {
    if (_enemiesRemaining > 0) _enemiesRemaining--;
  }

  void startFirstWave() {
    _waveTimer = 1.0;
    _state = WaveState.waiting;
  }

  WaveState get state => _state;
  int get enemiesRemaining => _enemiesRemaining;
  int get enemiesTotal => _enemiesTotal;
  double get completionPercent => _enemiesTotal == 0 ? 0.0 : 1.0 - (_enemiesRemaining / _enemiesTotal);
}
