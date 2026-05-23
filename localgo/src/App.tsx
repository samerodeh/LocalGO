import React, { useState, FormEvent } from 'react'
import './App.css'

/* ─────────────────────────────────────────────
   LOGO
───────────────────────────────────────────── */
const Logo: React.FC<{ dark?: boolean }> = ({ dark = false }) => (
  <span className={`logo ${dark ? 'logo--dark' : ''}`}>
    <span className="logo__local">Local</span>
    <span className="logo__go">Go</span>
  </span>
)

/* ─────────────────────────────────────────────
   NAV
───────────────────────────────────────────── */
const Nav: React.FC = () => {
  const [menuOpen, setMenuOpen] = useState(false)

  return (
    <header className="nav">
      <div className="container nav__inner">
        <Logo />
        <button
          className="nav__hamburger"
          aria-label="Toggle menu"
          onClick={() => setMenuOpen(v => !v)}
        >
          <span className={`hamburger-icon ${menuOpen ? 'open' : ''}`} />
        </button>
        <nav className={`nav__links ${menuOpen ? 'nav__links--open' : ''}`}>
          <a href="#about" onClick={() => setMenuOpen(false)}>About</a>
          <a href="#how" onClick={() => setMenuOpen(false)}>How It Works</a>
          <a href="#features" onClick={() => setMenuOpen(false)}>Features</a>
          <a href="#contact" className="nav__cta" onClick={() => setMenuOpen(false)}>
            Partner With Us
          </a>
        </nav>
      </div>
    </header>
  )
}

/* ─────────────────────────────────────────────
   HERO
───────────────────────────────────────────── */
const Hero: React.FC = () => (
  <section className="hero">
    {/* decorative diagonal bar — mirrors business card */}
    <div className="hero__bar" aria-hidden="true" />

    <div className="container hero__inner">
      <div className="hero__badge anim-fade-in d1">Montreal · SGW · Downtown</div>

      <h1 className="hero__title anim-fade-up d2">
        <Logo /><br />
        <span className="hero__tagline">Fast &amp; Reliable Delivery</span>
      </h1>

      <p className="hero__sub anim-fade-up d3">
        Supporting local businesses in downtown Montreal — delivered fast from SGW and beyond.
        One app. Every local favourite.
      </p>

      <div className="hero__actions anim-fade-up d4">
        <a href="#contact" className="btn btn--primary">Partner With Us</a>
        <a href="#how" className="btn btn--ghost">How It Works</a>
      </div>
    </div>

    <div className="hero__stats anim-fade-up d5">
      <div className="container hero__stats-inner">
        {[
          { value: '50+', label: 'Local Partners' },
          { value: '30 min', label: 'Avg. Delivery' },
          { value: '3 km', label: 'SGW Radius' },
        ].map(s => (
          <div className="stat" key={s.label}>
            <span className="stat__value">{s.value}</span>
            <span className="stat__label">{s.label}</span>
          </div>
        ))}
      </div>
    </div>
  </section>
)

/* ─────────────────────────────────────────────
   ABOUT
───────────────────────────────────────────── */
const About: React.FC = () => (
  <section className="about section" id="about">
    <div className="container about__inner">
      <div className="about__text">
        <span className="eyebrow">About LocalGo</span>
        <h2 className="section-title">
          One platform.<br />Every local business.
        </h2>
        <p>
          LocalGo is a delivery platform built specifically for the downtown Montreal ecosystem.
          Centered around Concordia University's SGW campus, we connect students, residents, and
          workers with the restaurants, markets, and shops that make the neighbourhood special.
        </p>
        <p>
          We handle the full delivery logistics — so local businesses can focus on what they do
          best, while reaching more customers through a single, unified app experience.
        </p>
        <a href="#contact" className="btn btn--primary" style={{ marginTop: '2rem', display: 'inline-flex' }}>
          Join Our Network
        </a>
      </div>

      <div className="about__cards">
        {[
          {
            icon: '🏪',
            title: 'Built for Local',
            body: 'We exclusively partner with independent businesses — no chains, no compromises.',
          },
          {
            icon: '🚀',
            title: 'Logistics Handled',
            body: 'We manage drivers, routing, and delivery so you don\'t have to.',
          },
          {
            icon: '📱',
            title: 'Unified Experience',
            body: 'Customers order from multiple businesses in one cart, one checkout, one delivery.',
          },
        ].map(c => (
          <div className="about-card" key={c.title}>
            <span className="about-card__icon">{c.icon}</span>
            <h3 className="about-card__title">{c.title}</h3>
            <p className="about-card__body">{c.body}</p>
          </div>
        ))}
      </div>
    </div>
  </section>
)

