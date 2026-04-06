// ============================================================
// DRONE - Geometry Fight 3
// ============================================================
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../data/constants.dart';
import '../enemy.dart';

class Drone extends Enemy {
  Drone({required super.position})
      : super(
          type: EnemyType.drone,
          maxHP: EnemyConstants.droneHP,
          speed: EnemyConstants.droneSpeed,
          scoreValue: EnemyConstants.droneScore,
          geomValue: EnemyConstants.droneGeoms,
          color: EnemyConstants.droneColor,
          size: EnemyConstants.droneSize,
        );

  @override
  void updateAI(double dt, Vector2 playerPosition) {
    final direction = playerPosition - position;
    if (direction.length > 0) velocity = direction.normalized() * speed;
  }

  @override
  void renderShape(Canvas canvas, Offset center, double size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(center.dx, center.dy - size)
      ..lineTo(center.dx + size * 0.7, center.dy)
      ..lineTo(center.dx, center.dy + size)
      ..lineTo(center.dx - size * 0.7, center.dy)
      ..close();
    canvas.drawPath(path, paint);
  }
}