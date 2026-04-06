// ============================================================
// SWARM MOTHER BOSS - Geometry Fight 3
// ============================================================
// Boss della Wave 40. La madre dello swarm.
// 4 Fasi + Berserk finale:
// - Fase 1 (100%-75%): Genera minion, sparo lento
// - Fase 2 (75%-50%): Più minion, attacco a onda
// - Fase 3 (50%-20%): Minion aggressivi, attacco circolare
// - Fase 4 (20%-0%): Furia, spawn continuo
// - Berserk (< 20% se minion vivi): Distruzione totale
// ============================================================

import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../data/constants.dart';
import '../enemy.dart';
import '../projectile.dart';

class SwarmMotherBoss extends Enemy {
  // Fasi
  final double _phase1Threshold = BossConstants.swarmMotherPhase1Threshold;
  final double _phase2Threshold = BossConstants.swarmMotherPhase2Threshold;
  final double _phase3Threshold = BossConstants.swarmMotherPhase3Threshold;
  final double _berserkThreshold = BossConstants.swarmMotherBerserkThreshold;
  int _currentPhase = 1;

  // Stato
  double _attackTimer = 0.0;
  double _spawnTimer = 0.0;
  double _rotationAngle = 0;
  bool _isBerserk = false;

  // Minion
  final List<SwarmMinion> _minions = [];
  final int _maxMinions = 8;

  // Callback
  Function(EnemyProjectile projectile)? onEnemyShoot;
  Function(Enemy minion)? onMinionSpawn;

  SwarmMotherBoss({required Vector2 position})
      : super(
          type: EnemyType.drone,
          position: position,
          maxHP: BossConstants.swarmMotherHP,
          speed: 60.0,
          scoreValue: 20000,
          geomValue: 200,
          color: BossConstants.swarmMotherColor,
          size: 70.0,
        );

  @override
  void update(double dt) {
    super.update(dt);
    if (!isActive) return;

    _rotationAngle += dt * 0.4;
    _attackTimer -= dt;
    _spawnTimer -= dt;

    // Aggiorna fase
    _updatePhase();

    // Aggiorna minion
    for (final minion in _minions) {
      minion.update(dt);
    }
    _minions.removeWhere((m) => !m.isAlive);

    // Spawn minion
    if (_spawnTimer <= 0 && _minions.length < _maxMinions) {
      _spawnMinion();
      _spawnTimer = _getSpawnInterval();
    }

    // Attacco
    if (_attackTimer <= 0) {
      _attack();
      _attackTimer = _getAttackInterval();
    }

    // Movimento
    final targetX = ArenaConstants.arenaWidth / 2 + cos(lifetime * 0.1) * 250;
    final targetY = ArenaConstants.arenaHeight / 2 + sin(lifetime * 0.15) * 250;
    velocity = (Vector2(targetX, targetY) - position) * 0.4;
  }

  void _updatePhase() {
    final hpPercent = this.hpPercent;

    // Berserk check
    if (!_isBerserk && hpPercent <= _berserkThreshold && _minions.isNotEmpty) {
      _isBerserk = true;
      _currentPhase = 5;
    } else if (hpPercent <= _phase3Threshold) {
      _currentPhase = 4;
    } else if (hpPercent <= _phase2Threshold) {
      _currentPhase = 3;
    } else if (hpPercent <= _phase1Threshold) {
      _currentPhase = 2;
    } else {
      _currentPhase = 1;
    }
  }

  double _getSpawnInterval() {
    return switch (_currentPhase) {
      1 => 4.0,
      2 => 3.0,
      3 => 2.0,
      4 => 1.0,
      5 => 0.5, // Berserk
      _ => 3.0,
    };
  }

  double _getAttackInterval() {
    return switch (_currentPhase) {
      1 => 2.0,
      2 => 1.5,
      3 => 1.0,
      4 => 0.7,
      5 => 0.3, // Berserk
      _ => 1.5,
    };
  }

  void _spawnMinion() {
    final angle = Random().nextDouble() * 2 * pi;
    final distance = 100.0;
    final pos = position + Vector2(cos(angle) * distance, sin(angle) * distance);
    final minion = SwarmMinion(
      position: pos,
      phase: _currentPhase,
    );
    _minions.add(minion);
    onMinionSpawn?.call(minion);
  }

  void _attack() {
    if (_isBerserk) {
      // Attacco berserk: pioggia di proiettili
      _attackBerserk();
    } else if (_currentPhase >= 3) {
      // Attacco circolare
      _attackCircle();
    } else {
      // Attacco base
      _attackBasic();
    }
  }

  void _attackBasic() {
    final count = 6 + _currentPhase * 2;
    for (int i = 0; i < count; i++) {
      final angle = (i * 2 * pi / count) + _rotationAngle;
      final direction = Vector2(cos(angle), sin(angle));
      _shootProjectile(direction, 200);
    }
  }

