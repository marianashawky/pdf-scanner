import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const primary = Color(0xFF2EE8D4);
  static const primaryForeground = Color(0xFF0B1418);
  static const primaryGlow = Color(0x472EE8D4);
  static const studio = Color(0xFF161C24);
  static const studioMuted = Color(0xFF1C232C);
  static const success = Color(0xFF3DCC7A);
  static const danger = Color(0xFFE86A5A);

  static const darkBackground = Color(0xFF0C1016);
  static const darkForeground = Color(0xFFF7FAFB);
  static const darkMuted = Color(0xFF232B33);
  static const darkMutedForeground = Color(0xFFC8D2D8);
  static const darkBorder = Color(0x33FFFFFF);

  static const lightBackground = Color(0xFFF3F6F7);
  static const lightForeground = Color(0xFF1A2229);
  static const lightMuted = Color(0xFFE6EEF0);
  static const lightMutedForeground = Color(0xFF5C6B74);
  static const lightBorder = Color(0x1A1A2229);

  static const paper = Color(0xFFF7F8F8);
  static const paperInk = Color(0xFF151A1F);
  static const navBar = Color(0xFFF4F6F7);
}

class StudioPalette extends ThemeExtension<StudioPalette> {
  const StudioPalette({
    required this.background,
    required this.foreground,
    required this.muted,
    required this.mutedForeground,
    required this.card,
    required this.cardForeground,
    required this.iconWell,
    required this.iconWellForeground,
    required this.border,
    required this.hero,
    required this.navBar,
    required this.scanButton,
    required this.scanIcon,
    required this.softShadow,
  });

  final Color background;
  final Color foreground;
  final Color muted;
  final Color mutedForeground;
  final Color card;
  final Color cardForeground;
  final Color iconWell;
  final Color iconWellForeground;
  final Color border;
  final Color hero;
  final Color navBar;
  final Color scanButton;
  final Color scanIcon;
  final Color softShadow;

  static const dark = StudioPalette(
    background: AppColors.darkBackground,
    foreground: AppColors.darkForeground,
    muted: AppColors.darkMuted,
    mutedForeground: AppColors.darkMutedForeground,
    card: Color(0xFF171E26),
    cardForeground: AppColors.darkForeground,
    iconWell: Color(0xFF222B34),
    iconWellForeground: AppColors.primary,
    border: AppColors.darkBorder,
    hero: Color(0xFF12181F),
    navBar: Color(0xFF151C24),
    scanButton: AppColors.primary,
    scanIcon: AppColors.primaryForeground,
    softShadow: Color(0x66000000),
  );

  static const light = StudioPalette(
    background: AppColors.lightBackground,
    foreground: AppColors.lightForeground,
    muted: AppColors.lightMuted,
    mutedForeground: AppColors.lightMutedForeground,
    card: Colors.white,
    cardForeground: AppColors.lightForeground,
    iconWell: Color(0xFFE8F7F5),
    iconWellForeground: AppColors.lightForeground,
    border: AppColors.lightBorder,
    hero: AppColors.studio,
    navBar: Colors.white,
    scanButton: AppColors.primary,
    scanIcon: AppColors.primaryForeground,
    softShadow: Color(0x14151A22),
  );

  static StudioPalette of(BuildContext context) {
    return Theme.of(context).extension<StudioPalette>() ?? dark;
  }

  @override
  StudioPalette copyWith({
    Color? background,
    Color? foreground,
    Color? muted,
    Color? mutedForeground,
    Color? card,
    Color? cardForeground,
    Color? iconWell,
    Color? iconWellForeground,
    Color? border,
    Color? hero,
    Color? navBar,
    Color? scanButton,
    Color? scanIcon,
    Color? softShadow,
  }) {
    return StudioPalette(
      background: background ?? this.background,
      foreground: foreground ?? this.foreground,
      muted: muted ?? this.muted,
      mutedForeground: mutedForeground ?? this.mutedForeground,
      card: card ?? this.card,
      cardForeground: cardForeground ?? this.cardForeground,
      iconWell: iconWell ?? this.iconWell,
      iconWellForeground: iconWellForeground ?? this.iconWellForeground,
      border: border ?? this.border,
      hero: hero ?? this.hero,
      navBar: navBar ?? this.navBar,
      scanButton: scanButton ?? this.scanButton,
      scanIcon: scanIcon ?? this.scanIcon,
      softShadow: softShadow ?? this.softShadow,
    );
  }

  @override
  StudioPalette lerp(ThemeExtension<StudioPalette>? other, double t) {
    if (other is! StudioPalette) return this;
    return StudioPalette(
      background: Color.lerp(background, other.background, t)!,
      foreground: Color.lerp(foreground, other.foreground, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      mutedForeground: Color.lerp(mutedForeground, other.mutedForeground, t)!,
      card: Color.lerp(card, other.card, t)!,
      cardForeground: Color.lerp(cardForeground, other.cardForeground, t)!,
      iconWell: Color.lerp(iconWell, other.iconWell, t)!,
      iconWellForeground: Color.lerp(iconWellForeground, other.iconWellForeground, t)!,
      border: Color.lerp(border, other.border, t)!,
      hero: Color.lerp(hero, other.hero, t)!,
      navBar: Color.lerp(navBar, other.navBar, t)!,
      scanButton: Color.lerp(scanButton, other.scanButton, t)!,
      scanIcon: Color.lerp(scanIcon, other.scanIcon, t)!,
      softShadow: Color.lerp(softShadow, other.softShadow, t)!,
    );
  }
}
