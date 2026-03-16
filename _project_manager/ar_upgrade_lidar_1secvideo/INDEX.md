# AR Scan Upgrade - Project Index

**File:** `INDEX.md`  
**Last Updated:** March 11, 2026

---

## Quick Start Guide

### For Different Roles

| Role | Read This First | Then Continue With |
|------|-----------------|-------------------|
| **Product Manager / Designer** | `SUMMARY.md` → `01-ui-ux/ui-design-spec.md` | Review limitations in `05-limitations/known-limitations.md` |
| **Mobile Developer (iOS)** | `SUMMARY.md` → `02-frame-management/frame-selection-strategy.md` → `03-hybrid-depth/hybrid-depth-system.md` | Test with `06-testing/testing-strategy.md` |
| **Mobile Developer (Android)** | `SUMMARY.md` → `02-frame-management/frame-selection-strategy.md` → `03-hybrid-depth/hybrid-depth-system.md` | Test with `06-testing/testing-strategy.md` |
| **AI/ML Engineer** | `SUMMARY.md` → `04-gemini-integration/gemini-multimodal-analysis.md` | Review limitations in `05-limitations/known-limitations.md` |
| **QA / Test Engineer** | `SUMMARY.md` → `06-testing/testing-strategy.md` | Understand system from other docs |

---

## Document Hierarchy

```
_project_manager/ar_upgrade_lidar_1secvideo/
│
├── INDEX.md                              ← You are here (this file)
├── SUMMARY.md                            ← Executive summary & implementation guide
│
├── 01-ui-ux/
│   └── ui-design-spec.md                 ← Complete UI/UX design with code examples
│       • Action button redesign
│       • User guidance system
│       • Real-time visual feedback
│       • Error states & recovery guides
│
├── 02-frame-management/
│   └── frame-selection-strategy.md       ← Frame capture & preprocessing pipeline
│       • Camera configuration specs
│       • Smart frame selection algorithm
│       • Preprocessing pipeline (ML Kit, cropping)
│       • File size optimization
│
├── 03-hybrid-depth/
│   └── hybrid-depth-system.md            ← LiDAR + ARKit/ARCore implementation
│       • Hardware detection & routing
│       • LiDAR mode implementation (iPhone Pro)
│       • ARKit/ARCore fallback implementation
│       • Parallax reconstruction (legacy devices)
│
├── 04-gemini-integration/
│   └── gemini-multimodal-analysis.md     ← API integration details
│       • Prompt engineering design
│       • Gemini analyzer service implementation
│       • Result parsing & validation
│       • Error handling & fallback strategies
│
├── 05-limitations/
│   └── known-limitations.md              ← Accuracy challenges & mitigations
│       • Food types with reduced accuracy (salad, liquids, etc.)
│       • Environmental challenges (lighting, reflections)
│       • Scale ambiguity solutions
│       • User expectation management
│
├── 06-testing/
│   └── testing-strategy.md               ← Comprehensive testing protocol
│       • Unit tests for core algorithms
│       • Integration test matrix by device type
│       • User acceptance testing (UAT) protocol
│       • Performance benchmarks
│       • CI/CD integration setup
│
└── SUMMARY.md                            ← Complete project overview
    • Key innovations summary
    • File structure guide
    • Implementation phases
    • Technical specifications
    • Device support matrix
    • Risk assessment
    • Success metrics & KPIs
```

---

## Core Concepts Overview

### 1. The "1-Second Scan" Flow

**User Experience:**
1. User taps **"สแกนด้วย AR"** button (instead of traditional "Take Photo")
2. Circular guide appears with rotation arrow instruction
3. User rotates phone slowly around food for exactly 1 second
4. Real-time bounding box shows detection progress
5. System automatically selects best 3 frames from 30 captured
6. Gemini AI analyzes frames + depth data to estimate calories
7. Result displayed with confidence indicator and adjustment options

**Technical Flow:**
```
Button Press → Camera Session Start (1s @ 30fps) → 
Frame Buffer Capture → Smart Selection (best 3 of 30) → 
Local ML Detection → Depth Extraction (LiDAR/ARKit/Parallax) → 
Gemini API Analysis → Result Display
```

