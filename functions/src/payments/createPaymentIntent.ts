import * as functions from 'firebase-functions';
import * as logger from 'firebase-functions/logger';
import Stripe = require('stripe');

function getStripe(): Stripe.Stripe {
  const key = process.env.STRIPE_SECRET_KEY;
  if (!key) {
    throw new functions.https.HttpsError('internal', 'Stripe is not configured.');
  }
  return new Stripe(key, { apiVersion: '2026-04-22.dahlia' });
}

/**
 * MINIMAL: Creates a fixed €5 PaymentIntent for testing.
 * No cart, no product validation — just auth + Stripe.
 */
export const createPaymentIntent = functions.https.onCall(async (request) => {
  if (!request.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'You must be signed in to pay.');
  }

  const uid = request.auth.uid;
  logger.info('createPaymentIntent (minimal)', { uid });

  try {
    const stripe = getStripe();
    const paymentIntent = await stripe.paymentIntents.create({
      amount: 500, // €5.00 in cents
      currency: 'eur',
      automatic_payment_methods: { enabled: true },
      metadata: { userId: uid },
    });

    logger.info('PaymentIntent created', { paymentIntentId: paymentIntent.id, uid });
    return { clientSecret: paymentIntent.client_secret! };
  } catch (error) {
    logger.error('createPaymentIntent failed', {
      error: error instanceof Error ? error.message : 'Unknown',
    });
    throw new functions.https.HttpsError('internal', 'Failed to create payment.');
  }
});
