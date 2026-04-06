// ============================================================
// OBJECT POOL - Geometry Fight 3
// ============================================================
class ObjectPool<T> {
  final List<T> _available = [];
  final List<T> _inUse = [];
  final T Function() _factory;
  final int maxSize;
  final void Function(T)? _onRelease;

  ObjectPool({required T Function() factory, int initialSize = 50, this.maxSize = 200, void Function(T)? onRelease})
      : _factory = factory, _onRelease = onRelease {
    for (int i = 0; i < initialSize; i++) {
      _available.add(_factory());
    }
  }

  T acquire() {
    T item;
    if (_available.isNotEmpty) {
      item = _available.removeLast();
    } else if (_inUse.length < maxSize) {
      item = _factory();
    } else {
      item = _inUse.removeAt(0);
      _onRelease?.call(item);
    }
    _inUse.add(item);
    return item;
  }

  void release(T item) {
    if (_inUse.remove(item)) {
      _onRelease?.call(item);
      if (_available.length < maxSize) {
        _available.add(item);
      }
    }
  }

  void releaseAll() {
    for (final item in _inUse) {
      _onRelease?.call(item);
      if (_available.length < maxSize) {
        _available.add(item);
      }
    }
    _inUse.clear();
  }

  void reset() {
    _available.clear();
    _inUse.clear();
    for (int i = 0; i < maxSize; i++) {
      _available.add(_factory());
    }
  }
  int get availableCount => _available.length;
  int get inUseCount => _inUse.length;
  int get totalCount => _available.length + _inUse.length;
  String get debugInfo => 'Pool: $inUseCount in uso, $availableCount disponibili, $maxSize max';
}
