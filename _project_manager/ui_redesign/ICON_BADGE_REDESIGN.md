# Icon & Badge Redesign — Professional Material Design

**ระยะเวลา:** 3-4 วัน | **Complexity:** 🟡 Medium | **ไฟล์ที่แก้:** 40+ ไฟล์

---

## 🎯 เป้าหมาย

เปลี่ยนระบบ icon/badge ทั้งแอปจาก **emoji** (⚡🔥💎🏆) เป็น **Material Icons** ที่เข้ากับ teal theme ปัจจุบัน เพื่อให้ดู professional และสอดคล้องกับ Material 3 design language

### ปัญหาปัจจุบัน
- ใช้ emoji มากกว่า 30 ตัวทั่วแอป ทำให้ดู "เด็กทำ"
- ไม่สอดคล้องกับ teal theme (Airbnb-inspired)
- Mixed design language (emoji + Material icons)

### เป้าหมายหลังแก้
- ใช้ Material Icons เป็นหลัก (มากับ Flutter ไม่ต้องลง package)
- สีสอดคล้องกับ teal theme
- Design language เดียวกันทั้งแอป

---

## 📊 Emoji-to-Icon Mapping

| Emoji | ใช้ที่ | Material Icon | สีที่ใช้ |
|-------|--------|---------------|----------|
| ⚡ | Energy | `Icons.bolt_rounded` | `Colors.amber.shade600` |
| 🔥 | Streak, Calories | `Icons.local_fire_department_rounded` | `Colors.deepOrange.shade500` |
| 💎 | Diamond tier, Subscription | `Icons.diamond_outlined` | `AppColors.primary` (teal) |
| 🏆 | Milestones | `Icons.emoji_events_rounded` | `Colors.amber.shade600` |
| 🎯 | Targets, Goals | `Icons.track_changes_rounded` | `Colors.blue.shade600` |
| 🎲 | Random bonus | `Icons.casino_rounded` | `Colors.purple.shade600` |
| 🎉 | Success, Celebration | `Icons.celebration_rounded` | `Colors.green.shade600` |
| 🥉 | Bronze tier | `Icons.workspace_premium_outlined` | `Color(0xFFCD7F32)` (bronze) |
| 🥈 | Silver tier | `Icons.workspace_premium_outlined` | `Color(0xFFC0C0C0)` (silver) |
| 🥇 | Gold tier | `Icons.workspace_premium_outlined` | `Color(0xFFFFD700)` (gold) |
| ⭐ | Starter tier | `Icons.star_rounded` | `Colors.amber.shade400` |
| 📋 | Challenges | `Icons.checklist_rounded` | `Colors.blue.shade600` |
| 🍽️ | Meals | `Icons.restaurant_rounded` | `Colors.orange.shade600` |
| 🤖 | AI, Chat | `Icons.smart_toy_rounded` | `AppColors.primary` |
| ⏰ | Time, Timer | `Icons.schedule_rounded` | `Colors.grey.shade600` |
| 📸 | Camera, Photo | `Icons.photo_camera_rounded` | `Colors.blue.shade600` |
| 🔍 | Search, Analyze | `Icons.search_rounded` | `Colors.grey.shade700` |
| 🧬 | Analysis | `Icons.science_rounded` | `Colors.purple.shade600` |
| 📊 | Statistics, Charts | `Icons.bar_chart_rounded` | `Colors.blue.shade600` |
| ✨ | AI analyzed | `Icons.auto_awesome_rounded` | `Colors.purple.shade600` |
| 💡 | Tips | `Icons.lightbulb_outline_rounded` | `Colors.amber.shade600` |
| ✅ | Success | `Icons.check_circle_rounded` | `Colors.green.shade600` |
| ❌ | Error | `Icons.cancel_rounded` | `Colors.red.shade600` |
| 💪 | Health, Macros | `Icons.fitness_center_rounded` | `Colors.blue.shade700` |
| 📝 | Text, Notes | `Icons.edit_note_rounded` | `Colors.grey.shade600` |
| ✏️ | Edit, Manual | `Icons.edit_rounded` | `Colors.grey.shade600` |
| 💾 | Save | `Icons.save_rounded` | `Colors.blue.shade600` |
| 🔄 | Repeat | `Icons.repeat_rounded` | `Colors.blue.shade600` |
| 📅 | Calendar, Date | `Icons.calendar_today_rounded` | `Colors.grey.shade600` |
| 🎁 | Gift, Welcome | `Icons.card_giftcard_rounded` | `Colors.pink.shade400` |
| ℹ️ | Info | `Icons.info_outline_rounded` | `Colors.blue.shade600` |
| ⚠️ | Warning | `Icons.warning_amber_rounded` | `Colors.amber.shade600` |
| 🍎 | Snack (meal) | `Icons.restaurant_rounded` | `Colors.red.shade400` |
| 🌅 | Breakfast | `Icons.wb_twilight_rounded` | `Colors.orange.shade400` |
| 🌞 | Lunch | `Icons.wb_sunny_rounded` | `Colors.amber.shade600` |
| 🌙 | Dinner | `Icons.nightlight_rounded` | `Colors.indigo.shade600` |
| 🍿 | Snack | `Icons.fastfood_rounded` | `Colors.orange.shade400` |
| 💰 | Money, Price | `Icons.attach_money_rounded` | `Colors.green.shade600` |
| 🔒 | Lock, Locked | `Icons.lock_outline_rounded` | `Colors.grey.shade600` |
| 📱 | Device, Mobile | `Icons.smartphone_rounded` | `Colors.grey.shade700` |
| 💚 | Heart, Love | `Icons.favorite_rounded` | `Colors.green.shade600` |
| 🚀 | Start, Launch | `Icons.rocket_launch_rounded` | `AppColors.primary` |
| 📦 | Package, Product | `Icons.inventory_2_outlined` | `Colors.brown.shade500` |
| 🍳 | Food search | `Icons.restaurant_menu_rounded` | `Colors.orange.shade600` |
| ♾️ | Infinity | `Icons.all_inclusive_rounded` | `Colors.grey.shade600` |

