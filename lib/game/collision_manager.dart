// ============================================================
// COLLISION MANAGER - Geometry Fight 3
// ============================================================
// Gestisce le collisioni tra proiettili e nemici, e tra nemici e player.
// Usa un approccio diretto di distance checking per semplicità.
// ============================================================

import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../data/constants.dart';
import 'entities/player.dart';
import 'entities/enemy.dart';
import 'entities/projectile.dart';
import 'entities/geom.dart';
import 'systems/score_system.dart';
import 'systems/particle_system.dart';
import 'systems/wave_system.dart';
import 'entities/enemies/all_enemies.dart';
import 'geometry_fight_game.dart';

class CollisionManager extends Component {
  // Riferimenti ai sistemi (vengono imposti dal gioco)
  ScoreSystem? scoreSystem;
  ParticleSystem? particleSystem;
  WaveSystem? waveSystem;
  Player? player;
  GeometryFightGame? game;

  // Random per drop
  final Random _random = Random();

  @override
  void update(double dt) {
    super.update(dt);

    // Se il player è morto, non processare collisioni
    if (player == null || !player!.isAlive) return;

    // Trova tutti i proiettili, nemici e geom attivi nel gioco
    final projectiles = parent!.children.whereType<PlayerProjectile>().toList();
    final enemyProjectiles = parent!.children.whereType<EnemyProjectile>().toList();
    final enemies = parent!.children.whereType<Enemy>().toList();
    final geoms = parent!.children.whereType<Geom>().toList();

    // 1. Controlla collisioni proiettili player -> nemici
    for (final projectile in projectiles) {
      if (!projectile.isActive) continue;

      for (final enemy in enemies) {
        if (!enemy.isActive) continue;

        final distance = projectile.position.distanceTo(enemy.position);
        final collisionRadius = projectile.size.x / 2 + enemy.size.x / 2;

        if (distance < collisionRadius) {
          // Collisione rilevata!
          _onProjectileHitEnemy(projectile, enemy);
          break; // Un proiettile può colpire un solo nemico per frame
        }
      }
    }

    // 2. Controlla collisioni proiettili nemici -> player
    for (final projectile in enemyProjectiles) {
      final distance = projectile.position.distanceTo(player!.position);
      final collisionRadius = projectile.size.x / 2 + PlayerConstants.hurtboxRadius;

      if (distance < collisionRadius) {
        _onEnemyProjectileHitPlayer(projectile);
      }
    }

    // 3. Controlla collisioni nemici -> player
    for (final enemy in enemies) {
      if (!enemy.isActive) continue;

      final distance = enemy.position.distanceTo(player!.position);
      final collisionRadius = enemy.size.x / 2 + PlayerConstants.hurtboxRadius;

      if (distance < collisionRadius) {
        _onEnemyHitPlayer(enemy);
        break;
      }
    }

    // 4. Controlla collisioni geom -> player (raccolta)
    for (final geom in geoms) {
      if (geom.isRemoved) continue;

      final distance = geom.position.distanceTo(player!.position);
      final collectionRadius = geom.collectionRadius + PlayerConstants.playerRadius;

      if (distance < collectionRadius) {
        _onGeomCollected(geom);
      }
    }
  }

  // ============================================================
  // GESTIONE COLLISIONI
  // ============================================================

  /// Quando un proiettile colpisce un nemico
  void _onProjectileHitEnemy(PlayerProjectile projectile, Enemy enemy) {
    // Disattiva il proiettile
    projectile.isActive = false;
    projectile.removeFromParent();

    // Danneggia il nemico
    enemy.takeDamage(1.0);

    // Effetto particellare piccolo
    particleSystem?.explosion(
      position: enemy.position.clone(),
      color: enemy.color,
      count: 5,
    );

    // Se il nemico è morto
    if (!enemy.isActive) {
      _onEnemyKilled(enemy);
    }
  }

  /// Quando un proiettile nemico colpisce il player
  void _onEnemyProjectileHitPlayer(EnemyProjectile projectile) {
    if (player!.state == PlayerState.invincible || player!.state == PlayerState.dead) return;

    projectile.removeFromParent();
    player!.hit();

    // Screen shake
    game?.startShake(intensity: 8.0, duration: 0.2);

    // Effetto esplosione
    particleSystem?.explosion(
      position: player!.position.clone(),
      color: const Color(0xFFFF0000),
      count: 10,
    );
  }

  /// Quando un nemico colpisce il player
  void _onEnemyHitPlayer(Enemy enemy) {
    player!.hit();

    // Screen shake
    game?.startShake(intensity: 10.0, duration: 0.3);

    // Effetto esplosione
    particleSystem?.explosion(
      position: player!.position.clone(),
      color: const Color(0xFFFF0000),
      count: 15,
    );
  }

  /// Quando un geom viene raccolto
  void _onGeomCollected(Geom geom) {
    geom.collect();
    scoreSystem?.collectGeom(geom.value);
    particleSystem?.explosion(
      position: geom.position.clone(),
      color: GeomConstants.geomColor,
      count: 3,
    );
  }

  /// Quando un nemico viene ucciso
  void _onEnemyKilled(Enemy enemy) {
    // Aggiungi punteggio
    scoreSystem?.addKillScore(enemy.scoreValue);

    // Notifica il wave system
    waveSystem?.onEnemyKilled();

    // Effetto esplosione grande
    particleSystem?.explosion(
      position: enemy.position.clone(),
      color: enemy.color,
      count: 20,
    );

    // Screen shake piccolo
    game?.startShake(intensity: 3.0, duration: 0.15);

    // Deforma la griglia
    // (accesso tramite il gioco principale)

    // Drop geom
    _dropGeoms(enemy);

    // Se è uno Splitter, crea 3 mini-splitter
    if (enemy is Splitter && enemy.level == 1) {
      _spawnSplitterChildren(enemy);
    }

    // Rimuovi il nemico
    enemy.removeFromParent();
  }

  /// Crea i figli dello Splitter quando muore
  void _spawnSplitterChildren(Splitter parent) {
    for (int i = 0; i < 3; i++) {
      final angle = (i * 2 * pi / 3);
      final offset = Vector2(cos(angle), sin(angle)) * 30;
      final child = Splitter(
        position: parent.position.clone() + offset,
        level: 2,
      );
      child.onDeath = (deadEnemy) {
        _onEnemyKilled(deadEnemy);
      };
      parent.parent?.add(child);
    }
  }

  /// Drop di geom quando un nemico muore
  void _dropGeoms(Enemy enemy) {
    final dropChance = PowerUpConstants.powerUpSpawnChance * 2; // 10% chance
    final geomCount = _random.nextDouble() < dropChance ? 2 : 1;

    for (int i = 0; i < geomCount; i++) {
      // Offset casuale dalla posizione del nemico
      final angle = _random.nextDouble() * 2 * pi;
      final distance = _random.nextDouble() * 30;
      final offset = Vector2(cos(angle) * distance, sin(angle) * distance);

      final geom = Geom(
        position: enemy.position.clone() + offset,
        value: enemy.geomValue,
      );

      // Velocità iniziale casuale (effetto esplosione)
      geom.velocity = Vector2(
        cos(angle) * 100,
        sin(angle) * 100,
      );

      parent?.add(geom);
    }
  }
}
