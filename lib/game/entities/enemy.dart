// ============================================================
// ENEMY BASE - Geometry Fight 3
// ============================================================

import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../data/constants.dart';

enum EnemyType { drone, snake, mine, spawner, weaver, bouncer, splitter, shieldEnemy, blackHole, kamikaze }

abstract class Enemy extends PositionComponent {
  final EnemyType type;
  double _currentHP;
  final double maxHP;
  double speed;
  final int scoreValue;
  final int geomValue;
  final Color color;
  bool isActive = true;
  double lifetime = 0;
  double _pulseAnimation = 0;
  Function(Enemy enemy)? onDeath;
  Function(Enemy enemy, double damage)? onHit;

  Enemy({
    required this.type,
    required Vector2 position,
    required this.maxHP,
    required this.speed,
    required this.scoreValue,
    required this.geomValue,
    required this.color,
    double size = 20,
  })  : _currentHP = maxHP,
        super(position: position.clone(), size: Vector2.all(size * 2), anchor: Anchor.center);

  @override
  void update(double dt) {
    super.update(dt);
    lifetime += dt;
    _pulseAnimation += dt * 5;
    position.add(velocity * dt);
    position.x = position.x.clamp(0.0, ArenaConstants.arenaWidth);
    position.y = position.y.clamp(0.0, ArenaConstants.arenaHeight);
  }

  Vector2 velocity = Vector2.zero();

  void updateAI(double dt, Vector2 playerPosition);

  void takeDamage(double damage) {
    if (!isActive) return;
    _currentHP -= damage;
    onHit?.call(this, damage);
    if (_currentHP <= 0) { isActive = false; onDeath?.call(this); removeFromParent(); }
  }

  @override
  void render(Canvas canvas) {
    if (!isActive) return;
    final center = Offset(size.x / 2, size.y / 2);
    final pulseSize = size.x / 2 + sin(_pulseAnimation) * 2;
    final glowPaint = Paint()..color = color.withValues(alpha: 0.4)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(center, pulseSize + 4, glowPaint);
    renderShape(canvas, center, pulseSize);
  }

  void renderShape(Canvas canvas, Offset center, double size);

  double get currentHP => _currentHP;
  double get hpPercent => _currentHP / maxHP;
  bool get isAlive => isActive;
}
