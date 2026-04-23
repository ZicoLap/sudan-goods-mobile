import * as admin from 'firebase-admin';
import { RegistrationError } from '../utils/errors';

/**
 * Check if a user already exists by email
 */
export async function checkExistingUser(email: string): Promise<boolean> {
  try {
    await admin.auth().getUserByEmail(email);
    return true;
  } catch (error: any) {
    if (error.code === 'auth/user-not-found') {
      return false;
    }
    throw new RegistrationError('INTERNAL_ERROR', 'Failed to check existing user');
  }
}

/**
 * Create a new Firebase Auth user
 */
export async function createAuthUser(
  email: string,
  password: string,
  displayName: string
): Promise<admin.auth.UserRecord> {
  try {
    return await admin.auth().createUser({
      email,
      password,
      displayName,
      emailVerified: false,
    });
  } catch (error: any) {
    if (error.code === 'auth/email-already-exists') {
      throw new RegistrationError('USER_EXISTS', 'An account with this email already exists');
    }
    if (error.code === 'auth/invalid-password') {
      throw new RegistrationError('VALIDATION_ERROR', 'Password is too weak', [error.message]);
    }
    throw new RegistrationError('AUTH_ERROR', `Failed to create user: ${error.message}`);
  }
}

/**
 * Delete a Firebase Auth user (used for rollback)
 */
export async function deleteAuthUser(uid: string): Promise<void> {
  try {
    await admin.auth().deleteUser(uid);
  } catch (error) {
    // Log but don't throw - we're already in error handling
    console.error(`Failed to delete auth user ${uid} during rollback:`, error);
  }
}
