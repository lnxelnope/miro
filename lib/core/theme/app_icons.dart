import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Centralized icon configuration
/// Replaces emoji with Material Icons + colors that match the teal theme
class AppIcons {
  // ───────────────────────────────────────────────────────────
  // ENERGY & GAMIFICATION
  // ───────────────────────────────────────────────────────────
  
  static const IconData energy = Icons.bolt_rounded;
  static const Color energyColor = Color(0xFFF59E0B); // Amber-500
  
  static const IconData streak = Icons.local_fire_department_rounded;
  static const Color streakColor = Color(0xFFFF5722); // Deep Orange-500
  
  static const IconData milestone = Icons.emoji_events_rounded;
  static const Color milestoneColor = Color(0xFFF59E0B); // Amber-500
  
  static const IconData challenge = Icons.checklist_rounded;
  static const Color challengeColor = Color(0xFF3B82F6); // Blue-500
  
  static const IconData randomBonus = Icons.casino_rounded;
  static const Color randomBonusColor = Color(0xFF9C27B0); // Purple-600
  
  static const IconData target = Icons.track_changes_rounded;
  static const Color targetColor = Color(0xFF3B82F6); // Blue-500
  
  static const IconData celebration = Icons.celebration_rounded;
  static const Color celebrationColor = Color(0xFF22C55E); // Green-500
  
  static const IconData gift = Icons.card_giftcard_rounded;
  static const Color giftColor = Color(0xFFEC4899); // Pink-500
  
  static const IconData discount = Icons.local_offer_rounded;
  static const Color discountColor = Color(0xFFFF5722); // Deep Orange-500
  
  // ───────────────────────────────────────────────────────────
  // TIERS
  // ───────────────────────────────────────────────────────────
  
  static const IconData tierStarter = Icons.star_rounded;
  static const Color tierStarterColor = Color(0xFFFBBF24); // Amber-400
  
  static const IconData tierBronze = Icons.workspace_premium_outlined;
  static const Color tierBronzeColor = Color(0xFFCD7F32); // Bronze
  
  static const IconData tierSilver = Icons.workspace_premium_outlined;
  static const Color tierSilverColor = Color(0xFFC0C0C0); // Silver
  
  static const IconData tierGold = Icons.workspace_premium_outlined;
  static const Color tierGoldColor = Color(0xFFFFD700); // Gold
  
  static const IconData tierDiamond = Icons.diamond_outlined;
  static const Color tierDiamondColor = AppColors.primary; // Teal
  
  // ───────────────────────────────────────────────────────────
  // FOOD & HEALTH
  // ───────────────────────────────────────────────────────────
  
  static const IconData meal = Icons.restaurant_rounded;
  static const Color mealColor = Color(0xFFF97316); // Orange-500
  
  static const IconData calories = Icons.local_fire_department_rounded;
  static const Color caloriesColor = Color(0xFFFF5722); // Deep Orange-500
  
  static const IconData macros = Icons.fitness_center_rounded;
  static const Color macrosColor = Color(0xFF1E40AF); // Blue-700
  
  static const IconData breakfast = Icons.wb_twilight_rounded;
  static const Color breakfastColor = Color(0xFFFB923C); // Orange-400
  
  static const IconData lunch = Icons.wb_sunny_rounded;
  static const Color lunchColor = Color(0xFFF59E0B); // Amber-500
  
  static const IconData dinner = Icons.nightlight_rounded;
  static const Color dinnerColor = Color(0xFF4F46E5); // Indigo-600
  
  static const IconData snack = Icons.fastfood_rounded;
  static const Color snackColor = Color(0xFFFB923C); // Orange-400
  
  static const IconData statistics = Icons.bar_chart_rounded;
  static const Color statisticsColor = Color(0xFF3B82F6); // Blue-500
  
  // ───────────────────────────────────────────────────────────
  // AI & ANALYSIS
  // ───────────────────────────────────────────────────────────
  
  static const IconData ai = Icons.smart_toy_rounded;
  static const Color aiColor = AppColors.primary; // Teal
  
  static const IconData aiAnalyzed = Icons.auto_awesome_rounded;
  static const Color aiAnalyzedColor = Color(0xFF9C27B0); // Purple-600
  
  static const IconData camera = Icons.photo_camera_rounded;
  static const Color cameraColor = Color(0xFF3B82F6); // Blue-500
  
  static const IconData search = Icons.search_rounded;
  static const Color searchColor = Color(0xFF6B7280); // Gray-500
  
  static const IconData science = Icons.science_rounded;
  static const Color scienceColor = Color(0xFF9C27B0); // Purple-600
  
  // ───────────────────────────────────────────────────────────
  // STATUS & ACTIONS
  // ───────────────────────────────────────────────────────────
  
  static const IconData success = Icons.check_circle_rounded;
  static const Color successColor = Color(0xFF22C55E); // Green-500
  
  static const IconData error = Icons.cancel_rounded;
  static const Color errorColor = Color(0xFFEF4444); // Red-500
  
  static const IconData warning = Icons.warning_amber_rounded;
  static const Color warningColor = Color(0xFFF59E0B); // Amber-500
  
  static const IconData info = Icons.info_outline_rounded;
  static const Color infoColor = Color(0xFF3B82F6); // Blue-500
  
  static const IconData tips = Icons.lightbulb_outline_rounded;
  static const Color tipsColor = Color(0xFFF59E0B); // Amber-500
  
  static const IconData edit = Icons.edit_rounded;
  static const Color editColor = Color(0xFF6B7280); // Gray-500
  
  static const IconData save = Icons.save_rounded;
  static const Color saveColor = Color(0xFF3B82F6); // Blue-500
  
  static const IconData repeat = Icons.repeat_rounded;
  static const Color repeatColor = Color(0xFF3B82F6); // Blue-500
  
  static const IconData timer = Icons.schedule_rounded;
  static const Color timerColor = Color(0xFF6B7280); // Gray-500
  
  static const IconData calendar = Icons.calendar_today_rounded;
  static const Color calendarColor = Color(0xFF6B7280); // Gray-500
  
  // ───────────────────────────────────────────────────────────
  // MISC
  // ───────────────────────────────────────────────────────────
  
  static const IconData subscription = Icons.diamond_outlined;
  static const Color subscriptionColor = AppColors.primary; // Teal
  
  static const IconData money = Icons.attach_money_rounded;
  static const Color moneyColor = Color(0xFF22C55E); // Green-500
  
  static const IconData device = Icons.smartphone_rounded;
  static const Color deviceColor = Color(0xFF6B7280); // Gray-500
  
  static const IconData infinity = Icons.all_inclusive_rounded;
  static const Color infinityColor = Color(0xFF6B7280); // Gray-500
  
  static const IconData package = Icons.inventory_2_outlined;
  static const Color packageColor = Color(0xFF8B4513); // Brown
  
  static const IconData launch = Icons.rocket_launch_rounded;
  static const Color launchColor = AppColors.primary; // Teal
  
  // ───────────────────────────────────────────────────────────
  // HELPER METHODS
  // ───────────────────────────────────────────────────────────
  
  /// Create an icon with consistent styling
  static Widget icon(
    IconData iconData, {
    Color? color,
    double size = 20,
  }) {
    return Icon(iconData, color: color, size: size);
  }
  
  /// Create an icon with label (replaces emoji + text pattern)
  static Widget iconWithLabel(
    IconData iconData,
    String label, {
    Color? iconColor,
    Color? textColor,
    double iconSize = 20,
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.normal,
    double spacing = 8,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(iconData, color: iconColor, size: iconSize),
        SizedBox(width: spacing),
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
