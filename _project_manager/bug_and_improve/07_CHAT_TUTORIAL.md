# Implementation Guide #07: Add Chat Tutorial Step

**Priority:** 🟡 Medium  
**Estimated Time:** 45-60 minutes  
**Difficulty:** Easy-Medium

---

## Overview

Add a new tutorial step to teach users about the Chat system functionality, including how to type food names, use multiple languages with Miro AI, access Quick Actions, and understand Energy consumption.

---

## Files to Modify

### Main Files:
1. `lib/features/home/widgets/feature_tour.dart` - Add new chat tutorial step
2. `lib/features/home/presentation/home_screen.dart` - Pass chat button key to tour

---

## Step-by-Step Implementation

### STEP 1: Add Chat Button GlobalKey in Home Screen

**File:** `lib/features/home/presentation/home_screen.dart`

**Find where other GlobalKeys are defined (around line 30-40):**

```dart
final GlobalKey _energyBadgeKey = GlobalKey();
final GlobalKey _pullToRefreshKey = GlobalKey();
// Add this:
final GlobalKey _chatButtonKey = GlobalKey();
```

**Find the `MagicButton` widget (around line 180-200):**

```dart
MagicButton(
  onTap: () {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ChatScreen(),
      ),
    );
  },
),
```

**Wrap it with a key:**

```dart
MagicButton(
  key: _chatButtonKey,  // Add this line
  onTap: () {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ChatScreen(),
      ),
    );
  },
),
```

**Pass the key to FeatureTour (find where FeatureTour is shown):**

```dart
FeatureTour(
  energyBadgeKey: _energyBadgeKey,
  pullToRefreshKey: _pullToRefreshKey,
  chatButtonKey: _chatButtonKey,  // Add this line
)
```

---

### STEP 2: Update FeatureTour Widget Constructor

**File:** `lib/features/home/widgets/feature_tour.dart`

**Find the constructor (around line 10-20):**

```dart
class FeatureTour extends StatefulWidget {
  final GlobalKey energyBadgeKey;
  final GlobalKey pullToRefreshKey;
  // Add this:
  final GlobalKey chatButtonKey;

  const FeatureTour({
    super.key,
    required this.energyBadgeKey,
    required this.pullToRefreshKey,
    required this.chatButtonKey,  // Add this
  });

  @override
  State<FeatureTour> createState() => _FeatureTourState();
}
```

---

### STEP 3: Add Chat Tutorial Target

**File:** `lib/features/home/widgets/feature_tour.dart`

**Find the `_createTargets()` method where targets are added.**

**After the Pull-to-Refresh target, add the Chat target:**

