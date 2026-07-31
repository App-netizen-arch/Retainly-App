import { initializeTestEnvironment, assertFails, assertSucceeds, RulesTestEnvironment } from '@firebase/rules-unit-testing';
import { readFileSync } from 'fs';

let testEnv: RulesTestEnvironment;
let db: ReturnType<RulesTestEnvironment['unauthenticatedContext']>;

beforeAll(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: 'retainly-app-b4f4a',
    firestore: {
      rules: readFileSync('../../firestore.rules', 'utf-8'),
    },
  });
  db = testEnv.unauthenticatedContext();
});

afterAll(async () => {
  await testEnv.cleanup();
});

beforeEach(async () => {
  await testEnv.clearFirestore();
});

afterEach(async () => {
  // no-op
});

describe('Firestore Security Rules', () => {
  test('unauthenticated users cannot read user profiles', async () => {
    const ref = db.firestore().collection('users').doc('user_1');
    await assertFails(ref.get());
  });

  test('authenticated owner can read own user profile', async () => {
    const authedDb = testEnv.authenticatedContext('user_1', { email: 'user1@test.com' });
    const ref = authedDb.firestore().collection('users').doc('user_1');
    await assertSucceeds(ref.get());
  });

  test('authenticated user cannot read another user profile', async () => {
    const authedDb = testEnv.authenticatedContext('user_2', { email: 'user2@test.com' });
    const ref = authedDb.firestore().collection('users').doc('user_1');
    await assertFails(ref.get());
  });

  test('authenticated owner can write own user profile', async () => {
    const authedDb = testEnv.authenticatedContext('user_1', { email: 'user1@test.com' });
    const ref = authedDb.firestore().collection('users').doc('user_1');
    await assertSucceeds(ref.set({ name: 'Student One' }));
  });

  test('unauthenticated users cannot create sync outbox', async () => {
    const ref = db.firestore().collection('sync_outbox').doc();
    await assertFails(ref.set({ userId: 'user_1', payload: {} }));
  });

  test('authenticated user can create sync outbox with matching userId', async () => {
    const authedDb = testEnv.authenticatedContext('user_1', { email: 'user1@test.com' });
    const ref = authedDb.firestore().collection('sync_outbox').doc();
    await assertSucceeds(ref.set({ userId: 'user_1', payload: {} }));
  });

  test('authenticated user cannot create sync outbox with mismatched userId', async () => {
    const authedDb = testEnv.authenticatedContext('user_1', { email: 'user1@test.com' });
    const ref = authedDb.firestore().collection('sync_outbox').doc();
    await assertFails(ref.set({ userId: 'user_2', payload: {} }));
  });

  test('ai_consents are owner-only', async () => {
    const authedDb = testEnv.authenticatedContext('user_1', { email: 'user1@test.com' });
    const ref = authedDb.firestore().collection('ai_consents').doc('user_1');
    await assertSucceeds(ref.set({ aiConsent: true }));
    const otherDb = testEnv.authenticatedContext('user_2', { email: 'user2@test.com' });
    await assertFails(otherDb.firestore().collection('ai_consents').doc('user_1').get());
  });
