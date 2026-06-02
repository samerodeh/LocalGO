/**
 * Translations — English, French, Arabic
 *
 * Structured as: translations[lang][section][key]
 * Arrays are used for repeated items (cards, steps, features, etc.)
 *
 * Arabic text is right-to-left (RTL).  The LanguageContext sets
 * document.documentElement.dir accordingly so CSS [dir="rtl"] rules
 * automatically flip the layout.
 */

export type Lang = 'en' | 'fr' | 'ar'

// ─── Type definitions ─────────────────────────────────────────────────────

export interface Translations {
  nav: {
    about: string
    howItWorks: string
    features: string
    downloadApp: string
    listBusiness: string
    backHome: string
  }
  hero: {
    badge: string
    tagline: string
    sub: string
    cta1: string
    cta2: string
    stat1label: string
    stat2label: string
    stat3label: string
    stat4label: string
  }
  about: {
    eyebrow: string
    title: string
    p1: string
    p2: string
    cta: string
    card1title: string
    card1body: string
    card2title: string
    card2body: string
    card3title: string
    card3body: string
  }
  how: {
    eyebrow: string
    title: string
    s1title: string
    s1body: string
    s2title: string
    s2body: string
    s3title: string
    s3body: string
  }
  comparison: {
    eyebrow: string
    title: string
    intro: string
    badLabel: string
    goodLabel: string
    goodBadge: string
    bad: string[]
    good: string[]
    badSummary: string
    goodSummary: string
    cta1: string
    cta2: string
  }
  features: {
    eyebrow: string
    title: string
    items: Array<{ title: string; body: string }>
  }
  contact: {
    eyebrow: string
    title: string
    body: string
    labelName: string
    labelBusiness: string
    labelEmail: string
    labelType: string
    labelMessage: string
    placeholderName: string
    placeholderBusiness: string
    placeholderEmail: string
    placeholderMessage: string
    typeOptions: string[]
    submit: string
    successH3: string
    successP: string
  }
  marketplace: {
    eyebrow: string
    title: string
    sub: string
    filters: string[]
    statusOpen: string
    statusBusy: string
    statusComing: string
    browseBtn: string
    launchingSoon: string
    partnerSingular: string
    partnerPlural: string
    ctaH3: string
    ctaP: string
    ctaBtn: string
  }
  register: {
    eyebrow: string
    title: string
    sub: string
    perksTitle: string
    perk1title: string
    perk1body: string
    perk2title: string
    perk2body: string
    perk3title: string
    perk3body: string
    perk4title: string
    perk4body: string
    pricingDeliveryLabel: string
    pricingCommissionLabel: string
    formTitle: string
    labelOwner: string
    labelBusinessName: string
    labelEmail: string
    labelPhone: string
    labelType: string
    labelAddress: string
    labelDailyOrders: string
    labelDescription: string
    placeholderOwner: string
    placeholderBusiness: string
    placeholderEmail: string
    placeholderPhone: string
    placeholderAddress: string
    placeholderDescription: string
    typeOptions: string[]
    dailyOrderOptions: string[]
    submit: string
    successH3: string
    successP: string
  }
  footer: {
    tagline: string
    location: string
    linkAbout: string
    linkHow: string
    linkFeatures: string
    linkMarketplace: string
    linkRegister: string
    pricing: string
    copyright: string
  }
  modal: {
    title:      string
    comingSoon: string
    note:       string
  }
}

// ─── English ──────────────────────────────────────────────────────────────

