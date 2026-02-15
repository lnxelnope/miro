# 🚨 Troubleshooting: 429 Error (Resource Exhausted)

## ❓ What is Error 429?

Error 429 means **"Too Many Requests"** or **"Resource Exhausted"**. It happens when:

1. **Rate Limit Exceeded** - Too many API calls in a short time
2. **Quota Exhausted** - Daily/monthly API usage limit reached
3. **Concurrent Requests** - Too many simultaneous requests
4. **Temporary API Issues** - Gemini API experiencing high load

---

## ✅ Solutions Implemented

### 1. **Backend Retry Logic** (Cloud Functions)

The backend now automatically retries failed requests:

```typescript
// Exponential backoff retry
- Attempt 1: Immediate
- Attempt 2: Wait 2 seconds, retry
- Attempt 3: Wait 4 seconds, retry
- Attempt 4: Wait 8 seconds, retry (last attempt)
```

**Benefits:**
- Handles temporary rate limits automatically
- User doesn't see error for transient issues
- No Energy deducted if all retries fail

### 2. **Client-Side Error Handling**

User-friendly error messages:

```
❌ Before:
"Exception: Gemini API error: {"error":{"code":429,...}}"

✅ After:
"AI service is temporarily busy. Please try again in a few seconds.
Your Energy has not been deducted."
```

---

## 📊 Gemini API Quotas (Free Tier)

| Limit Type | Free Tier | Paid Tier |
|------------|-----------|-----------|
| Requests Per Minute (RPM) | 15 | 360+ |
| Requests Per Day (RPD) | 1,500 | 10,000+ |
| Tokens Per Minute (TPM) | 1M | 4M+ |

**Current Usage:** Check at [Google AI Studio](https://aistudio.google.com/)

---

## 🔍 Debugging 429 Errors

### Check Backend Logs:

```bash
firebase functions:log --only analyzeFood
```

Look for:
```
⚠️ Rate limit hit (attempt 1/4)
⏳ Waiting 2000ms before retry...
```

### Check Client Logs:

```
I/flutter: [GeminiService] Calling backend: image
I/flutter: ❌ Gemini Backend Error: Exception: AI service is temporarily busy...
```

---

## 🛠️ If 429 Errors Persist

### Option 1: **Upgrade to Paid Tier**

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Navigate to **Billing**
3. Enable billing for your project
4. Gemini API quotas automatically increase

**Recommended for production apps**

### Option 2: **Request Quota Increase**

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Navigate to **IAM & Admin** → **Quotas**
3. Search for "Generative Language API"
4. Request quota increase

### Option 3: **Implement Client-Side Rate Limiting**

Add delays between requests:

```dart
// In your app
DateTime? _lastApiCall;

Future<void> analyzeFood() async {
  // Enforce 4-second delay between requests
  if (_lastApiCall != null) {
    final elapsed = DateTime.now().difference(_lastApiCall!);
    if (elapsed.inSeconds < 4) {
      await Future.delayed(Duration(seconds: 4 - elapsed.inSeconds));
    }
  }
  
  // Make API call
  await GeminiService.analyzeFoodImage(...);
  _lastApiCall = DateTime.now();
}
```

### Option 4: **Monitor Usage Patterns**

Check if specific features cause spikes:

```bash
# View analytics
firebase functions:log --only analyzeFood | grep "429"
```

Common causes:
- Users rapidly scanning multiple items
- Bulk analysis features
- Testing without delays

---

## 📈 Best Practices

### 1. **User Feedback**
- Show loading indicator during analysis
- Display retry count if applicable
- Inform user if service is busy

### 2. **Graceful Degradation**
- Don't block entire app on 429
- Allow manual retry
- Cache previous results

### 3. **Rate Limiting**
- Limit analysis frequency per user
- Add cooldown between requests
- Queue requests instead of parallel calls

### 4. **Monitoring**
Set up alerts for:
- High 429 error rate
- Approaching quota limits
- Unusual usage spikes

---

## 🎯 Current Configuration

### Backend (Cloud Functions):
```typescript
// analyzeFood.ts
const maxRetries = 3;
const backoffMs = [2000, 4000, 8000]; // 2s, 4s, 8s
```

### Client (Flutter):
```dart
// gemini_service.dart
// Automatic handling of 429 errors
// User sees: "Please try again in a few seconds"
```

---

## ✅ Testing Retry Logic

### Simulate 429 Error:

1. **Backend Test:**
   ```bash
   # Rapidly call Cloud Function
   for i in {1..20}; do curl -X POST [FUNCTION_URL]; done
   ```

2. **App Test:**
   - Scan 10+ foods rapidly
   - Watch logs for retry messages

### Expected Behavior:

```
Attempt 1: ⚠️ Rate limit hit
⏳ Waiting 2000ms...
Attempt 2: ⚠️ Rate limit hit
⏳ Waiting 4000ms...
Attempt 3: ✅ Success!
```

---

## 📞 Support Contacts

- **Gemini API Issues:** [Google AI Support](https://ai.google.dev/support)
- **Firebase Issues:** [Firebase Support](https://firebase.google.com/support)
- **Billing Questions:** [Google Cloud Billing](https://cloud.google.com/billing/docs/how-to/get-support)

---

## 📝 Changelog

**2026-02-13:**
- ✅ Added retry logic with exponential backoff (3 retries)
- ✅ Improved client-side error messages
- ✅ Added "Energy not deducted" notification
- ✅ Documented quota limits and solutions

---

## 🚀 Next Steps

1. **Monitor:** Watch for 429 errors in production
2. **Optimize:** Adjust retry delays based on real-world data
3. **Scale:** Consider paid tier when user base grows
4. **Alert:** Set up Firebase Performance Monitoring

---

**Last Updated:** 2026-02-13  
**Status:** Retry logic deployed ✅  
**Recommended Action:** Monitor usage in production
