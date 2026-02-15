# Implementation Guide #05: Fix Energy Badge Overflow

**Priority:** 🔴 High  
**Estimated Time:** 30-45 minutes  
**Difficulty:** Easy

---

## Overview

Fix the Energy Badge green border overflow issue when the energy count exceeds 1,000 on small screens. Make the badge flexible and responsive to accommodate any number of digits.

---

## Problem

Current behavior:
- Energy count > 1,000 → Number overflows outside green border
- Happens on narrow screens (width < 360dp)
- Badge has fixed width that doesn't adapt

**Expected:** Badge should expand/shrink based on digit count

---

## Files to Modify

### Main File:
- `lib/features/energy/widgets/energy_badge_riverpod.dart`

---

## Step-by-Step Implementation

### STEP 1: Locate Energy Badge Widget

**File:** `lib/features/energy/widgets/energy_badge_riverpod.dart`

**This file is around 85 lines.**

**Current implementation uses fixed sizing or constrained containers.**

---

### STEP 2: Review Current Implementation

**Open the file and find the `build` method.**

**Look for the badge container structure:**

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final energyBalance = ref.watch(energyBalanceProvider);
  
  return energyBalance.when(
    data: (balance) {
      // Find the Container or similar widget that wraps the badge
      return GestureDetector(
        onTap: () {
          // Navigate to energy store
        },
        child: Container(
          // This might have fixed width or padding
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getBackgroundColor(balance),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.green, width: 2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('⚡'),
              SizedBox(width: 4),
              Text('$balance'),
            ],
          ),
        ),
      );
    },
    // ... loading and error states
  );
}
```

---

### STEP 3: Replace with Flexible Implementation

**Replace the entire `build` method with this:**

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final energyBalance = ref.watch(energyBalanceProvider);
  
  return energyBalance.when(
    data: (balance) {
      // Determine background color based on balance
      Color backgroundColor;
      if (balance < 10) {
        backgroundColor = Colors.red.withOpacity(0.1);
      } else if (balance < 30) {
        backgroundColor = Colors.orange.withOpacity(0.1);
      } else {
        backgroundColor = Colors.green.withOpacity(0.1);
      }
      
      // Determine border color
      Color borderColor;
      if (balance < 10) {
        borderColor = Colors.red;
      } else if (balance < 30) {
        borderColor = Colors.orange;
      } else {
        borderColor = Colors.green;
      }
      
      // Format display text
      final displayText = balance >= 1000 
          ? '${(balance / 1000).toStringAsFixed(1)}K' 
          : balance.toString();
      
      return GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const EnergyStoreScreen(),
            ),
          );
        },
        child: IntrinsicWidth(
          child: Container(
            constraints: const BoxConstraints(
              minWidth: 60,
              maxWidth: 120,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: borderColor,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '⚡',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      displayText,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: borderColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
    loading: () => const SizedBox(
      width: 60,
      height: 32,
      child: Center(
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    ),
    error: (error, stack) => GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const EnergyStoreScreen(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey, width: 2),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('⚡', style: TextStyle(fontSize: 16)),
            SizedBox(width: 4),
            Text('?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    ),
  );
}
```

---

### STEP 4: Add Import if Missing