/* ─────────────────────────────────────────────
   HOW IT WORKS
───────────────────────────────────────────── */
const steps = [
  {
    n: '01',
    title: 'Browse Local Businesses',
    body: 'Customers discover your restaurant or market alongside other beloved local spots in our curated downtown Montreal catalogue.',
  },
  {
    n: '02',
    title: 'One App, One Order',
    body: 'They build a single cart across multiple merchants — food, groceries, and essentials together — and check out in seconds.',
  },
  {
    n: '03',
    title: 'Fast Delivery',
    body: 'Our riders deliver across the SGW area and downtown core, keeping your customers happy and coming back.',
  },
]

const HowItWorks: React.FC = () => (
  <section className="how section" id="how">
    <div className="container">
      <div className="section-header">
        <span className="eyebrow">How It Works</span>
        <h2 className="section-title">Simple for businesses.<br />Seamless for customers.</h2>
      </div>

      <div className="steps">
        {steps.map((s, i) => (
          <div className="step" key={s.n}>
            <div className="step__number">{s.n}</div>
            {i < steps.length - 1 && <div className="step__connector" aria-hidden="true" />}
            <h3 className="step__title">{s.title}</h3>
            <p className="step__body">{s.body}</p>
          </div>
        ))}
      </div>
    </div>
  </section>
)

/* ─────────────────────────────────────────────
   FEATURES
───────────────────────────────────────────── */
const features = [
  { icon: '🏙️', title: 'Downtown Montreal Focus', body: 'We know every block between Guy and Atwater. Your neighbourhood, our expertise.' },
  { icon: '⚡', title: 'Fast Delivery Around SGW', body: 'Tight delivery zones mean faster times and fresher orders for Concordia students and locals.' },
  { icon: '❤️', title: 'Supports Small Businesses', body: 'Fair revenue splits and zero hidden fees. We grow when you grow.' },
  { icon: '🛒', title: 'Food + Grocery + Essentials', body: 'One platform covering restaurants, dépanneurs, bakeries, florists, and more.' },
  { icon: '📊', title: 'Business Dashboard', body: 'Real-time order tracking, sales analytics, and customer insights in one place.' },
  { icon: '🤝', title: 'Dedicated Partner Support', body: 'A real human to call when you need help — not a chatbot ticketing system.' },
]

const Features: React.FC = () => (
  <section className="features section" id="features">
    <div className="container">
      <div className="section-header section-header--light">
        <span className="eyebrow eyebrow--light">Features</span>
        <h2 className="section-title section-title--light">Everything a local business needs.</h2>
      </div>

      <div className="features__grid">
        {features.map(f => (
          <div className="feature-card" key={f.title}>
            <span className="feature-card__icon">{f.icon}</span>
            <h3 className="feature-card__title">{f.title}</h3>
            <p className="feature-card__body">{f.body}</p>
          </div>
        ))}
      </div>
    </div>
  </section>
)

