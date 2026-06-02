/**
 * Home Page
 *
 * Assembles all homepage sections in order:
 *   Hero → About → HowItWorks → Comparison → Features → Contact
 */

import React from 'react'
import Hero        from '../sections/Hero'
import About       from '../sections/About'
import HowItWorks  from '../sections/HowItWorks'
import Comparison  from '../sections/Comparison'
import Features    from '../sections/Features'
import Contact     from '../sections/Contact'

const HomePage: React.FC = () => (
  <>
    <Hero />
    <About />
    <HowItWorks />
    <Comparison />
    <Features />
    <Contact />
  </>
)

export default HomePage
