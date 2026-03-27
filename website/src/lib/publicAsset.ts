/**
 * Prefix paths to files in `public/` with `basePath`.
 * Required for `next/image` + `output: 'export'`: prerendered HTML otherwise
 * emits `/arcal/...` instead of `/miro/arcal/...` and images 404 on Firebase Hosting.
 */
export function publicAsset(path: string): string {
  const prefix = process.env.NEXT_PUBLIC_BASE_PATH ?? '';
  const p = path.startsWith('/') ? path : `/${path}`;
  return `${prefix}${p}`;
}
