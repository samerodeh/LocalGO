/**
 * DeliveryScene v2 — How It Works section
 *
 * Compact downtown city: skyscrapers in the core, mid-rise buildings,
 * a residential house on the outskirts. A glowing orange route tube
 * traces the delivery path street-by-street from the store (orange pin)
 * to the customer's house (green pin). A tiny package travels along it.
 */
import React, { useRef, useMemo, Suspense } from 'react'
import { Canvas, useFrame } from '@react-three/fiber'
import { OrbitControls } from '@react-three/drei'
import * as THREE from 'three'

// ─── Building data ────────────────────────────────────────────────────────────
// [x, z, width, height, depth, colorIndex, litWindows]
type BD = [number, number, number, number, number, number, boolean]

const BDATA: BD[] = [
  // ── Downtown core — tall skyscrapers ──
  [ 0.0, -1.5,  .55, 2.2, .55, 0, true ],
  [ 0.7, -1.0,  .44, 1.8, .44, 1, true ],
  [-0.6, -1.2,  .50, 2.0, .50, 2, true ],
  [ 0.2, -2.0,  .42, 1.5, .42, 0, true ],
  [-0.2, -0.7,  .46, 1.3, .46, 3, true ],
  // ── Right cluster ──
  [ 1.8, -0.8,  .54, 1.0, .50, 1, true ],
  [ 2.3, -0.2,  .46,  .85,.42, 4, true ],
  [ 1.0, -1.6,  .46,  .90,.46, 3, false],
  [ 2.1, -1.5,  .40,  .65,.40, 0, false],
  [ 1.5,  0.05, .50,  .70,.50, 2, false],
  // ── Left cluster ──
  [-2.0, -0.5,  .50,  .90,.46, 4, true ],
  [-2.4, -1.3,  .46,  .75,.42, 1, false],
  [-1.5, -1.8,  .50,  .60,.50, 0, false],
  [-1.1, -0.2,  .42,  .65,.42, 5, false],
  // ── Near cluster (positive z) — shorter ──
  [ 0.5,  0.8,  .54,  .60,.50, 2, false],
  [-0.5,  1.1,  .50,  .50,.46, 4, false],
  [ 1.5,  0.9,  .46,  .55,.46, 1, false],
  [-1.6,  0.7,  .50,  .60,.50, 3, false],
  // ── Far cluster (negative z) ──
  [ 1.2, -2.5,  .40,  .55,.40, 2, false],
  [-0.8, -2.6,  .46,  .60,.46, 4, false],
  [ 2.8, -1.1,  .36,  .45,.36, 5, false],
  [-2.8, -0.9,  .36,  .50,.36, 0, false],
  // ── Extra fill ──
  [ 0.9, -0.3,  .40,  .55,.40, 3, false],
  [-0.9, -0.4,  .40,  .50,.40, 1, false],
  [ 1.6, -2.2,  .36,  .50,.36, 2, false],
]

const WALL_COLORS = [
  '#0d2137', '#0f2744', '#102035', '#162d4a', '#1a2f4a', '#1e3a5f',
]

const STORE_POS: [number, number, number] = [-2.7, 0, 0.5]
const HOUSE_POS: [number, number, number] = [ 2.7, 0, 1.2]

// Street-level route waypoints
const ROUTE_PTS = [
  new THREE.Vector3(-2.7, 0.07, 0.50),
  new THREE.Vector3(-2.0, 0.07, 0.38),
  new THREE.Vector3(-1.2, 0.07, 0.28),
  new THREE.Vector3( 0.0, 0.07, 0.22),
  new THREE.Vector3( 1.2, 0.07, 0.28),
  new THREE.Vector3( 2.0, 0.07, 0.56),
  new THREE.Vector3( 2.7, 0.07, 1.20),
]