---

## 📝 สิ่งที่ต้องทำ

### Phase 1: สร้าง Foundation Classes

#### 1.1 สร้าง `lib/core/theme/app_icons.dart`

```dart
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
```

#### 1.2 เพิ่มสีใน `lib/core/theme/app_colors.dart`

```dart
// เพิ่มใน AppColors class

// Tier colors (for gamification)
static const Color tierBronze = Color(0xFFCD7F32);
static const Color tierSilver = Color(0xFFC0C0C0);
static const Color tierGold = Color(0xFFFFD700);
static const Color tierDiamond = primary; // Teal

// Energy level colors
static const Color energyVeryLow = Color(0xFFEF4444); // Red-500 (< 10)
static const Color energyLow = Color(0xFFF59E0B); // Amber-500 (< 30)
static const Color energyMedium = Color(0xFF10B981); // Emerald-500 (< 100)
static const Color energyHigh = Color(0xFF06B6D4); // Cyan-500 (≥ 100)
```

---

### Phase 2: Update Core Models

#### 2.1 Update `lib/core/models/gamification_state.dart`

```dart
import 'package:flutter/material.dart';
import '../theme/app_icons.dart';
import '../theme/app_colors.dart';

class GamificationState {
  // ... existing fields ...
  
  /// Tier icon (replaces tierEmoji)
  IconData get tierIcon {
    switch (tier) {
      case 'bronze':
        return AppIcons.tierBronze;
      case 'silver':
        return AppIcons.tierSilver;
      case 'gold':
        return AppIcons.tierGold;
      case 'diamond':
        return AppIcons.tierDiamond;
      default:
        return AppIcons.tierStarter;
    }
  }
  
  /// Tier color
  Color get tierColor {
    switch (tier) {
      case 'bronze':
        return AppColors.tierBronze;
      case 'silver':
        return AppColors.tierSilver;
      case 'gold':
        return AppColors.tierGold;
      case 'diamond':
        return AppColors.tierDiamond;
      default:
        return AppIcons.tierStarterColor;
    }
  }
  
  /// Keep old getter for backward compatibility (deprecated)
  @Deprecated('Use tierIcon instead')
  String get tierEmoji {
    switch (tier) {
      case 'bronze':
        return '🥉';
      case 'silver':
        return '🥈';
      case 'gold':
        return '🥇';
      case 'diamond':
        return '💎';
      default:
        return '⭐';
    }
  }
  
  /// Subscription badge icon (replaces subscriptionBadge)
  IconData? get subscriptionIcon {
    if (isSubscriber && subscriptionStatus == 'active') {
      return AppIcons.subscription;
    }
    return null;
  }
  
  /// Subscription badge color
  Color? get subscriptionColor {
    if (isSubscriber && subscriptionStatus == 'active') {
      return AppIcons.subscriptionColor;
    }
    return null;
  }
}
```

---

### Phase 3: Update Energy Widgets

#### 3.1 Update `lib/features/energy/widgets/energy_badge.dart`

**ก่อนแก้:**
```dart
Text('⚡', style: TextStyle(fontSize: 16)),
// ...
Text('💎', style: TextStyle(fontSize: 14)),
```

**หลังแก้:**
```dart
import '../../../core/theme/app_icons.dart';

// แทนที่ energy emoji
Icon(AppIcons.energy, size: 18, color: AppIcons.energyColor),

// แทนที่ diamond emoji
Icon(
  AppIcons.subscription,
  size: 16,
  color: AppIcons.subscriptionColor,
),
```

#### 3.2 Update `lib/features/energy/widgets/streak_display.dart`

**ก่อนแก้:**
```dart
Text('🔥', style: TextStyle(fontSize: 24)),
// ...
Text(gamification.tierEmoji, style: TextStyle(fontSize: 20)),
```

**หลังแก้:**
```dart
import '../../../core/theme/app_icons.dart';

// แทนที่ streak emoji
Icon(AppIcons.streak, size: 28, color: AppIcons.streakColor),

// แทนที่ tier emoji
Icon(
  gamification.tierIcon,
  size: 24,
  color: gamification.tierColor,
),
```

#### 3.3 Update `lib/features/energy/widgets/milestone_progress_card.dart`

**ก่อนแก้:**
```dart
Row(
  children: [
    Text('🏆', style: TextStyle(fontSize: 20)),
    SizedBox(width: 8),
    Text('Milestones', ...),
  ],
),
// ...
Text('+$reward ⚡', ...),
// ...
label: Text('Claim +$reward ⚡'),
```

**หลังแก้:**
```dart
import '../../../core/theme/app_icons.dart';

// Header
AppIcons.iconWithLabel(
  AppIcons.milestone,
  'Milestones',
  iconColor: AppIcons.milestoneColor,
  iconSize: 24,
  fontSize: 18,
  fontWeight: FontWeight.bold,
),

// Reward text
Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    Text('+$reward '),
    Icon(AppIcons.energy, size: 14, color: AppIcons.energyColor),
  ],
),

// Button label
Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    Text('Claim +$reward '),
    Icon(AppIcons.energy, size: 16, color: Colors.white),
  ],
),
```

#### 3.4 Update `lib/features/energy/widgets/weekly_challenge_card.dart`

