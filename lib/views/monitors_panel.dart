import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:monitorist/viewmodels/monitors_viewmodel.dart';
import 'package:provider/provider.dart';

class MonitorsPanel extends StatefulWidget {
  const MonitorsPanel({super.key});

  @override
  State<MonitorsPanel> createState() => _MonitorsPanelState();
}

class _MonitorsPanelState extends State<MonitorsPanel> {
  @override
  void initState() {
    super.initState();
    final viewModel = context.read<MonitorsViewModel>();
    viewModel.loadMonitors();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MonitorsViewModel>();
    final head = Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: const SelectableText(
          "Monitors",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
    );
    final monitorItems = viewModel.monitorViewModels.map((vm) {
      return ChangeNotifierProvider.value(value: vm, child: MonitorItem());
    }).toList();
    final body = Expanded(child: ListView(children: monitorItems));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [head, SizedBox(height: 8), body],
    );
  }
}

class MonitorItem extends StatefulWidget {
  const MonitorItem({super.key});

  @override
  State<MonitorItem> createState() => _MonitorItemState();
}

class _MonitorItemState extends State<MonitorItem> {
  late TextEditingController _brightnessController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    final viewModel = context.read<MonitorViewModel>();
    viewModel.loadSettings();
    _brightnessController = TextEditingController(
      text: viewModel.brightness.toString(),
    );
    viewModel.addListener(() {
      _brightnessController.text = viewModel.brightness.toString();
    });
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _brightnessController.text = viewModel.brightness.toString();
      }
    });
  }

  @override
  void dispose() {
    _brightnessController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MonitorViewModel>();
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            Expanded(
              child: SelectableText(
                viewModel.name,
                style: TextStyle(fontSize: 18),
              ),
            ),
            Row(
              children: [
                SizedBox(
                  width: 300,
                  child: Slider(
                    value: viewModel.brightness.toDouble(),
                    onChanged: (value) =>
                        viewModel.setBrightness(value.round()),
                    min: 0.0,
                    max: 100.0,
                    divisions: 100,
                    label: "Brightness",
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: _brightnessController,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      isDense: true,
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onSubmitted: (value) {
                      final brightness = int.tryParse(value);
                      if (brightness != null) {
                        viewModel.setBrightness(brightness.clamp(0, 100));
                      } else {
                        _brightnessController.text = viewModel.brightness
                            .toString();
                      }
                    },
                    onTapOutside: (_) {
                      _brightnessController.text = viewModel.brightness
                          .toString();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
