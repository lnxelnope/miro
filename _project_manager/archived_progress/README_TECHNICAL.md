# Miro: The Hybrid Life Assistant (Technical Design)

## 🎯 Core Philosophy
- **User Experience:** Maximum Laziness (Automated Logging).
- **Architecture:** **Local Filter -> Cloud Intelligence.**
- **Privacy:** Personal images/texts are processed locally first. Only specific queries (e.g., stock price, food calories) hit the internet.

## 🛠️ Tech Stack
| Component | Technology | Role |
|-----------|------------|------|
| **Framework** | Flutter | Cross-platform UI & Logic |
| **Local Database** | Isar Database | Store transactions & portfolio snapshot |
| **Vision (Filter)** | Google ML Kit | **Local:** Filter junk images, extract text/QR from bills |
| **Brain (NLU)** | MediaPipe LLM (Gemma 3 - 4B) | **Local:** Parse chat to Intent (Buy/Sell/Eat) & JSON |
| **Financial Data** | Yahoo Finance / SEC API | **Online:** Fetch real-time asset prices (Ported from `rebalancer`) |
| **Nutrition Data** | Gemini 2.5 Flash API | **Online:** Fetch accurate macros for food items |

## 📱 Data Flow (The "Hybrid" Pipeline)

### 1. The Scanner (Local Filter)
- **Action:** Scan Gallery.
- **ML Kit:** 
    - Trash/Selfie -> Ignore.
    - Slip/Bill -> Extract Text -> Local NLU parses Amount/Date.
    - Food Image -> Tag as "Food" -> Send "Food Name" to Cloud for Macros.

### 2. The Brain (Local -> Online)
- **Chat:** "ซื้อ K-WORLDX 10,000 บาท"
- **Local Gemma 3:** Understands Intent -> `{"action": "buy", "symbol": "K-WORLDX", "amount": 10000}`.
- **Online Service:** Takes `symbol`, fetches `Current NAV`, calculates `Units` received.
- **Result:** Save Transaction & Update Portfolio.

### 3. The Portfolio (Investment Engine)
- **Logic:** Ported from `rebalancer` project.
- **Features:**
    - Real-time Net Worth calculation.
    - Asset Allocation tracking (Health, Wealth, Productivity dashboard).

## 📂 Folder Structure

```
lib/
├── core/
│   ├── ai/
│   │   ├── local_brain.dart       # Gemma 3 (MediaPipe)
│   │   └── cloud_brain.dart       # Gemini Flash (Nutrition)
│   ├── services/
│   │   ├── finance_service.dart   # Yahoo/SEC API (from Rebalancer)
│   │   └── scanner_service.dart   # ML Kit
│   └── database/
├── features/
│   ├── timeline/
│   ├── portfolio/                 # Wealth Dashboard
│   └── chat/
└── models/
```

## 🚀 Phase 1 Milestones
1.  [ ] Setup Flutter Project.
2.  [ ] Port `price_engine.py` logic to Dart (Finance Service).
3.  [ ] Implement ML Kit Scanner.
4.  [ ] Integrate Gemma 3.
