// ============================================================
// PROJECTILE - Geometry Fight 3
// ============================================================
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../data/constants.dart';

class PlayerProjectile extends PositionComponent {
  Vector2 direction;
  double speed;
  int bouncesRemaining;
  double lifetime;
  bool isActive = true;
  final Color color;

  PlayerProjectile({
    required super.position,
    required this.direction,
    this.speed = ProjectileConstants.bulletSpeed,
    int bounces = 2,
    this.lifetime = ProjectileConstants.bulletLifetime,
    this.color = ProjectileConstants.bulletColor,
  })  : bouncesRemaining = bounces,
        super(size: Vector2(ProjectileConstants.bulletWidth, ProjectileConstants.bulletHeight), anchor: Anchor.center);

  @override
  void update(double dt) {
    super.update(dt);
    if (!isActive) return;
    position.add(direction * speed * dt);
    lifetime -= dt;
    if (lifetime <= 0) { removeFromParent(); return; }
    if (position.x < 0) { position.x = 0; _bounce(Vector2(1, 0)); }
    if (position.x > ArenaConstants.arenaWidth) { position.x = ArenaConstants.arenaWidth; _bounce(Vector2(-1, 0)); }
    if (position.y < 0) { position.y = 0; _bounce(Vector2(0, 1)); }
    if (position.y > ArenaConstants.arenaHeight) { position.y = ArenaConstants.arenaHeight; _bounce(Vector2(0, -1)); }
  }

  void _bounce(Vector2 normal) {
    if (bouncesRemaining <= 0) { removeFromParent(); return; }
    bouncesRemaining--;
    direction = direction - normal * 2 * direction.dot(normal);
  }

  @override
  void render(Canvas canvas) {
    if (!isActive) return;
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final glowPaint = Paint()..color = color.withValues(alpha: 0.4)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    final rect = Rect.fromCenter(center: Offset(size.x / 2, size.y / 2), width: size.x, height: size.y);
    canvas.drawRect(rect, glowPaint);
    canvas.drawRect(rect, paint);
  }
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
