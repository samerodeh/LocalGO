/**
 * emailService.ts — powered by Web3Forms
 *
 * Setup (one-time, ~30 seconds):
 *   1. Go to https://web3forms.com/access
 *   2. Enter your email → get a free access key instantly (no sign-up)
 *   3. Create /Users/samerodeh/localgo-landing/.env.local and add:
 *        VITE_W3F_KEY=your_access_key_here
 *   4. Restart the dev server — done.
 *
 * Free tier: 250 emails/month, emails land in your inbox directly.
 */

const ACCESS_KEY = import.meta.env.VITE_W3F_KEY as string | undefined

export const emailConfigured = () => Boolean(ACCESS_KEY)

// ─── Registration form ────────────────────────────────────────────────────

export interface RegistrationPayload {
  ownerName:    string
  businessName: string
  email:        string
  phone:        string
  businessType: string
  address:      string
  dailyOrders:  string
  description:  string
}

export async function sendRegistration(data: RegistrationPayload): Promise<void> {
  const res = await fetch('https://api.web3forms.com/submit', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', Accept: 'application/json' },
    body: JSON.stringify({
      access_key:    ACCESS_KEY,
      subject:       `New Partner Registration: ${data.businessName}`,
      from_name:     data.ownerName,
      replyto:       data.email,
      'Owner Name':  data.ownerName,
      'Business':    data.businessName,
      'Email':       data.email,
      'Phone':       data.phone,
      'Type':        data.businessType,
      'Address':     data.address,
      'Daily Orders':data.dailyOrders,
      'Description': data.description,
    }),
  })
  const json = await res.json()
  if (!json.success) throw new Error(json.message ?? 'Submission failed')
}

// ─── Contact / enquiry form ───────────────────────────────────────────────

export interface ContactPayload {
  name:     string
  business: string
  email:    string
  message:  string
}

export async function sendContact(data: ContactPayload): Promise<void> {
  const res = await fetch('https://api.web3forms.com/submit', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', Accept: 'application/json' },
    body: JSON.stringify({
      access_key:   ACCESS_KEY,
      subject:      `New Partner Enquiry: ${data.business}`,
      from_name:    data.name,
      replyto:      data.email,
      'Name':       data.name,
      'Business':   data.business,
      'Email':      data.email,
      'Message':    data.message,
    }),
  })
  const json = await res.json()
  if (!json.success) throw new Error(json.message ?? 'Submission failed')
}
