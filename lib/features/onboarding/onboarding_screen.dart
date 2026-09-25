import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/paper_visual.dart';
import '../../core/widgets/studio_widgets.dart';
import '../../providers.dart';
import '../shell/app_shell.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  Future<void> _finish() async {
    await ref.read(settingsProvider.notifier).completeOnboarding();
    if (!mounted) return;
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AppShell()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pages = [
      _OnboardPage(
        eyebrow: l10n.onboard1Eyebrow,
        title: l10n.onboard1Title,
        body: l10n.onboard1Body,
        icon: Icons.verified_user_outlined,
      ),
      _OnboardPage(
        eyebrow: l10n.onboard2Eyebrow,
        title: l10n.onboard2Title,
        body: l10n.onboard2Body,
        icon: Icons.auto_fix_high_outlined,
      ),
      _OnboardPage(
        eyebrow: l10n.onboard3Eyebrow,
        title: l10n.onboard3Title,
        body: l10n.onboard3Body,
        icon: Icons.crop_free_rounded,
      ),
    ];
    final last = _page == pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
          child: Column(
            children: [
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: _finish,
                  child: Text(
                    l10n.skip,
                    style: studioText(
                      context: context,
                      color: AppColors.darkMutedForeground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: pages.length,
                  onPageChanged: (value) => setState(() => _page = value),
                  itemBuilder: (_, index) => pages[index],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(pages.length, (index) {
                  final active = index == _page;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: active ? AppColors.primary : const Color(0xFF2A3138),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 22),
              StudioButton(
                label: last ? l10n.enterStudio : l10n.continueLabel,
                onPressed: () {
                  if (last) {
                    _finish();
                  } else {
                    _controller.nextPage(duration: const Duration(milliseconds: 320), curve: Curves.easeOutCubic);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardPage extends StatelessWidget {
  const _OnboardPage({
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.icon,
  });

  final String eyebrow;
  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        PaperVisual(size: 176, icon: icon),
        const SizedBox(height: 32),
        Text(
          eyebrow,
          style: studioText(
            context: context,
            fontSize: 12,
            letterSpacing: 2.2,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          textAlign: TextAlign.center,
          style: studioText(
            context: context,
            fontSize: 32,
            height: 1.1,
            fontWeight: FontWeight.w700,
            letterSpacing: -1,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          body,
          textAlign: TextAlign.center,
          style: studioText(context: context, fontSize: 15, height: 1.45, color: AppColors.darkMutedForeground),
        ),
        const Spacer(),
      ],
    );
  }
}
