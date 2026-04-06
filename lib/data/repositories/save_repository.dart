// ============================================================
// SAVE REPOSITORY - Geometry Fight 3
// ============================================================
// Gestisce il salvataggio e il caricamento dei dati usando Hive.
// ============================================================

import 'package:hive_flutter/hive_flutter.dart';
import '../models/save_data.dart';

/// Chiave per il box Hive
const String _saveBoxName = 'geometry_fight_3_save';
const String _saveDataKey = 'save_data';

/// Repository per la gestione dei salvataggi
class SaveRepository {
  late Box<SaveData> _box;

  /// Inizializza il repository
  Future<void> init() async {
    // Registra l'adapter per SaveData
    Hive.registerAdapter(SaveDataAdapter());
    
    // Apri il box
    _box = await Hive.openBox<SaveData>(_saveBoxName);
    
    // Se non esiste un salvataggio, creane uno vuoto
    if (_box.get(_saveDataKey) == null) {
      await _box.put(_saveDataKey, SaveData.initial());
    }
  }

  /// Carica i dati salvati
  SaveData load() {
    return _box.get(_saveDataKey) ?? SaveData.initial();
  }

  /// Salva i dati
  Future<void> save(SaveData data) async {
    await _box.put(_saveDataKey, data);
  }

  /// Resetta i dati
  Future<void> reset() async {
    await _box.put(_saveDataKey, SaveData.initial());
  }

  /// Chiude il box (da chiamare alla chiusura dell'app)
  Future<void> close() async {
    await _box.close();
  }
}
