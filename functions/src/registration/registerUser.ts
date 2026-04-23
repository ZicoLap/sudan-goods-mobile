import * as functions from 'firebase-functions';
import * as logger from 'firebase-functions/logger';
import * as admin from 'firebase-admin';
import { validateRegistrationInput } from './validation';
import { createAuthUser, checkExistingUser, deleteAuthUser } from '../services/authService';
import { createUserDocument } from '../services/userService';
import { RegistrationError } from '../utils/errors';
import { RegisterUserResponse, RegisterUserError } from './types';

/**
 * Cloud Callable Function: Register a new user
 * 
 * Security: No authentication required (this IS the registration)
 * Rate limiting: Applied by Firebase automatically (1000 calls per 100 seconds per user IP)
 */
export const registerUser = functions.https.onCall(async (request) => {
  const data = request.data;
  const requestId = `req_${Date.now()}_${Math.random().toString(36).substring(2, 8)}`;
  logger.info('Registration attempt', { requestId });

  try {
    // 1. Validate input
    const validatedData = validateRegistrationInput(data);

    // 2. Check for existing user by email
    const exists = await checkExistingUser(validatedData.email);
    if (exists) {
      throw new RegistrationError('USER_EXISTS', 'An account with this email already exists');
    }

    // 3. Create Firebase Auth user
    const displayName = `${validatedData.firstName} ${validatedData.lastName}`;
    const userRecord = await createAuthUser(
      validatedData.email,
      validatedData.password,
      displayName
    );

    // 4. Prepare Firestore document
    const userDoc = {
      uid: userRecord.uid,
      email: validatedData.email,
      firstName: validatedData.firstName,
      lastName: validatedData.lastName,
      role: 'customer' as const,
      gender: validatedData.gender,
      birthday: new Date(validatedData.birthday),
      createdAt: admin.firestore.Timestamp.now(),
      phoneNumber: validatedData.phoneNumber,
      addresses: [validatedData.address],
    };

    // 5. Create Firestore document (with rollback on failure)
    try {
      await createUserDocument(userDoc);
    } catch (firestoreError) {
      // CRITICAL: Rollback Auth user if Firestore fails
      logger.error('Firestore write failed, rolling back auth user', {
        requestId,
        uid: userRecord.uid,
        error: firestoreError,
      });
      await deleteAuthUser(userRecord.uid);
      throw firestoreError;
    }

    logger.info('User registered successfully', {
      requestId,
      uid: userRecord.uid,
      email: validatedData.email,
    });

    // 6. Return success response
    const response: RegisterUserResponse = {
      success: true,
      uid: userRecord.uid,
      email: validatedData.email,
      message: 'Registration successful. Please check your email to verify your account.',
    };

    return response;

  } catch (error) {
    // Log the error with context
    logger.error('Registration failed', {
      requestId,
      error: error instanceof Error ? error.message : 'Unknown error',
      code: error instanceof RegistrationError ? error.code : 'INTERNAL_ERROR',
    });

    // Return structured error response
    if (error instanceof RegistrationError) {
      const errorResponse: RegisterUserError = {
        success: false,
        code: error.code as any,
        message: error.message,
        details: error.details,
      };
      throw new functions.https.HttpsError(
        mapErrorCode(error.code),
        error.message,
        errorResponse
      );
    }

    // Unexpected error
    const internalError: RegisterUserError = {
      success: false,
      code: 'INTERNAL_ERROR',
      message: 'An unexpected error occurred. Please try again later.',
    };
    throw new functions.https.HttpsError('internal', internalError.message, internalError);
  }
});

/**
 * Map custom error codes to Firebase HttpsError codes
 */
function mapErrorCode(code: string): functions.https.FunctionsErrorCode {
  const mapping: Record<string, functions.https.FunctionsErrorCode> = {
    'VALIDATION_ERROR': 'invalid-argument',
    'USER_EXISTS': 'already-exists',
    'AUTH_ERROR': 'internal',
    'DATABASE_ERROR': 'unavailable',
    'INTERNAL_ERROR': 'internal',
  };
  return mapping[code] || 'internal';
}
