import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as logger from 'firebase-functions/logger';
import { RegistrationError } from '../utils/errors';
import { OrderUserProfile } from '../orders/types';

export interface UserDocument {
  uid: string;
  email: string;
  firstName: string;
  lastName: string;
  role: 'customer';
  gender: string;
  birthday: Date;
  createdAt: admin.firestore.Timestamp;
  phoneNumber: string;
  addresses: Array<{
    street: string;
    city: string;
    country: string;
    postalCode: string;
    label?: string;
  }>;
}

/**
 * Create user document in Firestore
 * Returns true on success, throws on failure
 */
export async function createUserDocument(userData: UserDocument): Promise<void> {
  const db = admin.firestore();
  
  try {
    await db.collection('users').doc(userData.uid).set(userData);
  } catch (error: any) {
    throw new RegistrationError(
      'DATABASE_ERROR',
      `Failed to create user profile: ${error.message}`
    );
  }
}

/**
 * Delete user document (reserved for rollback if additional writes are added
 * after Firestore succeeds — not currently called since Firestore is the last
 * step and a failure there leaves nothing to clean up).
 */
export async function deleteUserDocument(uid: string): Promise<void> {
  const db = admin.firestore();
  try {
    await db.collection('users').doc(uid).delete();
  } catch (error) {
    logger.error('Failed to delete user document during rollback', { uid, error });
  }
}

/**
 * Fetches the user profile fields required for order creation.
 *
 * Fix #9: Accepts an optional addressIndex so the caller can select a specific
 * saved address. Defaults to index 0 if not provided.
 *
 * Throws HttpsError('failed-precondition') when:
 * - The user document does not exist.
 * - The user has no saved delivery addresses.
 * - The requested addressIndex is out of bounds.
 */
export async function fetchOrderUserProfile(
  uid: string,
  addressIndex = 0
): Promise<OrderUserProfile> {
  const db = admin.firestore();
  const snap = await db.collection('users').doc(uid).get();

  if (!snap.exists) {
    throw new functions.https.HttpsError(
      'failed-precondition',
      'User profile not found.'
    );
  }

  const data = snap.data()!;
  const addresses: UserDocument['addresses'] = data.addresses ?? [];

  if (addresses.length === 0) {
    throw new functions.https.HttpsError(
      'failed-precondition',
      'No delivery address found on your profile.'
    );
  }

  // Fix #9: Validate addressIndex bounds.
  if (addressIndex < 0 || addressIndex >= addresses.length) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      `Address index ${addressIndex} is out of range (you have ${addresses.length} address(es)).`
    );
  }

  const firstName: string = data.firstName ?? '';
  const lastName: string = data.lastName ?? '';

  return {
    name: `${firstName} ${lastName}`.trim(),
    phone: data.phoneNumber ?? '',
    address: addresses[addressIndex] as Record<string, unknown>,
  };
}
