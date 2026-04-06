// ============================================================
// GEOM - Geometry Fight 3
// ============================================================
// Cristallo che dropa dai nemici morti e può essere raccolto
// dal player per ottenere geomi (valuta di gioco).
// ============================================================

import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../data/constants.dart';

class Geom extends PositionComponent {
  int value;
  double _lifetime;
  bool _collected = false;
  bool _magnetActive = false;
  Vector2 velocity = Vector2.zero();
  double _pulseAnimation = 0;

  Geom({
    required super.position,
    this.value = 1,
    double lifetime = GeomConstants.geomLifetime,
  })  : _lifetime = lifetime,
        super(size: Vector2.all(GeomConstants.geomSize), anchor: Anchor.center);

  @override
  void update(double dt) {
    super.update(dt);
    _lifetime -= dt;
    _pulseAnimation += dt * 5;

    if (_lifetime <= 0 || _collected) {
      removeFromParent();
      return;
    }

    // Se il magnet è attivo, vola verso il player
    if (_magnetActive) {
      // La direzione verso il player viene impostata dall'esterno
      position.add(velocity * dt);
    } else {
      // Movimento iniziale con leggero drift
      velocity *= 0.95;
      position.add(velocity * dt);
    }
  }

  /// Imposta la direzione verso il player per il magnet
  void setMagnetDirection(Vector2 direction, double speed) {
    _magnetActive = true;
    velocity = direction.normalized() * speed;
  }

  void collect() {
    _collected = true;
  }

  @override
  void render(Canvas canvas) {
    if (_collected) return;

    final center = Offset(this.size.x / 2, this.size.y / 2);
    final geomSize = GeomConstants.geomSize * (1.0 + sin(_pulseAnimation) * 0.1);

    // Glow esterno
    final glowPaint = Paint()
      ..color = GeomConstants.geomColor.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(center, geomSize + 3, glowPaint);

    // Cristallo a forma di diamante
    final paint = Paint()
      ..color = GeomConstants.geomColor
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(center.dx, center.dy - geomSize)
      ..lineTo(center.dx + geomSize * 0.6, center.dy)
      ..lineTo(center.dx, center.dy + geomSize)
      ..lineTo(center.dx - geomSize * 0.6, center.dy)
      ..close();

    canvas.drawPath(path, paint);

    // Valore scritto sopra
    if (value > 1) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: '$value',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2));
    }
  }

  double get collectionRadius => GeomConstants.geomSize + 5;
}
