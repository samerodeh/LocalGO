/**
 * Hero Section
 *
 * Full-viewport opening section with:
 * - Location badge
 * - LocalGo logo + tagline (translated)
 * - Value proposition subtitle (translated)
 * - Two primary CTAs:
 *     1. Register Your Business → Register page
 *     2. Download the App → AppDownloadModal
 * - Stats bar: $5 · 10% · 30 min · 3 km (labels translated)
 */

import React, { useState } from 'react'
import { motion } from 'framer-motion'
import { useRouter } from '../context/RouterContext'
import { useLang } from '../context/LanguageContext'
import Logo from '../components/Logo'
import AppDownloadModal from '../components/AppDownloadModal'

const Hero: React.FC = () => {
  const { go }            = useRouter()
  const { T }             = useLang()
  const h                 = T.hero
  const [modal, setModal] = useState(false)

  const stats = [
    { value: '$5',     label: h.stat1label },
    { value: '10%',    label: h.stat2label },
    { value: '30 min', label: h.stat3label },
    { value: '3 km',   label: h.stat4label },
  ]

  return (
    <>
      <section className="hero">
        {/* Decorative diagonal accent bar */}
        <motion.div
          className="hero__bar"
          aria-hidden="true"
          initial={{ scaleX: 0 }}
          animate={{ scaleX: 1 }}
          transition={{ duration: 1, delay: 0.5 }}
        />

        <div className="container hero__inner">
          {/* Location badge */}
          <motion.div
            className="hero__badge"
            initial={{ opacity: 0, scale: 0.8 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ duration: 0.5 }}
            whileHover={{ scale: 1.05 }}
          >
            {h.badge}
          </motion.div>

          {/* Headline */}
          <motion.h1
            className="hero__title"
            initial={{ opacity: 0, y: 50 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.2 }}
          >
            <Logo />
            <br />
            <motion.span
              className="hero__tagline"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              transition={{ duration: 0.6, delay: 0.6 }}
            >
              {h.tagline}
            </motion.span>
          </motion.h1>

          {/* Subtitle */}
          <motion.p
            className="hero__sub"
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, delay: 0.4 }}
          >
            {h.sub}
          </motion.p>

          {/* CTAs */}
          <motion.div
            className="hero__actions"
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, delay: 0.6 }}
          >
            {/* For businesses */}
            <motion.button
              className="btn btn--primary btn--hero"
              onClick={() => go('register')}
              whileHover={{ scale: 1.05, y: -3 }}
              whileTap={{ scale: 0.95 }}
            >
              {h.cta1}
            </motion.button>

            {/* Download the app */}
            <motion.button
              className="btn btn--ghost btn--hero"
              onClick={() => setModal(true)}
              whileHover={{ scale: 1.05, y: -2 }}
              whileTap={{ scale: 0.95 }}
            >
              {h.cta2}
            </motion.button>
          </motion.div>
        </div>

        {/* Stats bar */}
        <motion.div
          className="hero__stats"
          initial={{ opacity: 0, y: 50 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.8 }}
        >
          <div className="container hero__stats-inner">
            {stats.map((s, i) => (
              <motion.div
                className="stat"
                key={s.label}
                initial={{ opacity: 0, scale: 0.8 }}
                animate={{ opacity: 1, scale: 1 }}
                transition={{ duration: 0.5, delay: 1 + i * 0.1 }}
                whileHover={{ scale: 1.05, y: -5 }}
              >
                <motion.span
                  className="stat__value"
                  initial={{ scale: 0 }}
                  animate={{ scale: 1 }}
                  transition={{ type: 'spring', stiffness: 200, delay: 1.1 + i * 0.1 }}
                >
                  {s.value}
                </motion.span>
                <span className="stat__label">{s.label}</span>
              </motion.div>
            ))}
          </div>
        </motion.div>
      </section>

      <AppDownloadModal open={modal} onClose={() => setModal(false)} />
    </>
  )
}

export default Hero
