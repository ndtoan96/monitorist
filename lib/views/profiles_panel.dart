import 'package:flutter/material.dart';
import 'package:monitorist/viewmodels/editprofile_viewmodel.dart';
import 'package:monitorist/viewmodels/monitors_viewmodel.dart';
import 'package:monitorist/viewmodels/nightlight_viewmodel.dart';
import 'package:monitorist/viewmodels/profiles_viewmodel.dart';
import 'package:monitorist/views/edit_view.dart';
import 'package:provider/provider.dart';

class ProfilesPanel extends StatelessWidget {
  const ProfilesPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProfilesViewModel>();
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
            children: viewModel.profiles
                .map((profile) => profile.name)
                .map(
                  (name) => ProfileItem(
                    name: name,
                    onSet: viewModel.applyProfile,
                    onDelete: viewModel.deleteProfile,
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
                final editProfileViewmodel = EditProfileViewModel.newProfile(
                  nightlightViewModel: context.read<NightlightViewModel>(),
                  monitorsViewModel: context.read<MonitorsViewModel>(),
                  profilesViewmodel: context.read<ProfilesViewModel>(),
                );
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ChangeNotifierProvider.value(
                      value: editProfileViewmodel,
                      child: EditView(name: editProfileViewmodel.name),
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
  final void Function(String) onSet;
  final void Function(String) onDelete;
  const ProfileItem({
    super.key,
    required this.name,
    required this.onSet,
    required this.onDelete,
  });

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
              onPressed: () => onSet(name),
              icon: Icon(Icons.check),
              label: Text("Apply"),
            ),
            TextButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    final editProfileViewmodel =
                        EditProfileViewModel.editProfile(
                          name: name,
                          nightlightViewModel: context
                              .read<NightlightViewModel>(),
                          monitorsViewModel: context.read<MonitorsViewModel>(),
                          profilesViewmodel: context.read<ProfilesViewModel>(),
                        );
                    return ChangeNotifierProvider.value(
                      value: editProfileViewmodel,
                      child: EditView(name: name),
                    );
                  },
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
