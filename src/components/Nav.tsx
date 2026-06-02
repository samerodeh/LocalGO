/**
 * Nav
 *
 * Fixed top navigation bar with:
 * - LocalGo logo (links home)
 * - "Back to Home" button on sub-pages
 * - Anchor links for homepage sections (translated)
 * - Language switcher: EN | FR | عربي
 * - "Download the App" CTA → opens AppDownloadModal
 * - "List Your Business" CTA → Register page
 * - Hamburger menu on mobile
 */

import React, { useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { useRouter } from '../context/RouterContext'
import { useLang } from '../context/LanguageContext'
import { Lang } from '../i18n/translations'
import { IconArrowLeft } from '../icons'
import Logo from './Logo'
import AppDownloadModal from './AppDownloadModal'

const LANGS: { code: Lang; label: string }[] = [
  { code: 'en', label: 'EN'    },
  { code: 'fr', label: 'FR'    },
  { code: 'ar', label: 'عربي'  },
]

const Nav: React.FC = () => {
  const [menuOpen, setMenuOpen]   = useState(false)
  const [modalOpen, setModalOpen] = useState(false)
  const { page, go }              = useRouter()
  const { lang, setLang, T }      = useLang()

  const closeMenu = () => setMenuOpen(false)

  /** Section anchor hrefs are always in English — IDs are language-agnostic */
  const sectionLinks = [
    { label: T.nav.about,      href: '#about'       },
    { label: T.nav.howItWorks, href: '#howitworks'  },
    { label: T.nav.features,   href: '#features'    },
  ]

  return (
    <>
      <motion.header
        className="nav"
        initial={{ y: -100 }}
        animate={{ y: 0 }}
        transition={{ type: 'spring', stiffness: 100, damping: 20 }}
      >
        <div className="container nav__inner">
          <Logo />

          {/* Back button — only shown on sub-pages */}
          {page !== 'home' && (
            <motion.button
              className="nav__back"
              onClick={() => go('home')}
              initial={{ opacity: 0, x: -10 }}
              animate={{ opacity: 1, x: 0 }}
            >
              <IconArrowLeft /> {T.nav.backHome}
            </motion.button>
          )}

          {/* Mobile hamburger */}
          <button
            className="nav__hamburger"
            aria-label="Toggle menu"
            onClick={() => setMenuOpen(v => !v)}
          >
            <span className={`hamburger-icon ${menuOpen ? 'open' : ''}`} />
          </button>

          {/* Desktop & mobile nav */}
          <AnimatePresence>
            <motion.nav
              className={`nav__links ${menuOpen ? 'nav__links--open' : ''}`}
              initial={false}
              animate={{ opacity: 1 }}
            >
              {/* Section anchors — home page only */}
              {page === 'home' && sectionLinks.map((item, i) => (
                <motion.a
                  key={item.href}
                  href={item.href}
                  onClick={closeMenu}
                  initial={{ opacity: 0, y: -20 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: i * 0.1 }}
                  whileHover={{ y: -2 }}
                >
                  {item.label}
                </motion.a>
              ))}

              {/* Language switcher */}
              <div className="lang-switcher">
                {LANGS.map(l => (
                  <button
                    key={l.code}
                    className={`lang-btn ${lang === l.code ? 'lang-btn--active' : ''}`}
                    onClick={() => { setLang(l.code); closeMenu() }}
                  >
                    {l.label}
                  </button>
                ))}
              </div>

              {/* Primary CTA — Download App */}
              <motion.button
                className="nav__cta"
                onClick={() => { setModalOpen(true); closeMenu() }}
                initial={{ opacity: 0, scale: 0.9 }}
                animate={{ opacity: 1, scale: 1 }}
                transition={{ delay: 0.2 }}
                whileHover={{ scale: 1.05 }}
                whileTap={{ scale: 0.95 }}
              >
                {T.nav.downloadApp}
              </motion.button>

              {/* Secondary CTA — Register */}
              <motion.button
                className="nav__cta nav__cta--outline"
                onClick={() => { go('register'); closeMenu() }}
                initial={{ opacity: 0, scale: 0.9 }}
                animate={{ opacity: 1, scale: 1 }}
                transition={{ delay: 0.3 }}
                whileHover={{ scale: 1.05 }}
                whileTap={{ scale: 0.95 }}
              >
                {T.nav.listBusiness}
              </motion.button>
            </motion.nav>
          </AnimatePresence>
        </div>
      </motion.header>

      {/* App download modal */}
      <AppDownloadModal open={modalOpen} onClose={() => setModalOpen(false)} />
    </>
  )
}

export default Nav
