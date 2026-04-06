// ============================================================
// PARTICLE SYSTEM - Geometry Fight 3
// ============================================================
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../data/constants.dart';
import '../../utils/object_pool.dart';

class Particle {
  Vector2 position;
  Vector2 velocity;
  Color color;
  double size;
  double lifetime;
  double maxLifetime;
  bool isActive = false;
  Particle({required this.position, required this.velocity, required this.color, required this.size, required this.lifetime, required this.maxLifetime});
  void reset() { position = Vector2.zero(); velocity = Vector2.zero(); color = Colors.white; size = 1.0; lifetime = 0.0; maxLifetime = 1.0; isActive = false; }
  double get alpha => (lifetime / maxLifetime).clamp(0.0, 1.0);
}

class ParticleSystem extends Component {
  late ObjectPool<Particle> _particlePool;
  final List<Particle> _activeParticles = [];
  final Random _random = Random();

  @override
  Future<void> onLoad() async {
    _particlePool = ObjectPool<Particle>(factory: () => Particle(position: Vector2.zero(), velocity: Vector2.zero(), color: Colors.white, size: 1.0, lifetime: 0.0, maxLifetime: 1.0), initialSize: EffectConstants.maxParticles, maxSize: EffectConstants.maxParticles, onRelease: (p) => p.reset());
  }

  @override
  void update(double dt) {
    for (int i = _activeParticles.length - 1; i >= 0; i--) {
      final p = _activeParticles[i];
      p.lifetime -= dt;
      if (p.lifetime <= 0) { _particlePool.release(p); _activeParticles.removeAt(i); }
      else { p.position.add(p.velocity * dt); p.velocity.scale(0.98); }
    }
  }

  void emit({required Vector2 position, required Color color, int count = 10, double speed = 100.0, double size = 4.0, double lifetime = 0.5}) {
    for (int i = 0; i < count; i++) {
      if (_activeParticles.length >= EffectConstants.maxParticles) { final oldest = _activeParticles.removeAt(0); _particlePool.release(oldest); }
      final angle = _random.nextDouble() * 2 * pi;
      final particleSpeed = speed * (0.5 + _random.nextDouble() * 0.5);
      final particle = _particlePool.acquire();
      particle.position = position.clone(); particle.velocity = Vector2(cos(angle) * particleSpeed, sin(angle) * particleSpeed);
      particle.color = color; particle.size = size * (0.5 + _random.nextDouble() * 0.5);
      particle.lifetime = lifetime * (0.5 + _random.nextDouble() * 0.5); particle.maxLifetime = particle.lifetime; particle.isActive = true;
      _activeParticles.add(particle);
    }
  }

  void explosion({required Vector2 position, required Color color, int count = 20}) { emit(position: position, color: color, count: count, speed: 200.0, size: 6.0, lifetime: 0.3); }
  void trail({required Vector2 position, required Color color, int count = 3}) { emit(position: position, color: color, count: count, speed: 20.0, size: 3.0, lifetime: 0.15); }

  @override
  void render(Canvas canvas) {
    for (final p in _activeParticles) {
      final paint = Paint()..color = p.color.withValues(alpha: p.alpha)..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(p.position.x, p.position.y), p.size * p.alpha, paint);
    }
  }

  int get activeCount => _activeParticles.length;
  void clear() { _particlePool.releaseAll(); _activeParticles.clear(); }
}
