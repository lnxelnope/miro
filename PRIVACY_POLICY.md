# Privacy Policy

**MiRO — My Intake Record Oracle**

> Your food data is stored locally on your device. Compact backups are synced securely via Firebase to protect your history across devices.

---

## Information We Collect

MiRO stores the following data locally on your device (Offline-first):

• Food entries (name, calories, nutrients)
• Food photos (stored locally on your device)
• Health goals (kcal, macros)
• Basic personal information (name, gender, age, weight, height)
• Created meal recipes (My Meals)
• Saved ingredients (Ingredients)
• Energy balance (for AI features)
• Energy purchase history (via Google Play)

---

## Data Storage

• All food data and personal information stored locally on your device (Local database)
• Energy balance synchronized with Firebase Firestore for cross-device persistence
• Compact food history (text-only nutrition data) is backed up to Firebase during daily Energy claims to enable cross-device restoration
• Small thumbnail images (~40-80 KB) of food photos may be uploaded to Firebase Storage after AI analysis for backup purposes
• Full-resolution food photos remain on your device only and are never uploaded
• You can delete all local data anytime (Profile → Clear Data)

---

## Cloud Backup & Data Sync

When you claim your daily Energy, MiRO automatically syncs a compact backup of your food history:

### What is synced:

• Food entry text data: food name, calories, macronutrients, micronutrients, meal type, timestamp
• Custom meals (My Meals): recipe name, ingredients, nutrition data
• Small thumbnail images (~40-80 KB) with nutrition metadata after AI food analysis
• Health profile: gender, age, weight, height, target weight, activity level
• Nutrition goals: calorie goal, macro targets, meal budgets, cuisine preference, TDEE
• AR Scale data: detected object labels, bounding box coordinates (px), image dimensions, pixel-per-cm calibration ratio

### What is NOT synced:

• Full-resolution food photos (stay on your device only)
• Your name or avatar

### How it works:

• Syncing happens automatically when you claim daily Energy — no separate action required
• Data is identified by an anonymous hashed device ID (not linked to your identity)
• You can restore your food history on a new device using a Recovery Key
• Recovery Keys are viewable in Profile → Account and can be regenerated at any time

### Purpose:

• Protect your food history in case of device loss or upgrade
• Enable seamless transition to a new device
• Improve AI accuracy through aggregated, anonymized nutrition data

### Anonymized AI Training Data

We may use **anonymized** food images and associated metadata (nutrition labels, detected object bounding boxes, calibration data) to improve AI food recognition models or license to third-party AI/ML companies. This data is:

• Fully anonymized — no device ID, personal identity, or location data is included
• Stripped of EXIF metadata and any identifying information
• Aggregated at population level — individual users cannot be identified
• Used solely for improving food recognition technology

You may opt out of AI training data usage by contacting support@tnbgrp.com.

---

## Data Transmission to Third Parties

### In-App Purchase

• Purchase data → Processed via Google Play Billing
• Payment information is handled by Google, not by us
• We only store Product ID and Purchase Token to verify purchases

### Firebase Services

• Device ID → Used to manage Energy balance and prevent fraudulent usage
• Cloud Functions → Process AI requests, manage Energy deduction, and handle data sync
• Firestore → Stores Energy balance, compact food history backups, and Recovery Key hashes
• Firebase Storage → Stores small food thumbnail images with nutrition metadata

### Firebase Analytics (Optional - Requires User Consent)

• App events → Screen views, feature usage, and user interactions
• Device information → Device model, OS version, screen resolution
• Aggregated statistics → Usage patterns to improve app functionality

### What we DO NOT collect:

• Full-resolution food photos (only small thumbnails ~40-80 KB)
• Personal health information (weight, height, goals)
• Personal identifiers (name, email, phone number)
• Location data

**Purpose:** Improve app performance, understand feature usage, and optimize user experience.

**Your Choice:** You can opt-in or opt-out of analytics at any time in Profile → Settings.

---

## Required Permissions

MiRO requests the following permissions:

• **Camera:** Take food photos for AI analysis
• **Photos/Gallery:** Select food photos from gallery
• **Internet:** Send photos to AI API and sync Energy balance
• **Health Data (optional):** Read active energy burned and write dietary nutrition data to Apple Health (iOS) or Google Health Connect (Android)

