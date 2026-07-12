/**
 * Registration request from client
 */
export interface RegisterUserRequest {
  email: string;
  password: string;
  firstName: string;
  lastName: string;
  phoneNumber: string;
  gender: 'male' | 'female';
  birthday: string; // ISO 8601 format: "1990-01-15"
  address: {
    street: string;
    city: string;
    country: string;
    postalCode: string;
    label?: string;
  };
}

/**
 * Successful registration response
 */
export interface RegisterUserResponse {
  success: true;
  uid: string;
  email: string;
  message: string;
}

/**
 * Error response structure
 */
export interface RegisterUserError {
  success: false;
  code: 'VALIDATION_ERROR' | 'USER_EXISTS' | 'AUTH_ERROR' | 'DATABASE_ERROR' | 'INTERNAL_ERROR';
  message: string;
  details?: string[];
}
