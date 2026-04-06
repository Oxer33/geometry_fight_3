// ============================================================
// POWERUP SYSTEM - Geometry Fight 3
// ============================================================
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../data/constants.dart';

enum PowerUpType { rapidFire, spreadShot, shield, magnet, timeSlow, overdrive, bombRecharge, scoreMultiplier }

extension PowerUpTypeExtensions on PowerUpType {
  Color get color {
    switch (this) {
      case PowerUpType.rapidFire: return PowerUpConstants.rapidFireColor;
      case PowerUpType.spreadShot: return PowerUpConstants.spreadShotColor;
      case PowerUpType.shield: return PowerUpConstants.shieldColor;
      case PowerUpType.magnet: return PowerUpConstants.magnetColor;
      case PowerUpType.timeSlow: return PowerUpConstants.timeSlowColor;
      case PowerUpType.overdrive: return PowerUpConstants.overdriveColor;
      case PowerUpType.bombRecharge: return PowerUpConstants.bombRechargeColor;
      case PowerUpType.scoreMultiplier: return PowerUpConstants.scoreMultiplierColor;
    }
  }
  String get name {
    switch (this) {
      case PowerUpType.rapidFire: return 'Rapid Fire';
      case PowerUpType.spreadShot: return 'Spread Shot';
      case PowerUpType.shield: return 'Shield';
      case PowerUpType.magnet: return 'Magnet';
      case PowerUpType.timeSlow: return 'Time Slow';
      case PowerUpType.overdrive: return 'Overdrive';
      case PowerUpType.bombRecharge: return 'Bomb +1';
      case PowerUpType.scoreMultiplier: return '2x Score';
    }
  }
}

class ActivePowerUp {
  final PowerUpType type;
  double remainingTime;
  final double duration;
  ActivePowerUp({required this.type, this.duration = PowerUpConstants.powerUpDuration}) : remainingTime = duration;
  void update(double dt) { remainingTime -= dt; }
  bool get isExpired => remainingTime <= 0;
  double get percentRemaining => remainingTime / duration;
}

class PowerUpSystem extends Component {
  final List<ActivePowerUp> _activePowerUps = [];
  final Random _random = Random();
  Function(PowerUpType type)? onPowerUpCollected;
  Function(PowerUpType type)? onPowerUpExpired;

  @override
  void update(double dt) {
    for (int i = _activePowerUps.length - 1; i >= 0; i--) {
      final powerUp = _activePowerUps[i];
      powerUp.update(dt);
      if (powerUp.isExpired) { onPowerUpExpired?.call(powerUp.type); _activePowerUps.removeAt(i); }
    }
  }

  void activatePowerUp(PowerUpType type) { _activePowerUps.removeWhere((p) => p.type == type); _activePowerUps.add(ActivePowerUp(type: type)); onPowerUpCollected?.call(type); }
  bool isPowerUpActive(PowerUpType type) { return _activePowerUps.any((p) => p.type == type); }
  ActivePowerUp? getActivePowerUp(PowerUpType type) { final list = _activePowerUps.where((p) => p.type == type); return list.isNotEmpty ? list.first : null; }
  bool shouldSpawnPowerUp() { return _random.nextDouble() < PowerUpConstants.powerUpSpawnChance; }
  PowerUpType getRandomPowerUpType() { final values = PowerUpType.values; return values[_random.nextInt(values.length)]; }
  List<ActivePowerUp> get activePowerUps => List.unmodifiable(_activePowerUps);
  void clear() { _activePowerUps.clear(); }
}