const en: Translations = {
  nav: {
    about:        'About',
    howItWorks:   'How It Works',
    features:     'Features',
    downloadApp:  'Download the App',
    listBusiness: 'List Your Business',
    backHome:     'Back to Home',
  },
  hero: {
    badge:      'MONTREAL · SGW · DOWNTOWN',
    tagline:    'Fast & Reliable Delivery',
    sub:        "A delivery platform built for downtown Montreal's independent businesses. Flat $5 delivery. 10% commission. No hidden fees.",
    cta1:       'Register Your Business & Protect Your Profits',
    cta2:       'Download the App & Support Local',
    stat1label: 'Flat Delivery Fee',
    stat2label: 'Commission Only',
    stat3label: 'Avg. Delivery',
    stat4label: 'Service Radius',
  },
  about: {
    eyebrow:    'About LocalGo',
    title:      'One platform.\nEvery local business.',
    p1:         "LocalGo is a delivery platform built for the downtown Montreal neighbourhood. Anchored around Concordia's SGW campus, we connect students, residents, and workers with the restaurants, markets, and shops that define the area.",
    p2:         'We handle full delivery logistics — so local businesses can focus on what they do best while reaching more customers through a single, unified app.',
    cta:        'Join Our Network',
    card1title: 'Independent Businesses Only',
    card1body:  'We partner exclusively with locally owned shops, restaurants, and markets — no chains.',
    card2title: 'End-to-End Logistics',
    card2body:  'We manage drivers, routing, and last-mile delivery so you can focus on your business.',
    card3title: 'Unified Customer Experience',
    card3body:  'Customers order from multiple merchants in one cart, one checkout, one delivery.',
  },
  how: {
    eyebrow:  'How It Works',
    title:    'Simple for businesses.\nSeamless for customers.',
    s1title:  'Browse Local Businesses',
    s1body:   'Customers discover your shop alongside other independent businesses in our curated downtown Montreal catalogue.',
    s2title:  'One Order, Multiple Merchants',
    s2body:   'A single cart spans restaurants, grocers, and specialty stores — one checkout, no friction.',
    s3title:  'Fast, Reliable Delivery',
    s3body:   'Our riders cover the SGW area and downtown core with consistent delivery times.',
  },
  comparison: {
    eyebrow:    'Transparency',
    title:      'Why order with LocalGo\nand forget the big delivery companies?',
    intro:      'Uber Eats and DoorDash profit at the expense of both the restaurant and the customer. LocalGo is built differently.',
    badLabel:   'Uber Eats & DoorDash',
    goodLabel:  'LocalGo',
    goodBadge:  "Montreal's Choice",
    bad: [
      '30% commission taken from restaurants',
      'Restaurants forced to raise menu prices online',
      'Variable delivery fees + hidden service charges',
      'Your meal can cost nearly double the menu price',
      'Customer data owned by the platform, not you',
    ],
    good: [
      'Flat $5 delivery fee for customers — always',
      'Only 10% commission for partner businesses',
      "You pay the same price as the restaurant's real menu",
      'Zero hidden fees or surprise charges at checkout',
      'Your customer relationships stay yours',
    ],
    badSummary:  'Up to 30% commission + hidden fees — you pay more, businesses earn less.',
    goodSummary: '$5 flat delivery for customers · 10% commission for businesses.',
    cta1: 'Download the App & Support Local',
    cta2: 'Register Your Business',
  },
  features: {
    eyebrow: 'Features',
    title:   'Built for local business.',
    items: [
      { title: 'Downtown Montreal Focus',    body: 'Tight delivery zones covering the SGW corridor, Guy to Atwater, and the surrounding downtown core.' },
      { title: 'Fast Delivery',              body: 'Optimised routing keeps average delivery times under 30 minutes across our service area.' },
      { title: 'Fair Revenue Model',         body: 'Transparent fee structure with no hidden charges. Your growth is our growth.' },
      { title: 'Food, Grocery & More',       body: 'One platform for restaurants, dépanneurs, bakeries, florists, and specialty stores.' },
      { title: 'Business Dashboard',         body: 'Live order tracking, sales analytics, and customer insights in a single interface.' },
      { title: 'Dedicated Partner Support',  body: 'A direct line to your account manager — not a ticketing queue.' },
    ],
  },
  contact: {
    eyebrow:           'Partner With Us',
    title:             'Ready to grow\nyour reach?',
    body:              "Tell us about your business and we'll be in touch within one business day. No commitment required.",
    labelName:         'Your Name',
    labelBusiness:     'Business Name',
    labelEmail:        'Email Address',
    labelType:         'Business Type',
    labelMessage:      'Tell us about your business',
    placeholderName:   'Jane Smith',
    placeholderBusiness: 'Café du Coin',
    placeholderEmail:  'you@yourbusiness.com',
    placeholderMessage: 'Location, daily order volume, anything else we should know.',
    typeOptions:       ['Restaurant', 'Grocery / Market', 'Bakery / Café', 'Specialty Store', 'Other'],
    submit:            'Send Partnership Request',
    successH3:         'Message received.',
    successP:          "We'll be in touch within one business day.",
  },
  marketplace: {
    eyebrow:         'Marketplace',
    title:           'Order from local businesses\nyou actually care about.',
    sub:             'Flat $5 delivery · Within 3 km of SGW · No hidden fees',
    filters:         ['All', 'Restaurant', 'Grocery / Market', 'Bakery / Café', 'Specialty Store'],
    statusOpen:      'Open Now',
    statusBusy:      'Busy',
    statusComing:    'Coming Soon',
    browseBtn:       'Browse & Order',
    launchingSoon:   'Launching soon',
    partnerSingular: 'partner',
    partnerPlural:   'partners',
    ctaH3:           'Is your business missing from this list?',
    ctaP:            'Join our network and reach more customers in your neighbourhood today.',
    ctaBtn:          'Register Your Business',
  },
  register: {
    eyebrow:                 'Partner Registration',
    title:                   'Register your business.\nProtect your profits.',
    sub:                     "Join Montreal's local-first delivery network. No hidden fees. No compromises.",
    perksTitle:              'Why partner with LocalGo?',
    perk1title:              'Only 10% Commission',
    perk1body:               'Keep 90% of every order. No setup fees, no monthly charges.',
    perk2title:              'Fast Onboarding',
    perk2body:               'Go live within 48 hours of submitting your information.',
    perk3title:              'Your Data, Your Customers',
    perk3body:               'We never sell or share your customer data with third parties.',
    perk4title:              'Dedicated Support',
    perk4body:               'A real account manager to help you grow from day one.',
    pricingDeliveryLabel:    'Flat delivery\nfor customers',
    pricingCommissionLabel:  'Commission\nper order',
    formTitle:               'Business Registration',
    labelOwner:              'Owner / Contact Name',
    labelBusinessName:       'Business Name',
    labelEmail:              'Email Address',
    labelPhone:              'Phone Number',
    labelType:               'Business Type',
    labelAddress:            'Business Address / Location',
    labelDailyOrders:        'Estimated Daily Orders',
    labelDescription:        'Tell us about your business',
    placeholderOwner:        'Jane Smith',
    placeholderBusiness:     'Café du Coin',
    placeholderEmail:        'you@yourbusiness.com',
    placeholderPhone:        '514-555-0199',
    placeholderAddress:      '123 Rue Sainte-Catherine O, Montreal, QC',
    placeholderDescription:  'What you offer, your location, any special requirements…',
    typeOptions:             ['Restaurant', 'Grocery / Market', 'Bakery / Café', 'Specialty Store', 'Other'],
    dailyOrderOptions:       ['Less than 20', '20–50', '50–100', '100+'],
    submit:                  'Submit Registration',
    successH3:               'Application received.',
    successP:                'Our team will reach out within one business day to get your business live on LocalGo.',
  },
  footer: {
    tagline:        'MONTREAL DELIVERY SERVICES',
    location:       'MONTREAL, QC',
    linkAbout:      'About',
    linkHow:        'How It Works',
    linkFeatures:   'Features',
    linkMarketplace:'Marketplace',
    linkRegister:   'Register Business',
    pricing:        'Flat-Rate Delivery: $5 (Within 3 km) \u00A0·\u00A0 Only 10% Commission – No Hidden Fees',
    copyright:      'LocalGo. All rights reserved.',
  },
  modal: {
    title:      'App Coming Soon',
    comingSoon: "We're working hard to bring LocalGo to iOS & Android.",
    note:       'Stay tuned — the app will be available very soon!',
  },
}