**ก่อนแก้:**
```dart
Text('📋', style: TextStyle(fontSize: 20)),
// ...
Text('🍽', style: TextStyle(fontSize: 18)),
Text('🤖', style: TextStyle(fontSize: 18)),
Text('⏰ Resets every Monday', ...),
```

**หลังแก้:**
```dart
import '../../../core/theme/app_icons.dart';

// Header
AppIcons.iconWithLabel(
  AppIcons.challenge,
  'Weekly Challenges',
  iconColor: AppIcons.challengeColor,
  iconSize: 24,
  fontSize: 18,
  fontWeight: FontWeight.bold,
),

// Challenge icons
Icon(AppIcons.meal, size: 20, color: AppIcons.mealColor),  // Log meals
Icon(AppIcons.ai, size: 20, color: AppIcons.aiColor),      // Use AI

// Reset info
AppIcons.iconWithLabel(
  AppIcons.timer,
  'Resets every Monday',
  iconColor: AppIcons.timerColor,
  iconSize: 14,
  fontSize: 12,
  textColor: Colors.grey.shade600,
),
```

#### 3.5 Update `lib/features/energy/widgets/random_bonus_dialog.dart`

**ก่อนแก้:**
```dart
Text('🎲', style: TextStyle(fontSize: 64)),
// ...
Text('⚡', style: TextStyle(fontSize: 24)),
// ...
Text('Awesome! 🎉', ...),
```

**หลังแก้:**
```dart
import '../../../core/theme/app_icons.dart';

// Dialog icon
Icon(
  AppIcons.randomBonus,
  size: 80,
  color: AppIcons.randomBonusColor,
),

// Energy icon
Icon(AppIcons.energy, size: 28, color: AppIcons.energyColor),

// Button text
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Text('Awesome! ', style: TextStyle(fontSize: 16)),
    Icon(AppIcons.celebration, size: 18, color: Colors.white),
  ],
),
```

#### 3.6 Update `lib/features/energy/widgets/welcome_offer_progress.dart`

**ก่อนแก้:**
```dart
Text('🎁', style: TextStyle(fontSize: 20)),
```

**หลังแก้:**
```dart
import '../../../core/theme/app_icons.dart';

Icon(AppIcons.gift, size: 24, color: AppIcons.giftColor),
```

#### 3.7 Update `lib/features/energy/widgets/welcome_offer_unlocked_dialog.dart`

**ก่อนแก้:**
```dart
Text('🎉', style: TextStyle(fontSize: 48)),
// ...
Text('⚡ Unlimited AI Analysis', ...),
Text('⏰ 48 Hours Only', ...),
Text('🎁 Save up to 50%', ...),
```

**หลังแก้:**
```dart
import '../../../core/theme/app_icons.dart';

// Title icon
Icon(
  AppIcons.celebration,
  size: 64,
  color: AppIcons.celebrationColor,
),

// Features with icons
AppIcons.iconWithLabel(
  AppIcons.energy,
  'Unlimited AI Analysis',
  iconColor: AppIcons.energyColor,
),

AppIcons.iconWithLabel(
  AppIcons.timer,
  '48 Hours Only',
  iconColor: AppIcons.timerColor,
),

AppIcons.iconWithLabel(
  AppIcons.gift,
  'Save up to 50%',
  iconColor: AppIcons.giftColor,
),
```

#### 3.8 Update `lib/features/energy/widgets/no_energy_dialog.dart`

**ก่อนแก้:**
```dart
Text('⚡', style: TextStyle(fontSize: 48)),
// ...
Text('💡 Tip: ...', ...),
```

**หลังแก้:**
```dart
import '../../../core/theme/app_icons.dart';

// Title icon
Icon(AppIcons.energy, size: 64, color: AppIcons.energyColor),

// Tip
AppIcons.iconWithLabel(
  AppIcons.tips,
  'Tip: ...',
  iconColor: AppIcons.tipsColor,
),
```

#### 3.9 Update `lib/features/energy/presentation/energy_store_screen.dart`

**หาและแทนที่ emoji ทั้งหมด:**

```dart
import '../../../core/theme/app_icons.dart';

// Line 63: AppBar title
AppIcons.iconWithLabel(
  AppIcons.energy,
  'Energy Store',
  iconColor: AppIcons.energyColor,
  fontSize: 20,
  fontWeight: FontWeight.w600,
),

// Line 113-114: Section headers
AppIcons.iconWithLabel(
  AppIcons.money,
  'Regular Prices',
  iconColor: AppIcons.moneyColor,
),

// Line 210: Balance card icon
Icon(AppIcons.energy, size: 48, color: Colors.white),

// Line 295: Energy Pass
AppIcons.iconWithLabel(
  AppIcons.energy,
  'Energy Pass',
  iconColor: Colors.white,
),

// Line 351: Welcome banner
Icon(AppIcons.gift, size: 32, color: AppIcons.giftColor),

// Package emojis (lines 124, 134, 145, 157, etc.)
// แทนที่ด้วย Icon widgets:
Icon(AppIcons.target, size: 48, color: AppIcons.targetColor),    // Starter
Icon(AppIcons.subscription, size: 48, color: AppColors.primary), // Value Pack
Icon(AppIcons.streak, size: 48, color: AppIcons.streakColor),    // Power User
Icon(AppIcons.milestone, size: 48, color: AppIcons.milestoneColor), // Ultimate

// Info card icons (lines 654, 667-670)
AppIcons.iconWithLabel(AppIcons.energy, '1 Energy = 1 AI analysis'),
AppIcons.iconWithLabel(AppIcons.infinity, 'Energy never expires'),
AppIcons.iconWithLabel(AppIcons.device, 'One-time purchase, per device'),
// ... etc
```

