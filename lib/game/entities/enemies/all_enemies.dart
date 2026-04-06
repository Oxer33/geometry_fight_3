// ============================================================
// ALTRI NEMICI - Geometry Fight 3
// ============================================================
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../data/constants.dart';
import '../enemy.dart';

enum KamikazeState { idle, charging, recovering }

class Spawner extends Enemy {
  double _spawnTimer = 0;
  Function()? onSpawnDrone;
  Spawner({required super.position})
      : super(type: EnemyType.spawner, maxHP: EnemyConstants.spawnerHP, speed: EnemyConstants.spawnerSpeed,
              scoreValue: EnemyConstants.spawnerScore, geomValue: 5, color: EnemyConstants.spawnerColor, size: EnemyConstants.spawnerSize);
  @override
  void update(double dt) { super.update(dt); _spawnTimer += dt; if (_spawnTimer >= EnemyConstants.spawnerSpawnInterval) { _spawnTimer = 0; onSpawnDrone?.call(); } }
  @override
  void updateAI(double dt, Vector2 playerPosition) { final away = position - playerPosition; if (away.length > 0) velocity = away.normalized() * speed; }
  @override
  void renderShape(Canvas canvas, Offset center, double size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = i * pi / 3;
      if (i == 0) {
        path.moveTo(center.dx + cos(angle) * size, center.dy + sin(angle) * size);
      } else {
        path.lineTo(center.dx + cos(angle) * size, center.dy + sin(angle) * size);
      }
    }
    path.close(); canvas.drawPath(path, paint);
  }
}

class Bouncer extends Enemy {
  Bouncer({required super.position, double? initialSpeed})
      : super(type: EnemyType.bouncer, maxHP: EnemyConstants.bouncerHP, speed: initialSpeed ?? EnemyConstants.bouncerBaseSpeed,
              scoreValue: EnemyConstants.bouncerScore, geomValue: 3, color: EnemyConstants.bouncerColor, size: EnemyConstants.bouncerSize) {
    final angle = Random().nextDouble() * 2 * pi; velocity = Vector2(cos(angle), sin(angle)) * speed;
  }
  @override
  void update(double dt) { super.update(dt); if (position.x <= 0 || position.x >= ArenaConstants.arenaWidth) velocity.x = -velocity.x; if (position.y <= 0 || position.y >= ArenaConstants.arenaHeight) velocity.y = -velocity.y; }
  @override
  void updateAI(double dt, Vector2 playerPosition) {}
  @override
  void renderShape(Canvas canvas, Offset center, double size) { final paint = Paint()..color = color..style = PaintingStyle.fill; canvas.drawCircle(center, size, paint); }
}

class Splitter extends Enemy {
  final int level;
  Splitter({required super.position, this.level = 1})
      : super(type: EnemyType.splitter, maxHP: EnemyConstants.splitterHP, speed: EnemyConstants.splitterSpeed + (level - 1) * 50,
              scoreValue: level == 1 ? EnemyConstants.splitterScoreLarge : level == 2 ? EnemyConstants.splitterScoreMedium : EnemyConstants.splitterScoreSmall,
              geomValue: level, color: EnemyConstants.splitterColor,
              size: level == 1 ? EnemyConstants.splitterSizeLarge : level == 2 ? EnemyConstants.splitterSizeMedium : EnemyConstants.splitterSizeSmall);
  @override
  void updateAI(double dt, Vector2 playerPosition) { final dir = playerPosition - position; if (dir.length > 0) velocity = dir.normalized() * speed; }
  @override
  void renderShape(Canvas canvas, Offset center, double size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final path = Path();
    for (int i = 0; i < 3; i++) {
      final angle = i * 2 * pi / 3 - pi / 2;
      if (i == 0) {
        path.moveTo(center.dx + cos(angle) * size, center.dy + sin(angle) * size);
      } else {
        path.lineTo(center.dx + cos(angle) * size, center.dy + sin(angle) * size);
      }
    }
    path.close(); canvas.drawPath(path, paint);
  }
}

