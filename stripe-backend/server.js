// Minimal Stripe backend for LocalGO's PaymentSheet.
// The iOS app POSTs to /create-payment-intent and expects back:
//   { clientSecret, ephemeralKey, customer }
//
// Run locally:   npm install && npm start
// Deploy to:     Render / Railway / Fly / a Vercel or Cloud Function, etc.
//
// SECURITY: the SECRET key (sk_...) lives ONLY here, never in the app.

const express = require("express");
const Stripe = require("stripe");

const stripe = Stripe(process.env.STRIPE_SECRET_KEY);
const app = express();
app.use(express.json());

app.get("/", (_req, res) => res.send("LocalGO Stripe backend is running."));

app.post("/create-payment-intent", async (req, res) => {
  try {
    const { amount, currency = "cad" } = req.body;
    if (!amount || amount < 50) {
      return res.status(400).json({ error: "Invalid amount (in cents)." });
    }

    // 1) A Customer so the card can be saved/reused.
    const customer = await stripe.customers.create();

    // 2) An ephemeral key so the app can manage that Customer securely.
    const ephemeralKey = await stripe.ephemeralKeys.create(
      { customer: customer.id },
      { apiVersion: "2024-06-20" } // match your Stripe SDK / dashboard version
    );

    // 3) The PaymentIntent for this order.
    const paymentIntent = await stripe.paymentIntents.create({
      amount,                      // integer, in cents (e.g. $42.50 -> 4250)
      currency,                    // "cad"
      customer: customer.id,
      automatic_payment_methods: { enabled: true },
    });

    res.json({
      clientSecret: paymentIntent.client_secret,
      ephemeralKey: ephemeralKey.secret,
      customer: customer.id,
      publishableKey: process.env.STRIPE_PUBLISHABLE_KEY,
    });
  } catch (err) {
    console.error(err);
    res.status(400).json({ error: err.message });
  }
});

const port = process.env.PORT || 4242;
app.listen(port, () => console.log(`Stripe backend listening on ${port}`));
