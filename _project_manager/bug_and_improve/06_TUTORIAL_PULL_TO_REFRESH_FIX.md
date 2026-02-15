# Implementation Guide #06: Fix Tutorial Pull-to-Refresh Text Off-Screen

**Priority:** 🔴 High  
**Estimated Time:** 30-60 minutes  
**Difficulty:** Easy-Medium

---

## Overview

Fix the Pull-to-Refresh tutorial step where the description text appears off-screen (above the visible area), leaving users seeing only a blank dark overlay with no text.

---

## Problem

Current behavior:
- Tutorial Step 2 (Pull-to-Refresh) shows dark overlay
- Description text is positioned ABOVE the screen (negative Y or top overflow)
- Users see only a blank dark box with no text

**Expected:** Description text should be visible within screen bounds

---

## Files to Modify

### Main File:
- `lib/features/home/widgets/feature_tour.dart`

---

## Step-by-Step Implementation

### STEP 1: Locate Feature Tour File

**File:** `lib/features/home/widgets/feature_tour.dart`

**This file is around 225 lines and contains the 3-step tutorial.**

---

### STEP 2: Find Pull-to-Refresh Target Definition

**Search for the Pull-to-Refresh target (Step 2).**

**Look for code that creates a TargetFocus for the RefreshIndicator:**

```dart
// Around line 100-150
targets.add(
  TargetFocus(
    identify: "pull_to_refresh",
    keyTarget: widget.pullToRefreshKey,
    contents: [
      TargetContent(
        align: ContentAlign.bottom, // Or ContentAlign.top
        builder: (context, controller) {
          return Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Auto Photo Scan",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 20.0,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    "Pull down to refresh and scan your photo gallery for food images",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ],
  ),
);
```

---

### STEP 3: Fix Content Alignment

**The issue is likely with `ContentAlign` value.**

**Change from:**
```dart
align: ContentAlign.top,  // This causes text to go off-screen
```

**To:**
```dart
align: ContentAlign.bottom,  // This keeps text below target
```

**OR if target is at the top of screen, use:**
```dart
align: ContentAlign.custom,
customPosition: CustomTargetContentPosition(
  top: 100,  // Fixed position from top
),
```

---

### STEP 4: Add Padding to Ensure Visibility

**Wrap the content in a SafeArea and add padding:**

**Replace the builder content with:**

```dart
TargetContent(
  align: ContentAlign.bottom,
  padding: const EdgeInsets.all(20),
  builder: (context, controller) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Auto Photo Scan",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 20.0,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Pull down to refresh and scan your photo gallery for food images automatically",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  },
),
```

---

### STEP 5: Check Target Key Position

**The target key might be pointing to the wrong widget.**

**In the home screen, verify the RefreshIndicator has the correct key:**

**File:** `lib/features/home/presentation/home_screen.dart`

**Find the RefreshIndicator:**

```dart
RefreshIndicator(
  key: _pullToRefreshKey,  // Ensure this key is defined
  onRefresh: _scanGallery,
  child: ListView(
    // ...
  ),
)
```

**Ensure `_pullToRefreshKey` is created:**

```dart
final GlobalKey _pullToRefreshKey = GlobalKey();
```

**And passed to FeatureTour:**

```dart
FeatureTour(
  // ...
  pullToRefreshKey: _pullToRefreshKey,
)
```

---

### STEP 6: Alternative Fix - Use Custom Position

**If ContentAlign.bottom still doesn't work, use custom positioning:**

```dart
TargetContent(
  align: ContentAlign.custom,
  customPosition: CustomTargetContentPosition(
    top: MediaQuery.of(context).size.height * 0.4,  // 40% from top
  ),
  builder: (context, controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Auto Photo Scan",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 20.0,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Pull down to refresh and scan your photo gallery for food images automatically",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  },
),
```

---

### STEP 7: Verify Other Tutorial Steps Work Correctly

**While you're in this file, verify the other two steps:**

**Step 1: Energy Badge**
```dart
// Should use ContentAlign.bottom since badge is at top
TargetFocus(
  identify: "energy_badge",
  keyTarget: widget.energyBadgeKey,
  contents: [
    TargetContent(
      align: ContentAlign.bottom,  // Text below badge
      // ...
    ),
  ],
),
```

**Step 3: Chat Button**
```dart
// Should use ContentAlign.top since button is at bottom
TargetFocus(
  identify: "chat_button",
  keyTarget: widget.chatButtonKey,
  contents: [
    TargetContent(
      align: ContentAlign.top,  // Text above button
      // ...
    ),
  ],
),
```

