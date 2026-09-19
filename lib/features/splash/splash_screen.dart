import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/paper_visual.dart';
import '../../core/widgets/studio_widgets.dart';
import '../../providers.dart';
import '../onboarding/onboarding_screen.dart';
import '../shell/app_shell.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 900), _enter);
  }

  void _enter() {
    if (!mounted) return;
    final onboarded = ref.read(settingsProvider).hasOnboarded;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => onboarded ? const AppShell() : const OnboardingScreen(),
        transitionsBuilder: (_, animation, _, child) => FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 420),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
          child: Column(
            children: [
              const Spacer(),
              const PaperVisual(size: 196)
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .scale(begin: const Offset(0.92, 0.92), curve: Curves.easeOutCubic),
              const SizedBox(height: 36),
              Text(
                'PRIVATE BY DESIGN',
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  letterSpacing: 2.4,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Your documents.\nOnly on your device.',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  fontSize: 34,
                  height: 1.1,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1.2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Scan, polish, and organize PDFs with studio-quality tools. No account. No uploads.',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  fontSize: 15,
                  height: 1.45,
                  color: AppColors.darkMutedForeground,
                ),
              ),
              const Spacer(),
              StudioButton(
                label: 'Enter your studio  >',
                onPressed: _enter,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.verified_user_outlined, size: 16, color: AppColors.darkMutedForeground),
                  const SizedBox(width: 6),
                  Text(
                    '100% local processing',
                    style: GoogleFonts.manrope(fontSize: 13, color: AppColors.darkMutedForeground),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
