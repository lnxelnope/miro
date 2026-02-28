# Privacy Policy — Miro Cal

**Effective Date:** February 18, 2026  
**Last Updated:** February 18, 2026

## 1. Information We Collect

Miro Cal stores the following data **locally on your device** (Offline-first):

- Food entries (name, calories, nutrients)
- Food photos (stored locally on your device)
- Health goals (kcal, macros)
- Basic personal information (name, gender, age, weight, height)
- Created meal recipes (My Meals)
- Saved ingredients (Ingredients)
- Energy balance (for AI features)
- Energy purchase history (via Google Play)

## 2. Data Transmission to Third Parties

### 2.1 In-App Purchase
- **Purchase data** → Processed via Google Play Billing
  - Payment information is handled by Google, not by us
  - We only store Product ID and Purchase Token to verify purchases

### 2.2 Firebase Services
- **Device ID** → Used to manage Energy balance and prevent fraudulent usage
- **Cloud Functions** → Process AI requests and manage Energy deduction
- **Firestore** → Stores Energy balance for cross-device synchronization

### 2.3 Firebase Analytics (Optional - Requires User Consent)
- **App events** → Screen views, feature usage, and user interactions
- **Device information** → Device model, OS version, screen resolution
- **Aggregated statistics** → Usage patterns to improve app functionality

**What we DO NOT collect:**
- Food entries, food photos, or nutrition data
- Personal health information (weight, height, goals)
- Personal identifiers (name, email, phone number)
- Location data

**Purpose:** Improve app performance, understand feature usage, and optimize user experience.

**Your Choice:** You can opt-in or opt-out of analytics at any time in Profile → Settings.

## 3. Data Storage

- All food data and personal information stored **locally on your device** (Local database)
- Energy balance synchronized with Firebase Firestore for cross-device persistence
- No cloud backup of food data (if you uninstall the app, local food data will be lost)
- You can delete all local data anytime (Profile → Clear Data)

## 4. Required Permissions

| Permission | Purpose |
|------------|---------|
| Camera | Take food photos for AI analysis |
| Photos/Gallery | Select food photos from gallery |
| Internet | Send photos to AI API and sync Energy balance |

## 5. User Rights

- Delete all local data anytime
- Uninstall the app to remove all local data
- Energy balance persists across app reinstalls (linked to your device)
- Request Energy data deletion by contacting support

## 6. Security

- Energy transactions secured via Firebase with device authentication
- Local data stored in encrypted Local Database (Isar)
- Firebase Analytics used for app improvement (requires user consent)
- No advertising or third-party tracking SDKs
- Payment processing handled securely by Google Play Billing
- All data transmission encrypted via HTTPS

## 7. Children's Privacy

Miro Cal is not intended for children under 13 years of age. We do not knowingly collect personal information from children.

## 8. Data Retention

- Local food data: Retained until you delete it or uninstall the app
- Energy balance: Retained indefinitely (linked to your device)
- Purchase records: Retained as required by Google Play and tax regulations

## 9. Changes to This Policy

We may update this Privacy Policy from time to time. Changes will be communicated through app updates. Continued use of the app after changes constitutes acceptance of the updated policy.

## 10. Data Collection Consent

### 10.1 Analytics Opt-In/Opt-Out
You have full control over analytics data collection:
- Upon first app use, you'll be asked to consent to Firebase Analytics
- You can decline and still use all app features normally
- You can change your preference anytime in **Profile → Settings → Analytics Data Collection**
- Declining analytics does not affect any core functionality

### 10.2 What Happens When You Opt-In
- App usage patterns are collected (anonymously)
- No food data, photos, or health information is collected
- Data is aggregated and cannot identify individual users
- Used solely to improve app performance and user experience

### 10.3 What Happens When You Opt-Out
- No analytics data is collected
- All app features remain fully functional
- Energy system, AI analysis, and purchases work normally

## 11. PDPA Compliance (Thailand Personal Data Protection Act)

### 11.1 Your Rights
Under the Personal Data Protection Act (PDPA), you have the right to:
- **Access:** Request a copy of your data
- **Rectification:** Correct inaccurate data
- **Erasure:** Request deletion of your data
- **Portability:** Receive your data in a structured format
- **Objection:** Object to data processing
- **Withdraw Consent:** Revoke analytics consent at any time

### 11.2 Data Categories
- **General Data:** Device ID, Energy balance, purchase history, app usage (if opted-in)
- **Sensitive Data:** Health-related information (weight, height, nutrition goals) stored **locally only** on your device

### 11.3 How to Exercise Your Rights
- **Delete local data:** Profile → Clear Data
- **Revoke analytics consent:** Profile → Settings → Analytics Data Collection (toggle off)
- **Request data deletion:** Contact us through Google Play Store

### 11.4 Data Retention
- Local data: Until you delete it or uninstall the app
- Energy balance: Retained until you request deletion
- Analytics data: Retained according to Firebase's retention policy (opt-out anytime)

## 12. Contact Us

If you have questions about this Privacy Policy, please contact us through **Google Play Store**.
