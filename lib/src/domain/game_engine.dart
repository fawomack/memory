import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/config.dart';
import 'game_state.dart';
import 'mode.dart';

// GameEngine implemented as a StateNotifier so it integrates cleanly with
// Riverpod. It manages round sequencing, reveal timing, guess validation,
// scoring, and delegates continuation logic to a GameMode strategy.
class GameEngine extends StateNotifier<GameState> {
  final GameConfig baseConfig;
  final GameMode mode;

  // Internal sequence and guess tracking
  List<int> _currentSequence = [];
  int _currentGuessIndex = 0;
  bool _isRevealing = false;

  GameEngine({required this.baseConfig, required this.mode})
      : super(GameState(
          roundIndex: 0,
          gridSize: baseConfig.startGridSize,
          revealDurationMs: baseConfig.revealDurationMs,
          phase: GamePhase.idle,
        ));

  // Start a full game session.
  Future<void> startGame() async {
    state = state.copyWith(
      roundIndex: 0,
      gridSize: baseConfig.startGridSize,
      mistakes: 0,
      score: 0,
      phase: GamePhase.idle,
      guessIndex: 0,
    );
    await startRound();
  }

  // Start a single round: generate sequence, reveal it, then switch to guessing.
  Future<void> startRound() async {
    final effectiveConfig = mode.applyRoundStart(state, baseConfig);
    final gridCells = state.gridSize * state.gridSize;

    // Sequence length grows with roundIndex; simple rule: startGridSize + roundIndex
    final seqLen = baseConfig.startGridSize + state.roundIndex;
    _currentSequence = _generateSequence(seqLen, gridCells);
    _currentGuessIndex = 0;

    // Update state with new sequence and reveal duration
    state = state.copyWith(
      sequence: List<int>.from(_currentSequence),
      guessIndex: 0,
      phase: GamePhase.revealing,
      revealDurationMs: effectiveConfig.revealDurationMs,
    );

    // Reveal sequence to player
    await _revealSequence(_currentSequence, effectiveConfig.revealDurationMs);

    // After revealing, switch to guessing phase
    state = state.copyWith(phase: GamePhase.guessing, highlightedIndex: -1);
  }

  // Generate a random sequence of unique positions (no duplicates).
  List<int> _generateSequence(int length, int gridCells) {
    final rand = Random();
    final available = List<int>.generate(gridCells, (i) => i);
    final seq = <int>[];
    for (int i = 0; i < length && available.isNotEmpty; i++) {
      final idx = rand.nextInt(available.length);
      seq.add(available.removeAt(idx));
    }
    return seq;
  }

  // Reveal each index with delays; updates `highlightedIndex` in state.
  Future<void> _revealSequence(List<int> sequence, int revealMs) async {
    _isRevealing = true;
    for (final idx in sequence) {
      if (!_isRevealing) break;
      state = state.copyWith(highlightedIndex: idx);
      await Future.delayed(Duration(milliseconds: revealMs));
      state = state.copyWith(highlightedIndex: -1);
      await Future.delayed(const Duration(milliseconds: 150));
    }
    _isRevealing = false;
  }

  // Handle a player's guess; returns true if guess was correct.
  bool handleGuess(int position) {
    if (state.phase != GamePhase.guessing) return false;
    final expected = _currentSequence[_currentGuessIndex];
    final correct = position == expected;
    if (correct) {
      _currentGuessIndex++;
      // award points for a correct guess
      final newScore = state.score + 10; // simple flat score
      state = state.copyWith(score: newScore, guessIndex: _currentGuessIndex);
      // If sequence complete, end round successfully
      if (_currentGuessIndex >= _currentSequence.length) {
        _onRoundComplete(success: true);
      }
    } else {
      final newMistakes = state.mistakes + 1;
      state = state.copyWith(mistakes: newMistakes);
      // Ask mode whether to continue based on mistakes
      final result = mode.onRoundEnd(state);
      if (!result.continueGame) {
        _onRoundComplete(success: false);
      }
    }
    return correct;
  }

  // Called when round completes to advance or finish the game.
  Future<void> _onRoundComplete({required bool success}) async {
    state = state.copyWith(phase: GamePhase.roundResult);
    final result = mode.onRoundEnd(state);
    if (!result.continueGame) {
      state = state.copyWith(phase: GamePhase.finished);
      return;
    }

    // Prepare next round: increase roundIndex and maybe grid size.
    final nextRound = state.roundIndex + 1;
    var nextGrid = state.gridSize;
    if (success) {
      nextGrid = (state.gridSize + baseConfig.gridIncrement).clamp(baseConfig.startGridSize, baseConfig.maxGridSize);
    }

    state = state.copyWith(
      roundIndex: nextRound,
      gridSize: nextGrid,
      phase: GamePhase.idle,
      guessIndex: 0,
    );

    // small delay before starting the next round automatically
    await Future.delayed(const Duration(milliseconds: 600));
    await startRound();
  }

  // Stop any active reveal and mark finished.
  void stop() {
    _isRevealing = false;
    state = state.copyWith(phase: GamePhase.finished, highlightedIndex: -1);
  }

  @override
  void dispose() {
    _isRevealing = false;
    super.dispose();
  }
}
