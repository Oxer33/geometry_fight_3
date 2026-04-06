import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../data/constants.dart';
import '../enemy.dart';

class Weaver extends Enemy {
  double _sinePhase = 0;
  Weaver({required super.position})
      : super(
          type: EnemyType.weaver,
          maxHP: EnemyConstants.weaverHP,
          speed: EnemyConstants.weaverSpeed,
          scoreValue: EnemyConstants.weaverScore,
          geomValue: 2,
          color: EnemyConstants.weaverColor,
          size: EnemyConstants.weaverSize,
        ) { _sinePhase = Random().nextDouble() * 2 * pi; }

  @override
  void updateAI(double dt, Vector2 playerPosition) {
    final direction = playerPosition - position;
    if (direction.length > 0) {
      direction.normalize();
      _sinePhase += dt * EnemyConstants.weaverSineFrequency * 2 * pi;
      final perpendicular = Vector2(-direction.y, direction.x);
      velocity = direction * speed + perpendicular * sin(_sinePhase) * EnemyConstants.weaverSineAmplitude;
    }
  }

  @override
  void renderShape(Canvas canvas, Offset center, double size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(center.dx, center.dy - size * 1.3)
      ..lineTo(center.dx + size * 0.6, center.dy)
      ..lineTo(center.dx, center.dy + size * 1.3)
      ..lineTo(center.dx - size * 0.6, center.dy)
      ..close();
    canvas.drawPath(path, paint);
  }
}