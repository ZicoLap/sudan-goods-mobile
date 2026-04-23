import * as admin from 'firebase-admin';
import * as logger from 'firebase-functions/logger';
import { RegistrationError } from '../utils/errors';

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
