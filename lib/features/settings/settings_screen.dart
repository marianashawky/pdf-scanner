import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);
    final locale = AppLocale.fromName(settings.localeCode);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 120),
          children: [
            ScreenHeader(
              title: l10n.settings,
              subtitle: l10n.makeStudioYours,
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
                  settings.themeMode.isDark ? l10n.darkStudio : l10n.lightStudio,
                  style: studioText(context: context, fontWeight: FontWeight.w700, color: palette.cardForeground),
                ),
                subtitle: Text(
                  settings.themeMode.isDark ? l10n.darkStudioSub : l10n.lightStudioSub,
                  style: studioText(
                    context: context,
                    fontSize: 12,
                    color: palette.cardForeground.withValues(alpha: 0.72),
                  ),
                ),
                onChanged: (_) => ref.read(settingsProvider.notifier).toggleTheme(),
              ),
            ),
            const SizedBox(height: 12),
            StudioCard(
              onTap: () => _chooseLanguage(context, ref, locale),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  const IconWell(icon: Icons.language_rounded),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.language,
                          style: studioText(context: context, fontWeight: FontWeight.w700, color: palette.cardForeground),
                        ),
                        Text(
                          locale.nativeLabel,
                          style: studioText(
                            context: context,
                            fontSize: 12,
                            color: palette.cardForeground.withValues(alpha: 0.72),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: palette.cardForeground.withValues(alpha: 0.55)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            StudioCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: settings.autoEnhance,
                activeThumbColor: AppColors.primary,
                secondary: const IconWell(icon: Icons.auto_fix_high_rounded),
                title: Text(
                  l10n.autoEnhance,
                  style: studioText(context: context, fontWeight: FontWeight.w700, color: palette.cardForeground),
                ),
                subtitle: Text(
                  l10n.autoEnhanceSub,
                  style: studioText(
                    context: context,
                    fontSize: 12,
                    color: palette.cardForeground.withValues(alpha: 0.72),
                  ),
                ),
                onChanged: (value) => ref.read(settingsProvider.notifier).setAutoEnhance(value),
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
                        Text(
                          l10n.localProcessing,
                          style: studioText(context: context, fontWeight: FontWeight.w700, color: palette.cardForeground),
                        ),
                        Text(
                          l10n.filesNeverLeave,
                          style: studioText(
                            context: context,
                            fontSize: 12,
                            color: palette.cardForeground.withValues(alpha: 0.72),
                          ),
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
                        Text(
                          l10n.defaultQuality,
                          style: studioText(context: context, fontWeight: FontWeight.w700, color: palette.cardForeground),
                        ),
                        Text(
                          l10n.qualityLabel(settings.quality),
                          style: studioText(
                            context: context,
                            fontSize: 12,
                            color: palette.cardForeground.withValues(alpha: 0.72),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: palette.cardForeground.withValues(alpha: 0.55)),
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
                        Text(
                          l10n.helpTips,
                          style: studioText(context: context, fontWeight: FontWeight.w700, color: palette.cardForeground),
                        ),
                        Text(
                          l10n.learnEssentials,
                          style: studioText(
                            context: context,
                            fontSize: 12,
                            color: palette.cardForeground.withValues(alpha: 0.72),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: palette.cardForeground.withValues(alpha: 0.55)),
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
                      l10n.clearLocalDocs,
                      style: studioText(context: context, fontWeight: FontWeight.w700, color: palette.cardForeground),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),
            const ScanMarkIcon(color: AppColors.primary, size: 36),
            const SizedBox(height: 10),
            Text(
              l10n.appName,
              textAlign: TextAlign.center,
              style: studioText(context: context, fontSize: 18, fontWeight: FontWeight.w700, color: palette.foreground),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.versionLabel,
              textAlign: TextAlign.center,
              style: studioText(context: context, fontSize: 13, color: palette.mutedForeground),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _chooseLanguage(BuildContext context, WidgetRef ref, AppLocale current) async {
    final l10n = AppLocalizations.of(context);
    final next = await showModalBottomSheet<AppLocale>(
      context: context,
      backgroundColor: StudioPalette.of(context).card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.chooseLanguage,
                  style: studioText(context: context, fontWeight: FontWeight.w800, fontSize: 18),
                ),
                const SizedBox(height: 8),
                ...AppLocale.values.map((locale) {
                  return ListTile(
                    title: Text(
                      locale.nativeLabel,
                      style: studioText(context: context, fontWeight: FontWeight.w700, color: StudioPalette.of(context).cardForeground),
                    ),
                    trailing: locale == current ? const Icon(Icons.check_rounded, color: AppColors.primary) : null,
                    onTap: () => Navigator.pop(context, locale),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
    if (next != null) {
      await ref.read(settingsProvider.notifier).setLocaleCode(next.name);
    }
  }

  Future<void> _chooseQuality(BuildContext context, WidgetRef ref, ScanQuality current) async {
    final l10n = AppLocalizations.of(context);
    final next = await showModalBottomSheet<ScanQuality>(
      context: context,
      backgroundColor: StudioPalette.of(context).card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) {
        final palette = StudioPalette.of(context);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: ScanQuality.values.map((quality) {
                return ListTile(
                  title: Text(
                    l10n.qualityLabel(quality),
                    style: studioText(context: context, fontWeight: FontWeight.w700, color: palette.cardForeground),
                  ),
                  subtitle: Text(
                    l10n.qualitySubtitle(quality),
                    style: studioText(context: context, color: palette.cardForeground.withValues(alpha: 0.7)),
                  ),
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
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.clearAllTitle),
          content: Text(l10n.clearAllBody),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
            TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.clear)),
          ],
        );
      },
    );
    if (confirmed == true) {
      await ref.read(documentsProvider.notifier).clearAll();
    }
  }
}
