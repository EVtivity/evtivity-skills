Generated from https://www.evtivity.com/docs/csms/profile. Do not edit.

# Profile

Manage your own operator account, password, two-factor authentication, passkeys, and recovery codes.

## Overview

The Profile page holds the settings of your own operator account. Open it from the user menu at the top right: click your name or email, then **Profile**. Opening your own user on the Users page also opens it.

![Profile page](https://www.evtivity.com/screenshots/csms/profile.png)

The page has these tabs:

- **Personal Info** - your avatar, name, mobile number, language and timezone.
- **Appearance** - light or dark theme.
- **Change Password** - your password.
- **Two-Factor Authentication** - your second factor, passkeys and security keys, and recovery codes.
- **Notifications** - your SMS notifications and the AI insight action digest email.
- **Chatbot AI** and **Support AI** - your own AI provider settings, shown when the feature is on. See [AI Assistant](https://www.evtivity.com/docs/csms/ai-assistant#personal-configuration).

## Personal Info

### Avatar

Your avatar shows in the sidebar user area, on the Users list and on your user page. Without one, your initials show. On the **Personal Info** tab, click **Edit Avatar** to open the editor. The avatar is saved as soon as you save it in the editor, apart from the form below.

The avatar editor has two modes:

- **Create** - pick the hair or headwear, glasses, eyebrows, eyes, mouth, facial hair, clothes, colors, background and direction. **Hair or Headwear**, **Glasses** and **Facial Hair** start with a **None** option. Click **Random** for a new random avatar, then **Save**.
- **Upload** - click **Choose Image** and pick a JPEG, PNG or WebP image smaller than 1 MB. It is cropped to a centered square, scaled to at most 512 x 512 pixels, saved without its metadata, and stored as soon as it uploads. Uploads need the [S3 bucket](https://www.evtivity.com/docs/csms/settings#s3-bucket).

**Remove Avatar** asks for a confirmation, deletes an uploaded image and shows initials again. One avatar is kept at a time: saving a generated avatar replaces an uploaded image, and the other way around.

### Name, Mobile, Language and Timezone

1. Open the **Personal Info** tab and click **Edit**.
2. Change **First Name**, **Last Name**, **Mobile**, **Language** or **Timezone**.
3. Click **Save**.

Your email address is shown but cannot change here. Ask another admin to change it on the Users page.

When your account has a second factor, a new mobile number needs a proof first: a code of your method or one of your passkeys. When you sign in with SMS codes, also click **Send Code to New Number** and enter the code from the text message under **Code Sent to the New Number**. The number is saved only once confirmed.

## Change Password

1. Open the **Change Password** tab.
2. Enter **Current Password**, **New Password** and **Confirm Password**.
3. Click **Change Password**.

A password change signs out your other sessions. Accounts created through SSO have no password and cannot change it here.

## Two-Factor Authentication

The **Two-Factor Authentication** tab shows whether your account uses a second factor and lets you add, change or remove one. The methods offered are the ones an admin switched on in Settings > Security > MFA (see [MFA settings](https://www.evtivity.com/docs/csms/settings#mfa)).

![Two-Factor Authentication tab of the profile](https://www.evtivity.com/screenshots/csms/profile-mfa.png)

### Set Up a Code Method

1. Open the **Two-Factor Authentication** tab.
2. Confirm it is you. Without a second factor, enter your current password. With a passkey, choose it under **Confirm With** and click **Verify with a Passkey**. An SSO account without a password clicks **Sign In Again with SSO** and comes back to the page.
3. Under **Select method**, pick **Email**, **Authenticator App** or **SMS**, and click **Set Up**.
4. For the authenticator app, scan the QR code. For email or SMS, check for the code.
5. Enter the 6-digit code and click **Verify**.

The first factor turns MFA on and shows your recovery codes once.

An account has one code method. To switch methods, turn MFA off and set up the new method.

### Passkeys and Security Keys

The **Passkeys and Security Keys** card lists your passkeys and security keys with their name, type, created date and last use. A passkey lives on your phone, computer or password manager. A security key is a physical FIDO2 key, such as a YubiKey. Passkeys work only over HTTPS or on localhost. Elsewhere the card says so and offers no option.

To add one:

1. Click **Add a Passkey or Security Key**.
2. Confirm it is you, as for a code method.
3. Click **Continue** and follow the browser prompt: use your fingerprint, face or screen lock, or insert and touch your security key.
4. Enter a name you recognize and click **Save**, or click **Keep This Name**.

A first passkey on an account without MFA turns MFA on, signs out your other sessions and shows your recovery codes once. You can register up to 20.

**Rename** changes the name. **Remove** asks you to confirm with a factor you have or a recovery code, never your password alone. Removing your only factor turns MFA off and deletes your recovery codes. When your organization requires MFA for your role, your only passkey cannot be removed: add another factor first.

When an admin turns on Passkey Sign-In, **Sign In with a Passkey** on the sign-in page signs you in with the passkey alone. At the verification step after your password, **Use a Passkey or Security Key** uses it as the second factor.

### Recovery Codes

Recovery codes sign you in when you lose your second factor. Each code works once.

![Recovery codes shown once on the profile](https://www.evtivity.com/screenshots/csms/profile-recovery-codes.png)

1. Copy the codes with **Copy Codes**, or save them as a text file with **Download Codes**.
2. Store them somewhere safe, then click **Done**. They are not shown again.

The card shows how many codes are left. **Regenerate Recovery Codes** replaces every code: confirm it is you with a code of your method or a passkey. When you have no codes, the card says so and offers to generate them. At the verification step after your password, **Use a Recovery Code** takes one.

### Turn MFA Off

1. Click **Disable MFA**.
2. Confirm it is you with a factor you have or a recovery code. Your password alone is not enough.
3. Confirm.

Turning MFA off also removes your passkeys and recovery codes and signs out your other sessions. When your organization requires MFA for your role, the tab says so and MFA cannot be turned off. To change your method then, ask an admin to reset your MFA.

## Notes

- Every change to your sign-in methods, a recovery code used, a phone number change and a new API key send you a security notice. See [Security Notices](https://www.evtivity.com/docs/configuration/authentication#security-notices).
- Wrong codes entered on this page do not lock your sign-in, but a wrong current password counts toward the sign-in lock. See [Sign-In Lockout](https://www.evtivity.com/docs/configuration/authentication#sign-in-lockout).
- API keys cannot use this page's actions. See [API Keys](https://www.evtivity.com/docs/csms/settings#api-keys).
