import 'package:flutter/material.dart';
import 'package:monitorist/services/profiles_service.dart';
import 'package:monitorist/viewmodels/editprofile_viewmodel.dart';
import 'package:provider/provider.dart';

class EditView extends StatefulWidget {
  final String name;
  const EditView({super.key, required this.name});

  @override
  State<EditView> createState() => _EditViewState();
}

class _EditViewState extends State<EditView> {
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
    final viewModel = context.watch<EditProfileViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: viewModel.isNew ? Text("New Profile") : Text("Edit Profile"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 300,
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(border: OutlineInputBorder()),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    onChanged: viewModel.setName,
                  ),
                ),
                Checkbox(
                  value: viewModel.preview,
                  onChanged: (bool? value) {
                    viewModel.setPreview(value ?? true);
                  },
                ),
                const Text("Preview"),
              ],
            ),
            SizedBox(height: 16),
            ChangeNotifierProvider.value(
              value: viewModel.editProfileNightlightViewModel,
              child: NightlightCard(),
            ),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: viewModel.editProfileMonitorViewModels
                    .map(
                      (vm) => ChangeNotifierProvider.value(
                        value: vm,
                        child: MonitorCard(
                          onRemove: () {
                            viewModel.removeMonitor(vm.id);
                          },
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: "saveBtn",
            onPressed: () {
              try {
                viewModel.saveProfile();
                viewModel.restoreBaseline();
              } on ProfileException catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(e.message)));
                return;
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(e.toString())));
                return;
              }
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
                viewModel.restoreBaseline();
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
  final void Function() onRemove;
  const MonitorCard({super.key, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<EditProfileMonitorViewModel>();
    final card = Card(
      child: Container(
        decoration: viewModel.exists
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
                  value: viewModel.isIncluded,
                  onChanged: viewModel.exists
                      ? (bool? value) {
                          viewModel.setIncluded(value ?? true);
                        }
                      : null,
                ),
              ),
              Text(viewModel.name),
              Slider(
                value: viewModel.brightness,
                onChanged: viewModel.exists ? viewModel.setBrightness : null,
                min: 0,
                max: 100,
                divisions: 100,
              ),
              Text(viewModel.brightness.toInt().toString()),
              Spacer(),
              viewModel.exists
                  ? SizedBox.shrink()
                  : IconButton(
                      onPressed: onRemove,
                      icon: Icon(Icons.cancel),
                      tooltip: "Remove this monitor from the profile",
                    ),
            ],
          ),
        ),
      ),
    );
    if (viewModel.exists) {
      return card;
    } else {
      return Tooltip(message: "This monitor does not exist", child: card);
    }
  }
}

class NightlightCard extends StatefulWidget {
  const NightlightCard({super.key});

  @override
  State<NightlightCard> createState() => _NightlightCardState();
}

class _NightlightCardState extends State<NightlightCard> {
  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<EditProfileNightlightViewModel>();
    return Card(
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
            Tooltip(
              message: "Include nightlight setting in the profile",
              child: Checkbox(
                value: viewModel.isIncluded,
                onChanged: (bool? value) {
                  viewModel.setIncluded(value ?? true);
                },
              ),
            ),
            Text("Nightlight"),
            viewModel.strength != null
                ? Slider(
                    value: viewModel.strength!,
                    onChanged: viewModel.isEnabled
                        ? viewModel.setStrength
                        : null,
                    min: 0,
                    max: 100,
                    divisions: 100,
                  )
                : SizedBox.shrink(),
            viewModel.strength != null
                ? Text(viewModel.strength!.toInt().toString())
                : SizedBox.shrink(),
            Switch(value: viewModel.isEnabled, onChanged: viewModel.setEnabled),
          ],
        ),
      ),
    );
  }
}
