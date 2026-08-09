import '../config/config.dart';
import 'game_state.dart';

// GameMode: strategy interface describing mode-specific behavior.
abstract class GameMode {
  // Optional human-readable id
  String get id;

  // Called before a round starts; can return a per-round config override.
  // Allow modes to tweak per-round effective `GameConfig`. The default
  // implementation returns the provided config unchanged.
  GameConfig applyRoundStart(GameState state, GameConfig baseConfig) => baseConfig;

  // Called after a round ends so the mode can compute results or side-effects.
  GameResult onRoundEnd(GameState state) => GameResult(continueGame: true);

  // Whether the engine should continue after the latest state.
  bool shouldContinue(GameState state) => true;
}
