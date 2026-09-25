import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';

class StudioNavBar extends StatelessWidget {
  const StudioNavBar({
    super.key,
    required this.index,
    required this.onSelect,
    required this.onScan,
  });

  final int index;
  final ValueChanged<int> onSelect;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    final palette = StudioPalette.of(context);
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final idle = isDark ? const Color(0xFFB7C2C9) : const Color(0xFF6B7780);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: SizedBox(
        height: 86,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              height: 72,
              decoration: BoxDecoration(
                color: palette.navBar,
                borderRadius: BorderRadius.circular(36),
                boxShadow: [
                  BoxShadow(
                    color: palette.softShadow,
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  _NavItem(
                    icon: Icons.home_outlined,
                    label: l10n.home,
                    selected: index == 0,
                    idle: idle,
                    onTap: () => onSelect(0),
                  ),
                  _NavItem(
                    icon: Icons.crop_free_rounded,
                    label: l10n.scan,
                    selected: false,
                    idle: idle,
                    hidden: true,
                    onTap: onScan,
                  ),
                  _NavItem(
                    icon: Icons.insert_drive_file_outlined,
                    label: l10n.files,
                    selected: index == 1,
                    idle: idle,
                    onTap: () => onSelect(1),
                  ),
                  _NavItem(
                    icon: Icons.auto_fix_high_outlined,
                    label: l10n.tools,
                    selected: index == 2,
                    idle: idle,
                    onTap: () => onSelect(2),
                  ),
                  _NavItem(
                    icon: Icons.settings_outlined,
                    label: l10n.settings,
                    selected: index == 3,
                    idle: idle,
                    onTap: () => onSelect(3),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              child: GestureDetector(
                onTap: onScan,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: palette.scanButton,
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(color: AppColors.primaryGlow, blurRadius: 22, offset: Offset(0, 8)),
                    ],
                    border: Border.all(color: palette.navBar, width: 6),
                  ),
                  child: Icon(Icons.crop_free_rounded, color: palette.scanIcon, size: 26),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.idle,
    this.hidden = false,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color idle;
  final bool hidden;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : idle;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Opacity(
          opacity: hidden ? 0 : 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                style: studioText(
                  context: context,
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