```dart
// Around line 150-180, after the pull-to-refresh target

// Step 3: Chat Button
targets.add(
  TargetFocus(
    identify: "chat_button",
    keyTarget: widget.chatButtonKey,
    alignSkip: Alignment.topRight,
    shape: ShapeLightFocus.Circle,
    radius: 10,
    contents: [
      TargetContent(
        align: ContentAlign.top,
        padding: const EdgeInsets.all(20),
        builder: (context, controller) {
          return Container(
            margin: const EdgeInsets.only(bottom: 100),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title with icon
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chat_bubble,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "AI Chat Assistant",
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
                
                // Feature descriptions
                _buildFeatureRow(
                  icon: Icons.restaurant_menu,
                  text: "Type food names to analyze nutrition",
                ),
                const SizedBox(height: 12),
                _buildFeatureRow(
                  icon: Icons.language,
                  text: "Use multiple languages with Miro AI mode",
                ),
                const SizedBox(height: 12),
                _buildFeatureRow(
                  icon: Icons.flash_on,
                  text: "Quick Actions for common tasks",
                ),
                const SizedBox(height: 12),
                _buildFeatureRow(
                  icon: Icons.battery_charging_full,
                  text: "Uses 1 Energy per message with Miro AI",
                ),
                
                const SizedBox(height: 20),
                
                // Note box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Local AI mode is free but English-only",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        controller.skip();
                      },
                      child: const Text(
                        "SKIP",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        controller.next();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text("FINISH"),
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

### STEP 4: Add Helper Method for Feature Rows

**Still in:** `lib/features/home/widgets/feature_tour.dart`

**Add this helper method at the bottom of the `_FeatureTourState` class:**

```dart
Widget _buildFeatureRow({required IconData icon, required String text}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(
        icon,
        color: Colors.white,
        size: 20,
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            height: 1.3,
          ),
        ),
      ),
    ],
  );
}
```

---

### STEP 5: Update Tutorial Step Count Display

**File:** `lib/features/home/widgets/feature_tour.dart`

**Find where the tutorial is shown (in `_showFeatureTour()` method):**

**If there's any text showing "Step X of Y", update it:**

```dart
// Change from "3 steps" to "4 steps" if displayed anywhere
// Or change step counter logic to reflect 4 steps instead of 3
```

**In the `showTutorial()` call, the steps are now:**
1. Energy Badge
2. Pull-to-Refresh
3. Chat Button (NEW)

---

### STEP 6: Update Tutorial Completion Logic

**The tutorial should now complete after showing all 3 steps.**

**Find the last target's "FINISH" button:**

**In Step 3 (Chat Button), the "FINISH" button should:**

```dart
ElevatedButton(
  onPressed: () {
    controller.next();  // This will finish the tutorial
  },
  child: const Text("FINISH"),
),
```

**This will automatically mark the tutorial as completed.**

---

### STEP 7: Adjust Chat Button Target Positioning

**If the content overlaps with the chat button, adjust the margin:**

**In the Container inside TargetContent:**

```dart
Container(
  margin: const EdgeInsets.only(bottom: 100),  // Adjust this value
  // Increase if content still overlaps with button
  // Decrease if content is too far from button
  ...
)
```

---

## Testing Checklist

- [ ] Tutorial starts correctly on first launch
- [ ] Step 1 (Energy Badge) shows and explains energy system
- [ ] Step 2 (Pull-to-Refresh) shows and explains auto-scan
- [ ] Step 3 (Chat Button) shows and explains chat features
- [ ] Chat tutorial content is visible and readable
- [ ] All 4 feature bullet points display correctly:
  - Type food names
  - Multiple languages
  - Quick Actions
  - Energy consumption
- [ ] Info note about Local AI displays correctly
- [ ] "SKIP" button works on all steps
- [ ] "NEXT" button works on steps 1-2
- [ ] "FINISH" button works on step 3
- [ ] Tutorial completes and doesn't show again
- [ ] Content doesn't overlap with chat button
- [ ] Tested on small, medium, and large screens

---

## How to Reset Tutorial for Testing

**Option 1: Clear SharedPreferences**

```dart
// Add temporary button in profile screen
TextButton(
  onPressed: () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('feature_tour_completed_v1');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tutorial reset. Restart app.')),
    );
  },
  child: const Text('Reset Tutorial (DEV)'),
),
```

**Option 2: Clear app data**

```bash
# Android
adb shell pm clear com.yourcompany.miro

# Or uninstall/reinstall
flutter clean
flutter run
```

---

## Troubleshooting

### Issue: Chat button key not found
**Solution:** Ensure `_chatButtonKey` is passed to both `MagicButton` and `FeatureTour`

### Issue: Content overlaps with chat button
**Solution:** Increase the `bottom` margin in the Container

### Issue: Text goes off-screen on small devices
**Solution:** Reduce font sizes or padding

### Issue: "FINISH" button doesn't complete tutorial
**Solution:** Ensure `controller.next()` is called, not `controller.skip()`

### Issue: Tutorial doesn't start
**Solution:** Check SharedPreferences key and ensure it matches across app

---

## Completion Criteria

✅ Task is complete when:
- Chat tutorial step added as Step 3
- All content displays correctly and readable
- Chat button is highlighted properly during tutorial
- Tutorial flow: Energy Badge → Pull-to-Refresh → Chat
- "FINISH" button completes tutorial
- Tutorial doesn't show again after completion
- No build errors or missing keys
- Tested on multiple screen sizes
- All 4 chat features are explained clearly

---

## Estimated Time

- 15 min: Add chat button key and pass to tour
- 15 min: Create chat tutorial target content
- 10 min: Add helper method for feature rows
- 10 min: Adjust positioning and styling
- 10 min: Testing and verification

**Total: 45-60 minutes**

---

## Notes

- This is Step 3 (last step) of the tutorial
- Use `ContentAlign.top` since chat button is at bottom of screen
- The "FINISH" button is more appropriate than "NEXT" for the last step
- Feature rows use icons for better visual communication
- Info note clarifies the difference between Local AI and Miro AI modes
