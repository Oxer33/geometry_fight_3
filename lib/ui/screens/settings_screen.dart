// ============================================================
// SETTINGS SCREEN - Geometry Fight 3
// ============================================================
// Schermata impostazioni per volume, vibrazione, reset dati.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/save_data.dart';
import '../../main.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  double _bgmVolume = 0.7;
  double _sfxVolume = 0.8;
  bool _vibrationEnabled = true;
  bool _showFPS = false;

  @override
  void initState() {
    super.initState();
    final saveData = ref.read(saveDataProvider);
    _bgmVolume = saveData.bgmVolume;
    _sfxVolume = saveData.sfxVolume;
    _vibrationEnabled = saveData.vibrationEnabled;
    _showFPS = saveData.showFPS;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IMPOSTAZIONI', style: TextStyle(fontFamily: 'monospace')),
        backgroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Volume BGM
          _buildVolumeSlider(
            title: 'Volume Musica',
            icon: Icons.music_note,
            value: _bgmVolume,
            onChanged: (v) {
              setState(() => _bgmVolume = v);
              _saveSettings();
            },
          ),
          const SizedBox(height: 16),
          // Volume SFX
          _buildVolumeSlider(
            title: 'Volume Effetti',
            icon: Icons.volume_up,
            value: _sfxVolume,
            onChanged: (v) {
              setState(() => _sfxVolume = v);
              _saveSettings();
            },
          ),
          const SizedBox(height: 24),
          // Vibrazione
          SwitchListTile(
            title: const Text(
              'Vibrazione',
              style: TextStyle(color: Colors.white, fontFamily: 'monospace'),
            ),
            value: _vibrationEnabled,
            onChanged: (v) {
              setState(() => _vibrationEnabled = v);
              _saveSettings();
            },
            activeThumbColor: const Color(0xFF00FFFF),
          ),
          // Mostra FPS
          SwitchListTile(
            title: const Text(
              'Mostra FPS',
              style: TextStyle(color: Colors.white, fontFamily: 'monospace'),
            ),
            value: _showFPS,
            onChanged: (v) {
              setState(() => _showFPS = v);
              _saveSettings();
            },
            activeThumbColor: const Color(0xFF00FFFF),
          ),
          const Divider(color: Colors.grey),
          // Reset dati
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text(
              'Reset Dati',
              style: TextStyle(color: Colors.red, fontFamily: 'monospace'),
            ),
            subtitle: const Text('Cancella tutti i progressi'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: Colors.black87,
                  title: const Text(
                    'Conferma Reset',
                    style: TextStyle(color: Colors.red),
                  ),
                  content: const Text(
                    'Sei sicuro di voler cancellare tutti i dati? Questa azione è irreversibile.',
                    style: TextStyle(color: Colors.white),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annulla', style: TextStyle(color: Colors.grey)),
                    ),
                    TextButton(
                      onPressed: () {
                        ref.read(saveDataProvider.notifier).update(SaveData.initial());
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text('Conferma', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeSlider({
    required String title,
    required IconData icon,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF00FFFF)),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'monospace',
                fontSize: 16,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: 0,
          max: 1,
          divisions: 10,
          activeColor: const Color(0xFF00FFFF),
          onChanged: onChanged,
        ),
        Text(
          '${(value * 100).round()}%',
          style: const TextStyle(color: Colors.grey, fontFamily: 'monospace'),
        ),
      ],
    );
  }

  void _saveSettings() {
    final saveData = ref.read(saveDataProvider);
    saveData.bgmVolume = _bgmVolume;
    saveData.sfxVolume = _sfxVolume;
    saveData.vibrationEnabled = _vibrationEnabled;
    saveData.showFPS = _showFPS;
    ref.read(saveDataProvider.notifier).save();
  }
}