/* ─────────────────────────────────────────────
   CONTACT / PARTNER FORM
───────────────────────────────────────────── */
const Contact: React.FC = () => {
  const [sent, setSent] = useState(false)
  const [form, setForm] = useState({ name: '', business: '', email: '', message: '' })

  const handle = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) =>
    setForm(prev => ({ ...prev, [e.target.name]: e.target.value }))

  const submit = (e: FormEvent) => {
    e.preventDefault()
    // In production this would POST to an API
    setSent(true)
  }

  return (
    <section className="contact section" id="contact">
      <div className="container contact__inner">
        <div className="contact__left">
          <span className="eyebrow">Partner With Us</span>
          <h2 className="section-title">Ready to grow<br />your reach?</h2>
          <p>
            Tell us about your business and we'll be in touch within one business day.
            No commitment required — just a conversation.
          </p>

          <ul className="contact__details">
            <li><strong>T:</strong> 514.555.0199</li>
            <li><strong>E:</strong> hello@localgo.ca</li>
            <li><strong>W:</strong> www.localgo.ca</li>
            <li><strong>📍</strong> Montreal, QC</li>
          </ul>
        </div>

        <div className="contact__form-wrap">
          {sent ? (
            <div className="contact__success">
              <span className="contact__success-icon">✓</span>
              <h3>We received your message!</h3>
              <p>Expect a reply within one business day.</p>
            </div>
          ) : (
            <form className="contact__form" onSubmit={submit} noValidate>
              <div className="form-row">
                <label>
                  Your Name
                  <input
                    type="text" name="name" value={form.name}
                    onChange={handle} required placeholder="Jane Smith"
                  />
                </label>
                <label>
                  Business Name
                  <input
                    type="text" name="business" value={form.business}
                    onChange={handle} required placeholder="Café du Coin"
                  />
                </label>
              </div>
              <label>
                Email Address
                <input
                  type="email" name="email" value={form.email}
                  onChange={handle} required placeholder="you@yourbusiness.com"
                />
              </label>
              <label>
                Business Type
                <select name="type" onChange={handle} defaultValue="">
                  <option value="" disabled>Select…</option>
                  <option>Restaurant</option>
                  <option>Grocery / Market</option>
                  <option>Bakery / Café</option>
                  <option>Specialty Store</option>
                  <option>Other</option>
                </select>
              </label>
              <label>
                Tell us about your business
                <textarea
                  name="message" value={form.message}
                  onChange={handle} rows={4}
                  placeholder="Where are you located? How many orders do you handle per day?"
                />
              </label>
              <button type="submit" className="btn btn--primary btn--full">
                Send Partnership Request
              </button>
            </form>
          )}
        </div>
      </div>
    </section>
  )
}

/* ─────────────────────────────────────────────
   FOOTER
───────────────────────────────────────────── */
const Footer: React.FC = () => (
  <footer className="footer">
    {/* orange diagonal bar — mirrors business card back */}
    <div className="footer__bar" aria-hidden="true" />
    <div className="container footer__inner">
      <div className="footer__brand">
        <Logo />
        <p className="footer__sub">MONTREAL DELIVERY SERVICES</p>
        <p className="footer__location">MONTREAL, QC</p>
      </div>
      <div className="footer__links">
        <a href="#about">About</a>
        <a href="#how">How It Works</a>
        <a href="#features">Features</a>
        <a href="#contact">Partner With Us</a>
      </div>
      <div className="footer__contact">
        <p><strong>T:</strong> 514.555.0199</p>
        <p><strong>E:</strong> hello@localgo.ca</p>
        <p><strong>W:</strong> www.localgo.ca</p>
      </div>
    </div>
    <div className="footer__bottom">
      <div className="container">
        <span>Built for downtown Montreal 🇨🇦</span>
        <span>© {new Date().getFullYear()} LocalGo. All rights reserved.</span>
      </div>
    </div>
  </footer>
)

/* ─────────────────────────────────────────────
   APP
───────────────────────────────────────────── */
export default function App() {
  return (
    <>
      <Nav />
      <main>
        <Hero />
        <About />
        <HowItWorks />
        <Features />
        <Contact />
      </main>
      <Footer />
    </>
  )
}
