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
      {/* Decorative orange diagonal bar */}
      <motion.div
        className="footer__bar"
        aria-hidden="true"
        initial={{ scaleX: 0 }}
        whileInView={{ scaleX: 1 }}
        viewport={{ once: true }}
        transition={{ duration: 1 }}
      />

      <div className="container footer__inner">
        {/* Brand */}
        <motion.div
          className="footer__brand"
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6 }}
        >
          <Logo />
          <p className="footer__sub">{f.tagline}</p>
          <p className="footer__location">{f.location}</p>
        </motion.div>

        {/* Nav links */}
        <motion.div
          className="footer__links"
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6, delay: 0.1 }}
        >
          <motion.a href="#about"      whileHover={{ x: 4 }} transition={{ duration: 0.2 }}>{f.linkAbout}</motion.a>
          <motion.a href="#howitworks" whileHover={{ x: 4 }} transition={{ duration: 0.2 }}>{f.linkHow}</motion.a>
          <motion.a href="#features"   whileHover={{ x: 4 }} transition={{ duration: 0.2 }}>{f.linkFeatures}</motion.a>
          <motion.a onClick={() => go('marketplace')} style={{ cursor: 'pointer' }} whileHover={{ x: 4 }} transition={{ duration: 0.2 }}>
            {f.linkMarketplace}
          </motion.a>
          <motion.a onClick={() => go('register')} style={{ cursor: 'pointer' }} whileHover={{ x: 4 }} transition={{ duration: 0.2 }}>
            {f.linkRegister}
          </motion.a>
        </motion.div>

        {/* Contact details */}
        <motion.div
          className="footer__contact"
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6, delay: 0.2 }}
        >
          <p><strong>T</strong> 514.555.0199</p>
          <p><strong>E</strong> hello@localgo.ca</p>
          <p><strong>W</strong> www.localgo.ca</p>
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
        <div className="container">
          <span>{f.pricing}</span>
          <span>&copy; {new Date().getFullYear()} {f.copyright}</span>
        </div>
      </motion.div>
    </motion.footer>
  )
}

export default Footer