// ─── French ───────────────────────────────────────────────────────────────

const fr: Translations = {
  nav: {
    about:        'À propos',
    howItWorks:   'Comment ça marche',
    features:     'Fonctionnalités',
    downloadApp:  "Télécharger l'app",
    listBusiness: 'Inscrire votre commerce',
    backHome:     'Accueil',
  },
  hero: {
    badge:      'MONTRÉAL · SGW · CENTRE-VILLE',
    tagline:    'Livraison Rapide & Fiable',
    sub:        'Une plateforme de livraison pour les commerces indépendants du centre-ville de Montréal. Livraison à 5$. Commission de 10%. Zéro frais cachés.',
    cta1:       'Inscrivez votre commerce & protégez vos profits',
    cta2:       "Télécharger l'app & soutenir le local",
    stat1label: 'Livraison forfait',
    stat2label: 'Commission seule',
    stat3label: 'Livraison moy.',
    stat4label: 'Rayon de service',
  },
  about: {
    eyebrow:    'À propos de LocalGo',
    title:      'Une plateforme.\nTous les commerces locaux.',
    p1:         "LocalGo est une plateforme de livraison conçue pour le quartier du centre-ville de Montréal. Ancrée autour du campus SGW de Concordia, nous connectons étudiants, résidents et travailleurs aux restaurants, marchés et boutiques qui définissent le quartier.",
    p2:         "Nous gérons toute la logistique de livraison — pour que les commerces locaux puissent se concentrer sur leur cœur de métier tout en atteignant plus de clients via une application unifiée.",
    cta:        'Rejoindre notre réseau',
    card1title: 'Commerces indépendants uniquement',
    card1body:  'Nous nous associons exclusivement avec des commerces, restaurants et marchés locaux — sans franchises.',
    card2title: 'Logistique complète',
    card2body:  'Nous gérons les livreurs, les itinéraires et la livraison du dernier kilomètre pour vous.',
    card3title: 'Expérience client unifiée',
    card3body:  'Les clients commandent chez plusieurs marchands dans un seul panier, une seule caisse, une seule livraison.',
  },
  how: {
    eyebrow:  'Comment ça marche',
    title:    'Simple pour les commerces.\nFluide pour les clients.',
    s1title:  'Découvrez les commerces locaux',
    s1body:   'Les clients découvrent votre boutique aux côtés d\'autres commerces indépendants dans notre catalogue curated du centre-ville.',
    s2title:  'Une commande, plusieurs marchands',
    s2body:   'Un seul panier couvre restaurants, épiceries et boutiques spécialisées — une seule caisse, sans friction.',
    s3title:  'Livraison rapide et fiable',
    s3body:   'Nos livreurs couvrent la zone SGW et le centre-ville avec des délais de livraison constants.',
  },
  comparison: {
    eyebrow:    'Transparence',
    title:      'Pourquoi commander avec LocalGo\net oublier les grandes plateformes?',
    intro:      'Uber Eats et DoorDash profitent aux dépens du restaurant et du client. LocalGo est construit différemment.',
    badLabel:   'Uber Eats & DoorDash',
    goodLabel:  'LocalGo',
    goodBadge:  'Le choix de Montréal',
    bad: [
      '30% de commission prélevée sur les restaurants',
      'Les restaurants obligés d\'augmenter les prix en ligne',
      'Frais de livraison variables + frais de service cachés',
      'Votre repas peut coûter presque le double du prix affiché',
      'Données clients appartenant à la plateforme, pas à vous',
    ],
    good: [
      'Frais de livraison fixe 5$ pour les clients — toujours',
      'Seulement 10% de commission pour les commerces partenaires',
      'Vous payez le même prix qu\'au menu du restaurant',
      'Zéro frais cachés ou surprises en caisse',
      'Vos relations clients restent les vôtres',
    ],
    badSummary:  'Jusqu\'à 30% de commission + frais cachés — vous payez plus, les commerces gagnent moins.',
    goodSummary: 'Livraison fixe 5$ pour les clients · 10% de commission pour les commerces.',
    cta1: "Télécharger l'app & soutenir le local",
    cta2: 'Inscrire votre commerce',
  },
  features: {
    eyebrow: 'Fonctionnalités',
    title:   'Conçu pour les commerces locaux.',
    items: [
      { title: 'Focus sur le centre-ville',    body: 'Zones de livraison précises couvrant le corridor SGW, de Guy à Atwater et le centre-ville.' },
      { title: 'Livraison rapide',             body: 'Un routage optimisé maintient les délais de livraison moyens sous 30 minutes dans notre zone.' },
      { title: 'Modèle de revenus équitable',  body: 'Structure tarifaire transparente sans frais cachés. Votre croissance est notre croissance.' },
      { title: 'Alimentation, épicerie & plus',body: 'Une plateforme pour restaurants, dépanneurs, boulangeries, fleuristes et boutiques spécialisées.' },
      { title: 'Tableau de bord commercial',   body: "Suivi des commandes en temps réel, analyses des ventes et insights clients dans une interface unique." },
      { title: 'Support partenaire dédié',     body: "Une ligne directe avec votre gestionnaire de compte — pas une file d'attente." },
    ],
  },
  contact: {
    eyebrow:            'Partenariat',
    title:              'Prêt à élargir\nvotre portée?',
    body:               "Parlez-nous de votre commerce et nous vous contacterons dans un délai d'un jour ouvrable. Sans engagement.",
    labelName:          'Votre nom',
    labelBusiness:      'Nom du commerce',
    labelEmail:         'Adresse e-mail',
    labelType:          'Type de commerce',
    labelMessage:       'Parlez-nous de votre commerce',
    placeholderName:    'Jane Smith',
    placeholderBusiness:'Café du Coin',
    placeholderEmail:   'vous@votrecommerce.com',
    placeholderMessage: 'Emplacement, volume de commandes journalier, tout ce que nous devrions savoir.',
    typeOptions:        ['Restaurant', 'Épicerie / Marché', 'Boulangerie / Café', 'Boutique spécialisée', 'Autre'],
    submit:             'Envoyer la demande',
    successH3:          'Message reçu.',
    successP:           'Nous vous contacterons dans un jour ouvrable.',
  },
  marketplace: {
    eyebrow:         'Marché',
    title:           'Commandez auprès des commerces\nlocaux qui vous tiennent à cœur.',
    sub:             'Livraison fixe 5$ · Dans un rayon de 3 km de SGW · Sans frais cachés',
    filters:         ['Tous', 'Restaurant', 'Épicerie / Marché', 'Boulangerie / Café', 'Boutique spécialisée'],
    statusOpen:      'Ouvert',
    statusBusy:      'Occupé',
    statusComing:    'Bientôt',
    browseBtn:       'Explorer & commander',
    launchingSoon:   'Lancement prochain',
    partnerSingular: 'partenaire',
    partnerPlural:   'partenaires',
    ctaH3:           'Votre commerce n\'est pas dans la liste?',
    ctaP:            'Rejoignez notre réseau et atteignez plus de clients dans votre quartier.',
    ctaBtn:          'Inscrire votre commerce',
  },
  register: {
    eyebrow:                 'Inscription partenaire',
    title:                   'Inscrivez votre commerce.\nProtégez vos profits.',
    sub:                     'Rejoignez le réseau de livraison local de Montréal. Sans frais cachés. Sans compromis.',
    perksTitle:              'Pourquoi devenir partenaire de LocalGo?',
    perk1title:              'Seulement 10% de commission',
    perk1body:               'Gardez 90% de chaque commande. Pas de frais d\'installation, pas de frais mensuels.',
    perk2title:              'Intégration rapide',
    perk2body:               'Soyez en ligne dans les 48 heures suivant la soumission de vos informations.',
    perk3title:              'Vos données, vos clients',
    perk3body:               'Nous ne vendons ni ne partageons jamais vos données clients avec des tiers.',
    perk4title:              'Support dédié',
    perk4body:               'Un vrai responsable de compte pour vous aider à croître dès le premier jour.',
    pricingDeliveryLabel:    'Livraison fixe\npour les clients',
    pricingCommissionLabel:  'Commission\npar commande',
    formTitle:               'Inscription commerciale',
    labelOwner:              'Nom du propriétaire / contact',
    labelBusinessName:       'Nom du commerce',
    labelEmail:              'Adresse e-mail',
    labelPhone:              'Numéro de téléphone',
    labelType:               'Type de commerce',
    labelAddress:            'Adresse / emplacement du commerce',
    labelDailyOrders:        'Nombre de commandes journalières estimé',
    labelDescription:        'Parlez-nous de votre commerce',
    placeholderOwner:        'Jane Smith',
    placeholderBusiness:     'Café du Coin',
    placeholderEmail:        'vous@votrecommerce.com',
    placeholderPhone:        '514-555-0199',
    placeholderAddress:      '123 rue Sainte-Catherine O, Montréal, QC',
    placeholderDescription:  'Vos offres, votre emplacement, tout besoin particulier…',
    typeOptions:             ['Restaurant', 'Épicerie / Marché', 'Boulangerie / Café', 'Boutique spécialisée', 'Autre'],
    dailyOrderOptions:       ['Moins de 20', '20–50', '50–100', '100+'],
    submit:                  'Soumettre l\'inscription',
    successH3:               'Demande reçue.',
    successP:                'Notre équipe vous contactera dans un jour ouvrable pour mettre votre commerce en ligne sur LocalGo.',
  },
  footer: {
    tagline:        'SERVICES DE LIVRAISON À MONTRÉAL',
    location:       'MONTRÉAL, QC',
    linkAbout:      'À propos',
    linkHow:        'Comment ça marche',
    linkFeatures:   'Fonctionnalités',
    linkMarketplace:'Marché',
    linkRegister:   'Inscrire un commerce',
    pricing:        'Livraison forfaitaire: 5$ (Dans un rayon de 3 km) \u00A0·\u00A0 Seulement 10% de commission – Zéro frais cachés',
    copyright:      'LocalGo. Tous droits réservés.',
  },
  modal: {
    title:      'Application Bientôt Disponible',
    comingSoon: 'Nous travaillons pour amener LocalGo sur iOS & Android.',
    note:       'Restez à l\'écoute — l\'application sera disponible très bientôt !',
  },
}

