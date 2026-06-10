import React, { useRef, useMemo, Suspense } from 'react'
import { Canvas, useFrame } from '@react-three/fiber'
import * as THREE from 'three'

const OrbParticles: React.FC = () => {
  const count = 80
  const positions = useMemo(() => {
    const arr = new Float32Array(count * 3)
    for (let i = 0; i < count; i++) {
      const r   = 1.2 + Math.random() * 2.8
      const th  = Math.random() * Math.PI * 2
      const phi = Math.random() * Math.PI
      arr[i * 3]     = r * Math.sin(phi) * Math.cos(th)
      arr[i * 3 + 1] = r * Math.cos(phi)
      arr[i * 3 + 2] = r * Math.sin(phi) * Math.sin(th)
    }
    return arr
  }, [])

  const geo = useMemo(() => {
    const g = new THREE.BufferGeometry()
    g.setAttribute('position', new THREE.BufferAttribute(positions, 3))
    return g
  }, [positions])

  const ref = useRef<THREE.Points>(null)

  useFrame(({ clock }) => {
    if (ref.current) {
      ref.current.rotation.y = clock.getElapsedTime() * 0.07
      ref.current.rotation.x = clock.getElapsedTime() * 0.03
    }
  })

  return (
    <points ref={ref} geometry={geo}>
      <pointsMaterial size={0.06} color="#f97316" transparent opacity={0.4} sizeAttenuation />
    </points>
  )
}

const CoreSphere: React.FC = () => {
  const ref = useRef<THREE.Mesh>(null)

  useFrame(({ clock }) => {
    if (ref.current) {
      const t = clock.getElapsedTime()
      ref.current.rotation.y = t * 0.15
      ref.current.rotation.x = t * 0.08
    }
  })

  return (
    <mesh ref={ref}>
      <icosahedronGeometry args={[0.8, 1]} />
      <meshStandardMaterial
        color="#f97316"
        wireframe
        transparent
        opacity={0.18}
        emissive="#f97316"
        emissiveIntensity={0.5}
      />
    </mesh>
  )
}

const FeaturesOrb: React.FC = () => (
  <Canvas
    camera={{ position: [0, 0, 5], fov: 55 }}
    gl={{ antialias: true, alpha: true }}
    dpr={[1, 1.5]}
    style={{ width: '100%', height: '100%' }}
  >
    <Suspense fallback={null}>
      <ambientLight intensity={0.5} />
      <pointLight position={[3, 3, 3]} intensity={1.5} color="#f97316" />
      <CoreSphere />
      <OrbParticles />
    </Suspense>
  </Canvas>
)

export default FeaturesOrb
