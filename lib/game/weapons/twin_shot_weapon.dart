// ============================================================
// TWIN SHOT WEAPON - Geometry Fight 3
// ============================================================
// Arma che spara due proiettili paralleli.
// Maggiore probabilità di colpire i nemici.
// ============================================================

import 'package:flame/components.dart';

import '../../data/constants.dart';
import 'weapon_base.dart';

class TwinShotWeapon extends WeaponBase {
  TwinShotWeapon(super.config);

  @override
  List<WeaponProjectileData> generateProjectiles({
    required Vector2 position,
    required Vector2 direction,
  }) {
    final projectiles = <WeaponProjectileData>[];
    final normalizedDir = direction.normalized();
    // Calcola la perpendicolare per l'offset
    final perpendicular = Vector2(-normalizedDir.y, normalizedDir.x);
    final offset = WeaponConstants.twinOffset;

    // Proiettile sinistro
    projectiles.add(WeaponProjectileData(
      position: position.clone() + perpendicular * offset,
      direction: normalizedDir.clone(),
      speed: config.projectileSpeed,
      bounces: config.projectileBounces,
      lifetime: config.projectileLifetime,
      color: config.color,
      damage: config.damage,
    ));

    // Proiettile destro
    projectiles.add(WeaponProjectileData(
      position: position.clone() - perpendicular * offset,
      direction: normalizedDir.clone(),
      speed: config.projectileSpeed,
      bounces: config.projectileBounces,
      lifetime: config.projectileLifetime,
      color: config.color,
      damage: config.damage,
    ));

    return projectiles;
  }
}
