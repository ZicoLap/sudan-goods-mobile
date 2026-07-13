import * as nodemailer from 'nodemailer';
import * as logger from 'firebase-functions/logger';

const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.GMAIL_USER,
    pass: process.env.GMAIL_APP_PASSWORD,
  },
});

/**
 * Sends an email verification link to a newly registered user.
 */
export async function sendVerificationEmail(
  toEmail: string,
  firstName: string,
  verificationLink: string
): Promise<void> {
  const mailOptions = {
    from: `"Sudan Goods" <${process.env.GMAIL_USER}>`,
    to: toEmail,
    subject: 'Verify your Sudan Goods account',
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 560px; margin: 0 auto; padding: 32px 24px; color: #1a1a1a;">
        <h2 style="margin: 0 0 8px; font-size: 24px; color: #E85500;">Welcome to Sudan Goods, ${firstName}!</h2>
        <p style="margin: 0 0 24px; font-size: 15px; color: #555;">
          Thanks for registering. Please verify your email address to activate your account.
        </p>
        <a href="${verificationLink}"
           style="display: inline-block; padding: 14px 32px; background: linear-gradient(135deg, #F36805, #E85500);
                  color: #fff; text-decoration: none; border-radius: 10px; font-size: 15px; font-weight: 600;">
          Verify Email Address
        </a>
        <p style="margin: 24px 0 0; font-size: 13px; color: #999;">
          If you did not create an account, you can safely ignore this email.<br/>
          This link expires after 24 hours.
        </p>
      </div>
    `,
  };

  await transporter.sendMail(mailOptions);
  logger.info('Verification email sent', { to: toEmail });
}
