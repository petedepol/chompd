import '../models/service_pricing.dart';
import '../models/subscription.dart';
import '../services/exchange_rate_service.dart';

/// ~45 services with known pricing tiers across 4 currencies.
const List<ServiceInfo> servicePricingData = [
  // ─── Streaming ───
  ServiceInfo(
    name: 'Netflix',
    slug: 'netflix',
    category: 'streaming',
    brandColor: '#E50914',
    iconLetter: 'N',
    fallbackCurrency: 'USD',
    tiers: [
      ServiceTier(tier: 'Standard with Ads', gbp: 4.99, usd: 7.99, eur: 5.99, pln: 33.0),
      ServiceTier(tier: 'Standard', gbp: 10.99, usd: 17.99, eur: 13.99, pln: 49.0),
      ServiceTier(tier: 'Premium', gbp: 17.99, usd: 24.99, eur: 19.99, pln: 67.0),
    ],
  ),
  ServiceInfo(
    name: 'Disney+',
    slug: 'disney_plus',
    category: 'streaming',
    brandColor: '#113CCF',
    iconLetter: 'D+',
    fallbackCurrency: 'USD',
    tiers: [
      ServiceTier(tier: 'Standard', gbp: 8.99, gbpYr: 89.9, usd: 15.99, usdYr: 159.99, eur: 9.99, eurYr: 99.9, pln: 34.99, plnYr: 349.9),
      ServiceTier(tier: 'Premium', gbp: 12.99, gbpYr: 129.9, usd: 18.99, usdYr: 189.99, eur: 14.99, eurYr: 149.9, pln: 59.99, plnYr: 599.9),
    ],
  ),
  ServiceInfo(
    name: 'Amazon Prime Video',
    slug: 'prime_video',
    category: 'streaming',
    brandColor: '#00A8E1',
    iconLetter: 'P',
    fallbackCurrency: 'USD',
    tiers: [
      ServiceTier(tier: 'Prime (includes Video)', gbp: 8.99, gbpYr: 95.0, usd: 14.99, usdYr: 139.0, eur: 8.99, eurYr: 89.9),
    ],
  ),
  ServiceInfo(
    name: 'Apple TV+',
    slug: 'apple_tv',
    category: 'streaming',
    brandColor: '#000000',
    iconLetter: 'tv',
    fallbackCurrency: 'USD',
    tiers: [
      ServiceTier(tier: 'Individual', gbp: 8.99, gbpYr: 89.0, usd: 12.99, usdYr: 129.0, eur: 9.99, eurYr: 99.0, pln: 37.99),
    ],
  ),
  ServiceInfo(
    name: 'YouTube Premium',
    slug: 'youtube_premium',
    category: 'streaming',
    brandColor: '#FF0000',
    iconLetter: 'Y',
    fallbackCurrency: 'USD',
    tiers: [
      ServiceTier(tier: 'Individual', gbp: 12.99, gbpYr: 129.99, usd: 13.99, usdYr: 139.99, eur: 13.99, eurYr: 139.99, pln: 26.99, plnYr: 269.9),
      ServiceTier(tier: 'Family', gbp: 22.99, gbpYr: 229.99, usd: 22.99, usdYr: 229.99, eur: 29.99, pln: 43.99),
    ],
  ),
  ServiceInfo(
    name: 'Paramount+',
    slug: 'paramount_plus',
    category: 'streaming',
    brandColor: '#0064FF',
    iconLetter: 'P+',
    fallbackCurrency: 'USD',
    tiers: [
      ServiceTier(tier: 'Essential', gbp: 4.99, gbpYr: 49.9, usd: 8.99, eur: 7.99),
      ServiceTier(tier: 'Premium', gbp: 7.99, usd: 13.99, eur: 10.99),
    ],
  ),
  ServiceInfo(
    name: 'Crunchyroll',
    slug: 'crunchyroll',
    category: 'streaming',
    brandColor: '#F47521',
    iconLetter: 'CR',
    fallbackCurrency: 'USD',
    tiers: [
      ServiceTier(tier: 'Fan', gbp: 4.99, gbpYr: 49.99, usd: 7.99, usdYr: 79.99, eur: 6.99, eurYr: 69.99),
      ServiceTier(tier: 'Mega Fan', gbp: 6.99, gbpYr: 69.99, usd: 9.99, usdYr: 99.99, eur: 9.99, eurYr: 99.99),
    ],
  ),
  ServiceInfo(
    name: 'NOW (Sky)',
    slug: 'now_sky',
    category: 'streaming',
    brandColor: '#2DDA78',
    iconLetter: 'N',
    fallbackCurrency: 'GBP',
    tiers: [
      ServiceTier(tier: 'Entertainment', gbp: 6.99),
      ServiceTier(tier: 'Cinema', gbp: 6.99),
    ],
  ),

  // ─── Music ───
  ServiceInfo(
    name: 'Spotify',
    slug: 'spotify',
    category: 'music',
    brandColor: '#1DB954',
    iconLetter: 'S',
    fallbackCurrency: 'EUR',
    tiers: [
      ServiceTier(tier: 'Individual', gbp: 12.99, usd: 11.99, eur: 12.99, pln: 26.99),
      ServiceTier(tier: 'Duo', gbp: 17.99, usd: 16.99, eur: 17.99, pln: 36.99),
      ServiceTier(tier: 'Family', gbp: 21.99, usd: 19.99, eur: 21.99, pln: 45.99),
      ServiceTier(tier: 'Student', gbp: 6.49, usd: 5.99, eur: 6.99, pln: 14.49),
    ],
  ),
  ServiceInfo(
    name: 'Apple Music',
    slug: 'apple_music',
    category: 'music',
    brandColor: '#FA233B',
    iconLetter: '\u266a',
    fallbackCurrency: 'USD',
    tiers: [
      ServiceTier(tier: 'Individual', gbp: 10.99, gbpYr: 109.0, usd: 10.99, usdYr: 109.0, eur: 10.99, eurYr: 109.0, pln: 24.99),
      ServiceTier(tier: 'Family', gbp: 16.99, gbpYr: 169.0, usd: 16.99, usdYr: 169.0, eur: 16.99, eurYr: 169.0, pln: 34.99),
      ServiceTier(tier: 'Student', gbp: 5.99, usd: 5.99, eur: 5.99, pln: 12.99),
    ],
  ),
  ServiceInfo(
    name: 'Tidal',
    slug: 'tidal',
    category: 'music',
    brandColor: '#000000',
    iconLetter: 'T',
    fallbackCurrency: 'USD',
    tiers: [
      ServiceTier(tier: 'Individual', gbp: 10.99, gbpYr: 109.99, usd: 10.99, usdYr: 109.99, eur: 10.99, eurYr: 109.99, pln: 24.99),
      ServiceTier(tier: 'Family', gbp: 16.99, gbpYr: 169.99, usd: 16.99, usdYr: 169.99, eur: 16.99, eurYr: 169.99, pln: 34.99),
    ],
  ),
  ServiceInfo(
    name: 'Amazon Music Unlimited',
    slug: 'amazon_music',
    category: 'music',
    brandColor: '#25D1DA',
    iconLetter: 'AM',
    fallbackCurrency: 'USD',
    tiers: [
      ServiceTier(tier: 'Individual', gbp: 10.99, gbpYr: 99.0, usd: 10.99, usdYr: 99.0, eur: 10.99, eurYr: 99.0),
    ],
  ),
  ServiceInfo(
    name: 'Deezer',
    slug: 'deezer',
    category: 'music',
    brandColor: '#A238FF',
    iconLetter: 'D',
    fallbackCurrency: 'EUR',
    tiers: [
      ServiceTier(tier: 'Premium', gbp: 10.99, gbpYr: 109.99, usd: 10.99, usdYr: 109.99, eur: 10.99, eurYr: 109.99, pln: 23.99),
      ServiceTier(tier: 'Family', gbp: 17.99, gbpYr: 179.99, usd: 17.99, usdYr: 179.99, eur: 17.99, eurYr: 179.99, pln: 39.99),
    ],
  ),

  // ─── Storage ───
  ServiceInfo(
    name: 'iCloud+',
    slug: 'icloud',
    category: 'storage',
    brandColor: '#3693F5',
    iconLetter: 'iC',
    fallbackCurrency: 'USD',
    tiers: [
      ServiceTier(tier: '50 GB', gbp: 0.99, usd: 0.99, eur: 0.99, pln: 3.99),
      ServiceTier(tier: '200 GB', gbp: 2.99, usd: 2.99, eur: 2.99, pln: 12.99),
      ServiceTier(tier: '2 TB', gbp: 8.99, usd: 9.99, eur: 9.99, pln: 42.99),
    ],
  ),
  ServiceInfo(
    name: 'Google One',
    slug: 'google_one',
    category: 'storage',
    brandColor: '#4285F4',
    iconLetter: 'G1',
    fallbackCurrency: 'USD',
    tiers: [
      ServiceTier(tier: '100 GB', gbp: 1.99, gbpYr: 19.99, usd: 2.99, usdYr: 29.99, eur: 2.99, eurYr: 29.99, pln: 8.99, plnYr: 89.99),
      ServiceTier(tier: '2 TB', gbp: 7.99, gbpYr: 79.99, usd: 9.99, usdYr: 99.99, eur: 9.99, eurYr: 99.99, pln: 45.99, plnYr: 459.99),
    ],
  ),
  ServiceInfo(
    name: 'Dropbox',
    slug: 'dropbox',
    category: 'storage',
    brandColor: '#0061FF',
    iconLetter: 'Db',
    fallbackCurrency: 'USD',
    tiers: [
      ServiceTier(tier: 'Plus (2TB)', gbp: 9.99, gbpYr: 95.88, usd: 11.99, usdYr: 119.88, eur: 11.99, eurYr: 119.88),
    ],
  ),
  ServiceInfo(
    name: 'OneDrive (M365)',
    slug: 'onedrive',
    category: 'storage',
    brandColor: '#0078D4',
    iconLetter: 'OD',
    fallbackCurrency: 'USD',
    tiers: [
      ServiceTier(tier: 'Basic (100GB)', gbp: 1.99, gbpYr: 19.99, usd: 1.99, usdYr: 19.99, eur: 2.0, eurYr: 20.0),
    ],
  ),

  // ─── Productivity ───
  ServiceInfo(
    name: 'Microsoft 365',
    slug: 'microsoft_365',
    category: 'productivity',
    brandColor: '#D83B01',
    iconLetter: 'M',
    fallbackCurrency: 'USD',
    tiers: [
      ServiceTier(tier: 'Personal', gbp: 6.99, gbpYr: 59.99, usd: 6.99, usdYr: 69.99, eur: 7.0, eurYr: 69.0, pln: 29.99, plnYr: 299.0),
      ServiceTier(tier: 'Family', gbp: 9.99, gbpYr: 79.99, usd: 9.99, usdYr: 99.99, eur: 10.0, eurYr: 99.0, pln: 42.99, plnYr: 429.0),
    ],
  ),
  ServiceInfo(
    name: 'Adobe Creative Cloud',
    slug: 'adobe_cc',
    category: 'productivity',
    brandColor: '#FF0000',
    iconLetter: 'Ai',
    fallbackCurrency: 'USD',
    tiers: [
      ServiceTier(tier: 'Photography (PS+LR)', gbp: 9.98, gbpYr: 119.76, usd: 9.99, usdYr: 119.88, eur: 11.99, eurYr: 143.88),
      ServiceTier(tier: 'All Apps', gbp: 54.99, gbpYr: 659.88, usd: 59.99, usdYr: 659.88, eur: 63.49, eurYr: 737.88),
    ],
  ),
  ServiceInfo(
    name: 'Notion',
    slug: 'notion',
    category: 'productivity',
    brandColor: '#000000',
    iconLetter: 'N',
    fallbackCurrency: 'USD',
    tiers: [
      ServiceTier(tier: 'Plus', gbp: 7.5, gbpYr: 72.0, usd: 10.0, usdYr: 96.0, eur: 9.5, eurYr: 91.2),
    ],
  ),
  ServiceInfo(
    name: 'Canva',
    slug: 'canva',
    category: 'productivity',
    brandColor: '#00C4CC',
    iconLetter: 'Ca',
    fallbackCurrency: 'USD',
    tiers: [
      ServiceTier(tier: 'Pro', gbp: 10.99, gbpYr: 99.99, usd: 12.99, usdYr: 119.99, eur: 11.99, eurYr: 109.99),
    ],
  ),
  ServiceInfo(
    name: '1Password',
    slug: '1password',
    category: 'productivity',
    brandColor: '#0572EC',
    iconLetter: '1P',
    fallbackCurrency: 'USD',
    tiers: [
      ServiceTier(tier: 'Individual', gbp: 2.65, gbpYr: 31.8, usd: 2.99, usdYr: 35.88, eur: 2.99, eurYr: 35.88),
      ServiceTier(tier: 'Families', gbp: 4.65, gbpYr: 55.8, usd: 4.99, usdYr: 59.88, eur: 4.99, eurYr: 59.88),
    ],
  ),
  ServiceInfo(
    name: 'NordVPN',
    slug: 'nordvpn',
    category: 'productivity',
    brandColor: '#4687FF',
    iconLetter: 'NV',
    fallbackCurrency: 'USD',
    tiers: [
      ServiceTier(tier: 'Standard (1yr)', gbp: 3.39, gbpYr: 40.68, usd: 4.59, usdYr: 55.08, eur: 4.49, eurYr: 53.88),
    ],
  ),
  ServiceInfo(
    name: 'ExpressVPN',
    slug: 'expressvpn',
    category: 'productivity',
    brandColor: '#DA3940',
    iconLetter: 'EV',
    fallbackCurrency: 'USD',
    tiers: [
      ServiceTier(tier: '12-month', gbp: 6.32, gbpYr: 75.84, usd: 8.32, usdYr: 99.84, eur: 7.77, eurYr: 93.24),
    ],
  ),

  // ─── AI ───
  ServiceInfo(
    name: 'ChatGPT Plus',
    slug: 'chatgpt',
    category: 'ai',
    brandColor: '#10A37F',
    iconLetter: 'C',
    fallbackCurrency: 'USD',
    tiers: [
      ServiceTier(tier: 'Plus', gbp: 20.0, gbpYr: 200.0, usd: 20.0, usdYr: 200.0, eur: 20.0, eurYr: 200.0, pln: 99.99, plnYr: 999.99),
    ],
  ),
  ServiceInfo(
    name: 'Claude Pro',
    slug: 'claude',
    category: 'ai',
    brandColor: '#D4A27F',
    iconLetter: 'C',
    fallbackCurrency: 'USD',
    tiers: [
      ServiceTier(tier: 'Pro', gbp: 18.0, usd: 20.0, eur: 20.0),
    ],
  ),
  ServiceInfo(
    name: 'Midjourney',
    slug: 'midjourney',
    category: 'ai',
    brandColor: '#000000',
    iconLetter: 'MJ',
    fallbackCurrency: 'USD',
    tiers: [
      ServiceTier(tier: 'Basic', gbp: 8.0, gbpYr: 80.0, usd: 10.0, usdYr: 96.0, eur: 10.0, eurYr: 96.0),
      ServiceTier(tier: 'Standard', gbp: 24.0, gbpYr: 240.0, usd: 30.0, usdYr: 288.0, eur: 30.0, eurYr: 288.0),
    ],
  ),
  ServiceInfo(
    name: 'GitHub Copilot',
    slug: 'github_copilot',
    category: 'ai',
    brandColor: '#000000',
    iconLetter: 'GH',
    fallbackCurrency: 'USD',
    tiers: [
      ServiceTier(tier: 'Individual', gbp: 8.0, gbpYr: 80.0, usd: 10.0, usdYr: 100.0, eur: 10.0, eurYr: 100.0),
    ],
  ),
  ServiceInfo(
    name: 'Perplexity Pro',
    slug: 'perplexity',
    category: 'ai',
    brandColor: '#20B8CD',
    iconLetter: 'Px',
    fallbackCurrency: 'USD',
    tiers: [
      ServiceTier(tier: 'Pro', gbp: 17.0, gbpYr: 170.0, usd: 20.0, usdYr: 200.0, eur: 20.0, eurYr: 200.0),
    ],
  ),

  // ─── Fitness ───
  ServiceInfo(
    name: 'Strava',
    slug: 'strava',
    category: 'fitness',
    brandColor: '#FC4C02',
    iconLetter: 'S',
    fallbackCurrency: 'USD',
    tiers: [
      ServiceTier(tier: 'Subscriber', gbp: 6.99, gbpYr: 59.99, usd: 11.99, usdYr: 79.99, eur: 8.99, eurYr: 59.99, pln: 29.99),
    ],
  ),
  ServiceInfo(
    name: 'Apple Fitness+',
    slug: 'apple_fitness',
    category: 'fitness',
    brandColor: '#A2E03E',
    iconLetter: 'F+',
    fallbackCurrency: 'USD',
    tiers: [
      ServiceTier(tier: 'Individual', gbp: 9.99, gbpYr: 79.99, usd: 9.99, usdYr: 79.99, eur: 9.99, eurYr: 79.99, pln: 37.99),
    ],
  ),
  ServiceInfo(
    name: 'Peloton',
    slug: 'peloton',
    category: 'fitness',
    brandColor: '#000000',
    iconLetter: 'P',
    fallbackCurrency: 'USD',
    tiers: [
      ServiceTier(tier: 'App', gbp: 12.99, usd: 13.99),
    ],
  ),
  ServiceInfo(
    name: 'MyFitnessPal',
    slug: 'myfitnesspal',
    category: 'fitness',
    brandColor: '#0070D1',
    iconLetter: 'MF',
    fallbackCurrency: 'USD',
    tiers: [
      ServiceTier(tier: 'Premium', gbp: 15.99, gbpYr: 59.99, usd: 19.99, usdYr: 79.99, eur: 15.99, eurYr: 59.99),
    ],
  ),
  ServiceInfo(
    name: 'Headspace',
    slug: 'headspace',
    category: 'fitness',
    brandColor: '#F47D31',
    iconLetter: 'H',
    fallbackCurrency: 'USD',
    tiers: [
      ServiceTier(tier: 'Individual', gbp: 9.99, gbpYr: 49.99, usd: 12.99, usdYr: 69.99, eur: 12.99, eurYr: 59.99),
    ],
  ),
  ServiceInfo(
    name: 'Calm',
    slug: 'calm',
    category: 'fitness',
    brandColor: '#4285F4',
    iconLetter: 'Ca',
    fallbackCurrency: 'USD',
    tiers: [
      ServiceTier(tier: 'Premium', gbp: 11.99, gbpYr: 49.99, usd: 14.99, usdYr: 69.99, eur: 14.99, eurYr: 59.99),
    ],
  ),

  // ─── Gaming ───
  ServiceInfo(
    name: 'Xbox Game Pass',
    slug: 'xbox_gamepass',
    category: 'gaming',
    brandColor: '#107C10',
    iconLetter: 'X',
    fallbackCurrency: 'USD',
    tiers: [
      ServiceTier(tier: 'Core', gbp: 6.99, usd: 9.99, eur: 7.99, pln: 29.99),
      ServiceTier(tier: 'Standard', gbp: 10.99, usd: 14.99, eur: 12.99, pln: 46.99),
      ServiceTier(tier: 'Ultimate', gbp: 14.99, usd: 19.99, eur: 17.99, pln: 62.99),
    ],
  ),
  ServiceInfo(
    name: 'PlayStation Plus',
    slug: 'ps_plus',
    category: 'gaming',
    brandColor: '#003791',
    iconLetter: 'PS',
    fallbackCurrency: 'USD',
    tiers: [
      ServiceTier(tier: 'Essential', gbp: 6.99, gbpYr: 49.99, usd: 9.99, usdYr: 79.99, eur: 8.99, eurYr: 59.99, pln: 29.0, plnYr: 200.0),
      ServiceTier(tier: 'Extra', gbp: 10.99, gbpYr: 99.99, usd: 14.99, usdYr: 134.99, eur: 13.99, eurYr: 119.99, pln: 49.0, plnYr: 400.0),
      ServiceTier(tier: 'Premium', gbp: 13.49, gbpYr: 119.99, usd: 17.99, usdYr: 159.99, eur: 16.99, eurYr: 149.99, pln: 59.0, plnYr: 480.0),
    ],
  ),
  ServiceInfo(
    name: 'Nintendo Switch Online',
    slug: 'nintendo_online',
    category: 'gaming',
    brandColor: '#E60012',
    iconLetter: 'NS',
    fallbackCurrency: 'USD',
    tiers: [
      ServiceTier(tier: 'Individual', gbp: 3.49, gbpYr: 17.99, usd: 3.99, usdYr: 19.99, eur: 3.99, eurYr: 19.99),
    ],
  ),
  ServiceInfo(
    name: 'EA Play',
    slug: 'ea_play',
    category: 'gaming',
    brandColor: '#000000',
    iconLetter: 'EA',
    fallbackCurrency: 'USD',
    tiers: [
      ServiceTier(tier: 'Standard', gbp: 3.99, gbpYr: 24.99, usd: 5.99, usdYr: 39.99, eur: 4.99, eurYr: 29.99, pln: 19.99),
    ],
  ),
  ServiceInfo(
    name: 'Apple Arcade',
    slug: 'apple_arcade',
    category: 'gaming',
    brandColor: '#0070C9',
    iconLetter: 'AA',
    fallbackCurrency: 'USD',
    tiers: [
      ServiceTier(tier: 'Individual', gbp: 6.99, gbpYr: 69.0, usd: 6.99, usdYr: 49.99, eur: 6.99, eurYr: 69.0, pln: 27.99),
    ],
  ),

  // ─── Reading ───
  ServiceInfo(
    name: 'Kindle Unlimited',
    slug: 'kindle_unlimited',
    category: 'reading',
    brandColor: '#FF9900',
    iconLetter: 'K',
    fallbackCurrency: 'USD',
    tiers: [
      ServiceTier(tier: 'Standard', gbp: 9.99, usd: 11.99, eur: 9.99),
    ],
  ),
  ServiceInfo(
    name: 'Audible',
    slug: 'audible',
    category: 'reading',
    brandColor: '#F8991C',
    iconLetter: 'Au',
    fallbackCurrency: 'USD',
    tiers: [
      ServiceTier(tier: 'Premium Plus', gbp: 7.99, usd: 14.95, eur: 9.95),
    ],
  ),
  ServiceInfo(
    name: 'Apple News+',
    slug: 'apple_news',
    category: 'reading',
    brandColor: '#FC3158',
    iconLetter: 'N+',
    fallbackCurrency: 'USD',
    tiers: [
      ServiceTier(tier: 'Individual', gbp: 12.99, usd: 12.99),
    ],
  ),
  ServiceInfo(
    name: 'Medium',
    slug: 'medium',
    category: 'reading',
    brandColor: '#000000',
    iconLetter: 'M',
    fallbackCurrency: 'USD',
    tiers: [
      ServiceTier(tier: 'Member', gbp: 4.53, gbpYr: 45.29, usd: 5.0, usdYr: 50.0, eur: 4.8, eurYr: 48.0),
    ],
  ),

  // ─── Communication ───
  ServiceInfo(
    name: 'Zoom',
    slug: 'zoom',
    category: 'communication',
    brandColor: '#0B5CFF',
    iconLetter: 'Z',
    fallbackCurrency: 'USD',
    tiers: [
      ServiceTier(tier: 'Pro', gbp: 10.59, gbpYr: 105.9, usd: 13.33, usdYr: 159.9, eur: 13.19, eurYr: 131.9),
    ],
  ),
  ServiceInfo(
    name: 'Discord Nitro',
    slug: 'discord_nitro',
    category: 'communication',
    brandColor: '#5865F2',
    iconLetter: 'D',
    fallbackCurrency: 'USD',
    tiers: [
      ServiceTier(tier: 'Nitro Basic', gbp: 2.49, gbpYr: 24.99, usd: 2.99, usdYr: 29.99, eur: 2.99, eurYr: 29.99),
      ServiceTier(tier: 'Nitro', gbp: 8.49, gbpYr: 84.99, usd: 9.99, usdYr: 99.99, eur: 9.99, eurYr: 99.99),
    ],
  ),
  ServiceInfo(
    name: 'Slack',
    slug: 'slack',
    category: 'communication',
    brandColor: '#4A154B',
    iconLetter: 'S',
    fallbackCurrency: 'USD',
    tiers: [
      ServiceTier(tier: 'Pro (per user)', gbp: 5.75, gbpYr: 58.5, usd: 8.75, usdYr: 87.5, eur: 7.25, eurYr: 72.5),
    ],
  ),

  // ─── Bundle ───
  ServiceInfo(
    name: 'Apple One',
    slug: 'apple_one',
    category: 'bundle',
    brandColor: '#000000',
    iconLetter: 'A1',
    fallbackCurrency: 'USD',
    tiers: [
      ServiceTier(tier: 'Individual', gbp: 18.95, usd: 19.95, eur: 19.95),
      ServiceTier(tier: 'Family', gbp: 24.95, usd: 25.95, eur: 25.95),
    ],
  ),

  // ─── Developer ───
  ServiceInfo(
    name: 'GitHub Pro',
    slug: 'github',
    category: 'developer',
    brandColor: '#181717',
    iconLetter: 'GH',
    fallbackCurrency: 'USD',
    tiers: [
      ServiceTier(tier: 'Pro', gbp: 3.25, gbpYr: 33.0, usd: 4.0, usdYr: 44.0, eur: 4.0, eurYr: 44.0),
    ],
  ),
  ServiceInfo(
    name: 'Figma',
    slug: 'figma',
    category: 'developer',
    brandColor: '#F24E1E',
    iconLetter: 'Fi',
    fallbackCurrency: 'USD',
    tiers: [
      ServiceTier(tier: 'Professional', gbp: 12.0, gbpYr: 132.0, usd: 15.0, usdYr: 144.0, eur: 15.0, eurYr: 144.0),
    ],
  ),
];

