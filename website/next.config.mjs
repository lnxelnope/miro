/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'export',
  basePath: '/miro',
  images: {
    unoptimized: true,
  },
  trailingSlash: true,
};

export default nextConfig;
