const { initializeTestEnvironment, assertFails, assertSucceeds, clearFirestoreData } = require('@firebase/rules-unit-testing');
const fs = require('fs');
const path = require('path');

/** @type {import('@firebase/rules-unit-testing').RulesTestEnvironment} */
let testEnv;

const PROJECT_ID = 'sudan-goods-follow-tests';
const RULES_PATH = path.join(__dirname, 'firestore.rules');

beforeAll(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: {
      rules: fs.readFileSync(RULES_PATH, 'utf8'),
    },
  });
});

afterAll(async () => {
  await testEnv.cleanup();
});

beforeEach(async () => {
  await clearFirestoreData({ projectId: PROJECT_ID });
});

function authedDb(uid) {
  return testEnv.authenticatedContext(uid).firestore();
}

function adminDb() {
  return testEnv.unauthenticatedContext().firestore();
}

describe('Follow rules', () => {
  test('cannot read/write someone else\'s following', async () => {
    const uidA = 'userA';
    const uidB = 'userB';

    // Seed a store document as active + approved
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().doc('stores/store1').set({ isActive: true, isApproved: true });
      await ctx.firestore().doc(`users/${uidA}/following/store1`).set({
        storeId: 'store1', storeName: 'S1', storeLogoUrl: null, storeIsActive: true, followedAt: new Date(),
      });
    });

    const dbB = authedDb(uidB);
    await assertFails(dbB.doc(`users/${uidA}/following/store1`).get());
  });

  test('can follow active & approved store', async () => {
    const uid = 'u1';
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().doc('stores/s1').set({ isActive: true, isApproved: true });
    });

    const db = authedDb(uid);
    await assertSucceeds(
      db.doc(`users/${uid}/following/s1`).set({
        storeId: 's1', storeName: 'S1', storeLogoUrl: null, storeIsActive: true, followedAt: new Date(),
      })
    );

    await assertSucceeds(db.doc(`users/${uid}/following/s1`).get());
  });

  test('cannot follow inactive or unapproved store', async () => {
    const uid = 'u2';
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().doc('stores/inactive').set({ isActive: false, isApproved: true });
      await ctx.firestore().doc('stores/unapproved').set({ isActive: true, isApproved: false });
    });

    const db = authedDb(uid);

    await assertFails(
      db.doc(`users/${uid}/following/inactive`).set({
        storeId: 'inactive', storeName: 'S', storeLogoUrl: null, storeIsActive: false, followedAt: new Date(),
      })
    );

    await assertFails(
      db.doc(`users/${uid}/following/unapproved`).set({
        storeId: 'unapproved', storeName: 'S', storeLogoUrl: null, storeIsActive: true, followedAt: new Date(),
      })
    );
  });

  test('can unfollow (delete) own doc', async () => {
    const uid = 'u3';
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().doc('stores/s1').set({ isActive: true, isApproved: true });
      await ctx.firestore().doc(`users/${uid}/following/s1`).set({
        storeId: 's1', storeName: 'S1', storeLogoUrl: null, storeIsActive: true, followedAt: new Date(),
      });
    });

    const db = authedDb(uid);
    await assertSucceeds(db.doc(`users/${uid}/following/s1`).delete());
  });

  test('clients cannot write mirror collection stores/{id}/followers', async () => {
    const uid = 'u4';
    const db = authedDb(uid);

    await assertFails(
      db.doc(`stores/s1/followers/${uid}`).set({ userId: uid, followedAt: new Date() })
    );
  });
});
