// SettingsScreen: allows adjusting basic game parameters that persist
// between sessions via `ConfigController`.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/game_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late int _gridStart;
  late int _revealMs;

  @override
  void initState() {
    super.initState();
    final cfg = ref.read(configControllerProvider);
    _gridStart = cfg.startGridSize;
    _revealMs = cfg.revealDurationMs;
  }

  @override
  Widget build(BuildContext context) {
    final cfg = ref.watch(configControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Start Grid Size'),
                DropdownButton<int>(
                  value: _gridStart,
                  items: List.generate(4, (i) => i + 3)
                      .map((v) => DropdownMenuItem(value: v, child: Text('$v x $v')))
                      .toList(),
                  onChanged: (v) => setState(() => _gridStart = v!),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Reveal Duration (ms)'),
                SizedBox(
                  width: 160,
                  child: TextFormField(
                    initialValue: '$_revealMs',
                    keyboardType: TextInputType.number,
                    onChanged: (s) => _revealMs = int.tryParse(s) ?? _revealMs,
                    decoration: const InputDecoration(suffixText: 'ms'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      // Save changes via the controller
                      final newCfg = cfg.copyWith(startGridSize: _gridStart, revealDurationMs: _revealMs);
                      final navigator = Navigator.of(context); // capture before async gap
                      await ref.read(configControllerProvider.notifier).update(newCfg);
                      if (!mounted) return;
                      navigator.pop();
                    },
                    child: const Text('Save'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await ref.read(configControllerProvider.notifier).reset();
                      if (!mounted) return;
                      setState(() {
                        final c = ref.read(configControllerProvider);
                        _gridStart = c.startGridSize;
                        _revealMs = c.revealDurationMs;
                      });
                    },
                    child: const Text('Reset'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Current config: start ${cfg.startGridSize} reveal ${cfg.revealDurationMs}ms'),
          ],
        ),
      ),
    );
  }
}
