import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import cors from 'cors';
import OpenAI from 'openai';
import { ImageAnnotatorClient } from '@google-cloud/vision';
import Anthropic from '@anthropic-ai/sdk';
import { GoogleGenerativeAI } from '@google/generative-ai';

admin.initializeApp();
const db = admin.firestore();
const storage = admin.storage();
const auth = admin.auth();

function getOpenAIClient(provider?: string): OpenAI | null {
  const apiKey = process.env.AI_API_KEY || functions.config().ai?.api_key;
  if (!apiKey) return null;
  if (provider === 'openrouter') {
    return new OpenAI({
      apiKey,
      baseURL: 'https://openrouter.ai/api/v1',
    });
  }
  return new OpenAI({ apiKey });
}

function getAnthropicClient(): Anthropic | null {
  const apiKey = process.env.ANTHROPIC_API_KEY || functions.config().ai?.anthropic_api_key;
  if (!apiKey) return null;
  return new Anthropic({ apiKey });
}

function getGeminiClient(): GoogleGenerativeAI | null {
  const apiKey = process.env.GEMINI_API_KEY || functions.config().ai?.gemini_api_key;
  if (!apiKey) return null;
  return new GoogleGenerativeAI(apiKey);
}

function getProvider(): string {
  return process.env.AI_PROVIDER || functions.config().ai?.provider || 'openai';
}

function resolveModel(model: string | undefined, provider?: string): string {
  const mapped = model || 'default';
  const currentProvider = provider || getProvider();
  const providerDefaults: Record<string, string> = {
    openai: 'gpt-4o-mini',
    anthropic: 'claude-3-5-sonnet-20241022',
    gemini: 'gemini-1.5-flash',
    openrouter: 'openrouter/free',
  };
  const supported = new Set([
    'task-breakdown',
    'revision-draft',
    'flashcards',
    'quiz-draft',
    'subject-qna',
    'default',
  ]);
  if (!supported.has(mapped)) return mapped;
  return providerDefaults[currentProvider] || providerDefaults.openai;
}

export const aiProxy = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be signed in');
  }
  const userId = context.auth.uid;
  const consentDoc = await db.collection('ai_consents').doc(userId).get();
  const consent = consentDoc.data();
  if (!consent?.aiAssistance) {
    throw new functions.https.HttpsError('permission-denied', 'AI assistance consent required');
  }

  const { prompt, model, maxTokens, temperature } = data as { prompt?: string; model?: string; maxTokens?: number; temperature?: number };
  if (!prompt || typeof prompt !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing prompt');
  }

  const today = new Date();
  today.setHours(0, 0, 0, 0);
  const usageSnap = await db
    .collection('ai_requests')
    .where('userId', '==', userId)
    .where('createdAt', '>=', admin.firestore.Timestamp.fromDate(today))
    .get();

  if (usageSnap.size >= 50) {
    throw new functions.https.HttpsError('resource-exhausted', 'Daily AI quota exceeded. Try again tomorrow.');
  }

  const usageRef = await db.collection('ai_requests').add({
    userId,
    prompt: prompt.substring(0, 2000),
    model: model || 'default',
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  const provider = getProvider();
  const openai = getOpenAIClient(provider);
  const anthropic = getAnthropicClient();
  const gemini = getGeminiClient();
  const resolvedModel = resolveModel(model, provider);
  let output = '';

  try {
    if (provider === 'anthropic' && anthropic) {
      const message = await anthropic.messages.create({
        model: resolvedModel,
        max_tokens: maxTokens || 1024,
        temperature: temperature ?? 0.7,
        messages: [{ role: 'user', content: prompt }],
      });
      output = message.content[0]?.type === 'text' ? message.content[0].text : 'No response from AI provider.';
    } else if (provider === 'gemini' && gemini) {
      const geminiModel = gemini.getGenerativeModel({ model: resolvedModel });
      const result = await geminiModel.generateContent(prompt);
      output = result.response.text() || 'No response from AI provider.';
    } else if (openai) {
      const completion = await openai.chat.completions.create({
        model: resolvedModel,
        messages: [{ role: 'user', content: prompt }],
        max_tokens: maxTokens || 1024,
        temperature: temperature ?? 0.7,
      });
      output = completion.choices[0]?.message?.content?.trim() || 'No response from AI provider.';
    } else {
      output = 'AI provider not configured. Set AI_API_KEY in Firebase Functions config.';
    }
  } catch (error: any) {
    functions.logger.error('AI API error', error);
    output = `AI provider error: ${error.message}`;
  }

  if (!output || output.trim() === '') {
    throw new functions.https.HttpsError('invalid-argument', 'Empty AI response received');
  }
  if (output.length > 4000) {
    throw new functions.https.HttpsError('invalid-argument', 'AI response too long');
  }

  return {
    requestId: usageRef.id,
    notice: 'AI responses may contain errors. Verify with your textbook.',
    provider,
    model: model || 'default',
    output,
  };
});

