// ============================================================
// SAVE DATA MODEL - Geometry Fight 3
// ============================================================
// Modello per il salvataggio dei dati di gioco usando Hive.
// Persiste: valuta, upgrade, skin sbloccate, highscore, statistiche.
// ============================================================

import 'package:hive/hive.dart';

part 'save_data.g.dart'; // Generato da hive_generator

/// Modello principale per il salvataggio dei dati
@HiveType(typeId: 0)
class SaveData extends HiveObject {
  /// Gold Geoms (valuta premium)
  @HiveField(0)
  int goldGeoms;

  /// Upgrade permanenti (upgradeId → livello)
  @HiveField(1)
  Map<String, int> upgrades;

  /// Skin sbloccate
  @HiveField(2)
  List<String> unlockedSkins;

  /// Modalità di gioco sbloccate
  @HiveField(3)
  List<String> unlockedModes;

  /// Highscore per modalità (mode → score)
  @HiveField(4)
  Map<String, int> highscores;

  /// Tempo totale di gioco in secondi
  @HiveField(5)
  int totalPlaytime;

  /// Statistiche varie (kills, waves, etc.)
  @HiveField(6)
  Map<String, int> stats;

  /// Skin attualmente selezionata
  @HiveField(7)
  String currentSkin;

  /// Modalità attualmente selezionata
  @HiveField(8)
  String currentMode;

  /// Volume BGM (0.0 - 1.0)
  @HiveField(9)
  double bgmVolume;

  /// Volume SFX (0.0 - 1.0)
  @HiveField(10)
  double sfxVolume;

  /// Mostra FPS in debug
  @HiveField(11)
  bool showFPS;

  /// Vibrazione abilitata
  @HiveField(12)
  bool vibrationEnabled;

  /// Tutorial già visualizzato
  @HiveField(13)
  bool tutorialSeen;

  SaveData({
    this.goldGeoms = 0,
    Map<String, int>? upgrades,
    List<String>? unlockedSkins,
    List<String>? unlockedModes,
    Map<String, int>? highscores,
    this.totalPlaytime = 0,
    Map<String, int>? stats,
    this.currentSkin = 'classic',
    this.currentMode = 'classic',
    this.bgmVolume = 0.7,
    this.sfxVolume = 0.8,
    this.showFPS = false,
    this.vibrationEnabled = true,
    this.tutorialSeen = false,
  })  : upgrades = upgrades ?? {},
        unlockedSkins = unlockedSkins ?? ['classic'],
        unlockedModes = unlockedModes ?? ['classic'],
        highscores = highscores ?? {},
        stats = stats ?? {
          'totalKills': 0,
          'totalWaves': 0,
          'totalBossesDefeated': 0,
          'totalGeomsCollected': 0,
          'totalBombsUsed': 0,
          'totalPowerUpsCollected': 0,
          'perfectWaves': 0,
          'maxCombo': 0,
        };

  /// Factory per creare un SaveData vuoto (primo avvio)
  factory SaveData.initial() {
    return SaveData();
  }

  /// Aggiorna un upgrade
  void setUpgrade(String upgradeId, int level) {
    upgrades[upgradeId] = level;
  }

  /// Ottiene il livello di un upgrade
  int getUpgradeLevel(String upgradeId) {
    return upgrades[upgradeId] ?? 0;
  }

  /// Aggiunge Gold Geoms
  void addGoldGeoms(int amount) {
    goldGeoms += amount;
  }

  /// Spende Gold Geoms (restituisce true se sufficiente)
  bool spendGoldGeoms(int amount) {
    if (goldGeoms >= amount) {
      goldGeoms -= amount;
      return true;
    }
    return false;
  }

  /// Aggiorna un highscore (restituisce true se è un nuovo record)
  bool updateHighscore(String mode, int score) {
    final currentHighscore = highscores[mode] ?? 0;
    if (score > currentHighscore) {
      highscores[mode] = score;
      return true;
    }
    return false;
  }

  /// Ottiene l'highscore di una modalità
  int getHighscore(String mode) {
    return highscores[mode] ?? 0;
  }

  /// Incrementa una statistica
  void incrementStat(String statId, [int amount = 1]) {
    stats[statId] = (stats[statId] ?? 0) + amount;
  }

  /// Ottiene una statistica
  int getStat(String statId) {
    return stats[statId] ?? 0;
  }

  /// Sblocca una skin
  void unlockSkin(String skinId) {
    if (!unlockedSkins.contains(skinId)) {
      unlockedSkins.add(skinId);
    }
  }

  /// Verifica se una skin è sbloccata
  bool isSkinUnlocked(String skinId) {
    return unlockedSkins.contains(skinId);
  }

  /// Sblocca una modalità
  void unlockMode(String modeId) {
    if (!unlockedModes.contains(modeId)) {
      unlockedModes.add(modeId);
    }
  }

  /// Verifica se una modalità è sbloccata
  bool isModeUnlocked(String modeId) {
    return unlockedModes.contains(modeId);
  }

  /// Resetta tutti i dati (per debug)
  void reset() {
    goldGeoms = 0;
    upgrades.clear();
    unlockedSkins.clear();
    unlockedSkins.add('classic');
    unlockedModes.clear();
    unlockedModes.add('classic');
    highscores.clear();
    totalPlaytime = 0;
    stats.clear();
    stats['totalKills'] = 0;
    stats['totalWaves'] = 0;
    stats['totalBossesDefeated'] = 0;
    stats['totalGeomsCollected'] = 0;
    stats['totalBombsUsed'] = 0;
    stats['totalPowerUpsCollected'] = 0;
    stats['perfectWaves'] = 0;
    stats['maxCombo'] = 0;
    currentSkin = 'classic';
    currentMode = 'classic';
    tutorialSeen = false;
  }

  @override
  String toString() {
    return 'SaveData(geoms: $goldGeoms, skin: $currentSkin, playtime: ${totalPlaytime}s)';
  }
}
