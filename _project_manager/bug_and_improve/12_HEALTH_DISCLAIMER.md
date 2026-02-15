# Implementation Guide #12: Health Disclaimer

**Priority:** 🔴 Critical (Legal/Liability Protection)  
**Estimated Time:** 1-2 hours  
**Difficulty:** Easy

---

## Overview

Add legally compliant health disclaimer text to protect against liability. The disclaimer must clearly state that MIRO is NOT a medical/health advisory service and all data is for informational purposes only.

---

## Legal Requirement

This disclaimer is MANDATORY to:
1. Protect against legal liability
2. Clarify the app's purpose (tracking tool, not medical advice)
3. Meet regulatory compliance standards
4. Prevent potential lawsuits from users

---

## Files to Create/Modify

### New Files:
1. `lib/core/constants/app_disclaimer.dart` - Disclaimer text constant

### Files to Modify:
1. `lib/features/health/widgets/daily_summary_card.dart` - Add disclaimer to summary
2. `lib/features/health/widgets/gemini_analysis_sheet.dart` - Add disclaimer to AI results
3. `lib/features/profile/presentation/profile_screen.dart` - Add disclaimer link/section
4. Create new screen: `lib/features/legal/presentation/disclaimer_screen.dart`

---

## Step-by-Step Implementation

### STEP 1: Create Disclaimer Constants File

**Create file:** `lib/core/constants/app_disclaimer.dart`

**Full file content:**

```dart
/// Health and liability disclaimer for MIRO app
class AppDisclaimer {
  AppDisclaimer._();

  /// Short disclaimer for inline display
  static const String short = 
      'MIRO is an informational tool only. '
      'Nutritional data are approximations and not medical advice. '
      'Consult healthcare professionals for dietary guidance.';

  /// Full disclaimer for dedicated screen
  static const String full = '''
⚠️ HEALTH & LEGAL DISCLAIMER

MIRO is a nutrition tracking and analysis tool designed for informational and personal reference purposes only. The data, estimates, and analyses provided by MIRO — including AI-generated nutritional information — are approximations and should NOT be considered as medical advice, dietary prescriptions, or professional health recommendations.

MIRO is NOT a licensed healthcare provider, dietitian, or nutritionist. The information presented within this application is intended to assist users in tracking and understanding their dietary intake, and should be used solely as a supplementary reference for the user's own analysis and decision-making.

For personalized health, dietary, or medical advice, please consult a qualified healthcare professional, registered dietitian, or licensed nutritionist.

By using MIRO, you acknowledge and agree that all nutritional data is provided on an "as-is" basis without warranty of accuracy, completeness, or fitness for any particular purpose.

MIRO, its developers, and affiliated parties assume no responsibility or liability for any consequences resulting from the use of this application or reliance on the information provided.

If you have any medical conditions, allergies, dietary restrictions, or health concerns, you MUST consult with appropriate healthcare professionals before making dietary changes.

This tool is not intended to diagnose, treat, cure, or prevent any disease or medical condition.
''';

  /// Icon for disclaimer warning
  static const String icon = '⚠️';
}
```

---

### STEP 2: Create Disclaimer Screen

**Create file:** `lib/features/legal/presentation/disclaimer_screen.dart`

**Full file content:**

```dart
import 'package:flutter/material.dart';
import 'package:miro/core/constants/app_disclaimer.dart';

class DisclaimerScreen extends StatelessWidget {
  const DisclaimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Disclaimer'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Warning icon
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    '⚠️',
                    style: TextStyle(fontSize: 48),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Full disclaimer text
            Text(
              AppDisclaimer.full,
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Acknowledgment section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Important Reminders:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildBulletPoint('All nutritional data is estimated'),
                  _buildBulletPoint('AI analysis may contain errors'),
                  _buildBulletPoint('Not a substitute for professional advice'),
                  _buildBulletPoint('Consult healthcare providers for medical guidance'),
                  _buildBulletPoint('Use at your own discretion and risk'),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Close button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade800,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'I Understand',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              fontSize: 16,
              color: Colors.blue.shade900,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

### STEP 3: Add Disclaimer Widget Component

**Create file:** `lib/core/widgets/disclaimer_widget.dart`

**Full file content:**

```dart
import 'package:flutter/material.dart';
import 'package:miro/core/constants/app_disclaimer.dart';
import 'package:miro/features/legal/presentation/disclaimer_screen.dart';

/// Reusable disclaimer widget that can be added to any screen
class DisclaimerWidget extends StatelessWidget {
  final bool compact;
  final bool showFullButton;

  const DisclaimerWidget({
    super.key,
    this.compact = false,
    this.showFullButton = true,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompactDisclaimer(context);
    } else {
      return _buildFullDisclaimer(context);
    }
  }

  Widget _buildCompactDisclaimer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'For informational purposes only. Not medical advice.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade800,
              ),
            ),
          ),
          if (showFullButton)
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const DisclaimerScreen(),
                  ),
                );
              },
              child: const Text('Details', style: TextStyle(fontSize: 12)),
            ),
        ],
      ),
    );
  }

  Widget _buildFullDisclaimer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('⚠️', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Disclaimer',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            AppDisclaimer.short,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade800,
              height: 1.4,
            ),
          ),
          if (showFullButton) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const DisclaimerScreen(),
                  ),
                );
              },
              child: const Text('Read Full Disclaimer'),
            ),
          ],
        ],
      ),
    );
  }
}
```

---

### STEP 4: Add Disclaimer to Daily Summary Card

**File:** `lib/features/health/widgets/daily_summary_card.dart`

**Find the end of the card content (before the closing Container).**

**Add the disclaimer at the bottom:**

```dart
import 'package:miro/core/widgets/disclaimer_widget.dart';