// ─── Single building ──────────────────────────────────────────────────────────
const Building: React.FC<{ def: BD; idx: number }> = ({ def, idx }) => {
  const [bx, bz, w, h, d, ci] = def
  const litBuilding = def[6]
  const wallColor = WALL_COLORS[ci] ?? '#0f2744'

  // Window positions — front + back faces only, capped for performance
  const windows = useMemo(() => {
    if (!litBuilding || h < 0.8) return []
    const list: Array<{ x: number; y: number; z: number; flip: boolean }> = []
    const cols = Math.min(3, Math.max(1, Math.floor(w / 0.20)))
    const rows = Math.min(5, Math.max(1, Math.floor(h / 0.36)))
    for (let r = 0; r < rows; r++) {
      for (let c = 0; c < cols; c++) {
        if ((idx * 17 + r * 9 + c * 13) % 6 === 0) continue
        const wy = 0.28 + r * 0.36
        if (wy > h - 0.1) continue
        const wx = (c - (cols - 1) / 2) * 0.20
        list.push({ x: bx + wx, y: wy, z: bz + d / 2 + 0.004, flip: false })
        list.push({ x: bx + wx, y: wy, z: bz - d / 2 - 0.004, flip: true })
      }
    }
    return list
  }, [bx, bz, w, h, d, idx, litBuilding])

  return (
    <>
      {/* Body */}
      <mesh position={[bx, h / 2, bz]} castShadow receiveShadow>
        <boxGeometry args={[w, h, d]} />
        <meshStandardMaterial
          color={wallColor}
          metalness={0.12}
          roughness={0.78}
          emissive={wallColor}
          emissiveIntensity={0.04}
        />
      </mesh>
      {/* Rooftop accent */}
      <mesh position={[bx, h + 0.018, bz]}>
        <boxGeometry args={[w, 0.035, d]} />
        <meshBasicMaterial color={litBuilding ? '#1e3a5f' : '#06101c'} />
      </mesh>
      {/* Lit windows */}
      {windows.map((win, i) => (
        <mesh
          key={i}
          position={[win.x, win.y, win.z]}
          rotation={[0, win.flip ? Math.PI : 0, 0]}
        >
          <planeGeometry args={[0.068, 0.092]} />
          <meshBasicMaterial
            color={(idx * 3 + i) % 4 === 0 ? '#f97316' : '#fbbf24'}
            transparent
            opacity={0.6 + (i % 4) * 0.08}
          />
        </mesh>
      ))}
    </>
  )
}

// ─── Ground + street grid ─────────────────────────────────────────────────────
const Ground: React.FC = () => (
  <>
    {/* Dark city base */}
    <mesh rotation={[-Math.PI / 2, 0, 0]} position={[0, 0, 0]} receiveShadow>
      <planeGeometry args={[16, 12]} />
      <meshStandardMaterial color="#040a12" roughness={0.95} />
    </mesh>
    {/* Main delivery street */}
    <mesh rotation={[-Math.PI / 2, 0, 0]} position={[0, 0.002, 0.32]}>
      <planeGeometry args={[16, 0.52]} />
      <meshBasicMaterial color="#070f1a" transparent opacity={0.85} />
    </mesh>
    {/* Centre-line dashes */}
    {[-4, -3, -2, -1, 0, 1, 2, 3, 4].map(xi => (
      <mesh key={xi} rotation={[-Math.PI / 2, 0, 0]} position={[xi * 1.2, 0.004, 0.32]}>
        <planeGeometry args={[0.38, 0.04]} />
        <meshBasicMaterial color="#1a2f4a" transparent opacity={0.5} />
      </mesh>
    ))}
    {/* Secondary cross street */}
    <mesh rotation={[-Math.PI / 2, 0, 0]} position={[0, 0.002, -0.5]}>
      <planeGeometry args={[16, 0.42]} />
      <meshBasicMaterial color="#060d18" transparent opacity={0.8} />
    </mesh>
  </>
)

