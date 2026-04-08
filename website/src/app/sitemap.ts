import type { MetadataRoute } from 'next';
import { SITE_URL } from '@/lib/site';

/** Required for `output: 'export'` (Next 15+) */
export const dynamic = 'force-static';

/** หน้าที่ต้องการให้ index — ไม่รวม /admin */
const PATHS: { path: string; changeFrequency: MetadataRoute.Sitemap[0]['changeFrequency']; priority: number }[] = [
  { path: '/', changeFrequency: 'weekly', priority: 1 },
  { path: '/th/', changeFrequency: 'weekly', priority: 0.95 },
  { path: '/support/', changeFrequency: 'weekly', priority: 0.8 },
  { path: '/privacy/', changeFrequency: 'monthly', priority: 0.6 },
  { path: '/terms/', changeFrequency: 'monthly', priority: 0.6 },
  { path: '/eula/', changeFrequency: 'monthly', priority: 0.5 },
];

export default function sitemap(): MetadataRoute.Sitemap {
  const lastModified = new Date();
  return PATHS.map(({ path, changeFrequency, priority }) => ({
    url: `${SITE_URL}${path === '/' ? '/' : path}`,
    lastModified,
    changeFrequency,
    priority,
  }));
}
