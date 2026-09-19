import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/paper_visual.dart';
import '../../core/widgets/studio_widgets.dart';
import '../../providers.dart';
import '../onboarding/onboarding_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final palette = StudioPalette.of(context);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 120),
          children: [
            const ScreenHeader(
              title: 'Settings',
              subtitle: 'Make the studio yours.',
            ),
            const SizedBox(height: 22),
            StudioCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: settings.themeMode.isDark,
                activeThumbColor: AppColors.primary,
                secondary: IconWell(
                  icon: settings.themeMode.isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                ),
                title: Text(
                  settings.themeMode.isDark ? 'Dark studio' : 'Light studio',
                  style: GoogleFonts.manrope(fontWeight: FontWeight.w700, color: palette.cardForeground),
                ),
                subtitle: Text(
                  settings.themeMode.isDark ? 'Midnight paper workspace' : 'Bright paper workspace',
                  style: GoogleFonts.manrope(fontSize: 12, color: palette.cardForeground.withValues(alpha: 0.5)),
                ),
                onChanged: (_) => ref.read(settingsProvider.notifier).toggleTheme(),
              ),
            ),
            const SizedBox(height: 12),
            StudioCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  const IconWell(icon: Icons.verified_user_outlined),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Local processing', style: GoogleFonts.manrope(fontWeight: FontWeight.w700, color: palette.cardForeground)),
                        Text(
                          'Files never leave this device',
                          style: GoogleFonts.manrope(fontSize: 12, color: palette.cardForeground.withValues(alpha: 0.5)),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.check_rounded, color: AppColors.success),
                ],
              ),
            ),
            const SizedBox(height: 12),
            StudioCard(
              onTap: () => _chooseQuality(context, ref, settings.quality),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  const IconWell(icon: Icons.speed_rounded),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Default quality', style: GoogleFonts.manrope(fontWeight: FontWeight.w700, color: palette.cardForeground)),
                        Text(
                          settings.quality.label,
                          style: GoogleFonts.manrope(fontSize: 12, color: palette.cardForeground.withValues(alpha: 0.5)),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: palette.cardForeground.withValues(alpha: 0.4)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            StudioCard(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OnboardingScreen())),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  const IconWell(icon: Icons.help_outline_rounded),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Help & tips', style: GoogleFonts.manrope(fontWeight: FontWeight.w700, color: palette.cardForeground)),
                        Text(
                          'Learn the essentials',
                          style: GoogleFonts.manrope(fontSize: 12, color: palette.cardForeground.withValues(alpha: 0.5)),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: palette.cardForeground.withValues(alpha: 0.4)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            StudioCard(
              onTap: () => _clear(context, ref),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  const IconWell(icon: Icons.delete_outline_rounded),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Clear local documents',
                      style: GoogleFonts.manrope(fontWeight: FontWeight.w700, color: palette.cardForeground),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),
            const ScanMarkIcon(color: AppColors.primary, size: 36),
            const SizedBox(height: 10),
            Text(
              AppConstants.appName,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w700, color: palette.foreground),
            ),
            const SizedBox(height: 4),
            Text(
              AppConstants.versionLabel,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(fontSize: 13, color: palette.mutedForeground),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _chooseQuality(BuildContext context, WidgetRef ref, ScanQuality current) async {
    final next = await showModalBottomSheet<ScanQuality>(
      context: context,
      backgroundColor: StudioPalette.of(context).card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: ScanQuality.values.map((quality) {
                return ListTile(
                  title: Text(quality.label, style: GoogleFonts.manrope(fontWeight: FontWeight.w700)),
                  subtitle: Text(quality.subtitle),
                  trailing: quality == current ? const Icon(Icons.check_rounded, color: AppColors.primary) : null,
                  onTap: () => Navigator.pop(context, quality),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
    if (next != null) {
      await ref.read(settingsProvider.notifier).setQuality(next);
    }
  }

  Future<void> _clear(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear all documents?'),
          content: const Text('This permanently deletes locally stored PDFs from this device.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Clear')),
          ],
        );
      },
    );
    if (confirmed == true) {
      await ref.read(documentsProvider.notifier).clearAll();
    }
  }
}
