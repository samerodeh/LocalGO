/**
 * Icon Library
 *
 * Inline SVG icon components using the Feather icon style:
 * stroke-based, 24×24 viewBox, 1.75 stroke-width, round caps/joins.
 *
 * Each component renders a bare <svg> — sizing is controlled via CSS
 * on the parent element (e.g. .feature-card__icon, .about-card__icon).
 */

/** Shared SVG props for all icons */
const props = {
  viewBox: '0 0 24 24',
  fill: 'none',
  stroke: 'currentColor',
  strokeWidth: 1.75,
  strokeLinecap: 'round' as const,
  strokeLinejoin: 'round' as const,
}

// ─── Business / Commerce ───────────────────────────────────────────────────

export const IconStore = () => (
  <svg {...props}>
    <path d="M3 9l1-5h16l1 5"/>
    <path d="M3 9a2 2 0 0 0 2 2 2 2 0 0 0 2-2 2 2 0 0 0 2 2 2 2 0 0 0 2-2 2 2 0 0 0 2 2 2 2 0 0 0 2-2"/>
    <path d="M5 21V11m14 10V11"/>
    <rect x="9" y="15" width="6" height="6"/>
  </svg>
)

export const IconBuilding = () => (
  <svg {...props}>
    <rect x="3" y="3" width="18" height="18" rx="2"/>
    <path d="M9 22V12h6v10"/><path d="M9 7h1m4 0h1M9 11h1m4 0h1"/>
  </svg>
)

export const IconShoppingBag = () => (
  <svg {...props}>
    <path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/>
    <line x1="3" y1="6" x2="21" y2="6"/>
    <path d="M16 10a4 4 0 0 1-8 0"/>
  </svg>
)

export const IconDollar = () => (
  <svg {...props}>
    <line x1="12" y1="1" x2="12" y2="23"/>
    <path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/>
  </svg>
)

// ─── Delivery / Logistics ──────────────────────────────────────────────────

export const IconRoute = () => (
  <svg {...props}>
    <circle cx="6" cy="19" r="3"/>
    <path d="M9 19h8.5a3.5 3.5 0 0 0 0-7h-11a3.5 3.5 0 0 1 0-7H15"/>
    <circle cx="18" cy="5" r="3"/>
  </svg>
)

export const IconMapPin = () => (
  <svg {...props}>
    <path d="M21 10c0 7-9 13-9 13S3 17 3 10a9 9 0 0 1 18 0z"/>
    <circle cx="12" cy="10" r="3"/>
  </svg>
)

export const IconZap = () => (
  <svg {...props} strokeWidth={1.75}>
    <polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"/>
  </svg>
)

// ─── Data / Analytics ─────────────────────────────────────────────────────

export const IconBarChart = () => (
  <svg {...props}>
    <line x1="18" y1="20" x2="18" y2="10"/>
    <line x1="12" y1="20" x2="12" y2="4"/>
    <line x1="6"  y1="20" x2="6"  y2="14"/>
    <line x1="2"  y1="20" x2="22" y2="20"/>
  </svg>
)

export const IconTrendingUp = () => (
  <svg {...props}>
    <polyline points="23 6 13.5 15.5 8.5 10.5 1 18"/>
    <polyline points="17 6 23 6 23 12"/>
  </svg>
)

// ─── People / Support ─────────────────────────────────────────────────────

export const IconHeadphones = () => (
  <svg {...props}>
    <path d="M3 18v-6a9 9 0 0 1 18 0v6"/>
    <path d="M21 19a2 2 0 0 1-2 2h-1a2 2 0 0 1-2-2v-3a2 2 0 0 1 2-2h3z"/>
    <path d="M3 19a2 2 0 0 0 2 2h1a2 2 0 0 0 2-2v-3a2 2 0 0 0-2-2H3z"/>
  </svg>
)

export const IconUsers = () => (
  <svg {...props}>
    <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/>
    <circle cx="9" cy="7" r="4"/>
    <path d="M23 21v-2a4 4 0 0 0-3-3.87"/>
    <path d="M16 3.13a4 4 0 0 1 0 7.75"/>
  </svg>
)

// ─── UI / Navigation ──────────────────────────────────────────────────────

export const IconLayers = () => (
  <svg {...props}>
    <polygon points="12 2 2 7 12 12 22 7 12 2"/>
    <polyline points="2 17 12 22 22 17"/>
    <polyline points="2 12 12 17 22 12"/>
  </svg>
)

export const IconShield = () => (
  <svg {...props}>
    <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>
  </svg>
)

export const IconArrowLeft = () => (
  <svg {...props} strokeWidth={2}>
    <line x1="19" y1="12" x2="5" y2="12"/>
    <polyline points="12 19 5 12 12 5"/>
  </svg>
)

// ─── Status indicators ────────────────────────────────────────────────────

/** Green check — used in comparison "LocalGo" column */
export const IconCheck = () => (
  <svg {...props} strokeWidth={2.5}>
    <polyline points="20 6 9 17 4 12"/>
  </svg>
)

/** Red X — used in comparison "Big Platforms" column */
export const IconX = () => (
  <svg {...props} strokeWidth={2.5}>
    <line x1="18" y1="6" x2="6" y2="18"/>
    <line x1="6"  y1="6" x2="18" y2="18"/>
  </svg>
)
