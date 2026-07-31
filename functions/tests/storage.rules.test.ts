import { initializeTestEnvironment, assertFails, assertSucceeds, RulesTestEnvironment } from '@firebase/rules-unit-testing';
import { readFileSync } from 'fs';

let testEnv: RulesTestEnvironment;
let storage: ReturnType<RulesTestEnvironment['unauthenticatedContext']>;

beforeAll(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: 'retainly-app-b4f4a',
    storage: {
      rules: readFileSync('../../storage.rules', 'utf-8'),
    },
  });
  storage = testEnv.unauthenticatedContext();
});

afterAll(async () => {
  await testEnv.cleanup();
});

describe('Storage Security Rules', () => {
  test('unauthenticated users cannot upload to users folder', async () => {
    const ref = storage.storage().ref('users/user_1/file.txt');
    await assertFails(new Promise((_, reject) => { ref.putString('hello', 'raw').catch(reject); }));
  });

  test('authenticated owner can upload to own users folder', async () => {
    const authedStorage = testEnv.authenticatedContext('user_1', { email: 'user1@test.com' });
    const ref = authedStorage.storage().ref('users/user_1/file.txt');
    await assertSucceeds(new Promise((resolve, reject) => { ref.putString('hello', 'raw').then(resolve).catch(reject); }));
  });

  test('authenticated user cannot upload to another users folder', async () => {
    const authedStorage = testEnv.authenticatedContext('user_2', { email: 'user2@test.com' });
    const ref = authedStorage.storage().ref('users/user_1/file.txt');
    await assertFails(new Promise((_, reject) => { ref.putString('hello', 'raw').catch(reject); }));
  });

  test('owner can delete own file', async () => {
    const authedStorage = testEnv.authenticatedContext('user_1', { email: 'user1@test.com' });
    const ref = authedStorage.storage().ref('users/user_1/file.txt');
    await assertSucceeds(new Promise((resolve, reject) => { ref.putString('hello', 'raw').then(resolve).catch(reject); }));
    await assertSucceeds(ref.delete());
  });

  test('owner can upload to ai-uploads folder', async () => {
    const authedStorage = testEnv.authenticatedContext('user_1', { email: 'user1@test.com' });
    const ref = authedStorage.storage().ref('ai-uploads/user_1/image.png');
    await assertSucceeds(new Promise((resolve, reject) => { ref.putString('hello', 'raw').then(resolve).catch(reject); }));
  });

  test('owner can upload to ocr-output folder', async () => {
    const authedStorage = testEnv.authenticatedContext('user_1', { email: 'user1@test.com' });
    const ref = authedStorage.storage().ref('ocr-output/user_1/result.txt');
    await assertSucceeds(new Promise((resolve, reject) => { ref.putString('hello', 'raw').then(resolve).catch(reject); }));
  });

  test('authenticated users cannot write to study-groups files', async () => {
    const authedStorage = testEnv.authenticatedContext('user_1', { email: 'user1@test.com' });
    const ref = authedStorage.storage().ref('study-groups/group_1/notes.pdf');
    await assertFails(new Promise((resolve, reject) => { ref.putString('hello', 'raw').then(resolve).catch(reject); }));
  });
});
