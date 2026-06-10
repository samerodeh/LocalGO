/**
 * Footer
 *
 * Site-wide footer containing:
 * - Brand / tagline column (translated)
 * - Navigation links (translated)
 * - Contact details
 * - Bottom bar with pricing summary and copyright (translated)
 */

import React from 'react'
import { motion } from 'framer-motion'
import { useRouter } from '../context/RouterContext'
import { useLang } from '../context/LanguageContext'
import Logo from './Logo'

const Footer: React.FC = () => {
  const { go }   = useRouter()
  const { T }    = useLang()
  const f        = T.footer

  return (
    <motion.footer
      className="footer"
      initial={{ opacity: 0 }}
      whileInView={{ opacity: 1 }}
      viewport={{ once: true }}
      transition={{ duration: 0.8 }}
    >
      <div className="container footer__inner">

        {/* Brand */}
        <motion.div
          className="footer__brand"
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6 }}
        >
          <Logo />
          <p className="footer__desc">{f.tagline}</p>
          <span className="footer__badge">
            <span className="footer__badge-dot" />
            {f.location}
          </span>
        </motion.div>

        {/* Nav links */}
        <motion.div
          className="footer__col"
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6, delay: 0.1 }}
        >
          <p className="footer__col-heading">Navigation</p>
          <div className="footer__links">
            <motion.a href="#about"      whileHover={{ x: 4 }} transition={{ duration: 0.2 }}>{f.linkAbout}</motion.a>
            <motion.a href="#howitworks" whileHover={{ x: 4 }} transition={{ duration: 0.2 }}>{f.linkHow}</motion.a>
            <motion.a href="#features"   whileHover={{ x: 4 }} transition={{ duration: 0.2 }}>{f.linkFeatures}</motion.a>
            <motion.a onClick={() => go('marketplace')} style={{ cursor: 'pointer' }} whileHover={{ x: 4 }} transition={{ duration: 0.2 }}>
              {f.linkMarketplace}
            </motion.a>
            <motion.a onClick={() => go('register')} style={{ cursor: 'pointer' }} whileHover={{ x: 4 }} transition={{ duration: 0.2 }}>
              {f.linkRegister}
            </motion.a>
          </div>
        </motion.div>

        {/* Contact details */}
        <motion.div
          className="footer__col"
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6, delay: 0.2 }}
        >
          <p className="footer__col-heading">Contact</p>
          <div className="footer__contact">
            <div className="footer__contact-item">
              <span className="footer__contact-label">T</span>
              <span>514.555.0199</span>
            </div>
            <div className="footer__contact-item">
              <span className="footer__contact-label">E</span>
              <span>samerodeh.dev@gmail.com</span>
            </div>
            <div className="footer__contact-item">
              <span className="footer__contact-label">W</span>
              <span>samerodeh.dev</span>
            </div>
          </div>
        </motion.div>

      </div>

      {/* Bottom bar */}
      <motion.div
        className="footer__bottom"
        initial={{ opacity: 0 }}
        whileInView={{ opacity: 1 }}
        viewport={{ once: true }}
        transition={{ duration: 0.6, delay: 0.3 }}
      >
        <div className="container footer__bottom-inner">
          <div className="footer__bottom-left">
            <span className="footer__bottom-dot" />
            <span>{f.pricing}</span>
          </div>
          <span>&copy; {new Date().getFullYear()} {f.copyright}</span>
        </div>
      </motion.div>
    </motion.footer>
  )
}

export default Footer
