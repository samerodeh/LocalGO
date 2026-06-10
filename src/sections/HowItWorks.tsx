/**
 * How It Works Section
 *
 * Three numbered step cards explaining the customer ordering flow.
 * All text is translated via LanguageContext.
 * Steps animate in with a spring effect as they enter the viewport.
 */

import React, { lazy, Suspense } from 'react'
import { motion } from 'framer-motion'
import { useLang } from '../context/LanguageContext'

const DeliveryScene = lazy(() => import('../components/three/DeliveryScene'))

const HowItWorks: React.FC = () => {
  const { T } = useLang()
  const h     = T.how

  const steps = [
    { n: '01', title: h.s1title, body: h.s1body },
    { n: '02', title: h.s2title, body: h.s2body },
    { n: '03', title: h.s3title, body: h.s3body },
  ]

  return (
    <motion.section
      className="how section"
      id="howitworks"
      initial={{ opacity: 0 }}
      whileInView={{ opacity: 1 }}
      viewport={{ once: true, margin: '-100px' }}
      transition={{ duration: 0.8 }}
    >
      <div className="container">
        <motion.div
          className="section-header"
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6 }}
        >
          <span className="eyebrow">{h.eyebrow}</span>
          <h2 className="section-title">
            {h.title.split('\n').map((line, i) => (
              <span key={i}>{line}{i === 0 && <br />}</span>
            ))}
          </h2>
        </motion.div>

        {/* 3D delivery scene */}
        <motion.div
          className="how__3d"
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.8, delay: 0.1 }}
          aria-hidden="true"
        >
          <div className="how__3d-hint">Drag to explore</div>
          <Suspense fallback={<div className="how__3d-fallback" />}>
            <DeliveryScene />
          </Suspense>
        </motion.div>

        <div className="steps">
          {steps.map((s, i) => (
            <motion.div
              className="step"
              key={s.n}
              initial={{ opacity: 0, y: 80, rotateX: -15 }}
              whileInView={{ opacity: 1, y: 0, rotateX: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.6, delay: i * 0.2, type: 'spring', stiffness: 100 }}
              whileHover={{ y: -12, scale: 1.02, transition: { duration: 0.3 } }}
              style={{ transformStyle: 'preserve-3d', perspective: 1000 }}
            >
              <motion.div
                className="step__number"
                initial={{ scale: 0 }}
                whileInView={{ scale: 1 }}
                viewport={{ once: true }}
                transition={{ type: 'spring', stiffness: 200, delay: i * 0.2 + 0.3 }}
              >
                {s.n}
              </motion.div>
              <h3 className="step__title">{s.title}</h3>
              <p className="step__body">{s.body}</p>
            </motion.div>
          ))}
        </div>
      </div>
    </motion.section>
  )
}

export default HowItWorks
