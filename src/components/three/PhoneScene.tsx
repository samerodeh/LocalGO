/**
 * PhoneScene — About section
 * A 3-D phone mockup showing the LocalGo app UI.
 * Screen uses MeshBasicMaterial so it glows regardless of scene lighting.
 * Tilts gently toward the mouse cursor; auto-rotates slowly.
 * Fully interactive — drag to spin.
 */
import React, { useRef, Suspense } from 'react'
import { Canvas, useFrame, useThree } from '@react-three/fiber'
import { Float, OrbitControls, RoundedBox } from '@react-three/drei'
import * as THREE from 'three'

// ── Screen UI planes (MeshBasicMaterial = always visible, like a real screen) ──
const AppScreen: React.FC = () => (
  <group position={[0, 0, 0.068]}>
    {/* Screen background */}
    <mesh>
      <planeGeometry args={[0.98, 1.96]} />
      <meshBasicMaterial color="#0a0f1e" />
    </mesh>

    {/* Status-bar */}
    <mesh position={[0, 0.88, 0.001]}>
      <planeGeometry args={[0.98, 0.055]} />
      <meshBasicMaterial color="#0f172a" />
    </mesh>

    {/* Header / nav bar — orange */}
    <mesh position={[0, 0.76, 0.001]}>
      <planeGeometry args={[0.98, 0.14]} />
      <meshBasicMaterial color="#f97316" />
    </mesh>

    {/* "LocalGo" logo dot on header */}
    <mesh position={[-0.33, 0.76, 0.002]}>
      <circleGeometry args={[0.025, 16]} />
      <meshBasicMaterial color="#ffffff" />
    </mesh>

    {/* Small white text lines on header */}
    <mesh position={[-0.05, 0.76, 0.002]}>
      <planeGeometry args={[0.28, 0.025]} />
      <meshBasicMaterial color="#ffffff" />
    </mesh>
    <mesh position={[-0.08, 0.73, 0.002]}>
      <planeGeometry args={[0.18, 0.016]} />
      <meshBasicMaterial color="rgba(255,255,255,0.6)" transparent opacity={0.6} />
    </mesh>

    {/* Search bar */}
    <mesh position={[0, 0.58, 0.001]}>
      <planeGeometry args={[0.82, 0.09]} />
      <meshBasicMaterial color="#1e293b" />
    </mesh>
    {/* Search icon dot */}
    <mesh position={[-0.28, 0.58, 0.002]}>
      <circleGeometry args={[0.02, 12]} />
      <meshBasicMaterial color="#f97316" />
    </mesh>
    {/* Search text line */}
    <mesh position={[0.04, 0.58, 0.002]}>
      <planeGeometry args={[0.34, 0.022]} />
      <meshBasicMaterial color="#334155" />
    </mesh>

    {/* Category chips */}
    {[-0.28, 0, 0.28].map((x, i) => (
      <mesh key={i} position={[x, 0.44, 0.001]}>
        <planeGeometry args={[0.22, 0.065]} />
        <meshBasicMaterial color={i === 0 ? '#f97316' : '#1e293b'} />
      </mesh>
    ))}
    {/* Chip labels */}
    {[-0.28, 0, 0.28].map((x, i) => (
      <mesh key={`cl${i}`} position={[x, 0.44, 0.002]}>
        <planeGeometry args={[0.12, 0.018]} />
        <meshBasicMaterial color={i === 0 ? '#ffffff' : '#64748b'} />
      </mesh>
    ))}

    {/* Store cards (3 rows) */}
    {[0.27, 0.0, -0.27].map((y, i) => (
      <group key={i} position={[0, y, 0.001]}>
        {/* Card bg */}
        <mesh>
          <planeGeometry args={[0.88, 0.215]} />
          <meshBasicMaterial color="#1e293b" />
        </mesh>
        {/* Store image placeholder — colored square */}
        <mesh position={[-0.32, 0, 0.001]}>
          <planeGeometry args={[0.17, 0.155]} />
          <meshBasicMaterial color={['#f97316', '#3b82f6', '#10b981'][i]} />
        </mesh>
        {/* Title text line */}
        <mesh position={[0.1, 0.05, 0.001]}>
          <planeGeometry args={[0.4, 0.03]} />
          <meshBasicMaterial color="#e2e8f0" />
        </mesh>
        {/* Sub text line */}
        <mesh position={[0.06, 0.01, 0.001]}>
          <planeGeometry args={[0.3, 0.022]} />
          <meshBasicMaterial color="#64748b" />
        </mesh>
        {/* Rating dots */}
        {[0, 0.035, 0.07].map((dx, j) => (
          <mesh key={j} position={[-0.06 + dx, -0.04, 0.001]}>
            <circleGeometry args={[0.008, 8]} />
            <meshBasicMaterial color="#f97316" />
          </mesh>
        ))}
        {/* Price badge */}
        <mesh position={[0.34, -0.04, 0.001]}>
          <planeGeometry args={[0.1, 0.048]} />
          <meshBasicMaterial color="#f97316" />
        </mesh>
        <mesh position={[0.34, -0.04, 0.002]}>
          <planeGeometry args={[0.06, 0.02]} />
          <meshBasicMaterial color="#ffffff" />
        </mesh>
      </group>
    ))}

    {/* Bottom tab bar */}
    <mesh position={[0, -0.88, 0.001]}>
      <planeGeometry args={[0.98, 0.155]} />
      <meshBasicMaterial color="#0f172a" />
    </mesh>
    {/* Tab icons */}
    {[-0.33, -0.11, 0.11, 0.33].map((x, i) => (
      <mesh key={i} position={[x, -0.88, 0.002]}>
        <circleGeometry args={[0.022, 12]} />
        <meshBasicMaterial color={i === 0 ? '#f97316' : '#334155'} />
      </mesh>
    ))}
    {/* Active tab label */}
    <mesh position={[-0.33, -0.915, 0.002]}>
      <planeGeometry args={[0.08, 0.015]} />
      <meshBasicMaterial color="#f97316" />
    </mesh>
  </group>
)