// Inside the build method, at the bottom of the card:
// ... existing progress bars and nutrition display ...

const SizedBox(height: 16),
const DisclaimerWidget(compact: true),
```

---

### STEP 5: Add Disclaimer to AI Analysis Sheet

**File:** `lib/features/health/widgets/gemini_analysis_sheet.dart`

**Find the bottom of the sheet content.**

**Add disclaimer before the "Add to Log" button:**

```dart
import 'package:miro/core/widgets/disclaimer_widget.dart';

// At the bottom of the analysis sheet content:
const SizedBox(height: 24),
const DisclaimerWidget(compact: false, showFullButton: true),
const SizedBox(height: 24),

// Then the "Add to Log" button
ElevatedButton(
  // ... existing button code
),
```

---

### STEP 6: Add Disclaimer Link to Profile Screen

**File:** `lib/features/profile/presentation/profile_screen.dart`

**Find the ListView with profile options (Settings, About, etc.).**

**Add a disclaimer option:**

```dart
import 'package:miro/features/legal/presentation/disclaimer_screen.dart';

// In the ListView, add this ListTile:
ListTile(
  leading: const Icon(Icons.warning_amber, color: Colors.orange),
  title: const Text('Health Disclaimer'),
  subtitle: const Text('Important legal information'),
  trailing: const Icon(Icons.chevron_right),
  onTap: () {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const DisclaimerScreen(),
      ),
    );
  },
),
```

---

### STEP 7: Create Legal Folder Structure

**Create folders:**

```
lib/features/legal/
  └── presentation/
      └── disclaimer_screen.dart (already created in STEP 2)
```

**Create:**
```
lib/core/constants/
  └── app_disclaimer.dart (already created in STEP 1)
```

**Create:**
```
lib/core/widgets/
  └── disclaimer_widget.dart (already created in STEP 3)
```

---

### STEP 8: Add First-Time Disclaimer Dialog (Optional but Recommended)

**File:** `lib/features/onboarding/presentation/onboarding_screen.dart`

**After completing onboarding, show disclaimer dialog once:**

```dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:miro/features/legal/presentation/disclaimer_screen.dart';

// In the "Get Started" button onPressed:
onPressed: () async {
  // Save onboarding completion
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('onboarding_completed', true);
  
  // Check if disclaimer has been shown
  final disclaimerShown = prefs.getBool('disclaimer_acknowledged') ?? false;
  
  if (!disclaimerShown && mounted) {
    // Show disclaimer dialog
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Text('⚠️', style: TextStyle(fontSize: 24)),
            SizedBox(width: 12),
            Text('Important Notice'),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            'Before you continue, please note:\n\n${AppDisclaimer.short}\n\n'
            'Do you understand and agree to use MIRO as an informational tool only?',
            style: const TextStyle(fontSize: 16, height: 1.4),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await prefs.setBool('disclaimer_acknowledged', true);
              Navigator.of(context).pop();
              // Navigate to home
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
            child: const Text('I Understand and Agree'),
          ),
        ],
      ),
    );
  } else if (mounted) {
    // Navigate to home directly
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }
},
```

---

## Testing Checklist

- [ ] Daily Summary Card shows compact disclaimer at bottom
- [ ] AI Analysis Sheet shows full disclaimer
- [ ] Profile screen has "Health Disclaimer" option
- [ ] Tapping profile disclaimer option opens full disclaimer screen
- [ ] Disclaimer screen displays full legal text
- [ ] "I Understand" button closes disclaimer screen
- [ ] First-time users see disclaimer dialog after onboarding
- [ ] Disclaimer is visible on small screens (no text cutoff)
- [ ] All disclaimer text is readable (proper font size)
- [ ] "Read Full Disclaimer" links work correctly
- [ ] No build errors or missing imports

---

## Troubleshooting

### Issue: Import errors for DisclaimerWidget
**Solution:** Ensure `lib/core/widgets/disclaimer_widget.dart` is created and imported correctly

### Issue: Text too small to read
**Solution:** Increase font size in disclaimer widgets (minimum 14px)

### Issue: Disclaimer makes UI too crowded
**Solution:** Use compact version in most places, full version only in analysis sheet

### Issue: Users skip disclaimer dialog
**Solution:** Make dialog `barrierDismissible: false` so they must acknowledge it

---

## Legal Review (Important!)

**Before releasing:**
1. Have a lawyer review the disclaimer text
2. Ensure it complies with local laws in your target markets
3. Consider adding app-specific language based on your jurisdiction
4. Update disclaimer if app features change significantly
5. Keep disclaimer version history for legal records

---

## Completion Criteria

✅ Task is complete when:
- Disclaimer constants file created
- Disclaimer screen implemented
- Disclaimer widget component created
- Disclaimer added to daily summary card
- Disclaimer added to AI analysis sheet
- Disclaimer link added to profile screen
- First-time disclaimer dialog works (optional)
- All disclaimer text is legally appropriate
- No build errors
- Tested on multiple screens and verified visibility

---

## Estimated Time

- 20 min: Create disclaimer constants and screen
- 15 min: Create disclaimer widget component
- 15 min: Add to daily summary card
- 15 min: Add to AI analysis sheet
- 10 min: Add to profile screen
- 15 min: Add first-time dialog
- 10 min: Testing and verification

**Total: 1-2 hours**

---

## Critical Notes

- This is NOT legal advice - consult a lawyer
- Disclaimer must be VISIBLE, not hidden
- Users should see it regularly (not just once)
- Keep disclaimer text updated
- Document when and where disclaimer is shown
- This protects you legally but doesn't eliminate all liability
- Consider requiring users to acknowledge disclaimer in onboarding
