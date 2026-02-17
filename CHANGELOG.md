# Changelog

## [1.1.3+28] - 2026-02-18

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
