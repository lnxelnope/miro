# AR Scan Upgrade - Hybrid LiDAR + 1-Second Video Scanning

**Project:** Miro Food Calorie Scanner Enhancement  
**Status:** Planning Phase (Ready for Development)  
**Last Updated:** March 11, 2026

---

## 🎯 Project Overview

This project upgrades Miro's food scanning feature to use a **Hybrid AR Scan System** that:
- Uses **LiDAR precision mode** on iPhone Pro devices (±20% accuracy)
- Falls back to **ARKit/ARCore estimation** on standard devices (±35% accuracy)  
- Provides **parallax-based reconstruction** for legacy devices (±45% with warnings)

The "1-Second Scan" flow combines Local AI detection, AR visual feedback, and Gemini multimodal analysis into a seamless user experience.

---

## 📁 Documentation Structure

All planning documents are organized in this directory:

```
_project_manager/ar_upgrade_lidar_1secvideo/
│
├── README.md                    ← You are here (project overview)
├── INDEX.md                     ← Navigation guide for different roles
├── SUMMARY.md                   ← Executive summary & implementation roadmap
│
├── 01-ui-ux/ui-design-spec.md   ← Complete UI/UX design with code
├── 02-frame-management/frame-selection-strategy.md  ← Frame capture pipeline
├── 03-hybrid-depth/hybrid-depth-system.md           ← LiDAR + ARKit implementation
├── 04-gemini-integration/gemini-multimodal-analysis.md  ← API integration
├── 05-limitations/known-limitations.md               ← Accuracy challenges & fixes
└── 06-testing/testing-strategy.md                    ← Testing protocol
```

---

## 🚀 Quick Start Guide

### For Different Team Members

| Role | Read First | Then Continue With |
|------|------------|-------------------|
| **Product Manager** | `SUMMARY.md` → `INDEX.md` | Review all limitations in `05-limitations/` |
| **UI/UX Designer** | `SUMMARY.md` → `01-ui-ux/ui-design-spec.md` | Check testing requirements in `06-testing/` |
| **iOS Developer** | `SUMMARY.md` → `02-frame-management/frame-selection-strategy.md` → `03-hybrid-depth/hybrid-depth-system.md` | Implement tests from `06-testing/testing-strategy.md` |
| **Android Developer** | Same as iOS + focus on ARCore implementation in `03-hybrid-depth/` |
| **AI Engineer** | `SUMMARY.md` → `04-gemini-integration/gemini-multimodal-analysis.md` | Understand limitations from `05-limitations/` |
| **QA Engineer** | `SUMMARY.md` → `06-testing/testing-strategy.md` | Review all implementation docs for test cases |

### For Stakeholders & Decision Makers

Start with:
1. **SUMMARY.md** - Executive summary, key innovations, and success metrics
2. **INDEX.md** - Navigation guide to find relevant technical details
3. **Risk Assessment** section in each document before approving decisions

---

## 🌟 Key Features

### 1. "1-Second Scan" User Experience

**What Users Do:**
1. Tap **"สแกนด้วย AR"** button (instead of traditional camera)
2. Follow visual guide to rotate phone around food for exactly 1 second
3. See real-time bounding box feedback during scan
4. Get calorie estimate with confidence indicator and adjustment options

**Technical Implementation:**
- Capture 30 frames at 30fps for exactly 1 second
- Automatically select best 3 frames based on quality metrics
- Process locally first (bounding box), then send to Gemini API
- Return structured JSON result in <5 seconds

### 2. Adaptive Depth System

**Device-Aware Processing:**

```
User Device Detection → Smart Routing → Optimal Depth Method

iPhone Pro (LiDAR) ────→ LiDAR Mode → ±20% accuracy
Standard iOS/Android ──→ ARKit/ARCore → ±35% accuracy  
Legacy Devices ────────→ Parallax Only → ±45% (+warnings)
```

**Benefits:**
- Best possible accuracy on each device type
- Graceful degradation for older hardware
- Consistent user experience across all devices

### 3. AI Integration Architecture

**Local AI (Fast, On-Device):**
- ML Kit object detection and bounding box estimation
- Real-time visual feedback during scan
- Preprocessing to reduce token costs

**Cloud AI (Powerful, Gemini):**
- Multimodal analysis from 3 frames + depth metadata
- Food type identification with confidence scoring
- Volume calculation using parallax + depth data
- Calorie estimation from nutritional database matching

**Synergy:** Local processing enables real-time feedback; cloud provides sophisticated reasoning.

---

## 📊 Expected Performance

### Accuracy by Device Category

| Device Type | Method | Accuracy Target | Example Use Case |
|-------------|--------|-----------------|------------------|
| iPhone 12-15 Pro | LiDAR mesh analysis | ±20% error | Sandwich, apple, pasta bowl |
| Standard iOS/Android | ARKit/ARCore depth API | ±35% error | Most solid foods |
| Legacy Devices | Parallax from 3 frames | ±45% error (with warnings) | Basic estimation only |

