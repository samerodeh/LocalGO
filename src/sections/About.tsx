/**
 * About Section
 *
 * Two-column layout:
 * - Left: heading, body copy, and "Join Our Network" CTA (all translated)
 * - Right: three value-proposition cards (translated titles and bodies)
 */

import React from 'react'
import { motion } from 'framer-motion'
import { useRouter } from '../context/RouterContext'
import { useLang } from '../context/LanguageContext'
import { IconStore, IconRoute, IconLayers } from '../icons'

const About: React.FC = () => {
  const { go } = useRouter()
  const { T }  = useLang()
  const a      = T.about

  const cards = [
    { Icon: IconStore,  title: a.card1title, body: a.card1body },
    { Icon: IconRoute,  title: a.card2title, body: a.card2body },
    { Icon: IconLayers, title: a.card3title, body: a.card3body },
  ]

  return (
    <motion.section
      className="about section"
      id="about"
      initial={{ opacity: 0 }}
      whileInView={{ opacity: 1 }}
      viewport={{ once: true, margin: '-100px' }}
      transition={{ duration: 0.8 }}
    >
      <div className="container about__inner">
        {/* Left — text content */}
        <motion.div
          className="about__text"
          initial={{ opacity: 0, x: -50 }}
          whileInView={{ opacity: 1, x: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6 }}
        >
          <span className="eyebrow">{a.eyebrow}</span>
          <h2 className="section-title">
            {a.title.split('\n').map((line, i) => (
              <span key={i}>{line}{i === 0 && <br />}</span>
            ))}
          </h2>
          <p>{a.p1}</p>
          <p>{a.p2}</p>

          <motion.button
            className="btn btn--primary"
            style={{ marginTop: '2rem' }}
            onClick={() => go('register')}
            whileHover={{ scale: 1.05, y: -3 }}
            whileTap={{ scale: 0.95 }}
          >
            {a.cta}
          </motion.button>
        </motion.div>

        {/* Right — value proposition cards */}
        <div className="about__cards">
          {cards.map((c, i) => (
            <motion.div
              className="about-card"
              key={c.title}
              initial={{ opacity: 0, y: 50 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.5, delay: i * 0.15 }}
              whileHover={{ y: -8, x: 4 }}
            >
              <span className="about-card__icon"><c.Icon /></span>
              <h3 className="about-card__title">{c.title}</h3>
              <p className="about-card__body">{c.body}</p>
            </motion.div>
          ))}
        </div>
      </div>
    </motion.section>
  )
}

export default About
