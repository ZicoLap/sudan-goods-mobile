import { RegisterUserRequest } from './types';
import { RegistrationError } from '../utils/errors';

const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const MIN_PASSWORD_LENGTH = 8;
const MAX_NAME_LENGTH = 50;
const PHONE_REGEX = /^[\+]?[0-9\s\-\(\)]{8,20}$/;

/**
 * Validates all registration input fields
 * Throws RegistrationError with specific codes for client handling
 */
export function validateRegistrationInput(data: unknown): RegisterUserRequest {
  const errors: string[] = [];
  
  if (!data || typeof data !== 'object') {
    throw new RegistrationError('VALIDATION_ERROR', 'Request body must be an object');
  }

  const input = data as Partial<RegisterUserRequest>;

  // Email validation
  if (!input.email || !EMAIL_REGEX.test(input.email)) {
    errors.push('Valid email is required');
  }

  // Password validation
  if (!input.password || input.password.length < MIN_PASSWORD_LENGTH) {
    errors.push(`Password must be at least ${MIN_PASSWORD_LENGTH} characters`);
  }

  // Name validations
  if (!input.firstName || input.firstName.trim().length === 0) {
    errors.push('First name is required');
  } else if (input.firstName.length > MAX_NAME_LENGTH) {
    errors.push(`First name must be less than ${MAX_NAME_LENGTH} characters`);
  }

  if (!input.lastName || input.lastName.trim().length === 0) {
    errors.push('Last name is required');
  } else if (input.lastName.length > MAX_NAME_LENGTH) {
    errors.push(`Last name must be less than ${MAX_NAME_LENGTH} characters`);
  }

  // Phone validation
  if (!input.phoneNumber || !PHONE_REGEX.test(input.phoneNumber)) {
    errors.push('Valid phone number is required');
  }

  // Gender validation
  const validGenders = ['male', 'female'];
  if (!input.gender || !validGenders.includes(input.gender)) {
    errors.push('Gender must be male or female');
  }

  // Birthday validation
  if (!input.birthday) {
    errors.push('Birthday is required');
  } else {
    const birthDate = new Date(input.birthday);
    if (isNaN(birthDate.getTime())) {
      errors.push('Birthday must be a valid date');
    } else {
      const age = calculateAge(birthDate);
      if (age < 13) {
        errors.push('User must be at least 13 years old');
      }
    }
  }

  // Address validation
  if (!input.address || typeof input.address !== 'object') {
    errors.push('Address is required');
  } else {
    const addr = input.address;
    if (!addr.street?.trim()) errors.push('Street address and house number are required');
    if (!addr.city?.trim()) errors.push('City is required');
    if (!addr.country?.trim()) errors.push('Country is required');
    if (!addr.postalCode?.trim()) errors.push('Postal code is required');
  }

  if (errors.length > 0) {
    throw new RegistrationError('VALIDATION_ERROR', 'Input validation failed', errors);
  }

  return input as RegisterUserRequest;
}

function calculateAge(birthDate: Date): number {
  const today = new Date();
  let age = today.getFullYear() - birthDate.getFullYear();
  const monthDiff = today.getMonth() - birthDate.getMonth();
  if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
    age--;
  }
  return age;
}
