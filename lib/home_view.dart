import 'package:flutter/material.dart';
import 'package:monitorist/edit_view.dart';

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
                  NightlightPanel(initStrength: 50.0, initEnabled: true),
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

class ProfilesPanel extends StatelessWidget {
  const ProfilesPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          margin: EdgeInsets.only(top: 4.0),
          child: Center(
            child: SelectableText(
              "Profiles",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ),
        ),
        SizedBox(height: 8),
        Expanded(
          child: ListView(
            children: [
              ProfileItem(name: "Day profile"),
              ProfileItem(name: "Night profile"),
              ProfileItem(name: "Coding profile"),
              ProfileItem(
                name: "Another profile with a very looooooooong name",
              ),
              ProfileItem(name: "name"),
              ProfileItem(name: "name"),
              ProfileItem(name: "name"),
              ProfileItem(name: "name"),
              ProfileItem(name: "name"),
              ProfileItem(name: "name"),
              ProfileItem(name: "name"),
              ProfileItem(name: "name"),
              ProfileItem(name: "name"),
            ],
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: Card(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const EditView.newProfile(),
                ),
              ),
              icon: Icon(Icons.add),
              label: Text("Add Profile"),
            ),
          ),
        ),
      ],
    );
  }
}

class ProfileItem extends StatelessWidget {
  final String name;
  const ProfileItem({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: SelectableText(
                name,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: Icon(Icons.check),
              label: Text("Set"),
            ),
            TextButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EditView.editProfile(name: name),
                ),
              ),
              icon: Icon(Icons.edit),
              label: Text("Edit"),
            ),
            TextButton.icon(
              onPressed: () async {
                bool? confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("Confirm Deletion"),
                    content: Text(
                      "Are you sure you want to delete the profile '$name'?",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text("Delete"),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  // Delete the profile
                }
              },
              icon: Icon(
                Icons.delete,
                color: Theme.of(context).colorScheme.error,
              ),
              label: Text(
                "Delete",
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        ),
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
        Container(
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
        ),
        SizedBox(height: 8),
        Expanded(
          child: ListView(
            children: [
              MonitorItem(name: "Monitor 1", initBrightness: 40.0),
              MonitorItem(
                name: "A very looooooooong name",
                initBrightness: 30.0,
              ),
              MonitorItem(
                name: "A very looooooooong name",
                initBrightness: 30.0,
              ),
              MonitorItem(
                name: "A very looooooooong name",
                initBrightness: 30.0,
              ),
              MonitorItem(
                name: "A very looooooooong name",
                initBrightness: 30.0,
              ),
              MonitorItem(
                name: "A very looooooooong name",
                initBrightness: 30.0,
              ),
              MonitorItem(
                name: "A very looooooooong name",
                initBrightness: 30.0,
              ),
              MonitorItem(
                name: "A very looooooooong name",
                initBrightness: 30.0,
              ),
              MonitorItem(
                name: "A very looooooooong name",
                initBrightness: 30.0,
              ),
              MonitorItem(
                name: "A very looooooooong name",
                initBrightness: 30.0,
              ),
              MonitorItem(
                name: "A very looooooooong name",
                initBrightness: 30.0,
              ),
              MonitorItem(
                name: "A very looooooooong name",
                initBrightness: 30.0,
              ),
              MonitorItem(
                name: "A very looooooooong name",
                initBrightness: 30.0,
              ),
              MonitorItem(
                name: "A very looooooooong name",
                initBrightness: 30.0,
              ),
            ],
          ),
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
  late double _brightness;
  @override
  void initState() {
    super.initState();
    _brightness = widget.initBrightness;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            Expanded(
              child: SelectableText(
                widget.name,
                style: TextStyle(fontSize: 18),
              ),
            ),
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
        ),
      ),
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
  late double _strength;
  late bool _isEnabled;

  @override
  void initState() {
    super.initState();
    _strength = 50.0;
    _isEnabled = true;
  }

  @override
  Widget build(BuildContext context) {
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
      ),
    );
  }
}