// ─── Arabic ───────────────────────────────────────────────────────────────

const ar: Translations = {
  nav: {
    about:        'حول',
    howItWorks:   'كيف يعمل',
    features:     'المميزات',
    downloadApp:  'تحميل التطبيق',
    listBusiness: 'أضف عملك',
    backHome:     'الرئيسية',
  },
  hero: {
    badge:      'مونتريال · SGW · وسط المدينة',
    tagline:    'توصيل سريع وموثوق',
    sub:        'منصة توصيل مبنية للمحلات المستقلة في وسط مدينة مونتريال. رسوم توصيل ثابتة 5$. عمولة 10%. بدون رسوم خفية.',
    cta1:       'سجّل عملك وأحمِ أرباحك',
    cta2:       'حمّل التطبيق وادعم المحلي',
    stat1label: 'رسوم التوصيل',
    stat2label: 'العمولة فقط',
    stat3label: 'متوسط التوصيل',
    stat4label: 'نطاق الخدمة',
  },
  about: {
    eyebrow:    'عن LocalGo',
    title:      'منصة واحدة.\nكل الأعمال المحلية.',
    p1:         'LocalGo منصة توصيل مبنية لحي وسط مدينة مونتريال. انطلاقاً من حرم SGW في جامعة كونكورديا، نربط الطلاب والسكان والعمال بالمطاعم والأسواق والمحلات التي تميّز المنطقة.',
    p2:         'نتولى إدارة كامل عمليات التوصيل — لتتمكن الأعمال المحلية من التركيز على ما تتقنه بينما تصل إلى المزيد من العملاء عبر تطبيق واحد موحّد.',
    cta:        'انضم إلى شبكتنا',
    card1title: 'أعمال مستقلة فقط',
    card1body:  'نتعاون حصرياً مع المحلات والمطاعم والأسواق المملوكة محلياً — بدون سلاسل.',
    card2title: 'لوجستيات متكاملة',
    card2body:  'ندير السائقين والتوجيه والتوصيل حتى آخر مسافة حتى تتفرغ لعملك.',
    card3title: 'تجربة عملاء موحّدة',
    card3body:  'يطلب العملاء من عدة تجار في سلة واحدة، دفعة واحدة، توصيلة واحدة.',
  },
  how: {
    eyebrow:  'كيف يعمل',
    title:    'بسيط للأعمال.\nسلس للعملاء.',
    s1title:  'تصفّح الأعمال المحلية',
    s1body:   'يكتشف العملاء متجرك إلى جانب أعمال مستقلة أخرى في كتالوجنا المختار لوسط مدينة مونتريال.',
    s2title:  'طلب واحد، تجار متعددون',
    s2body:   'سلة واحدة تشمل المطاعم والبقاليات والمحلات المتخصصة — دفعة واحدة، بدون تعقيد.',
    s3title:  'توصيل سريع وموثوق',
    s3body:   'يغطي سائقونا منطقة SGW ووسط المدينة بأوقات توصيل منتظمة.',
  },
  comparison: {
    eyebrow:    'الشفافية',
    title:      'لماذا تطلب مع LocalGo\nوتنسى شركات التوصيل الكبيرة؟',
    intro:      'Uber Eats وDoorDash يربحون على حساب المطعم والعميل معاً. LocalGo مبني بطريقة مختلفة.',
    badLabel:   'Uber Eats & DoorDash',
    goodLabel:  'LocalGo',
    goodBadge:  'خيار مونتريال',
    bad: [
      'عمولة 30% مأخوذة من المطاعم',
      'المطاعم مضطرة لرفع أسعار القائمة أونلاين',
      'رسوم توصيل متغيرة + رسوم خدمة خفية',
      'قد تكلف وجبتك ضعف سعرها الحقيقي',
      'بيانات عملائك تخص المنصة لا أنت',
    ],
    good: [
      'رسوم توصيل ثابتة 5$ للعملاء — دائماً',
      'عمولة 10% فقط للأعمال الشريكة',
      'تدفع نفس سعر قائمة المطعم الحقيقية',
      'صفر رسوم خفية أو مفاجآت عند الدفع',
      'علاقات عملائك تبقى ملكك',
    ],
    badSummary:  'حتى 30% عمولة + رسوم خفية — تدفع أكثر، الأعمال تكسب أقل.',
    goodSummary: 'توصيل ثابت 5$ للعملاء · عمولة 10% للأعمال.',
    cta1: 'حمّل التطبيق وادعم المحلي',
    cta2: 'سجّل عملك',
  },
  features: {
    eyebrow: 'المميزات',
    title:   'مبني للأعمال المحلية.',
    items: [
      { title: 'التركيز على وسط مونتريال',    body: 'مناطق توصيل دقيقة تغطي ممر SGW من Guy إلى Atwater ووسط المدينة.' },
      { title: 'توصيل سريع',                  body: 'التوجيه المحسّن يبقي متوسط وقت التوصيل أقل من 30 دقيقة في منطقة الخدمة.' },
      { title: 'نموذج إيرادات عادل',          body: 'هيكل رسوم شفاف بدون رسوم خفية. نموّك هو نموّنا.' },
      { title: 'طعام، بقالة والمزيد',         body: 'منصة واحدة للمطاعم والبقاليات والمخابز والزهور والمحلات المتخصصة.' },
      { title: 'لوحة تحكم الأعمال',          body: 'تتبع الطلبات الفوري وتحليلات المبيعات وبيانات العملاء في واجهة واحدة.' },
      { title: 'دعم شريك مخصص',              body: 'خط مباشر مع مدير حسابك — ليس طابور تذاكر.' },
    ],
  },
  contact: {
    eyebrow:            'تعاون معنا',
    title:              'هل أنت مستعد\nللنمو؟',
    body:               'أخبرنا عن عملك وسنتواصل معك خلال يوم عمل واحد. بدون التزام.',
    labelName:          'اسمك',
    labelBusiness:      'اسم العمل',
    labelEmail:         'البريد الإلكتروني',
    labelType:          'نوع العمل',
    labelMessage:       'أخبرنا عن عملك',
    placeholderName:    'محمد علي',
    placeholderBusiness:'مطعم الأصالة',
    placeholderEmail:   'you@yourbusiness.com',
    placeholderMessage: 'الموقع، حجم الطلبات اليومي، أي معلومات أخرى.',
    typeOptions:        ['مطعم', 'بقالة / سوق', 'مخبز / مقهى', 'محل متخصص', 'أخرى'],
    submit:             'إرسال طلب الشراكة',
    successH3:          'تم استلام رسالتك.',
    successP:           'سنتواصل معك خلال يوم عمل واحد.',
  },
  marketplace: {
    eyebrow:         'السوق',
    title:           'اطلب من الأعمال المحلية\nالتي تهمّك فعلاً.',
    sub:             'توصيل ثابت 5$ · ضمن 3 كم من SGW · بدون رسوم خفية',
    filters:         ['الكل', 'مطعم', 'بقالة / سوق', 'مخبز / مقهى', 'محل متخصص'],
    statusOpen:      'مفتوح الآن',
    statusBusy:      'مشغول',
    statusComing:    'قريباً',
    browseBtn:       'تصفّح واطلب',
    launchingSoon:   'الإطلاق قريباً',
    partnerSingular: 'شريك',
    partnerPlural:   'شركاء',
    ctaH3:           'عملك غير موجود في هذه القائمة؟',
    ctaP:            'انضم إلى شبكتنا وتواصل مع المزيد من العملاء في حيّك اليوم.',
    ctaBtn:          'سجّل عملك',
  },
  register: {
    eyebrow:                 'تسجيل الشريك',
    title:                   'سجّل عملك.\nأحمِ أرباحك.',
    sub:                     'انضم إلى شبكة التوصيل المحلية في مونتريال. بدون رسوم خفية. بدون تنازلات.',
    perksTitle:              'لماذا تشارك مع LocalGo؟',
    perk1title:              'عمولة 10% فقط',
    perk1body:               'احتفظ بـ 90% من كل طلب. بدون رسوم إعداد أو رسوم شهرية.',
    perk2title:              'إعداد سريع',
    perk2body:               'ابدأ العمل خلال 48 ساعة من تقديم معلوماتك.',
    perk3title:              'بياناتك، عملاؤك',
    perk3body:               'لا نبيع أو نشارك أبداً بيانات عملائك مع أطراف ثالثة.',
    perk4title:              'دعم مخصص',
    perk4body:               'مدير حساب حقيقي لمساعدتك على النمو من اليوم الأول.',
    pricingDeliveryLabel:    'رسوم التوصيل\nللعملاء',
    pricingCommissionLabel:  'العمولة\nلكل طلب',
    formTitle:               'تسجيل العمل',
    labelOwner:              'اسم المالك / جهة الاتصال',
    labelBusinessName:       'اسم العمل',
    labelEmail:              'البريد الإلكتروني',
    labelPhone:              'رقم الهاتف',
    labelType:               'نوع العمل',
    labelAddress:            'عنوان العمل / الموقع',
    labelDailyOrders:        'الطلبات اليومية المتوقعة',
    labelDescription:        'أخبرنا عن عملك',
    placeholderOwner:        'محمد علي',
    placeholderBusiness:     'مطعم الأصالة',
    placeholderEmail:        'you@yourbusiness.com',
    placeholderPhone:        '514-555-0199',
    placeholderAddress:      '123 Rue Sainte-Catherine O, Montreal, QC',
    placeholderDescription:  'ما تقدمه، موقعك، أي متطلبات خاصة…',
    typeOptions:             ['مطعم', 'بقالة / سوق', 'مخبز / مقهى', 'محل متخصص', 'أخرى'],
    dailyOrderOptions:       ['أقل من 20', '20–50', '50–100', 'أكثر من 100'],
    submit:                  'إرسال التسجيل',
    successH3:               'تم استلام طلبك.',
    successP:                'سيتواصل فريقنا معك خلال يوم عمل واحد لبدء عملك على LocalGo.',
  },
  footer: {
    tagline:        'خدمات التوصيل في مونتريال',
    location:       'مونتريال، كيبيك',
    linkAbout:      'حول',
    linkHow:        'كيف يعمل',
    linkFeatures:   'المميزات',
    linkMarketplace:'السوق',
    linkRegister:   'تسجيل عمل',
    pricing:        'توصيل بسعر ثابت: 5$ (ضمن 3 كم) \u00A0·\u00A0 عمولة 10% فقط – بدون رسوم خفية',
    copyright:      'LocalGo. جميع الحقوق محفوظة.',
  },
  modal: {
    title:      'التطبيق قادم قريباً',
    comingSoon: 'نعمل بجد لإطلاق LocalGo على iOS وAndroid.',
    note:       'ترقّبوا — سيكون التطبيق متاحاً قريباً جداً!',
  },
}

// ─── Exported map ─────────────────────────────────────────────────────────

export const translations: Record<Lang, Translations> = { en, fr, ar }
