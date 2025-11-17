import 'package:flutter/material.dart';
import 'package:monitorist/home_view.dart';
import 'package:monitorist/services/monitors_service.dart';
import 'package:monitorist/services/nightlight_service.dart';
import 'package:monitorist/services/profiles_service.dart';
import 'package:monitorist/src/rust/frb_generated.dart';
import 'package:monitorist/viewmodels/monitors_viewmodel.dart';
import 'package:monitorist/viewmodels/nightlight_viewmodel.dart';
import 'package:monitorist/viewmodels/profiles_viewmodel.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  await RustLib.init();
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => NightlightService()),
        Provider(create: (_) => MonitorsService()),
        Provider(create: (_) => ProfilesService()),
        ChangeNotifierProvider(
          create: (context) => NightlightPanelViewmodel(
            nightlightService: context.read<NightlightService>(),
          ),
        ),
        Provider(
          create: (context) => MonitorsPanelViewmodel(
            monitorsService: context.read<MonitorsService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ProfilesViewmodel(
            profilesService: context.read<ProfilesService>(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Monitorist',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyanAccent),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.cyanAccent,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const HomeView(),
    );
  }
}
