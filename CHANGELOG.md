# Changelog

## [1.2.0+48] - 2026-02-26

### 🎉 Major Feature: Health Sync (Apple Health / Google Health Connect)

#### Two-Way Health Data Integration:
- **Outbound Sync:** Every food entry logged in MiRO automatically syncs to Apple Health (iOS) and Google Health Connect (Android)
  - Full ingredient-level breakdown: Calories, Protein, Carbs, Fat, Meal Type
  - Works seamlessly with smartwatches (Apple Watch, Samsung Galaxy Watch), fitness apps (Google Fit, Fitbit, Garmin)
  - Delete food in MiRO → automatically removed from Health app too
  - One log, visible everywhere — your smartwatch, fitness dashboard, and health ecosystem all stay in sync

- **Inbound Sync:** Active Energy (calories burned from movement) pulled from Health apps
  - Real-time bonus calories added to your daily calorie goal
  - Green progress bar fills as you move throughout the day
  - Toggle on/off directly from home screen (available in both Basic & Pro modes)
  - Customizable BMR (default 1,500 kcal/day) for accurate active energy calculation
  - Example: Goal = 2,000 kcal. You burned 350 active kcal by afternoon → MiRO shows your goal as 2,350 kcal

#### Privacy & Permissions:
- Single permission request for both read (Active Energy) and write (Nutrition) permissions
- Permission requested only when user enables Health Sync
- User can disable anytime — no data leaves device without consent
- Updated Terms of Service and Privacy Policy with Health Data Integration sections
- Full localization (l10n) for all 12 supported languages

#### Technical Implementation:
- **iOS:** Apple HealthKit integration with proper entitlements (`Runner.entitlements`) and Info.plist permissions
- **Android:** Google Health Connect integration (minSdk 26, `FlutterFragmentActivity`, manifest declarations)
- **Data Models:** Added `customBmr` field to UserProfile, `healthConnectId` to FoodEntry
- **Services:** `HealthSyncService` handles all health data operations
- **UI:** Compact Active Energy row with green progress bar, mini toggle, fire icon

### 🐛 Bug Fixes:
- **Fixed: NaN/Infinity Error in BMR Calculation** - Resolved crash when displaying BMR in settings (`Unsupported operation: Infinity or NaN toInt`)
  - Root cause: Existing user profiles created before `customBmr` field was added returned NaN from Isar database
  - Solution: Added `safeBmr` getter in UserProfile model with NaN/Infinity safety checks
  - Added safety checks in all `.toInt()` calls for activeEnergy and goal calculations
  - All NaN/Infinity values now default to 1,500 kcal

- **Fixed: Active Energy Not Updating When BMR Changed** - Active Energy now recalculates immediately when BMR is changed in settings
  - Root cause: `activeEnergyProvider` was reading profile directly from database instead of watching `profileNotifierProvider`
  - Solution: Changed provider to watch `profileNotifierProvider` — automatically recalculates when profile changes
  - Also fixed `effectiveCalorieGoalProvider` to watch profile changes

### 🔧 Technical:
- Updated `user_profile.dart`: Added `safeBmr` getter for NaN safety
- Updated `health_provider.dart`: Changed to watch `profileNotifierProvider` for real-time updates
- Updated `health_sync_service.dart`: Added BMR parameter validation
- Updated `daily_summary_card.dart`: Added safety checks for NaN/Infinity in goal and activeEnergy
- Updated `profile_screen.dart`: BMR setting tile uses `safeBmr` getter

---

## [1.1.22+47] - 2026-02-26

### ✨ UI Improvements
- **Basic Mode: Selection Bar Redesign** - Improved selection action bar for better space efficiency
  - Added **Unselect** button (icon-only) to quickly clear all selections
  - Converted Delete and Move Date buttons to **icon-only** format (saves horizontal space)
  - Analyze button retains text label (only button with text for clarity)
  - All icon buttons include tooltips for better discoverability
  - Selection bar now appears above food items when entering selection mode

### 🐛 Bug Fixes
- **Fixed: Long Press Behavior** - Reverted from popup menu back to selection mode
  - Long press now directly enters selection mode (matches original design)
  - More intuitive UX with selection bar appearing immediately
  - Fixed space issues with truncated button text

### 🔒 Safety Improvements
- **Delete Confirmation Dialog** - Added confirmation dialog before deleting selected entries in Basic mode
  - Shows all selected entry names in confirmation message
  - Uses proper l10n localization (Thai/English support)
  - Prevents accidental deletion of multiple entries

### 🔧 Technical
- Updated `food_sandbox.dart`: Selection bar UI improvements, icon-only buttons, unselect functionality
- Updated `basic_mode_tab.dart`: Added delete confirmation dialog with l10n support

---

## [1.1.21+46] - 2026-02-26

### ✨ New Features
- **Basic Mode: Long Press to Move Date** - Long press any food entry in Basic mode → shows menu with "Move to Another Date" option
  - Opens date picker to select new date
  - Moves entry to selected date (preserves meal type and all data)
  - Shows confirmation snackbar after moving
- **Platform Tracking** - Automatically detects and stores OS platform (android/ios) in user profile at app startup
  - Added `platform` field to UserProfile model
  - Used for future database migration support (e.g., iOS China market separation)

