import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
  );

  try {
    await container.read(adsServiceProvider).initialize();
  } catch (_) {
    // Ads are optional; the studio still works fully offline.
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const PdfScannerApp(),
    ),
  );
}
