import {setGlobalOptions} from "firebase-functions";

// Cost control: max 10 concurrent instances per function
setGlobalOptions({ maxInstances: 10 });

// Initialize Firebase Admin (must be first)
import * as admin from 'firebase-admin';
admin.initializeApp();

// Export all functions
export { registerUser } from './registration';
export { createOrder, cancelOrder } from './orders';
export { createPaymentIntent } from './payments/createPaymentIntent';
export { stripeWebhook } from './payments/stripeWebhook';