// ============================================================
// SINGLE SHOT WEAPON - Geometry Fight 3
// ============================================================
// Arma base - proiettile singolo.
// ============================================================

import 'package:flame/components.dart';

import 'weapon_base.dart';

class SingleShotWeapon extends WeaponBase {
  SingleShotWeapon(super.config);

  @override
  List<WeaponProjectileData> generateProjectiles({
    required Vector2 position,
    required Vector2 direction,
  }) {
    return [
      WeaponProjectileData(
        position: position.clone(),
        direction: direction.clone(),
        speed: config.projectileSpeed,
        bounces: config.projectileBounces,
        lifetime: config.projectileLifetime,
        color: config.color,
        damage: config.damage,
      ),
    ];
  }
}
