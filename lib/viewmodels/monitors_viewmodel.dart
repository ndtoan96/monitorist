import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:monitorist/services/monitors_service.dart';
import 'package:monitorist/src/rust/api/monitors.dart';

class MonitorsViewModel extends ChangeNotifier {
  final MonitorsService _monitorsService;
  final List<MonitorViewModel> _monitorViewModels = [];
  MonitorsViewModel({required MonitorsService monitorsService})
    : _monitorsService = monitorsService;

  UnmodifiableListView<MonitorViewModel> get monitorViewModels =>
      UnmodifiableListView(_monitorViewModels);

  Future<void> loadMonitors() async {
    final monitorResults = await _monitorsService.getMonitors();
    _monitorViewModels.clear();
    for (final result in monitorResults) {
      if (result.success != null) {
        _monitorViewModels.add(MonitorViewModel(monitor: result.success!));
      } else {
        // Handle error case if needed
      }
    }
    notifyListeners();
  }
}

class MonitorViewModel extends ChangeNotifier {
  final Monitor _monitor;
  final String _id;
  String _name = "";
  double _brightness = 0.0;
  double? _brightnessToSet;
  bool _setBrightnessRunning = false;
  MonitorViewModel({required Monitor monitor}) : _monitor = monitor, _id = monitor.devicePath();

  String get id => _id;
  String get name => _name;
  double get brightness => _brightness;

  Future<void> loadSettings() async {
    _name = await _monitor.displayName();
    final brightnessValue = await _monitor.getBrightness();
    _brightness = brightnessValue.toDouble();
    notifyListeners();
  }

  Future<void> setBrightness(double value) async {
    _brightness = value;
    notifyListeners();
    if (_setBrightnessRunning) {
      _brightnessToSet = value;
      return;
    } else {
      _setBrightnessRunning = true;
      await _monitor.setBrightness(value: value.toInt());
      while (_brightnessToSet != null) {
        final nextValue = _brightnessToSet!;
        _brightnessToSet = null;
        await _monitor.setBrightness(value: nextValue.toInt());
      }
      _setBrightnessRunning = false;
    }
  }
}
