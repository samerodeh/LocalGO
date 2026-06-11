# LocalGO Stripe backend

Tiny server that gives the iOS app what Stripe's PaymentSheet needs:
`{ clientSecret, ephemeralKey, customer }`.

## 1. Add your keys
```bash
cp .env.example .env
# paste your sk_test_... and pk_test_... from dashboard.stripe.com/apikeys
```

## 2. Run it
```bash
npm install
npm start          # -> http://localhost:4242
```

Test it:
```bash
curl -X POST http://localhost:4242/create-payment-intent \
  -H "Content-Type: application/json" \
  -d '{"amount":4250,"currency":"cad"}'
```
You should get back `clientSecret`, `ephemeralKey`, and `customer`.

## 3. Deploy
Push this folder to Render / Railway / Fly / Vercel. Set the same two
env vars (`STRIPE_SECRET_KEY`, `STRIPE_PUBLISHABLE_KEY`) in the host's
dashboard. You'll get a public URL like `https://localgo-api.onrender.com`.

## 4. Point the app at it
In `LocalGOConsumer/Services/Config.swift`:
- `stripePublishableKey` = your `pk_test_...`
- `backendURL`           = your deployed URL (no trailing slash)

Done — `Config.isStripeConfigured` flips to true and checkout uses the
real Stripe PaymentSheet instead of the local test authorize.

## Test cards
- Success: `4242 4242 4242 4242`, any future expiry, any CVC, any ZIP.
- More: https://stripe.com/docs/testing
