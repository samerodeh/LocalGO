/**
 * Contact / Partner Enquiry Section
 *
 * Two-column layout:
 * - Left: heading, copy, and contact details (translated)
 * - Right: enquiry form with translated labels and placeholders
 *
 * On successful submission the form is replaced by a translated success message.
 * TODO: wire the submit handler to a real backend API.
 */

import React, { useState, FormEvent } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { useLang } from '../context/LanguageContext'
import { sendContact, emailConfigured } from '../lib/emailService'

const Contact: React.FC = () => {
  const { T } = useLang()
  const c     = T.contact

  const [sent,    setSent]    = useState(false)
  const [loading, setLoading] = useState(false)
  const [error,   setError]   = useState('')
  const [form, setForm] = useState({ name: '', business: '', email: '', message: '' })

  const handle = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) =>
    setForm(prev => ({ ...prev, [e.target.name]: e.target.value }))

  const submit = async (e: FormEvent) => {
    e.preventDefault()
    setError('')
    if (emailConfigured()) {
      setLoading(true)
      try {
        await sendContact({ name: form.name, business: form.business, email: form.email, message: form.message })
      } catch {
        setError('Could not send message. Please try again.')
        setLoading(false)
        return
      }
      setLoading(false)
    }
    setSent(true)
  }

  return (
    <motion.section
      className="contact section"
      id="contact"
      initial={{ opacity: 0 }}
      whileInView={{ opacity: 1 }}
      viewport={{ once: true, margin: '-100px' }}
      transition={{ duration: 0.8 }}
    >
      <div className="container contact__inner">
        {/* Left — intro and contact details */}
        <motion.div
          className="contact__left"
          initial={{ opacity: 0, x: -50 }}
          whileInView={{ opacity: 1, x: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6 }}
        >
          <span className="eyebrow">{c.eyebrow}</span>
          <h2 className="section-title">
            {c.title.split('\n').map((line, i) => (
              <span key={i}>{line}{i === 0 && <br />}</span>
            ))}
          </h2>
          <p>{c.body}</p>

          <motion.ul
            className="contact__details"
            initial={{ opacity: 0 }}
            whileInView={{ opacity: 1 }}
            viewport={{ once: true }}
            transition={{ duration: 0.6, delay: 0.2 }}
          >
            <li><strong>T</strong> 514.555.0199</li>
            <li><strong>E</strong> hello@localgo.ca</li>
            <li><strong>W</strong> www.localgo.ca</li>
            <li><strong>Location</strong> Montreal, QC</li>
          </motion.ul>
        </motion.div>

        {/* Right — form or success state */}
        <motion.div
          className="contact__form-wrap"
          initial={{ opacity: 0, x: 50 }}
          whileInView={{ opacity: 1, x: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6 }}
        >
          <AnimatePresence mode="wait">
            {sent ? (
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
                <h3>{c.successH3}</h3>
                <p>{c.successP}</p>
              </motion.div>
            ) : (
              <motion.form
                className="contact__form"
                onSubmit={submit}
                noValidate
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                exit={{ opacity: 0 }}
              >
                <motion.div className="form-row" initial={{ opacity: 0, y: 30 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.1 }}>
                  <label>
                    {c.labelName}
                    <input type="text" name="name" value={form.name} onChange={handle} required placeholder={c.placeholderName} />
                  </label>
                  <label>
                    {c.labelBusiness}
                    <input type="text" name="business" value={form.business} onChange={handle} required placeholder={c.placeholderBusiness} />
                  </label>
                </motion.div>

                <motion.label initial={{ opacity: 0, y: 30 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.2 }}>
                  {c.labelEmail}
                  <input type="email" name="email" value={form.email} onChange={handle} required placeholder={c.placeholderEmail} />
                </motion.label>

                <motion.label initial={{ opacity: 0, y: 30 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.3 }}>
                  {c.labelType}
                  <select name="type" onChange={handle} defaultValue="">
                    <option value="" disabled>Select…</option>
                    {c.typeOptions.map(o => <option key={o}>{o}</option>)}
                  </select>
                </motion.label>

                <motion.label initial={{ opacity: 0, y: 30 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.4 }}>
                  {c.labelMessage}
                  <textarea name="message" value={form.message} onChange={handle} rows={4} placeholder={c.placeholderMessage} />
                </motion.label>

                {error && (
                  <p style={{ color: '#ef4444', fontSize: '0.875rem', marginTop: '0.5rem' }}>{error}</p>
                )}

                <motion.button
                  type="submit"
                  className="btn btn--primary btn--full"
                  initial={{ opacity: 0, y: 30 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: 0.5 }}
                  whileHover={loading ? {} : { scale: 1.02, y: -2 }}
                  whileTap={loading ? {} : { scale: 0.98 }}
                  disabled={loading}
                  style={{ opacity: loading ? 0.7 : 1 }}
                >
                  {loading ? 'Sending…' : c.submit}
                </motion.button>
              </motion.form>
            )}
          </AnimatePresence>
        </motion.div>
      </div>
    </motion.section>
  )
}

export default Contact