**At the top of the file, ensure these imports exist:**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miro/features/energy/presentation/energy_store_screen.dart';
import 'package:miro/features/energy/providers/energy_provider.dart';
```

---

### STEP 5: Explanation of Key Changes

**1. `IntrinsicWidth` Widget:**
- Allows the container to size itself based on child content
- Ensures badge expands/contracts naturally

**2. `constraints` on Container:**
- `minWidth: 60` - Minimum width for small numbers
- `maxWidth: 120` - Maximum width to prevent huge badges

**3. `Flexible` + `FittedBox` on Text:**
- `Flexible` allows text to take available space
- `FittedBox` scales down text if it would overflow
- Combination ensures text never breaks border

**4. Display Text Formatting:**
- Numbers ≥ 1,000 show as "1.0K", "9.9K", etc.
- Reduces digit count for very large numbers
- Keeps badge compact

**5. Color Coding:**
- Red: < 10 Energy
- Orange: 10-29 Energy
- Green: ≥ 30 Energy

---

### STEP 6: Test Different Energy Values

**Add a temporary test function (optional, for testing only):**

**Create a test button in home screen temporarily:**

```dart
// In home_screen.dart, add to AppBar actions temporarily:
IconButton(
  icon: Icon(Icons.add),
  onPressed: () async {
    final energyService = EnergyService();
    await energyService.addEnergy(500);
    setState(() {}); // Refresh
  },
),
IconButton(
  icon: Icon(Icons.remove),
  onPressed: () async {
    final energyService = EnergyService();
    final current = await energyService.getBalance();
    await energyService.consumeEnergy(min(current, 100));
    setState(() {}); // Refresh
  },
),
```

**Test with these values:**
1. Set energy to 9 → Should be RED, fit properly
2. Set energy to 99 → Should be GREEN, fit properly
3. Set energy to 999 → Should be GREEN, fit properly
4. Set energy to 1,000 → Should show "1.0K", fit properly
5. Set energy to 9,999 → Should show "10.0K", fit properly
6. Set energy to 99,999 → Should show "100.0K", fit properly

**Remove test buttons after testing.**

---

## Testing Checklist

- [ ] Badge displays correctly with 1 digit (< 10)
- [ ] Badge displays correctly with 2 digits (10-99)
- [ ] Badge displays correctly with 3 digits (100-999)
- [ ] Badge displays correctly with 4+ digits (≥ 1,000, shows as K format)
- [ ] Green border never clips/overflows text
- [ ] Badge color changes correctly:
  - Red for < 10
  - Orange for 10-29
  - Green for ≥ 30
- [ ] Badge is not too large (doesn't obstruct other UI)
- [ ] Badge is not too small (text is readable)
- [ ] Tested on narrow screen (width < 360dp)
- [ ] Tested on normal screen (width 360-400dp)
- [ ] Tested on wide screen (width > 400dp)
- [ ] Tapping badge still opens Energy Store
- [ ] Loading state shows small spinner
- [ ] Error state shows "?" symbol

---

## Troubleshooting

### Issue: Text still overflows
**Solution:** Increase `maxWidth` constraint or reduce font size in `TextStyle`

### Issue: Badge is too wide
**Solution:** Reduce `maxWidth` constraint or adjust padding

### Issue: Badge is too tall
**Solution:** Reduce `vertical` padding or font size

### Issue: "K" format looks weird (e.g., "1000.0K")
**Solution:** Check the formatting logic:
```dart
final displayText = balance >= 1000 
    ? '${(balance / 1000).toStringAsFixed(1)}K'  // Shows 1.0K, 9.9K, etc.
    : balance.toString();
```

### Issue: Color not updating
**Solution:** Ensure `ref.watch(energyBalanceProvider)` is used, not `ref.read()`

---

## Alternative Solution (If Above Doesn't Work)

**If you still have issues, use this simpler approach:**

```dart
// Simpler badge with automatic wrapping
return GestureDetector(
  onTap: () { /* ... */ },
  child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: borderColor, width: 2),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('⚡'),
        const SizedBox(width: 4),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 80),
          child: Text(
            displayText,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: borderColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  ),
);
```

---

## Completion Criteria

✅ Task is complete when:
- Energy badge displays correctly for all energy values (1 to 99,999+)
- No overflow or clipping at any energy level
- Badge size adapts responsively to content
- Tested on small screens (< 360dp width)
- Badge remains readable and not obstructing other UI
- Color coding works correctly (red/orange/green)
- No build errors or warnings

---

## Estimated Time

- 10 min: Review current implementation
- 10 min: Implement flexible solution
- 10 min: Test with different energy values
- 10 min: Test on different screen sizes
- 5 min: Final verification

**Total: 30-45 minutes**

---

## Notes

- **IntrinsicWidth** is key to making the badge flexible
- **FittedBox** ensures text scales down if needed
- **Constraints** prevent badge from becoming too large or too small
- **K format** (1.0K, 9.9K) keeps badge compact for large numbers
- This solution works for any number of digits without hardcoding sizes
