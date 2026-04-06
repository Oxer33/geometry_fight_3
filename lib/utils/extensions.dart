// ============================================================
// EXTENSIONS - Geometry Fight 3
// ============================================================
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

extension Vector2Extensions on Vector2 {
  Vector2 randomWithin(double radius) { final angle = Random().nextDouble() * 2 * pi; final distance = Random().nextDouble() * radius; return Vector2(cos(angle) * distance, sin(angle) * distance); }
  double angleTo(Vector2 other) { final diff = other - this; return atan2(diff.y, diff.x); }
  Vector2 normalizedTo(double length) { if (length == 0) return Vector2.zero(); final c = clone(); c.normalize(); c.scale(length); return c; }
  Vector2 clampLength(double maxLength) { final currentLength = length; if (currentLength > maxLength) { final c = clone(); c.scale(maxLength / currentLength); return c; } return this; }
  Vector2 lerpTo(Vector2 target, double t) => this + (target - this) * t;
  bool isWithin(double distance, Vector2 other) => distanceToSquared(other) <= distance * distance;
  Vector2 reflect(Vector2 normal) => this - normal * 2 * dot(normal);
}

extension ColorExtensions on Color {
  Color lighter(double amount) {
    final redVal = (r * 255.0 + (255 * amount)).clamp(0, 255).toInt();
    final greenVal = (g * 255.0 + (255 * amount)).clamp(0, 255).toInt();
    final blueVal = (b * 255.0 + (255 * amount)).clamp(0, 255).toInt();
    final alphaVal = (a * 255.0).round().clamp(0, 255);
    return Color.fromARGB(alphaVal, redVal, greenVal, blueVal);
  }
  Color darker(double amount) {
    final redVal = (r * 255.0 * (1 - amount)).clamp(0, 255).toInt();
    final greenVal = (g * 255.0 * (1 - amount)).clamp(0, 255).toInt();
    final blueVal = (b * 255.0 * (1 - amount)).clamp(0, 255).toInt();
    final alphaVal = (a * 255.0).round().clamp(0, 255);
    return Color.fromARGB(alphaVal, redVal, greenVal, blueVal);
  }
  Color withAlphaValue(int alpha) {
    final redVal = (r * 255.0).round().clamp(0, 255);
    final greenVal = (g * 255.0).round().clamp(0, 255);
    final blueVal = (b * 255.0).round().clamp(0, 255);
    return Color.fromARGB(alpha, redVal, greenVal, blueVal);
  }
}

extension DoubleExtensions on double {
  double clampTo(double min, double max) => clamp(min, max).toDouble();
  double get degreesToRadians => this * (pi / 180.0);
  double get radiansToDegrees => this * (180.0 / pi);
  double lerpTo(double end, double t) => this + (end - this) * t;
  double get randomUpTo => Random().nextDouble() * this;
  bool isNear(double other, {double tolerance = 0.001}) => (this - other).abs() < tolerance;
}

extension IntExtensions on int {
  double get toDoubleVal => toDouble();
  String formatScore() => toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
}

double angleBetween(Vector2 from, Vector2 to) => atan2(to.y - from.y, to.x - from.x);
double distanceBetween(Vector2 a, Vector2 b) => sqrt(pow(b.x - a.x, 2) + pow(b.y - a.y, 2));
double lerp(double a, double b, double t) => a + (b - a) * t;
double clampValue(double value, double min, double max) { if (value < min) return min; if (value > max) return max; return value; }
Color randomNeonColor() { final random = Random(); final hue = random.nextDouble() * 360; return HSLColor.fromAHSL(1.0, hue, 0.9, 0.6).toColor(); }
