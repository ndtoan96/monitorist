import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Overview')),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(children: [NightlightPanel(initStrength: 50.0, initEnabled: true), MonitorsPanel()]),
            ),
          ),
          Expanded(flex: 1, child: Container(color: Colors.greenAccent)),
        ],
      ),
    );
  }
}

class MonitorsPanel extends StatelessWidget {
  const MonitorsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Monitors",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        Column(
          children: [
            MonitorItem(name: "Monitor 1", initBrightness: 40.0),
            MonitorItem(name: "A very looooooooong name", initBrightness: 30.0),
          ],
        ),
      ],
    );
  }
}

class MonitorItem extends StatefulWidget {
  final String name;
  final double initBrightness;
  final Function(double)? onBrightnessChanged;

  const MonitorItem({
    super.key,
    required this.name,
    required this.initBrightness,
    this.onBrightnessChanged,
  });

  @override
  State<MonitorItem> createState() => _MonitorItemState();
}

class _MonitorItemState extends State<MonitorItem> {
  double _brightness = 0.0;
  @override
  void initState() {
    super.initState();
    _brightness = widget.initBrightness;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          widget.name,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Spacer(),
        Row(
          children: [
            SizedBox(
              width: 300,
              child: Slider(
                value: _brightness,
                onChanged: (value) {
                  if (widget.onBrightnessChanged != null) {
                    widget.onBrightnessChanged!(value);
                  }
                  setState(() {
                    _brightness = value;
                  });
                },
                min: 0.0,
                max: 100.0,
                divisions: 100,
                label: "Brightness",
              ),
            ),
            Text(
              "${_brightness.toInt()}",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ],
    );
  }
}

class NightlightPanel extends StatefulWidget {
  final double initStrength;
  final bool initEnabled;
  final Function(double)? onStrengthChanged;
  final Function(bool)? onEnabledChanged;

  const NightlightPanel({
    super.key,
    required this.initStrength,
    required this.initEnabled,
    this.onStrengthChanged,
    this.onEnabledChanged,
  });

  @override
  State<NightlightPanel> createState() => _NightlightPanelState();
}

class _NightlightPanelState extends State<NightlightPanel> {
  double _strength = 0.0;
  bool _isEnabled = false;

  @override
  void initState() {
    super.initState();
    _strength = 50.0;
    _isEnabled = true;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,

      children: [
        const Text(
          "Nightlight",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        Row(
          children: [
            SizedBox(
              width: 300,
              child: Slider(
                value: _strength,
                onChanged: _isEnabled
                    ? (double value) {
                        if (widget.onStrengthChanged != null) {
                          widget.onStrengthChanged!(value);
                        }
                        setState(() {
                          _strength = value;
                        });
                      }
                    : null,
                min: 0.0,
                max: 100.0,
                divisions: 100,
                label: 'Strength',
              ),
            ),
            Text(
              "${_strength.toInt()}",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        Switch(
          value: _isEnabled,
          onChanged: (bool value) {
            if (widget.onEnabledChanged != null) {
              widget.onEnabledChanged!(value);
            }
            setState(() {
              _isEnabled = value;
            });
          },
        ),
      ],
    );
  }
}
