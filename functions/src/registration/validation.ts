import { RegisterUserRequest } from './types';
import { RegistrationError } from '../utils/errors';

const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const MIN_PASSWORD_LENGTH = 8;
const MAX_NAME_LENGTH = 50;
const MAX_EMAIL_LENGTH = 254;
const MAX_PHONE_LENGTH = 20;
const MAX_ADDRESS_FIELD_LENGTH = 100;
const MAX_POSTAL_CODE_LENGTH = 20;
const MAX_LABEL_LENGTH = 30;
const PHONE_REGEX = /^\+?[0-9]{8,20}$/;

/**
 * Validates all registration input fields and returns a sanitized copy.
 * Throws RegistrationError with specific codes for client handling.
 */
export function validateRegistrationInput(data: unknown): RegisterUserRequest {
  const errors: string[] = [];

  if (!data || typeof data !== 'object') {
    throw new RegistrationError('VALIDATION_ERROR', 'Request body must be an object');
  }

  const raw = data as Partial<RegisterUserRequest>;

  // Trim and sanitize scalar fields
  const email = typeof raw.email === 'string' ? raw.email.trim() : '';
  const password = typeof raw.password === 'string' ? raw.password : '';
  const firstName = typeof raw.firstName === 'string' ? raw.firstName.trim() : '';
  const lastName = typeof raw.lastName === 'string' ? raw.lastName.trim() : '';
  const phoneNumber = typeof raw.phoneNumber === 'string' ? raw.phoneNumber.trim() : '';

  // Email validation
  if (!email || !EMAIL_REGEX.test(email) || email.length > MAX_EMAIL_LENGTH) {
    errors.push('Valid email is required');
  }

  // Password validation
  if (!password || password.length < MIN_PASSWORD_LENGTH) {
    errors.push(`Password must be at least ${MIN_PASSWORD_LENGTH} characters`);
  }

  // Name validations
  if (!firstName) {
    errors.push('First name is required');
  } else if (firstName.length > MAX_NAME_LENGTH) {
    errors.push(`First name must be ${MAX_NAME_LENGTH} characters or less`);
  }

  if (!lastName) {
    errors.push('Last name is required');
  } else if (lastName.length > MAX_NAME_LENGTH) {
    errors.push(`Last name must be ${MAX_NAME_LENGTH} characters or less`);
  }

  // Phone validation (digits and optional leading + only)
  if (!phoneNumber || !PHONE_REGEX.test(phoneNumber) || phoneNumber.length > MAX_PHONE_LENGTH) {
    errors.push('Valid phone number is required');
  }

  // Gender validation
  const validGenders = ['male', 'female'];
  if (!raw.gender || !validGenders.includes(raw.gender)) {
    errors.push('Gender must be male or female');
  }

  // Birthday validation
  let birthday = raw.birthday;
  if (!birthday) {
    errors.push('Birthday is required');
  } else {
    const birthDate = new Date(birthday);
    if (isNaN(birthDate.getTime())) {
      errors.push('Birthday must be a valid date');
    } else {
      const age = calculateAge(birthDate);
      if (age < 13) {
        errors.push('User must be at least 13 years old');
      }
    }
  }

  // Address validation and sanitization
  const sanitizedAddress = {
    street: '',
    city: '',
    country: '',
    postalCode: '',
    label: '',
  };

  if (!raw.address || typeof raw.address !== 'object') {
    errors.push('Address is required');
  } else {
    const addr = raw.address as any;
    sanitizedAddress.street = typeof addr.street === 'string' ? addr.street.trim() : '';
    sanitizedAddress.city = typeof addr.city === 'string' ? addr.city.trim() : '';
    sanitizedAddress.country = typeof addr.country === 'string' ? addr.country.trim() : '';
    sanitizedAddress.postalCode = typeof addr.postalCode === 'string' ? addr.postalCode.trim() : '';
    sanitizedAddress.label = typeof addr.label === 'string' ? addr.label.trim() : '';

    if (!sanitizedAddress.street) errors.push('Street address and house number are required');
    else if (sanitizedAddress.street.length > MAX_ADDRESS_FIELD_LENGTH) {
      errors.push(`Street address must be ${MAX_ADDRESS_FIELD_LENGTH} characters or less`);
    }

    if (!sanitizedAddress.city) errors.push('City is required');
    else if (sanitizedAddress.city.length > MAX_ADDRESS_FIELD_LENGTH) {
      errors.push(`City must be ${MAX_ADDRESS_FIELD_LENGTH} characters or less`);
    }

    if (!sanitizedAddress.country) errors.push('Country is required');
    else if (sanitizedAddress.country.length > MAX_ADDRESS_FIELD_LENGTH) {
      errors.push(`Country must be ${MAX_ADDRESS_FIELD_LENGTH} characters or less`);
    }

    if (!sanitizedAddress.postalCode) errors.push('Postal code is required');
    else if (sanitizedAddress.postalCode.length > MAX_POSTAL_CODE_LENGTH) {
      errors.push(`Postal code must be ${MAX_POSTAL_CODE_LENGTH} characters or less`);
    }

    if (sanitizedAddress.label.length > MAX_LABEL_LENGTH) {
      errors.push(`Address label must be ${MAX_LABEL_LENGTH} characters or less`);
    }
  }

  if (errors.length > 0) {
    throw new RegistrationError('VALIDATION_ERROR', 'Input validation failed', errors);
  }

  return {
    email,
    password,
    firstName,
    lastName,
    phoneNumber,
    gender: raw.gender as 'male' | 'female',
    birthday: birthday as string,
    address: sanitizedAddress,
  };
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
