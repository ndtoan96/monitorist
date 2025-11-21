import 'package:flutter/material.dart';
import 'package:monitorist/components/reactive_text_field.dart';
import 'package:monitorist/viewmodels/nightlight_viewmodel.dart';
import 'package:monitorist/viewmodels/theme_viewmodel.dart';
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
        actions: [
          IconButton(
            icon: Icon(
              context.watch<ThemeViewmodel>().isDarkMode
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              context.read<ThemeViewmodel>().toggleTheme();
            },
          ),
        ],
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

class NightlightPanel extends StatelessWidget {
  const NightlightPanel({super.key});

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
                        value: viewModel.strength!.toDouble(),
                        onChanged: viewModel.isEnabled
                            ? (value) => viewModel.setStrength(value.round())
                            : null,
                        min: 0.0,
                        max: 100.0,
                        divisions: 100,
                        label: 'Strength',
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      child: ReactiveTextField(
                        value: viewModel.strength!,
                        setValue: viewModel.setStrength,
                        readOnly: !viewModel.isEnabled,
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
