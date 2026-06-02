/**
 * AppDownloadModal
 *
 * Full-screen overlay shown when the user clicks "Download the App".
 * Displays an "App Coming Soon" message — store links will be added
 * once the app launches.
 *
 * Translations respect the active language (EN / FR / AR).
 */

import React from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { useLang } from '../context/LanguageContext'

interface Props {
  open:    boolean
  onClose: () => void
}

const AppDownloadModal: React.FC<Props> = ({ open, onClose }) => {
  const { T } = useLang()
  const m = T.modal

  return (
    <AnimatePresence>
      {open && (
        <>
          {/* Backdrop */}
          <motion.div
            className="modal-backdrop"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            transition={{ duration: 0.25 }}
            onClick={onClose}
            aria-hidden="true"
          />

          {/* Panel */}
          <motion.div
            className="modal-panel"
            role="dialog"
            aria-modal="true"
            aria-label={m.title}
            initial={{ opacity: 0, scale: 0.9, y: 20 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.9, y: 20 }}
            transition={{ type: 'spring', stiffness: 300, damping: 28 }}
          >
            {/* Close button */}
            <button className="modal-close" onClick={onClose} aria-label="Close">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" width="20" height="20">
                <path d="M18 6L6 18M6 6l12 12" strokeLinecap="round"/>
              </svg>
            </button>

            {/* Rocket / coming-soon icon */}
            <motion.div
              className="modal-icon"
              animate={{ y: [0, -8, 0] }}
              transition={{ duration: 2.4, repeat: Infinity, ease: 'easeInOut' }}
            >
              <span style={{ fontSize: '2.8rem', lineHeight: 1 }}>🚀</span>
            </motion.div>

            <h2 className="modal-title">{m.title}</h2>
            <p className="modal-sub">{m.comingSoon}</p>
            <p className="modal-note">{m.note}</p>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  )
}

export default AppDownloadModal
