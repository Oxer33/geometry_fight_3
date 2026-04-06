// ============================================================
// COSTANTI GLOBALI - Geometry Fight 3
// ============================================================
// Questo file contiene tutte le costanti utilizzate nel gioco.
// Centralizzare i valori qui rende il bilanciamento più facile.
// ============================================================

import 'package:flutter/material.dart';

// --- Dimensioni Arena ---
class ArenaConstants {
  static const double arenaWidth = 3000.0;
  static const double arenaHeight = 3000.0;
  static const double wallBounceCount = 2.0; // Rimbalzi massimi proiettili
  static const double spawnPadding = 200.0; // Padding spawn fuori schermo
}

// --- Configurazione Player ---
class PlayerConstants {
  static const double baseSpeed = 400.0; // Unità/s
  static const double playerRadius = 16.0; // Dimensione visiva
  static const double hurtboxRadius = 8.0; // Hurtbox più piccola (fair)
  static const int startingLives = 3;
  static const double invincibilityDuration = 2.0; // Secondi dopo respawn
  static const double baseFireRate = 8.0; // Colpi al secondo
  static const int maxBombs = 3;
  static const int startingBombs = 1;
  static const double cameraLerp = 0.08; // Smoothing camera
  static const Color playerColor = Color(0xFF00FFFF); // Ciano neon
}

// --- Configurazione Proiettili Player ---
class ProjectileConstants {
  static const double bulletWidth = 4.0;
  static const double bulletHeight = 8.0;
  static const double bulletSpeed = 700.0; // Unità/s
  static const double bulletLifetime = 2.0; // Secondi prima dissoluzione
  static const double bulletBounceCount = 2.0; // Rimbalzi massimi
  static const Color bulletColor = Color(0xFFFFE500); // Giallo neon
}

// --- Configurazione Nemici ---
class EnemyConstants {
  // DRONE
  static const double droneHP = 1.0;
  static const double droneSpeed = 180.0;
  static const int droneScore = 50;
  static const int droneGeoms = 1;
  static const Color droneColor = Color(0xFFFF00AA); // Rosa
  static const double droneSize = 18.0;

  // SNAKE
  static const double snakeHeadHP = 1.0;
  static const double snakeSpeed = 120.0;
  static const int snakeScorePerSegment = 100;
  static const int snakeSegmentCount = 8;
  static const double snakeSegmentGap = 14.0;
  static const Color snakeHeadColor = Color(0xFF00FF44); // Verde
  static const Color snakeBodyColor = Color(0xFF00AA33);
  static const double snakeSize = 16.0;

  // MINE
  static const double mineHP = 2.0;
  static const int mineScore = 75;
  static const double mineExplosionRadius = 100.0;
  static const double mineTriggerRadius = 80.0;
  static const double mineDetonDelay = 0.5; // Secondi prima esplosione
  static const Color mineColor = Color(0xFF888888); // Grigio
  static const double mineSize = 20.0;

  // SPAWNER
  static const double spawnerHP = 15.0;
  static const double spawnerSpeed = 60.0;
  static const int spawnerScore = 500;
  static const double spawnerSpawnInterval = 3.0; // Secondi
  static const int spawnerSpawnCount = 2; // Drone generati
  static const Color spawnerColor = Color(0xFFFF8800); // Arancione
  static const double spawnerSize = 30.0;

  // WEAVER
  static const double weaverHP = 2.0;
  static const double weaverSpeed = 220.0;
  static const int weaverScore = 150;
  static const double weaverSineAmplitude = 60.0;
  static const double weaverSineFrequency = 0.8;
  static const Color weaverColor = Color(0xFF00AAFF); // Azzurro
  static const double weaverSize = 20.0;

  // BOUNCER
  static const double bouncerHP = 3.0;
  static const double bouncerBaseSpeed = 200.0;
  static const double bouncerMaxSpeed = 500.0;
  static const double bouncerSpeedIncrease = 20.0; // Per rimbalzo
  static const int bouncerScore = 200;
  static const Color bouncerColor = Color(0xFFFFDD00); // Giallo
  static const double bouncerSize = 22.0;

