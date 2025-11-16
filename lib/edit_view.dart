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
                MonitorCard(name: "Monitor 4", brightness: 50, existed: false),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: "saveBtn",
            onPressed: () {
              // Save profile changes
              Navigator.of(context).pop();
            },
            child: Icon(Icons.save),
          ),
          SizedBox(width: 16),
          FloatingActionButton(
            heroTag: "cancelBtn",
            onPressed: () async {
              // Cancel editing
              bool? confirmed = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: Text("Discard changes?"),
                  content: Text(
                    "Are you sure you want to discard your changes?",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      child: Text("No"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      child: Text("Yes"),
                    ),
                  ],
                ),
              );
              if (confirmed == true && context.mounted) {
                Navigator.of(context).pop();
              }
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
  final bool existed;

  const MonitorCard({
    super.key,
    required this.name,
    required this.brightness,
    this.existed = true,
  });

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
    final card = Card(
      child: Container(
        decoration: widget.existed
            ? null
            : BoxDecoration(
                border: Border.all(color: Theme.of(context).colorScheme.error),
                borderRadius: BorderRadius.circular(12.0),
                color: Theme.of(context).colorScheme.errorContainer,
              ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Tooltip(
                message: "Include this monitor in the profile",
                child: Checkbox(
                  value: _included,
                  onChanged: widget.existed
                      ? (bool? value) {
                          setState(() {
                            _included = value ?? true;
                          });
                        }
                      : null,
                ),
              ),
              Text(widget.name),
              Slider(
                value: _brightness,
                onChanged: widget.existed
                    ? (double value) {
                        setState(() {
                          _brightness = value;
                        });
                      }
                    : null,
                min: 0,
                max: 100,
                divisions: 100,
              ),
              Text(_brightness.toInt().toString()),
              Spacer(),
              widget.existed
                  ? SizedBox.shrink()
                  : IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.cancel),
                      tooltip: "Remove this monitor from the profile",
                    ),
            ],
          ),
        ),
      ),
    );
    if (widget.existed) {
      return card;
    } else {
      return Tooltip(message: "This monitor does not exist", child: card);
    }
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
