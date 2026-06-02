/**
 * Business Registration Page
 *
 * Allows business owners to apply to join the LocalGo partner network.
 * All UI text is translated via LanguageContext (EN / FR / AR).
 *
 * On submission, sends a notification email via EmailJS and shows a
 * success confirmation. Requires VITE_EMAILJS_* environment variables.
 */

import React, { useState, FormEvent } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { useLang } from '../context/LanguageContext'
import { IconDollar, IconZap, IconShield, IconUsers } from '../icons'
import { sendRegistration, emailConfigured } from '../lib/emailService'

const PERK_ICONS = [IconDollar, IconZap, IconShield, IconUsers]

const RegisterPage: React.FC = () => {
  const { T }  = useLang()
  const r      = T.register
  const [sent,    setSent]    = useState(false)
  const [loading, setLoading] = useState(false)
  const [error,   setError]   = useState('')
  const [form, setForm] = useState({
    ownerName: '', businessName: '', email: '', phone: '',
    businessType: '', address: '', dailyOrders: '', description: '',
  })

  const handle = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) =>
    setForm(prev => ({ ...prev, [e.target.name]: e.target.value }))

  const submit = async (e: FormEvent) => {
    e.preventDefault()
    setError('')
    if (emailConfigured()) {
      setLoading(true)
      try {
        await sendRegistration(form)
      } catch {
        setError('Could not send your registration. Please try again.')
        setLoading(false)
        return
      }
      setLoading(false)
    }
    setSent(true)
  }

  const perks = [
    { title: r.perk1title, body: r.perk1body },
    { title: r.perk2title, body: r.perk2body },
    { title: r.perk3title, body: r.perk3body },
    { title: r.perk4title, body: r.perk4body },
  ]

  return (
    <motion.div
      className="page-wrapper"
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0 }}
      transition={{ duration: 0.4 }}
    >
      {/* ── Page hero ── */}
      <div className="page-hero">
        <div className="container">
          <motion.span className="eyebrow eyebrow--light" initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ delay: 0.1 }}>
            {r.eyebrow}
          </motion.span>
          <motion.h1 className="page-hero__title" initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.2 }}>
            {r.title.split('\n').map((line, i) => (
              <span key={i}>{line}{i === 0 && <br />}</span>
            ))}
          </motion.h1>
          <motion.p className="page-hero__sub" initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.3 }}>
            {r.sub}
          </motion.p>
        </div>
      </div>

      {/* ── Main body ── */}
      <div className="register-body section">
        <div className="container register-inner">

          {/* ── Left: perks + pricing ── */}
          <div className="register-perks">
            <h2 className="register-perks__title">{r.perksTitle}</h2>

            <div className="register-perks__list">
              {perks.map((p, i) => {
                const Icon = PERK_ICONS[i]
                return (
                  <motion.div
                    className="perk-card"
                    key={p.title}
                    initial={{ opacity: 0, x: -30 }}
                    whileInView={{ opacity: 1, x: 0 }}
                    viewport={{ once: true }}
                    transition={{ duration: 0.5, delay: i * 0.1 }}
                  >
                    <span className="perk-card__icon"><Icon /></span>
                    <div>
                      <h4 className="perk-card__title">{p.title}</h4>
                      <p className="perk-card__body">{p.body}</p>
                    </div>
                  </motion.div>
                )
              })}
            </div>

            {/* Pricing summary pills */}
            <div className="register-pricing">
              <div className="pricing-pill">
                <span className="pricing-pill__value">$5</span>
                <span className="pricing-pill__label">{r.pricingDeliveryLabel}</span>
              </div>
              <div className="pricing-divider">+</div>
              <div className="pricing-pill">
                <span className="pricing-pill__value">10%</span>
                <span className="pricing-pill__label">{r.pricingCommissionLabel}</span>
              </div>
            </div>
          </div>

          {/* ── Right: registration form ── */}
          <motion.div
            className="contact__form-wrap"
            initial={{ opacity: 0, x: 50 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.6 }}
          >
            <AnimatePresence mode="wait">
              {sent ? (
                /* ── Success state ── */
                <motion.div
                  className="contact__success"
                  initial={{ opacity: 0, scale: 0.95 }}
                  animate={{ opacity: 1, scale: 1 }}
                  exit={{ opacity: 0 }}
                  transition={{ duration: 0.4 }}
                >
                  <motion.span
                    className="contact__success-icon"
                    initial={{ scale: 0 }}
                    animate={{ scale: 1 }}
                    transition={{ delay: 0.2, type: 'spring', stiffness: 300 }}
                  >
                    ✓
                  </motion.span>
                  <h3>{r.successH3}</h3>
                  <p>{r.successP}</p>
                </motion.div>
              ) : (
                /* ── Registration form ── */
                <motion.form
                  className="contact__form"
                  onSubmit={submit}
                  noValidate
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  exit={{ opacity: 0 }}
                >
                  <h3 className="register-form__title">{r.formTitle}</h3>

                  <div className="form-row">
                    <label>
                      {r.labelOwner}
                      <input type="text" name="ownerName" value={form.ownerName} onChange={handle} required placeholder={r.placeholderOwner} />
                    </label>
                    <label>
                      {r.labelBusinessName}
                      <input type="text" name="businessName" value={form.businessName} onChange={handle} required placeholder={r.placeholderBusiness} />
                    </label>
                  </div>

                  <div className="form-row">
                    <label>
                      {r.labelEmail}
                      <input type="email" name="email" value={form.email} onChange={handle} required placeholder={r.placeholderEmail} />
                    </label>
                    <label>
                      {r.labelPhone}
                      <input type="tel" name="phone" value={form.phone} onChange={handle} placeholder={r.placeholderPhone} />
                    </label>
                  </div>

                  <label>
                    {r.labelType}
                    <select name="businessType" value={form.businessType} onChange={handle} required>
                      <option value="" disabled>Select…</option>
                      {r.typeOptions.map(o => <option key={o}>{o}</option>)}
                    </select>
                  </label>

                  <label>
                    {r.labelAddress}
                    <input type="text" name="address" value={form.address} onChange={handle} required placeholder={r.placeholderAddress} />
                  </label>

                  <label>
                    {r.labelDailyOrders}
                    <select name="dailyOrders" value={form.dailyOrders} onChange={handle}>
                      <option value="" disabled>Select range…</option>
                      {r.dailyOrderOptions.map(o => <option key={o}>{o}</option>)}
                    </select>
                  </label>

                  <label>
                    {r.labelDescription}
                    <textarea name="description" value={form.description} onChange={handle} rows={4} placeholder={r.placeholderDescription} />
                  </label>

                  {error && (
                    <p style={{ color: '#ef4444', fontSize: '0.875rem', marginTop: '0.5rem' }}>{error}</p>
                  )}

                  <motion.button
                    type="submit"
                    className="btn btn--primary btn--full"
                    whileHover={loading ? {} : { scale: 1.02, y: -2 }}
                    whileTap={loading ? {} : { scale: 0.98 }}
                    disabled={loading}
                    style={{ opacity: loading ? 0.7 : 1 }}
                  >
                    {loading ? 'Sending…' : r.submit}
                  </motion.button>
                </motion.form>
              )}
            </AnimatePresence>
          </motion.div>

        </div>
      </div>
    </motion.div>
  )
}

export default RegisterPage
