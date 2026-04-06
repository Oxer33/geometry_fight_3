import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../data/constants.dart';
import '../enemy.dart';

class Mine extends Enemy {
  double _detonTimer = 0;
  bool _exploding = false;

  Mine({required super.position})
      : super(
          type: EnemyType.mine,
          maxHP: EnemyConstants.mineHP,
          speed: 0,
          scoreValue: EnemyConstants.mineScore,
          geomValue: 2,
          color: EnemyConstants.mineColor,
          size: EnemyConstants.mineSize,
        );

  @override
  void update(double dt) {
    super.update(dt);
    if (_exploding) {
      _detonTimer -= dt;
      if (_detonTimer <= 0) removeFromParent();
    }
  }

  @override
  void updateAI(double dt, Vector2 playerPosition) {
    if (_exploding) return;
    final dist = position.distanceTo(playerPosition);
    if (dist < EnemyConstants.mineTriggerRadius) {
      _detonTimer = EnemyConstants.mineDetonDelay;
      _exploding = true;
    }
  }

  @override
  void renderShape(Canvas canvas, Offset center, double size) {
    final paint = Paint()
      ..color = _exploding ? Colors.red : color
      ..style = PaintingStyle.fill;
    final path = Path();
    for (int i = 0; i < 8; i++) {
      final angle = i * pi / 4;
      final r = i.isEven ? size : size * 0.5;
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
  }
}