export const ocrProcess = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be signed in');
  }
  const userId = context.auth.uid;
  const consentDoc = await db.collection('ai_consents').doc(userId).get();
  const consent = consentDoc.data();
  if (!consent?.ocrScanning) {
    throw new functions.https.HttpsError('permission-denied', 'OCR consent required');
  }
  const { filePath, language } = data as { filePath?: string; language?: string };
  if (!filePath) {
    throw new functions.https.HttpsError('invalid-argument', 'Missing filePath');
  }

  const staleCutoff = admin.firestore.Timestamp.fromDate(new Date(Date.now() - 60 * 60 * 1000)); // 1 hour

  const recentJobsSnap = await db.collection('ocr_jobs')
    .where('userId', '==', userId)
    .where('filePath', '==', filePath)
    .where('status', 'in', ['queued', 'processing'])
    .where('createdAt', '>=', staleCutoff)
    .limit(1)
    .get();

  if (!recentJobsSnap.empty) {
    const existing = recentJobsSnap.docs[0];
    return { jobId: existing.id, status: 'processing', notice: 'Duplicate job suppressed' };
  }

  const jobRef = await db.collection('ocr_jobs').add({
    userId,
    filePath,
    language: language || 'en',
    status: 'queued',
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  try {
    if (!filePath.startsWith('gs://')) {
      await jobRef.update({
        status: 'failed',
        error: 'filePath must be a Cloud Storage path (gs://bucket/path).',
        completedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      throw new functions.https.HttpsError('invalid-argument', 'Invalid filePath');
    }

    const visionClient = new ImageAnnotatorClient();
    const outputUri = `${filePath}.ocr_output_${Date.now()}/`;

    const [operation] = await visionClient.asyncBatchAnnotateFiles({
      requests: [
        {
          inputConfig: {
            gcsSource: { uri: filePath },
            mimeType: 'application/pdf',
          },
          features: [{ type: 'DOCUMENT_TEXT_DETECTION' }],
          outputConfig: {
            gcsDestination: { uri: outputUri },
          },
        },
      ],
    });

    await jobRef.update({
      status: 'processing',
      operationName: operation.name,
      outputUri,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return { jobId: jobRef.id, status: 'processing' };
  } catch (error: any) {
    functions.logger.error('OCR processing error', error);
    await jobRef.update({
      status: 'failed',
      error: error.message,
      completedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    throw new functions.https.HttpsError('internal', 'OCR processing failed', { jobId: jobRef.id });
  }
});



export const syncWorker = functions.pubsub.schedule('every 15 minutes').onRun(async (_context) => {
  const snapshot = await db.collection('sync_outbox').where('synced', '==', false).limit(100).get();
  for (const doc of snapshot.docs) {
    const data = doc.data();
    const entity = data.entity;
    const entityId = data.entityId;
    const operation = data.operation || 'set';
    const payload = data.data;

    let targetRef: admin.firestore.DocumentReference | undefined;
    if (entity) {
      targetRef = entityId ? db.collection(entity).doc(entityId) : db.collection(entity).doc();
    }

    try {
      if (!targetRef) {
        throw new Error('Missing entity');
      }

      if (operation === 'delete') {
        await targetRef.delete();
      } else {
        await targetRef.set(payload, { merge: true });
      }

      await doc.ref.update({
        synced: true,
        syncedAt: admin.firestore.FieldValue.serverTimestamp(),
        error: null,
      });
    } catch (error: any) {
      await doc.ref.update({
        error: error.message,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
  }
  return null;
});

export const pruneTombstones = functions.pubsub.schedule('every 24 hours').onRun(async (_context) => {
  const cutoff = admin.firestore.Timestamp.now().toDate();
  cutoff.setDate(cutoff.getDate() - 30);
  const snapshot = await db.collection('sync_tombstones').where('deletedAt', '<', cutoff).limit(500).get();
  const batch = db.batch();
  for (const doc of snapshot.docs) {
    batch.delete(doc.ref);
  }
  await batch.commit();
  return null;
});

