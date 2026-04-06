import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../data/constants.dart';
import '../enemy.dart';

class SnakeSegment {
  Vector2 position;
  SnakeSegment(this.position);
}

class Snake extends Enemy {
  final List<SnakeSegment> _segments = [];
  double _sinePhase = 0;

  Snake({required super.position, int segmentCount = EnemyConstants.snakeSegmentCount})
      : super(
          type: EnemyType.snake,
          maxHP: EnemyConstants.snakeHeadHP,
          speed: EnemyConstants.snakeSpeed,
          scoreValue: EnemyConstants.snakeScorePerSegment * segmentCount,
          geomValue: segmentCount,
          color: EnemyConstants.snakeHeadColor,
          size: EnemyConstants.snakeSize,
        ) {
    for (int i = 0; i < segmentCount; i++) {
      _segments.add(SnakeSegment(position.clone()));
    }
    _sinePhase = Random().nextDouble() * 2 * pi;
  }

  @override
  void update(double dt) {
    super.update(dt);
    for (int i = 0; i < _segments.length; i++) {
      final target = i == 0 ? position : _segments[i - 1].position;
      final diff = target - _segments[i].position;
      if (diff.length > EnemyConstants.snakeSegmentGap) {
        _segments[i].position.add(diff.normalized() * speed * dt);
      }
    }
  }

  @override
  void updateAI(double dt, Vector2 playerPosition) {
    final direction = playerPosition - position;
    if (direction.length > 0) {
      _sinePhase += dt * 3;
      direction.normalize();
      final perpendicular = Vector2(-direction.y, direction.x);
      velocity = direction * speed + perpendicular * sin(_sinePhase) * 50;
    }
  }

  @override
  void renderShape(Canvas canvas, Offset center, double size) {
    final headPaint = Paint()..color = EnemyConstants.snakeHeadColor..style = PaintingStyle.fill;
    canvas.drawCircle(center, size, headPaint);
    final bodyPaint = Paint()..color = EnemyConstants.snakeBodyColor..style = PaintingStyle.fill;
    for (int i = 1; i < _segments.length; i++) {
      final seg = _segments[i];
      canvas.drawCircle(Offset(seg.position.x, seg.position.y), size * (1 - i / _segments.length * 0.5), bodyPaint);
    }
  }

  int get segmentCount => _segments.length;
}