class ShieldEnemy extends Enemy {
  double _shieldHP = EnemyConstants.shieldHP; double _shieldRegenTimer = 0; bool _shieldActive = true;
  ShieldEnemy({required super.position})
      : super(type: EnemyType.shieldEnemy, maxHP: EnemyConstants.shieldEnemyHP, speed: EnemyConstants.shieldEnemySpeed,
              scoreValue: EnemyConstants.shieldEnemyScore, geomValue: 4, color: EnemyConstants.shieldEnemyColor, size: EnemyConstants.shieldEnemySize);
  @override
  void update(double dt) { super.update(dt); if (!_shieldActive) { _shieldRegenTimer += dt; if (_shieldRegenTimer >= EnemyConstants.shieldRegenTime) { _shieldActive = true; _shieldHP = EnemyConstants.shieldHP; } } }
  @override
  void updateAI(double dt, Vector2 playerPosition) { final dir = playerPosition - position; if (dir.length > 0) velocity = dir.normalized() * speed; }
  bool blockHit(Vector2 hitDirection) { if (!_shieldActive) return false; final dot = velocity.normalized().dot(hitDirection.normalized()); if (dot > 0.5) { _shieldHP--; if (_shieldHP <= 0) { _shieldActive = false; _shieldRegenTimer = 0; } return true; } return false; }
  @override
  void renderShape(Canvas canvas, Offset center, double size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill; canvas.drawCircle(center, size, paint);
    if (_shieldActive) { final shieldPaint = Paint()..color = Colors.blue.withValues(alpha: 0.5)..style = PaintingStyle.stroke..strokeWidth = 3; canvas.drawArc(Rect.fromCircle(center: center, radius: size + 5), -0.5, 1.0, false, shieldPaint); }
  }
}

class BlackHole extends Enemy {
  double _rotationAngle = 0;
  BlackHole({required super.position})
      : super(type: EnemyType.blackHole, maxHP: EnemyConstants.blackHoleHP, speed: EnemyConstants.blackHoleSpeed,
              scoreValue: EnemyConstants.blackHoleScore, geomValue: EnemyConstants.blackHoleGeoms, color: EnemyConstants.blackHoleColor, size: EnemyConstants.blackHoleSize);
  @override
  void update(double dt) { super.update(dt); _rotationAngle += dt * 2; }
  @override
  void updateAI(double dt, Vector2 playerPosition) { final dir = playerPosition - position; if (dir.length > 0) velocity = dir.normalized() * speed; }
  @override
  void renderShape(Canvas canvas, Offset center, double size) {
    final paint = Paint()..color = Colors.black..style = PaintingStyle.fill; canvas.drawCircle(center, size, paint);
    final borderPaint = Paint()..color = const Color(0xFFFF0000).withValues(alpha: 0.6)..style = PaintingStyle.stroke..strokeWidth = 3;
    canvas.drawArc(Rect.fromCircle(center: center, radius: size + 3), _rotationAngle, pi * 1.5, false, borderPaint);
  }
}

class Kamikaze extends Enemy {
  KamikazeState _state = KamikazeState.idle; double _stateTimer = 0; Vector2 _chargeTarget = Vector2.zero();
  Kamikaze({required super.position})
      : super(type: EnemyType.kamikaze, maxHP: EnemyConstants.kamikazeHP, speed: 0,
              scoreValue: EnemyConstants.kamikazeScore, geomValue: 2, color: EnemyConstants.kamikazeColor, size: EnemyConstants.kamikazeSize);
  @override
  void update(double dt) {
    super.update(dt); _stateTimer += dt;
    if (_state == KamikazeState.idle && _stateTimer >= EnemyConstants.kamikazeIdleDuration) { _state = KamikazeState.charging; _stateTimer = 0; }
    else if (_state == KamikazeState.charging) { velocity = (_chargeTarget - position).normalized() * EnemyConstants.kamikazeChargeSpeed; if (position.distanceTo(_chargeTarget) < 20) { _state = KamikazeState.recovering; _stateTimer = 0; velocity = Vector2.zero(); } }
    else if (_state == KamikazeState.recovering && _stateTimer >= 1.0) { _state = KamikazeState.idle; _stateTimer = 0; }
  }
  @override
  void updateAI(double dt, Vector2 playerPosition) { if (_state == KamikazeState.idle && _stateTimer >= EnemyConstants.kamikazeIdleDuration * 0.5) _chargeTarget = playerPosition.clone(); }
  @override
  void renderShape(Canvas canvas, Offset center, double size) {
    final paint = Paint()..color = _state == KamikazeState.idle && _stateTimer > 0.5 ? Colors.red.withValues(alpha: sin(_stateTimer * 20) * 0.5 + 0.5) : color..style = PaintingStyle.fill;
    final path = Path()..moveTo(center.dx + size, center.dy)..lineTo(center.dx - size, center.dy - size * 0.5)..lineTo(center.dx - size * 0.5, center.dy)..lineTo(center.dx - size, center.dy + size * 0.5)..close();
    canvas.drawPath(path, paint);
  }
}