### 2. Hybrid Depth System Architecture

**Adaptive to Available Hardware:**

| Device Category | Detection Method | Accuracy Target |
|-----------------|------------------|-----------------|
| iPhone Pro (12+) | LiDAR point cloud + mesh volume | ±20% |
| Standard iOS/Android | ARKit/ARCore depth API | ±35% |
| Legacy Devices | Parallax from 3 frames only | ±45% (+warnings) |

**Key Insight:** Same user experience, tiered accuracy based on hardware capability.

### 3. AI Integration Strategy

**Local AI (Fast, On-Device):**
- ML Kit for object detection & bounding box estimation
- Real-time visual feedback during scan
- Preprocessing before cloud API call

**Cloud AI (Powerful, Gemini):**
- Multimodal analysis combining 3 frames + depth metadata
- Food type identification from visual patterns
- Volume calculation using parallax + depth data
- Calorie estimation from nutritional database matching

**Synergy:** Local processing reduces token costs and enables real-time feedback; cloud provides sophisticated reasoning.

---

## Implementation Checklist by Phase

### Phase 1: Core Framework (Weeks 1-3)

#### Week 1: Camera Setup & Frame Capture
- [ ] Initialize AR camera session with correct presets
- [ ] Implement frame buffer (memory-only, no disk write)
- [ ] Add basic bounding box overlay visualization
- [ ] Set up ML Kit integration for object detection

**Deliverable:** Can capture frames and show basic bounding boxes in real-time.

#### Week 2: Frame Selection Algorithm
- [ ] Implement quality scoring (brightness, blur, coverage)
- [ ] Build frame selection logic (best 3 of captured)
- [ ] Add preprocessing pipeline (crop, compress, normalize)
- [ ] Write unit tests for selection algorithm

**Deliverable:** Can select optimal frames and prepare them for API.

#### Week 3: Basic UI Integration
- [ ] Design "Scan with AR" button animation
- [ ] Implement guiding circle & rotation arrow overlay
- [ ] Add progress indicator during scan
- [ ] Create basic result display card

**Deliverable:** Complete end-to-end scanning flow (without depth/Gemini).

---

### Phase 2: Depth System Integration (Weeks 4-6)

#### Week 4: Device Detection & Routing
- [ ] Implement device capability detector (LiDAR vs ARKit vs monocular)
- [ ] Build routing logic to select appropriate depth method
- [ ] Add LiDAR initialization for iPhone Pro devices
- [ ] Write hardware detection unit tests

**Deliverable:** System correctly identifies device type and selects depth method.

#### Week 5: LiDAR Implementation (iPhone Pro)
- [ ] Integrate ARKit mesh reconstruction for LiDAR
- [ ] Implement volume calculation from point cloud
- [ ] Add bounding box extraction from mesh
- [ ] Test with known-volume calibration objects

**Deliverable:** LiDAR mode produces accurate volume estimates on iPhone Pro.

#### Week 6: Fallback Depth Methods
- [ ] Implement ARKit depth API for standard iOS devices
- [ ] Implement ARCore depth API for Android devices  
- [ ] Build parallax reconstruction fallback (structure from motion)
- [ ] Test across multiple device types

**Deliverable:** All supported devices can perform scanning with appropriate accuracy.

---

### Phase 3: Gemini Integration (Weeks 7-9)

#### Week 7: Prompt Engineering & API Setup
- [ ] Design system prompt for food analysis task
- [ ] Build dynamic user prompt template builder
- [ ] Set up Gemini API client with proper error handling
- [ ] Implement JSON response parsing and validation

**Deliverable:** Can send scan data to Gemini and receive structured results.

#### Week 8: Result Processing & Confidence Display
- [ ] Build FoodScanResult model from JSON response
- [ ] Implement confidence scoring display in UI
- [ ] Add manual adjustment sliders for low-confidence scans
- [ ] Create error state handling (timeout, parse errors)

