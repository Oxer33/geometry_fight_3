// ============================================================
// THE GRID BOSS - Geometry Fight 3
// ============================================================
// Boss della Wave 10. Una griglia vivente che cambia forma.
// 3 Fasi:
// - Fase 1 (100%-60% HP): Si muove lentamente, spara proiettili dai bordi
// - Fase 2 (60%-30% HP): Si divide in 4 quadranti, attacco più aggressivo
// - Fase 3 (30%-0% HP): Collassa, attacco finale disperato con laser
// ============================================================

import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../data/constants.dart';
import '../enemy.dart';
import '../projectile.dart';

/// Fasi del boss The Grid
enum GridPhase { phase1, phase2, phase3 }

/// Stati del boss The Grid
enum GridState { idle, moving, attacking, transitioning }

class TheGridBoss extends Enemy {
  GridPhase _currentPhase = GridPhase.phase1;
  GridState _state = GridState.idle;
  double _stateTimer = 0.0;
  double _attackTimer = 0.0;
  double _transitionTimer = 0.0;
  Vector2 _targetPosition = Vector2.zero();
  double _rotationAngle = 0;
  double _pulseIntensity = 0;

  // Callback per spawnare proiettili nemici
  Function(EnemyProjectile projectile)? onEnemyShoot;

  TheGridBoss({required Vector2 position})
      : super(
          type: EnemyType.drone, // Usiamo drone come tipo base
          position: position,
          maxHP: BossConstants.gridHP,
          speed: BossConstants.gridSize * 0.3,
          scoreValue: 5000,
          geomValue: 50,
          color: BossConstants.gridColor,
          size: BossConstants.gridSize,
        );

  @override
  void update(double dt) {
    super.update(dt);
    if (!isActive) return;

    _updatePhase();
    _updateState(dt);
    _updateBehavior(dt);
    _rotationAngle += dt * 0.5;
    _pulseIntensity = sin(lifetime * 3) * 0.2 + 0.8;
  }

  /// Aggiorna la fase in base agli HP
  void _updatePhase() {
    if (hpPercent > BossConstants.gridPhase1Threshold) {
      _currentPhase = GridPhase.phase1;
    } else if (hpPercent > BossConstants.gridPhase2Threshold) {
      _currentPhase = GridPhase.phase2;
    } else {
      _currentPhase = GridPhase.phase3;
    }
  }

  /// Gestisce le transizioni di stato
  void _updateState(double dt) {
    _stateTimer -= dt;
    _attackTimer -= dt;
    _transitionTimer -= dt;

    if (_state == GridState.transitioning && _transitionTimer <= 0) {
      _state = GridState.idle;
      _stateTimer = 1.0;
    }

    if (_state == GridState.idle && _stateTimer <= 0) {
      _chooseNextAction();
    }

    if (_state == GridState.moving && _stateTimer <= 0) {
      _state = GridState.idle;
    }

    if (_state == GridState.attacking && _attackTimer <= 0) {
      _state = GridState.idle;
      _stateTimer = 0.5;
    }
  }

  /// Sceglie la prossima azione in base alla fase
  void _chooseNextAction() {
    switch (_currentPhase) {
      case GridPhase.phase1:
        _phase1Behavior();
        break;
      case GridPhase.phase2:
        _phase2Behavior();
        break;
      case GridPhase.phase3:
        _phase3Behavior();
        break;
    }
  }

  // ============================================================
  // FASE 1: Griglia compatta, attacchi dai bordi
  // ============================================================
  void _phase1Behavior() {
    final rand = Random().nextDouble();
    if (rand < 0.4) {
      // Movimento lento verso il centro
      _state = GridState.moving;
      _stateTimer = 2.0;
      _targetPosition = Vector2(
        ArenaConstants.arenaWidth / 2 + (Random().nextDouble() - 0.5) * 400,
        ArenaConstants.arenaHeight / 2 + (Random().nextDouble() - 0.5) * 400,
      );
    } else if (rand < 0.8) {
      // Attacco: sparo circolare
      _state = GridState.attacking;
      _attackTimer = 1.5;
      _attackPatternCircle();
    } else {
      // Attacco: sparo a spirale
      _state = GridState.attacking;
      _attackTimer = 2.0;
      _attackPatternSpiral();
    }
  }

