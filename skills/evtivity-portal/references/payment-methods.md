Generated from https://www.evtivity.com/docs/portal/payment-methods (website commit 0f3462e). Do not edit.

# Payment Methods

Add, verify, manage, and remove credit or debit cards for EV charging payments, with Stripe, Adyen, or the test provider.

## Overview

Payment methods are required for authenticated charging at stations with paid tariffs. Cards are stored by the operator's payment provider (Stripe or Adyen). EVtivity keeps only the card brand, the last 4 digits, and the provider's card reference, never the full card number.

## View Payment Methods

1. Open the Portal and tap the **Account** tab.
2. Tap **Payment Methods**.

The page lists all saved cards with:

- Card brand (Visa, Mastercard, Amex, etc.)
- Last 4 digits
- Expiration date
- Default indicator

![Payment methods](https://www.evtivity.com/screenshots/portal/payment-methods.png)

## Add a Card

1. On the Payment Methods page, tap **Create Payment Method**.
2. Enter your card number, expiration date, and CVC in the card form. The form comes from the payment provider, so the card data goes straight to the provider.
3. Tap **Add Card**.

If this is your first card, it is automatically set as your default payment method.

### Card Verification (3D Secure)

Your bank can ask you to confirm the card:

- **Stripe**: the bank's verification opens over the page. Confirm the card there, and the card is saved.
- **Adyen**: the page shows "Complete the verification from your bank to continue." and opens your bank's page. After you confirm, the browser returns to the Card Verification page (`/payments/return`), which shows "Finishing the verification with your bank...", then takes you back to Payment Methods with the message "Card saved.". If the verification cannot finish, the page shows the reason and **Back to payment methods**.

If the bank refuses the card, or the verification fails, the card is not saved. The page shows the reason, for example "Your card was declined. Try a different card." or "Authentication failed. The card was not saved." If the Card Verification page says the link is incomplete, start again from the card form.

### Test Mode

When the operator runs the test payment provider, the form shows "Test mode, no real money. Pick a test card." and a **Test card** list instead of card fields. Each test card has a fixed outcome. A card that requires authentication shows a challenge with **Approve** and **Fail**. See [Test Payment Provider](https://www.evtivity.com/docs/integrations/test-payment-provider).

When the operator has not selected a payment provider, the page shows "Payment processing is not available at this time." and no card can be added.

## Set Default Payment Method

1. On the Payment Methods page, find the card you want to use as default.
2. Tap **Set as default**.

The default payment method is used automatically when you start a charging session. You can select a different card at the time of charging if needed.

## Remove a Card

1. On the Payment Methods page, find the card you want to remove.
2. Tap **Remove**.
3. Confirm the removal.

If you remove your default card and have other cards saved, you must set a new default before starting a paid charging session.

## Notes

- You need at least one payment method to start charging at stations with non-free tariffs.
- Pre-authorization holds are placed on your card when a session starts. The final amount is captured when the session ends. Starting a session on a saved card asks for no CVC and no verification.
- Failed payment captures are logged but do not block session completion. The operator may follow up separately.
