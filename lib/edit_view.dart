import 'package:flutter/material.dart';
import 'package:monitorist/viewmodels/edit_profile_viewmodel.dart';
import 'package:provider/provider.dart';

class EditView extends StatefulWidget {
  final EditProfileViewmodel _viewmodel;

  const EditView({super.key, required EditProfileViewmodel viewmodel})
    : _viewmodel = viewmodel;

  @override
  State<EditView> createState() => _EditViewState();
}

class _EditViewState extends State<EditView> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget._viewmodel.name);
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
        title: widget._viewmodel.isNew
            ? Text("New Profile")
            : Text("Edit Profile"),
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
                  onChanged: widget._viewmodel.setName,
                ),
              ),
              Checkbox(
                value: widget._viewmodel.preview,
                onChanged: (bool? value) {
                  widget._viewmodel.setPreview(value ?? true);
                },
              ),
              const Text("Preview"),
            ],
          ),
          ChangeNotifierProvider.value(
            value: widget._viewmodel.nightlightCardViewmodel,
            child: Consumer<NightlightCardViewmodel>(
              builder: (context, viewmodel, child) =>
                  NightlightCard(viewmodel: viewmodel),
            ),
          ),
          Divider(),
          Expanded(
            child: ListView(
              children: widget._viewmodel.monitorCardViewmodels
                  .map(
                    (vm) => ChangeNotifierProvider.value(
                      value: vm,
                      child: Consumer<MonitorCardViewmodel>(
                        builder: (context, viewmodel, child) =>
                            MonitorCard(viewmodel: viewmodel),
                      ),
                    ),
                  )
                  .toList(),
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
              widget._viewmodel.saveProfile();
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

class MonitorCard extends StatelessWidget {
  final MonitorCardViewmodel _viewmodel;

  const MonitorCard({super.key, required MonitorCardViewmodel viewmodel})
    : _viewmodel = viewmodel;

  @override
  Widget build(BuildContext context) {
    final card = Card(
      child: Container(
        decoration: _viewmodel.exists
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
                  value: _viewmodel.isIncluded,
                  onChanged: _viewmodel.exists
                      ? (bool? value) {
                          _viewmodel.setIncluded(value ?? true);
                        }
                      : null,
                ),
              ),
              Text(_viewmodel.name),
              Slider(
                value: _viewmodel.brightness,
                onChanged: _viewmodel.exists ? _viewmodel.setBrightness : null,
                min: 0,
                max: 100,
                divisions: 100,
              ),
              Text(_viewmodel.brightness.toInt().toString()),
              Spacer(),
              _viewmodel.exists
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
    if (_viewmodel.exists) {
      return card;
    } else {
      return Tooltip(message: "This monitor does not exist", child: card);
    }
  }
}

class NightlightCard extends StatefulWidget {
  final NightlightCardViewmodel _viewmodel;
  const NightlightCard({super.key, required NightlightCardViewmodel viewmodel})
    : _viewmodel = viewmodel;

  @override
  State<NightlightCard> createState() => _NightlightCardState();
}

class _NightlightCardState extends State<NightlightCard> {
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
                value: widget._viewmodel.isIncluded,
                onChanged: (bool? value) {
                  widget._viewmodel.setIncluded(value ?? true);
                },
              ),
            ),
            Text("Nightlight"),
            widget._viewmodel.strength != null
                ? Slider(
                    value: widget._viewmodel.strength!,
                    onChanged: widget._viewmodel.isEnabled
                        ? widget._viewmodel.setStrength
                        : null,
                    min: 0,
                    max: 100,
                    divisions: 100,
                  )
                : SizedBox.shrink(),
            widget._viewmodel.strength != null
                ? Text(widget._viewmodel.strength!.toInt().toString())
                : SizedBox.shrink(),
            Switch(
              value: widget._viewmodel.isEnabled,
              onChanged: widget._viewmodel.setEnabled,
            ),
          ],
        ),
      ),
    );
  }
}
