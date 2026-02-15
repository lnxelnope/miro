# Bug Fixes & Feature Improvements - Implementation Guides

**Project:** MIRO Nutrition Tracking App  
**Last Updated:** February 15, 2026  
**Target Audience:** Junior Developers

---

## 📋 Overview

This folder contains **detailed, step-by-step implementation guides** for 12 bug fixes and feature improvements identified during user testing. Each guide is designed to be followed **without needing to ask questions** or make decisions.

**IMPORTANT:** This entire project must be in English only. All code, comments, UI text, documentation, and commit messages must be written in English.

---

## 🚀 How to Use These Guides

### For Junior Developers:

1. **Read the entire guide** before starting implementation
2. **Follow steps sequentially** - don't skip steps
3. **Copy code exactly** as shown - it's production-ready
4. **Test after each major step** using the provided checklist
5. **Check troubleshooting section** if you encounter issues
6. **Mark completion criteria** when done

### Estimated Total Time:
- **High Priority Tasks:** ~15-20 hours
- **Medium Priority Tasks:** ~8-12 hours  
- **Total Project:** ~25-30 hours

---

## 📊 Implementation Priority Order

### Phase 1: Critical Fixes (Do These First)
| # | Guide File | Task | Priority | Time | Difficulty |
|:-:|-----------|------|:--------:|:----:|:----------:|
| 02 | `02_REMOVE_BETA_FEEDBACK.md` | Remove Beta Feedback UI | 🔴 High | 30 min | Easy |
| 05 | `05_ENERGY_BADGE_FIX.md` | Fix Energy Badge Overflow | 🔴 High | 45 min | Easy |
| 06 | `06_TUTORIAL_PULL_TO_REFRESH_FIX.md` | Fix Tutorial Text Off-Screen | 🔴 High | 1 hour | Easy-Med |
| 12 | `12_HEALTH_DISCLAIMER.md` | Add Health Disclaimer | 🔴 **CRITICAL** | 2 hours | Easy |

**Phase 1 Total:** ~4-5 hours

---

### Phase 2: Core Features (Do These Second)
| # | Guide File | Task | Priority | Time | Difficulty |
|:-:|-----------|------|:--------:|:----:|:----------:|
| 01 | `01_CAMERA_CHAT_BUTTONS.md` | Add Camera Button & Redesign | 🔴 High | 3 hours | Medium |
| 03 | `03_IMAGE_ANALYSIS_PREVIEW.md` | Image Analysis Preview Screen | 🔴 High | 4 hours | Med-High |
| 04 | `04_AI_INGREDIENT_BREAKDOWN.md` | Fix AI Ingredient Breakdown | 🔴 High | 3 hours | Medium |

**Phase 2 Total:** ~10 hours

---

### Phase 3: Enhanced Features (Do These Third)
| # | Guide File | Task | Priority | Time | Difficulty |
|:-:|-----------|------|:--------:|:----:|:----------:|
| 07 | `07_CHAT_TUTORIAL.md` | Add Chat Tutorial Step | 🟡 Medium | 1 hour | Easy-Med |
| 08 | `08_FOOD_MOCKUP_TUTORIAL.md` | Food Mock-up Tutorial | 🟡 High | TBD | Medium |
| 10 | `10_TODAY_SUMMARY_DASHBOARD.md` | Full Nutrition Dashboard | 🟡 High | TBD | High |

**Phase 3 Total:** ~15+ hours

---

### Phase 4: Optional Enhancements (Do If Time Permits)
| # | Guide File | Task | Priority | Time | Difficulty |
|:-:|-----------|------|:--------:|:----:|:----------:|
| 09 | `09_MICRONUTRIENTS_SUMMARY.md` | Show Micronutrients in Summary | 🟢 Low-Med | TBD | Medium |
| 11 | `11_MICRONUTRIENT_CHARTS.md` | Collapsible Micro Charts | 🟡 Medium | TBD | Medium |

**Phase 4 Total:** ~8+ hours

---

## 📁 Guide File Structure

Each guide file contains:

1. **Overview** - What the task is about
2. **Files to Create/Modify** - Exact file paths
3. **Step-by-Step Implementation** - Detailed instructions with code
4. **Testing Checklist** - What to verify after implementation
5. **Troubleshooting** - Common issues and solutions
6. **Completion Criteria** - How to know you're done
7. **Estimated Time** - How long it should take

---

## ✅ Completed Tasks Tracker

Use this to track your progress:

