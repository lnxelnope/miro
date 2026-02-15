# 🚀 Pre-Launch Checklist

## ⚠️ CRITICAL: Remove Beta Features Before Public Launch

### 1. Remove Beta Feedback Button
- [ ] Delete file: `lib/features/feedback/beta_feedback_button.dart`
- [ ] Remove import and usage in `lib/features/home/presentation/home_screen.dart`:
  ```dart
  // Remove this import:
  import '../../feedback/beta_feedback_button.dart';
  
  // Change Stack back to just HealthPage:
  body: const HealthPage(),  // Remove Stack wrapper
  ```

### 2. Disable Force Pro Mode
- [ ] Edit `lib/core/services/usage_limiter.dart`:
  ```dart
  // Change this line:
  static const bool _forceProDuringDev = false;  // Set to FALSE
  ```

### 3. Verify Pro Purchase Flow
- [ ] Test "Upgrade to Pro" button in Profile screen
- [ ] Verify In-App Purchase works correctly
- [ ] Test AI usage limits for free users (3/day)
- [ ] Test unlimited AI for Pro users

### 4. Update Version
- [ ] Bump version to `1.0.3` or `1.1.0`
- [ ] Update CHANGELOG.md with "Public Release" entry

### 5. Final Checks
- [ ] Remove all TODO comments related to beta
- [ ] Test app thoroughly without beta features
- [ ] Build release APK/AAB
- [ ] Upload to Play Store Production track

---

## Search for Beta Markers

Run these commands to find remaining beta code:

```bash
# Find TODO comments
grep -r "TODO.*beta" lib/
grep -r "TODO.*Remove before" lib/

# Find feedback references
grep -r "BetaFeedback" lib/
grep -r "_forceProDuringDev" lib/
```

---

## Quick Reference

**Files to modify for public launch:**
1. `lib/features/home/presentation/home_screen.dart` — Remove feedback button
2. `lib/core/services/usage_limiter.dart` — Set `_forceProDuringDev = false`
3. `lib/features/feedback/` — Delete entire folder
