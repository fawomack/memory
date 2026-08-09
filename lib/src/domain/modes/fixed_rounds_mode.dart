import '../mode.dart';
import '../game_state.dart';

// FixedRoundsMode: ends after a fixed number of rounds.
class FixedRoundsMode extends GameMode {
  @override
  final String id;
  final int rounds;

  FixedRoundsMode({this.id = 'fixed_rounds', required this.rounds});

  @override
  GameResult onRoundEnd(GameState state) {
    final nextRound = state.roundIndex + 1;
    final continueGame = nextRound < rounds;
    return GameResult(continueGame: continueGame);
  }

  @override
  bool shouldContinue(GameState state) => state.roundIndex + 1 < rounds;
}
