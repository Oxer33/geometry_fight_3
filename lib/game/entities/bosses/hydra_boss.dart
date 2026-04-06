// ============================================================
// HYDRA BOSS - Geometry Fight 3
// ============================================================
// Boss della Wave 20. Un'idra con core centrale e 4 teste.
// Meccanica: le teste devono essere distrutte tutte entro 3 secondi,
// altrimenti si rigenerano.
// ============================================================

import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../data/constants.dart';
import '../enemy.dart';
import '../projectile.dart';

class HydraBoss extends Enemy {
  // Core
  double _coreHP = BossConstants.hydraCoreHP;
  final double _coreMaxHP = BossConstants.hydraCoreHP;

  // Teste
  final List<HydraHead> _heads = [];
  final double _headMaxHP = BossConstants.hydraHeadHP;
  final int _headCount = BossConstants.hydraHeadCount;
  final double _headRegenWindow = BossConstants.hydraHeadRegenWindow;

  // Stato
  double _attackTimer = 0.0;
  double _regenTimer = 0.0;
  List<bool> _headAlive = [];
  double _rotationAngle = 0;

  // Callback
  Function(EnemyProjectile projectile)? onEnemyShoot;

  HydraBoss({required Vector2 position})
      : super(
          type: EnemyType.drone,
          position: position,
          maxHP: BossConstants.hydraCoreHP + (BossConstants.hydraHeadHP * BossConstants.hydraHeadCount),
          speed: 80.0,
          scoreValue: 10000,
          geomValue: 100,
          color: BossConstants.hydraColor,
          size: 60.0,
        ) {
    _headAlive = List.filled(_headCount, true);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Inizializza le teste
    for (int i = 0; i < _headCount; i++) {
      final head = HydraHead(
        currentHP: _headMaxHP,
        maxHP: _headMaxHP,
        index: i,
      );
      _heads.add(head);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isActive) return;

    _rotationAngle += dt * 0.3;
    _attackTimer -= dt;
    _regenTimer -= dt;

    // Aggiorna posizioni teste
    _updateHeadPositions();

    // Aggiorna teste
    for (final head in _heads) {
      head.updateState(dt);
    }

    // Attacco
    if (_attackTimer <= 0) {
      _attack();
      _attackTimer = 1.5;
    }

    // Rigenerazione teste
    if (_regenTimer <= 0) {
      _checkHeadRegen();
      _regenTimer = _headRegenWindow;
    }

    // Movimento orbitale lento
    final targetX = ArenaConstants.arenaWidth / 2 + cos(lifetime * 0.2) * 200;
    final targetY = ArenaConstants.arenaHeight / 2 + sin(lifetime * 0.3) * 200;
    velocity = (Vector2(targetX, targetY) - position) * 0.5;
  }

  void _updateHeadPositions() {
    for (int i = 0; i < _heads.length; i++) {
      if (_headAlive[i]) {
        final angle = _rotationAngle + (i * 2 * pi / _headCount);
        final radius = 80.0;
        _heads[i].offset = Vector2(cos(angle) * radius, sin(angle) * radius);
      }
    }
  }

  void _attack() {
    // Ogni testa viva spara
    for (int i = 0; i < _heads.length; i++) {
      if (_headAlive[i]) {
        final headPos = position + _heads[i].offset;
        // Sparo verso il centro dell'arena (dove dovrebbe essere il player)
        final angle = Random().nextDouble() * 2 * pi;
        final direction = Vector2(cos(angle), sin(angle));
        _shootProjectile(headPos, direction, 300);
      }
    }

    // Core sparo circolare
    final count = 8;
    for (int i = 0; i < count; i++) {
      final angle = (i * 2 * pi / count) + _rotationAngle;
      final direction = Vector2(cos(angle), sin(angle));
      _shootProjectile(position, direction, 200);
    }
  }

  void _shootProjectile(Vector2 pos, Vector2 direction, double speed) {
    if (onEnemyShoot == null) return;
    final projectile = EnemyProjectile(
      position: pos.clone(),
      direction: direction.normalized(),
      speed: speed,
    );
    onEnemyShoot!(projectile);
  }

  void _checkHeadRegen() {
    // Conta teste distrutte
    final deadHeads = <int>[];
    for (int i = 0; i < _headCount; i++) {
      if (!_headAlive[i] || _heads[i].currentHP <= 0) {
        deadHeads.add(i);
      }
    }

    // Se tutte le teste sono morte, non rigenerare (core vulnerabile)
    if (deadHeads.length == _headCount) return;

    // Rigenera teste morte
    for (final i in deadHeads) {
      _heads[i].currentHP = _headMaxHP;
      _headAlive[i] = true;
    }
  }

  /// Danneggia una testa specifica
  void damageHead(int headIndex, double damage) {
    if (headIndex < 0 || headIndex >= _headCount) return;
    _heads[headIndex].currentHP -= damage;
    if (_heads[headIndex].currentHP <= 0 && _headAlive[headIndex]) {
      _headAlive[headIndex] = false;
    }
  }

