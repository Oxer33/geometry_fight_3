// ============================================================
// HOMING WEAPON - Geometry Fight 3
// ============================================================
// Arma che spara 3 missili a ricerca che inseguono i nemici.
// ============================================================

import 'dart:math';
import 'package:flame/components.dart';

import '../../data/constants.dart';
import 'weapon_base.dart';

class HomingWeapon extends WeaponBase {
  HomingWeapon(super.config);

  @override
  List<WeaponProjectileData> generateProjectiles({
    required Vector2 position,
    required Vector2 direction,
  }) {
    final projectiles = <WeaponProjectileData>[];
    final count = WeaponConstants.homingMissileCount;
    final baseAngle = atan2(direction.y, direction.x);

    for (int i = 0; i < count; i++) {
      // Leggera variazione di direzione per ogni missile
      final angleOffset = (i - (count - 1) / 2) * 0.15;
      final angle = baseAngle + angleOffset;
      final newDirection = Vector2(cos(angle), sin(angle));

      projectiles.add(WeaponProjectileData(
        position: position.clone(),
        direction: newDirection,
        speed: config.projectileSpeed,
        bounces: 0, // Non rimbalzano
        lifetime: 4.0, // Vita più lunga per permettere la ricerca
        color: config.color,
        damage: config.damage,
        size: 8.0,
        isHoming: true, // Attiva homing
      ));
    }

    return projectiles;
  }
}
