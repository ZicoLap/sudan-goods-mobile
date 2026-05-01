import * as functions from 'firebase-functions';
import * as logger from 'firebase-functions/logger';
import * as admin from 'firebase-admin';
import Stripe = require('stripe');

const db = admin.firestore();

type StripeInstance = Stripe.Stripe;

function getStripe(): StripeInstance {
  const key = process.env.STRIPE_SECRET_KEY;
  if (!key) throw new Error('STRIPE_SECRET_KEY not configured');
  return new Stripe(key, { apiVersion: '2026-04-22.dahlia' });
}

function getWebhookSecret(): string {
  const secret = process.env.STRIPE_WEBHOOK_SECRET;
  if (!secret) throw new Error('STRIPE_WEBHOOK_SECRET not configured');
  return secret;
}

/**
 * MINIMAL: Verifies Stripe signature and writes a record to stripeEvents.
 * No order creation — just confirms the webhook pipeline works end-to-end.
 */
export const stripeWebhook = functions.https.onRequest(async (req, res) => {
  const sig = req.headers['stripe-signature'];
  if (!sig) {
    res.status(400).send('Missing stripe-signature header');
    return;
  }

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  let event: any;
  try {
    const stripe = getStripe();
    event = stripe.webhooks.constructEvent(
      (req as any).rawBody,
      sig,
      getWebhookSecret()
    ) as any;
  } catch (err) {
    logger.warn('Webhook signature verification failed', {
      error: err instanceof Error ? err.message : 'Unknown',
    });
    res.status(400).send('Webhook signature verification failed');
    return;
  }

  logger.info('Stripe webhook received', { type: event.type, id: event.id });

  if (event.type === 'payment_intent.succeeded') {
    const pi = event.data.object;
    await db.collection('stripeEvents').doc(event.id).set({
      type: event.type,
      paymentIntentId: pi.id,
      amount: pi.amount,
      currency: pi.currency,
      userId: pi.metadata?.userId ?? null,
      receivedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    logger.info('payment_intent.succeeded recorded', { paymentIntentId: pi.id });
  } else if (event.type === 'payment_intent.payment_failed') {
    const pi = event.data.object;
    logger.info('payment_intent.payment_failed', {
      paymentIntentId: pi.id,
      error: pi.last_payment_error?.message,
    });
  } else {
    logger.info('Unhandled event type', { type: event.type });
  }

  res.status(200).send({ received: true });
});
