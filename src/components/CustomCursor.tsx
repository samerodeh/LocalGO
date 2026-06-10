import React, { useEffect, useState, useRef } from 'react'
import { motion, useMotionValue, useSpring } from 'framer-motion'

const CustomCursor: React.FC = () => {
  const [isHovering, setIsHovering] = useState(false)
  const [isClicking, setIsClicking] = useState(false)
  const [hidden, setHidden] = useState(true)
  const [isTouchDevice] = useState(() =>
    typeof window !== 'undefined' && window.matchMedia('(pointer: coarse)').matches
  )
  const observerRef = useRef<MutationObserver | null>(null)

  const rawX = useMotionValue(-200)
  const rawY = useMotionValue(-200)

  const dotX = useSpring(rawX, { damping: 35, stiffness: 400, mass: 0.3 })
  const dotY = useSpring(rawY, { damping: 35, stiffness: 400, mass: 0.3 })
  const ringX = useSpring(rawX, { damping: 22, stiffness: 120, mass: 0.5 })
  const ringY = useSpring(rawY, { damping: 22, stiffness: 120, mass: 0.5 })

  useEffect(() => {
    if (isTouchDevice) return

    const onMove = (e: MouseEvent) => {
      setHidden(false)
      rawX.set(e.clientX)
      rawY.set(e.clientY)
    }
    const onDown  = () => setIsClicking(true)
    const onUp    = () => setIsClicking(false)
    const onLeave = () => setHidden(true)
    const onEnter = () => setHidden(false)

    const attachHovers = () => {
      document.querySelectorAll<Element>('button, a, [data-hover], input, select, textarea, label').forEach(el => {
        el.addEventListener('mouseenter', () => setIsHovering(true))
        el.addEventListener('mouseleave', () => setIsHovering(false))
      })
    }

    window.addEventListener('mousemove', onMove)
    window.addEventListener('mousedown', onDown)
    window.addEventListener('mouseup',   onUp)
    document.addEventListener('mouseleave', onLeave)
    document.addEventListener('mouseenter', onEnter)
    attachHovers()

    observerRef.current = new MutationObserver(attachHovers)
    observerRef.current.observe(document.body, { childList: true, subtree: true })

    return () => {
      window.removeEventListener('mousemove', onMove)
      window.removeEventListener('mousedown', onDown)
      window.removeEventListener('mouseup',   onUp)
      document.removeEventListener('mouseleave', onLeave)
      document.removeEventListener('mouseenter', onEnter)
      observerRef.current?.disconnect()
    }
  }, [isTouchDevice, rawX, rawY])

  if (isTouchDevice) return null

  return (
    <>
      <motion.div
        className="cursor-dot"
        style={{ x: dotX, y: dotY, translateX: '-50%', translateY: '-50%' }}
        initial={{ opacity: 0 }}
        animate={{
          opacity: hidden ? 0 : 1,
          scale: isClicking ? 0.5 : isHovering ? 0 : 1,
        }}
        transition={{ scale: { type: 'spring', stiffness: 500, damping: 25 }, opacity: { duration: 0.15 } }}
      />
      <motion.div
        className="cursor-ring"
        style={{ x: ringX, y: ringY, translateX: '-50%', translateY: '-50%' }}
        initial={{ opacity: 0 }}
        animate={{
          opacity: hidden ? 0 : 1,
          scale: isClicking ? 0.75 : isHovering ? 1.6 : 1,
          borderColor: isHovering ? 'rgba(249,115,22,0.9)' : 'rgba(249,115,22,0.45)',
          backgroundColor: isHovering ? 'rgba(249,115,22,0.08)' : 'transparent',
        }}
        transition={{ scale: { type: 'spring', stiffness: 220, damping: 18 }, opacity: { duration: 0.15 } }}
      />
    </>
  )
}

export default CustomCursor