**Deliverable:** Users see results with clear confidence indicators and can adjust.

#### Week 9: Fallback Strategies & Optimization
- [ ] Implement retry logic for failed analyses
- [ ] Build nutrition database fallback when AI fails
- [ ] Optimize token usage (image compression strategies)
- [ ] Performance testing across network conditions

**Deliverable:** Robust system that handles errors gracefully and stays within budget.

---

### Phase 4: UX Polish & Testing (Weeks 10-12)

#### Week 10: Complete UI/UX Flow
- [ ] Refine all error state messages and guides
- [ ] Implement onboarding flow for new users
- [ ] Add confidence-based guidance variations
- [ ] Polish animations and transitions

**Deliverable:** Professional, polished user experience with clear feedback.

#### Week 11: Comprehensive Testing
- [ ] Execute unit test suite (all algorithms)
- [ ] Run integration tests across device matrix
- [ ] Conduct UAT with 20+ participants
- [ ] Profile performance on all target devices

**Deliverable:** All success criteria met; ready for beta launch.

#### Week 12: Launch Preparation
- [ ] Final security audit & dependency review
- [ ] Create release notes and user documentation
- [ ] Set up analytics tracking for key metrics
- [ ] Prepare support team with troubleshooting guides

**Deliverable:** Feature ready for production deployment.

---

## Key Decision Points

### Decision 1: Hybrid vs LiDAR-Only

**Choice Made:** Implement hybrid approach (LiDAR + fallback) instead of LiDAR-only.

**Rationale:**
- Broader market coverage (supports all devices, not just Pro models)
- Graceful degradation path for legacy hardware
- Future-proofs investment as more users upgrade to Pro

**Owner:** Product Manager / Technical Lead  
**Status:** ✅ Approved - documented in SUMMARY.md

### Decision 2: Frame Count & Duration

**Choice Made:** Exactly 1 second at 30fps → select best 3 frames.

**Rationale:**
- User expectation of "quick scan" (not long video)
- Optimal balance between data richness and token costs
- Matches research findings for sufficient rotation capture

**Owner:** Product Manager / UX Designer  
**Status:** ✅ Approved - documented in SUMMARY.md

### Decision 3: Local vs Cloud AI Split

**Choice Made:** Use both ML Kit (local) + Gemini (cloud).

**Rationale:**
- Real-time feedback requires on-device processing
- Complex analysis benefits from cloud LLM capabilities
- Cost optimization through intelligent preprocessing

**Owner:** AI Engineer / Backend Developer  
**Status:** ✅ Approved - documented in 04-gemini-integration/gemini-multimodal-analysis.md

### Decision 4: Manual Adjustment Tools

**Choice Made:** Always provide manual adjustment sliders.

**Rationale:**
- Acknowledges inherent estimation uncertainty
- Increases user trust and perceived control
- Provides valuable feedback data for model improvement

**Owner:** UX Designer / Product Manager  
**Status:** ✅ Approved - documented in 01-ui-ux/ui-design-spec.md

---

## Communication & Coordination

### Weekly Sync Agenda Template

```markdown
# AR Scan Upgrade - Weekly Sync

## Date: [YYYY-MM-DD]

### Phase Progress Review
- Current phase: [Phase N]
- Last completed milestone: [Milestone Name]
- Next upcoming milestone: [Milestone Name]

### Blockers & Risks
- [ ] Any blockers preventing progress?
- [ ] New risks identified since last week?

### Upcoming Tests/Reviews Needed
- [ ] Device testing scheduled: [Date]
- [ ] Design review needed for: [Feature]
- [ ] API quota check required before: [Date]

### Decisions Required This Week
1. [Decision topic 1] - Deadline: [Date]
2. [Decision topic 2] - Deadline: [Date]

### Action Items from Last Week
- [x] Completed item 1 (Owner: Name)
- [ ] In-progress item 2 (Owner: Name, ETA: Date)
```

### Key Contacts by Topic

