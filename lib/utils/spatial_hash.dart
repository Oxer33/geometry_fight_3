// ============================================================
// SPATIAL HASH GRID - Geometry Fight 3
// ============================================================
import 'package:flame/components.dart';

class SpatialEntity {
  final String id;
  Vector2 position;
  double radius;
  SpatialEntity({required this.id, required this.position, required this.radius});
}

class SpatialHashGrid {
  final double cellSize;
  final Map<String, List<SpatialEntity>> _cells = {};

  SpatialHashGrid({this.cellSize = 64.0});

  String _getCellKey(Vector2 position) {
    final cellX = (position.x / cellSize).floor();
    final cellY = (position.y / cellSize).floor();
    return '$cellX,$cellY';
  }

  List<String> _getNeighborCells(String cellKey) {
    final parts = cellKey.split(',');
    final centerX = int.parse(parts[0]);
    final centerY = int.parse(parts[1]);
    final neighbors = <String>[];
    for (int dx = -1; dx <= 1; dx++) {
      for (int dy = -1; dy <= 1; dy++) { neighbors.add('${centerX + dx},${centerY + dy}'); }
    }
    return neighbors;
  }

  void insert(SpatialEntity entity) { final cellKey = _getCellKey(entity.position); _cells.putIfAbsent(cellKey, () => []).add(entity); }
  void remove(SpatialEntity entity) { final cellKey = _getCellKey(entity.position); _cells[cellKey]?.removeWhere((e) => e.id == entity.id); }

  void updatePosition(SpatialEntity entity, Vector2 oldPosition) {
    final oldCell = _getCellKey(oldPosition);
    final newCell = _getCellKey(entity.position);
    if (oldCell != newCell) { _cells[oldCell]?.removeWhere((e) => e.id == entity.id); _cells.putIfAbsent(newCell, () => []).add(entity); }
  }

  List<SpatialEntity> query(Vector2 position, {double? radius}) {
    final searchRadius = radius ?? cellSize;
    final cellKey = _getCellKey(position);
    final neighborCells = _getNeighborCells(cellKey);
    final results = <SpatialEntity>[];
    final seenIds = <String>{};
    for (final cell in neighborCells) {
      final entities = _cells[cell];
      if (entities != null) {
        for (final entity in entities) {
          if (seenIds.contains(entity.id)) continue;
          if (entity.position.distanceTo(position) <= searchRadius + entity.radius) { results.add(entity); seenIds.add(entity.id); }
        }
      }
    }
    return results;
  }

  List<(SpatialEntity, SpatialEntity)> findOverlappingPairs() {
    final pairs = <(SpatialEntity, SpatialEntity)>[];
    final checkedPairs = <String>{};
    for (final cellKey in _cells.keys) {
      final entities = _cells[cellKey]!;
      final neighborCells = _getNeighborCells(cellKey);
      for (final neighborCell in neighborCells) {
        final neighborEntities = _cells[neighborCell];
        if (neighborEntities == null) continue;
        for (final a in entities) {
          for (final b in neighborEntities) {
            if (a.id == b.id) continue;
            final pairKey = a.id.compareTo(b.id) < 0 ? '${a.id}-${b.id}' : '${b.id}-${a.id}';
            if (checkedPairs.contains(pairKey)) continue;
            checkedPairs.add(pairKey);
            if (a.position.distanceTo(b.position) <= a.radius + b.radius) pairs.add((a, b));
          }
        }
      }
    }
    return pairs;
  }

  void clear() { _cells.clear(); }
  String get debugInfo => 'SpatialHashGrid: ${_cells.length} celle, ${_cells.values.fold(0, (sum, list) => sum + list.length)} entità';
}
