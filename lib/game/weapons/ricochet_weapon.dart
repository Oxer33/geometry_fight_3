// ============================================================
// RICOCHET WEAPON - Geometry Fight 3
// ============================================================
// Arma che spara proiettili che rimbalzano sui muri e nemici.
// ============================================================

import 'package:flame/components.dart';

import '../../data/constants.dart';
import 'weapon_base.dart';

class RicochetWeapon extends WeaponBase {
  RicochetWeapon(super.config);

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
        bounces: WeaponConstants.ricochetBounces, // 5 rimbalzi
        lifetime: 4.0, // Vita più lunga per permettere più rimbalzi
        color: config.color,
        damage: config.damage,
        size: 6.0,
      ),
    ];
  }
}
