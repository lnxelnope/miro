# Isar → Drift Migration Status

## ✅ COMPLETED (40%)

### Infrastructure
- ✅ Installed Drift packages (`drift`, `drift_sqflite`, `drift_dev`)
- ✅ Created `lib/core/database/app_database.dart` with 9 tables
- ✅ Generated `app_database.g.dart`
- ✅ Created new `DatabaseService` using Drift
- ✅ Updated `build.yaml` for Drift configuration

### Model Files Deleted
- ✅ `lib/core/models/energy_transaction.dart`
- ✅ `lib/features/chat/models/chat_message.dart`
- ✅ `lib/features/profile/models/user_profile.dart`
- ✅ `lib/features/health/models/daily_summary.dart`
- ✅ `lib/features/health/models/ingredient.dart`
- ✅ `lib/features/health/models/my_meal.dart`
- ✅ `lib/features/health/models/my_meal_ingredient.dart`
- ✅ `lib/features/health/models/food_entry.dart`

### Migrated Collections
- ✅ **EnergyTransaction** (100%)
  - `lib/core/services/energy_service.dart`
  - `lib/main.dart`
  - `lib/features/energy/providers/energy_provider.dart`

---

## ⏳ TODO (60%)

### Remaining Collections to Migrate

1. **ChatMessage + ChatSession**
   - `lib/features/chat/providers/chat_provider.dart` (700 lines!)
   - `lib/core/ai/gemini_chat_service.dart`
   - `lib/features/chat/presentation/chat_screen.dart`
   - `lib/features/chat/services/intent_handler.dart`

2. **UserProfile**
   - `lib/features/profile/providers/profile_provider.dart`
   - `lib/features/profile/presentation/profile_screen.dart`
   - `lib/features/onboarding/presentation/onboarding_screen.dart`
   - `lib/main.dart`

3. **DailySummary**
   - `lib/core/services/daily_summary_service.dart`
   - `lib/features/health/providers/health_provider.dart`

4. **Ingredient**
   - `lib/features/health/widgets/create_meal_sheet.dart`
   - `lib/features/health/widgets/edit_food_bottom_sheet.dart`
   - `lib/features/home/widgets/simple_food_detail_sheet.dart`
   - `lib/features/chat/services/food_lookup_service.dart`

5. **MyMeal + MyMealIngredient**
   - `lib/features/health/providers/my_meal_provider.dart`
   - `lib/features/health/presentation/health_my_meal_tab.dart`
   - `lib/features/health/widgets/create_meal_sheet.dart`

6. **FoodEntry** (Largest!)
   - `lib/features/health/providers/health_provider.dart`
   - `lib/features/health/providers/micronutrient_stats_provider.dart`
   - `lib/features/scanner/logic/scan_controller.dart`
   - `lib/core/services/data_sync_service.dart`
   - `lib/core/services/backup_service.dart`
   - และอีกหลายไฟล์...

### Final Steps
- Delete old `.g.dart` files from Isar
- Run `dart run build_runner build --delete-conflicting-outputs`
- Test compile
- Build AAB and verify 16KB alignment

---

## 🚀 HOW TO CONTINUE

### Option 1: Use Python Script (Recommended)
```bash
# From c:\aiprogram\miro\
python migrate_isar_to_drift.py lib/

# This will:
# - Convert imports automatically
# - Convert simple queries (.where().findAll(), etc.)
# - Mark complex queries with TODO comments
# - Create .bak backups

# Then manually fix TODO markers:
grep -r "TODO: Convert" lib/
```

### Option 2: Manual Migration
Follow [`ISAR_TO_DRIFT_MIGRATION_GUIDE.md`](./ISAR_TO_DRIFT_MIGRATION_GUIDE.md) for detailed query conversion examples.

### Option 3: Continue with AI
Resume this conversation with the AI agent to continue automated migration.

---

## 📊 Files Modified So Far

1. `pubspec.yaml` - Updated dependencies
2. `build.yaml` - Created for Drift config
3. `lib/core/database/app_database.dart` - New Drift schema
4. `lib/core/database/database_service.dart` - New DatabaseService
5. `lib/core/database/database_service_drift.dart` - Compatibility wrapper
6. `lib/core/database/drift_extensions.dart` - Helper extensions
7. `lib/core/services/energy_service.dart` - Migrated ✅
8. `lib/main.dart` - Updated EnergyService instantiation ✅
9. `lib/features/energy/providers/energy_provider.dart` - Updated ✅

---

## ⚠️ IMPORTANT NOTES

1. **Data Loss OK**: User confirmed data can be deleted, so no migration script needed
2. **No Isar References**: All model files deleted, compiler will show errors for remaining usage
3. **16KB Goal**: After migration, verify `.so` files have `align 2**14` or higher
4. **Test Incrementally**: Test after each collection migration
5. **Pattern Reference**: Use `energy_service.dart` as a working example

---

## 🎯 Estimated Remaining Time

- **With Python script**: 2-4 hours (mostly manual TODO fixes)
- **Fully manual**: 1-2 days
- **With AI agent**: Continue this session for automated migration

---

**Current Status: 40% Complete | Next: ChatMessage migration**