---

### STEP 8: Complete Fixed Implementation

**Here's the COMPLETE fixed Pull-to-Refresh target:**

```dart
targets.add(
  TargetFocus(
    identify: "pull_to_refresh",
    keyTarget: widget.pullToRefreshKey,
    alignSkip: Alignment.topRight,
    shape: ShapeLightFocus.RRect,
    radius: 20,
    contents: [
      TargetContent(
        align: ContentAlign.bottom,
        padding: const EdgeInsets.all(20),
        builder: (context, controller) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.refresh,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Auto Photo Scan",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  "Pull down to refresh and automatically scan your photo gallery for food images",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => controller.next(),
                      child: const Text(
                        "GOT IT",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    ],
  ),
);
```

---

## Testing Checklist

- [ ] Run the app and trigger the feature tour (first launch or reset)
- [ ] Step 1 (Energy Badge) shows text correctly
- [ ] Step 2 (Pull-to-Refresh) shows text **VISIBLE ON SCREEN**
- [ ] Step 3 (Chat Button) shows text correctly
- [ ] All text is readable (not cut off, not overlapping)
- [ ] "GOT IT" or "Next" buttons are visible
- [ ] "Skip" button is visible
- [ ] Test on small screen (< 360dp width)
- [ ] Test on normal screen (360-400dp width)
- [ ] Test on large screen (> 400dp width)
- [ ] Test on different Android versions
- [ ] Test on iOS (if available)

---

## How to Reset Tutorial for Testing

**Option 1: Clear app data**
```bash
# Android
adb shell pm clear com.yourcompany.miro

# Or uninstall and reinstall
flutter run
```

**Option 2: Add a reset button temporarily**

**In profile screen or home screen, add:**

```dart
TextButton(
  onPressed: () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('feature_tour_completed_v1');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tutorial reset. Restart app to see it.')),
    );
  },
  child: Text('Reset Tutorial (DEV)'),
),
```

**Import:**
```dart
import 'package:shared_preferences/shared_preferences.dart';
```

**Remove this button after testing.**

---

## Troubleshooting

### Issue: Text still goes off-screen
**Solution 1:** Use `ContentAlign.custom` with fixed position
**Solution 2:** Increase padding and use SafeArea
**Solution 3:** Target a different widget (the ListView instead of RefreshIndicator)

### Issue: Dark overlay appears but no content at all
**Solution:** Check if the builder is returning null or empty widget. Add debug print inside builder.

### Issue: Text overlaps with target element
**Solution:** Increase padding or change content alignment

### Issue: Can't proceed to next step
**Solution:** Check if "Next" or "Got It" button is visible and functional

### Issue: Tutorial doesn't start
**Solution:** Check SharedPreferences key and ensure it's correctly checked in home_screen.dart

---

## Debug Steps

**Add debug prints to verify:**

```dart
TargetContent(
  align: ContentAlign.bottom,
  builder: (context, controller) {
    print('Pull-to-Refresh tutorial content building');
    print('Screen height: ${MediaQuery.of(context).size.height}');
    print('Padding top: ${MediaQuery.of(context).padding.top}');
    
    return Container(
      // ... rest of code
    );
  },
),
```

**Check Flutter inspector:**
- Run app in debug mode
- Open Flutter Inspector
- Click on the tutorial overlay
- Check the position and size of the content widget

---

## Completion Criteria

✅ Task is complete when:
- Pull-to-Refresh tutorial text is VISIBLE on screen
- Text doesn't overflow or get cut off
- All 3 tutorial steps work correctly
- Tested on multiple screen sizes
- No dark blank boxes with missing text
- Users can read instructions clearly
- Tutorial can be completed without issues

---

## Estimated Time

- 10 min: Locate and review current implementation
- 10 min: Fix content alignment
- 10 min: Test and verify fix works
- 10 min: Test all 3 tutorial steps
- 10 min: Test on different screen sizes
- 10 min: Final verification and cleanup

**Total: 30-60 minutes**

---

## Notes

- The `tutorial_coach_mark` package sometimes has alignment issues with widgets at screen edges
- Using `ContentAlign.custom` gives more control but requires manual positioning
- Always test on the smallest target device screen size
- SafeArea ensures content stays within visible screen bounds
- Adding proper padding prevents text from touching screen edges
