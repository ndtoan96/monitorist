import 'package:flutter/material.dart';

class EditView extends StatefulWidget {
  final bool isNew;
  final String name;
  const EditView.newProfile({super.key}) : isNew = true, name = "New Profile";
  const EditView.editProfile({super.key, required this.name}) : isNew = false;

  @override
  State<EditView> createState() => _EditViewState();
}

class _EditViewState extends State<EditView> {
  bool _preview = true;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.isNew ? Text("New Profile") : Text("Edit Profile"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(border: OutlineInputBorder()),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  onChanged: (value) {
                    // Handle name change if needed
                  },
                ),
              ),
              Checkbox(
                value: _preview,
                onChanged: (bool? value) {
                  setState(() {
                    _preview = value ?? true;
                  });
                },
              ),
              const Text("Preview"),
            ],
          ),
          NightlightCard(strength: 50),
          Divider(),
          Expanded(
            child: ListView(
              children: [
                MonitorCard(name: "Monitor 1", brightness: 50),
                MonitorCard(name: "Monitor 2", brightness: 50),
                MonitorCard(name: "Monitor 3", brightness: 50),
                MonitorCard(name: "Monitor 4", brightness: 50),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: () {
              // Save profile changes
            },
            child: Icon(Icons.save),
          ),
          SizedBox(width: 16),
          FloatingActionButton(
            onPressed: () {
              // Cancel editing
            },
            child: Icon(Icons.cancel),
          ),
        ],
      ),
    );
  }
}

class MonitorCard extends StatefulWidget {
  final String name;
  final double brightness;

  const MonitorCard({super.key, required this.name, required this.brightness});

  @override
  State<MonitorCard> createState() => _MonitorCardState();
}

class _MonitorCardState extends State<MonitorCard> {
  bool _included = true;
  late double _brightness;

  @override
  void initState() {
    super.initState();
    _brightness = widget.brightness;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Tooltip(
              message: "Include this monitor in the profile",
              child: Checkbox(
                value: _included,
                onChanged: (bool? value) {
                  setState(() {
                    _included = value ?? true;
                  });
                },
              ),
            ),
            Text(widget.name),
            Slider(
              value: _brightness,
              onChanged: (double value) {
                setState(() {
                  _brightness = value;
                });
              },
              min: 0,
              max: 100,
              divisions: 100,
            ),
            Text(_brightness.toInt().toString()),
          ],
        ),
      ),
    );
  }
}

class NightlightCard extends StatefulWidget {
  final double strength;
  const NightlightCard({super.key, required this.strength});

  @override
  State<NightlightCard> createState() => _NightlightCardState();
}

class _NightlightCardState extends State<NightlightCard> {
  bool _included = true;
  late double _strength;
  late bool _isEnabled;

  @override
  void initState() {
    super.initState();
    _strength = 50;
    _isEnabled = true;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
            Tooltip(
              message: "Include nightlight setting in the profile",
              child: Checkbox(
                value: _included,
                onChanged: (bool? value) {
                  setState(() {
                    _included = value ?? true;
                  });
                },
              ),
            ),
            Text("Nightlight"),
            Slider(
              value: _strength,
              onChanged: _isEnabled
                  ? (double value) {
                      setState(() {
                        _strength = value;
                      });
                    }
                  : null,
              min: 0,
              max: 100,
              divisions: 100,
            ),
            Text(_strength.toInt().toString()),
            Switch(
              value: _isEnabled,
              onChanged: (bool value) {
                setState(() {
                  _isEnabled = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
