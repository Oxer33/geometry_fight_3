// ============================================================
// SCORE SYSTEM - Geometry Fight 3
// ============================================================
import 'dart:math';
import 'package:flame/components.dart';
import '../../data/constants.dart';

class ScoreSystem extends Component {
  int _currentScore = 0;
  double _multiplier = 1.0;
  int _currentGeoms = 0;
  int _totalGeoms = 0;
  double _comboTimer = 0.0;
  int _recentKills = 0;
  bool _comboActive = false;

  Function(int score)? onScoreChanged;
  Function(double multiplier)? onMultiplierChanged;
  Function(int geoms)? onGeomCollected;
  Function(int comboCount)? onCombo;

  @override
  void update(double dt) { if (_comboTimer > 0) { _comboTimer -= dt; if (_comboTimer <= 0) _resetCombo(); } }

  void addKillScore(int baseScore) {
    _multiplier = min(_multiplier + ScoreConstants.multiplierIncrement, ScoreConstants.multiplierMax);
    _currentScore += (baseScore * _multiplier).round();
    _recentKills++; _comboTimer = ScoreConstants.comboTimeWindow;
    if (_recentKills >= ScoreConstants.comboKillCount && !_comboActive) { _comboActive = true; onCombo?.call(_recentKills); }
    onScoreChanged?.call(_currentScore); onMultiplierChanged?.call(_multiplier);
  }

  void addBossScore(int baseScore) { addKillScore(baseScore * 10); }
  void collectGeom(int value) { _currentGeoms += (value * _multiplier).round(); _totalGeoms += _currentGeoms; onGeomCollected?.call(_currentGeoms); }
  void resetMultiplier() { _multiplier = 1.0; onMultiplierChanged?.call(_multiplier); }
  void _resetCombo() { _comboTimer = 0.0; _recentKills = 0; _comboActive = false; }
  void addWaveBonus(int waveNumber) { _currentScore += waveNumber * 100; onScoreChanged?.call(_currentScore); }
  void addPerfectWaveBonus() { _currentGeoms *= ScoreConstants.perfectWaveBonus; onGeomCollected?.call(_currentGeoms); }
  void reset() { _currentScore = 0; _multiplier = 1.0; _currentGeoms = 0; _totalGeoms = 0; _resetCombo(); }

  int get currentScore => _currentScore;
  double get multiplier => _multiplier;
  int get currentGeoms => _currentGeoms;
  int get totalGeoms => _totalGeoms;
  bool get comboActive => _comboActive;
  int get recentKills => _recentKills;
}
