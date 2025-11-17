import 'package:flutter/foundation.dart';
import 'package:monitorist/services/monitors_service.dart';
import 'package:monitorist/src/rust/api/monitors.dart';

class MonitorsPanelViewmodel {
  final MonitorsService _monitorsService;
  MonitorsPanelViewmodel({required MonitorsService monitorsService})
    : _monitorsService = monitorsService;

  Future<List<MonitorItemViewmodel>> getMonitorItemViewModels() async {
    final monitorResults = await _monitorsService.getMonitors();
    List<MonitorItemViewmodel> monitorViewmodels = [];
    for (final result in monitorResults) {
      if (result.success != null) {
        monitorViewmodels.add(MonitorItemViewmodel(monitor: result.success!));
      } else {
        // Handle error case if needed
      }
    }
    return monitorViewmodels;
  }
}

class MonitorItemViewmodel extends ChangeNotifier {
  final Monitor _monitor;
  String _name = "";
  double _brightness = 0.0;
  MonitorItemViewmodel({required Monitor monitor}) : _monitor = monitor;

  String get name => _name;
  double get brightness => _brightness;

  Future<void> loadSettings() async {
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
