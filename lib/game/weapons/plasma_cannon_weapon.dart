// ============================================================
// PLASMA CANNON WEAPON - Geometry Fight 3
// ============================================================
// Arma che spara proiettili esplosivi ad area.
// Il proiettile esplode al contatto, danneggiando tutti i nemici vicini.
// ============================================================

import 'package:flame/components.dart';

import '../../data/constants.dart';
import 'weapon_base.dart';

class PlasmaCannonWeapon extends WeaponBase {
  PlasmaCannonWeapon(super.config);

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
        bounces: 0, // Non rimbalza
        lifetime: 3.0, // Vita più lunga
        color: config.color,
        damage: config.damage,
        size: 12.0, // Proiettile più grande
      ),
    ];
  }

  /// Calcola il raggio di esplosione per questo proiettile
  double get explosionRadius => WeaponConstants.plasmaExplosionRadius;
}
