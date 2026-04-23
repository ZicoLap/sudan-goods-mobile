import * as admin from 'firebase-admin';
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
 * Delete user document (used for rollback)
 */
export async function deleteUserDocument(uid: string): Promise<void> {
  const db = admin.firestore();
  try {
    await db.collection('users').doc(uid).delete();
  } catch (error) {
    console.error(`Failed to delete user document ${uid} during rollback:`, error);
  }
}
