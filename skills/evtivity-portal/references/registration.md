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
   - **Password**. By default it needs at least 12 characters, an uppercase letter, a lowercase letter, and a number. Your charging provider can change these rules. The form lists the rules in effect under the field and checks them as you type.
   - **Phone (optional)** (used for SMS notifications and MFA)
3. Tap **Create Account**.

![Registration form](https://www.evtivity.com/screenshots/portal/register.png)

The portal then asks you to check your inbox. Open the verification link, then sign in. If the email address already has an account, the portal shows the same message and the email tells you that someone tried to register with your address, with links to sign in and to reset your password. Nothing on the existing account changes.

A phone number can be used for at most three new accounts in 24 hours.

If the operator has disabled portal self-registration (`portal.registrationEnabled = false`), the endpoint returns `PORTAL_REGISTRATION_DISABLED` and the form shows a "contact your operator to be invited" message. In that case, the operator creates your account and sends you an invitation. See [Accept an Invitation](#accept-an-invitation).

## Accept an Invitation

If your charging provider created your driver account, you receive an email invitation instead of signing up.

1. Open the invitation email and click the **Set Your Password** link.
2. Enter a password that meets the rules listed under the field (by default at least 12 characters, with an uppercase letter, a lowercase letter, and a number) and confirm it.
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

![Verify Your Email screen](https://www.evtivity.com/screenshots/portal/verify-email.png)

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

The reset link also confirms your email address.

## Multi-Factor Authentication (MFA)

MFA adds a second verification step to your login. You can use one code method (email, authenticator app or SMS) plus passkeys and security keys. The operator controls which methods are enabled system-wide.

Set up and manage MFA in **Account** > **Security**.

![Account Security page](https://www.evtivity.com/screenshots/portal/account-security.png)

Every change asks you to confirm it is you first:

- Without a second factor, enter your current password.
- With a second factor, use it: a code of your method, sent when the field opens, or one of your passkeys.

### Email MFA

1. Go to **Account** and tap **Security**.
2. Confirm it is you.
3. Under **Select method**, select **Email** and tap **Set Up**.
4. A 6-digit code is sent to your registered email.
5. Enter the code and tap **Verify**.

On your next login, a code is sent to your email after you enter your password.

### Authenticator App (TOTP)

1. Go to **Account** and tap **Security**.
2. Confirm it is you.
3. Under **Select method**, select **Authenticator App** and tap **Set Up**.
4. Scan the QR code with an authenticator app (Google Authenticator, Authy, or similar).
5. Enter the 6-digit code from the app and tap **Verify**.

On your next login, open your authenticator app and enter the current code.

### SMS MFA

1. Go to **Account** and tap **Security**.
2. Confirm it is you.
3. Under **Select method**, select **SMS** and tap **Set Up**.
4. A 6-digit code is sent to your registered phone number.
5. Enter the code and tap **Verify**.

On your next login, a code is sent via SMS after you enter your password.

**SMS** is offered only when your profile has a phone number. While SMS codes are on, you cannot remove the phone number from your profile. Disable MFA first.

### Recovery Codes

Turning MFA on shows ten recovery codes once. Each code signs you in once when you lose your second factor.

1. Tap **Copy Codes**, or save them as a text file with **Download Codes**.
2. Store them somewhere safe, then tap **Done**. They are not shown again.

On the verification step after your password, tap **Use a Recovery Code** to use one. **Account** > **Security** shows how many codes are left. **Regenerate Recovery Codes** replaces every code after you confirm with a code of your method or a passkey.

### Disable MFA

1. Go to **Account** and tap **Security**.
2. Tap **Disable MFA**.
3. Confirm it is you with a factor you have or a recovery code. Your password alone is not enough.

Disabling MFA also removes your passkeys and recovery codes and signs you out on your other devices.

When the operator requires MFA for drivers, the portal asks you to set up MFA right after you enter your password, and you are signed in once the setup is done. You cannot disable MFA while it is required. The mobile app cannot do this setup: it tells you to finish in the portal.

After 5 wrong passwords or codes in a row, sign-in is locked for 30 seconds. Each further wrong try doubles the wait, up to 15 minutes.

To switch methods (for example from SMS to authenticator app), disable MFA first and then set up the new method. Attempting to set up while MFA is already enabled returns `MFA_ALREADY_ENABLED`, since overwriting the live secret without confirming the new one would otherwise lock you out at next login.

## Passkeys and Security Keys

A passkey (on your phone, computer or password manager) or a FIDO2 security key, such as a YubiKey, can be your second factor, or your whole sign-in when the operator allows passkey sign-in. Passkeys appear only when your browser supports them on a secure page (HTTPS).

- **Add a passkey**: in **Account** > **Security**, tap **Add a Passkey or Security Key**, confirm it is you, tap **Continue**, then follow your browser's prompt and give the passkey a name. The first passkey turns MFA on, signs you out on your other devices and shows your recovery codes once.
- **Sign in with a passkey**: on the sign-in page, tap **Sign In with a Passkey**, or pick a passkey from the email field's suggestions.
- **Second factor**: after your password, tap **Use a Passkey or Security Key** on the verification step.
- **Rename or remove**: in **Account** > **Security**. Removing a passkey asks you to confirm with a factor you have or a recovery code, never your password alone, and signs you out on your other devices. Removing your last factor turns MFA off and deletes your recovery codes. While the operator requires MFA, your only passkey cannot be removed.
- **Recovery codes**: you can confirm new recovery codes with a passkey.

The mobile app does not support passkeys yet. If a passkey or recovery codes are your only factors, the app tells you to sign in through the portal and set up an authenticator app, email or SMS codes there.

## Notes

- Verification codes expire after 5 minutes.
- TOTP codes use a 30-second rotation window with a 1-step tolerance.
- The operator can enable or disable each MFA method from the CSMS Settings page.
- A code goes only to the channel of your method: an email code by email, an SMS code by SMS.
- Every change to your sign-in methods, a recovery code used and a phone number change send you a security notice by email, and by text message when you sign in with SMS codes.