// ─── Name Matching ───

/// Alias map for fuzzy name matching. Keys are normalised lowercase.
const Map<String, String> _serviceAliases = {
  // Streaming
  'amazon prime': 'prime_video',
  'prime video': 'prime_video',
  'amazon prime video': 'prime_video',
  'prime': 'prime_video',
  'disney plus': 'disney_plus',
  'disney+': 'disney_plus',
  'disneyplus': 'disney_plus',
  'apple tv': 'apple_tv',
  'apple tv+': 'apple_tv',
  'appletv': 'apple_tv',
  'youtube premium': 'youtube_premium',
  'yt premium': 'youtube_premium',
  'youtube': 'youtube_premium',
  'paramount plus': 'paramount_plus',
  'paramount+': 'paramount_plus',
  'now tv': 'now_sky',
  'now': 'now_sky',
  'sky now': 'now_sky',
  // Music
  'apple music': 'apple_music',
  'amazon music': 'amazon_music',
  'amazon music unlimited': 'amazon_music',
  // Storage
  'icloud': 'icloud',
  'icloud+': 'icloud',
  'icloud plus': 'icloud',
  'google one': 'google_one',
  'onedrive': 'onedrive',
  'one drive': 'onedrive',
  // Productivity
  'microsoft 365': 'microsoft_365',
  'office 365': 'microsoft_365',
  'ms 365': 'microsoft_365',
  'adobe cc': 'adobe_cc',
  'adobe creative cloud': 'adobe_cc',
  'photoshop': 'adobe_cc',
  'lightroom': 'adobe_cc',
  '1password': '1password',
  'onepassword': '1password',
  'nord vpn': 'nordvpn',
  'express vpn': 'expressvpn',
  // AI
  'chatgpt': 'chatgpt',
  'chatgpt plus': 'chatgpt',
  'openai': 'chatgpt',
  'gpt plus': 'chatgpt',
  'claude': 'claude',
  'claude pro': 'claude',
  'anthropic': 'claude',
  'github copilot': 'github_copilot',
  'copilot': 'github_copilot',
  'perplexity': 'perplexity',
  'perplexity pro': 'perplexity',
  // Fitness
  'apple fitness': 'apple_fitness',
  'apple fitness+': 'apple_fitness',
  'my fitness pal': 'myfitnesspal',
  // Gaming
  'xbox game pass': 'xbox_gamepass',
  'game pass': 'xbox_gamepass',
  'gamepass': 'xbox_gamepass',
  'playstation plus': 'ps_plus',
  'ps plus': 'ps_plus',
  'ps+': 'ps_plus',
  'psn': 'ps_plus',
  'playstation': 'ps_plus',
  'nintendo online': 'nintendo_online',
  'nintendo switch online': 'nintendo_online',
  'ea play': 'ea_play',
  'apple arcade': 'apple_arcade',
  // Reading
  'kindle': 'kindle_unlimited',
  'kindle unlimited': 'kindle_unlimited',
  'apple news': 'apple_news',
  'apple news+': 'apple_news',
  // Communication
  'discord': 'discord_nitro',
  'discord nitro': 'discord_nitro',
  'nitro': 'discord_nitro',
  // Developer
  'github': 'github',
  'github pro': 'github',
};

