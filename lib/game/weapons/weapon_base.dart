// ============================================================
// WEAPON BASE - Geometry Fight 3
// ============================================================
// Classe base astratta per tutte le armi del gioco.
// Ogni arma definisce il proprio comportamento di sparo,
// tipo di proiettile, rate of fire, ecc.
// ============================================================

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../data/constants.dart';
// Import delle implementazioni specifiche
import 'single_shot_weapon.dart';
import 'spread_shot_weapon.dart';
import 'twin_shot_weapon.dart';
import 'laser_weapon.dart';
import 'plasma_cannon_weapon.dart';
import 'homing_weapon.dart';
import 'ricochet_weapon.dart';
import 'overdrive_weapon.dart';

/// Tipo di arma disponibile nel gioco
enum WeaponType {
  singleShot,    // Proiettile singolo base
  spreadShot,    // Proiettili multipli a ventaglio
  twinShot,      // Due proiettili paralleli
  laser,         // Raggio continuo
  plasmaCannon,  // Proiettile esplosivo
  homing,        // Proiettile a ricerca
  ricochet,      // Proiettile che rimbalza
  overdrive,     // Fuoco automatico ultra-rapido
}

/// Configurazione base di un'arma
class WeaponConfig {
  final WeaponType type;
  final String name;
  final String description;
  final Color color;
  final double fireRate; // Colpi al secondo
  final double damage;
  final double projectileSpeed;
  final int projectileBounces;
  final double projectileLifetime;
  final bool isUnlocked;
  final int unlockCost; // Costo in geom per sbloccare

  const WeaponConfig({
    required this.type,
    required this.name,
    required this.description,
    required this.color,
    this.fireRate = 8.0,
    this.damage = 1.0,
    this.projectileSpeed = ProjectileConstants.bulletSpeed,
    this.projectileBounces = 2,
    this.projectileLifetime = ProjectileConstants.bulletLifetime,
    this.isUnlocked = true,
    this.unlockCost = 0,
  });
}

/// Classe base astratta per tutte le armi
abstract class WeaponBase {
  final WeaponConfig config;
  double _fireTimer = 0.0;
  bool _isFiring = false;

  WeaponBase(this.config);

  /// Reset del timer di fuoco
  void reset() {
    _fireTimer = 0.0;
    _isFiring = false;
  }

  /// Aggiornamento dell'arma (chiamato ogni frame)
  void update(double dt) {
    if (_fireTimer > 0) {
      _fireTimer -= dt;
    }
  }

  /// Tentativo di sparo - ritorna true se può sparare
  bool tryFire() {
    if (_fireTimer <= 0) {
      _fireTimer = 1.0 / config.fireRate;
      _isFiring = true;
      return true;
    }
    return false;
  }

  /// Metodo astratto per generare i proiettili
  /// Deve essere implementato da ogni arma specifica
  List<WeaponProjectileData> generateProjectiles({
    required Vector2 position,
    required Vector2 direction,
  });

  /// Ferma il fuoco (per armi automatiche)
  void stopFiring() {
    _isFiring = false;
  }

  bool get isFiring => _isFiring;
  double get fireTimer => _fireTimer;
  double get fireRate => config.fireRate;
  WeaponType get type => config.type;
}

/// Dati per la creazione di un proiettile da un'arma
class WeaponProjectileData {
  final Vector2 position;
  final Vector2 direction;
  final double speed;
  final int bounces;
  final double lifetime;
  final Color color;
  final double damage;
  final double? size; // Opzionale, per proiettili di dimensioni diverse
  final bool isHoming; // Proiettile a ricerca
  final bool isPlasma; // Proiettile esplosivo

  const WeaponProjectileData({
    required this.position,
    required this.direction,
    this.speed = ProjectileConstants.bulletSpeed,
    this.bounces = 2,
    this.lifetime = ProjectileConstants.bulletLifetime,
    this.color = ProjectileConstants.bulletColor,
    this.damage = 1.0,
    this.size,
    this.isHoming = false,
    this.isPlasma = false,
  });
}

