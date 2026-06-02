/**
 * Comparison Section — "Why LocalGo?"
 *
 * Side-by-side comparison of big platforms vs LocalGo.
 * All copy is translated via LanguageContext.
 *
 * CTA "Download the App" opens the AppDownloadModal;
 * CTA "Register Your Business" navigates to the register page.
 */

import React, { useState } from 'react'
import { motion } from 'framer-motion'
import { useRouter } from '../context/RouterContext'
import { useLang } from '../context/LanguageContext'
import { IconCheck, IconX } from '../icons'
import AppDownloadModal from '../components/AppDownloadModal'

const Comparison: React.FC = () => {
  const { go }            = useRouter()
  const { T }             = useLang()
  const c                 = T.comparison
  const [modal, setModal] = useState(false)

  return (
    <>
      <motion.section
        className="comparison section"
        id="comparison"
        initial={{ opacity: 0 }}
        whileInView={{ opacity: 1 }}
        viewport={{ once: true, margin: '-100px' }}
        transition={{ duration: 0.8 }}
      >
        <div className="container">
          {/* Section header */}
          <motion.div
            className="section-header section-header--light"
            initial={{ opacity: 0, y: 30 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.6 }}
          >
            <span className="eyebrow eyebrow--light">{c.eyebrow}</span>
            <h2 className="section-title section-title--light">
              {c.title.split('\n').map((line, i) => (
                <span key={i}>{line}{i === 0 && <br />}</span>
              ))}
            </h2>
            <p className="comparison__intro">{c.intro}</p>
          </motion.div>

          {/* Two-column comparison cards */}
          <div className="comparison__grid">
            {/* ── Big Platforms (red accent, X bullets) ── */}
            <motion.div
              className="cmp-card cmp-card--bad"
              initial={{ opacity: 0, x: -40 }}
              whileInView={{ opacity: 1, x: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.6 }}
              whileHover={{ y: -4 }}
            >
              <div className="cmp-card__header">
                <span className="cmp-card__label">{c.badLabel}</span>
              </div>
              <ul className="cmp-card__list">
                {c.bad.map(item => (
                  <li key={item} className="cmp-item cmp-item--bad">
                    <span className="cmp-item__icon"><IconX /></span>
                    <span>{item}</span>
                  </li>
                ))}
              </ul>
              <div className="cmp-card__summary cmp-card__summary--bad">
                {c.badSummary}
              </div>
            </motion.div>

            {/* ── LocalGo (orange accent, check bullets) ── */}
            <motion.div
              className="cmp-card cmp-card--good"
              initial={{ opacity: 0, x: 40 }}
              whileInView={{ opacity: 1, x: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.6, delay: 0.1 }}
              whileHover={{ y: -4 }}
            >
              <div className="cmp-card__header">
                <span className="cmp-card__label">{c.goodLabel}</span>
                <span className="cmp-card__badge">{c.goodBadge}</span>
              </div>
              <ul className="cmp-card__list">
                {c.good.map(item => (
                  <li key={item} className="cmp-item cmp-item--good">
                    <span className="cmp-item__icon"><IconCheck /></span>
                    <span>{item}</span>
                  </li>
                ))}
              </ul>
              <div className="cmp-card__summary cmp-card__summary--good">
                {c.goodSummary}
              </div>
            </motion.div>
          </div>

          {/* CTA row */}
          <motion.div
            className="comparison__cta"
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.5, delay: 0.3 }}
          >
            <motion.button
              className="btn btn--primary"
              onClick={() => setModal(true)}
              whileHover={{ scale: 1.05, y: -3 }}
              whileTap={{ scale: 0.95 }}
            >
              {c.cta1}
            </motion.button>
            <motion.button
              className="btn btn--ghost btn--outline-light"
              onClick={() => go('register')}
              whileHover={{ scale: 1.05, y: -2 }}
              whileTap={{ scale: 0.95 }}
            >
              {c.cta2}
            </motion.button>
          </motion.div>
        </div>
      </motion.section>

      <AppDownloadModal open={modal} onClose={() => setModal(false)} />
    </>
  )
}

export default Comparison
