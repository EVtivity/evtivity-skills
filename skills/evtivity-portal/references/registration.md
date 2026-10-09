Generated from https://www.evtivity.com/docs/portal/registration. Do not edit.

# Registration and Authentication

Create a driver account, verify your email, log in, reset your password, and set up multi-factor authentication.

## Overview

The EVtivity Portal requires a driver account for authenticated charging, session history, and payment management. This guide covers the full registration and login flow.

## Create an Account

1. Open the Portal and tap **Create One** on the login screen.
2. Fill in the registration form:
   - **First name** and **Last name**
   - **Email** (used for login and notifications)
   - **Password** (at least 12 characters, with an uppercase letter, a lowercase letter, and a number). The form lists these requirements under the field and checks them as you type.
   - **Phone (optional)** (used for SMS notifications and MFA)
3. Tap **Create Account**.

![Registration form](https://www.evtivity.com/screenshots/portal/register.png)

A phone number can be used for at most three new accounts in 24 hours.

If the operator has disabled portal self-registration (`portal.registrationEnabled = false`), the endpoint returns `PORTAL_REGISTRATION_DISABLED` and the form shows a "contact your operator to be invited" message. In that case, the operator creates your account and sends you an invitation. See [Accept an Invitation](#accept-an-invitation).

## Accept an Invitation

If your charging provider created your driver account, you receive an email invitation instead of signing up.

1. Open the invitation email and click the **Set Your Password** link.
2. Enter a password (at least 12 characters, with an uppercase letter, a lowercase letter, and a number) and confirm it.
3. Tap **Set Password**, then sign in with your email and new password.

![Accept an invitation](https://www.evtivity.com/screenshots/portal/activate.png)

Your existing charging sessions, RFID cards, payment methods, and invoices are already on the account. The link works once and expires after 7 days. If it has expired or was already used, ask your charging provider to send a new invitation. Setting the password also confirms your email address.

## Verify Your Email

After registration, the system sends a verification email to the address you provided.

1. Open the email from EVtivity.
2. Click the verification link.
3. You are redirected to the Portal login page with a confirmation message.

You cannot start authenticated charging sessions until your email is verified.

The verification link is sent by email only, never by SMS.

If the email does not arrive, tap **Resend verification email** on the **Verify Your Email** screen. Each request sends a new link and replaces the previous one. You can request one email a minute and five emails in 24 hours, the first one included. Over the limit, the screen explains the limit and keeps the button disabled until you can request again.

## Log In

1. Open the Portal.
2. Enter your **Email** and **Password**.
3. Tap **Sign In**.

![Login screen](https://www.evtivity.com/screenshots/portal/login.png)

If MFA is enabled on your account, you will be prompted for a verification code after entering your credentials. See the MFA section below.

## Forgot Password

1. On the login screen, tap **Forgot Password?**.
2. Enter your registered email address.
3. Tap **Send Reset Link**.
4. Open the email and click the reset link (valid for 1 hour, single use).
5. Enter a new password that meets the listed requirements and confirm it.
6. You are redirected to the login page.

Completing the reset revokes every existing session on your account, so any device you previously signed in on will be logged out and require re-authentication.

## Multi-Factor Authentication (MFA)

MFA adds a second verification step to your login. Three methods are available (the operator controls which methods are enabled system-wide).

### Email MFA

1. Go to **Account** and tap **Security**.
2. Under **Select method**, select **Email** and tap **Set Up**.
3. A 6-digit code is sent to your registered email.
4. Enter the code and tap **Verify**.

On your next login, a code is sent to your email after you enter your password.

### Authenticator App (TOTP)

1. Go to **Account** and tap **Security**.
2. Under **Select method**, select **Authenticator App** and tap **Set Up**.
3. Scan the QR code with an authenticator app (Google Authenticator, Authy, or similar).
4. Enter the 6-digit code from the app and tap **Verify**.

On your next login, open your authenticator app and enter the current code.

### SMS MFA

1. Go to **Account** and tap **Security**.
2. Under **Select method**, select **SMS** and tap **Set Up**.
3. A 6-digit code is sent to your registered phone number.
4. Enter the code and tap **Verify**.

On your next login, a code is sent via SMS after you enter your password.

### Disable MFA

1. Go to **Account** and tap **Security**.
2. Enter your password to confirm.
3. Tap **Disable MFA**.

To switch methods (for example from SMS to authenticator app), disable MFA first and then set up the new method. Attempting to set up while MFA is already enabled returns `MFA_ALREADY_ENABLED`, since overwriting the live secret without confirming the new one would otherwise lock you out at next login.

## Notes

- Verification codes expire after 5 minutes.
- TOTP codes use a 30-second rotation window with a 1-step tolerance.
- The operator can enable or disable each MFA method from the CSMS Settings page.
