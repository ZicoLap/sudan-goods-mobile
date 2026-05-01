/**
 * Custom error class for registration failures
 */
export class RegistrationError extends Error {
  constructor(
    public code: string,
    message: string,
    public details?: string[]
  ) {
    super(message);
    this.name = 'RegistrationError';
  }
}

/**
 * Custom error class for order creation failures.
 * Carries a machine-readable code for structured logging.
 */
export class OrderError extends Error {
  constructor(
    public code: string,
    message: string
  ) {
    super(message);
    this.name = 'OrderError';
  }
}
