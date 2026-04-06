// ============================================================
// SHOP SCREEN - Geometry Fight 3
// ============================================================
// Schermata shop per acquistare upgrade e skin.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/save_data.dart';
import '../../main.dart';

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  int _selectedTab = 0;
  final _tabs = ['Upgrade', 'Skin', 'Modalità'];

  @override
  Widget build(BuildContext context) {
    final saveData = ref.watch(saveDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SHOP', style: TextStyle(fontFamily: 'monospace')),
        backgroundColor: Colors.black,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text('💎', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(
                  '${saveData.goldGeoms}',
                  style: const TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 20,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab bar
          Row(
            children: List.generate(
              _tabs.length,
              (i) => Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedTab = i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: _selectedTab == i
                          ? const Color(0xFF00FFFF).withValues(alpha: 0.2)
                          : Colors.transparent,
                      border: Border(
                        bottom: BorderSide(
                          color: _selectedTab == i
                              ? const Color(0xFF00FFFF)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      _tabs[i],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _selectedTab == i
                            ? const Color(0xFF00FFFF)
                            : Colors.grey,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Contenuto tab
          Expanded(
            child: _buildTabContent(_selectedTab, saveData),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(int tab, SaveData saveData) {
    switch (tab) {
      case 0:
        return _buildUpgradeList(saveData);
      case 1:
        return _buildSkinGrid(saveData);
      case 2:
        return _buildModeList(saveData);
      default:
        return const SizedBox();
    }
  }

  Widget _buildUpgradeList(SaveData saveData) {
    final upgrades = [
      {'name': 'Firepower', 'icon': '🔥', 'key': 'firepower', 'maxLevel': 5, 'basePrice': 100},
      {'name': 'Speed', 'icon': '⚡', 'key': 'speed', 'maxLevel': 5, 'basePrice': 100},
      {'name': 'Fire Rate', 'icon': '🔫', 'key': 'fire_rate', 'maxLevel': 5, 'basePrice': 100},
      {'name': 'Shield', 'icon': '🛡️', 'key': 'shield_capacity', 'maxLevel': 3, 'basePrice': 300},
      {'name': 'Lives', 'icon': '❤️', 'key': 'starting_lives', 'maxLevel': 2, 'basePrice': 500},
      {'name': 'Bombs', 'icon': '💣', 'key': 'bomb_capacity', 'maxLevel': 2, 'basePrice': 400},
      {'name': 'Magnet', 'icon': '🧲', 'key': 'magnet_range', 'maxLevel': 3, 'basePrice': 250},
      {'name': 'XP Boost', 'icon': '✨', 'key': 'xp_boost', 'maxLevel': 3, 'basePrice': 300},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: upgrades.length,
      itemBuilder: (context, i) {
        final upgrade = upgrades[i];
        final currentLevel = saveData.getUpgradeLevel(upgrade['key'] as String);
        final maxLevel = upgrade['maxLevel'] as int;
        final basePrice = upgrade['basePrice'] as int;
        final price = basePrice * (currentLevel + 1);
        final isMaxed = currentLevel >= maxLevel;

        return Card(
          color: Colors.grey[900],
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Text(upgrade['icon'] as String, style: const TextStyle(fontSize: 32)),
            title: Text(
              upgrade['name'] as String,
              style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
            ),
            subtitle: Row(
              children: [
                ...List.generate(
                  maxLevel,
                  (j) => Icon(
                    j < currentLevel ? Icons.star : Icons.star_border,
                    color: const Color(0xFFFFD700),
                    size: 16,
                  ),
                ),
              ],
            ),
            trailing: isMaxed
                ? const Text('MAX', style: TextStyle(color: Color(0xFFFFD700)))
                : ElevatedButton(
                    onPressed: saveData.goldGeoms >= price
                        ? () {
                            // TODO: Acquista upgrade
                          }
                        : null,
                    child: Text('$price 💎'),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildSkinGrid(SaveData saveData) {
    final skins = [
      {'id': 'classic', 'name': 'Classic', 'price': 0, 'unlocked': true},
      {'id': 'stealth', 'name': 'Stealth', 'price': 500, 'unlocked': saveData.isSkinUnlocked('stealth')},
      {'id': 'crystal', 'name': 'Crystal', 'price': 1000, 'unlocked': saveData.isSkinUnlocked('crystal')},
      {'id': 'ghost', 'name': 'Ghost', 'price': 1500, 'unlocked': saveData.isSkinUnlocked('ghost')},
      {'id': 'omega', 'name': 'Omega', 'price': 3000, 'unlocked': saveData.isSkinUnlocked('omega')},
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: skins.length,
      itemBuilder: (context, i) {
        final skin = skins[i];
        return Card(
          color: Colors.grey[900],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.rocket, size: 48, color: Color(0xFF00FFFF)),
              const SizedBox(height: 8),
              Text(
                skin['name'] as String,
                style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
              ),
              const SizedBox(height: 8),
              skin['unlocked'] as bool
                  ? const Text('✅', style: TextStyle(fontSize: 24))
                  : Text(
                      '${skin['price']} 💎',
                      style: const TextStyle(color: Color(0xFFFFD700)),
                    ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModeList(SaveData saveData) {
    final modes = [
      {'id': 'classic', 'name': 'Classic', 'desc': '40 onde + boss', 'unlocked': true},
      {'id': 'boss_rush', 'name': 'Boss Rush', 'desc': 'Solo boss in sequenza', 'price': 2000, 'unlocked': saveData.isModeUnlocked('boss_rush')},
      {'id': 'survival', 'name': 'Survival', 'desc': 'Onde infinite', 'price': 2500, 'unlocked': saveData.isModeUnlocked('survival')},
      {'id': 'challenge', 'name': 'Challenge', 'desc': '10 livelli speciali', 'price': 3000, 'unlocked': saveData.isModeUnlocked('challenge')},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: modes.length,
      itemBuilder: (context, i) {
        final mode = modes[i];
        return Card(
          color: Colors.grey[900],
          child: ListTile(
            title: Text(
              mode['name'] as String,
              style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
            ),
            subtitle: Text(
              mode['desc'] as String,
              style: const TextStyle(color: Colors.grey),
            ),
            trailing: mode['unlocked'] as bool
                ? const Icon(Icons.check_circle, color: Color(0xFF00FF88))
                : ElevatedButton(
                    onPressed: saveData.goldGeoms >= (mode['price'] as int? ?? 0)
                        ? () {
                            // TODO: Sblocca modalità
                          }
                        : null,
                    child: Text('${mode['price']} 💎'),
                  ),
          ),
        );
      },
    );
  }
}
