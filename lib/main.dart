// ============================================================
// MAIN - Geometry Fight 3
// ============================================================
// Entry point dell'applicazione.
// Inizializza Hive, Riverpod e avvia il gioco.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/models/save_data.dart';
import 'data/repositories/save_repository.dart';
import 'ui/screens/main_menu.dart';

/// Provider per il repository salvataggi
final saveRepositoryProvider = Provider<SaveRepository>((ref) {
  throw UnimplementedError();
});

/// Provider per i dati salvati
final saveDataProvider = StateNotifierProvider<SaveDataNotifier, SaveData>((ref) {
  return SaveDataNotifier(ref.read(saveRepositoryProvider));
});

/// Notifier per i dati salvati
class SaveDataNotifier extends StateNotifier<SaveData> {
  final SaveRepository _repository;

  SaveDataNotifier(this._repository) : super(SaveData.initial()) {
    _load();
  }

  Future<void> _load() async {
    state = _repository.load();
  }

  Future<void> save() async {
    await _repository.save(state);
  }

  void update(SaveData data) {
    state = data;
    save();
  }
}

void main() async {
  // Assicura inizializzazione Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Inizializza Hive
  await Hive.initFlutter();

  // Inizializza repository
  final saveRepo = SaveRepository();
  await saveRepo.init();

  // Forza orientamento portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Imposta tema scuro di sistema
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    ProviderScope(
      overrides: [
        saveRepositoryProvider.overrideWithValue(saveRepo),
      ],
      child: const GeometryFight3App(),
    ),
  );
}

/// App principale
class GeometryFight3App extends ConsumerWidget {
  const GeometryFight3App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Geometry Fight 3',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF00FFFF),
        scaffoldBackgroundColor: const Color(0xFF000000),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00FFFF),
          secondary: Color(0xFFFF00AA),
          surface: Color(0xFF111111),
        ),
        fontFamily: 'monospace',
        useMaterial3: true,
      ),
      home: const MainMenuScreen(),
    );
  }
}
