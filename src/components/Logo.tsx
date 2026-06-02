/**
 * Logo
 *
 * The LocalGo wordmark: "Local" in white, "Go" in brand orange.
 * Clicking navigates back to the home page.
 *
 * Props:
 *   dark — renders "Local" in navy instead of white (used on light backgrounds)
 */

import React from 'react'
import { motion } from 'framer-motion'
import { useRouter } from '../context/RouterContext'

interface LogoProps {
  dark?: boolean
}

const Logo: React.FC<LogoProps> = ({ dark = false }) => {
  const { go } = useRouter()

  return (
    <motion.span
      className={`logo ${dark ? 'logo--dark' : ''}`}
      whileHover={{ scale: 1.05 }}
      transition={{ type: 'spring', stiffness: 400, damping: 10 }}
      onClick={() => go('home')}
      style={{ cursor: 'pointer' }}
    >
      {/* "Local" — white on dark, navy on light */}
      <motion.span
        className="logo__local"
        initial={{ opacity: 0, x: -20 }}
        animate={{ opacity: 1, x: 0 }}
        transition={{ duration: 0.5 }}
      >
        Local
      </motion.span>

      {/* "Go" — always brand orange */}
      <motion.span
        className="logo__go"
        initial={{ opacity: 0, x: 20 }}
        animate={{ opacity: 1, x: 0 }}
        transition={{ duration: 0.5, delay: 0.1 }}
      >
        Go
      </motion.span>
    </motion.span>
  )
}

export default Logo
