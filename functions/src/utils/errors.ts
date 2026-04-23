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