  // SPLITTER
  static const double splitterHP = 1.0;
  static const double splitterSpeed = 220.0;
  static const int splitterScoreLarge = 50;
  static const int splitterScoreMedium = 100;
  static const int splitterScoreSmall = 300;
  static const int splitCount = 3;
  static const Color splitterColor = Color(0xFFFFFFFF); // Bianco
  static const double splitterSizeLarge = 28.0;
  static const double splitterSizeMedium = 18.0;
  static const double splitterSizeSmall = 10.0;

  // SHIELD ENEMY
  static const double shieldEnemyHP = 3.0;
  static const double shieldHP = 5.0;
  static const double shieldRegenTime = 4.0;
  static const double shieldEnemySpeed = 150.0;
  static const int shieldEnemyScore = 350;
  static const Color shieldEnemyColor = Color(0xFF9900FF); // Viola
  static const double shieldEnemySize = 24.0;

  // BLACK HOLE
  static const double blackHoleHP = 20.0;
  static const double blackHoleSpeed = 10.0;
  static const int blackHoleScore = 1000;
  static const int blackHoleGeoms = 10;
  static const double blackHoleGravityRadius = 250.0;
  static const double blackHoleGravityForce = 800.0;
  static const double blackHoleAbsorbRadius = 60.0;
  static const Color blackHoleColor = Color(0xFF660000); // Rosso scuro
  static const double blackHoleSize = 30.0;

  // KAMIKAZE
  static const double kamikazeHP = 1.0;
  static const double kamikazeChargeSpeed = 800.0;
  static const double kamikazeIdleDuration = 1.5; // Secondi telegrafo
  static const int kamikazeScore = 100;
  static const Color kamikazeColor = Color(0xFFFF2200); // Rosso
  static const double kamikazeSize = 16.0;
}

// --- Configurazione Boss ---
class BossConstants {
  // THE GRID (Wave 10)
  static const double gridHP = 500.0;
  static const double gridPhase1Threshold = 0.6; // 60% HP
  static const double gridPhase2Threshold = 0.3; // 30% HP
  static const double gridSize = 200.0;
  static const Color gridColor = Color(0xFFFFFFFF);

  // HYDRA (Wave 20)
  static const double hydraCoreHP = 200.0;
  static const double hydraHeadHP = 150.0;
  static const int hydraHeadCount = 4;
  static const double hydraHeadRegenTime = 5.0;
  static const double hydraHeadRegenWindow = 3.0; // Devono morire entro 3s
  static const Color hydraColor = Color(0xFF00FF88);

  // SINGULARITY (Wave 30)
  static const double singularityHP = 1200.0;
  static const double singularityPulseInterval = 3.0;
  static const double singularityPullInterval = 5.0;
  static const Color singularityColor = Color(0xFF00FF00);

  // SWARM MOTHER (Wave 40)
  static const double swarmMotherHP = 2000.0;
  static const double swarmMotherPhase1Threshold = 0.75;
  static const double swarmMotherPhase2Threshold = 0.5;
  static const double swarmMotherPhase3Threshold = 0.2;
  static const double swarmMotherBerserkThreshold = 0.2;
  static const Color swarmMotherColor = Color(0xFFFF00FF);
}

// --- Configurazione Power-Up ---
class PowerUpConstants {
  static const double powerUpDuration = 15.0; // Secondi durata
  static const double powerUpSize = 20.0;
  static const double powerUpSpawnChance = 0.05; // 5% drop rate
  static const double powerUpLifetime = 10.0; // Secondi prima dissoluzione

  // Colori per tipo
  static const Color rapidFireColor = Color(0xFFFF4400);
  static const Color spreadShotColor = Color(0xFFFF8800);
  static const Color shieldColor = Color(0xFF00FFFF);
  static const Color magnetColor = Color(0xFFFFEE00);
  static const Color timeSlowColor = Color(0xFFAA00FF);
  static const Color overdriveColor = Color(0xFFFFFFFF);
  static const Color bombRechargeColor = Color(0xFF00FF44);
  static const Color scoreMultiplierColor = Color(0xFFFFD700);
}