### Accuracy by Food Category

| Food Type | Challenge | Expected Error | Mitigation Strategy |
|-----------|-----------|----------------|--------------------|
| Leafy Greens (salad) | Thin transparent leaves | ±40-60% | Show warning + adjustment slider |
| Clear Liquids | Refraction confuses sensors | ±30-50% | Suggest measuring cup alternative |
| Stacked Foods | Hidden layers not visible | ±20-30% undercount | Prompt for side view |
| Dehydrated Items | Air gaps inflate volume | ±15-25% overcount | Apply density correction factor |

### Performance Targets

| Metric | Target Value | Measurement Method |
|--------|--------------|-------------------|
| Total scan time (pre-API) | <3 seconds | Time from button press to result display |
| API call duration | <5000ms max | Including network latency |
| Token budget per scan | ~3,200 tokens | $0.0032 cost estimate |
| Crash-free sessions | >99.5% | Firebase Crashlytics data |

---

## 🗓️ Implementation Phases

### Phase 1: Core Framework (Weeks 1-3)

**Goal:** Basic scanning capability with frame capture and local AI detection

**Deliverables:**
- [ ] AR camera view with bounding box overlay
- [ ] Frame capture and selection logic (best 3 of 30)
- [ ] ML Kit food detection integration
- [ ] Simple cropping pipeline for API preparation

**Success Criteria:**
- Can capture 3 optimal frames in <1 second
- Object detection works on all supported devices
- Bounding boxes displayed in real-time during scan

### Phase 2: Depth System Integration (Weeks 4-6)

**Goal:** Implement hybrid depth extraction for different device types

**Deliverables:**
- [ ] LiDAR depth data extraction for iPhone Pro
- [ ] ARKit/ARCore fallback implementation
- [ ] Device detection and routing logic
- [ ] Metadata generation for API consumption

**Success Criteria:**
- LiDAR volume estimates within ±25% of actual weight (tested with calibration objects)
- Standard devices produce usable depth estimates
- Automatic device type detection works reliably

### Phase 3: Gemini Integration (Weeks 7-9)

**Goal:** Cloud AI analysis and result processing

**Deliverables:**
- [ ] Prompt engineering and testing for food analysis
- [ ] API integration with robust error handling
- [ ] JSON parsing and result validation
- [ ] Fallback strategies for low-confidence scans

**Success Criteria:**
- Food type identification accuracy >80% on test dataset
- Volume estimates within ±30% of actual (validated against scale)
- API calls complete in <5 seconds with 95th percentile

### Phase 4: UX Polish & Testing (Weeks 10-12)

**Goal:** Production-ready feature with comprehensive testing

**Deliverables:**
- [ ] Complete polished UI/UX flow from activation to result display
- [ ] Error handling and recovery guides for all edge cases
- [ ] Performance optimization across all target devices
- [ ] Comprehensive testing (unit, integration, UAT)

**Success Criteria:**
- User task completion rate >90% in usability tests
- Average scan time <3 seconds (including API call)
- User satisfaction score >4.0/5.0

---

## ⚠️ Known Limitations & Mitigations

### Food Types with Reduced Accuracy

| Category | Why It's Challenging | Error Range | Recommended Action |
|----------|---------------------|-------------|-------------------|
| **Leafy Greens** (salad) | Thin, transparent leaves; air gaps inflate volume | ±40-60% | Show warning + provide adjustment slider |
| **Clear Liquids** (water, broth) | Refraction through container walls confuses depth sensors | ±30-50% | Suggest pouring into marked measuring cup |
| **Stacked Foods** (pancake stack) | Top layer obscures lower layers from camera view | ±20-30% undercount | Prompt user to show side view for height estimation |
| **Dehydrated Items** (chips, crackers) | Air gaps between pieces inflate volume estimate | ±15-25% overcount | Apply density correction factor based on food type |

### Environmental Challenges

| Challenge | Impact | Detection Method | User Guidance |
|-----------|--------|------------------|---------------|
| **Poor Lighting** | Reduces depth accuracy to ±15mm minimum | Brightness analysis <60 | "เพิ่มแสงสว่างเพื่อผลลัพธ์ที่ดีขึ้น" (Add more light) |
| **Motion Blur** | Causes scanning artifacts on edges | Motion blur score >0.3 | "ถือให้มั่นคงขึ้น" (Hold steadier) |
| **Reflections** | Overexposed regions confuse depth sensors | Specular highlight detection | "เปลี่ยนมุมกล้องเพื่อลดการสะท้อน" (Change angle to reduce glare) |

### Scale Ambiguity Without Depth Data