---

### Phase 4: Update AI Loading Messages

#### 4.1 Update `lib/core/constants/ai_loading_messages.dart`

**ลบ emoji prefix ทั้งหมด:**

```dart
/// AI Loading Messages - Clean technical messages
class AILoadingMessages {
  // Image analysis
  static const String imageProcessing = 'PROCESSING IMAGE DATA...';
  static const String imageDetecting = 'DETECTING FOOD ITEMS...';
  static const String imageAnalyzing = 'ANALYZING COMPOSITION...';
  static const String imageCalculating = 'CALCULATING CALORIES...';
  static const String imageComputing = 'COMPUTING NUTRITION VALUES...';
  static const String imageFinalizing = 'FINALIZING RESULTS...';

  // Barcode analysis
  static const String barcodeReading = 'READING BARCODE DATA...';
  static const String barcodeFetching = 'FETCHING PRODUCT INFO...';
  static const String barcodeAnalyzing = 'ANALYZING NUTRITION LABEL...';
  static const String barcodeProcessing = 'PROCESSING INGREDIENTS...';
  static const String barcodeCalculating = 'CALCULATING VALUES...';
  static const String barcodePreparing = 'PREPARING RESULTS...';

  // Text analysis
  static const String textParsing = 'PARSING FOOD NAME...';
  static const String textIdentifying = 'IDENTIFYING INGREDIENTS...';
  static const String textAnalyzing = 'ANALYZING COMPOSITION...';
  static const String textEstimating = 'ESTIMATING NUTRIENTS...';
  static const String textComputing = 'COMPUTING MACROS...';
  static const String textFinalizing = 'FINALIZING DATA...';

  // Generic
  static const String analyzing = 'ANALYZING...';
  static const String processing = 'PROCESSING...';
  static const String calculating = 'CALCULATING NUTRITION...';
  static const String subtitle = 'Processing advanced nutrition analysis';
  
  // ... rest of class unchanged
}
```

**หมายเหตุ:** การแสดง loading ควรใช้ `CircularProgressIndicator` หรือ shimmer effect แทน emoji

---

### Phase 5: Update Health/Food Widgets

#### 5.1 Update `lib/features/health/presentation/food_preview_screen.dart`

```dart
import '../../../core/theme/app_icons.dart';

// Line 276: Macros section
AppIcons.iconWithLabel(
  AppIcons.macros,
  'Macros',
  iconColor: AppIcons.macrosColor,
),

// Line 302: Meal type section
AppIcons.iconWithLabel(
  AppIcons.meal,
  'Meal Type',
  iconColor: AppIcons.mealColor,
),

// Line 386: Save button
Icon(AppIcons.save, size: 20),

// Line 474: AI analyzed badge
Row(
  children: [
    Icon(AppIcons.aiAnalyzed, size: 14, color: AppIcons.aiAnalyzedColor),
    SizedBox(width: 4),
    Text('AI Analyzed'),
  ],
),

// Line 547: Calories section
AppIcons.iconWithLabel(
  AppIcons.calories,
  'CALORIES',
  iconColor: AppIcons.caloriesColor,
),
```

#### 5.2 Update `lib/features/health/widgets/food_detail_bottom_sheet.dart`

```dart
import '../../../core/theme/app_icons.dart';

// Line 239: Calories display
Icon(AppIcons.calories, size: 20, color: AppIcons.caloriesColor),

// Line 807: Calories icon
Icon(AppIcons.calories, size: 18, color: AppIcons.caloriesColor),

// Line 1182: Energy cost warning
AppIcons.iconWithLabel(
  AppIcons.energy,
  'Costs 1 Energy',
  iconColor: AppIcons.energyColor,
),
```

#### 5.3 Update `lib/features/health/widgets/create_meal_sheet.dart`

```dart
import '../../../core/theme/app_icons.dart';

// Line 203: Title icons
Icon(
  isEditMode ? AppIcons.edit : AppIcons.meal,
  size: 24,
  color: isEditMode ? AppIcons.editColor : AppIcons.mealColor,
),

// Line 330: Total nutrition
AppIcons.iconWithLabel(
  AppIcons.statistics,
  'Total Nutrition',
  iconColor: AppIcons.statisticsColor,
),

// Line 337: Calories
Icon(AppIcons.calories, size: 18, color: AppIcons.caloriesColor),

// Line 577: Base nutrition
AppIcons.iconWithLabel(
  AppIcons.statistics,
  'Base nutrition',
  iconColor: AppIcons.statisticsColor,
),

// Line 587: Detail tip
AppIcons.iconWithLabel(
  AppIcons.tips,
  'Detail text',
  iconColor: AppIcons.tipsColor,
),

// Line 667: Info icon
Icon(AppIcons.info, size: 16, color: AppIcons.infoColor),
```

#### 5.4 Update `lib/features/health/widgets/food_timeline_card.dart`

```dart
import '../../../core/theme/app_icons.dart';

// Line 179: Calorie badge
Icon(AppIcons.calories, size: 14, color: AppIcons.caloriesColor),
```

#### 5.5 Update `lib/features/health/widgets/my_meal_card.dart`

```dart
import '../../../core/theme/app_icons.dart';

// Line 60: Meal icon placeholder
Icon(AppIcons.meal, size: 32, color: AppIcons.mealColor),

// Line 99: AI/Manual badges
Icon(
  isAiGenerated ? AppIcons.aiAnalyzed : AppIcons.edit,
  size: 12,
  color: isAiGenerated ? AppIcons.aiAnalyzedColor : AppIcons.editColor,
),
```

