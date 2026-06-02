/**
 * App — Root Component
 *
 * Responsibilities:
 * 1. Owns the router state (current page + navigate function)
 * 2. Wraps the tree with RouterCtx and LanguageProvider
 * 3. Renders Nav + animated page switcher + Footer
 *
 * Language / RTL:
 *   LanguageProvider owns lang state and syncs html[dir] + html[lang].
 *   All components read translations via useLang().
 *
 * File structure:
 *   src/
 *   ├── context/RouterContext.tsx    — Page type, RouterCtx, useRouter
 *   ├── context/LanguageContext.tsx  — Lang type, LanguageProvider, useLang
 *   ├── i18n/translations.ts        — EN / FR / AR string tables
 *   ├── icons/index.tsx             — All inline SVG icons
 *   ├── components/
 *   │   ├── AppDownloadModal.tsx    — App Store / Play Store modal
 *   │   ├── Logo.tsx
 *   │   ├── Nav.tsx                 — Language switcher + Download CTA
 *   │   └── Footer.tsx
 *   ├── sections/                   — Homepage sections
 *   ├── pages/                      — Full page components
 *   ├── App.tsx                     ← you are here
 *   ├── App.css                     — All styles (+ RTL overrides at bottom)
 *   └── index.css                   — Design tokens + CSS reset
 */

import { useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'

import { RouterCtx, Page }       from './context/RouterContext'
import { LanguageProvider }      from './context/LanguageContext'
import Nav                       from './components/Nav'
import Footer                    from './components/Footer'
import HomePage                  from './pages/HomePage'
import MarketplacePage           from './pages/MarketplacePage'
import RegisterPage              from './pages/RegisterPage'

import './App.css'

export default function App() {
  const [page, setPage] = useState<Page>('home')

  const go = (p: Page) => {
    setPage(p)
    window.scrollTo({ top: 0, behavior: 'smooth' })
  }

  return (
    <LanguageProvider>
      <RouterCtx.Provider value={{ page, go }}>
        <Nav />
        <main>
          <AnimatePresence mode="wait">
            {page === 'home'        && <motion.div key="home">        <HomePage />        </motion.div>}
            {page === 'marketplace' && <motion.div key="marketplace"> <MarketplacePage /> </motion.div>}
            {page === 'register'    && <motion.div key="register">    <RegisterPage />    </motion.div>}
          </AnimatePresence>
        </main>
        <Footer />
      </RouterCtx.Provider>
    </LanguageProvider>
  )
}
