import '../mode.dart';
import '../game_state.dart';

// EndlessMode: continue until allowed mistakes exceeded.
class EndlessMode extends GameMode {
  @override
  final String id;
  final int allowedMistakes;

  EndlessMode({this.id = 'endless', this.allowedMistakes = 0});

  @override
  GameResult onRoundEnd(GameState state) {
    final continueGame = state.mistakes <= allowedMistakes;
    return GameResult(continueGame: continueGame);
  }

  @override
  bool shouldContinue(GameState state) => state.mistakes <= allowedMistakes;
}