**Problem:** On legacy devices without depth sensors, can't distinguish between small object close vs large object far.

**Solution:** Reference Object Mode (Phase 2 Enhancement)
- Guide user to place known-size object (plate, cup) next to food
- Use reference dimensions for scale calibration
- Significantly improves accuracy on non-LiDAR devices

---

## 🧪 Testing Strategy Overview

### Unit Tests

Test core algorithms:
- Frame selection algorithm (quality-based filtering)
- LiDAR volume calculation (sphere, cube, cylinder validation)
- Bounding box consensus logic
- Token budget management

**Coverage Target:** >80% for all core modules

### Integration Tests

Test across device matrix:
| Test Category | Devices to Test | Expected Outcome |
|--------------|-----------------|------------------|
| LiDAR Accuracy | iPhone 12-15 Pro series | Volume estimates ±20% of actual weight |
| ARKit Fallback | iPhone SE, XR, 11 | Volume estimates ±35% of actual |
| ARCore Fallback | Samsung S21/S22, Pixel 6/7 | Volume estimates ±40% of actual |

### User Acceptance Testing (UAT)

**Participant Criteria:**
- 20+ participants across device types
- Diverse food preferences represented
- Mix of tech proficiency levels

**Success Metrics:**
- Task completion rate >90%
- Average task time <20 seconds
- Confidence rating >3.5/5.0
- NPS score >40

---

## 🔧 Technical Stack

### iOS Implementation

| Component | Technology | Purpose |
|-----------|------------|---------|
| AR Session Management | ARKit (iOS 13+) | World tracking, depth estimation |
| LiDAR Processing | RealityKit | Mesh reconstruction on Pro devices |
| Object Detection | Google ML Kit | On-device food bounding box detection |
| Camera Control | AVFoundation | Frame capture at 30fps for 1 second |

### Android Implementation

| Component | Technology | Purpose |
|-----------|------------|---------|
| AR Session Management | ARCore (Android 8.0+) | World tracking, depth estimation |
| Depth API | ARCore Depth Library | Depth data extraction on supported devices |
| Object Detection | Google ML Kit | On-device food bounding box detection |
| Camera Control | CameraX | Frame capture at 30fps for 1 second |

### Cloud Integration

| Component | Technology | Purpose |
|-----------|------------|---------|
| AI Analysis | Gemini 2.0 Flash | Multimodal food analysis from images + depth data |
| API Client | google_generative_ai Flutter package | Secure API communication |
| Error Handling | Retry logic with exponential backoff | Robustness against network failures |

---

## 📈 Success Metrics & KPIs

### Technical Performance Targets

| Metric | Target Value | Measurement Method |
|--------|--------------|-------------------|
| Scan completion rate | >90% | Track scans started vs completed successfully |
| Average scan time | <3 seconds (pre-API) + <5s API call | End-to-end timing instrumentation |
| API success rate | >95% | Successful Gemini calls / total attempts |
| Crash-free sessions | >99.5% | Firebase Crashlytics error tracking |

### User Experience Targets

| Metric | Target Value | Measurement Method |
|--------|--------------|-------------------|
| Task completion time | <20 seconds (total) | Usability testing observation |
| First-time success rate | >80% | New user scan attempts without assistance |
| Result confidence rating | >3.5/5.0 | In-app survey post-scan |
| Manual adjustment usage | <40% of scans | Track slider adjustments after initial result |

### Business Impact Targets

| Metric | Target Value | Measurement Method |
|--------|--------------|-------------------|
| Feature adoption rate | >25% of active users | Daily scans / DAU (Daily Active Users) |
| Retention lift | +5% for feature users | Compare 30-day retention vs non-users |
| Support tickets related to accuracy | <2% of total scans | Tag support inquiries by category |

---

## 🚦 Getting Started Guide

### Step 1: Review Project Overview (All Team Members)

Start with these documents in order:
1. **README.md** - This file (current document) for high-level overview
2. **SUMMARY.md** - Executive summary, key innovations, implementation roadmap
3. **INDEX.md** - Navigation guide to find relevant technical details by role

### Step 2: Role-Specific Deep Dive

Choose your path based on team role:

**Product Manager / Designer:**
- Read `01-ui-ux/ui-design-spec.md` for complete UI/UX design with code examples
- Review `05-limitations/known-limitations.md` to understand accuracy constraints
- Focus on user guidance strategies and error state handling

**iOS Developer:**
- Study `02-frame-management/frame-selection-strategy.md` for frame capture & preprocessing pipeline
- Implement depth system from `03-hybrid-depth/hybrid-depth-system.md` (LiDAR mode)
- Write unit tests following patterns in `06-testing/testing-strategy.md`

**Android Developer:**
- Same as iOS + focus on ARCore implementation details in `03-hybrid-depth/`
- Ensure parity with iOS functionality across device types