### 🐛 Bug Fixes
- **Fixed: Analyze Results Not Showing Immediately** - Fixed analyze completion not refreshing food list
  - Root cause: Missing `foodEntriesByDateProvider` invalidation in batch analysis helper
  - Solution: Added proper provider invalidation with `dateOnly()` normalization
  - Results now appear immediately after analyze completes (no refresh needed)
  - Applied to both Pro and Basic mode analyze flows

### 🔧 Technical
- Updated `batch_analysis_helper.dart`: Added `foodEntriesByDateProvider` invalidation
- Updated `UserProfile` model: Added `platform` field (Isar schema regenerated)
- Updated `main.dart`: Auto-detect and save platform on first launch

---

## [1.1.20+45] - 2026-02-26

### 🔧 Build Update
- Version bump to 1.1.20+45
- ads declare
---

## [1.1.18+43] - 2026-02-24

### ✨ New Features
- Default app mode to Basic for new users (first-time after onboarding)

### 🐛 Bug Fixes
- Fixed: Calories (kcal) not updating when changing quantity in Basic mode food detail sheet
  - Added real-time nutrition recalculation based on baseCalories × quantity
  - Values now update immediately when user edits quantity field

---

## [1.1.14+39] - 2026-02-21

### 🔧 Build Update
- Version bump to 1.1.14+39

---

## [1.1.13+38] - 2026-02-21

### 🐛 Critical Bug Fixes

#### Fixed: Bonus Rate Offers Not Disappearing After Purchase
- **Issue**: Bonus rate offers (40% bonus, tier promo) not disappearing after purchase
  - Root cause: `markOfferClaimed()` only checked `productId` match, but `bonus_rate` offers don't have `productId`
  - Solution: Track `offerBonusTemplateId` and mark `claimed=true` after purchase completes
  - Frontend: Remove offers from local state immediately after purchase (UX improvement)

#### Fixed: Inactive Offers Still Visible
- **Issue**: `getActiveOffers()` not checking `template.isActive` flag
  - Admin-deactivated offers were still visible to users
  - Solution: Added `isActive === false` check in `getActiveOffers()` filter

### 🔧 Backend Changes
- Updated `verifyPurchase.ts`: Added bonus_rate offer claiming logic
- Updated `offersV2.ts`: Added `template.isActive` check in `getActiveOffers()`
- Updated `energy_store_screen.dart`: Immediate offer removal from local state
- Cleanup: Removed legacy code in `verifyPurchase.ts` (duplicate welcome bonus trigger)

---

## [1.1.12+37] - 2026-02-20

### ✨ New Feature: Enhanced Add Food (Timeline)

#### Add Food = Mini Create Meal
- **Ingredient editing**: Add food now supports main-ingredients and sub-ingredients, same as Create Meal
- **Autocomplete search**: Search from My Meal and Ingredient database while typing
- **AI search per ingredient**: Tap AI icon to analyze individual ingredients via Gemini
- **AI search per sub-ingredient**: Search DB first, fallback to AI for sub-ingredients
- **Auto-save to DB**: AI lookup results saved to Ingredient DB immediately
- **Auto-save meal**: When saving with ingredients, auto-creates MyMeal + Ingredient entries
- **Load from MyMeal**: Selecting a MyMeal suggestion auto-loads its ingredient tree for editing

#### Quick Add & Flexible Save
- **Quick Add**: Save without food name if kcal is provided → auto-names "Quick Add"
- **Name-only save**: Save with just a name (no kcal) → ready for Analyze All later
- **Ingredients-only**: Save with only ingredients, no name → auto-names "Quick Add"
- Only blocks save when there's truly nothing entered (no name, no kcal, no ingredients)

### 🐛 Critical Bug Fix: Energy Not Deducted

#### Fixed: AI usage not recording energy cost in batch operations
- **Issue**: Analyze All and Analyze Selected were using AI without deducting energy
  - Users could analyze unlimited items without spending energy points
  - 7 code paths were missing `UsageLimiter.recordAiUsage()` calls
  
- **Affected functions**:
  - `health_timeline_tab.dart` → `_startBatchAnalysis()` (3 paths: batch, fallback, image)
  - `meal_section.dart` → `_analyzeSelected()` (3 paths: batch, fallback, image)
  - `meal_section.dart` → `_analyzeSingleEntry()` (1 path: re-analyze)
  
- **Solution**: Added `UsageLimiter.recordAiUsage()` + energy provider invalidation after every successful AI call

- **Files Changed**:
  - `lib/features/health/widgets/add_food_bottom_sheet.dart`: Complete rewrite with ingredient system
  - `lib/features/health/presentation/health_timeline_tab.dart`: +3 energy recording points
  - `lib/features/health/widgets/meal_section.dart`: +4 energy recording points, +import

---

## [1.1.11+36] - 2026-02-20

### 🐛 Critical Bug Fix (Continued)

#### Fixed: Build Compilation Errors (Follow-up to 1.1.10)
- **Issue**: v1.1.10+35 failed to build due to Android SDK compatibility issues
  - Error: `android:attr/lStar not found`
  - Error: `BAKLAVA constant not found` in sqflite_android
  - Build failed before reaching production
  