  // ============================================================
  // FASE 2: Griglia divisa, attacchi più aggressivi
  // ============================================================
  void _phase2Behavior() {
    final rand = Random().nextDouble();
    if (rand < 0.3) {
      // Movimento più veloce
      _state = GridState.moving;
      _stateTimer = 1.5;
      _targetPosition = Vector2(
        ArenaConstants.arenaWidth / 2 + (Random().nextDouble() - 0.5) * 600,
        ArenaConstants.arenaHeight / 2 + (Random().nextDouble() - 0.5) * 600,
      );
    } else if (rand < 0.7) {
      // Attacco: doppio cerchio
      _state = GridState.attacking;
      _attackTimer = 1.0;
      _attackPatternDoubleCircle();
    } else {
      // Attacco: pioggia di proiettili
      _state = GridState.attacking;
      _attackTimer = 2.0;
      _attackPatternRain();
    }
  }

  // ============================================================
  // FASE 3: Collasso, attacco finale disperato
  // ============================================================
  void _phase3Behavior() {
    final rand = Random().nextDouble();
    if (rand < 0.2) {
      // Movimento erratico
      _state = GridState.moving;
      _stateTimer = 0.8;
      _targetPosition = Vector2(
        ArenaConstants.arenaWidth / 2 + (Random().nextDouble() - 0.5) * 800,
        ArenaConstants.arenaHeight / 2 + (Random().nextDouble() - 0.5) * 800,
      );
    } else if (rand < 0.6) {
      // Attacco: esplosione di proiettili
      _state = GridState.attacking;
      _attackTimer = 0.5;
      _attackPatternExplosion();
    } else {
      // Attacco: laser (simulato con proiettili veloci)
      _state = GridState.attacking;
      _attackTimer = 1.5;
      _attackPatternLaser();
    }
  }

  /// Aggiorna il comportamento (movimento verso target)
  void _updateBehavior(double dt) {
    if (_state == GridState.moving) {
      final direction = _targetPosition - position;
      if (direction.length > 5) {
        velocity = direction.normalized() * speed;
      } else {
        velocity = Vector2.zero();
      }
    } else if (_state == GridState.idle) {
      velocity *= 0.95;
    } else {
      velocity *= 0.9;
    }
  }

  // ============================================================
  // PATTERN DI ATTACCO
  // ============================================================

  /// Sparo circolare - proiettili in tutte le direzioni
  void _attackPatternCircle() {
    final count = 12 + (_currentPhase == GridPhase.phase3 ? 8 : 0);
    for (int i = 0; i < count; i++) {
      final angle = (i * 2 * pi / count);
      final direction = Vector2(cos(angle), sin(angle));
      _shootProjectile(direction, 250);
    }
  }

  /// Sparo a spirale
  void _attackPatternSpiral() {
    final count = 20;
    for (int i = 0; i < count; i++) {
      final angle = (i * 2 * pi / count) + _rotationAngle;
      final direction = Vector2(cos(angle), sin(angle));
      _shootProjectile(direction, 300);
    }
  }

  /// Doppio cerchio (Fase 2)
  void _attackPatternDoubleCircle() {
    for (int ring = 0; ring < 2; ring++) {
      final count = 16;
      final radius = 1.0 + ring * 0.5;
      for (int i = 0; i < count; i++) {
        final angle = (i * 2 * pi / count) + (ring * pi / count);
        final direction = Vector2(cos(angle), sin(angle)) * radius;
        _shootProjectile(direction.normalized(), 200 + ring * 50);
      }
    }
  }

  /// Pioggia di proiettili (Fase 2)
  void _attackPatternRain() {
    final count = 30;
    for (int i = 0; i < count; i++) {
      final angle = pi / 2 + (Random().nextDouble() - 0.5) * pi;
      final direction = Vector2(cos(angle), sin(angle));
      _shootProjectile(direction, 350 + Random().nextDouble() * 100);
    }
  }

