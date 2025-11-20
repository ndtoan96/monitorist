import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:monitorist/viewmodels/nightlight_viewmodel.dart';
import 'package:monitorist/views/monitors_panel.dart';
import 'package:monitorist/views/profiles_panel.dart';
import 'package:provider/provider.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const SelectableText('Overview'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  NightlightPanel(),
                  Divider(),
                  Expanded(child: MonitorsPanel()),
                ],
              ),
            ),
          ),
          VerticalDivider(),
          Expanded(flex: 1, child: ProfilesPanel()),
          SizedBox(width: 8),
        ],
      ),
    );
  }
}

class NightlightPanel extends StatefulWidget {
  const NightlightPanel({super.key});

  @override
  State<NightlightPanel> createState() => _NightlightPanelState();
}

class _NightlightPanelState extends State<NightlightPanel> {
  late TextEditingController _nightlightStrengthController;

  @override
  void initState() {
    super.initState();
    final viewModel = context.read<NightlightViewModel>();
    if (viewModel.strength != null) {
      _nightlightStrengthController = TextEditingController(
        text: viewModel.strength!.toInt().toString(),
      );
    } else {
      _nightlightStrengthController = TextEditingController();
    }
    viewModel.addListener(() {
      if (viewModel.strength != null) {
        _nightlightStrengthController.text = viewModel.strength!
            .toInt()
            .toString();
      } else {
        _nightlightStrengthController.text = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<NightlightViewModel>();
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          const SelectableText(
            "Nightlight",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          viewModel.strength != null
              ? Row(
                  children: [
                    SizedBox(
                      width: 300,
                      child: Slider(
                        value: viewModel.strength!,
                        onChanged: viewModel.isEnabled
                            ? viewModel.setStrength
                            : null,
                        min: 0.0,
                        max: 100.0,
                        divisions: 100,
                        label: 'Strength',
                      ),
                    ),
                    SizedBox(
                      width: 60,
                      child: TextField(
                        readOnly: viewModel.isEnabled ? false : true,
                        controller: _nightlightStrengthController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          isDense: true,
                        ),
                        onSubmitted: (textValue) {
                          final value = double.tryParse(textValue);
                          if (value != null) {
                            viewModel.setStrength(value.clamp(0.0, 100.0));
                            _nightlightStrengthController.text = value
                                .clamp(0.0, 100.0)
                                .toInt()
                                .toString();
                          } else {
                            // Reset to current value if parsing fails
                            _nightlightStrengthController.text = viewModel
                                .strength!
                                .toInt()
                                .toString();
                          }
                        },
                      ),
                    ),
                  ],
                )
              : SizedBox.shrink(),
          Switch(value: viewModel.isEnabled, onChanged: viewModel.setActive),
        ],
      ),
    );
  }
}