#### 5.6 Update `lib/features/health/widgets/ingredient_card.dart`

```dart
import '../../../core/theme/app_icons.dart';

// Line 122: AI/Manual badges
Icon(
  isAiGenerated ? AppIcons.aiAnalyzed : AppIcons.edit,
  size: 12,
  color: isAiGenerated ? AppIcons.aiAnalyzedColor : AppIcons.editColor,
),
```

#### 5.7 Update `lib/features/health/widgets/edit_ingredient_sheet.dart`

```dart
import '../../../core/theme/app_icons.dart';

// Line 157: Title
AppIcons.iconWithLabel(
  AppIcons.edit,
  'Edit Ingredient',
  iconColor: AppIcons.editColor,
),

// Line 238: Nutrition section
AppIcons.iconWithLabel(
  AppIcons.statistics,
  'Nutrition per amount',
  iconColor: AppIcons.statisticsColor,
),

// Line 249: Calories
Icon(AppIcons.calories, size: 16, color: AppIcons.caloriesColor),

// Line 306: Tip
AppIcons.iconWithLabel(
  AppIcons.tips,
  'Tip text',
  iconColor: AppIcons.tipsColor,
),
```

#### 5.8 Update `lib/features/health/widgets/quick_add_section.dart`

```dart
import '../../../core/theme/app_icons.dart';

// Line 221, 272: Repeat day/meal chips
CircleAvatar(
  backgroundColor: AppIcons.repeatColor.withOpacity(0.1),
  child: Icon(AppIcons.repeat, size: 16, color: AppIcons.repeatColor),
),

// Line 237: Quick add chips - แทนที่ emoji ด้วย icon based on item type
CircleAvatar(
  backgroundColor: _getItemColor(item).withOpacity(0.1),
  child: Icon(_getItemIcon(item), size: 16, color: _getItemColor(item)),
),

// เพิ่ม helper methods:
IconData _getItemIcon(dynamic item) {
  // Map based on meal type or food category
  // Return appropriate icon from AppIcons
  return AppIcons.meal; // default
}

// Lines 335, 460, 607: SnackBar messages
Icon(AppIcons.energy, size: 16),

// Lines 381, 531: Dialog titles
Icon(AppIcons.repeat, size: 24, color: AppIcons.repeatColor),
```

#### 5.9 Update `lib/features/health/presentation/health_my_meal_tab.dart`

```dart
import '../../../core/theme/app_icons.dart';

// Lines 115, 301, 997: Meals icons
Icon(AppIcons.meal, size: 24, color: AppIcons.mealColor),
```

#### 5.10 Update `lib/features/health/presentation/health_timeline_tab.dart`

```dart
import '../../../core/theme/app_icons.dart';

// Line 187: Date display
Icon(AppIcons.calendar, size: 16, color: AppIcons.calendarColor),
```

#### 5.11 Update `lib/core/constants/enums.dart`

```dart
import 'package:flutter/material.dart';
import '../theme/app_icons.dart';

extension MealTypeExtension on MealType {
  IconData get icon {
    switch (this) {
      case MealType.breakfast:
        return AppIcons.breakfast;
      case MealType.lunch:
        return AppIcons.lunch;
      case MealType.dinner:
        return AppIcons.dinner;
      case MealType.snack:
        return AppIcons.snack;
    }
  }

  Color get iconColor {
    switch (this) {
      case MealType.breakfast:
        return AppIcons.breakfastColor;
      case MealType.lunch:
        return AppIcons.lunchColor;
      case MealType.dinner:
        return AppIcons.dinnerColor;
      case MealType.snack:
        return AppIcons.snackColor;
    }
  }

  @Deprecated('Use icon getter instead')
  String get emoji {
    switch (this) {
      case MealType.breakfast:
        return '☀️';
      case MealType.lunch:
        return '🌤️';
      case MealType.dinner:
        return '🌙';
      case MealType.snack:
        return '🍿';
    }
  }
}

extension FoodSearchModeExtension on FoodSearchMode {
  IconData get icon {
    switch (this) {
      case FoodSearchMode.normal:
        return Icons.restaurant_menu_rounded;
      case FoodSearchMode.product:
        return AppIcons.package;
    }
  }

  @Deprecated('Use icon getter instead')
  String get emoji {
    switch (this) {
      case FoodSearchMode.normal:
        return '🍳';
      case FoodSearchMode.product:
        return '📦';
    }
  }
}
```

---

### Phase 6: Update Chat/AI Widgets

#### 6.1 Update `lib/features/chat/presentation/chat_screen.dart`

**มี emoji เยอะมาก ต้องแก้หลายจุด:**