---

## Health Data Integration

When you enable Health Sync, MiRO integrates with Apple Health (iOS) or Google Health Connect (Android):

### What we READ (with your permission):

• **Active Energy Burned:** Used to display how many calories you have burned today through physical activity

### What we WRITE (with your permission):

• **Dietary Energy (calories, protein, carbs, fat):** When you log a meal in MiRO, the nutrition data is sent to your Health App

### Important:

• Health Sync is optional — you must explicitly enable it
• All health data stays on your device — it is never sent to our servers
• You can disable Health Sync at any time in Settings
• Disabling Health Sync does not delete previously synced data from your Health App
• We only access the specific data types listed above — no heart rate, sleep, weight, or other health metrics

---

## Security

• Energy transactions secured via Firebase with device authentication
• Local data stored in encrypted Local Database (Isar)
• Firebase Analytics used for app improvement (requires user consent)
• No advertising or third-party tracking SDKs
• Payment processing handled securely by Google Play Billing
• All data transmission encrypted via HTTPS

---

## User Rights

• Delete all local data anytime
• Uninstall the app to remove all local data
• Energy balance persists across app reinstalls (linked to your device)
• Request deletion of cloud-synced food history and thumbnails by contacting support
• Request Energy data deletion by contacting support

---

## Data Retention

• **Local food data:** Retained until you delete it or uninstall the app
• **Cloud-synced food history:** Retained for up to 90 days for restoration purposes; deleted upon request
• **Thumbnail images:** Retained until you request deletion
• **Energy balance:** Retained indefinitely (linked to your device)
• **Purchase records:** Retained as required by Google Play and tax regulations

---

## Children's Privacy

MiRO is not intended for children under 13 years of age. We do not knowingly collect personal information from children.

---

## Changes to This Policy

We may update this Privacy Policy from time to time. Changes will be communicated through app updates. Continued use of the app after changes constitutes acceptance of the updated policy.

---

## Data Collection Consent

### Analytics Opt-In/Opt-Out

You have full control over analytics data collection:

• Upon first app use, you'll be asked to consent to Firebase Analytics
• You can decline and still use all app features normally
• You can change your preference anytime in Profile → Settings → Analytics Data Collection
• Declining analytics does not affect any core functionality

### What Happens When You Opt-In

• App usage patterns are collected (anonymously)
• No food data, photos, or health information is collected
• Data is aggregated and cannot identify individual users
• Used solely to improve app performance and user experience

### What Happens When You Opt-Out

• No analytics data is collected
• All app features remain fully functional
• Energy system, AI analysis, and purchases work normally

---

## PDPA Compliance (Thailand Personal Data Protection Act)

### Your Rights

Under the Personal Data Protection Act (PDPA), you have the right to:

• **Access:** Request a copy of your data
• **Rectification:** Correct inaccurate data
• **Erasure:** Request deletion of your data
• **Portability:** Receive your data in a structured format
• **Objection:** Object to data processing
• **Withdraw Consent:** Revoke analytics consent at any time

### Data Categories

• **General Data:** Device ID, Energy balance, purchase history, app usage (if opted-in), compact food history backups, thumbnail images, health profile, nutrition goals
• **Sensitive Data:** Health-related information (weight, height, nutrition goals) — stored locally and synced as part of cloud backup (identified by anonymous device ID only)

### How to Exercise Your Rights

• **Delete local data:** Profile → Clear Data
• **Revoke analytics consent:** Profile → Settings → Analytics Data Collection (toggle off)
• **Request data deletion:** Contact us through Google Play Store

### Data Retention

• **Local data:** Until you delete it or uninstall the app
• **Cloud-synced data:** Food history backups retained for 90 days; thumbnails retained until deletion request
• **Energy balance:** Retained until you request deletion
• **Analytics data:** Retained according to Firebase's retention policy (opt-out anytime)

---

## Contact Us

If you have questions about this Privacy Policy, please contact us through Google Play Store.

---

**Effective Date:** February 18, 2026  
**Last Updated:** March 1, 2026
