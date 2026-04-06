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
import 'systems/score_system.dart';
import 'systems/particle_system.dart';
import 'systems/wave_system.dart';
import 'entities/enemies/all_enemies.dart';

class CollisionManager extends Component {
  // Riferimenti ai sistemi (vengono imposti dal gioco)
  ScoreSystem? scoreSystem;
  ParticleSystem? particleSystem;
  WaveSystem? waveSystem;
  Player? player;

  // Callback per quando un nemico muore
  Function(Enemy enemy)? onEnemyKilled;

  @override
  void update(double dt) {
    super.update(dt);

    // Se il player è morto, non processare collisioni
    if (player == null || !player!.isAlive) return;

    // Trova tutti i proiettili e nemici attivi nel gioco
    final projectiles = parent!.children.whereType<PlayerProjectile>().toList();
    final enemies = parent!.children.whereType<Enemy>().toList();

    // 1. Controlla collisioni proiettili -> nemici
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

    // 2. Controlla collisioni nemici -> player
    for (final enemy in enemies) {
      if (!enemy.isActive) continue;

      final distance = enemy.position.distanceTo(player!.position);
      final collisionRadius = enemy.size.x / 2 + PlayerConstants.hurtboxRadius;

      if (distance < collisionRadius) {
        _onEnemyHitPlayer(enemy);
        break;
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

    // Effetto particellare
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

  /// Quando un nemico colpisce il player
  void _onEnemyHitPlayer(Enemy enemy) {
    player!.hit();

    // Effetto esplosione
    particleSystem?.explosion(
      position: player!.position.clone(),
      color: const Color(0xFFFF0000),
      count: 15,
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

    // Deforma la griglia
    // (accesso tramite il gioco principale)

    // Se è uno Splitter, crea 3 mini-splitter
    if (enemy is Splitter && enemy.level == 1) {
      _spawnSplitterChildren(enemy);
    }

    // Rimuovi il nemico
    enemy.removeFromParent();

    // Callback esterna
    onEnemyKilled?.call(enemy);
  }

  /// Crea i figli dello Splitter quando muore
  void _spawnSplitterChildren(Splitter parent) {
    for (int i = 0; i < 3; i++) {
      final angle = (i * 2 * 3.14159 / 3);
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
}