```dart
import '../../../core/theme/app_icons.dart';

// Line 212, 33: AI avatar
CircleAvatar(
  backgroundColor: AppIcons.aiColor.withOpacity(0.1),
  child: Icon(AppIcons.ai, color: AppIcons.aiColor),
),

// Example cards (lines 236-242)
_buildExampleCard(
  icon: AppIcons.breakfast,
  color: AppIcons.breakfastColor,
  text: 'Breakfast',
),
_buildExampleCard(
  icon: AppIcons.lunch,
  color: AppIcons.lunchColor,
  text: 'Lunch',
),
_buildExampleCard(
  icon: AppIcons.dinner,
  color: AppIcons.dinnerColor,
  text: 'Dinner',
),
_buildExampleCard(
  icon: AppIcons.snack,
  color: AppIcons.snackColor,
  text: 'Snack',
),

// Action chips (lines 316-349)
AppIcons.iconWithLabel(AppIcons.meal, 'What I can eat'),
AppIcons.iconWithLabel(AppIcons.statistics, 'Weekly'),
AppIcons.iconWithLabel(AppIcons.statistics, 'Monthly'),
AppIcons.iconWithLabel(AppIcons.tips, 'Tips'),
AppIcons.iconWithLabel(AppIcons.statistics, 'Summary'),

// Summary headers and content (lines 459-581)
// แทนที่ emoji ทั้งหมดด้วย icons:
Icon(AppIcons.statistics, ...),  // 📊
Icon(AppIcons.warning, ...),     // ⚠️
Icon(AppIcons.calendar, ...),    // 📅
Icon(AppIcons.success, ...),     // ✅
Icon(AppIcons.calories, ...),    // 🔥
Icon(AppIcons.target, ...),      // 🎯
Icon(AppIcons.macros, ...),      // 💪

// Energy cost badge (line 1230)
Container(
  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
  decoration: BoxDecoration(
    color: AppIcons.energyColor.withOpacity(0.1),
    borderRadius: BorderRadius.circular(8),
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(AppIcons.energy, size: 12, color: AppIcons.energyColor),
      SizedBox(width: 2),
      Text('1', style: TextStyle(fontSize: 10)),
    ],
  ),
),

// Greeting messages (lines 1273, 1281)
Icon(AppIcons.meal, ...),
Icon(AppIcons.macros, ...),

// Error messages (line 1313)
Icon(AppIcons.energy, ...),

// Suggestions (lines 1420, 1434)
Icon(AppIcons.meal, ...),
Icon(AppIcons.energy, ...),
```

#### 6.2 Update `lib/features/chat/widgets/message_bubble.dart`

```dart
import '../../../core/theme/app_icons.dart';

// Line 33: AI avatar
CircleAvatar(
  backgroundColor: AppIcons.aiColor.withOpacity(0.1),
  child: Icon(AppIcons.ai, size: 16, color: AppIcons.aiColor),
),
```

---

### Phase 7: Update Profile/Settings Widgets

#### 7.1 Update `lib/features/profile/presentation/profile_screen.dart`

```dart
import '../../../core/theme/app_icons.dart';

// Line 63: Health Goals
AppIcons.iconWithLabel(AppIcons.target, 'Health Goals'),

// Line 85: Cuisine Preference
AppIcons.iconWithLabel(AppIcons.meal, 'Cuisine Preference'),

// Line 91: Photo Scan
AppIcons.iconWithLabel(AppIcons.camera, 'Photo Scan'),

// Line 166: Subscription badge
Row(
  children: [
    Icon(AppIcons.subscription, size: 16, color: AppIcons.subscriptionColor),
    SizedBox(width: 4),
    Text('Active'),
  ],
),

// Line 189: Data section
AppIcons.iconWithLabel(AppIcons.save, 'Data'),

// Line 239: About section
AppIcons.iconWithLabel(AppIcons.info, 'About'),

// Line 506: AI mode cost
Icon(AppIcons.energy, size: 14, color: AppIcons.energyColor),

// Line 1081: Warning
Icon(AppIcons.warning, size: 20, color: AppIcons.warningColor),

// Line 1237: Restore success
Icon(AppIcons.success, size: 16),
```

#### 7.2 Update `lib/features/profile/presentation/health_goals_screen.dart`

```dart
import '../../../core/theme/app_icons.dart';

// Line 308: Quick Presets
AppIcons.iconWithLabel(AppIcons.target, 'Quick Presets'),

// Line 397: Daily Calorie Goal
AppIcons.iconWithLabel(AppIcons.calories, 'Daily Calorie Goal'),

// Line 558: Daily Water Goal (if exists)
// Use appropriate water icon
```

---

### Phase 8: Update Onboarding Widgets

#### 8.1 Update `lib/features/onboarding/presentation/onboarding_screen.dart`

```dart
import '../../../core/theme/app_icons.dart';

// Feature pills (lines 139-151)
Icon(AppIcons.camera, color: AppIcons.cameraColor),
Icon(Icons.chat_rounded, color: AppIcons.aiColor),
Icon(AppIcons.edit, color: AppIcons.editColor),

// Disclaimer (line 169)
Icon(AppIcons.info, size: 16, color: AppIcons.infoColor),

// Quick Setup page (line 246)
Icon(AppIcons.meal, size: 48, color: AppIcons.mealColor),

// Completion page (line 358)
Icon(AppIcons.celebration, size: 64, color: AppIcons.celebrationColor),

// Welcome Gift (line 406)
AppIcons.iconWithLabel(AppIcons.gift, 'Welcome Gift'),
```

#### 8.2 Update `lib/features/onboarding/presentation/tutorial_food_analysis_screen.dart`

```dart
import '../../../core/theme/app_icons.dart';

// Tutorial description (lines 55-57)
// แทนที่ emoji ด้วย icons ในคำอธิบาย

// Demo messages (lines 134, 145)
Icon(AppIcons.aiAnalyzed, ...),
Icon(AppIcons.tips, ...),

// Start button (line 308)
Icon(AppIcons.launch, size: 20),

// Tip boxes (lines 485-486, 1010)
Icon(AppIcons.tips, size: 20, color: AppIcons.tipsColor),

// Warning (line 732)
Icon(AppIcons.warning, ...),

// Completion (line 853)
Icon(AppIcons.milestone, size: 48, color: AppIcons.milestoneColor),

// Recap pills (lines 867-879)
Icon(AppIcons.camera, ...),
Icon(Icons.chat_rounded, ...),
Icon(AppIcons.edit, ...),
```

---

### Phase 9: Update Referral & Subscription Widgets

#### 9.1 Update `lib/features/referral/presentation/referral_screen.dart`