**AI Engineer:**
- Deep dive into `04-gemini-integration/gemini-multimodal-analysis.md` for API integration
- Design prompt engineering strategy following examples provided
- Implement fallback mechanisms based on `05-limitations/known-limitations.md`

**QA / Test Engineer:**
- Review `06-testing/testing-strategy.md` for comprehensive testing protocol
- Understand system from other docs to create test cases
- Set up device matrix and calibration objects for integration tests

### Step 3: Technical Setup

1. **Clone repository** and navigate to project directory
2. **Install dependencies:** `flutter pub get`
3. **Set up API keys:** Configure Gemini API key in `.env` file
4. **Configure devices:** Prepare test device list from testing strategy document
5. **Review codebase patterns:** Check existing implementation conventions

### Step 4: Begin Phase 1 Development

Start with Week 1 tasks from Phase 1 checklist in `SUMMARY.md`:
- Initialize AR camera session with correct presets
- Implement frame buffer (memory-only, no disk write)
- Add basic bounding box overlay visualization
- Set up ML Kit integration for object detection

**Tip:** Use the code examples provided in each document as starting points.

---

## 📞 Communication & Coordination

### Weekly Sync Meeting

**When:** Every Monday, 10:00 AM  
**Duration:** 30 minutes max  
**Format:** Stand-up style progress updates + blocker discussion

**Agenda Template:**
```markdown
# AR Scan Upgrade - Weekly Sync [Date]

## Phase Progress Review
- Current phase: [Phase N]
- Last completed milestone: [Milestone Name]
- Next upcoming milestone: [Milestone Name]

## Blockers & Risks
- Any blockers preventing progress?
- New risks identified since last week?

## Upcoming Tests/Reviews Needed
- Device testing scheduled: [Date]
- Design review needed for: [Feature]
- API quota check required before: [Date]

## Decisions Required This Week
1. [Decision topic 1] - Deadline: [Date]
2. [Decision topic 2] - Deadline: [Date]

## Action Items from Last Week
- [Completed items list]
```

### Key Contacts by Topic

| Topic | Primary Contact | Backup Contact |
|-------|-----------------|----------------|
| UI/UX Design | [Designer Name TBD] | [PM Name TBD] |
| iOS Implementation | [iOS Dev Name TBD] | [Android Dev Name TBD] |
| Android Implementation | [Android Dev Name TBD] | [iOS Dev Name TBD] |
| AI/ML Integration | [AI Engineer Name TBD] | [Backend Lead Name TBD] |
| Testing & QA | [QA Lead Name TBD] | [Dev Lead Name TBD] |

---

## 🔗 External Resources

### Documentation References

- **Apple ARKit Documentation:** https://developer.apple.com/documentation/arkit
- **Google ML Kit:** https://developers.google.com/ml-kit
- **Gemini API Docs:** https://ai.google.dev/gemini-api/docs
- **IEEE Food Volume Estimation Paper (2023):** Available through university library

### Tools & Utilities

| Tool | Purpose | Setup Instructions |
|------|---------|-------------------|
| **Flutter** | Cross-platform development framework | Already configured in project |
| **Firebase** | Analytics and crash reporting | Configure in `firebase_options.dart` |
| **Gemini API** | Cloud AI analysis service | Get key from Google Cloud Console |
| **ML Kit** | On-device object detection | Integrated via Flutter packages |

---

## 📝 Version History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | March 11, 2026 | AI Research Agent | Initial comprehensive planning document set |

---

## ✅ Final Checklist for Project Kickoff

Before starting development, ensure:

- [ ] All team members have reviewed relevant documentation
- [ ] Weekly sync schedule established and calendar invites sent
- [ ] Development environment configured (API keys, device access)
- [ ] Device test matrix prepared (LiDAR + non-LiDAR devices available)
- [ ] Calibration objects ordered or 3D-printed for testing
- [ ] UAT participant recruitment plan created
- [ ] Success metrics dashboard set up in Firebase/Analytics tool

**If all items checked:** Project is ready to begin Phase 1 development!

---

## 🎓 Additional Reading

For deeper understanding of underlying technologies:

### AR & Depth Sensing
- **ARKit Fundamentals (Apple Developer Course)** - Recommended for iOS developers
- **ARCore Getting Started Guide** - Required reading for Android team
- **LiDAR Scanner Technical Overview** - Apple's whitepaper on LiDAR technology

### AI & Machine Learning
- **Google ML Kit Documentation** - For object detection implementation details
- **Gemini API Prompt Engineering Best Practices** - Essential for effective API usage

### Food Nutrition Databases
- **USDA FoodData Central** - Primary source for nutritional information
- **OpenFoodFacts API** - Alternative database with crowdsourced data

---

*This README provides project overview and quick start guidance. For detailed technical specifications, refer to individual phase documents in this directory.*
