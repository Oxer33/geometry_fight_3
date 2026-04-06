// ============================================================
// LASER WEAPON - Geometry Fight 3
// ============================================================
// Arma laser che emette un raggio continuo.
// Il danno viene applicato ogni tick ai nemici nel raggio.
// ============================================================

import 'package:flame/components.dart';

import '../../data/constants.dart';
import 'weapon_base.dart';

class LaserWeapon extends WeaponBase {
  LaserWeapon(super.config);

  @override
  List<WeaponProjectileData> generateProjectiles({
    required Vector2 position,
    required Vector2 direction,
  }) {
    // Il laser non genera proiettili tradizionali,
    // ma viene gestito come raggio continuo nel collision manager
    return [
      WeaponProjectileData(
        position: position.clone(),
        direction: direction.clone(),
        speed: 2000.0, // Velocità molto alta per simulare il raggio
        bounces: 0,
        lifetime: 0.05, // Vita molto breve, viene rigenerato ogni frame
        color: config.color,
        damage: config.damage,
        size: WeaponConstants.laserWidth,
      ),
    ];
  }

  /// Lunghezza massima del laser
  double get laserLength => 600.0;

  /// Larghezza del laser
  double get laserWidth => WeaponConstants.laserWidth;
}