// ── Phone body ───────────────────────────────────────────────────────────────
const Phone: React.FC = () => {
  const groupRef = useRef<THREE.Group>(null)
  const { mouse } = useThree()

  useFrame(() => {
    if (!groupRef.current) return
    // Subtle mouse parallax tilt — horizontal only so screen stays visible
    const targetY = mouse.x * -0.2
    const targetX = mouse.y *  0.1
    groupRef.current.rotation.y += (targetY - groupRef.current.rotation.y) * 0.05
    groupRef.current.rotation.x += (targetX - groupRef.current.rotation.x) * 0.05
  })

  return (
    <Float speed={1.4} rotationIntensity={0.12} floatIntensity={0.6}>
      <group ref={groupRef}>
        {/* Body */}
        <RoundedBox args={[1.1, 2.2, 0.13]} radius={0.1} smoothness={4} castShadow>
          <meshStandardMaterial color="#1e293b" metalness={0.75} roughness={0.12}
            envMapIntensity={1.2} />
        </RoundedBox>

        {/* Screen bezel — slightly inset dark border */}
        <mesh position={[0, 0, 0.058]}>
          <planeGeometry args={[1.01, 2.01]} />
          <meshBasicMaterial color="#080d18" />
        </mesh>

        <AppScreen />

        {/* Camera notch */}
        <mesh position={[0, 1.05, 0.07]}>
          <circleGeometry args={[0.038, 16]} />
          <meshBasicMaterial color="#06090f" />
        </mesh>

        {/* Home indicator */}
        <mesh position={[0, -1.01, 0.07]}>
          <planeGeometry args={[0.26, 0.022]} />
          <meshBasicMaterial color="#334155" />
        </mesh>

        {/* Side buttons — right */}
        <mesh position={[0.575, 0.32, 0]} rotation={[0, Math.PI / 2, 0]}>
          <planeGeometry args={[0.055, 0.22]} />
          <meshStandardMaterial color="#0f172a" metalness={0.9} roughness={0.1} />
        </mesh>
        {/* Side buttons — left (volume) */}
        <mesh position={[-0.575, 0.18, 0]} rotation={[0, Math.PI / 2, 0]}>
          <planeGeometry args={[0.055, 0.12]} />
          <meshStandardMaterial color="#0f172a" metalness={0.9} roughness={0.1} />
        </mesh>
        <mesh position={[-0.575, -0.02, 0]} rotation={[0, Math.PI / 2, 0]}>
          <planeGeometry args={[0.055, 0.12]} />
          <meshStandardMaterial color="#0f172a" metalness={0.9} roughness={0.1} />
        </mesh>

        {/* Screen edge glow — very subtle orange halo */}
        <mesh position={[0, 0, 0.055]}>
          <planeGeometry args={[1.08, 2.15]} />
          <meshBasicMaterial color="#f97316" transparent opacity={0.03} />
        </mesh>
      </group>
    </Float>
  )
}

// ── Floating particles around the phone ─────────────────────────────────────
const PhoneParticles: React.FC = () => {
  const pts = useRef<THREE.Points>(null)
  const geo = React.useMemo(() => {
    const g = new THREE.BufferGeometry()
    const pos = new Float32Array(40 * 3)
    for (let i = 0; i < 40; i++) {
      const theta = Math.random() * Math.PI * 2
      const r = 1.6 + Math.random() * 1.4
      pos[i * 3]     = Math.cos(theta) * r
      pos[i * 3 + 1] = (Math.random() - 0.5) * 5
      pos[i * 3 + 2] = Math.sin(theta) * r * 0.4
    }
    g.setAttribute('position', new THREE.BufferAttribute(pos, 3))
    return g
  }, [])

  useFrame(({ clock }) => {
    if (pts.current) pts.current.rotation.y = clock.getElapsedTime() * 0.04
  })

  return (
    <points ref={pts} geometry={geo}>
      <pointsMaterial size={0.045} color="#f97316" transparent opacity={0.55} sizeAttenuation />
    </points>
  )
}

// ── Canvas export ─────────────────────────────────────────────────────────────
const PhoneScene: React.FC = () => (
  <Canvas
    camera={{ position: [0, 0, 3.8], fov: 46 }}
    gl={{ antialias: true, alpha: true }}
    dpr={[1, 1.5]}
    style={{ width: '100%', height: '100%' }}
  >
    <Suspense fallback={null}>
      {/* Lighting for the metallic phone body edges */}
      <ambientLight intensity={0.5} />
      <pointLight position={[2, 3, 5]}    intensity={2.8} color="#ffffff" />
      <pointLight position={[-3, 2, 4]}   intensity={1.5} color="#f97316" />
      <pointLight position={[0, -3, 3]}   intensity={0.6} color="#1e4080" />
      <spotLight position={[0, 5, 5]} intensity={1.8} angle={0.5} penumbra={0.6}
        color="#ffffff" castShadow />

      {/* Drag-to-spin only, no auto-rotation — Float + mouse tilt keeps it dynamic */}
      <OrbitControls
        enableZoom={false}
        enablePan={false}
        autoRotate={false}
        maxPolarAngle={Math.PI * 0.65}
        minPolarAngle={Math.PI * 0.35}
        maxAzimuthAngle={Math.PI * 0.5}
        minAzimuthAngle={-Math.PI * 0.5}
      />

      <Phone />
      <PhoneParticles />
    </Suspense>
  </Canvas>
)

export default PhoneScene
