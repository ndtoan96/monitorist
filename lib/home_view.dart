import 'package:flutter/material.dart';
import 'package:monitorist/edit_view.dart';
import 'package:monitorist/services/monitors_service.dart';
import 'package:monitorist/services/nightlight_service.dart';
import 'package:monitorist/viewmodels/edit_profile_viewmodel.dart';
import 'package:monitorist/viewmodels/monitors_viewmodel.dart';
import 'package:monitorist/viewmodels/nightlight_viewmodel.dart';
import 'package:monitorist/viewmodels/profiles_viewmodel.dart';
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
                  Consumer<NightlightPanelViewmodel>(
                    builder: (context, viewModel, child) {
                      return NightlightPanel(viewModel: viewModel);
                    },
                  ),
                  Divider(),
                  Expanded(
                    child: Consumer<MonitorsPanelViewmodel>(
                      builder: (context, viewModel, child) {
                        return MonitorsPanel(viewModel: viewModel);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          VerticalDivider(),
          Expanded(
            flex: 1,
            child: Consumer<ProfilesViewmodel>(
              builder: (context, viewModel, child) {
                return ProfilesPanel(viewModel: viewModel);
              },
            ),
          ),
          SizedBox(width: 8),
        ],
      ),
    );
  }
}

class ProfilesPanel extends StatelessWidget {
  final ProfilesViewmodel _viewModel;
  const ProfilesPanel({super.key, required ProfilesViewmodel viewModel})
    : _viewModel = viewModel;

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
            children: _viewModel.profiles
                .map((profile) => profile.name)
                .map(
                  (name) => ProfileItem(
                    name: name,
                    onDelete: _viewModel.deleteProfile,
                  ),
                )
                .toList(),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: Card(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextButton.icon(
              onPressed: () {
                final editorProfileViewmodel = EditProfileViewmodel.newProfile(
                  nightlightService: context.read<NightlightService>(),
                  monitorsService: context.read<MonitorsService>(),
                  profilesViewmodel: context.read<ProfilesViewmodel>(),
                );
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ChangeNotifierProvider.value(
                      value: editorProfileViewmodel,
                      child: Consumer<EditProfileViewmodel>(
                        builder: (context, viewmodel, child) =>
                            EditView(viewmodel: viewmodel),
                      ),
                    ),
                  ),
                );
              },
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
  final void Function(String) onDelete;
  const ProfileItem({super.key, required this.name, required this.onDelete});

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
              onPressed: () {},
              // => Navigator.of(context).push(
              //   MaterialPageRoute(
              //     builder: (context) => EditView.editProfile(name: name),
              //   ),
              // ),
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
                  onDelete(name);
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

class MonitorsPanel extends StatefulWidget {
  final MonitorsPanelViewmodel _viewModel;
  const MonitorsPanel({super.key, required MonitorsPanelViewmodel viewModel})
    : _viewModel = viewModel;

  @override
  State<MonitorsPanel> createState() => _MonitorsPanelState();
}

class _MonitorsPanelState extends State<MonitorsPanel> {
  List<MonitorItemViewmodel> _monitorViewmodels = [];
  @override
  void initState() {
    super.initState();
    widget._viewModel.getMonitorItemViewModels().then((value) {
      setState(() {
        _monitorViewmodels = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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
    final monitorItems = _monitorViewmodels.map((vm) {
      return ChangeNotifierProvider.value(
        value: vm,
        child: Consumer<MonitorItemViewmodel>(
          builder: (context, vm, child) => MonitorItem(viewModel: vm),
        ),
      );
    }).toList();
    final body = Expanded(child: ListView(children: monitorItems));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [head, SizedBox(height: 8), body],
    );
  }
}

class MonitorItem extends StatefulWidget {
  final MonitorItemViewmodel _viewmodel;

  const MonitorItem({super.key, required MonitorItemViewmodel viewModel})
    : _viewmodel = viewModel;

  @override
  State<MonitorItem> createState() => _MonitorItemState();
}

class _MonitorItemState extends State<MonitorItem> {
  @override
  void initState() {
    super.initState();
    widget._viewmodel.loadSettings();
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
                widget._viewmodel.name,
                style: TextStyle(fontSize: 18),
              ),
            ),
            Row(
              children: [
                SizedBox(
                  width: 300,
                  child: Slider(
                    value: widget._viewmodel.brightness,
                    onChanged: widget._viewmodel.setBrightness,
                    min: 0.0,
                    max: 100.0,
                    divisions: 100,
                    label: "Brightness",
                  ),
                ),
                Text(
                  "${widget._viewmodel.brightness.toInt()}",
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

class NightlightPanel extends StatelessWidget {
  final NightlightPanelViewmodel _viewModel;

  const NightlightPanel({
    super.key,
    required NightlightPanelViewmodel viewModel,
  }) : _viewModel = viewModel;

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
          _viewModel.strength != null
              ? Row(
                  children: [
                    SizedBox(
                      width: 300,
                      child: Slider(
                        value: _viewModel.strength!,
                        onChanged: _viewModel.isEnabled
                            ? _viewModel.setStrength
                            : null,
                        min: 0.0,
                        max: 100.0,
                        divisions: 100,
                        label: 'Strength',
                      ),
                    ),
                    Text(
                      "${_viewModel.strength!.toInt()}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                )
              : SizedBox.shrink(),
          Switch(value: _viewModel.isEnabled, onChanged: _viewModel.setActive),
        ],
      ),
    );
  }
}
