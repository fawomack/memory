// GameScreen: top-level UI for playing a single game session.
// It wires the `GameEngine` StateNotifier to the visible grid and
// provides controls to start/stop the game.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/game_providers.dart';
import '../../domain/mode.dart';
//import '../../domain/modes/fixed_rounds_mode.dart';
import '../widgets/grid_widget.dart';
import 'settings_screen.dart';

// We use a FixedRoundsMode for this screen as an example.
class GameScreen extends ConsumerWidget {
  final GameMode mode;

  const GameScreen({Key? key, required this.mode}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the engine state for this mode. UI will rebuild when state changes.
    final gameState = ref.watch(gameEngineProvider(mode));

    // Access the engine notifier to send commands (startGame, handleGuess, stop).
    final engine = ref.read(gameEngineProvider(mode).notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Game'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top info row: round, score, mistakes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Round: ${gameState.roundIndex + 1}'),
                Text('Score: ${gameState.score}'),
                Text('Mistakes: ${gameState.mistakes}'),
              ],
            ),
            const SizedBox(height: 12),
            // Grid area expands to available space
            Expanded(
              child: GridWidget(
                state: gameState,
                onTileTap: (index) {
                  engine.handleGuess(index);
                },
              ),
            ),
            const SizedBox(height: 12),
            // Control buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => engine.startGame(),
                    child: const Text('Start'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => engine.stop(),
                    child: const Text('Stop'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
