// ============================================================
// GRID DISTORTION - Geometry Fight 3
// ============================================================
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../data/constants.dart';

class GridNode {
  final Vector2 restPosition;
  Vector2 currentPosition;
  Vector2 velocity;
  GridNode({required this.restPosition}) : currentPosition = restPosition.clone(), velocity = Vector2.zero();
  void applyForce(Vector2 force) { velocity.add(force); }
  void update(double dt) {
    final displacement = currentPosition - restPosition;
    velocity.add(displacement * -GridConstants.gridSpringStrength * dt);
    velocity.scale(GridConstants.gridDamping);
    currentPosition.add(velocity * dt);
  }
  double get displacementMagnitude => (currentPosition - restPosition).length;
}

class GridDistortion extends Component {
  final List<List<GridNode>> _nodes = [];
  Vector2 _screenSize = Vector2.zero();
  final double spacing = GridConstants.gridSpacing;
  int get columns => (_screenSize.x / spacing).ceil() + 1;
  int get rows => (_screenSize.y / spacing).ceil() + 1;

  GridDistortion({required Vector2 size}) { _screenSize = size.clone(); _initializeGrid(); }

  void _initializeGrid() {
    _nodes.clear();
    for (int y = 0; y < rows; y++) {
      final row = <GridNode>[];
      for (int x = 0; x < columns; x++) { row.add(GridNode(restPosition: Vector2(x * spacing, y * spacing))); }
      _nodes.add(row);
    }
  }

  void applyExplosionForce(Vector2 position, double force) {
    final explosionForce = force * GridConstants.gridExplosionForce;
    for (final row in _nodes) { for (final node in row) { final diff = node.restPosition - position; final distance = diff.length; if (distance < 300 && distance > 0) { node.applyForce(diff.normalized() * explosionForce / (distance * distance)); } } }
  }

  void applyAttractionForce(Vector2 position, double force) {
    for (final row in _nodes) { for (final node in row) { final diff = position - node.restPosition; final distance = diff.length; if (distance < GridConstants.gridSpacing * 5 && distance > 0) { node.applyForce(diff.normalized() * force / (distance + 1) * 0.01); } } }
  }

  void updateGrid(double dt) {
    for (final row in _nodes) {
      for (final node in row) {
        node.update(dt);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = GridConstants.gridColor.withValues(alpha: GridConstants.gridOpacity)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    for (int y = 0; y < rows; y++) {
      final path = Path();
      for (int x = 0; x < columns; x++) {
        final node = _nodes[y][x];
        if (x == 0) {
          path.moveTo(node.currentPosition.x, node.currentPosition.y);
        } else {
          path.lineTo(node.currentPosition.x, node.currentPosition.y);
        }
      }
      canvas.drawPath(path, paint);
    }
    for (int x = 0; x < columns; x++) {
      final path = Path();
      for (int y = 0; y < rows; y++) {
        final node = _nodes[y][x];
        if (y == 0) {
          path.moveTo(node.currentPosition.x, node.currentPosition.y);
        } else {
          path.lineTo(node.currentPosition.x, node.currentPosition.y);
        }
      }
      canvas.drawPath(path, paint);
    }
  }

  void onResize(Vector2 newSize) { _screenSize = newSize.clone(); _initializeGrid(); }
}
