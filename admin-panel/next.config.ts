import type { NextConfig } from "next";
import path from "node:path";
import { fileURLToPath } from "node:url";

/** App root (admin-panel). Stops Turbopack/Webpack from resolving deps from parent `miro/`. */
const appRoot = path.dirname(fileURLToPath(import.meta.url));

const nextConfig: NextConfig = {
  /* config options here */
  reactCompiler: true,
  // Enable standalone output for Docker
  output: "standalone",
  async redirects() {
    return [{ source: '/dashboard', destination: '/', permanent: false }];
  },
  // Fix: `@import "tailwindcss"` was resolved from `miro/` (no node_modules) instead of here.
  turbopack: {
    root: appRoot,
  },
  webpack: (config) => {
    const localNodeModules = path.join(appRoot, "node_modules");
    config.resolve.modules = [
      localNodeModules,
      ...(Array.isArray(config.resolve.modules)
        ? config.resolve.modules
        : ["node_modules"]),
    ];
    return config;
  },
};

export default nextConfig;
