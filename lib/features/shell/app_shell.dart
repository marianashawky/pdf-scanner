import 'package:flutter/material.dart';

import '../../core/widgets/ad_banner_slot.dart';
import '../../core/widgets/studio_nav_bar.dart';
import '../files/files_screen.dart';
import '../home/home_screen.dart';
import '../scan/scan_camera_screen.dart';
import '../settings/settings_screen.dart';
import '../tools/tools_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _index = widget.initialIndex;

  void _openScan() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ScanCameraScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          HomeScreen(),
          FilesScreen(),
          ToolsScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AdBannerSlot(),
          StudioNavBar(
            index: _index,
            onSelect: (value) => setState(() => _index = value),
            onScan: _openScan,
          ),
        ],
      ),
    );
  }
}
