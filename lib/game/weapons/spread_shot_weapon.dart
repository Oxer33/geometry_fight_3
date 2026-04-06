// ============================================================
// SPREAD SHOT WEAPON - Geometry Fight 3
// ============================================================
// Arma che spara 5 proiettili a ventaglio.
// Utile per colpire più nemici contemporaneamente.
// ============================================================

import 'dart:math';
import 'package:flame/components.dart';

import '../../data/constants.dart';
import 'weapon_base.dart';

class SpreadShotWeapon extends WeaponBase {
  SpreadShotWeapon(super.config);

  @override
  List<WeaponProjectileData> generateProjectiles({
    required Vector2 position,
    required Vector2 direction,
  }) {
    final projectiles = <WeaponProjectileData>[];
    final count = WeaponConstants.spreadCount;
    final totalAngle = WeaponConstants.spreadAngle * pi / 180; // Converti in radianti
    final baseAngle = atan2(direction.y, direction.x);

    for (int i = 0; i < count; i++) {
      // Calcola l'angolo per ogni proiettile
      final angle = baseAngle - totalAngle / 2 + (totalAngle / (count - 1)) * i;
      final newDirection = Vector2(cos(angle), sin(angle));

      projectiles.add(WeaponProjectileData(
        position: position.clone(),
        direction: newDirection,
        speed: config.projectileSpeed,
        bounces: config.projectileBounces,
        lifetime: config.projectileLifetime,
        color: config.color,
        damage: config.damage,
      ));
    }

    return projectiles;
  }
}