// ─── Store (origin) ───────────────────────────────────────────────────────────
const StoreFront: React.FC = () => {
  const pinRef = useRef<THREE.Group>(null)
  useFrame(({ clock }) => {
    if (pinRef.current) {
      pinRef.current.position.y = 0.96 + Math.sin(clock.getElapsedTime() * 2.2) * 0.07
    }
  })
  const [sx, , sz] = STORE_POS
  return (
    <group position={[sx, 0, sz]}>
      {/* Store body */}
      <mesh position={[0, 0.44, 0]} castShadow>
        <boxGeometry args={[0.65, 0.88, 0.60]} />
        <meshStandardMaterial color="#0d2137" metalness={0.1} roughness={0.8} />
      </mesh>
      {/* Orange awning */}
      <mesh position={[0, 0.80, 0.33]} rotation={[-0.22, 0, 0]}>
        <boxGeometry args={[0.58, 0.028, 0.22]} />
        <meshBasicMaterial color="#f97316" />
      </mesh>
      {/* Fascia sign */}
      <mesh position={[0, 0.90, 0.315]}>
        <planeGeometry args={[0.46, 0.095]} />
        <meshBasicMaterial color="#f97316" />
      </mesh>
      {/* Door */}
      <mesh position={[0, 0.22, 0.308]}>
        <planeGeometry args={[0.17, 0.34]} />
        <meshBasicMaterial color="#f97316" transparent opacity={0.4} />
      </mesh>
      {/* Shop windows */}
      {[-0.19, 0.19].map((x, i) => (
        <mesh key={i} position={[x, 0.50, 0.308]}>
          <planeGeometry args={[0.14, 0.22]} />
          <meshBasicMaterial color="#fbbf24" transparent opacity={0.72} />
        </mesh>
      ))}
      {/* Orange map pin */}
      <group ref={pinRef} position={[0, 0.96, 0]}>
        <mesh position={[0, 0.10, 0]}>
          <sphereGeometry args={[0.095, 14, 14]} />
          <meshBasicMaterial color="#f97316" />
        </mesh>
        <mesh position={[0, 0.005, 0]} rotation={[Math.PI, 0, 0]}>
          <coneGeometry args={[0.048, 0.22, 10]} />
          <meshBasicMaterial color="#f97316" />
        </mesh>
        {/* Glow ring on ground */}
        <mesh position={[0, -0.95, 0]} rotation={[-Math.PI / 2, 0, 0]}>
          <ringGeometry args={[0.10, 0.20, 20]} />
          <meshBasicMaterial color="#f97316" transparent opacity={0.25} side={THREE.DoubleSide} />
        </mesh>
      </group>
    </group>
  )
}

// ─── House / apartment (destination) ─────────────────────────────────────────
const HouseUnit: React.FC = () => {
  const pinRef = useRef<THREE.Group>(null)
  useFrame(({ clock }) => {
    if (pinRef.current) {
      pinRef.current.position.y = 0.9 + Math.sin(clock.getElapsedTime() * 2.2 + 1.1) * 0.07
    }
  })
  const [hx, , hz] = HOUSE_POS
  return (
    <group position={[hx, 0, hz]}>
      {/* House body */}
      <mesh position={[0, 0.35, 0]} castShadow>
        <boxGeometry args={[0.66, 0.70, 0.62]} />
        <meshStandardMaterial color="#162d4a" metalness={0.1} roughness={0.8} />
      </mesh>
      {/* Pitched roof */}
      <mesh position={[0, 0.785, 0]} rotation={[0, Math.PI / 4, 0]}>
        <coneGeometry args={[0.545, 0.36, 4]} />
        <meshStandardMaterial color="#0a1520" roughness={0.9} />
      </mesh>
      {/* Door */}
      <mesh position={[0, 0.205, 0.315]}>
        <planeGeometry args={[0.165, 0.32]} />
        <meshBasicMaterial color="#f97316" transparent opacity={0.5} />
      </mesh>
      {/* Windows */}
      {[-0.19, 0.19].map((x, i) => (
        <mesh key={i} position={[x, 0.43, 0.315]}>
          <planeGeometry args={[0.14, 0.14]} />
          <meshBasicMaterial color="#fbbf24" transparent opacity={0.76} />
        </mesh>
      ))}
      {/* Green destination map pin */}
      <group ref={pinRef} position={[0, 0.9, 0]}>
        <mesh position={[0, 0.10, 0]}>
          <sphereGeometry args={[0.095, 14, 14]} />
          <meshBasicMaterial color="#22c55e" />
        </mesh>
        <mesh position={[0, 0.005, 0]} rotation={[Math.PI, 0, 0]}>
          <coneGeometry args={[0.048, 0.22, 10]} />
          <meshBasicMaterial color="#22c55e" />
        </mesh>
        {/* Ground ring */}
        <mesh position={[0, -0.89, 0]} rotation={[-Math.PI / 2, 0, 0]}>
          <ringGeometry args={[0.10, 0.20, 20]} />
          <meshBasicMaterial color="#22c55e" transparent opacity={0.25} side={THREE.DoubleSide} />
        </mesh>
      </group>
    </group>
  )
}

// ─── Glowing route tube ───────────────────────────────────────────────────────
const RoutePath: React.FC<{ curve: THREE.CatmullRomCurve3 }> = ({ curve }) => {
  const tubeGeo = useMemo(
    () => new THREE.TubeGeometry(curve, 100, 0.022, 6, false),
    [curve]
  )
  const glowGeo = useMemo(
    () => new THREE.TubeGeometry(curve, 60, 0.055, 6, false),
    [curve]
  )
  return (
    <>
      <mesh geometry={glowGeo}>
        <meshBasicMaterial color="#f97316" transparent opacity={0.12} />
      </mesh>
      <mesh geometry={tubeGeo}>
        <meshBasicMaterial color="#f97316" transparent opacity={0.55} />
      </mesh>
    </>
  )
}

