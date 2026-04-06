// GENERATED CODE - DO NOT MODIFY BY HAND
// Parte generata da hive_generator per SaveData

part of 'save_data.dart';

class SaveDataAdapter extends TypeAdapter<SaveData> {
  @override
  final int typeId = 0;

  @override
  SaveData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SaveData(
      goldGeoms: fields[0] as int? ?? 0,
      upgrades: (fields[1] as Map?)?.cast<String, int>() ?? {},
      unlockedSkins: (fields[2] as List?)?.cast<String>() ?? ['classic'],
      unlockedModes: (fields[3] as List?)?.cast<String>() ?? ['classic'],
      highscores: (fields[4] as Map?)?.cast<String, int>() ?? {},
      totalPlaytime: fields[5] as int? ?? 0,
      stats: (fields[6] as Map?)?.cast<String, int>() ?? {},
      currentSkin: fields[7] as String? ?? 'classic',
      currentMode: fields[8] as String? ?? 'classic',
      bgmVolume: fields[9] as double? ?? 0.7,
      sfxVolume: fields[10] as double? ?? 0.8,
      showFPS: fields[11] as bool? ?? false,
      vibrationEnabled: fields[12] as bool? ?? true,
      tutorialSeen: fields[13] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, SaveData obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.goldGeoms)
      ..writeByte(1)
      ..write(obj.upgrades)
      ..writeByte(2)
      ..write(obj.unlockedSkins)
      ..writeByte(3)
      ..write(obj.unlockedModes)
      ..writeByte(4)
      ..write(obj.highscores)
      ..writeByte(5)
      ..write(obj.totalPlaytime)
      ..writeByte(6)
      ..write(obj.stats)
      ..writeByte(7)
      ..write(obj.currentSkin)
      ..writeByte(8)
      ..write(obj.currentMode)
      ..writeByte(9)
      ..write(obj.bgmVolume)
      ..writeByte(10)
      ..write(obj.sfxVolume)
      ..writeByte(11)
      ..write(obj.showFPS)
      ..writeByte(12)
      ..write(obj.vibrationEnabled)
      ..writeByte(13)
      ..write(obj.tutorialSeen);
  }
}
