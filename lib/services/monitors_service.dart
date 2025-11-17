import 'package:monitorist/src/rust/api/monitors.dart';

class MonitorsService {
  Future<List<MonitorResult>> getMonitors() async {
    return await Monitor.getMonitors();
  }
}