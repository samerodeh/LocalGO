/**
 * LanguageContext
 *
 * Provides the active language and its translation object to the entire tree.
 * Also syncs document.documentElement.lang and dir so:
 *  - Screen readers announce the correct language
 *  - CSS [dir="rtl"] rules activate automatically for Arabic
 *
 * Usage:
 *   const { lang, setLang, T } = useLang()
 *   T.hero.cta1       // translated string
 *   setLang('ar')     // switch to Arabic (enables RTL)
 */

import { createContext, useContext, useState, useEffect, ReactNode } from 'react'
import { translations, Lang, Translations } from '../i18n/translations'

interface LanguageContextValue {
  lang:    Lang
  setLang: (l: Lang) => void
  /** Full translation object for the current language */
  T:       Translations
}

const LanguageCtx = createContext<LanguageContextValue>({
  lang:    'en',
  setLang: () => {},
  T:       translations.en,
})

export const LanguageProvider = ({ children }: { children: ReactNode }) => {
  const [lang, setLangState] = useState<Lang>('en')

  const setLang = (l: Lang) => setLangState(l)

  /** Keep html[lang] and html[dir] in sync with the selected language */
  useEffect(() => {
    const el = document.documentElement
    el.lang = lang
    el.dir  = lang === 'ar' ? 'rtl' : 'ltr'
  }, [lang])

  return (
    <LanguageCtx.Provider value={{ lang, setLang, T: translations[lang] }}>
      {children}
    </LanguageCtx.Provider>
  )
}

/** Hook — consume language/translations anywhere inside <LanguageProvider> */
export const useLang = () => useContext(LanguageCtx)