- [ ] **02 - Remove Beta Feedback** (30 min)
- [ ] **05 - Energy Badge Fix** (45 min)
- [ ] **06 - Tutorial Pull-to-Refresh Fix** (1 hour)
- [ ] **12 - Health Disclaimer** (2 hours) ⚠️ **CRITICAL**
- [ ] **01 - Camera & Chat Buttons** (3 hours)
- [ ] **03 - Image Analysis Preview** (4 hours)
- [ ] **04 - AI Ingredient Breakdown** (3 hours)
- [ ] **07 - Chat Tutorial** (1 hour)
- [ ] **08 - Food Mock-up Tutorial** (TBD)
- [ ] **10 - Today Summary Dashboard** (TBD)
- [ ] **09 - Micronutrients Summary** (TBD)
- [ ] **11 - Micronutrient Charts** (TBD)

---

## 🛠️ Prerequisites

Before starting any implementation:

### Required Tools:
- Flutter SDK (>=3.2.0)
- Dart SDK
- Android Studio or VS Code
- Git
- Firebase CLI (for backend changes)

### Required Knowledge:
- Basic Flutter/Dart programming
- Widget composition
- State management (Riverpod)
- Navigation
- Basic Firebase Cloud Functions (for Task #04)

### Project Setup:
```bash
# Clone the project
git clone <repo-url>
cd miro

# Install dependencies
flutter pub get

# Run the app
flutter run
```

---

## 📝 Code Standards

### All code in this project MUST follow these rules:

1. **English Only** - All code, comments, variable names, UI text
2. **Naming Conventions:**
   - Files: `snake_case.dart`
   - Classes: `PascalCase`
   - Variables/methods: `camelCase`
   - Constants: `UPPER_SNAKE_CASE`
3. **Comments:** Write clear comments for complex logic
4. **Imports:** Sort imports (dart, flutter, packages, relative)
5. **Formatting:** Use `flutter format .` before committing

---

## 🐛 Testing Requirements

After each implementation:

1. ✅ **Build succeeds** - No compilation errors
2. ✅ **Run `flutter analyze`** - No warnings or errors
3. ✅ **Test on emulator** - Verify functionality
4. ✅ **Test on real device** - Check performance
5. ✅ **Check all checklist items** in the guide
6. ✅ **Test edge cases** mentioned in troubleshooting

---

## 🔄 Git Workflow

### After completing each task:

```bash
# Create a feature branch
git checkout -b feature/task-XX-description

# Stage your changes
git add .

# Commit with clear message (English only)
git commit -m "feat: Add camera button and redesign chat button

- Reduce button sizes from 64px to 48px
- Add camera screen with gallery picker
- Implement image capture functionality
- Resolves #01"

# Push to remote
git push origin feature/task-XX-description

# Create pull request
```

### Commit Message Format:
```
<type>: <short description>

<detailed description>
<what changed and why>

<issue reference>
```

**Types:** `feat`, `fix`, `refactor`, `docs`, `test`, `chore`

---

## 🆘 Getting Help

### If you get stuck:

1. **Read the Troubleshooting section** in the guide
2. **Check the Testing Checklist** - did you miss a step?
3. **Review the code** - compare with the guide's code samples
4. **Check Flutter docs** - https://flutter.dev/docs
5. **Ask senior developer** - provide context and what you tried

### What to include when asking for help:
- Task number and guide file name
- Step number where you're stuck
- Error messages (full text)
- What you tried
- Expected vs actual behavior

---

## 📚 Useful Resources

- **Flutter Documentation:** https://flutter.dev/docs
- **Dart Language Tour:** https://dart.dev/guides/language/language-tour
- **Riverpod Documentation:** https://riverpod.dev
- **Firebase Flutter:** https://firebase.google.com/docs/flutter/setup
- **Material Design:** https://material.io/design

---

## 🎯 Success Criteria

The implementation project is complete when:

- ✅ All Phase 1 (Critical) tasks completed
- ✅ All Phase 2 (Core Features) tasks completed
- ✅ App builds without errors
- ✅ All tests pass
- ✅ App runs smoothly on test devices
- ✅ Code follows project standards
- ✅ Changes committed to Git with proper messages
- ✅ Pull requests created and reviewed

---

## ⚠️ Important Notes

1. **Do NOT skip the Health Disclaimer task (#12)** - It's legally critical
2. **Test on multiple screen sizes** - especially small devices (< 360dp)
3. **Backend changes (Task #04) require Firebase deployment**
4. **Keep backups** - commit frequently to Git
5. **Don't modify code not mentioned in guides** - stay focused
6. **Ask before making design decisions** - follow guides exactly

---

## 📞 Contact

**Project Lead:** [Add contact info]  
**Technical Questions:** [Add contact info]  
**Code Review:** [Add contact info]

---

**Good luck with the implementation! Follow the guides carefully and test thoroughly.**
