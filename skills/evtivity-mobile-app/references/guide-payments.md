Generated from https://www.evtivity.com/docs/mobile-app/guide/payments (website commit 0f3462e). Do not edit.

# Payments

Add a card with Stripe, Adyen, or the test provider, confirm it with your bank, set a default, and manage your saved payment methods.

## Overview

Charging is paid through a card you save in the app. Cards are stored by your operator's payment provider (Stripe or Adyen), so your full card number is never stored by the app or the operator. You manage cards under **Account &gt; Payment Methods**.

![Payment Methods screen](https://www.evtivity.com/screenshots/mobile/payment-methods.png)

Each saved card shows the brand, the last four digits, and a **Default** badge on the one in use.

## Add a card

1. Open the **Account** tab and tap **Payment Methods**.
2. Tap **Add a Card**.
3. Enter your card number, expiry, and security code in the provider's secure card form.
4. Save. The app shows "Card saved" and the card appears in your list.

### Card verification (3D Secure)

Your bank can ask you to confirm the card:

- **Stripe**: the verification opens inside the card sheet.
- **Adyen**: the app opens your bank's page. Confirm the card there, and you return to the app, which finishes saving the card.

If the bank refuses the card or the verification fails, the card is not saved and the app shows the reason.

### Test mode

When the operator runs the test payment provider, the app shows a **Test mode** badge ("No real card is charged. The test card you pick decides the outcome.") and a **Choose a test card** list instead of the card form. A card that requires authentication asks you to **Confirm the card** with **Approve** or **Fail authentication**.

### Older app versions

If your app version does not support the operator's payment provider, the screen shows a message instead of the card form:

- "Update the app to add a card with this payment provider."
- "This app build cannot add a card with this payment provider. Install the latest version of the app."

Install the latest version from your app store. Cards you saved earlier keep working for charging in every version.

## Set a default card

The default card is the one used when you start a session. To change it, tap **Set default** on another card. The **Default** badge moves to it.

## Remove a card

Tap **Remove** on a card to delete it. If you remove your only card, add another before you start your next session.

> **Note:**
>
> If your operator runs a free network or bills you another way (for example, a workplace or fleet account), the Payment Methods screen may show that no card is required. When the operator has not set up payments, the screen shows "Payments are not set up for this operator."
