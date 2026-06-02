/**
 * emailService.ts
 *
 * Thin wrapper around EmailJS for sending form submissions.
 *
 * Two templates are used:
 *   - REGISTRATION: business partner registration form (RegisterPage)
 *   - CONTACT:      general partner enquiry form (Contact section)
 *
 * Required environment variables (set in Replit Secrets):
 *   VITE_EMAILJS_SERVICE_ID       — from EmailJS dashboard › Email Services
 *   VITE_EMAILJS_TEMPLATE_REG     — template ID for the registration form
 *   VITE_EMAILJS_TEMPLATE_CONTACT — template ID for the contact form
 *   VITE_EMAILJS_PUBLIC_KEY       — from EmailJS account settings › API Keys
 *
 * EmailJS sends the variables as {{ variable_name }} in your template.
 * See the README comment at the bottom of this file for template setup.
 */

import emailjs from '@emailjs/browser'

const SERVICE_ID        = import.meta.env.VITE_EMAILJS_SERVICE_ID        as string
const TEMPLATE_REG      = import.meta.env.VITE_EMAILJS_TEMPLATE_REG      as string
const TEMPLATE_CONTACT  = import.meta.env.VITE_EMAILJS_TEMPLATE_CONTACT  as string
const PUBLIC_KEY        = import.meta.env.VITE_EMAILJS_PUBLIC_KEY        as string

/** Returns true if all four env vars are configured */
export const emailConfigured = () =>
  Boolean(SERVICE_ID && TEMPLATE_REG && TEMPLATE_CONTACT && PUBLIC_KEY)

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

/**
 * Send a business registration notification.
 * Maps form fields to EmailJS template variables.
 */
export async function sendRegistration(data: RegistrationPayload): Promise<void> {
  await emailjs.send(
    SERVICE_ID,
    TEMPLATE_REG,
    {
      from_name:    data.ownerName,
      business_name:data.businessName,
      from_email:   data.email,
      phone:        data.phone,
      business_type:data.businessType,
      address:      data.address,
      daily_orders: data.dailyOrders,
      description:  data.description,
    },
    PUBLIC_KEY,
  )
}

// ─── Contact / enquiry form ───────────────────────────────────────────────

export interface ContactPayload {
  name:     string
  business: string
  email:    string
  message:  string
}

/**
 * Send a general partner enquiry notification.
 */
export async function sendContact(data: ContactPayload): Promise<void> {
  await emailjs.send(
    SERVICE_ID,
    TEMPLATE_CONTACT,
    {
      from_name:    data.name,
      business_name:data.business,
      from_email:   data.email,
      message:      data.message,
    },
    PUBLIC_KEY,
  )
}

/*
 * ─── EmailJS Template Setup Guide ─────────────────────────────────────────
 *
 * 1. Sign up free at https://www.emailjs.com  (200 emails/month free)
 *
 * 2. Add an email service:
 *    Dashboard → Email Services → Add New Service → Gmail / Outlook / other
 *    Copy the "Service ID" → set as VITE_EMAILJS_SERVICE_ID
 *
 * 3. Create the REGISTRATION template:
 *    Dashboard → Email Templates → Create New Template
 *    Subject:  New Partner Registration: {{business_name}}
 *    Body example:
 *      Owner:         {{from_name}}
 *      Business:      {{business_name}}
 *      Email:         {{from_email}}
 *      Phone:         {{phone}}
 *      Type:          {{business_type}}
 *      Address:       {{address}}
 *      Daily orders:  {{daily_orders}}
 *      Description:   {{description}}
 *    Copy the "Template ID" → set as VITE_EMAILJS_TEMPLATE_REG
 *
 * 4. Create the CONTACT template:
 *    Subject:  New Partner Enquiry: {{business_name}}
 *    Body example:
 *      Name:     {{from_name}}
 *      Business: {{business_name}}
 *      Email:    {{from_email}}
 *      Message:  {{message}}
 *    Copy the "Template ID" → set as VITE_EMAILJS_TEMPLATE_CONTACT
 *
 * 5. Get your Public Key:
 *    Account → API Keys → Public Key
 *    Set as VITE_EMAILJS_PUBLIC_KEY
 *
 * ─────────────────────────────────────────────────────────────────────────
 */
