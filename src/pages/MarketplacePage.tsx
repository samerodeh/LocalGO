/**
 * Marketplace Page
 *
 * Displays all partner restaurants and shops as filterable cards.
 * "Browse & Order" opens the AppDownloadModal — the ordering happens
 * in the separate LocalGo mobile app, not on this website.
 *
 * All UI text is translated via LanguageContext (EN / FR / AR).
 */

import React, { useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { useRouter } from '../context/RouterContext'
import { useLang } from '../context/LanguageContext'
import { IconZap } from '../icons'
import AppDownloadModal from '../components/AppDownloadModal'

// ─── Partner data ─────────────────────────────────────────────────────────

/** Raw partner data — category keys match English filter labels */
const partnerData = [
  { initials: 'PC', color: '#c0392b', name: 'Pizza Concordia',     category: 'Restaurant',       cuisine: 'Italian · Pizza',               status: 'open'   as const, delivery: '20–30 min' },
  { initials: 'LM', color: '#27ae60', name: 'Le Marché Local',     category: 'Grocery / Market', cuisine: 'Fresh Produce · Deli',           status: 'open'   as const, delivery: '25–35 min' },
  { initials: 'CC', color: '#8e44ad', name: 'Café Concordia',      category: 'Bakery / Café',    cuisine: 'Coffee · Pastries',              status: 'open'   as const, delivery: '15–25 min' },
  { initials: 'SM', color: '#2980b9', name: 'Sushi Montréal',      category: 'Restaurant',       cuisine: 'Japanese · Sushi',               status: 'busy'   as const, delivery: '35–45 min' },
  { initials: 'FG', color: '#16a085', name: 'Fresh Greens',        category: 'Grocery / Market', cuisine: 'Organic · Healthy',              status: 'open'   as const, delivery: '20–30 min' },
  { initials: 'BD', color: '#d35400', name: 'Boulangerie du Coin', category: 'Bakery / Café',    cuisine: 'Artisan Bread · Viennoiserie',   status: 'open'   as const, delivery: '25–35 min' },
  { initials: 'FQ', color: '#e91e8c', name: 'Fleurs du Quartier',  category: 'Specialty Store',  cuisine: 'Flowers · Gifts',                status: 'coming' as const, delivery: '' },
  { initials: 'DE', color: '#f39c12', name: 'Dépanneur Express',   category: 'Grocery / Market', cuisine: 'Snacks · Beverages · Essentials', status: 'open'   as const, delivery: '15–25 min' },
  { initials: 'TM', color: '#1abc9c', name: 'Taco Montréal',       category: 'Restaurant',       cuisine: 'Mexican · Street Food',          status: 'coming' as const, delivery: '' },
]

// ─── Component ────────────────────────────────────────────────────────────

const MarketplacePage: React.FC = () => {
  const { go }              = useRouter()
  const { T }               = useLang()
  const m                   = T.marketplace
  const [filterIdx, setFilterIdx] = useState(0)
  const [modal, setModal]   = useState(false)

  /** Filters are translated; index 0 = "All" equivalent in any language */
  const filtered = filterIdx === 0
    ? partnerData
    : partnerData.filter(p => {
        const englishFilters = ['All', 'Restaurant', 'Grocery / Market', 'Bakery / Café', 'Specialty Store']
        return p.category === englishFilters[filterIdx]
      })

  const statusLabel = (s: 'open' | 'busy' | 'coming') =>
    s === 'open' ? m.statusOpen : s === 'busy' ? m.statusBusy : m.statusComing

  const count = filtered.length
  const countLabel = `${count} ${count === 1 ? m.partnerSingular : m.partnerPlural}`

  return (
    <>
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
              {m.eyebrow}
            </motion.span>
            <motion.h1 className="page-hero__title" initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.2 }}>
              {m.title.split('\n').map((line, i) => (
                <span key={i}>{line}{i === 0 && <br />}</span>
              ))}
            </motion.h1>
            <motion.p className="page-hero__sub" initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.3 }}>
              {m.sub}
            </motion.p>
          </div>
        </div>

        {/* ── Sticky filter bar ── */}
        <div className="marketplace-bar">
          <div className="container marketplace-bar__inner">
            <div className="mkt-filters">
              {m.filters.map((label, idx) => (
                <motion.button
                  key={label}
                  className={`mkt-filter ${filterIdx === idx ? 'mkt-filter--active' : ''}`}
                  onClick={() => setFilterIdx(idx)}
                  whileHover={{ scale: 1.03 }}
                  whileTap={{ scale: 0.97 }}
                >
                  {label}
                </motion.button>
              ))}
            </div>
            <p className="mkt-count">{countLabel}</p>
          </div>
        </div>

        {/* ── Partner card grid ── */}
        <div className="marketplace-body">
          <div className="container">
            <div className="partners-grid">
              <AnimatePresence mode="popLayout">
                {filtered.map((p, i) => (
                  <motion.div
                    className={`partner-card ${p.status === 'coming' ? 'partner-card--coming' : ''}`}
                    key={p.name}
                    layout
                    initial={{ opacity: 0, scale: 0.95 }}
                    animate={{ opacity: 1, scale: 1 }}
                    exit={{ opacity: 0, scale: 0.95 }}
                    transition={{ duration: 0.3, delay: i * 0.04 }}
                    whileHover={p.status !== 'coming' ? { y: -6, transition: { duration: 0.2 } } : {}}
                  >
                    {/* Logo + status */}
                    <div className="partner-card__top">
                      <div className="partner-logo" style={{ background: p.color }}>
                        <span>{p.initials}</span>
                      </div>
                      <span className={`partner-status partner-status--${p.status}`}>
                        {statusLabel(p.status)}
                      </span>
                    </div>

                    {/* Business info */}
                    <div className="partner-card__body">
                      <span className="partner-category">{p.category}</span>
                      <h3 className="partner-name">{p.name}</h3>
                      {p.cuisine && <p className="partner-cuisine">{p.cuisine}</p>}
                    </div>

                    {/* Delivery time + action */}
                    <div className="partner-card__footer">
                      <div className="partner-delivery">
                        <IconZap />
                        <span>{p.status === 'coming' ? m.launchingSoon : p.delivery}</span>
                      </div>
                      {p.status !== 'coming' ? (
                        <motion.button
                          className="btn btn--primary partner-btn"
                          onClick={() => setModal(true)}
                          whileHover={{ scale: 1.04 }}
                          whileTap={{ scale: 0.96 }}
                        >
                          {m.browseBtn}
                        </motion.button>
                      ) : (
                        <span className="partner-soon">{m.launchingSoon}</span>
                      )}
                    </div>
                  </motion.div>
                ))}
              </AnimatePresence>
            </div>

            {/* ── Bottom register CTA ── */}
            <motion.div
              className="mkt-register-cta"
              initial={{ opacity: 0, y: 30 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.6 }}
            >
              <div className="mkt-register-cta__text">
                <h3>{m.ctaH3}</h3>
                <p>{m.ctaP}</p>
              </div>
              <motion.button
                className="btn btn--primary"
                onClick={() => go('register')}
                whileHover={{ scale: 1.05, y: -2 }}
                whileTap={{ scale: 0.95 }}
              >
                {m.ctaBtn}
              </motion.button>
            </motion.div>
          </div>
        </div>
      </motion.div>

      <AppDownloadModal open={modal} onClose={() => setModal(false)} />
    </>
  )
}

export default MarketplacePage
