import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/config_service.dart';
import '../config/config.dart';
import '../domain/game_engine.dart';
import '../domain/mode.dart';
import '../domain/game_state.dart';
import 'config_controller.dart';

// Provider that exposes ConfigService single instance.
final configServiceProvider = Provider<ConfigService>((ref) => ConfigService());

// Async provider that loads the effective GameConfig (defaults + overrides).
final gameConfigProvider = FutureProvider<GameConfig>((ref) async {
  final svc = ref.read(configServiceProvider);
  return await svc.loadConfig();
});

// ConfigController provider exposes the live config and handles persistence.
final configControllerProvider = StateNotifierProvider<ConfigController, GameConfig>((ref) {
  final svc = ref.read(configServiceProvider);
  return ConfigController(svc);
});

// StateNotifier provider for GameEngine; a family so callers can pass a GameMode.
final gameEngineProvider = StateNotifierProvider.family<GameEngine, GameState, GameMode>((ref, mode) {
  // Watch the live config so the engine is recreated when user changes settings.
  final base = ref.watch(configControllerProvider);
  return GameEngine(baseConfig: base, mode: mode);
});