/// Find a [ServiceInfo] matching the user's subscription name.
/// Returns null if no match found.
ServiceInfo? findServiceByName(String name) {
  final normalised = name.toLowerCase().trim();

  // 1. Exact slug match
  final slug = normalised.replaceAll(' ', '_');
  for (final s in servicePricingData) {
    if (s.slug == slug) return s;
  }

  // 2. Alias match
  final aliasSlug = _serviceAliases[normalised];
  if (aliasSlug != null) {
    for (final s in servicePricingData) {
      if (s.slug == aliasSlug) return s;
    }
  }

  // 3. Exact name match (case-insensitive)
  for (final s in servicePricingData) {
    if (s.name.toLowerCase() == normalised) return s;
  }

  // 4. Partial match — name contains query or query contains name
  for (final s in servicePricingData) {
    final sLower = s.name.toLowerCase();
    if (normalised.contains(sLower) || sLower.contains(normalised)) {
      return s;
    }
  }

  return null;
}

/// Find the tier whose monthly price is closest to the user's actual price.
ServiceTier? findBestTier(
  Subscription sub,
  ServiceInfo service,
  String displayCurrency,
) {
  if (service.tiers.isEmpty) return null;
  if (service.tiers.length == 1) return service.tiers.first;

  final userMonthly = sub.monthlyEquivalentIn(displayCurrency);
  ServiceTier? best;
  double bestDiff = double.infinity;

  for (final tier in service.tiers) {
    final tierMonthly = resolveMonthlyPrice(tier, service, displayCurrency);
    if (tierMonthly == null) continue;
    final diff = (tierMonthly - userMonthly).abs();
    if (diff < bestDiff) {
      bestDiff = diff;
      best = tier;
    }
  }

  return best;
}

