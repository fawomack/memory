import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/config_service.dart';
import '../config/config.dart';

// ConfigController: StateNotifier that holds the current GameConfig and
// persists updates via ConfigService. It loads saved overrides on creation.
class ConfigController extends StateNotifier<GameConfig> {
  final ConfigService _service;

  ConfigController(this._service) : super(GameConfig.defaults()) {
    _load();
  }

  Future<void> _load() async {
    final cfg = await _service.loadConfig();
    state = cfg;
  }

  Future<void> update(GameConfig cfg) async {
    state = cfg;
    await _service.saveOverrides(cfg);
  }

  Future<void> reset() async {
    await _service.resetToDefaults();
    state = GameConfig.defaults();
  }
}