| Topic | Primary Contact | Backup Contact |
|-------|-----------------|----------------|
| UI/UX Design | [Designer Name] | [PM Name] |
| iOS Implementation | [iOS Dev Name] | [Android Dev Name] |
| Android Implementation | [Android Dev Name] | [iOS Dev Name] |
| AI/ML Integration | [AI Engineer Name] | [Backend Lead Name] |
| Testing & QA | [QA Lead Name] | [Dev Lead Name] |

---

## Resource Links

### Documentation References

| Document | Location | Purpose |
|----------|----------|---------|
| Project Summary | `SUMMARY.md` | High-level overview and implementation guide |
| UI/UX Specification | `01-ui-ux/ui-design-spec.md` | Complete design with code examples |
| Frame Management | `02-frame-management/frame-selection-strategy.md` | Capture & preprocessing pipeline |
| Depth Systems | `03-hybrid-depth/hybrid-depth-system.md` | LiDAR + ARKit/ARCore implementation |
| Gemini Integration | `04-gemini-integration/gemini-multimodal-analysis.md` | AI API integration details |
| Limitations & Risks | `05-limitations/known-limitations.md` | Accuracy challenges and mitigations |
| Testing Strategy | `06-testing/testing-strategy.md` | Comprehensive testing protocol |

### External References

- **Apple ARKit Documentation:** https://developer.apple.com/documentation/arkit
- **Google ML Kit:** https://developers.google.com/ml-kit
- **Gemini API Docs:** https://ai.google.dev/gemini-api/docs
- **IEEE Food Volume Paper (2023):** Available through university library

### Testing Resources

| Resource | Location | Access Instructions |
|----------|----------|---------------------|
| Calibration Objects | `assets/calibration/` | Use 3D-printed sphere, cube, cylinder |
| Test Food Samples | `assets/test_samples/` | See food category mapping in testing docs |
| Device Loaner Pool | [Device Lab Contact] | Request access via internal IT portal |

---

## Glossary & Terminology

### Technical Terms

| Term | Definition | Context |
|------|------------|---------|
| **LiDAR** | Light Detection and Ranging - time-of-flight depth sensor in iPhone Pro models | Hardware capability |
| **ARKit/ARCore Depth API** | iOS/Android frameworks for estimating scene depth using stereo vision | Fallback method |
| **Parallax Analysis** | 3D reconstruction technique using multiple camera viewpoints to estimate depth | Legacy device support |
| **Bounding Box** | Rectangular region containing detected object in image coordinates | Object detection output |
| **Token Budget** | Maximum tokens sent to Gemini API per request to control costs | Cost management |

### UI/UX Terms

| Term | Definition | Context |
|------|------------|---------|
| **"Scan with AR"** | Action button that initiates 1-second rotation capture | Primary interaction |
| **Guiding Circle** | Semi-transparent ring overlay showing optimal food positioning area | Visual guidance |
| **Confidence Indicator** | Badge showing reliability of calorie estimate (color-coded) | Result display |
| **Adjustment Slider** | Manual control for fine-tuning estimated calories | User refinement tool |

---

## Version History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | March 11, 2026 | AI Research Agent | Initial comprehensive planning document set |

---

## Final Notes

### For New Team Members

1. **Start with SUMMARY.md** to understand the big picture and key innovations
2. **Read documents relevant to your role** using the role-based navigation above
3. **Join weekly sync meetings** to stay aligned on progress and blockers
4. **Reference this INDEX.md** whenever you need to locate specific documentation

### For Stakeholders

1. **Review SUMMARY.md** for high-level technical overview and success metrics
2. **Focus on risk assessment section** in each document before approving decisions
3. **Monitor KPIs dashboard** once feature is live (links provided in Phase 4 deliverables)

### For Developers

1. **Read all relevant implementation docs** before starting work
2. **Run unit tests frequently** to catch issues early
3. **Use device testing matrix** from `06-testing/testing-strategy.md` for validation
4. **Follow token budget guidelines** in `04-gemini-integration/gemini-multimodal-analysis.md`

---

*This index document provides navigation and coordination support for the AR Scan Upgrade project. For detailed technical specifications, refer to individual phase documents.*
