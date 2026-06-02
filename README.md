# LocalGo

Landing page for **LocalGo** — a fast, low-fee delivery service for Montreal businesses. Built with Vite, React, and TypeScript, deployed on Vercel ([localgo.vercel.app](https://localgo.vercel.app)).

## Tech stack

- **Vite 5** + **React 18** + **TypeScript**
- **framer-motion** for animations
- **EmailJS** for the registration and contact forms
- Lightweight in-app router and i18n (English / French) via React context

## Getting started

```bash
npm install
npm run dev      # starts the dev server on http://localhost:5000
```

Other scripts:

```bash
npm run build    # type-check (tsc) + production build to dist/
npm run preview  # preview the production build locally
```

## Environment variables

The contact and registration forms use [EmailJS](https://www.emailjs.com). Create a `.env` file in the project root (these are baked in at build time, so they must be set wherever you build — locally and in Vercel's project settings):

```
VITE_EMAILJS_SERVICE_ID=
VITE_EMAILJS_TEMPLATE_REG=
VITE_EMAILJS_TEMPLATE_CONTACT=
VITE_EMAILJS_PUBLIC_KEY=
```

Without these, the forms render but won't send. See the setup guide in [`src/lib/emailService.ts`](src/lib/emailService.ts) for how to create the EmailJS service and templates.

## Project structure

```
src/
  components/   shared UI (Nav, Footer, Logo, AppDownloadModal)
  context/      LanguageContext, RouterContext
  i18n/         translations
  icons/
  lib/          emailService (EmailJS wrapper)
  pages/        HomePage, MarketplacePage, RegisterPage
  sections/     Hero, About, Features, HowItWorks, Comparison, Contact
```

## Deployment

Pushes to `main` auto-deploy to Vercel. The Vercel **Root Directory** must be the repo root (empty), and EmailJS env vars must be set in the Vercel project settings.