```dart
import '../../../core/theme/app_icons.dart';

// Line 59: Success message
Icon(AppIcons.celebration, size: 16),

// Line 98: AppBar title
Icon(Icons.people_rounded, size: 24),

// Line 158: Referral description
Icon(AppIcons.celebration, size: 16),

// Line 300: Step 4
Icon(AppIcons.celebration, size: 16),
```

#### 9.2 Update `lib/features/subscription/models/subscription_plan.dart`

```dart
import '../../../core/theme/app_icons.dart';

// Benefits with icons
class SubscriptionBenefit {
  final IconData icon;
  final Color iconColor;
  final String text;
  
  const SubscriptionBenefit({
    required this.icon,
    required this.iconColor,
    required this.text,
  });
}

// Line 34-37: Update benefits
SubscriptionBenefit(
  icon: AppIcons.aiAnalyzed,
  iconColor: AppIcons.aiAnalyzedColor,
  text: 'Unlimited AI Analysis',
),
SubscriptionBenefit(
  icon: AppIcons.gift,
  iconColor: AppIcons.giftColor,
  text: 'Double Streak Rewards',
),
SubscriptionBenefit(
  icon: AppIcons.device,
  iconColor: AppIcons.deviceColor,
  text: 'Priority Support',
),
```

---

### Phase 10: Update Misc Widgets

#### 10.1 Update `lib/core/widgets/disclaimer_widget.dart`

```dart
import '../theme/app_icons.dart';

// Line 34: Compact disclaimer
Icon(AppIcons.warning, size: 16, color: AppIcons.warningColor),

// Line 71: Full disclaimer
Icon(AppIcons.warning, size: 24, color: AppIcons.warningColor),
```

#### 10.2 Update `lib/features/home/widgets/feature_tour.dart`

```dart
import '../../../core/theme/app_icons.dart';

// Line 114: Energy System
AppIcons.iconWithLabel(
  AppIcons.energy,
  'Energy System',
  iconColor: AppIcons.energyColor,
),
```

#### 10.3 Update `lib/features/health/widgets/gemini_analysis_sheet.dart`

```dart
import '../../../core/theme/app_icons.dart';

// Line 807: Calories
Icon(AppIcons.calories, size: 18, color: AppIcons.caloriesColor),

// Line 955: Tips
Icon(AppIcons.tips, size: 16, color: AppIcons.tipsColor),
```

#### 10.4 Update `lib/features/health/widgets/log_from_meal_sheet.dart`

```dart
import '../../../core/theme/app_icons.dart';

// Line 101: Meal name
Icon(AppIcons.meal, size: 20, color: AppIcons.mealColor),

// Line 175: Calories
Icon(AppIcons.calories, size: 16, color: AppIcons.caloriesColor),
```

#### 10.5 Update `lib/features/health/widgets/edit_food_bottom_sheet.dart`

```dart
import '../../../core/theme/app_icons.dart';

// Line 620: Title
AppIcons.iconWithLabel(AppIcons.edit, 'Edit Food'),

// Line 700: Calories
Icon(AppIcons.calories, size: 16, color: AppIcons.caloriesColor),

// Line 887: Ingredients section
Icon(Icons.grass_rounded, size: 20, color: Colors.green.shade600),

// Line 933: Tip
Icon(AppIcons.tips, size: 16, color: AppIcons.tipsColor),

// Line 955: Search tip
Icon(AppIcons.search, size: 16, color: AppIcons.searchColor),
```

---

## 📋 Checklist สำหรับ QA

### Foundation

```
□ สร้าง lib/core/theme/app_icons.dart
□ เพิ่มสีใน lib/core/theme/app_colors.dart
□ Update lib/core/models/gamification_state.dart
  □ เพิ่ม tierIcon getter
  □ เพิ่ม tierColor getter
  □ เพิ่ม subscriptionIcon getter
  □ Deprecate tierEmoji
```

### Energy/Gamification (8 ไฟล์)

```
□ energy_badge.dart
□ energy_badge_riverpod.dart (ใช้ icon อยู่แล้ว ✅)
□ streak_display.dart
□ milestone_progress_card.dart
□ weekly_challenge_card.dart
□ random_bonus_dialog.dart
□ welcome_offer_progress.dart
□ welcome_offer_unlocked_dialog.dart
□ no_energy_dialog.dart
□ energy_store_screen.dart
```

### Health/Food (15 ไฟล์)

```
□ food_preview_screen.dart
□ food_detail_bottom_sheet.dart
□ create_meal_sheet.dart
□ food_timeline_card.dart
□ my_meal_card.dart
□ ingredient_card.dart
□ edit_ingredient_sheet.dart
□ quick_add_section.dart
□ health_my_meal_tab.dart
□ health_timeline_tab.dart
□ gemini_analysis_sheet.dart
□ log_from_meal_sheet.dart
□ edit_food_bottom_sheet.dart
□ health_diet_tab.dart (ถ้ามี emoji)
□ enums.dart (MealType, FoodSearchMode extensions)
```

### Chat/AI (2 ไฟล์)

```
□ chat_screen.dart
□ message_bubble.dart
```

### Loading Messages

```
□ ai_loading_messages.dart
```

### Profile/Settings (2 ไฟล์)

```
□ profile_screen.dart
□ health_goals_screen.dart
```

### Onboarding (2 ไฟล์)

```
□ onboarding_screen.dart
□ tutorial_food_analysis_screen.dart
```

### Referral & Subscription (2 ไฟล์)

```
□ referral_screen.dart
□ subscription_plan.dart
```

### Misc (3 ไฟล์)