// ─── Delivery package traveling along route ────────────────────────────────────
const DeliveryPackage: React.FC<{ curve: THREE.CatmullRomCurve3 }> = ({ curve }) => {
  const groupRef = useRef<THREE.Group>(null)
  const trailRefs = useRef<(THREE.Mesh | null)[]>([])
  const TRAIL = 10
  const progress = useRef(0)

  useFrame(({ clock }) => {
    progress.current = (clock.getElapsedTime() * 0.09) % 1
    const t = progress.current
    const pos = curve.getPoint(t)
    const tgt = curve.getPoint(Math.min(t + 0.012, 0.999))

    if (groupRef.current) {
      groupRef.current.position.set(pos.x, pos.y + 0.13, pos.z)
      groupRef.current.lookAt(tgt.x, pos.y + 0.13, tgt.z)
    }

    trailRefs.current.forEach((m, i) => {
      if (!m) return
      const lag = ((t - (i + 1) * 0.013) + 1) % 1
      const p = curve.getPoint(lag)
      m.position.set(p.x, p.y + 0.09, p.z)
      ;(m.material as THREE.MeshBasicMaterial).opacity = 0.5 - i * 0.046
    })
  })

  return (
    <>
      <group ref={groupRef}>
        {/* Package box */}
        <mesh>
          <boxGeometry args={[0.13, 0.10, 0.13]} />
          <meshBasicMaterial color="#f97316" />
        </mesh>
        {/* Tape cross on top */}
        <mesh position={[0, 0.052, 0]}>
          <boxGeometry args={[0.038, 0.012, 0.13]} />
          <meshBasicMaterial color="#ffffff" />
        </mesh>
        <mesh position={[0, 0.052, 0]}>
          <boxGeometry args={[0.13, 0.012, 0.038]} />
          <meshBasicMaterial color="#ffffff" />
        </mesh>
        {/* Orange glow halo */}
        <mesh>
          <sphereGeometry args={[0.155, 8, 8]} />
          <meshBasicMaterial color="#f97316" transparent opacity={0.13} />
        </mesh>
      </group>
      {/* Trail spheres */}
      {Array.from({ length: TRAIL }, (_, i) => (
        <mesh key={i} ref={el => { trailRefs.current[i] = el }}>
          <sphereGeometry args={[Math.max(0.006, 0.034 - i * 0.003), 6, 6]} />
          <meshBasicMaterial color="#fb923c" transparent opacity={0.45} />
        </mesh>
      ))}
    </>
  )
}

// ─── Scene assembly ────────────────────────────────────────────────────────────
const SceneInner: React.FC = () => {
  const curve = useMemo(
    () => new THREE.CatmullRomCurve3(ROUTE_PTS, false, 'catmullrom', 0.45),
    []
  )

  return (
    <>
      <ambientLight intensity={0.32} />
      <pointLight position={[0, 7, 2]}   intensity={2.0} color="#f97316" />
      <pointLight position={[0, 4, -5]}  intensity={0.5} color="#4070b0" />
      <pointLight position={STORE_POS}   intensity={0.8} color="#f97316" distance={3} />
      <pointLight position={HOUSE_POS}   intensity={0.8} color="#22c55e" distance={3} />
      <spotLight
        position={[0, 10, 5]}
        intensity={1.4}
        angle={0.5}
        penumbra={0.6}
        castShadow
      />

      <OrbitControls
        enableZoom={false}
        enablePan={false}
        autoRotate
        autoRotateSpeed={0.45}
        maxPolarAngle={Math.PI * 0.52}
        minPolarAngle={Math.PI * 0.10}
      />

      <Ground />
      {BDATA.map((def, i) => (
        <Building key={i} def={def} idx={i} />
      ))}
      <StoreFront />
      <HouseUnit />
      <RoutePath curve={curve} />
      <DeliveryPackage curve={curve} />
    </>
  )
}

// ─── Canvas export ────────────────────────────────────────────────────────────
const DeliveryScene: React.FC = () => (
  <Canvas
    camera={{ position: [0, 4.8, 7.5], fov: 52 }}
    gl={{ antialias: true, alpha: true }}
    dpr={[1, 1.5]}
    shadows
    style={{ width: '100%', height: '100%' }}
  >
    <Suspense fallback={null}>
      <SceneInner />
    </Suspense>
  </Canvas>
)

export default DeliveryScene