  /// Esplosione di proiettili (Fase 3)
  void _attackPatternExplosion() {
    final count = 24;
    for (int i = 0; i < count; i++) {
      final angle = Random().nextDouble() * 2 * pi;
      final direction = Vector2(cos(angle), sin(angle));
      _shootProjectile(direction, 400 + Random().nextDouble() * 200);
    }
  }

  /// Laser simulato (Fase 3)
  void _attackPatternLaser() {
    // Simula un laser con una raffica di proiettili veloci
    final count = 15;
    for (int i = 0; i < count; i++) {
      final direction = Vector2(cos(_rotationAngle), sin(_rotationAngle));
      _shootProjectile(direction, 800);
      _rotationAngle += 0.1;
    }
  }

  /// Sparo un proiettile nemico
  void _shootProjectile(Vector2 direction, double speed) {
    if (onEnemyShoot == null) return;
    final projectile = EnemyProjectile(
      position: position.clone(),
      direction: direction.normalized(),
      speed: speed,
    );
    onEnemyShoot!(projectile);
  }

  @override
  void updateAI(double dt, Vector2 playerPosition) {
    // Il boss usa il proprio sistema di comportamento
  }

  @override
  void renderShape(Canvas canvas, Offset center, double size) {
    final paint = Paint()
      ..color = color.withValues(alpha: _pulseIntensity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    // Disegna la griglia
    final gridSize = size / 4;
    for (int i = -2; i <= 2; i++) {
      // Linee verticali
      canvas.drawLine(
        Offset(center.dx + i * gridSize, center.dy - size),
        Offset(center.dx + i * gridSize, center.dy + size),
        paint,
      );
      // Linee orizzontali
      canvas.drawLine(
        Offset(center.dx - size, center.dy + i * gridSize),
        Offset(center.dx + size, center.dy + i * gridSize),
        paint,
      );
    }

    // Bordo esterno
    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    canvas.drawRect(
      Rect.fromCenter(center: center, width: size * 2, height: size * 2),
      borderPaint,
    );

    // Indicatore di fase (usato per debug)
    // final phaseText = switch (_currentPhase) {
    //   GridPhase.phase1 => 'I',
    //   GridPhase.phase2 => 'II',
    //   GridPhase.phase3 => 'III',
    // };

    // Barra HP
    _renderHealthBar(canvas, center, size);
  }

  /// Renderizza la barra della salute
  void _renderHealthBar(Canvas canvas, Offset center, double size) {
    final barWidth = size * 2;
    final barHeight = 8.0;
    final barY = center.dy - size - 20;

    // Sfondo
    final bgPaint = Paint()
      ..color = const Color(0xFF333333)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(center.dx - barWidth / 2, barY, barWidth, barHeight),
      bgPaint,
    );

    // Salute
    final hpPaint = Paint()
      ..color = hpPercent > 0.5
          ? const Color(0xFF00FF00)
          : hpPercent > 0.25
              ? const Color(0xFFFFFF00)
              : const Color(0xFFFF0000)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(center.dx - barWidth / 2, barY, barWidth * hpPercent, barHeight),
      hpPaint,
    );

    // Nome del boss
    // (verrebbe renderizzato con TextPainter in un'implementazione completa)
  }

  @override
  void takeDamage(double damage) {
    super.takeDamage(damage);
    if (!isActive) return;

    // Effetto visivo quando colpito
    _pulseIntensity = 1.5;

    // Transizione di fase
    if (hpPercent <= BossConstants.gridPhase2Threshold && _currentPhase == GridPhase.phase2) {
      _startTransition(GridPhase.phase3);
    } else if (hpPercent <= BossConstants.gridPhase1Threshold && _currentPhase == GridPhase.phase1) {
      _startTransition(GridPhase.phase2);
    }
  }

  /// Inizia la transizione tra fasi
  void _startTransition(GridPhase newPhase) {
    _state = GridState.transitioning;
    _transitionTimer = 1.0;
    _currentPhase = newPhase;

    // Effetto visivo di transizione
    _pulseIntensity = 2.0;
  }

  GridPhase get currentPhase => _currentPhase;
  GridState get currentState => _state;
}