  @override
  void takeDamage(double damage) {
    // Il danno va al core solo se tutte le teste sono morte
    final allDead = _headAlive.every((alive) => !alive);
    if (allDead) {
      _coreHP -= damage;
      if (_coreHP <= 0) {
        _coreHP = 0;
        isActive = false;
        onDeath?.call(this);
        removeFromParent();
      }
    } else {
      // Altrimenti il danno si distribuisce sulle teste vive
      final aliveHeads = <int>[];
      for (int i = 0; i < _headCount; i++) {
        if (_headAlive[i]) aliveHeads.add(i);
      }
      if (aliveHeads.isNotEmpty) {
        final targetIndex = aliveHeads[Random().nextInt(aliveHeads.length)];
        damageHead(targetIndex, damage);
      }
    }
  }

  @override
  void updateAI(double dt, Vector2 playerPosition) {}

  @override
  void renderShape(Canvas canvas, Offset center, double size) {
    // Disegna le teste
    for (int i = 0; i < _heads.length; i++) {
      if (_headAlive[i] && _heads[i].currentHP > 0) {
        final headPos = center + Offset(_heads[i].offset.x, _heads[i].offset.y);
        _renderHead(canvas, headPos, _heads[i].currentHP / _headMaxHP);
      }
    }

    // Disegna il core
    _renderCore(canvas, center, size);

    // Barra HP
    _renderHealthBar(canvas, center, size);
  }

  void _renderCore(Canvas canvas, Offset center, double size) {
    final coreSize = size * 0.4;
    final allDead = _headAlive.every((alive) => !alive);

    // Glow
    final glowPaint = Paint()
      ..color = color.withValues(alpha: allDead ? 0.6 : 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(center, coreSize + 5, glowPaint);

    // Core
    final paint = Paint()
      ..color = allDead ? const Color(0xFFFF0000) : color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, coreSize, paint);

    // HP core bar
    final hpPercent = _coreHP / _coreMaxHP;
    final barWidth = coreSize * 2;
    final barHeight = 4.0;
    final barY = center.dy + coreSize + 8;

    final bgPaint = Paint()..color = const Color(0xFF333333)..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(center.dx - barWidth / 2, barY, barWidth, barHeight), bgPaint);

    final hpPaint = Paint()
      ..color = hpPercent > 0.5 ? const Color(0xFF00FF00) : const Color(0xFFFF0000)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(center.dx - barWidth / 2, barY, barWidth * hpPercent, barHeight), hpPaint);
  }

  void _renderHead(Canvas canvas, Offset pos, double hpPercent) {
    final headSize = 15.0;

    // Glow
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(pos, headSize + 3, glowPaint);

    // Testa
    final paint = Paint()
      ..color = hpPercent > 0 ? color : const Color(0xFF333333)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pos, headSize, paint);

    // HP bar testa
    final barWidth = headSize * 2;
    final barHeight = 3.0;
    final barY = pos.dy + headSize + 4;

    final bgPaint = Paint()..color = const Color(0xFF333333)..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(pos.dx - barWidth / 2, barY, barWidth, barHeight), bgPaint);

    final hpPaint = Paint()
      ..color = hpPercent > 0.5 ? const Color(0xFF00FF00) : const Color(0xFFFF0000)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(pos.dx - barWidth / 2, barY, barWidth * hpPercent, barHeight), hpPaint);
  }

  void _renderHealthBar(Canvas canvas, Offset center, double size) {
    final barWidth = size * 2;
    final barHeight = 8.0;
    final barY = center.dy - size - 25;

    final bgPaint = Paint()..color = const Color(0xFF333333)..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(center.dx - barWidth / 2, barY, barWidth, barHeight), bgPaint);

    final totalHP = _coreHP + _heads.fold<double>(0, (sum, h) => sum + h.currentHP);
    final maxTotalHP = _coreMaxHP + (_headMaxHP * _headCount);
    final hpPercent = totalHP / maxTotalHP;

    final hpPaint = Paint()
      ..color = hpPercent > 0.5 ? const Color(0xFF00FF88) : const Color(0xFFFF0000)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(center.dx - barWidth / 2, barY, barWidth * hpPercent, barHeight), hpPaint);
  }

  @override
  double get hpPercent {
    final totalHP = _coreHP + _heads.fold<double>(0, (sum, h) => sum + h.currentHP);
    final maxTotalHP = _coreMaxHP + (_headMaxHP * _headCount);
    return totalHP / maxTotalHP;
  }
}

/// Singola testa dell'Hydra
class HydraHead {
  double currentHP;
  final double maxHP;
  final int index;
  Vector2 offset = Vector2.zero();

  HydraHead({required this.currentHP, required this.maxHP, required this.index});

  void updateState(double dt) {
    // Animazione pulsazione
  }
}