```
□ disclaimer_widget.dart
□ feature_tour.dart
□ (เช็คไฟล์อื่นๆ ที่อาจมี emoji)
```

### Testing

```
□ Build แอปสำเร็จ (ไม่มี error)
□ Hot reload/restart ทำงานได้
□ Visual QA:
  □ Energy Badge ดูดี สีถูก
  □ Streak Display icon ชัดเจน
  □ Milestone Cards ดู professional
  □ Weekly Challenge Cards สวย
  □ Random Bonus Dialog icon ใหญ่พอ
  □ Chat Screen AI avatar สวย
  □ Food cards/sheets ใช้ icon เหมาะสม
  □ Profile screen icons สม่ำเสมอ
  □ Onboarding icons ชัดเจน
□ Functionality:
  □ Energy badge tap เปิด store ได้
  □ Milestone claim ทำงาน
  □ Challenge claim ทำงาน
  □ Chat ใช้งานปกติ
  □ Food logging ปกติ
□ Theme consistency:
  □ สีทั้งหมดเข้ากับ teal theme
  □ Icon sizes สม่ำเสมอ
  □ Spacing ระหว่าง icon-text เหมาะสม
```

---

## 💡 Best Practices & Tips

### 1. Icon Sizing Guidelines

```dart
// Header/Title icons
Icon(AppIcons.energy, size: 24)

// Body/Content icons
Icon(AppIcons.energy, size: 20)

// Small badges/chips
Icon(AppIcons.energy, size: 16)

// Tiny inline icons
Icon(AppIcons.energy, size: 14)

// Dialog/Featured icons
Icon(AppIcons.energy, size: 48-80)
```

### 2. Color Usage

```dart
// ใช้สีจาก AppIcons constants
Icon(AppIcons.energy, color: AppIcons.energyColor)

// สำหรับ icon on colored background (ใช้ white/black)
Icon(AppIcons.energy, color: Colors.white)

// สำหรับ disabled state (ใช้ grey)
Icon(AppIcons.energy, color: Colors.grey.shade400)
```

### 3. Spacing

```dart
// ระหว่าง icon กับ text
Row(
  children: [
    Icon(...),
    SizedBox(width: 4-8), // 4 สำหรับ small, 8 สำหรับ normal
    Text(...),
  ],
)
```

### 4. Helper Method Usage

```dart
// แทนที่ pattern: emoji + text
// ก่อน:
Row(children: [Text('⚡'), SizedBox(width: 8), Text('Energy')])

// หลัง:
AppIcons.iconWithLabel(
  AppIcons.energy,
  'Energy',
  iconColor: AppIcons.energyColor,
)
```

### 5. Backward Compatibility

```dart
// ถ้าต้องการรักษา emoji ไว้ชั่วคราว (สำหรับ migration แบบค่อยเป็นค่อยไป)
// ใช้ @Deprecated annotation
@Deprecated('Use tierIcon instead')
String get tierEmoji { ... }
```

### 6. Testing Strategy

1. **Unit Test**: ไม่จำเป็นต้องแก้ (icon เป็น UI concern)
2. **Widget Test**: Update assertions ที่หา emoji text → หา Icon widget แทน
3. **Integration Test**: ไม่ได้รับผลกระทบ
4. **Visual QA**: ต้องเช็คทุกหน้าจอ

---

## 🎨 Design Rationale

### ทำไมใช้ Material Icons?

1. **Built-in**: มากับ Flutter ไม่ต้องลง package เพิ่ม
2. **Consistent**: Design language เดียวกันทั้งแอป (Material 3)
3. **Customizable**: ปรับสี ขนาดได้ตามต้องการ
4. **Professional**: ดูเป็นมืออาชีพกว่า emoji
5. **Theme-aware**: รองรับ dark mode ได้ดี

### Color Palette Rationale

- **Teal primary** (#2D8B75): สี brand หลัก (Airbnb-inspired)
- **Amber/Orange** (#F59E0B, #F97316): ความอบอุ่น เหมาะกับ food/energy
- **Deep Orange** (#FF5722): ไฟ/แคลอรี่
- **Purple** (#9C27B0): AI/เทคโนโลยี
- **Blue** (#3B82F6): ข้อมูล/สถิติ
- **Green** (#22C55E): ความสำเร็จ

### Icon Selection Rationale

| Category | Icon | เหตุผล |
|----------|------|--------|
| Energy | `bolt_rounded` | ชัดเจน узнаваема สากล |
| Streak | `local_fire_department_rounded` | แทนไฟได้ดี rounded style นุ่มนวล |
| Diamond | `diamond_outlined` | outlined style ดู elegant |
| Milestone | `emoji_events_rounded` | รางวัล/ความสำเร็จ |
| AI | `smart_toy_rounded` | robot/AI ยุคใหม่ |
| Meal | `restaurant_rounded` | อาหาร สากล |

---

## 📚 References

- [Material Icons Gallery](https://fonts.google.com/icons)
- [Flutter Icon Class](https://api.flutter.dev/flutter/widgets/Icon-class.html)
- [Material Design Color System](https://m3.material.io/styles/color/overview)

---

## 🚀 Next Steps

หลังจาก redesign เสร็จ:

1. **User Feedback**: รอฟีดแบค 1-2 สัปดาห์
2. **A/B Testing**: เปรียบเทียบ engagement metrics
3. **Iterate**: ปรับปรุงตาม feedback

Potential future improvements:

- Custom SVG icons สำหรับ brand identity
- Animated icons สำหรับ key interactions
- Lottie animations สำหรับ celebrations

---

**สร้างโดย:** AI Assistant  
**วันที่:** 2026-02-17  
**เวอร์ชัน:** 1.0