/// Factory per creare istanze di armi
class WeaponFactory {
  static const Map<WeaponType, WeaponConfig> configs = {
    WeaponType.singleShot: WeaponConfig(
      type: WeaponType.singleShot,
      name: 'Blaster',
      description: 'Proiettile singolo affidabile',
      color: ProjectileConstants.bulletColor,
      fireRate: 8.0,
      damage: 1.0,
    ),
    WeaponType.spreadShot: WeaponConfig(
      type: WeaponType.spreadShot,
      name: 'Spread Shot',
      description: '5 proiettili a ventaglio',
      color: PowerUpConstants.spreadShotColor,
      fireRate: 5.0,
      damage: 1.0,
    ),
    WeaponType.twinShot: WeaponConfig(
      type: WeaponType.twinShot,
      name: 'Twin Shot',
      description: 'Due proiettili paralleli',
      color: WeaponConstants.twinColor,
      fireRate: 7.0,
      damage: 1.0,
    ),
    WeaponType.laser: WeaponConfig(
      type: WeaponType.laser,
      name: 'Laser',
      description: 'Raggio continuo ad alto DPS',
      color: const Color(0xFFFF0000),
      fireRate: 20.0,
      damage: 0.3, // Danno per tick, ma tick molto frequenti
    ),
    WeaponType.plasmaCannon: WeaponConfig(
      type: WeaponType.plasmaCannon,
      name: 'Plasma Cannon',
      description: 'Proiettile esplosivo ad area',
      color: WeaponConstants.plasmaColor,
      fireRate: 2.0,
      damage: 3.0,
      projectileSpeed: 500.0,
    ),
    WeaponType.homing: WeaponConfig(
      type: WeaponType.homing,
      name: 'Homing Missiles',
      description: '3 missili a ricerca',
      color: WeaponConstants.homingColor,
      fireRate: 1.5,
      damage: 2.0,
      projectileSpeed: 350.0,
    ),
    WeaponType.ricochet: WeaponConfig(
      type: WeaponType.ricochet,
      name: 'Ricochet',
      description: 'Proiettile che rimbalza 5 volte',
      color: WeaponConstants.ricochetColor,
      fireRate: 6.0,
      damage: 1.0,
      projectileBounces: 5,
    ),
    WeaponType.overdrive: WeaponConfig(
      type: WeaponType.overdrive,
      name: 'Overdrive',
      description: 'Fuoco automatico ultra-rapido',
      color: WeaponConstants.overdriveColor,
      fireRate: 15.0,
      damage: 0.5,
    ),
  };

  /// Crea un'arma dal suo tipo
  static WeaponBase createWeapon(WeaponType type) {
    final config = configs[type]!;
    switch (type) {
      case WeaponType.singleShot:
        return SingleShotWeapon(config);
      case WeaponType.spreadShot:
        return SpreadShotWeapon(config);
      case WeaponType.twinShot:
        return TwinShotWeapon(config);
      case WeaponType.laser:
        return LaserWeapon(config);
      case WeaponType.plasmaCannon:
        return PlasmaCannonWeapon(config);
      case WeaponType.homing:
        return HomingWeapon(config);
      case WeaponType.ricochet:
        return RicochetWeapon(config);
      case WeaponType.overdrive:
        return OverdriveWeapon(config);
    }
  }

  /// Crea l'arma di default (single shot)
  static WeaponBase createDefaultWeapon() {
    return createWeapon(WeaponType.singleShot);
  }
}

// Le implementazioni specifiche delle armi sono nei file separati:
// - single_shot_weapon.dart
// - spread_shot_weapon.dart
// - twin_shot_weapon.dart
// - laser_weapon.dart
// - plasma_cannon_weapon.dart
// - homing_weapon.dart
// - ricochet_weapon.dart
// - overdrive_weapon.dart
