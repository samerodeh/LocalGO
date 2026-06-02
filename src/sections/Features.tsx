/**
 * Features Section
 *
 * Dark-background grid showcasing six platform capabilities.
 * All text is translated via LanguageContext.
 * Cards animate in with a slight 3-D Y-rotation as they enter the viewport.
 */

import React from 'react'
import { motion } from 'framer-motion'
import { useLang } from '../context/LanguageContext'
import {
  IconMapPin,
  IconZap,
  IconTrendingUp,
  IconShoppingBag,
  IconBarChart,
  IconHeadphones,
} from '../icons'

const ICONS = [IconMapPin, IconZap, IconTrendingUp, IconShoppingBag, IconBarChart, IconHeadphones]

const Features: React.FC = () => {
  const { T } = useLang()
  const f     = T.features

  return (
    <motion.section
      className="features section"
      id="features"
      initial={{ opacity: 0 }}
      whileInView={{ opacity: 1 }}
      viewport={{ once: true, margin: '-100px' }}
      transition={{ duration: 0.8 }}
    >
      <div className="container">
        <motion.div
          className="section-header section-header--light"
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6 }}
        >
          <span className="eyebrow eyebrow--light">{f.eyebrow}</span>
          <h2 className="section-title section-title--light">{f.title}</h2>
        </motion.div>

        <div className="features__grid">
          {f.items.map((item, i) => {
            const Icon = ICONS[i]
            return (
              <motion.div
                className="feature-card"
                key={item.title}
                initial={{ opacity: 0, y: 80, rotateY: -15 }}
                whileInView={{ opacity: 1, y: 0, rotateY: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.6, delay: i * 0.1, type: 'spring', stiffness: 100 }}
                whileHover={{ y: -10, scale: 1.03, transition: { duration: 0.3 } }}
                style={{ transformStyle: 'preserve-3d', perspective: 1000 }}
              >
                <span className="feature-card__icon"><Icon /></span>
                <h3 className="feature-card__title">{item.title}</h3>
                <p className="feature-card__body">{item.body}</p>
              </motion.div>
            )
          })}
        </div>
      </div>
    </motion.section>
  )
}

export default Features