// --- Configurazione Geomi ---
class GeomConstants {
  static const double geomSize = 12.0;
  static const double geomLifetime = 8.0; // Secondi prima dissoluzione
  static const double geomMagnetRadius = 400.0;
  static const double geomMagnetSpeed = 500.0;
  static const Color geomColor = Color(0xFF00FF88);
}

// --- Configurazione Score ---
class ScoreConstants {
  static const double multiplierIncrement = 0.1;
  static const double multiplierMax = 20.0;
  static const int comboKillCount = 5; // Kill in 0.5s per combo
  static const double comboTimeWindow = 0.5;
  static const int perfectWaveBonus = 2; // Moltiplicatore geomi
}

// --- Configurazione Armi ---
class WeaponConstants {
  // SPREAD SHOT
  static const int spreadCount = 5;
  static const double spreadAngle = 30.0; // Gradi totali

  // LASER
  static const double laserWidth = 3.0;
  static const double laserDPS = 100.0; // Danno per secondo

  // PLASMA CANNON
  static const double plasmaExplosionRadius = 80.0;
  static const Color plasmaColor = Color(0xFFCC00FF);

  // RICOCHET
  static const int ricochetBounces = 5;
  static const double ricochetSpeedIncrease = 1.2;
  static const Color ricochetColor = Color(0xFF00FF88);

  // HOMING
  static const int homingMissileCount = 3;
  static const double homingReload = 0.5;
  static const Color homingColor = Color(0xFF00FFFF);

  // TWIN SHOT
  static const double twinOffset = 12.0;
  static const Color twinColor = Color(0xFFFFFFFF);

  // OVERDRIVE
  static const double overdriveDuration = 3.0;
  static const Color overdriveColor = Color(0xFFFFFFFF);
}

// --- Configurazione Griglia ---
class GridConstants {
  static const double gridSpacing = 60.0; // Spaziatura linee
  static const double gridOpacity = 0.15;
  static const Color gridColor = Color(0xFF4488FF); // Azzurro/bianco
  static const double gridSpringStrength = 5.0; // Forza ritorno posizione
  static const double gridDamping = 0.85; // Smorzamento oscillazione
  static const double gridExplosionForce = 100.0; // Forza deformazione esplosione
}

// --- Configurazione Effetti ---
class EffectConstants {
  // Screen Shake
  static const double screenShakeMagnitude = 4.0; // Pixel
  static const double screenShakeDuration = 0.2; // Secondi

  // Chromatic Aberration
  static const double chromaticDuration = 0.05;

  // Slow-mo
  static const double slowMoTimeScale = 0.3;
  static const double slowMoDuration = 0.5;

  // Warp Lines
  static const double warpDuration = 0.3;

  // Pulse Ring
  static const double pulseRingDuration = 0.4;

  // Esplosione
  static const double explosionParticleCount = 20.0;
  static const double explosionDuration = 0.3;

  // Particelle
  static const int maxParticles = 300;
}

// --- Configurazione Audio ---
class AudioConstants {
  static const double bgmVolumeDefault = 0.7;
  static const double sfxVolumeDefault = 0.8;
}

// --- Configurazione Shop ---
class ShopConstants {
  // Upgrade prezzi
  static const int firepowerPrices = 100;
  static const int speedPrices = 100;
  static const int fireRatePrices = 100;
  static const int shieldCapacityPrices = 300;
  static const int startingLivesPrices = 500;
  static const int bombCapacityPrices = 400;
  static const int magnetRangePrices = 250;
  static const int xpBoostPrices = 300;

  // Prezzi modalità
  static const int bossRushPrice = 2000;
  static const int survivalPrice = 2500;
  static const int challengePrice = 3000;

  // Prezzi skin
  static const int stealthSkinPrice = 500;
  static const int crystalSkinPrice = 1000;
  static const int ghostSkinPrice = 1500;
  static const int omegaSkinPrice = 3000;
}

// --- Configurazione Wave ---
class WaveConstants {
  static const double wavePauseDuration = 3.0; // Secondi tra onde
  static const int bossWaveInterval = 10; // Boss ogni 10 onde
  static const double difficultyScaling = 0.1; // +10% difficoltà per onda
  static const double spawnInterval = 0.5; // Secondi tra spawn di nemici
}