/// Get a tier's monthly price in the display currency, with fallback chain.
double? resolveMonthlyPrice(
  ServiceTier tier,
  ServiceInfo service,
  String displayCurrency,
) {
  // Direct match
  final direct = tier.monthlyPrice(displayCurrency);
  if (direct != null) return direct;

  // Fallback currency from service definition
  final fb = tier.monthlyPrice(service.fallbackCurrency);
  if (fb != null) {
    return ExchangeRateService.instance.convert(
      fb,
      service.fallbackCurrency,
      displayCurrency,
    );
  }

  // Last resort: try GBP, then USD
  for (final code in ['GBP', 'USD']) {
    final p = tier.monthlyPrice(code);
    if (p != null) {
      return ExchangeRateService.instance.convert(p, code, displayCurrency);
    }
  }

  return null;
}

/// Get a tier's annual price in the display currency, with fallback chain.
double? resolveAnnualPrice(
  ServiceTier tier,
  ServiceInfo service,
  String displayCurrency,
) {
  final direct = tier.annualPrice(displayCurrency);
  if (direct != null) return direct;

  final fb = tier.annualPrice(service.fallbackCurrency);
  if (fb != null) {
    return ExchangeRateService.instance.convert(
      fb,
      service.fallbackCurrency,
      displayCurrency,
    );
  }

  for (final code in ['GBP', 'USD']) {
    final p = tier.annualPrice(code);
    if (p != null) {
      return ExchangeRateService.instance.convert(p, code, displayCurrency);
    }
  }

  return null;
}

/// Resolve monthly + annual prices from the SAME currency source.
///
/// This prevents mixed-currency comparisons where e.g. monthly comes from
/// a direct PLN price but annual falls back to a USD→PLN conversion,
/// producing bogus savings figures.
({double monthly, double annual})? resolvePricePair(
  ServiceTier tier,
  ServiceInfo service,
  String displayCurrency,
) {
  // Try each currency source in priority order; both must exist
  final sources = [
    displayCurrency,
    service.fallbackCurrency,
    'GBP',
    'USD',
  ];

  for (final code in sources) {
    final m = tier.monthlyPrice(code);
    final a = tier.annualPrice(code);
    if (m != null && a != null) {
      if (code == displayCurrency) {
        return (monthly: m, annual: a);
      }
      final fx = ExchangeRateService.instance;
      return (
        monthly: fx.convert(m, code, displayCurrency),
        annual: fx.convert(a, code, displayCurrency),
      );
    }
  }

  return null;
}
