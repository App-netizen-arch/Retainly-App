# Firebase Backend Setup

## Prerequisites
- Firebase project created at https://console.firebase.google.com
- Project ID: `retainly-app-b4f4a`
- Flutter SDK 3.24.0+
- Node.js 18+ (for Cloud Functions)
- Firebase CLI installed (`npm install -g firebase-tools`)

## 1. Replace Placeholder Values
Edit `lib/firebase_options.dart` with real Firebase project values:
- `apiKey`
- `appId`
- `messagingSenderId`
- `projectId`

Edit `android/app/google-services.json` with the real config downloaded from Firebase Console.

## 2. Enable Firebase Services
In Firebase Console, enable:
- **Cloud Firestore** (start in test mode, then apply `firestore.rules`)
- **Cloud Storage** (apply `storage.rules`)
- **Cloud Functions** (Blaze plan required for Cloud Functions)
- **Firebase Authentication** (Email/Password, Google)

## 3. Deploy Security Rules
```bash
firebase login
firebase use retainly-app-b4f4a
firebase deploy --only firestore:rules,storage:rules
```

## 4. Deploy Cloud Functions
```bash
cd functions
npm install
npm run build
cd ..
firebase deploy --only functions
```

## 5. AI Provider Configuration
The Cloud Functions `aiProxy` reads the AI provider API key from:
- `functions.config().ai.api_key` (legacy) or
- Firebase environment config / Secret Manager

Set the API key:
```bash
firebase functions:config:set ai.provider="openai" ai.api_key="YOUR_OPENAI_API_KEY"
firebase deploy --only functions
```

Supported providers:
- OpenAI (default): requires `OPENAI_API_KEY`
- To add Anthropic or Google Gemini, extend `functions/src/index.ts` `aiProxy` handler.

### 5.1 Current Configuration
- **Default provider**: OpenAI (`gpt-4o-mini`)
- **Daily quota**: 50 requests per user per day
- **Consent required**: Users must enable "AI Assistance" in Settings
- **Cost warning**: Users must accept the AI cost warning before first use

### 5.2 Setting the AI API Key
#### Option A: Firebase Functions Config (legacy)
```bash
firebase functions:config:set ai.provider="openai" ai.api_key="sk-..."
firebase deploy --only functions
```

#### Option B: Secret Manager (recommended for production)
1. In Google Cloud Console, go to **Secret Manager**
2. Create a secret named `openai-api-key`
3. Grant the Cloud Functions service account access to the secret
4. Update `functions/src/index.ts` to read from Secret Manager:
```typescript
import { SecretManagerServiceClient } from '@google-cloud/secret-manager';

const client = new SecretManagerServiceClient();
async function getOpenAIKey() {
  const [version] = await client.accessSecretVersion({ name: 'projects/retainly-app-b4f4a/secrets/openai-api-key/versions/latest' });
  return version.payload!.data!.toString();
}
```

### 5.3 Supported AI Tasks
The `aiProxy` function maps task types to AI models:
- `task-breakdown` → `gpt-4o-mini`
- `revision-draft` → `gpt-4o-mini`
- `flashcards` → `gpt-4o-mini`
- `quiz-draft` → `gpt-4o-mini`

### 5.4 Adding a New Provider (e.g., Anthropic Claude)
1. Add the provider SDK to `functions/package.json` (e.g., `@anthropic-ai/sdk`)
2. Extend `aiProxy` in `functions/src/index.ts`:
```typescript
if (provider === 'anthropic') {
  const anthropic = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });
  const message = await anthropic.messages.create({...});
  return { text: message.content[0].text };
}
```
3. Set the environment variable:
```bash
firebase functions:config:set ai.provider="anthropic" anthropic.api_key="sk-ant-..."
```
4. Update the Flutter client `lib/services/ai_service.dart` if new parameters are needed.

### 5.5 Quota Enforcement
Quota is enforced at two levels:
1. **Client-side**: `SharedPreferences` tracks daily usage (50 requests/day). The counter resets at midnight local time.
2. **Server-side**: `ai_requests` Firestore collection tracks requests per user per day. The Cloud Function rejects requests exceeding the daily limit.

### 5.6 Fallback Behavior
If the AI provider is unavailable:
- The app shows an error toast
- The user can retry later
- Local-only planning (manual task creation) continues to work

## 6. Firestore Collections
The app uses these collections (created by rules/structure on first write):
- `users/{userId}`
- `sync_outbox/{outboxId}`
- `sync_tombstones/{tombstoneId}`
- `sync_conflicts/{conflictId}`
- `ai_consents/{userId}`
- `ai_requests/{requestId}`
- `ocr_jobs/{jobId}`
- `user_profiles/{profileId}`
- `quizzes/{quizId}`
- `quiz_attempts/{attemptId}`

## 7. Storage Paths
- `users/{userId}/...` - user uploads
- `ai-uploads/{userId}/...` - AI processing inputs
- `ocr-output/{userId}/...` - OCR results

## 8. Firestore Indexes
Create `firestore.indexes.json` with composite indexes for:
- `ai_requests` queries by `userId` + `createdAt`
- `sync_outbox` queries by `userId` + `status`

Deploy indexes:
```bash
firebase deploy --only firestore:indexes
```

## 9. Testing Rules
Run Firestore and Storage rules tests before deploying:
```bash
cd functions
npm install
npm run test:rules
```
