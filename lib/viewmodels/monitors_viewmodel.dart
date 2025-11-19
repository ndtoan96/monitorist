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
  String _id = "";
  String _name = "";
  double _brightness = 0.0;
  MonitorViewModel({required Monitor monitor}) : _monitor = monitor;

  String get id => _id;
  String get name => _name;
  double get brightness => _brightness;

  Future<void> loadSettings() async {
    _id = await _monitor.deviceName();
    _name = await _monitor.displayName();
    final brightnessValue = await _monitor.getBrightness();
    _brightness = brightnessValue.toDouble();
    notifyListeners();
  }

  void setBrightness(double value) {
    _monitor.setBrightness(value: value.toInt());
    _brightness = value;
    notifyListeners();
  }
}
