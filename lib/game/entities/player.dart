// ============================================================
// PLAYER - Geometry Fight 3
// ============================================================
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../data/constants.dart';
import '../../data/models/save_data.dart';

enum PlayerState { alive, invincible, dead }

class Player extends PositionComponent {
  final SaveData saveData;
  PlayerState _state = PlayerState.alive;
  int _lives = PlayerConstants.startingLives;
  int _bombs = PlayerConstants.startingBombs;
  Vector2 _aimDirection = Vector2(1, 0);
  Vector2 _velocity = Vector2.zero();
  double _invincibilityTimer = 0.0;
  double _fireTimer = 0.0;
  double _thrusterAnimation = 0.0;
  final Color _color = PlayerConstants.playerColor;
  // Lista proiettili attivi - gestita dal sistema di collisione

  Function()? onHit;
  Function()? onDeath;
  Function(Vector2 position, Vector2 direction)? onShoot;

  Player({required super.position, required this.saveData})
      : super(size: Vector2.all(PlayerConstants.playerRadius * 2), anchor: Anchor.center);

  @override
  Future<void> onLoad() async { _applyUpgrades(); }

  @override
  void update(double dt) {
    super.update(dt);
    _thrusterAnimation += dt * 10;
    if (_state == PlayerState.invincible) { _invincibilityTimer -= dt; if (_invincibilityTimer <= 0) _state = PlayerState.alive; }
    if (_fireTimer > 0) _fireTimer -= dt;
    position.add(_velocity * dt);
    position.x = position.x.clamp(0.0, ArenaConstants.arenaWidth);
    position.y = position.y.clamp(0.0, ArenaConstants.arenaHeight);
    _velocity *= 0.92;
  }

  void _applyUpgrades() {
    final livesUpgrade = saveData.getUpgradeLevel('starting_lives');
    _lives = PlayerConstants.startingLives + livesUpgrade;
    final bombUpgrade = saveData.getUpgradeLevel('bomb_capacity');
    _bombs = PlayerConstants.startingBombs + bombUpgrade;
  }

  void move(Vector2 direction) {
    if (_state == PlayerState.dead) return;
    final speedUpgrade = saveData.getUpgradeLevel('speed');
    final speedMultiplier = 1.0 + (speedUpgrade * 0.10);
    final speed = PlayerConstants.baseSpeed * speedMultiplier;
    if (direction.length2 > 0) _velocity = direction.normalized() * speed;
  }

  void aim(Vector2 direction) { if (direction.length2 > 0) _aimDirection = direction.normalized(); }

  void shoot() {
    if (_state == PlayerState.dead || _fireTimer > 0) return;
    final fireRateUpgrade = saveData.getUpgradeLevel('fire_rate');
    final fireRateMultiplier = 1.0 + (fireRateUpgrade * 0.08);
    final fireInterval = 1.0 / (PlayerConstants.baseFireRate * fireRateMultiplier);
    _fireTimer = fireInterval;
    final projectilePosition = position.clone();
    onShoot?.call(projectilePosition, _aimDirection.clone());
  }

  void useBomb() { if (_bombs <= 0 || _state == PlayerState.dead) return; _bombs--; }

  void hit() {
    if (_state == PlayerState.invincible || _state == PlayerState.dead) return;
    _lives--; onHit?.call();
    if (_lives <= 0) { _state = PlayerState.dead; onDeath?.call(); }
    else { _state = PlayerState.invincible; _invincibilityTimer = PlayerConstants.invincibilityDuration; }
  }

  void respawn(Vector2 position) {
    this.position = position.clone(); _lives = PlayerConstants.startingLives; _bombs = PlayerConstants.startingBombs;
    _state = PlayerState.invincible; _invincibilityTimer = PlayerConstants.invincibilityDuration; _velocity = Vector2.zero();
  }

  @override
  void render(Canvas canvas) {
    if (_state == PlayerState.invincible && sin(_invincibilityTimer * 20) <= 0) return;
    if (_state == PlayerState.dead) return;
    final center = Offset(size.x / 2, size.y / 2);
    final radius = PlayerConstants.playerRadius;
    final glowPaint = Paint()..color = _color.withValues(alpha: 0.4)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(center, radius + 4, glowPaint);
    final paint = Paint()..color = _color..style = PaintingStyle.fill;
    final path = Path()..moveTo(center.dx + radius, center.dy)
      ..lineTo(center.dx - radius * cos(pi / 3), center.dy - radius * sin(pi / 3))
      ..lineTo(center.dx - radius * cos(pi / 3), center.dy + radius * sin(pi / 3))..close();
    canvas.drawPath(path, paint);
    // Thruster
    final thrusterLength = radius * (0.5 + sin(_thrusterAnimation) * 0.3);
    final thrusterWidth = radius * 0.3;
    final thrusterPaint = Paint()..color = const Color(0xFFFF6600).withValues(alpha: 0.8)..style = PaintingStyle.fill;
    final thrusterPath = Path()..moveTo(center.dx - radius * 0.8, center.dy - thrusterWidth)
      ..lineTo(center.dx - radius * 0.8 - thrusterLength, center.dy)
      ..lineTo(center.dx - radius * 0.8, center.dy + thrusterWidth)..close();
    canvas.drawPath(thrusterPath, thrusterPaint);
  }

  bool get isAlive => _state != PlayerState.dead;
  int get lives => _lives;
  int get bombs => _bombs;
  Vector2 get aimDirection => _aimDirection;
  PlayerState get state => _state;
  double get hurtboxRadius => PlayerConstants.hurtboxRadius;
}
