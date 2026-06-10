import React, { useRef, useMemo, Suspense } from 'react'
import { Canvas, useFrame } from '@react-three/fiber'
import { Float, OrbitControls, MeshDistortMaterial, Stars } from '@react-three/drei'
import * as THREE from 'three'

// ─── Location Pin ────────────────────────────────────────────────────────────
const LocationPin: React.FC = () => {
  const sphereRef  = useRef<THREE.Mesh>(null)
  const innerRef   = useRef<THREE.Mesh>(null)
  const ringRef    = useRef<THREE.Mesh>(null)

  useFrame(({ clock }) => {
    const t = clock.getElapsedTime()
    if (innerRef.current) innerRef.current.scale.setScalar(0.85 + Math.sin(t * 2) * 0.1)
    if (ringRef.current)  ringRef.current.rotation.z = t * 0.4
    if (sphereRef.current) {
      (sphereRef.current.material as THREE.MeshStandardMaterial).emissiveIntensity =
        0.25 + Math.sin(t * 1.5) * 0.1
    }
  })

  return (
    <Float speed={1.4} rotationIntensity={0.25} floatIntensity={0.9}>
      <group>
        {/* Pin head */}
        <mesh ref={sphereRef} position={[0, 0.7, 0]} castShadow>
          <sphereGeometry args={[1, 48, 48]} />
          <MeshDistortMaterial
            color="#f97316"
            metalness={0.4}
            roughness={0.15}
            distort={0.18}
            speed={2.5}
            emissive="#c2410c"
            emissiveIntensity={0.25}
          />
        </mesh>

        {/* Inner glow dot */}
        <mesh ref={innerRef} position={[0, 0.7, 0]}>
          <sphereGeometry args={[0.38, 24, 24]} />
          <meshStandardMaterial
            color="#ffffff"
            emissive="#ffffff"
            emissiveIntensity={1.2}
            transparent
            opacity={0.95}
          />
        </mesh>

        {/* Pin tail */}
        <mesh position={[0, -0.65, 0]} rotation={[Math.PI, 0, 0]}>
          <coneGeometry args={[0.45, 1.5, 20]} />
          <meshStandardMaterial
            color="#ea580c"
            metalness={0.5}
            roughness={0.25}
            emissive="#9a3412"
            emissiveIntensity={0.2}
          />
        </mesh>

        {/* Flat tip disk */}
        <mesh position={[0, -1.4, 0]}>
          <sphereGeometry args={[0.12, 16, 16]} />
          <meshStandardMaterial color="#c2410c" emissive="#c2410c" emissiveIntensity={0.4} />
        </mesh>

        {/* Orbit ring */}
        <mesh ref={ringRef} rotation={[Math.PI / 2.2, 0, 0]} position={[0, 0.2, 0]}>
          <torusGeometry args={[2, 0.025, 8, 80]} />
          <meshStandardMaterial
            color="#fb923c"
            emissive="#f97316"
            emissiveIntensity={0.6}
            transparent
            opacity={0.5}
          />
        </mesh>

        {/* Second orbit ring */}
        <mesh rotation={[Math.PI / 2.2, 0, Math.PI / 3]} position={[0, 0.2, 0]}>
          <torusGeometry args={[2.4, 0.015, 8, 80]} />
          <meshStandardMaterial
            color="#f97316"
            emissive="#f97316"
            emissiveIntensity={0.3}
            transparent
            opacity={0.25}
          />
        </mesh>
      </group>
    </Float>
  )
}

// ─── Floating Package ─────────────────────────────────────────────────────────
interface PackageProps {
  position: [number, number, number]
  phaseOffset: number
  color: string
  size?: number
}

const FloatingPackage: React.FC<PackageProps> = ({ position, phaseOffset, color, size = 0.32 }) => {
  const ref = useRef<THREE.Mesh>(null)

  useFrame(({ clock }) => {
    if (!ref.current) return
    const t = clock.getElapsedTime() + phaseOffset
    ref.current.position.y = position[1] + Math.sin(t * 0.7) * 0.35
    ref.current.rotation.x = t * 0.28
    ref.current.rotation.y = t * 0.38
    ref.current.rotation.z = t * 0.15
  })

  return (
    <mesh ref={ref} position={position} castShadow>
      <boxGeometry args={[size, size, size]} />
      <meshStandardMaterial
        color={color}
        metalness={0.25}
        roughness={0.45}
        emissive={color}
        emissiveIntensity={0.08}
      />
    </mesh>
  )
}

// ─── Particles ────────────────────────────────────────────────────────────────
const Particles: React.FC = () => {
  const count = 55
  const positions = useMemo(() => {
    const arr = new Float32Array(count * 3)
    for (let i = 0; i < count; i++) {
      const r   = 2.5 + Math.random() * 4
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
    if (ref.current) ref.current.rotation.y = clock.getElapsedTime() * 0.04
  })

  return (
    <points ref={ref} geometry={geo}>
      <pointsMaterial size={0.055} color="#fb923c" transparent opacity={0.55} sizeAttenuation />
    </points>
  )
}

// ─── Scene ────────────────────────────────────────────────────────────────────
const SceneInner: React.FC = () => (
  <>
    <ambientLight intensity={0.35} />
    <pointLight position={[4, 6, 4]}   intensity={2.2}  color="#f97316" />
    <pointLight position={[-4, -4, -4]} intensity={0.6}  color="#0f172a" />
    <spotLight
      position={[0, 10, 0]}
      intensity={1.2}
      angle={0.35}
      penumbra={0.5}
      color="#ffffff"
      castShadow
    />

    <OrbitControls
      enableZoom={false}
      enablePan={false}
      autoRotate
      autoRotateSpeed={0.55}
      maxPolarAngle={Math.PI * 0.72}
      minPolarAngle={Math.PI * 0.28}
    />

    <Stars radius={30} depth={12} count={600} factor={2} saturation={0} fade speed={1} />

    <LocationPin />

    <FloatingPackage position={[ 2.8,  1.2,  0.3]} phaseOffset={0}   color="#f97316" size={0.35} />
    <FloatingPackage position={[-2.4,  1.8, -0.8]} phaseOffset={1.8} color="#334155" size={0.28} />
    <FloatingPackage position={[ 1.8, -1.8,  1.2]} phaseOffset={3.2} color="#fb923c" size={0.22} />
    <FloatingPackage position={[-2.8, -0.6,  0.6]} phaseOffset={0.9} color="#1e293b" size={0.30} />
    <FloatingPackage position={[ 3.2, -0.4, -1.0]} phaseOffset={2.4} color="#f97316" size={0.20} />
    <FloatingPackage position={[-1.2,  2.8,  0.8]} phaseOffset={4.1} color="#94a3b8" size={0.18} />

    <Particles />

    <fog attach="fog" args={['#020617', 10, 22]} />
  </>
)

// ─── Export ───────────────────────────────────────────────────────────────────
const HeroScene: React.FC = () => (
  <Canvas
    camera={{ position: [0, 0, 6.5], fov: 58 }}
    gl={{ antialias: true, alpha: true }}
    dpr={[1, 1.5]}
    style={{ width: '100%', height: '100%' }}
  >
    <Suspense fallback={null}>
      <SceneInner />
    </Suspense>
  </Canvas>
)

export default HeroScene
