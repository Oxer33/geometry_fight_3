// ============================================================
// SINGULARITY BOSS - Geometry Fight 3
// ============================================================
// Boss della Wave 30. Una singolarità gravitazionale.
// Meccaniche:
// - Attira il player verso di sé (gravità)
// - Pulse attack ogni 3 secondi
// - Crea mini buchi neri temporanei
// ============================================================

import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../data/constants.dart';
import '../enemy.dart';
import '../projectile.dart';

class SingularityBoss extends Enemy {
  // Stato
  double _attackTimer = 0.0;
  double _pulseTimer = 0.0;
  double _pullTimer = 0.0;
  double _rotationAngle = 0;
  double _pulseRadius = 0;
  bool _isPulsing = false;

  // Mini buchi neri
  final List<MiniBlackHole> _miniBlackHoles = [];
  double _blackHoleSpawnTimer = 0;

  // Callback
  Function(EnemyProjectile projectile)? onEnemyShoot;

  SingularityBoss({required Vector2 position})
      : super(
          type: EnemyType.drone,
          position: position,
          maxHP: BossConstants.singularityHP,
          speed: 50.0,
          scoreValue: 15000,
          geomValue: 150,
          color: BossConstants.singularityColor,
          size: 50.0,
        );

  @override
  void update(double dt) {
    super.update(dt);
    if (!isActive) return;

    _rotationAngle += dt * 0.5;
    _attackTimer -= dt;
    _pulseTimer -= dt;
    _pullTimer -= dt;
    _blackHoleSpawnTimer -= dt;

    // Aggiorna pulse
    if (_isPulsing) {
      _pulseRadius += dt * 300;
      if (_pulseRadius > 400) {
        _isPulsing = false;
        _pulseRadius = 0;
      }
    }

    // Pulse attack
    if (_pulseTimer <= 0) {
      _startPulse();
      _pulseTimer = BossConstants.singularityPulseInterval;
    }

    // Pull attack
    if (_pullTimer <= 0) {
      _pullTimer = BossConstants.singularityPullInterval;
    }

    // Spawn mini buchi neri
    if (_blackHoleSpawnTimer <= 0 && _miniBlackHoles.length < 3) {
      _spawnMiniBlackHole();
      _blackHoleSpawnTimer = 5.0;
    }

    // Aggiorna mini buchi neri
    for (final bh in _miniBlackHoles) {
      bh.lifetime -= dt;
    }
    _miniBlackHoles.removeWhere((bh) => bh.lifetime <= 0);

    // Movimento lento
    final targetX = ArenaConstants.arenaWidth / 2 + cos(lifetime * 0.15) * 300;
    final targetY = ArenaConstants.arenaHeight / 2 + sin(lifetime * 0.2) * 300;
    velocity = (Vector2(targetX, targetY) - position) * 0.3;

    // Sparo continuo
    if (_attackTimer <= 0) {
      _attack();
      _attackTimer = 0.8;
    }
  }

  void _startPulse() {
    _isPulsing = true;
    _pulseRadius = 0;
  }

  void _spawnMiniBlackHole() {
    final angle = Random().nextDouble() * 2 * pi;
    final distance = 150.0 + Random().nextDouble() * 100;
    final pos = position + Vector2(cos(angle) * distance, sin(angle) * distance);
    _miniBlackHoles.add(MiniBlackHole(position: pos, lifetime: 8.0));
  }

  void _attack() {
    // Sparo a spirale
    final count = 12;
    for (int i = 0; i < count; i++) {
      final angle = (i * 2 * pi / count) + _rotationAngle;
      final direction = Vector2(cos(angle), sin(angle));
      _shootProjectile(direction, 250);
    }
  }

  void _shootProjectile(Vector2 direction, double speed) {
    if (onEnemyShoot == null) return;
    final projectile = EnemyProjectile(
      position: position.clone(),
      direction: direction.normalized(),
      speed: speed,
    );
    onEnemyShoot!(projectile);
  }

  /// Calcola la forza gravitazionale su una posizione
  Vector2 gravityForce(Vector2 targetPos, {double force = 200.0, double radius = 300.0}) {
    final direction = position - targetPos;
    final distance = direction.length;
    if (distance > radius || distance < 1) return Vector2.zero();
    final strength = force * (1 - distance / radius);
    return direction.normalized() * strength;
  }


  @override
  void updateAI(double dt, Vector2 playerPosition) {}

  @override
  void renderShape(Canvas canvas, Offset center, double size) {
    // Disegna mini buchi neri
    for (final bh in _miniBlackHoles) {
      _renderMiniBlackHole(canvas, bh);
    }

    // Pulse ring
    if (_isPulsing) {
      _renderPulseRing(canvas, center);
    }

    // Corpo principale - buco nero
    _renderBlackHole(canvas, center, size);

    // Barra HP
    _renderHealthBar(canvas, center, size);
  }

  void _renderBlackHole(Canvas canvas, Offset center, double size) {
    // Glow esterno
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    canvas.drawCircle(center, size + 10, glowPaint);

    // Anello rotante
    final ringPaint = Paint()
      ..color = const Color(0xFF00FF00)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawCircle(center, size + 5, ringPaint);

    // Centro nero
    final blackPaint = Paint()..color = const Color(0xFF000000)..style = PaintingStyle.fill;
    canvas.drawCircle(center, size * 0.6, blackPaint);

    // Centro verde
    final centerPaint = Paint()
      ..color = const Color(0xFF00FF00).withValues(alpha: 0.5 + sin(lifetime * 5) * 0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, size * 0.3, centerPaint);
  }

  void _renderPulseRing(Canvas canvas, Offset center) {
    final paint = Paint()
      ..color = const Color(0xFF00FF00).withValues(alpha: 0.3 * (1 - _pulseRadius / 400))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    canvas.drawCircle(center, _pulseRadius, paint);
  }

  void _renderMiniBlackHole(Canvas canvas, MiniBlackHole bh) {
    final screenPos = Offset(bh.position.x, bh.position.y);
    final size = 20.0;
    final alpha = bh.lifetime / 8.0;

    final glowPaint = Paint()
      ..color = const Color(0xFF660066).withValues(alpha: alpha * 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(screenPos, size + 5, glowPaint);

    final paint = Paint()
      ..color = const Color(0xFF000000).withValues(alpha: alpha)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(screenPos, size * 0.5, paint);
  }

  void _renderHealthBar(Canvas canvas, Offset center, double size) {
    final barWidth = size * 2;
    final barHeight = 8.0;
    final barY = center.dy - size - 20;

    final bgPaint = Paint()..color = const Color(0xFF333333)..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(center.dx - barWidth / 2, barY, barWidth, barHeight), bgPaint);

    final hpPaint = Paint()
      ..color = hpPercent > 0.5 ? const Color(0xFF00FF00) : const Color(0xFFFF0000)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(center.dx - barWidth / 2, barY, barWidth * hpPercent, barHeight), hpPaint);
  }
}

/// Mini buco nero temporaneo
class MiniBlackHole {
  final Vector2 position;
  double lifetime;

  MiniBlackHole({required this.position, required this.lifetime});
}
