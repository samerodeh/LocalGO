/**
 * RouterContext
 *
 * Lightweight client-side routing via React context.
 * Avoids adding react-router-dom as a dependency for a simple 3-page app.
 *
 * Usage:
 *   const { page, go } = useRouter()
 *   go('marketplace')   // navigate to a page
 */

import { createContext, useContext } from 'react'

/** All valid page identifiers */
export type Page = 'home' | 'marketplace' | 'register'

export interface RouterContextValue {
  /** Currently active page */
  page: Page
  /** Navigate to a page (also scrolls to top) */
  go: (page: Page) => void
}

export const RouterCtx = createContext<RouterContextValue>({
  page: 'home',
  go: () => {},
})

/** Hook — consume the router anywhere inside <RouterCtx.Provider> */
export const useRouter = () => useContext(RouterCtx)