  void _attackCircle() {
    // Doppio cerchio
    for (int ring = 0; ring < 2; ring++) {
      final count = 12;
      for (int i = 0; i < count; i++) {
        final angle = (i * 2 * pi / count) + _rotationAngle + (ring * pi / count);
        final direction = Vector2(cos(angle), sin(angle));
        _shootProjectile(direction, 250 + ring * 50);
      }
    }
  }

  void _attackBerserk() {
    final count = 20;
    for (int i = 0; i < count; i++) {
      final angle = Random().nextDouble() * 2 * pi;
      final direction = Vector2(cos(angle), sin(angle));
      _shootProjectile(direction, 300 + Random().nextDouble() * 100);
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

  @override
  void takeDamage(double damage) {
    super.takeDamage(damage);
    // Se berserk, più danno ricevuto
    if (_isBerserk) {
      // Già applicato dal damage base
    }
  }

  @override
  void updateAI(double dt, Vector2 playerPosition) {}

  @override
  void renderShape(Canvas canvas, Offset center, double size) {
    // Disegna minion
    for (final minion in _minions) {
      _renderMinion(canvas, minion);
    }

    // Corpo principale
    _renderBody(canvas, center, size);

    // Barra HP
    _renderHealthBar(canvas, center, size);
  }

  void _renderBody(Canvas canvas, Offset center, double size) {
    // Glow
    final glowColor = _isBerserk ? const Color(0xFFFF0000) : color;
    final glowPaint = Paint()
      ..color = glowColor.withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(center, size + 8, glowPaint);

    // Corpo - forma organica
    final paint = Paint()
      ..color = _isBerserk ? const Color(0xFFFF0044) : color
      ..style = PaintingStyle.fill;

    final path = Path();
    for (int i = 0; i < 8; i++) {
      final angle = (i * 2 * pi / 8) + _rotationAngle * 0.5;
      final r = size * (0.8 + sin(lifetime * 3 + i) * 0.2);
      final x = center.dx + cos(angle) * r;
      final y = center.dy + sin(angle) * r;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);

    // Centro pulsante
    final centerPaint = Paint()
      ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.3 + sin(lifetime * 5) * 0.2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, size * 0.3, centerPaint);
  }

  void _renderMinion(Canvas canvas, SwarmMinion minion) {
    final pos = Offset(minion.position.x, minion.position.y);
    final size = 12.0;

    final paint = Paint()
      ..color = const Color(0xFFFF00FF).withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pos, size, paint);
  }

  void _renderHealthBar(Canvas canvas, Offset center, double size) {
    final barWidth = size * 2;
    final barHeight = 8.0;
    final barY = center.dy - size - 25;

    final bgPaint = Paint()..color = const Color(0xFF333333)..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(center.dx - barWidth / 2, barY, barWidth, barHeight), bgPaint);

    final hpColor = _isBerserk
        ? const Color(0xFFFF0000)
        : hpPercent > 0.5
            ? const Color(0xFFFF00FF)
            : const Color(0xFFFF0000);
    final hpPaint = Paint()..color = hpColor..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(center.dx - barWidth / 2, barY, barWidth * hpPercent, barHeight), hpPaint);

    // Indicatore fase
    if (_isBerserk) {
      final textPainter = TextPainter(
        text: const TextSpan(
          text: 'BERSERK!',
          style: TextStyle(color: Color(0xFFFF0000), fontSize: 12, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(center.dx - textPainter.width / 2, barY - 18));
    }
  }
}

/// Minion dello Swarm
class SwarmMinion extends Enemy {
  final int phase;
  double _minionLifetime = 0;

  SwarmMinion({required Vector2 position, required this.phase})
      : super(
          type: EnemyType.drone,
          position: position,
          maxHP: 2.0 + phase,
          speed: 100.0 + phase * 20,
          scoreValue: 100,
          geomValue: 5,
          color: const Color(0xFFFF00FF),
          size: 15.0,
        );

  @override
  void update(double dt) {
    super.update(dt);
    _minionLifetime += dt;

    // Movimento verso il player (semplificato)
    final targetX = ArenaConstants.arenaWidth / 2 + sin(_minionLifetime * 2) * 200;
    final targetY = ArenaConstants.arenaHeight / 2 + cos(_minionLifetime * 1.5) * 200;
    velocity = (Vector2(targetX, targetY) - position) * 0.5;
  }

  @override
  void updateAI(double dt, Vector2 playerPosition) {}

  @override
  void renderShape(Canvas canvas, Offset center, double size) {
    final paint = Paint()
      ..color = const Color(0xFFFF00FF).withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, size, paint);
  }
}
