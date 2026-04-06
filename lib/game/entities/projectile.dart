// ============================================================
// PROJECTILE - Geometry Fight 3
// ============================================================
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../data/constants.dart';
import 'enemy.dart';

class PlayerProjectile extends PositionComponent {
  Vector2 direction;
  double speed;
  int bouncesRemaining;
  double lifetime;
  bool isActive = true;
  final Color color;

  // Proprietà per armi speciali
  final bool isHoming; // Proiettile a ricerca
  final bool isPlasma; // Proiettile esplosivo
  final double explosionRadius; // Raggio esplosione plasma
  final double? customSize; // Dimensione personalizzata

  PlayerProjectile({
    required super.position,
    required this.direction,
    this.speed = ProjectileConstants.bulletSpeed,
    int bounces = 2,
    this.lifetime = ProjectileConstants.bulletLifetime,
    this.color = ProjectileConstants.bulletColor,
    this.isHoming = false,
    this.isPlasma = false,
    this.explosionRadius = 0.0,
    this.customSize,
  })  : bouncesRemaining = bounces,
        super(
          size: Vector2.all(customSize ?? ProjectileConstants.bulletWidth),
          anchor: Anchor.center,
        );

  @override
  void update(double dt) {
    super.update(dt);
    if (!isActive) return;

    // Homing: insegui il nemico più vicino
    if (isHoming) {
      _updateHoming(dt);
    }

    position.add(direction * speed * dt);
    lifetime -= dt;
    if (lifetime <= 0) {
      if (isPlasma) {
        _explode();
      }
      removeFromParent();
      return;
    }
    if (position.x < 0) { position.x = 0; _bounce(Vector2(1, 0)); }
    if (position.x > ArenaConstants.arenaWidth) { position.x = ArenaConstants.arenaWidth; _bounce(Vector2(-1, 0)); }
    if (position.y < 0) { position.y = 0; _bounce(Vector2(0, 1)); }
    if (position.y > ArenaConstants.arenaHeight) { position.y = ArenaConstants.arenaHeight; _bounce(Vector2(0, -1)); }
  }

  /// Homing: trova il nemico più vicino e curva verso di esso
  void _updateHoming(double dt) {
    final enemies = parent?.parent?.children.whereType<Enemy>().toList() ?? [];
    Enemy? closestEnemy;
    double closestDistance = double.infinity;

    for (final enemy in enemies) {
      if (!enemy.isActive) continue;
      final distance = position.distanceTo(enemy.position);
      if (distance < closestDistance) {
        closestDistance = distance;
        closestEnemy = enemy;
      }
    }

    if (closestEnemy != null && closestDistance < 500) {
      final targetDir = (closestEnemy.position - position).normalized();
      // Interpola gradualmente verso la direzione del nemico
      direction = (direction + targetDir * dt * 5).normalized();
    }
  }

  /// Esplosione plasma: notifica il game per damage ad area
  void _explode() {
    // L'esplosione viene gestita dal collision manager quando il proiettile colpisce
  }

  void _bounce(Vector2 normal) {
    if (bouncesRemaining <= 0) {
      if (isPlasma) {
        _explode();
      }
      removeFromParent();
      return;
    }
    bouncesRemaining--;
    direction = direction - normal * 2 * direction.dot(normal);
  }

  @override
  void render(Canvas canvas) {
    if (!isActive) return;
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final glowPaint = Paint()..color = color.withValues(alpha: 0.4)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    if (isPlasma) {
      // Proiettile plasma: cerchio più grande
      final radius = customSize ?? 12.0;
      canvas.drawCircle(Offset(size.x / 2, size.y / 2), radius, glowPaint);
      canvas.drawCircle(Offset(size.x / 2, size.y / 2), radius, paint);
    } else if (isHoming) {
      // Proiettile homing: rombo
      final center = Offset(size.x / 2, size.y / 2);
      final s = size.x / 2;
      final path = Path()
        ..moveTo(center.dx, center.dy - s)
        ..lineTo(center.dx + s, center.dy)
        ..lineTo(center.dx, center.dy + s)
        ..lineTo(center.dx - s, center.dy)
        ..close();
      canvas.drawPath(path, glowPaint);
      canvas.drawPath(path, paint);
    } else {
      final rect = Rect.fromCenter(center: Offset(size.x / 2, size.y / 2), width: size.x, height: size.y);
      canvas.drawRect(rect, glowPaint);
      canvas.drawRect(rect, paint);
    }
  }

  double get collisionRadius => (customSize ?? size.x) / 2;
}

class EnemyProjectile extends PositionComponent {
  Vector2 direction;
  double speed;
  bool isActive = true;

  EnemyProjectile({required super.position, required this.direction, this.speed = 300.0})
      : super(size: Vector2(6, 6), anchor: Anchor.center);

  @override
  void update(double dt) {
    super.update(dt);
    position.add(direction * speed * dt);
    if (position.x < -50 || position.x > ArenaConstants.arenaWidth + 50 || position.y < -50 || position.y > ArenaConstants.arenaHeight + 50) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = const Color(0xFFFF0000)..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, paint);
  }
}