- **Root Cause**: Dependency requirements changed
  - `sqflite_android:2.4.2+` requires compileSdk 36 (Android 16) for new Java APIs
  - `isar_flutter_libs` also needs compileSdk 36
  - Previous build used compileSdk 35 (Android 15)
  
- **Solution**: Upgraded Android build configuration
  - **compileSdk**: 35 → 36 (Android 16 / API 36)
  - Force all subprojects to use compileSdk 36
  - targetSdk remains 35 (Play Store requirement)
  
- **All NaN fixes from v1.1.10 are included**:
  - 3-layer NaN sanitization (profile guard + food guard + JSON guard)
  - All NaN/Infinity values converted to 0 before JSON encoding
  - Tested successfully on production device

- **Files Changed**:
  - `android/app/build.gradle.kts`: `compileSdk = 36`
  - `android/build.gradle.kts`: Force subprojects to compileSdk 36
  - `lib/core/ai/gemini_chat_service.dart`: NaN sanitization (from 1.1.10)
  - `lib/features/chat/providers/chat_provider.dart`: Safe conversions (from 1.1.10)

---

## [1.1.10+35] - 2026-02-20

### 🐛 Critical Bug Fix

#### Fixed: Chat NaN Error on Production Devices
- **Issue**: "Converting object to an encodable object failed: NaN" error when using Chat
  - Occurred only on production (Google Play Store) builds, not in development
  - Caused by NaN (Not a Number) values in user profile or food data being sent to JSON encoder
  - JSON standard does not support NaN/Infinity values

- **Root Cause**: Legacy data from database migrations containing NaN values
  - Profile fields: `calorieGoal`, `weight`, `height`, `meal budgets`
  - Food context: `todayCalories`, `todayMacros`
  - No validation before `jsonEncode()` call

- **Solution**: 3-layer defense against NaN values
  1. **Profile Context Guard**: Added `_safeDouble()` helper to sanitize all profile fields
  2. **Food Context Guard**: Added `_safe()` validation before `.toInt()` conversions
  3. **JSON Encoding Guard**: Added `_sanitizeForJson()` recursive sanitizer before all `jsonEncode()` calls
  - All NaN/Infinity values now converted to 0 (or specified fallback)
  - Applied to both `analyzeChatMessage` and `getMenuSuggestions` flows

- **Files Changed**:
  - `lib/core/ai/gemini_chat_service.dart`: Added sanitization helpers
  - `lib/features/chat/providers/chat_provider.dart`: Added safe conversions

---

## [1.1.9+34] - 2026-02-20

### ✨ New Features

#### Smart Chat Context-Aware AI
- **AI Database Knowledge**: Miro AI now knows your MyMeal and Ingredient database
  - Suggests meals from your saved collection
  - Smart food matching (e.g., "ไข่ 2 ลูก" auto-matches "ไข่ต้ม" in DB)
  - Uses DB nutrition for instant logging (no energy cost!)

- **Custom Meal Creation via Chat**: Create meals with ingredients through chat
  - Example: "สร้างเมนู keto bread มี almond flour, butter, milk"
  - Saves as preliminary entry → use "Analyze All" for full nutrition
  - Auto-saves to MyMeal database after analysis

- **Data-Driven Responses**: Ask questions about your eating habits
  - "วันนี้กินไปกี่แคล?" → Shows consumed vs target
  - "เดือนนี้กินอะไรเยอะสุด?" → Analyzes recent history
  - "แนะนำเมนูประมาณ 500 kcal" → Suggests from your saved meals

- **Enhanced AI Context**: AI now knows your full nutrition profile
  - Carb/Fat goals (not just protein/calories)
  - Meal budgets (Breakfast/Lunch/Dinner/Snack)
  - Micronutrient targets (Fiber, Sugar, Sodium)

#### UI Improvements
- **Data Source Status Icons**: New visual indicators for food entries
  - 🗄️ Database icon (purple) = From MyMeal/Ingredient DB
  - ✨ Sparkle icon (green) = AI Verified
  - ✏️ Edit icon (orange) = Pending Analyze
  - Shows on food card (40x40 icon) and as badge overlay on food photos

- **Chat UI Cleanup**
  - Removed "2+" badge for cleaner interface
  - More space for conversation
  - Source icons in chat replies (🗄️ = from DB, ✏️ = pending)

- **Analyze All Bar**: Database icon now consistent across all screens

### 🐛 Bug Fixes
- **Analyze All Database Save**: Fixed analyzed items not saving to MyMeal/Ingredient
  - Added auto-save after successful analysis
  - Checks for duplicates before saving
  - Applied to batch analysis, individual fallback, and re-analysis flows

- **Chat Ingredients Hint**: Fixed AI not returning ingredient hints
  - Updated prompt to prioritize ingredient hints over full analysis
  - Added fallback to extract names from ingredients_detail if needed
  - Custom meals now properly save ingredient lists

- **AI Prompt Conflict**: Fixed AI analyzing when it should only log ingredients
  - Restructured prompt with CUSTOM MEAL MODE section at top
  - Added clear exceptions for when NOT to analyze
  - Example responses provided for clarity

