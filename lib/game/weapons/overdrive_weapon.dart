// ============================================================
// OVERDRIVE WEAPON - Geometry Fight 3
// ============================================================
// Arma a fuoco automatico ultra-rapido.
// Spara proiettili a velocità elevata per un tempo limitato.
// ============================================================

import 'package:flame/components.dart';

import '../../data/constants.dart';
import 'weapon_base.dart';

class OverdriveWeapon extends WeaponBase {
  double _overdriveTimer = 0.0;
  bool _overdriveActive = false;

  OverdriveWeapon(super.config);

  @override
  void reset() {
    super.reset();
    _overdriveTimer = 0.0;
    _overdriveActive = false;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_overdriveActive) {
      _overdriveTimer -= dt;
      if (_overdriveTimer <= 0) {
        _overdriveActive = false;
      }
    }
  }

  @override
  bool tryFire() {
    if (!_overdriveActive) {
      _overdriveActive = true;
      _overdriveTimer = WeaponConstants.overdriveDuration;
    }
    return super.tryFire();
  }

  @override
  List<WeaponProjectileData> generateProjectiles({
    required Vector2 position,
    required Vector2 direction,
  }) {
    return [
      WeaponProjectileData(
        position: position.clone(),
        direction: direction.clone(),
        speed: config.projectileSpeed * 1.5, // Più veloce
        bounces: 0,
        lifetime: 1.0,
        color: config.color,
        damage: config.damage,
        size: 4.0, // Proiettile più piccolo
      ),
    ];
  }

  @override
  void stopFiring() {
    super.stopFiring();
    _overdriveActive = false;
  }

  bool get isOverdriveActive => _overdriveActive;
  double get overdriveRemaining => _overdriveTimer;
}
