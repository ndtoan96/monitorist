import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
              bool? confirmed = viewModel.isChanged
                  ? await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: Text("Discard changes?"),
                        content: Text(
                          "Are you sure you want to discard your changes?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.of(dialogContext).pop(false),
                            child: Text("No"),
                          ),
                          TextButton(
                            onPressed: () =>
                                Navigator.of(dialogContext).pop(true),
                            child: Text("Yes"),
                          ),
                        ],
                      ),
                    )
                  : true;
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

class MonitorCard extends StatefulWidget {
  final void Function() onRemove;
  const MonitorCard({super.key, required this.onRemove});

  @override
  State<MonitorCard> createState() => _MonitorCardState();
}

class _MonitorCardState extends State<MonitorCard> {
  final TextEditingController _brightnessController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final FocusNode _keyboardFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final viewModel = context.read<EditProfileMonitorViewModel>();
    _brightnessController.text = viewModel.brightness.toString();
    viewModel.addListener(() {
      _brightnessController.text = viewModel.brightness.toString();
    });
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _brightnessController.text = viewModel.brightness.toString();
      }
    });
  }

  @override
  void dispose() {
    _brightnessController.dispose();
    _focusNode.dispose();
    _keyboardFocusNode.dispose();
    super.dispose();
  }

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
                value: viewModel.brightness.toDouble(),
                onChanged: viewModel.exists
                    ? (value) => viewModel.setBrightness(value.round())
                    : null,
                min: 0,
                max: 100,
                divisions: 100,
              ),
              SizedBox(
                width: 60,
                child: KeyboardListener(
                  focusNode: _keyboardFocusNode,
                  onKeyEvent: (event) {
                    if (event is KeyDownEvent &&
                        event.logicalKey == LogicalKeyboardKey.escape) {
                      _focusNode.unfocus();
                    }
                  },
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
                  ),
                ),
              ),
              Spacer(),
              viewModel.exists
                  ? SizedBox.shrink()
                  : IconButton(
                      onPressed: widget.onRemove,
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
  final TextEditingController _nightlightStrengthController =
      TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final FocusNode _keyboardFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final viewModel = context.read<EditProfileNightlightViewModel>();
    if (viewModel.strength != null) {
      _nightlightStrengthController.text = viewModel.strength!.toString();
    }
    viewModel.addListener(() {
      if (viewModel.strength != null) {
        _nightlightStrengthController.text = viewModel.strength!.toString();
      } else {
        _nightlightStrengthController.text = '';
      }
    });
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && viewModel.strength != null) {
        _nightlightStrengthController.text = viewModel.strength!.toString();
      }
    });
  }

  @override
  void dispose() {
    _nightlightStrengthController.dispose();
    _focusNode.dispose();
    _keyboardFocusNode.dispose();
    super.dispose();
  }

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
                    value: viewModel.strength!.toDouble(),
                    onChanged: viewModel.isEnabled
                        ? (value) => viewModel.setStrength(value.round())
                        : null,
                    min: 0,
                    max: 100,
                    divisions: 100,
                  )
                : SizedBox.shrink(),
            viewModel.strength != null
                ? SizedBox(
                    width: 80,
                    child: KeyboardListener(
                      focusNode: _keyboardFocusNode,
                      onKeyEvent: (event) {
                        if (event is KeyDownEvent &&
                            event.logicalKey == LogicalKeyboardKey.escape) {
                          _focusNode.unfocus();
                        }
                      },
                      child: TextField(
                        readOnly: !viewModel.isEnabled,
                        controller: _nightlightStrengthController,
                        focusNode: _focusNode,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          isDense: true,
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onSubmitted: (value) {
                          final strength = int.tryParse(value);
                          if (strength != null) {
                            viewModel.setStrength(strength.clamp(0, 100));
                          } else {
                            _nightlightStrengthController.text = viewModel
                                .strength!
                                .toString();
                          }
                        },
                      ),
                    ),
                  )
                : SizedBox.shrink(),
            Switch(value: viewModel.isEnabled, onChanged: viewModel.setEnabled),
          ],
        ),
      ),
    );
  }
}