### 🔧 Technical Improvements
- Added `_gatherFoodContext()` in chat provider (MyMeal, Ingredient, history, today's summary)
- Updated `GeminiChatService.analyzeChatMessage()` to accept foodContext parameter
- Backend `buildChatPrompt()` now injects user's food database context
- `analyzeFoodBatch()` and `analyzeFoodByName()` now accept ingredientNames parameter
- Added preliminary ingredientsJson support for chat-created entries
- Energy cost display fixed (Menu/Tips chips now show 1 energy)

---

## [1.1.8+33] - 2026-02-19

### 🐛 Bug Fixes
- **Meal Ingredients Display**: Fixed meal detail bottom sheet not showing ingredients list
  - Changed from `ref.read()` to `ref.watch()` for reactive updates
  - Wrapped bottom sheet builder with `Consumer` widget
  - Ingredients now display correctly when tapping on a meal
  
- **Add Ingredient Save Issue**: Fixed "Add Ingredient" button not saving new ingredients
  - Corrected save logic to use `saveIngredient()` for create mode
  - Corrected save logic to use `updateIngredient()` for edit mode
  - Removed duplicate save operation in callback
  - Added proper async/await handling

- **Edit Ingredient Stale Data**: Fixed edit screen showing old values after saving
  - Now reloads ingredient from database before opening edit sheet
  - Ensures fresh data is always displayed when editing
  - Applied same fix to meal editing

### 🔧 Technical Improvements
- Changed `EditIngredientSheet.onSave` callback from sync to async
- Added debug logging for ingredient save operations
- Improved error handling with stack traces in edit ingredient sheet
- Added null checks and error messages for missing ingredients/meals

---

## [1.1.7+32] - 2026-02-19

### 🐛 Bug Fixes
- **Food Scanning Auto-Analysis Disabled**: Fixed aggressive auto-analysis when scanning food images
  - Removed auto-trigger listener that analyzed images immediately after scanning
  - Scanned images now save as 0 kcal, 1 serving and wait for manual analysis
  - Users must press "Analyze All" button when ready to analyze
  - Prevents wasting Energy on food images the user didn't eat
  - Updated feedback message: "Saved — use Analyze All when ready"

### 🔧 Improvements
- **AI Search Feedback Enhanced**: Ingredient search now shows quantity used in results
  - Example: `AI: "chicken" 150.0 g → 165 kcal` (instead of just "chicken → 165 kcal")
  - Makes it easier to verify that the correct quantity was sent to AI
  - Applied to all ingredient editing sheets

### 🔧 Technical
- Removed `_autoTriggerAnalysisIfNeeded()` method from `HealthTimelineTab`
- Removed `_triggerAutoAnalysisInTimeline()` method from `HomeScreen`
- Removed auto-trigger listener in `initState()` of `HealthTimelineTab`
- Updated `ImageAnalysisPreviewScreen` success message
- Updated `EditIngredientSheet` AI search feedback to include quantity

---

## [1.1.6+31] - 2026-02-18

### 🔒 Privacy & Compliance
- **Firebase Analytics Consent System**: Added GDPR/PDPA compliant user consent
  - Analytics disabled by default, requires user opt-in
  - Consent dialog shown after onboarding
  - Toggle in Profile → Settings to opt-in/opt-out anytime
  - Privacy Policy updated with Analytics disclosure
- **Privacy Policy Updated**: Added Firebase Analytics, PDPA compliance sections
  - Section 2.3: Firebase Analytics data collection (optional)
  - Section 10: Data Collection Consent & opt-out instructions
  - Section 11: PDPA Compliance (Thailand Personal Data Protection Act)
  - Effective date: February 18, 2026

### 🛒 Store Compliance
- **Billing Library Update**: Updated to Google Play Billing Library 7.0+
  - in_app_purchase: 3.2.2 → 3.2.3
  - in_app_purchase_storekit: 0.3.22+1 → 0.4.7
  - Resolves Google Play policy violation (Aug 31, 2025 deadline)
- **Ready for Data Safety Declaration**: App compliant with Google Play data disclosure requirements

### 🍽️ Food Suggestions
- **Daily Calorie Cap**: Meal suggestions now respect daily calorie limits
  - If daily calories exceeded, no suggestions shown
  - If remaining calories < meal budget, suggests up to remaining amount only
  - Shows "Daily goal reached" message when over limit
  - Displays "Daily remaining ~X kcal" in orange when capped

### 📝 Files Added
- `lib/core/services/consent_service.dart`: Consent management
- `lib/core/widgets/analytics_consent_dialog.dart`: User consent UI
- `_project_manager/legal/privacy-policy.html`: HTML version for web hosting

---

## [1.1.5+30] - 2026-02-18

### ✨ New Features
- **Smart Food Suggestions (Ghost Suggestions)**: AI-powered meal recommendations in empty meal slots
  - Suggests foods from My Meals, Ingredients, and yesterday's entries that fit your per-meal budget
  - Shows top recommendation + up to 4 alternatives as tappable cards
  - One-tap to auto-fill with complete ingredient details (for My Meals)
  - Displays as faded "ghost" UI until you add food to that meal
  - Falls back to yesterday's meals when My Meal database is empty
  - Shows budget info (e.g., "515 / 560 kcal") in meal section headers
- **Suggestion Threshold Setting**: Control how flexible food suggestions are
  - Set threshold (± kcal) for suggestion range in Health Goals
  - Example: 700 kcal budget + 100 threshold → suggests 600-800 kcal foods
  - Default: ±100 kcal
  - Includes explanatory card to help users understand the feature
- **Per-Meal Calorie Budgets**: Customize calorie allocation for each meal
  - Set individual budgets for Breakfast, Lunch, Dinner, Snack
  - Lock 3 meals to auto-calculate the 4th (similar to macro locking)
  - Live validation shows total vs. goal
  - Smart suggestions use these budgets for personalized recommendations

### 🔥 Improvements
- **Exit Confirmation Dialog**: Added warning when pressing back to exit app
  - Prevents accidental app closure
  - Shows "Are you sure you want to exit?" dialog
- **My Meal Auto-Fill**: Tapping ghost suggestions from My Meals opens full ingredient view
  - Shows complete ingredient breakdown with serving size control
  - Saves all ingredients (main + sub-ingredients) to `ingredientsJson`
  - Same rich experience as logging from My Meal manually
- **Removed Quick Add Section**: Replaced with superior ghost suggestions system
  - No more "Favorite + Repeat Yesterday" section
  - Ghost suggestions are more intelligent and context-aware

### 🔧 Technical
- Added `suggestionThreshold`, `breakfastBudget`, `lunchBudget`, `dinnerBudget`, `snackBudget` to UserProfile
- New `FulfillCalorieProvider` calculates meal suggestions based on budget + threshold
- New `GhostMealSuggestion` widget with alternative cards UI
- Updated `MealSection` to display budget in header and pass suggestion callbacks
- Modified `LogFromMealSheet` integration for seamless ghost suggestion tap
- Isar schema migration for new profile fields (v30)

---

## [1.1.4+29] - 2026-02-18

### 🐛 Bug Fixes
- **AI Analysis Loading State**: Fixed loading dialog blocking back navigation
  - Replaced `ErrorHandler.showLoading` dialog with inline loading indicator
  - Added `PopScope` warning dialog when user tries to exit during analysis
  - Shows "ถ้าออกตอนนี้ผลวิเคราะห์จะหายไป และต้องวิเคราะห์ใหม่ (เสีย Energy อีกครั้ง)"
  - Prevents app from getting stuck in loading state
- **Sub-ingredients Not Updating**: Fixed sub-ingredients not clearing when main ingredient changes
  - Now clears old sub-ingredients before AI lookup
  - Sub-ingredients properly update from AI results when main ingredient changes
- **Search Button Auto-Select**: Fixed search button auto-selecting closest DB match
  - Removed `_findInDb` from `_lookupIngredient` method
  - Search button (magnifying glass) now always goes to AI analysis
  - Users can still select from Autocomplete dropdown for free DB lookup
  - If user types without selecting from dropdown → treated as new item for AI search
- **Autocomplete Not Showing Suggestions**: Fixed Autocomplete dropdown not displaying ingredient suggestions
  - Changed from `ref.read(allIngredientsProvider)` to `ref.watch(allIngredientsProvider)` in build method
  - Added `_cachedIngredients` field to properly subscribe to provider updates
  - Autocomplete now shows matching ingredients while typing (e.g., "ground" shows "boiled ground beef meatballs")
- **Non-Food Image Analysis Error**: Fixed `FormatException` when analyzing non-food images
  - Added validation to detect when AI returns text instead of JSON
  - Shows user-friendly Thai error message: "ไม่พบอาหารในภาพนี้ กรุณาลองถ่ายภาพอาหารใหม่อีกครั้ง"
  - Prevents raw `FormatException: Unexpected character` errors

### 🔧 Technical
- Removed unused `_findInDb` methods from `edit_food_bottom_sheet.dart` and `gemini_analysis_sheet.dart`
- Fixed Autocomplete provider subscription in `create_meal_sheet.dart`
- Improved error handling in `GeminiService._callBackend` for non-JSON responses
- Added proper `mounted` checks in `food_preview_screen.dart` finally block

---

## [1.1.3+27] - 2026-02-16

### 🐛 Bug Fixes
- **Create New Meal**: Fixed ingredient order bug — new items no longer replace/edit wrong rows
  - Added `UniqueKey` per ingredient row to prevent Flutter state reuse
  - New ingredients still appear at top when tapping Add
- **Unit Dropdown**: Replaced hardcoded unit lists with `UnitConverter.allDropdownItems` (36 units)
  - Image Analysis Preview, Food Detail, Health Timeline dialogs now show full unit list
  - Backend `analyzeFood.ts` prompt and validation updated to match

### ✨ Improvements
- **AI All (Create Meal)**: Now shows confirmation dialog before analyzing
  - Displays ingredient list and Energy cost (1 per item)
  - User must confirm before Energy is deducted
- **Individual AI lookup**: Still deducts 1 Energy directly (no confirmation needed)

### 🔧 Technical
- Removed unused `_showScanOptions` and imports (health_timeline_tab)
- Replaced deprecated `withOpacity` → `withValues` (health_timeline_tab, food_detail_bottom_sheet, create_meal_sheet)
- Replaced deprecated `value` → `initialValue` in DropdownButtonFormField

---

## [1.1.3+26] - 2026-02-15

### ✨ New Features
- **Cuisine Preference**: Set your typical cuisine for personalized AI recommendations
  - Choose from 15 cuisines (Thai, Japanese, Korean, Chinese, etc.)
  - Available in Onboarding (Page 3) and Profile Settings
  - AI suggests meals matching your cuisine preference
  - AI estimates portion sizes based on your cuisine culture

### 🐛 Bug Fixes
- Fixed chat input hint: Changed "พิมพ์ข้อความ..." to "Type a message..."
- Improved menu suggestion prompt: AI now strictly recommends dishes from selected cuisine

### 🔧 Technical
- Added `cuisinePreference` field to UserProfile (default: 'international')
- Backend prompts updated to use cuisine preference for chat and menu suggestions
- New `CuisineOptions` constant shared between Onboarding and Settings

---

## [1.0.3+24] - 2026-02-14

### 🚀 Production Launch
- **Welcome Gift**: New users now receive **100 Energy** (changed from 1000 beta testing)
- Ready for public release on Play Store

### 🐛 Critical Fixes
- **Fixed 400 Error**: Added `deviceId` to request body (was only in header)
- **Image Compression**: Resize images to 800px max width before upload
  - Reduces ~3-10MB photos to ~200-500KB
  - Prevents request timeouts and 400 errors
  - Better performance and lower bandwidth

### 🚀 Major Features
- **Dual AI Chat System**: Switch between Local AI (Free) and Miro AI (2⚡/chat)
  - Local AI: Free, English only, basic food logging
  - Miro AI: Multi-language, smart multi-food parsing, personalized responses
- **Personalized AI**: Miro AI uses your profile (age, weight, goals, activity level) for tailored advice
- **Multi-Food Parsing**: Log multiple foods in one message (e.g., "breakfast: eggs and toast, lunch: chicken salad")
- **Smart Menu Suggestions**: Personalized meal recommendations (2⚡)
- **Collapsible Quick Actions**: Clean, expandable UI

### ✨ Improvements
- **Compact Chat Interface**: Reduced header size, better visibility
- **Welcome Screen**: Added helpful examples (American food diary format)
- **Energy Cost**: Chat now costs 2⚡ (was 1⚡) to reflect token usage
- **Weekly/Monthly Summaries**: View nutrition progress over time (Free)
- **Direct Navigation**: Chat button now goes straight to full chat screen

### 🎨 UI/UX
- Simplified AI mode toggle (more compact)
- Removed energy indicator from input area
- Collapsible quick action buttons (tap arrow to show/hide)
- Better space utilization
- Improved welcome screen with real-world examples

### 🔧 Technical
- Backend receives user profile context for personalization
- Enhanced Gemini prompts with user data
- Variable energy costs (2 for chat/menu, 1 for images)
- Better error handling

### 🐛 Bug Fixes
- Fixed feature tour compilation error
- Improved energy validation
- Better multi-language food name handling

---

## [1.0.3+21] - 2026-02-13
- ⚡ **Energy-based AI Analysis**
  - Replaced BYOK with built-in backend (Firebase Cloud Functions)
  - AI analysis now costs 1 Energy per request
  - Users get 1000 Energy welcome gift on first install (beta: 1000, production: 100)
  
- 💰 **In-App Purchases (8 Energy Packages)**
  - Regular packages: 100, 500, 1000, 3000 Energy
  - Welcome Offer (40% off, 24-hour limited): Available after 10 AI uses
  - All purchases are non-refundable and never expire
  
- 🎁 **Welcome Offer System**
  - Unlocks after 10 AI analyses
  - 40% discount on all Energy packages
  - Valid for 24 hours only
  - Pop-up notification when unlocked (with countdown timer)
  - Progress indicator in Energy Store showing X/10 uses

### 🐛 Critical Bug Fixes
- **Fixed double-tap issue when analyzing food**
  - Added request tracking to prevent duplicate AI calls
  - Shows "⏳ Analysis in progress" if user clicks again
  - Prevents Energy deduction for duplicate requests
  
- **Fixed app crash after AI analysis completes**
  - Added mounted checks before all ref.invalidate() calls
  - Fixed "Bad state: Cannot use ref after widget disposed" error
  
- **Fixed Energy Store not updating after AI usage**
  - Now invalidates both energyBalanceProvider and currentEnergyProvider
  - Energy balance updates immediately in all screens
  
- **Fixed RenderFlex overflow on food timeline cards**
  - Wrapped calorie badge with Flexible widget
  - Reduced icon sizes and spacing
  - Added verified badge (✓) for analyzed entries
  
- **Fixed Health Goals macro auto-calculation**
  - Unlocked macro now auto-calculates correctly when 2 macros are locked
  - Updates when changing locked macro values or calorie goal
  - Removed "Total from macros" display (redundant with calorie goal)
  
- **Improved error handling for API rate limits**
  - Backend retry logic with exponential backoff (3 attempts)
  - User-friendly messages for 429 errors
  - Energy not deducted if API request fails

### 🎨 UI/UX Improvements
- **AI Analysis Refinements**
  - Changed all loading messages to technical English ("PROCESSING IMAGE DATA...", "DECODING INGREDIENTS...")
  - Removed "Gemini" branding from all user-facing text
  - Added confirmation dialog when re-analyzing already-analyzed food (warns about 1 Energy cost)
  - Added confirmation dialog when re-analyzing ingredients with existing nutrition data
  
- **Health Goals Screen**
  - Direct numerical input for macros (removed +/- buttons)
  - Lock feature: Lock up to 2 macros, 3rd auto-calculates
  - Visual "auto" badge for auto-calculated macro
  - Disabled input for auto-calculated macro
  - All text translated to English
  
- **Energy UI**
  - Energy Badge shows 999+ for large balances (formatted as 1K, 10K, etc.)
  - Improved Energy Store layout and package cards
  - Added "POPULAR" and "BEST DEAL" badges
  - Updated "Syncs across devices" to "One-time purchase, per device"

### 📄 Legal & Compliance
- **Updated Privacy Policy** (English)
  - Removed BYOK references
  - Added Energy System data handling
  - Added Firebase backend information
  - Added children's privacy section
  
- **Updated Terms of Service** (English)
  - Added comprehensive Energy System terms
  - Energy is non-refundable and non-exchangeable for cash
  - Energy has no expiration date
  - MIRO system decisions regarding Energy disputes are final
  - Added prohibited uses and limitation of liability

### 🔧 Technical Changes
- Migrated from direct Gemini API to Firebase Cloud Functions backend
- Added device-based Energy synchronization with Firebase Firestore
- Implemented exponential backoff retry for failed API requests (3 attempts)
- Better state management for Energy balance with dual providers
- Improved mounted checks to prevent disposed widget errors
- Enhanced confirmation dialogs with proper state tracking
- Optimized provider invalidation for real-time Energy updates

## [1.0.2+20] - 2026-02-12

### Added
- ⏱️ **Test Connection cooldown (30 seconds)**
  - Prevents users from clicking "Test" too many times
  - Shows countdown timer if clicked too quickly
  - Helps avoid "API quota exceeded" errors from rate limiting
  - Explains Gemini API rate limits: 15 requests/minute

### Changed
- ❓ **New FAQ: "Why does Test Connection show API quota exceeded?"**
  - Explains that clicking Test multiple times triggers rate limits
  - Provides clear solution: wait 1-2 minutes
  - Helps users understand this is NOT an API Key issue

## [1.0.2+19] - 2026-02-12

### Changed
- 📱 **Improved error messages for non-technical users**
  - Rewrote all API error messages to be more user-friendly
  - "API quota exceeded" → "API Limit Reached" with clear explanation
  - Added multi-line error messages with title and detailed explanation
  - Changed from SnackBar to Dialog for better readability
  - Errors now explain what happened and how to fix it

### Added
- ❓ **New FAQ: Google Security Alert**
  - Added FAQ explaining that Google security alerts are normal
  - Helps users understand the login warning is not related to the app
  - Reduces confusion for non-technical beta testers

### Example improvements:
- **Before**: "Exception: API quota exceeded — please wait a moment and try again"
- **After**: Dialog with title "API Limit Reached" and message "Your API key has been used too many times today. Please try again later (usually after a few minutes) or create a new API key"

## [1.0.2+18] - 2026-02-12

### Fixed
- 🐛 **Fixed Beta Feedback email launcher on some devices**
  - Changed to use `LaunchMode.externalApplication` for better compatibility
  - Added fallback dialog when no email app is found
  - Shows selectable email address and message content for manual copy
  - Improved error handling for email launch failures

## [1.0.2+17] - 2026-02-12

### Added
- 🧪 **Beta Feedback Button (Closed Beta Only)**
  - Added floating orange feedback button on bottom-left of home screen
  - Pre-filled template with Device info (saved for convenience), Category selector, and Feedback field
  - Categories: Bug, Suggestion, Health, Feedback, Other
  - Sends email to lnxelnope@gmail.com with subject: `[MIRO Beta] [Category] Feedback`
  - Device info is saved locally for next feedback
  - **TODO: Remove before public launch** (marked in code with comments)

### Changed
- 🆓 **All users are Pro during Closed Beta**
  - Set `_forceProDuringDev = true` in `usage_limiter.dart`
  - No AI usage limits during beta testing
  - Everyone can use unlimited Gemini analysis
  - **TODO: Set back to `false` before public launch** (when removing feedback button)

## [1.0.2+16] - 2026-02-12

### Changed
- 🌍 **Completed English localization in Log from Meal sheet**
  - Changed "ฐาน:" → **"Base:"** (meal base description)
  - Changed "ปริมาณ" → **"Amount"** (serving size label)
  - Changed "เดิม" → **"Original"** (helper text)
  - Changed "โปรตีน" → **"Protein"**, "คาร์บ" → **"Carbs"**, "ไขมัน" → **"Fat"** (macro labels)
  - App is now **100% English** — no Thai text remaining in user-facing screens

## [1.0.2+15] - 2026-02-12

### Changed
- 📸 **Adjusted photo scan defaults for better performance**
  - Changed default scan period to **1 day** (from 7 days)
  - Changed default scan limit to **100 images** (from 500 images)
  - Reason: More efficient scanning, reduces processing time and battery usage
  - Users can still adjust these settings in Profile → Photo Scan Settings

### Fixed
- 🎨 **Fixed AI/Manual badge being clickable in My Meals**
  - Badge is now display-only (non-interactive)
  - Prevents unnecessary detail sheet opening when clicking the badge
  - Use Edit button or tap the meal name/card to view details

## [1.0.2+14] - 2026-02-12

### Fixed
- 🎨 **Fixed unit dropdown showing white text on white background**
  - Added `style: TextStyle(color: Colors.black)` to all unit dropdowns
  - Added `dropdownColor: Colors.white` to ensure readable menu background
  - Fixed in: Create Meal, Edit Ingredient, Edit Food, Gemini Analysis, Add Food screens
  - Users can now properly see and select units when creating/editing meals and ingredients

## [1.0.2+13] - 2026-02-12

### Fixed
- 🐛 **Fixed Gallery permission issue preventing photo scanning**
  - Fixed `GalleryService` requesting all media types (image + video) causing permission denial
  - Now explicitly requests `RequestType.image` only (matching AndroidManifest permissions)
  - Added proper permission check for both `isAuth` and `hasAccess` (supports Android 14+ limited access)
  - This resolves "Gallery access denied" error even when permission was granted

- 🔧 **Fixed Isar database query compilation errors**
  - Added missing `import 'package:isar/isar.dart'` to `profile_screen.dart` and `scan_controller.dart`
  - Added missing `import '../../health/models/food_entry.dart'` to `profile_screen.dart`
  - Fixed `sourceEqualTo()` and `findFirst()` method not found errors

### Changed
- 🌍 **Removed ALL remaining Thai text from the app**
  - Changed "ใช้เมนูนี้" to "Use This Meal" in My Meals
  - Changed "แก้ไข" to "Edit" and "ลบ" to "Delete" in Ingredients
  - Changed all barcode/nutrition label scanner text to English
  - Changed food preview and meal logging text to English
  - **Fixed AI vision returning Thai units**: Changed default units from "จาน"/"ฟอง" to "plate"/"egg"
  - Removed `_translateLabel()` function that was converting English labels to Thai
  - App is now **100% English** for international release

## [1.0.2+12] - 2026-02-12

### Fixed
- 🐛 **Fixed photo scan not working after first scan**
  - Fixed `getScanStartDate()` logic that was blocking subsequent scans
  - Removed `lastScanTime` comparison that prevented finding new images
  - Now always uses `daysBack` setting for consistent scanning behavior
  - **Added duplicate detection** - prevents scanning same image multiple times
  - **Fixed Reset Scan History** - now properly deletes gallery-scanned entries before re-scanning

### Changed
- 📸 **Reverted photo scan defaults to original values**
  - Changed default scan period back to **7 days** (from 1 day)
  - Changed default scan limit back to **500 images** (from 100 images)
  - Reason: 1 day was too restrictive and caused scan failures
  - Users can still adjust these settings in Profile → Photo Scan

- 🔧 **Updated Android SDK targets**
  - Set `minSdk = 23` (explicit Android 6.0+)
  - Set `targetSdk = 35` (Android 15 - **Required by Play Store**)
  - Note: May not support ~18,940 older devices, but required for Play Store compliance

## [1.0.2+8] - 2026-02-12

### Changed
- 🛒 **Updated Product ID to `miro_pro`**
  - Google Play Console uses underscore for Product ID
  - Note: The SKU field (รหัสตัวเลือกการซื้อ) will auto-generate as `miro-pro` (with dash)

## [1.0.2+6] - 2026-02-12

### Fixed
- 🛒 **Fixed In-App Purchase not working**
  - Added `BILLING` permission to AndroidManifest
  - Added detailed debug logging for purchase flow
  - Added loading dialog when initiating purchase
  - Added error messages to show user what went wrong
  - Improved purchase status tracking
  - **Changed Product ID from `miro_cal_pro` to `miro-pro`** (Play Console format)

### Changed
- 🐛 Enhanced error handling in PurchaseService
- 📱 Better UI feedback during purchase process

### Important for Play Console Setup
To enable In-App Purchase, you must:
1. Go to Play Console → Monetize → In-app products
2. Create product with ID: `miro_pro` (Product ID - underscore allowed)
3. The SKU field will auto-generate (you can use dash here if required)
4. Set as **Active**
5. Set price
6. Make sure app is published to at least Internal Test track

## [1.0.1+5] - 2026-02-12

### Fixed
- 🔧 **Fixed API Key saving issue in release builds**
  - Added ProGuard rules for flutter_secure_storage
  - Added ProGuard rules for EncryptedSharedPreferences
  - Set explicit minSdk = 23 for Android 6.0+
  - Added `resetOnError: true` to prevent corrupted data issues
  - Added debug logging to trace storage operations

### Changed
- 🌍 **Updated onboarding screens to English**
  - Changed welcome screen logo from icon to app logo
  - Updated tagline to "the simplest AI-powered calorie tracker"
  - Translated all features screen text to English
  - Translated Basic Info screen to English
  - Translated API Key setup screen to English

### Technical Details
- Added to `proguard-rules.pro`:
  - Keep rules for `flutter_secure_storage`
  - Keep rules for `androidx.security.crypto`
  - Keep rules for `com.google.crypto.tink`
  - Keep rules for `EncryptedSharedPreferences`

## [1.0.0+4] - 2026-02-11

### Initial Release
- 🎉 First internal test release on Play Store
